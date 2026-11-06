---
title: Supabase ve Vercel — neler yapılır, yararı, dikkat edilecekler (BEE için)
retrieved: 2026-11-07
---

# Supabase ve Vercel: BEE için okuma notu

Mevcut `supabase.md` / `vercel.md` kural listesidir. Bu dosya "ne yapılabilir + ne ters gider" tarafını ekler. Kaynaklar: [Supabase pricing](https://supabase.com/pricing) · [Project pausing](https://supabase.com/docs/guides/platform/free-project-pausing) · [Supabase way to build](https://supabase.com/docs/guides/getting-started/the-supabase-way-to-build) · [Database overview](https://supabase.com/docs/guides/database/overview) · [Vercel Hobby](https://vercel.com/docs/plans/hobby) · [Fair use](https://vercel.com/docs/limits/fair-use-guidelines) · [Vercel limits](https://vercel.com/docs/limits) · [Vercel projects](https://vercel.com/docs/projects). Limit/fiyat rakamları değişir; karar öncesi sayfaya tekrar bak.

## A. Supabase — ne yapılır (BEE'ye uyanlar)

| Blok | BEE'de kullanımı | Güven |
|---|---|---|
| Postgres + otomatik REST API | Çözüm kaydı, vaka, müşteri tabloları; "şema = API" | Yüksek |
| Auth | Tek kullanıcı (Burak) girişi; RLS bu kimliğe bağlanır | Yüksek |
| RLS | Her tabloda zorunlu; istemciden doğrudan sorgunun güvenliği buna dayanır | Yüksek |
| Storage | Saha fotoğrafı (uç, pano, kablo). Kendi policy'si ayrı yazılır; public bucket herkese açıktır | Yüksek |
| Postgres fonksiyon/RPC | Veriye ait mantık (örn. çözüm süresi hesabı, analiz görünümü) burada, istemcide değil | Yüksek (öneri) |
| Cron (pg_cron) | Periyodik temizlik/özet; Free'de "pause" önleyen etkinlik üretmek için de kullanılabilir | Yüksek (özellik), Orta (bu amaçla yeterliliği) |
| Edge Function | Yalnız gizli anahtar gereken/üçüncü taraf çağrısı için; ilk sürümde gerekmez | Yüksek |
| Realtime | Tek kullanıcıda gereksiz; polling'den iyi ama BEE'de ihtiyaç yok | Yüksek |

## B. Supabase — dikkat edilecekler (önem sırasıyla)

| # | Risk | Neden BEE için önemli | Güven |
|---|---|---|---|
| 1 | **Free proje 1 hafta düşük etkinlikte durur.** Durunca API hata verir, uygulama açılmaz. Geri yükleme panelden, durduktan sonra ~1 yıl içinde | Burak sahada bir hafta girmezse uygulama sabaha ölü. Günde birkaç veritabanı isteği duraklamayı önlemeye genelde yeter | Yüksek |
| 2 | **Free'de otomatik yedek yok** (Pro: 7 gün). Yedek, düzenli `supabase db dump` ile alınır | Çözüm kayıtları ve müşteri verisi tek kopya. Yedek dosyası **public repoya konmaz** (müşteri verisi) | Yüksek (yedek yok), Orta (dump önerisi: ikincil kaynak) |
| 3 | **Yedekler Storage nesnelerini kapsamaz** | Fotoğraflar ayrıca yedeklenmeli | Yüksek |
| 4 | Free limitleri: 500 MB DB, 1 GB dosya, 5 GB egress, 2 aktif proje | Fotoğraf yoğun kullanımda 1 GB dolar. İstemcide sıkıştırma gerekir (aşağıdaki fikirler) | Yüksek |
| 5 | Limit aşımında davranış: DB dolunca salt-okunur, egress aşımında kısıtlama/402 (ikincil kaynaklar) | Kayıt girişi sahada sessizce başarısız olabilir | Orta |
| 6 | Storage policy tablo policy'sinden bağımsız; eksikse dosyalar açık | Müşteri/pano fotoğrafı sızar | Yüksek |
| 7 | Gizli (service_role/secret) anahtar istemci kodunda olmaz; repo public | Yanlışlıkla commit = herkes tüm veriyi okur | Yüksek |
| 8 | Migration dosya olarak yazılır, uygulama Burak onayıyla (bu proje kuralı) | `CLAUDE.md` kural 4 | Yüksek (proje kuralı) |
| 9 | Free'de log saklama 1 gün | Sorun ertesi gün araştırılamaz | Orta (ikincil) |

## C. Vercel — ne yapılır

| Özellik | BEE'de kullanımı | Güven |
|---|---|---|
| Git bağlı dağıtım + her PR için önizleme URL'si | iPhone'dan dalı açmadan deneme | Yüksek |
| Instant Rollback | Bozuk sürümde bir dokunuşla geri dönüş | Yüksek |
| Statik barındırma, `vercel.json` rewrites/headers | Tek sayfa uygulama yönlendirmesi, önbellek/güvenlik başlıkları | Yüksek |
| Ortam değişkenleri (development/preview/production ayrı) | Supabase URL ve public key; değişince yeniden dağıtım gerekir | Yüksek (ortam ayrımı); yeniden dağıtım: mevcut `vercel.md` |
| Vercel Functions, Cron Jobs | İhtiyaç olursa; Cron Hobby'de de var | Yüksek |
| Deployment Protection (Vercel Authentication) | Önizlemeleri girişsiz erişime kapatır | Yüksek |

## D. Vercel — dikkat edilecekler

| # | Risk | Güven |
|---|---|---|
| 1 | **Hobby planı yalnız ticari olmayan kişisel kullanım içindir.** "Mali kazanç amacıyla kullanılan her dağıtım" ticari sayılır; Pro ($20/ay) gerekir. BEE bir iş aracı. Yorum: bu tanıma girebilir, kesin hüküm Vercel destek tarafında | Yüksek (kural), **Doğrulanmadı** (BEE'nin kapsamda olduğu) |
| 2 | Hobby: günde 100 dağıtım, çalışma günlüğü 1 saat, kullanım aşımında 30 gün bekleme | Yüksek |
| 3 | Vite benzeri `VITE_` önekli değişkenler istemci paketine gömülür; gizli anahtar bu önekle konmaz (BEE vanilla JS, build yok → geçerli değil, Code'a not) | Yüksek |
| 4 | Önizlemeler üretim verisine erişirse blast radius büyür; önizleme ortamı ayrı Supabase anahtarı/projesi kullanmalı | Yüksek (ilke) |
| 5 | Public repo + Git bağlı dağıtım: her push canlıyı etkileyebilir; `main`'e doğrudan push yasağı bu yüzden önemli | Orta |

## E. Karar gereken noktalar (Burak)

1. Vercel: Hobby'de kalınacak mı, Pro mu? (D1)
2. Supabase: Free'de yedek + canlı tutma planı mı, Pro mu? (B1, B2)
3. Fotoğraflar Supabase Storage'a mı gidecek? (B3, B4)
