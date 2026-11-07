# T-001 · Supabase `apply_migration` onay sorusunda zaman aşımı
Tarih: 2026-11-07 · Durum: AÇIK

## Belirti
`apply_migration` 6 kez şu hatayla döndü: "timed out after 230s. The server asked the user a question, and no answer came before the time limit." Eski 0004 için 5 kez (2026-11-06/07), DROP'ları ayrılmış 0005 için 1 kez (2026-11-07). DROP'ları ayrılmış 0004 aynı gün ilk denemede `{"success":true}` döndü. Gövdedeki DELETE kaldırılan 0005 07:16 UTC'de sorusuz uygulandı (tahmin aracının 7. doğru tahmini).

## Olası nedenler
| # | Neden | Durum | Güven | Ölçüm |
|---|---|---|---|---|
| N1 | Soru Burak'ın ekranına ulaşmıyor: oturumun koştuğu bulut konteynerinde çıkıyor | DOĞRULANDI | Orta | supabase/supabase PR 53018: soru istemci oturumunun koştuğu yerde çıkar, uzaktan bakana "takılmış" görünür. Burak "onaylayacağım" dediği 0004 turunda da 5/5 zaman aşımı oldu |
| N2 | Soru yalnız DROP içeren SQL'de çıkar | ELENDİ | Yüksek | DROP'suz 0005 soruda kaldı. supabase/mcp `destructive-sql.ts` DELETE ve TRUNCATE'i de sayıyor |
| N3 | Soru, bir ifade DROP/DELETE/TRUNCATE ile başladığında çıkar; fonksiyon gövdesi de taranır | DOĞRULANDI | Yüksek | `destructive-sql.ts` ("Dollar … bodies still expose their semicolons") + `node araclar/mcp-soru-tahmini.mjs` 6 gözlemin 6'sını doğru tahmin etti (0000–0002 ve yeni 0004 sorusuz, eski 0004 ile 0005 sorulu) |
| N4 | Büyük dosyada pencere gelmiyor (boyut) | ELENDİ | Yüksek | 19,7 KB 0004 sorusuz geçti; 11 KB 0005 kaldı |
| N5 | MCP ya da ağ geçici hatası | ELENDİ | Yüksek | Hata metni sunucunun soru sorduğunu söylüyor; aynı dakikada `execute_sql` okuma çağrıları çalıştı |
| N6 | 0003 sorulu olmasına rağmen ikinci denemede geçti: o sefer soru nasıl cevaplandı | ADAY | Doğrulanmadı | — |

## 5 Neden
1. 0005 neden uygulanmadı? Araç 230 sn'de zaman aşımına uğradı. test: canlıda `svc_oturumlar` yok, 0005 fonksiyonu 0 (ölçüldü; yarım kalan bir şey yok).
2. Neden zaman aşımı? Sunucu onay sorusu sordu, cevap gelmedi. test: hata metni.
3. Neden cevap gelmedi? Soru Burak'ın telefonunda değil, konteynerde çıkıyor (N1). test: Burak hazırken bile 5/5 zaman aşımı; PR 53018.
4. Neden soru çıktı? 0005'te `svc_s_giris_tamamla` gövdesinde ifade başında `delete from svc_oturumlar …` var (N3). test: `node araclar/mcp-soru-tahmini.mjs` → 0005 "SORU ÇIKAR".
5. Neden bunu uygulamadan önce bilmedim? "Yalnız DROP tetikler" varsayımını ölçmeden kabul ettim; uygulama öncesi tahmin aracı yoktu. test: önceki turun planı "büyük iki dosya sorusuz uygulanabilmeli" diyordu, ölçüm yoktu.

## Ishikawa
- İnsan: Burak onaya hazırdı; soru ona gösterilmedi. Burak kaynaklı değil.
- Araç: Supabase MCP 0.13.0 (2026-09-17) yıkıcı SQL onayı; uzak oturumda soruyu gösterecek yer yok.
- Yöntem: iki ayrı kapı var: Burak onayı (kök CLAUDE.md kural 4) ve MCP onayı. İkincisini kimin, nereden cevaplayacağı tanımlı değildi.
- Girdi: migration'daki DROP ifadeleri ve fonksiyon gövdesindeki çalışma zamanı DELETE'i (uygulama anında hiçbir şey silmez ama tetikler).
- Ölçüm: uygulamadan önce "soru çıkar mı" ölçen araç yoktu; hipotez 6. denemeye kadar sınanmadı.
- Ortam: bulut konteyneri ve mobil uygulama; terminal Burak'ta değil.

## FMEA
| # | Olası hata | Ş | O | T | RPN | Önlem |
|---|---|---|---|---|---|---|
| F1 | 0005'ten önce kurulum (`svc_kurulum`) yapılır: 0003'ün parolasız giriş kapısı anahtar kurulunca çalışır hâle gelir | 5 | 2 | 4 | 40 | KAPANDI: 0005 canlıda, `svc_s_giris_basarili` oturum istiyor (07:17 UTC ölçüldü) |
| F2 | Elle SQL Editor uygulaması `schema_migrations`'a düşmez; "yazıldı = uygulandı" yanılgısı (TEHAİ 044–046 vakası) | 4 | 3 | 3 | 36 | Elle uygulamadan sonra eserler ölçülür (sütun, fonksiyon, yetki) |
| F3 | Sorulu dosya yine MCP ile denenir, 230 sn ve bir tur kaybolur | 2 | 4 | 2 | 16 | `node araclar/mcp-soru-tahmini.mjs` uygulamadan önce (`supabase/CLAUDE.md` Tuzaklar) |
| F4 | Tahmin aracı sunucudan sapar (sunucu kodu değişir), "sorusuz" der ama soru çıkar | 2 | 2 | 3 | 12 | Zaman aşımında N3 yeniden ölçülür, araç güncellenir. İlk sürüm "UPDATE without WHERE"ü atlıyordu; 2026-11-07'de eklendi |
| F5 | Migration bölününce canlı ara durumda kalır (0005'te `svc_talep_olustur` iki sürüm, eski durum seti) | 3 | 3 | 4 | 36 | `SON=<son> bash supabase/tests/yerel-kurulum.sh` ara durumu ölçer; 0006 API yazılmadan uygulanır |

## Doğrulama
- Canlı (salt okuma): `schema_migrations` son = `0004_modul1_saha`, MD5 `964f018d…` = dosya. `svc_oturumlar` yok, 0005 fonksiyonu 0. `svc_ayarlar` 0 satır. anon tablo yetkisi 0.
- Kaynak: supabase/mcp `database-operation-tools.ts`, `destructive-sql.ts`; Supabase MCP belgesi "Elicitations"; supabase/supabase PR 53018.
- Yerel: `node araclar/mcp-soru-tahmini.mjs` bölünmeden önceki ve sonraki 9 dosya sürümünde çalıştırıldı.

## Önleyici çözüm
- Yapıldı: `araclar/mcp-soru-tahmini.mjs` ve `supabase/CLAUDE.md` Tuzaklar kuralı ("SORU ÇIKAR" diyen dosya MCP ile denenmez).
- Yapıldı: bu teşhis protokolü ve `araclar/teshis.mjs` denetleyicisi (`dogrula.sh` 7. kontrol). Ölçümsüz DOĞRULANDI/ELENDİ yazılamaz.
- Yapıldı (Burak onayı): 0005'teki çalışma zamanı DELETE'i kaldırıldı (oturumlar giriş geçmişi), 0005 sorusuz uygulandı, MD5 `525f045a…` = dosya.
- Burak kararı bekliyor: 0006'nın (gerçek DROP) canlıya hangi yoldan gideceği.

## Çöken varsayım
"MCP onay sorusu yalnız DROP içeren SQL'de çıkar." 2026-11-07'de ölçülmeden kabul edildi, aynı gün 0005 ile çöktü.
