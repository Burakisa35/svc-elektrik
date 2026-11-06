# supabase/ — Claude Code kuralları

## Kurallar
- Proje: `burak-elektrik`, ref `uwmbtaxxdcjumxbnigpy`. TEHAİ projesi (`ofgenhpryssfznslxdkp`) bu repoya ait değil; ona yazma.
- **Uygulama onayı Burak'tan.** Migration dosya olarak yazılır; Burak onaylamadan uygulanmaz (kök `CLAUDE.md` kural 4).
- Her migration'ın ilk satırı kimlik kapısıdır: `select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');`
- Uygulanmış migration düzenlenmez; değişiklik yeni numarayla yapılır. Numara canlıdan okunur (`list_migrations`), dizinden değil.
- Her tabloda RLS açık, politika yok; anon ve authenticated rollerine tablo yetkisi verilmez. Anon yalnız `svc_*` fonksiyonlarını çalıştırır ve her fonksiyonun ilk adımı anahtar kontrolüdür (`svc_sahip_dogrula` / `svc_kapi_dogrula`).
- SECURITY DEFINER fonksiyonlarda `set search_path = public, pg_temp` zorunlu.
- Para alanları `numeric(12,2)` (TL). Girilmeyen alanın varsayılan değeri olmaz; boş kalır.
- `svc_olaylar` yalnız eklenir; iş ve talep silinmez (0004).

## Durum (2026-11-07)
| Migration | Durum | Güven |
|---|---|---|
| 0000–0003 | Canlıda; uygulanan SQL'in MD5'i dosyayla aynı | Yüksek |
| 0004 | **Yazıldı, uygulanmadı.** MCP `apply_migration` onay sorusu 4 kez cevapsız kaldı (pencere Burak'a ulaşmıyor olabilir) | Yüksek |
| Kurulum (`svc_kurulum()`) | Yapılmadı; `svc_ayarlar` boş, bu yüzden bütün fonksiyonlar kapalı | Yüksek |

## Tuzaklar
- `apply_migration`, DROP içeren SQL'de onay ister. Onay gelmezse 230 sn sonra zaman aşımına uğrar; aynı turda tekrar denenmez.
- SQL Editor'den elle uygulanan migration `schema_migrations`'a kaydedilmez. Kanıt olarak eserler (sütun, fonksiyon) ölçülür.
- Test geri alınsa da sıra numaraları geri alınmaz: testten sonra ilk gerçek kayıt `T26-0001` olmaz.
- Free plan: yedekleme ve zamana geri dönüş yok; Supabase dokümanına dayanıyor, hesapta doğrulanmadı.

## Komutlar
```bash
md5sum supabase/migrations/*.sql
```
Canlıdaki karşılığı: `select name, md5(array_to_string(statements,'')) from supabase_migrations.schema_migrations order by version;`

Erişim testi: `supabase/tests/db-erisim.sql` dosyasını SQL Editor'de ya da MCP `execute_sql` ile çalıştır. Beklenen sonuç `BEE_TEST_SONUC kalan=0` hatasıdır; hata kasıtlıdır, test verisini geri alır. Son koşum: 38/38.
