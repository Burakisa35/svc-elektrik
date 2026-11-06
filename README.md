# svc-elektrik

**Burak Elektrik ve Elektronik Teknik Servis (BEE)** — tek kullanıcılı, mobil öncelikli servis yönetim sitesi.

## Amaç

1. Saha işlerini ve müşteri bağlantılarını yönetmek.
2. **Teknik bilgi tabanı:** diafon/zil/interkom sistemlerinin uç haritaları, arıza vakaları ve test adımları; sahada "belirti → soru → test → olası neden" akışıyla kullanılır.

## Yerleşim

| Klasör | İçerik | Sahibi |
|---|---|---|
| `knowledge/` | Araştırma bilgi tabanı (güven etiketli) | Claude (sohbet) |
| `docs/briefs/` | Araştırma ve tasarım brief'leri | Claude (sohbet) |
| `docs/decisions/` | Karar kayıtları | Claude (sohbet) + Burak |
| `docs/references/` | Araç rehberleri (CLAUDE.md, Supabase, Vercel); resmî kaynaklı | Claude (sohbet) |
| `docs/quality/` | Kalite kapıları, denetim bulguları | Claude (sohbet), ayrı denetçi oturum |
| `src/`, `supabase/` | Uygulama ve veritabanı | Claude Code |

Kurallar ve rol sınırları: [`CLAUDE.md`](CLAUDE.md). Bilgi tabanı formatı: [`knowledge/_SPEC.md`](knowledge/_SPEC.md).

## Durum

Faz 0 (temel/iskelet) tamamlanıyor. Plan: araştırma (Netelsan, Audio, Simge → küresel aileler) → şartname → brief'ler → Claude Code uygulaması → denetim.
