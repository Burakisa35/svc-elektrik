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
| 0000–0005 | Canlıda; uygulanan SQL'in MD5'i dosyayla aynı (0004 `964f018d…` 06:57 UTC, 0005 `525f045a…` 07:16 UTC; ikisinde de bütün `svc_` tabloları 0 satır). 0005 sonrası: `svc_sahip_dogrula` oturum istiyor, `svc_s_giris_baslat` özet döndürmüyor, iç kapılar anon'a kapalı, danışman yalnız beklenen iki bulgu | Yüksek |
| 0006 | **Yazıldı, uygulanmadı.** Yalnız DROP/durum seti; gerçek silme olduğu için onay sorusu meşru ve bu oturumdan cevaplanamaz. **Ara durum (0005'te):** `svc_talep_olustur` iki sürüm yan yana, 13 parametreli çağrı "not unique" verir; durum CHECK'i eski set ('beklemede' var, 'ertelendi'/'kacirildi' yok). `SON=0005 bash supabase/tests/yerel-kurulum.sh` bu iki farkı KALDI olarak gösterir | Yüksek (yerel ölçüm) |
| Kurulum (`svc_kurulum()`) | Yapılmadı; `svc_ayarlar` boş, bu yüzden bütün fonksiyonlar kapalı. 0003'ün parolasız giriş açığı 0005 ile kapandı (`svc_s_giris_basarili` artık oturum istiyor, canlıda ölçüldü). Talep formu ve iş durumları için önce 0006 | Yüksek |

**API sözleşmesi (0005 sonrası):** giriş = `svc_s_giris_baslat` (salt, iterasyon) → sunucu PBKDF2 600k → `svc_s_giris_tamamla(anahtar, türetilmiş_hex, istemci)` → dönen `oturum` httpOnly çereze. Bundan sonraki her sahip RPC'si `x-bee-oturum: <token>` başlığıyla POST edilir. İlk parola: `svc_s_sifre_kur(anahtar, sha256(türetilmiş), salt, 600000)`. Çıkış: `svc_s_cikis`. Başlığın Supabase gateway'inden PostgREST'e geçtiği Supabase'in kendi örneğine dayanıyor (`x-app-api-key`, Yüksek); bu projede canlıda ölçülmedi.

## Yetki modelinin en kritik açığı ve karar önerisi (araştırma 2026-11-07, Burak onayı bekliyor)
**Açık:** DB yalnız sahip anahtarını doğruluyor, oturumu doğrulamıyor. Vercel ortamı sızarsa saldırgan `svc_s_giris_baslat` ile parola özetini alabilir (çevrimdışı kaba kuvvet), `svc_s_giris_basarili`'yi doğrudan çağırıp parolasız "giriş" yapabilir. Parola, kilit ve çıkıştaki iptal böylece atlanır (Yüksek, kod okundu).
**Öneri (0005):**
1. **Parola doğrulaması DB'de, PBKDF2 sunucuda kalır.** DB yalnız `sha256(PBKDF2(parola, salt, 600k))` özetini saklar. Sunucu türettiği anahtarı gönderir, DB özetle karşılaştırır. DB özet ya da salt dışında hiçbir şey döndürmez. Bu, RFC 5802 SCRAM'deki StoredKey düzeninin basit hâli: "saklanan bilgi tek başına istemciyi taklit etmeye yetmez" (Yüksek, RFC). Sonuç: anahtarı ele geçiren kişi yalnız çevrimiçi tahmin yapabilir, o da DB'deki atomik kilide takılır.
2. **Oturum DB'de.** Başarılı girişte DB rastgele bir oturum token'ı üretir ve `svc_oturumlar`'a yalnız özetini, süresiyle ve iptal alanıyla yazar. Sunucu token'ı httpOnly çerezde tutar ve her istekte `x-bee-oturum` başlığıyla gönderir. `svc_sahip_dogrula` başlığı `current_setting('request.headers', true)::json->>'x-bee-oturum'` ile okur (PostgREST ve Supabase belgeleri, Yüksek). Diğer ~15 fonksiyonun imzası değişmez. Yalnız giriş fonksiyonları başlıksız çalışır. Çıkış oturum satırını iptal eder.
3. **Reddedilen yol, kendi JWT'mizi imzalamak:** Supabase, projeye özel imza anahtarı yüklemeye izin veriyor, ama bu anahtar `service_role` dahil **her rolü** basabilir (Supabase signing-keys belgesi, Yüksek). Anahtar sızarsa RLS dahil her şey açılır; bugünkü modelden daha kötü.
4. **Legacy anahtarlar:** `anon` ve `service_role` (10 yıllık JWT'ler) hâlâ etkin ve kullanılmıyor. Supabase bunları 2026 sonunda kaldırıyor. Dashboard'dan devre dışı bırakılmalı: Settings → API Keys (Burak; Yüksek).
Kalan risk: anahtar ile canlı çerez **birlikte** çalınırsa erişim açılır. Anahtarla kilit tetiklenip sahip dışarıda bırakılabilir (hizmet engelleme).

## Tuzaklar
- **Onay sorusu bu oturumdan cevaplanamaz.** Supabase MCP (0.13.0, 2026-09-17'den beri) bir ifade DROP/DELETE/TRUNCATE ile başlıyorsa onay sorar; fonksiyon gövdesinin içi de sayılır (kaynak: supabase/mcp `destructive-sql.ts`, Yüksek). Soru oturumun koştuğu yerde, yani bu bulut konteynerinde çıkar, Burak'a ulaşmaz (supabase/supabase PR 53018, Orta) ve 230 sn sonra zaman aşımına uğrar. Uygulamadan önce `node araclar/mcp-soru-tahmini.mjs` çalıştırılır: "SORU ÇIKAR" diyen dosya MCP ile denenmez; aynı turda tekrar da denenmez.
- SQL Editor'den elle uygulanan migration `schema_migrations`'a kaydedilmez. Kanıt olarak eserler (sütun, fonksiyon) ölçülür.
- Sıra numaraları (`nextval`) transaction geri alınsa da ilerler. `db-erisim.sql` başta sayaçları kaydeder, sonda `setval` ile geri yükler (setval kalıcıdır). Yeni test bu kalıbı izlemeli; yoksa ilk gerçek iş `BEE-26-0001` olmaz.
- Free plan (Supabase dokümanı, Yüksek): indirilebilir yedek yok, zamana geri dönüş (PITR) yok; dokümanın önerisi düzenli `supabase db dump` ile dış yedek. 7 gün düşük aktivitede proje durdurulur (önce e-posta gelir), 90 gün içinde geri açılabilir.
- Supabase Auth kullanılmıyor (0 kullanıcı). Yeni kayıt (signup) ayarı SQL'den okunamıyor: doğrulanmadı. `authenticated` rolünün hiçbir yetkisi olmadığı için açık olsa bile veri açılmaz.
- Depolama (Storage) kovası, Edge Function, Vault sırrı ve branch yok. Realtime yayınında `svc_` tablosu yok. `pg_graphql` kurulu değil.

## Komutlar
```bash
bash supabase/tests/yerel-kurulum.sh   # boş PG 16'da Supabase taklidi + 0000→son migration + db-*.sql testleri (~2 sn, root)
md5sum supabase/migrations/*.sql
```
Yerel kurulum canlıya dokunmaz ve ücretsizdir. İkinci bir Supabase projesine gerek kalmadan "migration'lar sıfırdan kurulabiliyor mu" sorusunu ölçer. Sınırı: PostgREST ve gateway yok; sürüm farkı var (16 / canlı 17).
Canlıdaki karşılığı: `select name, md5(array_to_string(statements,'')) from supabase_migrations.schema_migrations order by version;`

Erişim testi: `supabase/tests/db-erisim.sql` dosyasını SQL Editor'de ya da MCP `execute_sql` ile çalıştır. Beklenen sonuç `BEE_TEST_SONUC kalan=0` hatasıdır; hata kasıtlıdır, test verisini geri alır. Son koşum (2026-11-07): 38/38, sayaçlar yerinde kaldı.

Denetim (her migration'dan sonra): MCP `get_advisors` güvenlik + performans. Beklenen kalıcı bulgular: `rls_enabled_no_policy` (INFO, kasıtlı) ve `anon_security_definer_function_executable` (WARN, kasıtlı; her fonksiyon anahtar ister). Bunların dışında çıkan her bulgu incelenir.
