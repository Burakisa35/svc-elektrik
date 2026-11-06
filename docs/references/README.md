# docs/references/

Projede kullandığımız araçların **doğru kullanım rehberi**. İki katman:

| Katman | Nedir | Nerede |
|---|---|---|
| **Temel (iç) referans** | Bu projenin kendi kuralları: roller, güven etiketi, kapılar | `CLAUDE.md`, `knowledge/_SPEC.md`, `docs/quality/` |
| **Dış referans** | Resmi dokümanlardan, bu projeye uyarlanmış özet | bu klasör |

Dosyalar: [`claude-md.md`](claude-md.md) · [`supabase.md`](supabase.md) · [`vercel.md`](vercel.md)

## Kurallar
- Kaynak yalnızca resmî doküman (code.claude.com, supabase.com, vercel.com). Her dosyanın başında `retrieved` tarihi var.
- Araç dokümanları sık değişir. Büyük bir iş öncesi ilgili sayfa yeniden açılır; tarih eskiyse dosya tazelenir.
- Güven etiketi: **Yüksek** = resmî dokümanda açıkça yazıyor; **Orta** = dokümandan çıkarım / projeye uyarlama; **Doğrulanmadı** = bu turda kaynakla teyit edilmedi.
- Bu dosyalar Claude Code içindir: `src/` ve `supabase/` kararlarında önce buraya bakılır; çelişki varsa brief ile bildirilir.
