#!/usr/bin/env bash
# Tek komutluk yerel doğrulama. Her kontrol tek satır; sonda SONUÇ. Çıkış kodu = kalan kontrol sayısı.
# Çalıştırma (repo kökünden): bash araclar/dogrula.sh
# Kapsam: yalnız yerelde ölçülebilenler. Canlı DB karşılaştırması (MD5, erişim testi) MCP ile: supabase/CLAUDE.md.
cd "$(dirname "$0")/.." || exit 1
TESLIM="${TESLIMLER_YOLU:-TESLIMLER.md}"
KAPI="select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');"
toplam=0; kalan=0
satir() { toplam=$((toplam+1)); if [ "$1" = 0 ]; then echo "GEÇTİ  $2"; else echo "KALDI  $2 — $3"; kalan=$((kalan+1)); fi; }

# 1. Koruma hook'u testi
cikti=$(bash .claude/hooks/koruma-test.sh 2>&1 | tail -1)
[ "$cikti" = "--- kalan=0" ]; satir $? "koruma hook testi" "$cikti"

# 2. JS sözdizimi
hata=""; for f in $(git ls-files 'src/*.js' 'src/**/*.js'); do node --check "$f" 2>/dev/null || hata="$hata $f"; done
[ -z "$hata" ]; satir $? "JS sözdizimi ($(git ls-files 'src/*.js' 'src/**/*.js' | wc -l) dosya)" "bozuk:$hata"

# 3. Her migration'ın ilk ifadesi kimlik kapısı (0000 kapıyı kuran dosyadır, hariç)
hata=""; for f in supabase/migrations/*.sql; do
  case "$f" in *0000_*) continue;; esac
  ilk=$(grep -vE '^\s*(--|$)' "$f" | head -1)
  [ "$ilk" = "$KAPI" ] || hata="$hata $(basename "$f")"
done
[ -z "$hata" ]; satir $? "migration kimlik kapısı ilk satırda" "eksik:$hata"

# 4. TESLIMLER: her commit dalda var ve HEAD'in atası
hata=""; for c in $(grep -oE '/commit/[0-9a-f]{7,40}' "$TESLIM" | cut -d/ -f3 | sort -u); do
  git cat-file -e "$c^{commit}" 2>/dev/null && git merge-base --is-ancestor "$c" HEAD 2>/dev/null || hata="$hata $c"
done
[ -z "$hata" ]; satir $? "TESLIMLER commit'leri dalda var" "bulunamayan:$hata"

# 5. TESLIMLER: "teslim edildi" satırının kanıtı boş olamaz
hata=$(awk -F'|' '/\| *teslim edildi *\|/ { k=$4; gsub(/[ \t—-]/,"",k); if (k=="") print $2 }' "$TESLIM")
[ -z "$hata" ]; satir $? "TESLIMLER teslim satırları kanıtlı" "kanıtsız:$hata"

echo "SONUÇ  $((toplam-kalan))/$toplam"
exit "$kalan"
