# T-001 · Supabase `apply_migration` onay sorusunda zaman aşımı
Tarih: 2026-11-07 · Kip: Arıza · Durum: AÇIK

## Belirti
`apply_migration` 6 kez şu hatayla döndü: "timed out after 230s. The server asked the user a question, and no answer came before the time limit." Eski 0004 için 5 kez (2026-11-06/07), DROP'ları ayrılmış 0005 için 1 kez (2026-11-07).

## Kanıt
- DROP'ları ayrılmış 0004 ilk denemede `{"success":true}` döndü. Canlı MD5 `964f018d…` = dosya.
- Gövdedeki DELETE kaldırılan 0005 07:16 UTC'de sorusuz uygulandı, MD5 `525f045a…` = dosya. Bu, tahmin aracının 7. doğru tahmini.
- `node araclar/mcp-soru-tahmini.mjs`: 0000–0002 ve 0004 sorusuz. Eski 0004, eski 0005 ve DELETE'li 0005 "SORU ÇIKAR".
- supabase/mcp `destructive-sql.ts`: ifadeler `;` ile bölünüyor ve "Dollar … bodies still expose their semicolons", yani fonksiyon gövdesi de taranıyor.

## Ishikawa
- Arayüz: soru Burak'ın ekranına hiç gelmedi. Bulut konteynerinde soruyu gösterecek bir yer yok.
- Veri: SQL içeriği. Migration'daki DROP ifadeleri ve fonksiyon gövdesindeki çalışma zamanı DELETE'i. Bu DELETE uygulama anında hiçbir şey silmez, ama soruyu tetikler.
- İş mantığı: oturum temizliği (`delete from svc_oturumlar …`) giriş fonksiyonunun içindeydi.
- Entegrasyon: Supabase MCP 0.13.0 (2026-09-17) yıkıcı SQL için onay soruyor. İstemci uzak oturumda bu soruyu gösteremiyor.
- Mimari: iki ayrı kapı var, Burak onayı (kök CLAUDE.md kural 4) ve MCP onayı. İkincisini kimin, nereden cevaplayacağı tanımlı değildi.
- Test: uygulamadan önce "soru çıkar mı" ölçen bir araç yoktu. Hipotez 6. denemeye kadar sınanmadı.

## 5 Neden
1. 0005 neden uygulanmadı? Araç 230 sn'de zaman aşımına uğradı. test: canlıda `svc_oturumlar` yok, 0005 fonksiyonu 0 (ölçüldü; yarım kalan bir şey yok).
2. Neden zaman aşımı? Sunucu onay sorusu sordu, cevap gelmedi. test: hata metni.
3. Neden cevap gelmedi? Soru Burak'ın telefonunda değil, konteynerde çıkıyor (N1). test: Burak hazırken bile 5/5 zaman aşımı oldu; PR 53018.
4. Neden soru çıktı? 0005'te `svc_s_giris_tamamla` gövdesinde ifade başında `delete from svc_oturumlar …` vardı (N3). test: `node araclar/mcp-soru-tahmini.mjs` 0005 için "SORU ÇIKAR" dedi; satır kaldırılınca "sorusuz" dedi ve uygulama sorusuz geçti.
5. Neden bunu uygulamadan önce bilmedim? "Yalnız DROP tetikler" varsayımını ölçmeden kabul ettim; uygulama öncesi tahmin aracı yoktu. test: önceki turun planında ölçüm yoktu, araç bu turda yazıldı.

## RCA
| # | Neden | Durum | Güven | Ölçüm |
|---|---|---|---|---|
| N1 | Soru Burak'ın ekranına ulaşmıyor: oturumun koştuğu bulut konteynerinde çıkıyor | DOĞRULANDI | Orta | supabase/supabase PR 53018: soru istemci oturumunun koştuğu yerde çıkar, uzaktan bakana "takılmış" görünür. Burak "onaylayacağım" dediği 0004 turunda da 5/5 zaman aşımı oldu |
| N2 | Soru yalnız DROP içeren SQL'de çıkar | ELENDİ | Yüksek | DROP'suz 0005 soruda kaldı. `destructive-sql.ts` DELETE'i, TRUNCATE'i ve WHERE'siz UPDATE'i de sayıyor |
| N3 | Soru, bir ifade DROP/DELETE/TRUNCATE ile başladığında ya da WHERE'siz UPDATE olduğunda çıkar; fonksiyon gövdesi de taranır | DOĞRULANDI | Yüksek | `destructive-sql.ts` + `node araclar/mcp-soru-tahmini.mjs` 7 gözlemin 7'sini doğru tahmin etti |
| N4 | Büyük dosyada pencere gelmiyor (boyut) | ELENDİ | Yüksek | 19,7 KB 0004 sorusuz geçti, 11 KB 0005 kaldı |
| N5 | MCP ya da ağ geçici hatası | ELENDİ | Yüksek | Hata metni sunucunun soru sorduğunu söylüyor; aynı dakikada `execute_sql` okuma çağrıları çalıştı |
| N6 | 0003 sorulu olmasına rağmen ikinci denemede geçti: o sefer soru nasıl cevaplandı | ADAY | Doğrulanmadı | — |

## FMEA
| # | Olası hata | Ş | O | T | RPN | Önlem |
|---|---|---|---|---|---|---|
| F1 | 0005'ten önce kurulum (`svc_kurulum`) yapılır: 0003'ün parolasız giriş kapısı anahtar kurulunca çalışır hâle gelir | 5 | 2 | 4 | 40 | KAPANDI: 0005 canlıda, `svc_s_giris_basarili` oturum istiyor (07:17 UTC ölçüldü) |
| F2 | Elle SQL Editor uygulaması `schema_migrations`'a düşmez; "yazıldı = uygulandı" yanılgısı (TEHAİ 044–046 vakası) | 4 | 3 | 3 | 36 | Elle uygulamadan sonra eserler ölçülür (sütun, fonksiyon, yetki) |
| F5 | Migration bölününce canlı ara durumda kalır (0005'te `svc_talep_olustur` iki sürüm, eski durum seti) | 3 | 3 | 4 | 36 | `SON=<son> bash supabase/tests/yerel-kurulum.sh` ara durumu ölçer; 0006 API yazılmadan uygulanır |
| F3 | Sorulu dosya yine MCP ile denenir, 230 sn ve bir tur kaybolur | 2 | 4 | 2 | 16 | `node araclar/mcp-soru-tahmini.mjs` uygulamadan önce (`supabase/CLAUDE.md` Tuzaklar) |
| F4 | Tahmin aracı sunucudan sapar (sunucu kodu değişir), "sorusuz" der ama soru çıkar | 2 | 2 | 3 | 12 | Zaman aşımında N3 yeniden ölçülür. İlk sürüm "UPDATE without WHERE"ü atlıyordu; 2026-11-07'de eklendi |

## Düzeltme
- 0004 ve 0005'teki DROP'lar küçük 0006'ya ayrıldı.
- 0005'teki çalışma zamanı DELETE'i kaldırıldı (Burak onayı). Oturumlar artık giriş geçmişi olarak kalıyor. Etki alanı: yalnız `svc_s_giris_tamamla`; buna bağlı test yoktu.

## Doğrulama
- Canlı (salt okuma): `schema_migrations` 0004 `964f018d…` ve 0005 `525f045a…` = dosya. `svc_sahip_dogrula` oturum istiyor. Güvenlik danışmanında yalnız beklenen 2 bulgu var.
- Yerel: `bash araclar/dogrula.sh` 7/7. `SON=0005` ile 0006'ya bağlı 2 KALDI (beklenen).

## Öğrenim
- `araclar/mcp-soru-tahmini.mjs` ve `supabase/CLAUDE.md` Tuzaklar kuralı: "SORU ÇIKAR" diyen dosya MCP ile denenmez.
- `SON=` ara durum ölçümü (`supabase/tests/yerel-kurulum.sh`).
- Bu teşhis düzeni ve `araclar/teshis.mjs`: ölçümsüz DOĞRULANDI/ELENDİ yazılamaz (`dogrula.sh` 6. kontrol).
- Burak kararı bekliyor: 0006'nın (gerçek DROP) canlıya hangi yoldan gideceği.

## Eleştirel sorular
1. Neden daha önce fark edilmedi? "MCP onay sorusu yalnız DROP içeren SQL'de çıkar" varsayımı ölçülmeden kabul edildi ve 0005 ile çöktü. Hata mesajı "soru sordu" diyordu, ama soru metnini görmeden tahmin ettim.
2. Aynı mantık kaç yerde? Etkilenen dosyalar 0003, eski 0004, 0005 ve 0006 ile `db-oturum.sql` (WHERE'siz UPDATE, `execute_sql` ile koşulsaydı). Tümü tahmin aracıyla tarandı.
3. Düzeltme başka işlemi bozar mı? Bölme bir ara durum üretti (F5). `svc_talep_olustur` 13 parametreyle "not unique" veriyor. Bunu çağıran bir API yok, 0006 ile kapanıyor.
4. Karmaşıklık katkısı? Migration'ın içinde çalışma zamanı temizliği vardı. Temizlik gerekli olmadığı halde soruyu tetikledi.
5. Tekil mi, mimari mi? Mimari. Uzak oturumda cevaplanamayan bir onay kapısı var. Her yıkıcı migration bundan etkilenir.
6. İleride ne bozulur? Fonksiyon gövdesine `delete`/`truncate` ya da WHERE'siz `update` yazan her gelecek migration. Ayrıca sunucunun detektörü değişirse tahmin aracı sapar (F4).
7. Daha basit tasarım? Evet. Silmeyen oturum tablosu (giriş geçmişi) hem soruyu kaldırdı hem bir denetim izi bıraktı.
