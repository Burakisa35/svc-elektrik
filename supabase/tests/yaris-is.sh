#!/usr/bin/env bash
# Yarış testi (K2, ADAYLAR Vaka 1): aynı istemci_id ile İKİ EŞZAMANLI iş açma isteği tek kayıt üretmeli ve ikisi de aynı işi döndürmeli.
# İki ayrı veritabanı oturumu ister; bu yüzden DO bloğu değil, betik. YALNIZ yerelde (yerel-kurulum.sh çağırır), canlıda ASLA:
# hazırlık satırları (anahtar, oturum) kalıcı yazılır.
# Kullanım: bash supabase/tests/yaris-is.sh <soket_dizini> <port>   → son satır "BEE_TEST_SONUC kalan=N"
set -u
D="$1"; P="$2"
q() { psql -h "$D" -p "$P" -U postgres -d postgres -X -q -t -A -v ON_ERROR_STOP=1 "$@"; }
TOK=$(printf 'd%.0s' $(seq 64)); U='7a2e1f00-0000-4000-8000-0000000000aa'; TEL='0533 444 55 66'
H="select set_config('request.headers', json_build_object('x-bee-oturum', '$TOK')::text, false) is not null;"
GOVDE="{\"istemci_id\":\"$U\",\"musteri\":{\"telefon\":\"$TEL\"},\"aciklama\":\"yaris\"}"
kalan=0; rapor=""

q -c "insert into svc_ayarlar (anahtar, deger) values ('sahip_hash', encode(sha256(convert_to('test-sahip-anahtari','UTF8')),'hex'))
      on conflict (anahtar) do update set deger = excluded.deger;
      insert into svc_oturumlar (token_hash, bitis) values (encode(sha256(convert_to('$TOK','UTF8')),'hex'), now() + interval '1 day');" >/dev/null

# A: işi açar ve 2 sn commit etmeden bekler. B: A'dan 0,5 sn sonra aynı istekle gelir.
A_CIKTI=$(mktemp)
( q -c "$H" -c "begin; select svc_s_is_olustur('test-sahip-anahtari', '$GOVDE'); select pg_sleep(2); commit;" > "$A_CIKTI" 2>&1 ) &
sleep 0.5
B=$(q -c "$H" -c "select svc_s_is_olustur('test-sahip-anahtari', '$GOVDE');" 2>&1 | tail -1)
wait
A=$(grep -E '^[0-9a-f-]{36}$' "$A_CIKTI" | head -1); rm -f "$A_CIKTI"

is_sayi=$(q -c "select count(*) from svc_isler where istemci_id = '$U';")
mus_sayi=$(q -c "select count(*) from svc_musteriler where telefon = '905334445566';")
if [ -n "$A" ] && [ "$A" = "$B" ]; then rapor="$rapor GEÇTİ Y1 ikinci istek aynı işi döndürdü;"
else rapor="$rapor KALDI Y1 A=${A:-yok} B=${B};"; kalan=$((kalan+1)); fi
if [ "$is_sayi" = 1 ] && [ "$mus_sayi" = 1 ]; then rapor="$rapor GEÇTİ Y2 tek iş, tek müşteri;"
else rapor="$rapor KALDI Y2 iş=$is_sayi müşteri=$mus_sayi;"; kalan=$((kalan+1)); fi
echo "$rapor" | tr ';' '\n' | sed '/^\s*$/d; s/^ //'
echo "BEE_TEST_SONUC kalan=$kalan"
