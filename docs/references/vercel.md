---
title: Vercel — proje rehberi
retrieved: 2026-11-07
---

# Vercel nasıl kullanılır

Kaynaklar: [Environment variables](https://vercel.com/docs/environment-variables) · [Ortamlar arası yönetim](https://vercel.com/docs/environment-variables/manage-across-environments) · [Config ve Secret](https://vercel.com/docs/environment-variables/sensitive-environment-variables) · [Deployments/Environments](https://vercel.com/docs/deployments/environments) · [Proje ayarları](https://vercel.com/docs/project-configuration/project-settings) · [vercel env](https://vercel.com/docs/cli/env) · [Framework değişkenleri](https://vercel.com/docs/environment-variables/framework-environment-variables)

## Resmî ilkeler
| Kural | Güven |
|---|---|
| Üç ortam: Production (production branch'e push veya `vercel --prod`), Preview (diğer branch/PR), Development (yerel). Değişkenler ortam başına atanır | Yüksek |
| Değişken değişikliği eski deployment'lara uygulanmaz; **yeniden deploy** gerekir | Yüksek |
| Parola/anahtar/token **Secret** türünde (yazma-yalnız); `vercel env add ... --sensitive`. Config türü okunabilir kalır | Yüksek |
| Her PR/branch için preview deployment ve otomatik URL (branch URL'si ve commit URL'si) oluşur | Yüksek |
| Yeni projenin **ilk** deployment'ı daima production'dır ve yalnız Production değişkenleriyle derlenir | Yüksek |
| Staging için Hobby dahil tüm planlarda: `staging` branch'i + preview alan adı + branch'e özel Preview değişkenleri; veya "staged production deployment" (otomatik domain atamasını kapat, doğrula, sonra promote) | Yüksek |
| Framework önekli değişkenler (`NEXT_PUBLIC_`, `PUBLIC_`) tarayıcıya gider | Yüksek |
| `vercel env pull` değişkenleri dosyaya yazar; `vercel env run -- komut` dosyaya yazmadan çalıştırır | Yüksek |
| `vercel.json` ve proje ayarlarında build/Node sürümü vb. tanımlanır | Yüksek |

## Bu proje için uygulama
1. **Her Code PR'ı preview URL'siyle gelir.** Burak telefonda preview'u dener, G3 kapısı budur (`docs/quality/gates.md`). (Orta: ilkeden uyarlama)
2. **Anahtar ayrımı.** Tarayıcıya giden yalnız Supabase publishable key ve proje URL'si (öneklenmiş). `service_role` hiçbir zaman Vercel istemci değişkeni olmaz. (Orta)
3. **Production'a elle promote.** Yeniden yazılan site yeterince oturana kadar "auto-assign production domains" kapalı tutulabilir; doğrulanan build promote edilir. Burak onayı gerekir. (Orta)
4. **.env dosyaları** gitignore'da; yerelde `vercel env pull`. (Orta)
5. **Mevcut sürüm**: kökteki `index.html` yeniden yazılacak; Vercel'e hangi repo/branch/domain bağlı **Doğrulanmadı**. Code'un ilk işi bunu raporlamak.

## Doğrulanmadı
- Geri alma (rollback/promote) akışı ve plan sınırları bu turda kaynakla doğrulanmadı.
- Bu repo için Vercel projesi, alan adı ve plan bilgisi kontrol edilmedi.
