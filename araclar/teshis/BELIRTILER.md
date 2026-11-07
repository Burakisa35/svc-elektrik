# Görülmüş belirtiler: ilk ölçüm

Bir belirti gördüğümde önce buraya bakarım. Satır, bu projedeki kendi kod işimde gerçekten yaşanmış bir vakadan gelir (2026-11-06/07). "İlk ölçüm", bir sonraki adımdan önce yapılacak tek komuttur. Yeni bir vaka çözüldüğünde satır eklenir. Vaka karmaşıksa `T-NNN` kaydı açılır (`_SABLON.md`).

| Belirti | İlk ölçüm | Önceki kök neden | Güven | Kayıt |
|---|---|---|---|---|
| `apply_migration` 230 sn zaman aşımı, "server asked the user a question" | `node araclar/mcp-soru-tahmini.mjs <dosya>` | İfade başında DROP/DELETE/TRUNCATE (fonksiyon gövdesi dahil). Soru konteynerde çıkıyor, Burak'a ulaşmıyor | Yüksek / Orta | T-001 |
| Araç eylemi reddedildi (izin sınıflandırıcısı, örn. "Self-Modification") | `git diff --stat -- <yol>`: ne değişti, ne değişmedi. Sonra Burak'a sor | Tasarım gereği: Code kendi korumasını tek başına değiştiremez. Başka yoldan deneme yok (Burak kural 10) | Yüksek | — |
| plpgsql "column reference … is ambiguous" | `grep -n "<ad>" <dosya>`: değişken mi, sütun mu? | Değişken adı sütun adıyla aynı (`anahtar`) | Yüksek | — |
| Toplu `sed` sonrası beklenmeyen hata | `git diff <dosya>`: yalnız hedeflenen satırlar mı değişti? | `sed` değişkenle birlikte aynı adlı sütunları da değiştirdi | Yüksek | — |
| `initdb` / postgres "permission denied" | `namei -l <yol>`: hangi üst dizin postgres kullanıcısına kapalı | Scratchpad üst dizinlerinde `o+x` yoktu. Çözüm: `mktemp -d /tmp/bee-pg.XXXXXX` | Yüksek | — |
| Test geri alındı ama ilk kayıt numarası atlıyor | Testten önce/sonra `select sequencename, last_value from pg_sequences` | `nextval` transaction'la geri alınmaz. Test sayaçları kaydedip `setval` ile geri yükler | Yüksek | — |
| Kendi raporumda bir sayı ("13/13", "N kontrol") | Yazmadan önce say: `grep -c` ya da çıktının son satırı | Sayı ölçülmeden yazılmıştı (gerçek 15) | Yüksek | — |
| Koruma hook'u canlı oturumda engellemedi | `pwd` ve oturumun açıldığı kök: hook repo kökünde mi yükleniyor? | **ADAY:** oturum `/home/user`'da açılıyor, repo kökünde değil | Orta | — |
| Migration bölündü/kısmen uygulandı; testler canlıda farklı davranabilir | `SON=<son uygulanan> bash supabase/tests/yerel-kurulum.sh` | Bölme ara durum üretti: 0005'te `svc_talep_olustur` "not unique", eski durum seti | Yüksek | T-001 F5 |
| Burak "SQL Editor'den yapıştırdım" dedi, eserler canlıda yok | Canlıda `postgres_logs` içinde `statement:` satırı: `log_statement=ddl` olduğu için DDL hata verse bile önce kayda düşer. Kontrol örneği: 0004/0005 satırları | 2026-11-07 `0006`: bu projede ve TEHAİ'de iz yok, yani ifade veritabanına hiç ulaşmadı. Gölge proje ölçülemedi (izin yok) | Orta | — |
| Canlı ile dosya farklı mı? | `select name, md5(array_to_string(statements,'')) from supabase_migrations.schema_migrations` ve `md5sum` | — (kontrol adımı) | Yüksek | — |
