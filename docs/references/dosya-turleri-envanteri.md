---
title: Burak'ın ekosistemindeki dosya türleri — envanter (keşif)
retrieved: 2026-11-07
status: taslak (Burak doğrulaması bekliyor)
---

# Dosya türleri envanteri

**Amaç:** Burak'ın çalışma ekosisteminde hangi dosya türleri var, hangisi ne işe yarıyor; bir sonraki dosya (`dosya-turleriyle-uretim-fikirleri.md`) bunun üstüne kurulu. Mod: keşif (sınırı: mevcut repolar ve kayıtlı beyanlar; yeni araştırma yok).

**Güven etiketleri:** *Yüksek* = repoda sayıldı (2026-11-07, git ls-files); *Orta* = Burak'ın kendi beyanı (bellek kaydı) ile tutarlı; *Doğrulanmadı* = çıkarım.

**Önemli sınır:** Repodaki dosyaların çoğu Claude Code tarafından üretilmiş olabilir. "Dosya var" ≠ "Burak bu türü kendi elleriyle düzenleyebiliyor". Hangisini kendisi bildiği **Doğrulanmadı**; son tabloda işaretlendi.

## 1. Sayım (dosya sayısı; özel repo için yalnız sayı, içerik alınmadı)

| Tür | tehai (özel, 1.362 dosya) | arel (50) | tehas-web (23) | svc-elektrik (56) | Ne için kullanılıyor (repodaki yer) | Etiket |
|---|---|---|---|---|---|---|
| `.md` | 513 | 3 | 3 | 50 | Talimat (CLAUDE.md, AGENTS.md), brief, araştırma, karar kayıtları; `docs/` altında yoğun | Yüksek |
| `.mjs` | 140 | – | – | – | Node betikleri: testler (`tests/`), araştırma/denetim veri betikleri; `package.json` `"type":"module"` | Yüksek |
| `.js` | 90 | 25 | 7 | – | Tarayıcı kodu (`assets/js`), sunucu işlevleri (`api/`), service worker | Yüksek |
| `.jsx` | – | – | 6 | – | React bileşenleri (yalnız tehas-web; tehai'de "React yok" kuralı var) | Yüksek |
| `.html` | 101 | 11 | 1 | 1 | Sayfalar, admin paneli, tek dosyalık arayüzler | Yüksek |
| `.css` | 4 | – | 1 | – | Tasarım token'ları ve stiller (çoğu stil HTML içinde olabilir) | Orta |
| `.sql` | 81 | – | – | – | Supabase migration'ları (`docs/migrations/`) | Yüksek |
| `.json` | 77 | 1 | 3 | – | Manifest (PWA), ayarlar (`.claude/settings.json`, `.mcp.json`), test tabanları, veri | Yüksek |
| `.jsonl` | 3 | – | – | – | Satır satır kayıt: ajan öğrenme kayıtları, araştırma verisi | Yüksek |
| `.py` | 44 | – | – | – | Teklif motoru (PDF/CSV işleme), prototip, öğrenme kaydı betiği | Yüksek |
| `.yml` / `.yaml` | 14 | 3 | – | – | GitHub Actions iş akışları, issue şablonu, kayıt (sicil) dosyaları | Yüksek |
| `.csv` | 11 | – | – | – | Katalog ve piyasa verisi, teklif verisi | Yüksek |
| `.xlsx` | 2 | – | – | – | Excel çalışma kitapları (teklif sicili, senaryo testi) | Yüksek |
| `.docx` | 3 | – | – | – | Araştırma/strateji belgeleri | Yüksek |
| `.pdf` | 8 | – | – | – | Teklif girdileri (şartname, teklif mektubu), strateji belgesi | Yüksek |
| `.svg` | 7 | 3 | 1 | – | Logo, ikonlar | Yüksek |
| `.png` / `.webp` | 7 / 239 | – | – | – | İkonlar, ürün fotoğrafları (webp, `assets/urun`) | Yüksek |
| `.ttf` | 3 | – | – | – | Yerel yazı tipleri | Yüksek |
| `.sh` | 1 | – | – | – | Claude Code SessionStart hook'u | Yüksek |
| `.toml` | 1 | – | – | – | Python proje ayarı | Yüksek |
| `.xml` / `.txt` | 1 / 7 | 1 / 1 | – | – | sitemap, robots, düz metin | Yüksek |
| uzantısız / nokta dosyaları | var | var | var | `.gitkeep` | `.gitignore`, `.vercelignore`, `vercel.json`, `sw.js` (service worker, js) | Yüksek |

## 2. Burak'ın beyanları (bellek kaydı, Orta)

- Vanilla HTML/CSS/JS + Supabase (RLS ayarları) ile çalışıyor; tehai için "React ve build aracı yok" kuralı koymuş.
- Python + Gemini ile Windows masaüstü sesli asistan (ERCAI) geliştirmiş.
- jsPDF ile istemci tarafında PDF teklif üretimi; teklif Excel'ini iPhone'da Excel ile kullanıyor; iPhone klavyesinde sesli dikte (Spokenly).
- Claude Code'a brief (md) yazdırıp yaptırıyor; CLAUDE.md ve görev kartı şablonu kullanmış.
- Satfinder cihazı için TP/konum listesi düzenleme yazılımı (USB'ye yükleme) geliştiriyor; dosya biçimi **Doğrulanmadı**.

## 3. Gözlemler (Yüksek: sayıldı; yorum Orta)

1. Kod çoğunlukla **düz JS/MJS + HTML**; build zinciri yok (tehai `package.json` yalnız test betikleri taşıyor). Bu, "tek dosya + Node betiği" tarzının işleyen bir pratik olduğunu gösteriyor.
2. tehai'de CLAUDE.md **359 satır**, 159 test dosyası, 513 md dosyası var. Resmî öneri < 200 satır ve ölçümler şişkin bağlamın maliyet getirdiğini gösteriyor (bkz. `context-dosyalari-literatur.md`). Burak'ın "test ve rapor yığınından yoruluyorum" tercihiyle aynı yönde: svc-elektrik'te bu örüntü tekrarlanmamalı.
3. Veri biçimleri katmanlı: insan için md/docx/pdf, makine için json/jsonl/csv/sql, görsel için svg/webp. Aynı bilgi birden fazla biçimde yaşıyor (ör. md ve jsonl) ve senkron tutmak maliyetli.
4. Ürün fotoğrafları `webp` (239 dosya): görsel ağırlığı bilinçli küçültülmüş.
5. `.github/workflows` var: otomatik kontrol altyapısı zaten kullanılıyor.

## 4. Burak'ın doğrulaması gereken tek şey

Hangi türleri **kendi elinle** açıp düzenleyebiliyorsun (md, html, js, json, sql…)? Cevap fikir dosyasındaki öncelikleri değiştirir: kendin düzenleyebildiğin tür = telefondan müdahale edebileceğin yer; geri kalanlar Code'un işi.
