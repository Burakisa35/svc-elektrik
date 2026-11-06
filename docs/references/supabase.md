---
title: Supabase — proje rehberi
retrieved: 2026-11-07
---

# Supabase nasıl kullanılır

Kaynaklar: [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security) · [Securing your API](https://supabase.com/docs/guides/api/securing-your-api) · [Migrations](https://supabase.com/docs/guides/deployment/database-migrations) · [Local workflow](https://supabase.com/docs/guides/local-development/cli-workflows) · [Environments](https://supabase.com/docs/guides/deployment/managing-environments) · [Maturity model](https://supabase.com/docs/guides/deployment/maturity-model) · [Production checklist](https://supabase.com/docs/guides/security/production-checklist) · [Shared responsibility](https://supabase.com/docs/guides/deployment/shared-responsibility-model)

## Güvenlik (tek kullanıcılı olsa da geçerli)
| Kural | Güven |
|---|---|
| Publishable key uygulamada yayınlanır; Data API tabloları o anahtarı bilen herkese açar. RLS'siz tablo herkesçe okunur/yazılır | Yüksek |
| Açık şemadaki **her** tabloda RLS aç; ayrıca `anon`/`authenticated` varsayılan yetkilerini geri al (`revoke all`) ve yalnız gerekeni ver. Policy eklemek yetkiyi geri almaz | Yüksek |
| Grant + RLS aynı migration'da | Yüksek |
| `service_role` RLS'yi atlar; yalnız sunucu tarafı (importer/edge function), istemciye asla | Yüksek |
| `security definer` fonksiyonları tek tek gözden geçir; RLS fonksiyonlara uygulanmaz, `execute` yalnız gerekenlere | Yüksek |
| Her tablo için `supabase/tests/` altında allow/deny testi, `supabase test db` | Yüksek |
| Security Advisor uyarılarını uygulamak bizim sorumluluğumuz | Yüksek |

## Şema ve migration
| Kural | Güven |
|---|---|
| Uzak veritabanını doğrudan değiştirme (SQL editor, Table Editor dahil); `db push` senkron hatası verir | Yüksek |
| Akış: `supabase migration new ad` → SQL yaz → `supabase db reset` ile yerelde doğrula → `supabase/migrations` commit | Yüksek |
| Yerel yığın yalnız geliştirme içindir, internete açılmaz | Yüksek |
| Seed'i elle yaz; üretim verisi/kişisel veri/anahtar commit etme | Yüksek |
| `db reset --remote` yıkıcıdır, üretimde asla | Yüksek |
| Canlıya çıkınca Dashboard ile şema değiştirme; ortamlar yerel → staging → prod önerilir | Yüksek |

## Bu proje için uygulama
1. **Bilgi tabanı tabloları** (`system_family`, `brand_model`, `terminal_map`, `fault_case`, `test_step`): `anon` okuma hakkı yok; yalnız Burak'ın oturumu (`authenticated`, tek kullanıcı kontrolü policy'de). (Orta: tasarım kararı, Burak onayı bekliyor)
2. **Müşteri paylaşım linkleri**: tabloya `anon select` verilmez; token doğrulayan dar bir `security definer` fonksiyon veya edge function. (Orta)
3. **Importer**: `knowledge/*.md` → tablolar, idempotent upsert (id = dosya `id`). `service_role` anahtarı yalnız yerelde/CI'da ortam değişkeni; repoya ve Vercel istemci değişkenlerine girmez. (Orta)
4. **Migration onayı**: bu projede migration önce dosya olarak yazılır, uygulama Burak onayıyla (`CLAUDE.md` kuralı 4). Uygulamadan önce `get_advisors` ile güvenlik taraması. (Orta)
5. **Staging**: tek kullanıcı için ayrı staging projesi şart değil; asgari: yerel + prod. Canlı veri girdikten sonra prod'a Dashboard'dan şema değişikliği yok. Staging kararı Burak'ta. (Orta)

## Doğrulanmadı
- Mevcut Supabase projesinin var olup olmadığı, hangi bölgede/planda olduğu bu turda kontrol edilmedi.
