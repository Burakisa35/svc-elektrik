---
title: Ücretsiz / en çok ~20$ servis kataloğu (sürekli liste)
retrieved: 2026-11-07
---

# Ücretsiz veya aylık ≤ ~20$ servisler

Canlı liste: ihtiyaç doğdukça eklenir. Her satır kaynaklı; fiyat/limit değişir, karar öncesi sayfaya tekrar bak. Güven: Yüksek = resmî sayfa bu oturumda okundu. "Ticari kullanım" sütunu ayrıca kontrol edilir (Vercel Hobby'de sorun çıktı).

## Katalog

| Kategori | Servis | Ücretsiz katman | ≤ ~20$ katman | Tuzak / not | Ticari kullanım | Güven |
|---|---|---|---|---|---|---|
| E-posta (bildirim, kampanya) | [Brevo](https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan) | Süresiz ücretsiz: günde 300 e-posta, 100.000 kişi, işlem e-postası ve API/SMTP dahil, SMS ek paket | Starter ~9$/ay'dan: günlük limit yok, aylık 5.000+ | Günlük limit aşılınca işlem e-postalarında 1.000'e kadar kuyruk, fazlası teslim edilmez. Kampanya 300 kişiden fazlaysa kalanı elle yeniden gönderilir. SMS prepaid kredi | Kısıtlama bu oturumda aranmadı: **Doğrulanmadı** | Yüksek (limitler) |
| E-posta (yalnız işlem / API) | [Resend](https://resend.com/pricing?product=transactional) | 3.000/ay ve günde 100, 3 alan adı | Pro 20$/ay: 50.000/ay, günlük limit yok | Gelen e-posta da kotadan düşer; günlük kota UTC gününe göre | Aranmadı: **Doğrulanmadı** | Yüksek |
| Barındırma + edge (Vercel alternatifi) | [Cloudflare Workers/Pages](https://developers.cloudflare.com/workers/platform/limits/) | Workers: günde 100.000 istek, istek başı 10 ms CPU. Pages: ayda 500 build, 20.000 dosya, dosya başı 25 MiB | Workers Paid en az 5$/ay | Free'de CPU 10 ms sınırı; limit aşılınca hata (1027) | Vercel gibi Hobby ticari yasağı **bu oturumda doğrulanmadı** | Yüksek (limitler) |
| Nesne depolama (fotoğraf) | [Cloudflare R2](https://developers.cloudflare.com/r2/pricing/) | 10 GB-ay, 1 milyon yazma + 10 milyon okuma/ay, çıkış (egress) ücretsiz | Standart 0,015$/GB-ay | Supabase Free Storage 1 GB'tan çok daha geniş. Ama Supabase RLS ile bağlı değil, ayrı erişim kontrolü gerekir | Aranmadı | Yüksek (fiyat) |
| CI / zamanlanmış iş | [GitHub Actions](https://docs.github.com/en/billing/concepts/product-billing/github-actions) | Public repoda standart runner ücretsiz. Özel repoda GitHub Free'de 12$ değerinde ayda dahil kullanım, 500 MB artifact | — | Public repoda log ve artifact herkese açık olabilir: yedek dökümü orada saklama | Kullanım koşulları GitHub ToS | Yüksek |
| Veritabanı | Supabase Free | Bkz. `supabase-vercel-yapilabilecekler.md` | Pro 25$ (**20$ üstü**) | 1 hafta etkinliksizlikte durur, yedek yok | Aranmadı | Yüksek |
| Barındırma | Vercel Hobby | Bkz. aynı dosya | Pro 20$/ay | **Ticari kullanım yasak** | Hayır (kural) | Yüksek |
| Ses → yazı (sahada dikteyle not) | [Spokenly](https://spokenly.app/pricing) | iPhone dahil (iOS 16.4+, özel klavye). Cihaz üstü Whisper/Parakeet modelleri sınırsız ve ücretsiz, hesap gerekmez; 100+ dil, otomatik algılama. Kendi API anahtarınla Spokenly ücret almaz, sağlayıcı kullanıma göre faturalar | Local+ 29$ tek seferlik (senkron, ek stil); Pro 12$/ay yıllık ödemeyle, 15$ aylık (bulut model + yapay zekâ temizleme) | Fiyat kaynaklarda farklı (resmî site 12$/15$, bir inceleme 9,99$, App Store 9,99–10,99$): tarih farkı olabilir, kesin değil. iPhone'da 700 MB üstü Whisper modeli çalışmayabilir (nicelenmiş ~547 MB önerilir). **Türkçe doğruluğu denenmedi: Doğrulanmadı.** Bulut modelde ses sağlayıcıya gider; müşteri adı/adres dikte etme | Resmî sayfada kısıtlama belirtilmedi (hesap paylaşımı yasak) | Yüksek (özellik/fiyat), Doğrulanmadı (Türkçe kalite) |
| Yapay zekâ (kodlama) | [Claude Pro](https://claude.com/pricing?mode=code) | Ücretsiz planda Claude Code **yok** | Pro 20$/ay (yıllık 17$/ay): Claude Code dahil; sohbet ve Code aynı kotayı paylaşır; 5 saatlik + haftalık limit | Üst model (Fable) Pro'da yalnız kullanım kredisiyle. Limit dolunca bekle veya kredi al | — | Yüksek |

## Eleme soruları (bir aracı listeye "teknisyene yararlı" diye almadan önce)

"Yüzde yüz yararlı" önceden garanti edilemez; yerine sınanabilir bir ölçüt konur: aşağıdaki üç soruya cevap ve 1 haftalık deneme.

| # | Soru | Neyi eler | Kanıt kaynağı |
|---|---|---|---|
| S1 | **Acı:** Son 10 işte bu sorun kaç kez yaşandı ve her seferinde kaç dakika/TL kaybettirdi? | "Güzel ama gerekmeyen" araçlar | Burak'ın iş geçmişi; çözüm kaydındaki süre verisi (brief 002) |
| S2 | **Saha:** iPhone 11'de, tek elle, internetsiz, ~30 saniyede çalışıyor mu? Çalışmazsa sessizce mi bozuluyor? | Masa başı araçlar, sessiz başarısızlık | Sahada denemeyle (belge okumak yetmez) |
| S3 | **Bedel ve çıkış:** Durursa, fiyat artarsa, ticari koşul engellerse veri ve iş akışı ne olur? | Kilitlenme, Vercel Hobby türü sürprizler | Resmî koşullar + dışa aktarma imkânı |

Karar kuralı: S1 ölçülmediyse araç "aday" kalır, S2 başarısızsa elenir, S3 cevapsızsa "Doğrulanmadı" ile ertelenir. Deneme: 1 hafta, bitiş ölçütü baştan yazılır.

## Kategori mantığı
Liste e-postayla sınırlı değil: ihtiyaç doğdukça yeni kategori açılır (ses→yazı, depolama, CI, yapay zekâ...). Her satırda aynı sorular: ücretsiz katman, ≤ ~20$ katman, tuzak/durma davranışı, ticari kullanım, güven.

## Henüz taranmayan kategoriler (sıradaki turlar)
Hepsi **Doğrulanmadı** (aranmadı): SMS (Türkiye fiyatı), harita/geokodlama, PDF üretimi/OCR, fotoğraf ölçüm/etiketleme, otomasyon (webhook/zamanlayıcı), hata izleme, çevrimdışı not/yedek, alan adı/DNS, kamera/CCTV araçları (Hikvision, ayrı iş kolu), antenli uydu açı bulucu (satfinder ayrı projede).

## Kullanım ilkesi
1. Önce ticari kullanım koşuluna bak (BEE iş aracıdır).
2. Sonra "durma" ve "limit aşımı" davranışına bak: sessiz başarısızlık sahada en pahalı hatadır.
3. Public repoya anahtar, müşteri verisi, döküm girmez.
