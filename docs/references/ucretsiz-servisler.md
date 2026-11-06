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
| Yapay zekâ (kodlama) | [Claude Pro](https://claude.com/pricing?mode=code) | Ücretsiz planda Claude Code **yok** | Pro 20$/ay (yıllık 17$/ay): Claude Code dahil; sohbet ve Code aynı kotayı paylaşır; 5 saatlik + haftalık limit | Üst model (Fable) Pro'da yalnız kullanım kredisiyle. Limit dolunca bekle veya kredi al | — | Yüksek |

## Henüz taranmayan kategoriler (sıradaki turlar)
SMS (Türkiye operatör fiyatı), harita/geokodlama, PDF üretimi, otomasyon (webhook/zamanlayıcı), hata izleme/izleme, saha formu/ yedek bulut, alan adı/DNS. Hepsi **Doğrulanmadı** (aranmadı).

## Kullanım ilkesi
1. Önce ticari kullanım koşuluna bak (BEE iş aracıdır).
2. Sonra "durma" ve "limit aşımı" davranışına bak: sessiz başarısızlık sahada en pahalı hatadır.
3. Public repoya anahtar, müşteri verisi, döküm girmez.
