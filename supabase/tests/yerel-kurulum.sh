#!/usr/bin/env bash
# Sıfırdan kurulum testi (brief 008 T1b'nin yerel karşılığı): boş PostgreSQL 16'da Supabase taklidi +
# bütün migration'lar sırayla + DB testleri. Canlıya dokunmaz, ücretsizdir, her koşuda sıfırdan başlar.
# Çalıştırma (repo kökünden, root): bash supabase/tests/yerel-kurulum.sh
# SON=0005 bash supabase/tests/yerel-kurulum.sh → 0005'te durur (canlıda henüz uygulanmamış migration varken o durumu ölçer).
# ATLA=0006 bash supabase/tests/yerel-kurulum.sh → 0006'yı atlar (canlıda arada uygulanmamış dosya varken o durumu ölçer).
# Sınır: yerel PG 16, canlı PG 17. PostgREST/gateway davranışı (başlık iletimi) burada ölçülmez.
set -u
cd "$(dirname "$0")/../.." || exit 1
B=/usr/lib/postgresql/16/bin
D=$(mktemp -d /tmp/bee-pg.XXXXXX); chmod 755 "$D"; chown postgres:postgres "$D"
PORT=54329
psqlx() { psql -h "$D" -p "$PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -q "$@"; }
bitir() { runuser -u postgres -- $B/pg_ctl -D "$D/data" stop -m fast >/dev/null 2>&1; rm -rf "$D"; }
trap bitir EXIT

runuser -u postgres -- $B/initdb -D "$D/data" -A trust -U postgres >/dev/null || { echo "KALDI  initdb"; exit 1; }
runuser -u postgres -- $B/pg_ctl -D "$D/data" -o "-k $D -p $PORT -c listen_addresses=''" -l "$D/log" start >/dev/null || { echo "KALDI  postgres başlamadı"; exit 1; }
for i in 1 2 3 4 5 6 7 8 9 10; do psqlx -c 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done

kalan=0
psqlx -f supabase/tests/supabase-taklit.sql >/dev/null 2>&1 && echo "GEÇTİ  Supabase taklidi" || { echo "KALDI  Supabase taklidi"; exit 1; }
for f in supabase/migrations/*.sql; do
  case "$(basename "$f")" in "${ATLA:-yok}"_*) echo "ATLANDI $(basename "$f") (ATLA=$ATLA: canlıda uygulanmamış dosya)"; continue;; esac
  if hata=$(psqlx -1 -f "$f" 2>&1 >/dev/null); then echo "GEÇTİ  $(basename "$f")"
  else echo "KALDI  $(basename "$f") — $(echo "$hata" | head -2 | tr '\n' ' ')"; kalan=$((kalan+1)); break; fi
  case "$(basename "$f")" in "${SON:-yok}"_*) echo "DUR    SON=$SON (canlının o anki durumu)"; break;; esac
done
# DB testleri kasıtlı "BEE_TEST_SONUC kalan=N" hatasıyla biter; N=0 beklenir.
for t in supabase/tests/db-*.sql; do
  sonuc=$(psqlx -f "$t" 2>&1 | grep -o 'BEE_TEST_SONUC kalan=[0-9]*' | head -1)
  if [ "$sonuc" = "BEE_TEST_SONUC kalan=0" ]; then echo "GEÇTİ  $(basename "$t")"
  else echo "KALDI  $(basename "$t") — ${sonuc:-sonuç satırı yok}"; psqlx -f "$t" 2>&1 | grep -E 'KALDI|ERROR' | head -5; kalan=$((kalan+1)); fi
done
# Yarış testleri iki oturum ister (betik); hazırlığı kalıcı yazdıkları için DB testlerinden SONRA ve yalnız yerelde koşar.
for t in supabase/tests/yaris-*.sh; do
  [ -e "$t" ] || continue
  cikti=$(bash "$t" "$D" "$PORT" 2>&1); sonuc=$(echo "$cikti" | grep -o 'BEE_TEST_SONUC kalan=[0-9]*' | tail -1)
  if [ "$sonuc" = "BEE_TEST_SONUC kalan=0" ]; then echo "GEÇTİ  $(basename "$t")"
  else echo "KALDI  $(basename "$t") — ${sonuc:-sonuç satırı yok}"; echo "$cikti" | grep -E 'KALDI|ERROR' | head -3; kalan=$((kalan+1)); fi
done
echo "SONUÇ  kalan=$kalan"
exit "$kalan"
