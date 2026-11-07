#!/usr/bin/env bash
# Bozma (mutasyon) testi: güvenlik ve kabul iddialarını taşıyan DB testleri, korudukları kod bozulunca kırmızıya dönüyor mu?
# Her bozma, migration'ların bir KOPYASINDA tek bir sed değişikliği yapar ve kopyada yerel-kurulum.sh çalıştırır.
# Sonuçlar:
#   ÖLDÜ        test yakaladı (iyi)
#   YAŞADI      testler yeşil kaldı: o davranışı koruyan test yok ya da zayıf (test açığı)
#   GEÇERSİZ    bozma kurulumu kırdı; testin başarısı SAYILMAZ (TEHAİ'deki koşucu bunları "yakalandı" sayıyordu)
#   UYGULANMADI sed eşleşmedi; bozma bayatlamış, güncellenmeli
# Çalıştırma (repo kökünden, root, yerel PG 16): bash supabase/tests/bozma.sh   (~2 sn/bozma). Canlıya dokunmaz.
set -u
cd "$(dirname "$0")/../.." || exit 1
KOK=$(pwd)

# kimlik | dosya | sed ifadesi | korunması gereken davranış
BOZMALAR=$(cat <<'EOF'
B01|0005_oturum_db.sql|s/^  perform svc_oturum_dogrula();$//|sahip kapısı oturum ister
B02|0005_oturum_db.sql|s/ and iptal_at is null and bitis > now();/ and iptal_at is null;/|süresi dolan oturum reddedilir
B03|0005_oturum_db.sql|s/^  update svc_oturumlar set iptal_at = now()$/  update svc_oturumlar set son_kullanim = now()/|çıkış oturumu kapatır
B04|0005_oturum_db.sql|s/if g.hata_sayisi + 1 >= 5 then/if g.hata_sayisi + 1 >= 50 then/|5. yanlış parolada kilit
B05|0005_oturum_db.sql|s/'salt', g.salt, 'iterasyon', g.iterasyon);/'salt', g.salt, 'iterasyon', g.iterasyon, 'h', g.password_hash);/|giriş başlangıcı özet döndürmez
B06|0005_oturum_db.sql|s/= g.password_hash then/<> g.password_hash then/|yanlış parola oturum vermez
B07|0005_oturum_db.sql|$a grant execute on function public.svc_anahtar_dogrula(text) to anon;|iç kapı anon'a kapalı
B08|0005_oturum_db.sql|$a grant select on public.svc_isler to anon;|anon tabloyu okuyamaz
B09|0001_operasyon_cekirdegi.sql|s/^begin raise exception 'BEE_OLAY_DEGISMEZ: olay kaydı değiştirilemez veya silinemez'; end \$\$;/begin return old; end $$;/|olay kaydı değişmez/silinmez
B10|0004_modul1_saha.sql|/^create trigger svc_isler_silinmez/,+1d|olay kaydı olan iş silinmez
B11|0001_operasyon_cekirdegi.sql|366{/and iptal_at is null/s//and true/}|iptal edilen link boş döner
B12|0001_operasyon_cekirdegi.sql|367{/son_gecerlilik > now()/s//true/}|süresi dolan link boş döner
B13|0001_operasyon_cekirdegi.sql|373s/to_jsonb(i.baslik)/to_jsonb(concat_ws(' ', i.baslik, i.aciklama))/|link iç açıklamayı sızdırmaz
B14|0004_modul1_saha.sql|s/^  if p ? 'istemci_id' then$/  if false then/|aynı istemci_id tekrar denemesi yeni iş açmaz
B15|0005_oturum_db.sql|s/^  if v_hata >= 5 then$/  if v_hata >= 50 then/|kurulum kodu 5 hatada kilitlenir
B16|0004_modul1_saha.sql|s/created_at > now() - interval '1 hour') >= 3 then/created_at > now() - interval '1 hour') >= 30 then/|aynı IP'den saatte en fazla 3 talep
B17|0005_oturum_db.sql|s/^  update svc_oturumlar set iptal_at = now()$/  raise exception using errcode = '42501', message = 'BEE_BOZMA'; update svc_oturumlar set iptal_at = now()/|O6 çıkışın kendisi reddedilince geçmemeli (test ölçütü)
EOF
)

oldu=0; yasadi=0; gecersiz=0; uygulanmadi=0
while IFS='|' read -r id dosya ifade davranis; do
  [ -z "$id" ] && continue
  T=$(mktemp -d /tmp/bee-bozma.XXXXXX)
  cp -r "$KOK/supabase" "$T/"
  hedef="$T/supabase/migrations/$dosya"
  sed -i -e "$ifade" "$hedef"
  if cmp -s "$KOK/supabase/migrations/$dosya" "$hedef"; then
    echo "UYGULANMADI $id $davranis"; uygulanmadi=$((uygulanmadi+1)); rm -rf "$T"; continue
  fi
  cikti=$(bash "$T/supabase/tests/yerel-kurulum.sh" 2>&1)
  if echo "$cikti" | grep -qE '^KALDI  [0-9]{4}_'; then
    echo "GEÇERSİZ    $id $davranis — kurulum: $(echo "$cikti" | grep -m1 -E '^KALDI  [0-9]{4}_' | cut -c8-110)"; gecersiz=$((gecersiz+1))
  elif [ "$(echo "$cikti" | tail -1)" = "SONUÇ  kalan=0" ]; then
    echo "YAŞADI      $id $davranis"; yasadi=$((yasadi+1))
  else
    yakalayan=$(echo "$cikti" | grep -oE 'KALDI [A-Z][0-9]+[a-z]?' | cut -d' ' -f2 | sort -u | tr '\n' ' ')
    echo "ÖLDÜ        $id $davranis — yakalayan: ${yakalayan:-$(echo "$cikti" | grep -m1 '^KALDI' | cut -c8-80)}"; oldu=$((oldu+1))
  fi
  rm -rf "$T"
done <<< "$BOZMALAR"

toplam=$((oldu+yasadi))
echo "SONUÇ  öldü=$oldu yaşadı=$yasadi geçersiz=$gecersiz uygulanmadı=$uygulanmadi  skor=$oldu/$toplam (geçersiz ve uygulanmadı skora girmez)"
exit $((yasadi + gecersiz + uygulanmadi))
