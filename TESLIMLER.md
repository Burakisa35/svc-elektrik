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
