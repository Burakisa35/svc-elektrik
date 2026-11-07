# TESLIMLER — Claude Code teslim kaydı

Tek dosya, ekleme usulü (satır silinmez, durum değişirse yeni satır eklenir). Code yalnız **teslim edildi / kısmen / bekliyor / başlanmadı** yazar; **kapanış kararı "Denetim" sütunundadır ve onu denetleyen (sohbet Claude'u) doldurur.** Her "teslim edildi" bir kanıt (komut çıktısı ya da commit) taşır.
Dal: `claude/jolly-allen-7gfz46` · Commit: `https://github.com/burakisa35/svc-elektrik/commit/<kod>`
Bütünlük: `bash araclar/dogrula.sh` → tablodaki her commit'in dalda var olduğunu ve her "teslim edildi" satırının kanıtlı olduğunu denetler.

| Brief · madde | Durum (Code) | Kanıt | Commit | Denetim |
|---|---|---|---|---|
| 004 · 1 Durum raporu | teslim edildi | `src/CLAUDE.md`, `supabase/CLAUDE.md` Durum tabloları; MCP `get_project`, `list_migrations` | [7efd02d](https://github.com/burakisa35/svc-elektrik/commit/7efd02d) | |
| 004 · 2 Alt dizin CLAUDE.md | teslim edildi | `wc -l` → src 36, supabase 36 (hedef ≤60) | [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075) | |
| 004 · 3 Kök CLAUDE.md Komutlar | kısmen | Komutlar çalıştırıldı (`koruma-test.sh` kalan=0, `node --check`, `md5sum`). PR açılmadı | [7efd02d](https://github.com/burakisa35/svc-elektrik/commit/7efd02d) | |
| 004 · 4 Koruma hook'u | kısmen | `koruma-test.sh` 24/24, bozma testinde 13 kırmızı. Yanlış pozitifler var (006 · 2) | [7efd02d](https://github.com/burakisa35/svc-elektrik/commit/7efd02d) | |
| 004 · 5 Hook canlı oturumda | kısmen | **Doğrulanmadı:** `touch --no-create knowledge/_x.md` iki oturumda engellenmedi (çıkış 0) | — | |
| 004 · 6 Importer XSS | başlanmadı | importer yok | — | |
| 004 · 7 `.gitignore` + sır kontrolü | teslim edildi | `git grep` sır kalıpları: eşleşme yok | [7efd02d](https://github.com/burakisa35/svc-elektrik/commit/7efd02d) | |
| 004 · 8 md'li/md'siz ölçüm | başlanmadı | — | — | |
| 006 · 1 CLAUDE.md dürüstlüğü | teslim edildi | Kök `CLAUDE.md` Koruma satırı "canlıda Doğrulanmadı" etiketli; 004 · 3 ve 004 · 5 burada "kısmen" | [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075) | |
| 006 · 2 Hook yanlış pozitifleri | bekliyor | Düzeltme yazıldı; `koruma.py`'ye yazma izin kontrolünce **iki kez reddedildi** ("Self-Modification"). `git diff --stat -- .claude/` boş; `git hash-object koruma.py` = `1f2055f`, HEAD ve `7efd02d` ile aynı | — | |
| 006 · 3 Actions yol denetimi | bekliyor | `setup/foundation` → `main` birleşmesi gerekiyor (Burak PR onayı) | — | |
| 006 · 4 Koruma kapsamı, `docs/kod/` | bekliyor | Burak kararı | — | |
| 006 · 5 Test canlı veritabanında | kısmen | Test sayaçları geri yüklüyor: koşum sonrası `pg_sequences.last_value` = null (değişmedi), 38/38. Ayrı test projesi kararı Burak'ta | [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075) | |
| 006 · 6 0004 anında satır sayısı | bekliyor | 0004 uygulanmadı; MCP `list_migrations` son = 0003. Uygulama anında ölçülecek | — | |
| 006 · §3 Çalışma disiplini | teslim edildi | `src/CLAUDE.md` "Çalışma disiplini" bölümü | [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075) | |
| 002 Arıza çözüm kaydı | başlanmadı | G2/G3 ve Burak onayı bekleniyor | — | |
| 005 Soru sistemi | başlanmadı | 006 bitmeden başlanmaz | — | |
| 007 Tasarım kimliği | başlanmadı | Okundu; koşul: 006 · 1–2 kapanmalı | — | |
| 008 Test düzeni | başlanmadı | Okundu (§6 sıra T0 → T1 → T3 → T4 → T1b → T2); koşul: 006 · 1–2 kapanmalı | — | |
| Brief dışı · Supabase ayrı proje, 0000–0001, erişim testi | teslim edildi | MCP `list_migrations`; MD5 dosya = canlı | [6fb2585](https://github.com/burakisa35/svc-elektrik/commit/6fb2585) | |
| Brief dışı · 0002 sahip fonksiyonları | teslim edildi | MD5 `cb1bc015…` dosya = canlı | [6bc172a](https://github.com/burakisa35/svc-elektrik/commit/6bc172a) | |
| Brief dışı · 0003 PBKDF2 girişi | teslim edildi | MD5 `f60bfea2…` dosya = canlı | [199938e](https://github.com/burakisa35/svc-elektrik/commit/199938e) | |
| Brief dışı · 0004 Modül 1 saha | bekliyor | Dosya MD5 `516ed4e0…`; canlıda yok (`svc_isler.engel` sütunu yok). Burak SQL Editor'den uygulayacak | [eb2910f](https://github.com/burakisa35/svc-elektrik/commit/eb2910f) | |
| Brief dışı · eski `index.html` silindi | teslim edildi | `git ls-tree HEAD index.html` boş | [babcfac](https://github.com/burakisa35/svc-elektrik/commit/babcfac) | |
| Brief dışı · Supabase tam denetim | teslim edildi | `get_advisors` (güvenlik/performans/sağlık), `query_logs`, katalog sorguları → `supabase/CLAUDE.md` | [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075) | |
| Brief dışı · Modül 1 API ve ekranlar | başlanmadı | 0004 ve tasarım yönü (ES-6) bekleniyor | — | |
| Brief dışı · Teslim kaydı biçimi (Denetim sütunu, kanıt şartı) + tek komutlu doğrulama | teslim edildi | `bash araclar/dogrula.sh` → SONUÇ 5/5; bozma: sahte commit ve kanıtsız satır içeren kopyada 2 KALDI (3/5) | `araclar/dogrula.sh` ekleyen commit | |
| Brief dışı · En kritik temel açık: araştırma + karar önerisi (0005 tasarımı) | teslim edildi | Exa 5 arama (PostgREST, Supabase signing keys, API keys, pre-request, RFC 5802) → `supabase/CLAUDE.md` "Yetki modelinin en kritik açığı" bölümü; migration yazılmadı | `supabase/CLAUDE.md`'yi güncelleyen commit | |
| Brief dışı · 0005 parola doğrulaması + oturum DB'de (Burak onayı) | kısmen | Yerelde boş PG 16'da 0000→0005 kuruldu; `db-oturum.sql` 15/15; bozma M1/M2/M3 → 4/1/2 KALDI. **Canlıya uygulanmadı** (MCP `list_migrations` son = 0003) | `0005_oturum_db.sql` ekleyen commit | |
| Brief dışı · Sıfırdan kurulum testi (yerel PG 16) | teslim edildi | `bash supabase/tests/yerel-kurulum.sh` → SONUÇ kalan=0 (taklit + 6 migration + 2 test dosyası); `bash araclar/dogrula.sh` → 6/6 | `yerel-kurulum.sh` ekleyen commit | |
| 006 · 6 0004 anında satır sayısı | teslim edildi | Uygulamadan hemen önce (2026-11-07 06:56 UTC) bütün `svc_` tabloları 0 satır, `svc_proje_kimlik` 1 | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · 0004 Modül 1 saha (DROP'lar 0006'ya ayrıldı) | teslim edildi | MCP `apply_migration` sorusuz başarılı; canlı MD5 `964f018d…` = dosya; eserler ölçüldü (svc_isler 4 sütun, 2 silinmezlik tetiği, 3 yeni fonksiyon, telefon boş olabilir) | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · 0005 canlıya (2. durum) | kısmen | MCP onay sorusunda 230 sn zaman aşımı; canlıda eser yok (`svc_oturumlar` yok, 0005 fonksiyonu 0). Kök neden: gövdedeki `delete from svc_oturumlar` (T-001). Yol Burak kararında | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · 0006 temizlik (DROP'lar, durum seti) | bekliyor | Dosya MD5 `10c11795…`; gerçek DROP içerir, onay sorusu meşru ve bu oturumdan cevaplanamaz | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · Kök neden: MCP onay sorusu zaman aşımı (P1) | teslim edildi | `araclar/teshis/T-001`: supabase/mcp `destructive-sql.ts` + PR 53018; `node araclar/mcp-soru-tahmini.mjs` 6 gözlemin 6'sıyla tutarlı. 0003'ün ikinci denemede geçişi açıklanmadı (ADAY) | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · Teşhis aracı (belirti → RCA/5 Neden/Ishikawa/FMEA) | teslim edildi | `node araclar/teshis.mjs` T-001 GEÇTİ; 8 bozmanın 8'i kendi kuralından KALDI, biçim değişikliği yeşil kaldı; `bash araclar/dogrula.sh` → 7/7, 2,95 sn | [98a8990](https://github.com/burakisa35/svc-elektrik/commit/98a8990) | |
| Brief dışı · 0005 parola doğrulaması + oturum DB'de (3. durum) | teslim edildi | MCP `apply_migration` sorusuz başarılı (07:16 UTC); canlı MD5 `525f045a…` = dosya; `svc_s_giris_basarili`/`svc_s_oturum_surumu` oturum istiyor; `get_advisors` güvenlik: yalnız beklenen 2 bulgu | [86d7e82](https://github.com/burakisa35/svc-elektrik/commit/86d7e82) | |
| Brief dışı · Ara durum ölçümü (`SON=`) + tahmin aracına UPDATE kuralı | teslim edildi | `SON=0005 bash supabase/tests/yerel-kurulum.sh` → 0006'ya bağlı 2 KALDI (beklenen); tam kurulum `dogrula.sh` 7/7 | [86d7e82](https://github.com/burakisa35/svc-elektrik/commit/86d7e82) | |
| Kod analizi skill briefi · ilk koşu (inceleme) | teslim edildi | `.claude/skills/kod-analizi/SKILL.md` (96 satır); `node araclar/teshis.mjs` T-001 GEÇTİ, 10 bozmanın 10'u kendi kuralından KALDI; `git diff --stat -- src/ supabase/` yalnız `src/CLAUDE.md`; skill'in bu oturumda yüklendiği **Doğrulanmadı** | [611e706](https://github.com/burakisa35/svc-elektrik/commit/611e706) | |
| Kod analizi · üç gerçek kod adayı | teslim edildi | `araclar/teshis/ADAYLAR.md`; yerel PG 16'da ölçüldü: A1 22P02, A2 23505, B3 kayıt 0, B4 NaN toplam, C1 0/0, C2 23514, C3 iptal→kapandi, C4 22P02, C5 iptal→kapandi. Düzeltme yapılmadı | [611e706](https://github.com/burakisa35/svc-elektrik/commit/611e706) | |
