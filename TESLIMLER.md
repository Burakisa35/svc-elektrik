# TESLIMLER — Claude Code'un brief durumu

Bir brief'i yeniden okuyup "yapılmamış" sanmamak için burası tek kayıttır. Brief dosyaları (`docs/briefs/`) sohbet Claude'unundur; Code onlara yazmaz, durumu buraya işler.
Durum: **tamam** (kanıtı var) · **kısmen** · **bekliyor** (karar ya da izin gerekiyor) · **başlanmadı**. Dal: `claude/jolly-allen-7gfz46`. Commit bağlantısı: `https://github.com/burakisa35/svc-elektrik/commit/<kısa-kod>`.

## Brief 004 — md dosyaları, koruma hook'u ([7efd02d](https://github.com/burakisa35/svc-elektrik/commit/7efd02d))
| # | İş | Durum | Kanıt / not |
|---|---|---|---|
| 1 | Durum raporu | tamam | `src/CLAUDE.md` + `supabase/CLAUDE.md` "Durum" tabloları, güven etiketli |
| 2 | `src/`, `supabase/` CLAUDE.md | tamam | 39 ve 37 satır (hedef ≤60) |
| 3 | Kök CLAUDE.md Komutlar | kısmen | Bölüm eklendi, komutlar çalıştırıldı. Brief "PR ile" diyor; PR açılmadı |
| 4 | Koruma hook'u (Bash dahil) | kısmen | Birim testi 24/24 ve bozma testi geçti. Yanlış pozitifler var (006/2) |
| 5 | Hook canlı oturumda çalışıyor mu | kısmen | **Doğrulanmadı.** İki oturumda deneme engellenmedi; oturumlar repo kökünde açılmadı |
| 6 | knowledge/ içeriğini veri say (importer XSS) | başlanmadı | Henüz importer yok |
| 7 | Sır/döküm `.gitignore` | tamam | `.gitignore` eklendi, sır taraması temiz |
| 8 | md'li/md'siz ölçüm | başlanmadı | Yığın istenmedi; sonra |

## Brief 006 — 004 düzeltmeleri
| # | İş | Durum | Kanıt / not |
|---|---|---|---|
| 1 | CLAUDE.md dürüstlüğü (B4, B5) | tamam | Kök `CLAUDE.md` Koruma satırı etiketlendi; 004/3 ve 004/5 bu tabloda "kısmen". Commit: bu dosyayla aynı commit |
| 2 | Hook yanlış pozitifleri (B2) | **bekliyor** | Yeni hook yazıldı, `.claude/hooks/koruma.py`'ye yazma izin kontrolünce **reddedildi** ("kendi kendini değiştirme"). Burak'ın izni gerekiyor |
| 3 | Sunucu tarafı kapı (GitHub Actions) | bekliyor | Önce `setup/foundation` → `main` birleşmesi (Burak PR onayı) |
| 4 | Koruma kapsamını daraltma, `docs/kod/` | bekliyor | Burak kararı |
| 5 | Test canlı veritabanında (B6) | kısmen | Test artık sayaçları geri yüklüyor (iz bırakmıyor, 38/38). Ayrı test projesi kararı Burak'ta |
| 6 | 0004 uygulama anında satır sayıları | bekliyor | 0004 uygulanmadı (MCP onayı 5 kez cevapsız); Burak SQL Editor'den uygulayacak |
| §3 | Çalışma disiplini 3 satır | tamam | `src/CLAUDE.md` "Çalışma disiplini" |

## Diğer brief'ler
| Brief | Uygulayan | Durum |
|---|---|---|
| 001, 003 | araştırmacı (sohbet) | Code'a iş yok |
| 002 Arıza çözüm kaydı | Code | başlanmadı (G2/G3 kapısını ve Burak onayını bekliyor) |
| 005 Soru sistemi | Code | başlanmadı (006 bitmeden başlanmaz) |
| 007 Tasarım kimliği | Code | başlanmadı (006/1 ve 006/2 kapanmadan başlanmaz; 006/2 izin bekliyor) |
| 008 Test düzeni | Code | başlanmadı (aynı koşul). Okundu. Bölüm 6'daki sıra: T0 → T1 → T3 → T4 → T1b → T2. İnceleme `7efd02d`'ye dayanıyor; o zamandan bu yana sayaç sorunu [0c19075](https://github.com/burakisa35/svc-elektrik/commit/0c19075)'te çözüldü |

## Brief dışı (Burak'ın doğrudan istekleri)
| Konu | Commit | Durum |
|---|---|---|
| Ayrı Supabase projesi, çekirdek şema 0000–0001, erişim testleri | [6fb2585](https://github.com/burakisa35/svc-elektrik/commit/6fb2585) | tamam, canlıda |
| Sahip işlemleri DB fonksiyonu (0002), service_role yok | [6bc172a](https://github.com/burakisa35/svc-elektrik/commit/6bc172a) | tamam, canlıda |
| PBKDF2 600k giriş + çıkışta oturum iptali (0003), ROADMAP | [199938e](https://github.com/burakisa35/svc-elektrik/commit/199938e) | tamam, canlıda |
| ROADMAP: TEHAİ'den alınacaklar, tek ortak link | [9ede537](https://github.com/burakisa35/svc-elektrik/commit/9ede537) | tamam |
| 0004 Modül 1 saha migration'ı | [eb2910f](https://github.com/burakisa35/svc-elektrik/commit/eb2910f) | **yazıldı, uygulanmadı** |
| Eski `index.html` silindi | [babcfac](https://github.com/burakisa35/svc-elektrik/commit/babcfac) | tamam |
| Supabase tam denetim (2026-11-07) | bu dosyayla aynı commit | tamam; bulgular `supabase/CLAUDE.md` |
| Modül 1 API ve ekranları | — | başlanmadı (0004'ü bekliyor) |
