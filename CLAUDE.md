# CLAUDE.md — svc-elektrik (BEE)

Burak Elektrik ve Elektronik Teknik Servis (BEE) için tek kullanıcılı (Burak), mobil öncelikli (iPhone 11, tek el) servis yönetim sitesi.
Bu dosya hem Claude Code hem sohbet tarafındaki Claude için bağlayıcıdır. Dizine özel kurallar alt klasörlerdeki `CLAUDE.md` dosyalarındadır; çelişkide en derindeki kazanır.

## Roller ve sınırlar (en önemli bölüm)

| Alan | Sahibi | Diğer taraf |
|---|---|---|
| `knowledge/**` (araştırma, uç/arıza bilgisi) | Claude (sohbet) | Claude Code **içeriği düzenlemez**; hatayı `docs/briefs/` altına not düşer |
| `docs/briefs/**`, `docs/decisions/**` | Claude (sohbet) yazar, Burak iletir | Code okur, uygular |
| `src/**`, `supabase/migrations/**`, UI, importer, build | Claude Code | Sohbet Claude'u **dokunmaz** |
| `index.html` (mevcut site) | Claude Code — **tümüyle yeniden yazılacak** (yama değil, sıfırdan tasarım) | Sohbet Claude'u dokunmaz |
| `.claude/hooks/*-test.sh` (koruma testleri, bozma testi dahil) | Claude Code | — |
| `.claude/hooks/koruma.py`, `.claude/settings.json` | Claude Code önerir; **Burak onayıyla, PR ile** girer (Burak, 2026-11-07) | Code kendi korumasını tek başına gevşetemez |
| `TESLIMLER.md` (teslim kaydı) | Claude Code: "Durum" sütunu | Sohbet Claude'u: "Denetim" sütunu (kapanış kararı) |
| Karar, öncelik, saha doğrulaması | Burak | — |

Kurallar:
1. Brief'ler Burak üzerinden taşınır; roller arası doğrudan iletişim yok. Dosya = tek doğruluk kaynağı.
2. Sohbet Claude'u yalnızca kendi alanına yazar. Code, `knowledge/` içeriğini koda çevirir (importer), içeriği değiştirmez.
3. `main`'e doğrudan push yok; her iş ayrı dal + commit. Commit mesajı Türkçe/kısa, "ne + neden".
4. Migration dosya olarak yazılır (`supabase/migrations/`). Uygulama onayı: Burak'ın TEHAİ için verdiği otomatik uygulama tercihi **bu proje için geçerli değildir**; svc-elektrik'te önce Burak'a sorulur.

## Kalite kontrol (paralel)

Üreten denetlemez. Her faz `docs/quality/gates.md` kapısından geçmeden kapanmaz; denetim üretimle paralel yürür, sonda toplanmaz. Ayrıntı: `docs/quality/README.md`. Bulgular `docs/quality/findings/` altına yazılır; engelleyici bulgu açıkken sonraki faza geçilmez.

## Güven etiketi (zorunlu)

Her teknik iddia şu etiketlerden birini taşır:
- **Yüksek** — üretici dokümanı/şeması veya ölçümle doğrulanmış
- **Orta** — birden fazla bağımsız vaka/analoji ile tutarlı, doğrudan kanıt yok
- **Doğrulanmadı** — kaynak yok ya da tahmin; tahminle doldurma, öyle bırak

Kablo renginden işlev çıkarılmaz; ucu devreye kadar takip eden kanıt aranır. Başka markanın şeması yalnızca elektriksel prensip karşılaştırması için kullanılır, o markanın ucu diye yazılmaz.

## Bilgi tabanı (knowledge/) ilkeleri

- Her uç için kayıt: **işlev + elektriksel sinyal + akım yolu + arıza davranışı + kanıt**. Biri bilinmiyorsa kayıt "tamamlanmadı" sayılır.
- Kaynak URL zorunlu; içerik özetlenir/paraphrase edilir, uzun alıntı yok. Şema/kılavuz görselleri repoya konmaz, bağlantı verilir.
- Format: `knowledge/_SPEC.md`. Şablonlar: `knowledge/_templates/`.
- Saha gözlemi (Burak'ın ölçümü/fotoğrafı) `field_report` olarak girer ve kaynak sınıfı "saha"dır; en yüksek ağırlıklı kanıt budur.

## Teknik yığın

- Hedef: Supabase (veri) + yazılım tarafı. Mevcut durum: kökte tek dosya `index.html`. Framework/dağıtım ayrıntısı **Doğrulanmadı** — Claude Code ilk işi olarak mevcut durumu raporlar ve `src/CLAUDE.md` içine yazar.
- Mobil öncelik, tek el kullanım, sahada zayıf internet olabilir (okuma çevrimdışı dayanıklı olmalı).

## Dil ve üslup

Arayüz ve dokümanlar Türkçe. Kısa, doğrudan, dolgusuz. Kod yorumları Türkçe veya İngilizce olabilir; tutarlı kalın.

## Komutlar

**Oturum başı (Code):** `TESLIMLER.md` ve `git log --oneline -10` okunur, sonra `bash araclar/dogrula.sh` çalıştırılır. KALDI satırı varken yeni iş açılmaz.
**Teslim:** bir madde ancak kanıtı (komut çıktısı ya da commit) varsa "teslim edildi" yazılır. Kapanış kararı denetleyenindir (`TESLIMLER.md` "Denetim" sütunu).
**Belirti, yeni özellik, iyileştirme, regresyon (Code):** yöntem `.claude/skills/kod-analizi/SKILL.md` (Belirti → Kanıt → Ishikawa → 5 Neden → RCA → FMEA → Düzeltme → Doğrulama → Öğrenim). İlk bakış `araclar/teshis/BELIRTILER.md`; kayıt `araclar/teshis/_SABLON.md` ile `T-NNN`. Ölçülmeyen neden ADAY kalır; `node araclar/teshis.mjs` denetler. Açık adaylar: `araclar/teshis/ADAYLAR.md`.
**Migration uygulamadan önce:** `node araclar/mcp-soru-tahmini.mjs`. "SORU ÇIKAR" diyen dosya bu oturumdan MCP ile uygulanamaz (`supabase/CLAUDE.md` Tuzaklar).

```bash
bash araclar/dogrula.sh    # tek komut: hook testi, JS sözdizimi, migration kimlik kapısı, TESLIMLER bütünlüğü, teşhis kayıtları, sıfırdan kurulum (7 kontrol, ~3 sn)
```
Canlı DB kontrolleri (migration MD5'i, `supabase/tests/db-erisim.sql` erişim testi) yerelde koşmaz; MCP ya da SQL Editor ile yapılır: `supabase/CLAUDE.md`. Tümü 2026-11-07'de denendi.
Koruma: `.claude/settings.json` hook'u, Code'un `knowledge/` ve `docs/` yazmasını Edit/Write **ve** Bash'te engellemek için yazıldı. Birim testinde engelliyor (Yüksek). Canlı oturumda engellediği **Doğrulanmadı**: 2026-11-07'deki iki oturumda deneme engellenmedi; oturumlar repo kökünde açılmadığı için hook yüklenmemiş olabilir (Orta). Yolu metinde geçmeyen betikle yazma yakalanmaz.

## Dizin haritası

```
CLAUDE.md          bu dosya (kökten kural seti)
README.md          proje özeti, yerleşim
knowledge/         araştırma bilgi tabanı (Claude sohbet sahibidir)
docs/briefs/       araştırma ve tasarım brief'leri
docs/decisions/    kısa karar kayıtları (ADR)
docs/quality/      kalite kapıları ve bulgu kayıtları
docs/references/   Supabase, Vercel, CLAUDE.md kullanım rehberleri (src/ ve supabase/ işinden önce oku)
src/               uygulama (Claude Code); durum ve kurallar src/CLAUDE.md
supabase/          migration'lar + DB testi (Claude Code); supabase/CLAUDE.md
TESLIMLER.md       brief teslim kaydı: Code durum yazar, denetleyen kapatır
araclar/           Claude Code'un araçları: dogrula.sh (tek komut), teshis/ (belirti → teşhis), mcp-soru-tahmini.mjs
```
