# src/ — Claude Code kuralları

## Durum (2026-11-07 ölçümü)
| Konu | Durum | Güven |
|---|---|---|
| `index.html` | `claude/jolly-allen-7gfz46` dalında silindi (`babcfac`); `main`'de hâlâ eski sayfa var | Yüksek |
| Framework | Yok. Vanilla HTML/CSS/JS + Vercel serverless (`src/api/*.js`, Node ESM). `package.json` yok, npm bağımlılığı yok | Yüksek |
| Vercel | `svc-elektrik` projesi var (takım `burakisa35's projects`) | Yüksek |
| Vercel bağlı repo, kök dizin, plan, deploy geçmişi | API 404/403 döndü, okunamadı | Doğrulanmadı |
| Supabase | `burak-elektrik`, ref `uwmbtaxxdcjumxbnigpy`, Frankfurt, plan free | Yüksek |
| `src/api/panel.js`, `src/api/public.js` | **Bozuk:** var olmayan eski tablolara (`svc_jobs`, `svc_customers`) bakıyor. Yeniden yazılacak | Yüksek |
| Ekranlar (panel, giriş, müşteri sayfası, vitrin) | Yok | Yüksek |

## Kararlar (koddan okunamaz)
- **Vercel'de service_role yok.** Sunucu yalnız publishable key + iki sır (`BEE_KAPI_ANAHTARI`, `BEE_SAHIP_ANAHTARI`) tutar; her veri işlemi bir `svc_*` DB fonksiyonudur. Tablolara doğrudan sorgu yazma.
- Publishable key tarayıcıya gitmez. DB hata metni tarayıcıya aktarılmaz; `BEE_*` kodu sabit bir mesaja eşlenir.
- Müşteri linki `/is#k=<token>`: token URL parçasında taşınır, sayfa JS'i onu POST gövdesinde gönderir (sunucu kaydına ve Referer'a düşmez).
- Parola PBKDF2-SHA256 600.000 iterasyon, sunucuda hesaplanır, karşılaştırma `timingSafeEqual` ile yapılır.
- Oturum çerezi `HttpOnly; Secure; SameSite=Strict`. Her istekte `svc_s_oturum_surumu` kontrol edilir; çıkış sürümü artırır.
- Mobil: ≤520px tek kolon, dokunma hedefi ≥44px, `100dvh`, form `font-size ≥16px`.
- Vercel kök dizini `src/` olmalı (`api/` ve `vercel.json` burada). Proje ayarında doğrulanmadı.

## Çalışma disiplini (brief 006 §3)
1. Bir madde ancak kanıt komutunun çıktısı varsa "bitti" yazılır; yoksa **kısmen** ya da **Doğrulanmadı**.
2. CLAUDE.md'ye yazılan her cümle güven etiketi taşır; ölçülmeyen şey etiketsiz yazılmaz.
3. Son rapor ≤15 satırdır: sonuç, kanıt, yapılmayanlar, Burak'ın karar vereceği konular. Süreç anlatımı rapora girmez. Teslimler `TESLIMLER.md`'ye işlenir.

## Tuzaklar
- `#` sonrası bazı uygulamalarda kaybolabilir; WhatsApp→Safari testi gerçek telefonda yapılır.
- iOS ana ekran PWA'sının çerez deposu Safari'den ayrıdır (Orta).
- PostgREST, yanlış yazılmış fonksiyon adına "bunu mu demek istediniz" ipucu verir: ad sızar, yetki sızmaz.

## Komutlar
```bash
for f in src/api/*.js src/assets/js/*.js; do node --check "$f"; done
```
