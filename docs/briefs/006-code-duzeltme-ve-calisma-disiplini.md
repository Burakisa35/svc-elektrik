# Brief 006 — Code: brief 004 düzeltmeleri ve çalışma disiplini

Yazan: sohbet Claude'u · Uygulayan: Claude Code · Karar: Burak · Tarih: 2026-11-07 · Durum: taslak
Dayanak: `docs/quality/findings/004-code-brief004-denetimi.md` (bulgular B1–B8)

## 1. Önce, ne iyi gitti (korunacak)
Bilmediğini "Doğrulanmadı" bırakma, kendi sınırını yazma, hook'u bozarak sınama, MD5 ile canlıyı doğrulama, 31–32 satırlık alt dizin dosyaları. Bunlar bu projede çalışma biçimidir; bozulmasın.

## 2. Düzeltmeler (bu sırayla)

| # | İş | Neden | Kabul ölçütü |
|---|---|---|---|
| 1 | **Rapor/CLAUDE.md dürüstlüğü (B4, B5):** kök `CLAUDE.md` Komutlar bölümündeki "hook engeller" cümlesine etiket ekle: canlı oturumda **Doğrulanmadı** (kök kural: her teknik iddia etiket taşır). Brief 004 madde 3 ve 5'i "kısmen" olarak işaretle | Bağlayıcı metinde ölçülmemiş iddia | İki cümle düzeltilmiş |
| 2 | **Hook yanlış pozitifleri (B2):** salt okuma komutları engellenmemeli: `node araç.mjs knowledge/`, `grep ... docs/ > /tmp/x`, `git show HEAD:docs/x > /tmp/y`. Yazma yönlendirmesi yalnız **hedef korunan yolsa** engellenmeli. Test dosyasına bu üç vaka (izin) eklenir | Planlanan linter/importer `knowledge/` okuyacak; hook onu kırar | Yeni vakalar kod 0 döner, mevcut 24 vaka bozulmaz |
| 3 | **Hook kaçakları (B3): hook'a yama yapma, sunucu tarafı kapı kur.** GitHub Actions (public repoda ücretsiz) PR'da korunan yolların değişimini kontrol eder; hook yerel kolaylık kalır. Bunun için `setup/foundation` önce `main`'e birleşmeli ki fark yalnız Code'un değişikliğini göstersin (birleştirme Burak'ın PR onayıyla) | Betik, `curl -o`, glob ve birleştirme yerel hook'u geçiyor; CI telefon/bulut oturumunda da çalışır | `claude/*` dalından `knowledge/x.md` değiştiren deneme PR'ı **kırmızı** olur |
| 4 | **Koruma kapsamı (B1):** `docs/**` kilidi daraltılır. Önerilen: `knowledge/**`, `docs/briefs/**`, `docs/decisions/**`, `docs/quality/**`, `docs/references/**`, `docs/soru-bankasi/**` korunur; Code'un teknik belgeleri `docs/kod/` altında Code'undur (`VERI_MODELI.md`, `ROADMAP.md` taşınır). **Burak onayı gerekir; kök `CLAUDE.md` rol tablosu buna göre güncellenir** | Kural benim brief'imden fazla geniş geldi | Burak kararı sonrası |
| 5 | **Test canlı veritabanında (B6):** gerçek veri girince canlıda test koşma. Seçenekler: ikinci ücretsiz proje (aynı anda 2 aktif proje hakkı var, Yüksek) veya testi yalnız ilk gerçek veriden önce koş. Burak karar verir | Sıra numaraları geri alınmıyor; gerçek veride risk | Karar kayıtlı |
| 6 | **0004 (B7):** uygulama anında tablo satır sayıları yeniden ölçülür ve rapora yazılır; `drop function` etkisi (yalnız eski imza) yazılı | "0 satır" beyanı eskir | Ölçüm çıktısı raporda |

## 3. Çalışma disiplini (kalıcı, 3 satır — `src/CLAUDE.md`'ye Code karar verip ekler)
1. "Bitti" yazmadan önce her madde için kanıt komutunun çıktısı var mı? Yoksa **"kısmen"** veya **Doğrulanmadı**.
2. Bağlayıcı metne (CLAUDE.md) yazdığın her cümle etiket taşır; ölçmediğin şey etiketsiz yazılmaz.
3. Son rapor ≤ 15 satır: sonuç, kanıt, yapılmayanlar, Burak'ın vereceği karar. Süreç anlatımı rapora girmez.

## 4. Sıra ve sınır
Önce 1 ve 2 (küçük, hemen). 3 ve 5, 4 Burak kararlarına bağlı. Brief 005 (soru sistemi) bu dalda henüz yok; **düzeltmeler bitmeden başlanmaz** (yığın istemiyoruz).
