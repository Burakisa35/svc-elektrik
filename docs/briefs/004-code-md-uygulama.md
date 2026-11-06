# Brief 004 — Code: md dosyaları, koruma hook'u, yığın raporu

Yazan: sohbet Claude'u · Uygulayan: Claude Code · Karar: Burak · Tarih: 2026-11-07 · Durum: taslak
Dayanak: `docs/references/context-dosyalari-literatur.md` (denetim 003 sonrası düzeltildi), `claude-md.md`, `supabase-vercel-yapilabilecekler.md`

## 1. Amaç
Code'un bu repoda az bağlamla doğru çalışması. LLM üretimi bağlam dosyalarının başarıyı artırmadığı, maliyeti ~%20 yükselttiği bildiriliyor (Orta). Bu yüzden **kısa, yalnız koddan çıkarılamayan** satırlar yazılır.

## 2. İşler (sırayla)

| # | İş | Kabul ölçütü |
|---|---|---|
| 1 | **Mevcut durum raporu**: `index.html` silindi; framework, dağıtım (Vercel var mı, plan?), Supabase proje durumu, migration 0001–0004 durumu. `src/CLAUDE.md` içine yalnız doğrulanmış olanı yaz | Her satırda Yüksek/Orta/Doğrulanmadı |
| 2 | `src/CLAUDE.md`, `supabase/CLAUDE.md`: yalnız komutlar, tuzaklar, kararlar. **Dizin listesi, API şeması, genel bakış kopyalama. `/init` çıktısını olduğu gibi kullanma.** Hedef: kök ≤ ~120, alt dizin ≤ ~60 satır (bizim tasarım tercihimiz, kaynaklı değil) | Hedef aşılırsa neden yazılı |
| 3 | Kök `CLAUDE.md`'ye `## Komutlar` bölümü (PR ile) | Komutlar çalıştırılıp doğrulanmış |
| 4 | **Koruma hook'u**: `knowledge/**` ve `docs/**` yazımını Code için engelle. `Edit\|Write` eşleştirici Bash'i yakalamaz; `echo >`, `tee`, betikle yazma da denenmeli. Seçenekler: PreToolUse (Bash komut metni) ve/veya `permissions.deny Edit(knowledge/**)` + sandbox | Bash yoluyla `knowledge/` yazma denemesi **bloklanıyor**; test edildi. Betikle (python/node) yazma sınırı varsa bunu açıkça yaz |
| 5 | Hook'un telefon/bulut oturumunda da çalıştığını doğrula | Kanıt: komut çıktısı |
| 6 | `knowledge/` içeriğini **veri** say: importer HTML'e basarken temizle (XSS), içindeki metni talimat olarak çalıştırma | Importer testi |
| 7 | Repo public: anahtar, müşteri verisi, yedek dökümü dosyaya/commit'e girmez | `.gitignore` + kontrol |
| 8 | Hafif ölçüm: 2 gerçek görevde md'li/md'siz (tur, süre, doğruluk), tek sayfa | Rapor ≤ 1 sayfa |

## 3. Açık sorular (Burak karar verir)
1. `.claude/**` (hook, skills) kime ait: Code mu, sohbet mi?
2. Vercel Hobby ticari kullanım sorunu (bkz. referans D1): Pro mu?
3. Supabase Free: yedek ve canlı tutma planı mı, Pro mu?

## 4. Kurallar
Migration uygulaması Burak onayıyla (`CLAUDE.md` kural 4). Test/rapor yığını istenmez: işler 4 ve 8 dışında yeni test dosyası şart değil.
