---
name: kod-analizi
description: SVC Elektrik (BEE) kod tabanında sistematik analiz. Bir hata ya da tutarsızlık görüldüğünde, yeni özellik yazılmadan önce, mevcut kod iyileştirilirken, modüller arası bağımlılık ya da regresyon riski incelenirken kullan. Belirti → Kanıt → Ishikawa → 5 Neden → RCA → FMEA → Düzeltme → Doğrulama → Öğrenim. Kayıt araclar/teshis/ altına yazılır ve node araclar/teshis.mjs ile denetlenir.
---

# Kod analizi (BEE / svc-elektrik)

**İlke:** görünen problemi düzeltmek yetmez. Problemi oluşturan nedeni, buna izin veren kod yapısını ve tekrarını engelleyecek kontrolü bul. Ölçülmeyen neden **ADAY** kalır, kesin yazılmaz.
**Kapsam:** yalnız bu repo (`src/`, `supabase/`, `araclar/`) ve canlı `burak-elektrik` (ref `uwmbtaxxdcjumxbnigpy`, salt okuma). TEHAİ ve admin paneli kapsam dışı. Olmayan dosya, fonksiyon ya da tablo varmış gibi yazılmaz; önce `git ls-files` ile bakılır.

## Hangi kipte çalışıyorum?

| Kip | Ne zaman | Değişen adım |
|---|---|---|
| Arıza | Bir belirti var (hata, zaman aşımı, kırmızı test, beklenmeyen canlı değer) | 9 adımın hepsi |
| Yeni özellik | Kod yazılmadan önce | Belirti yerine "bu değişiklik neyi bozabilir". FMEA ilk yapılır, testler koddan önce yazılır |
| İyileştirme | Çalışan kod sadeleştirilecek | Ishikawa'da Mimari dalı ve "daha basit tasarım" sorusu zorunlu. Regresyon kanıtı: değişiklikten önce ve sonra aynı testler |
| Bağımlılık / regresyon | Bir modül değişti, etkisi soruluyor | Aile taraması (aşağıda) zorunlu. `SON=<numara>` ile ara durum ölçülür |

İlk adım her kipte aynı: `araclar/teshis/BELIRTILER.md`'ye bak (bu repoda görülmüş belirti → ilk ölçüm).

## Protokol (sıra bozulmaz)

1. **Belirti:** kullanıcı ne görüyor? Ham metin, yorum yok.
2. **Kanıt:** gerçek kod ne yapıyor? `dosya:satır` ve **çalıştırılmış** ölçüm (komut + çıktı). Kaynak okumak kanıt değildir, davranış ölçülür.
3. **Ishikawa:** alternatif nedenler 6 dalda: Arayüz, Veri, İş mantığı, Entegrasyon, Mimari, Test. En az 4 dal doldurulur.
4. **5 Neden:** neden-sonuç zinciri. Her halkanın bir `test:` ifadesi olur, yani o halkayı çürütebilecek ölçüm.
5. **RCA:** her neden ADAY / DOĞRULANDI / ELENDİ. ADAY dışındaki her neden ölçümlüdür.
6. **FMEA:** aynı hata başka nerede, hangi şiddetle çıkar? Ölçek aşağıda.
7. **Düzeltme:** en düşük riskli kalıcı çözüm ve etki alanı (hangi fonksiyonlar, hangi çağıranlar).
8. **Doğrulama:** çözümü kanıtlayan test. Çözüm geri alındığında test kırmızıya dönmeli (bozma testi).
9. **Öğrenim:** tekrarı engelleyen kontrol. Kural metni değil **mekanizma** olmalı: test, `dogrula.sh` kontrolü, araç.

Kayıt biçimi tek kaynaktır: `araclar/teshis/_SABLON.md`. Kayıt `araclar/teshis/T-NNN-ad.md` olarak yazılır, `node araclar/teshis.mjs` geçmeden "bitti" denmez.

## Ishikawa dallarında bu repoya özgü yoklamalar

| Dal | Bakılacak yer | Örnek komut |
|---|---|---|
| Arayüz | `src/assets/js/`, ekranlar, hata mesajı eşlemesi | `grep -n "DURUM_ETIKET\|apiFetch" src/assets/js/*.js` |
| Veri | Kısıtlar (`check`, `not null`, `unique`), sayaçlar, canlı satırlar | `grep -n "check (" supabase/migrations/*.sql`; canlıda salt okuma `execute_sql` |
| İş mantığı | `svc_*` fonksiyon gövdeleri, dönüşümler (`::uuid`, `::numeric`), `coalesce`/`nullif` | `grep -nE "'\)::|->>'[a-z_]+'\)?::" supabase/migrations/*.sql` |
| Entegrasyon | `src/api/*.js` ile DB adları ve imzaları; Supabase MCP; Vercel ortamı | `grep -noE "svc_[a-z_]+" src/api/*.js` ile canlı `pg_proc`/tablo listesi karşılaştırması |
| Mimari | Rol sınırı (Vercel'de service_role yok), aynı bilginin iki alanda tutulması, migration ara durumları | `SON=0005 bash supabase/tests/yerel-kurulum.sh` |
| Test | `supabase/tests/db-*.sql` kapsamı, bozma testi | `grep -c "<fonksiyon>" supabase/tests/*.sql`; `bash araclar/dogrula.sh` |

**Aile taraması** ("aynı yanlış mantık kaç yerde?"): bulunan hatanın **desenini** yaz, bütün repoda ara, her eşleşmeyi ADAY / DOĞRULANDI / ELENDİ diye işaretle. Bilinen desenler:
- kontrol et, sonra ekle (kilitsiz tekillik): `grep -n "istemci_id" supabase/migrations/*.sql`
- isteğe bağlı JSON alanının korumasız dönüşümü: `grep -nE "\(p->>'[a-z_]+'\)::" supabase/migrations/*.sql`
- durum sözlüğü kayması (DB `check` ↔ JS sabitleri): `grep -nE "check \(durum|check \(asama|DURUM" supabase/migrations/*.sql src/**/*.js`
- var olmayan tabloya referans: `src/` içindeki `svc_` adları ↔ canlı tablo listesi
- karar metni ↔ kod kayması: `*/CLAUDE.md` "Kararlar" satırları ↔ son migration

## FMEA ölçeği (BEE'ye bağlı)

| Puan | Ş: şiddet | O: olasılık | T: tespit edilemezlik |
|---|---|---|---|
| 5 | Yetkisiz erişim, veri kaybı, para yanlış kaydı | Her normal kullanımda | Sessiz: hata yok, veri yanlış |
| 4 | İş kaydı oluşmuyor ya da yanlış durumda görünüyor | Haftalık saha akışında | Yalnız sonradan (toplam, rapor) görünür |
| 3 | İşlem hata veriyor, veri bozulmuyor, tekrar denenebilir | Belirli bir girdiyle (ör. virgüllü tutar) | Genel hata mesajı, nedeni belirsiz |
| 2 | Görünüm ya da metin hatası | Eşzamanlılık, nadir sıra | Açık hata kodu |
| 1 | Kozmetik | Yalnız kötü niyetli ya da kurgusal | `dogrula.sh` ya da test yakalar |

RPN = Ş × O × T. **Önce:** Ş = 5 olan her satır, sonra RPN ≥ 40 olanlar.

## Eleştirel sorular (her kayıtta cevaplanır)

1. Bu hata neden daha önce fark edilmedi? Hangi varsayım ölçülmeden kabul edildi?
2. Aynı yanlış mantık kaç farklı fonksiyonda var (aile taraması sonucu)?
3. Düzeltme başka bir işlemi bozabilir mi (çağıranlar, ara durum)?
4. Kodun gereksiz karmaşıklığı bu hatayı kolaylaştırıyor mu?
5. Tekil bir hata mı, yoksa mimari bir eksikliğin belirtisi mi?
6. Bugün çalışıyor görünen hangi işlem aynı nedenle ileride bozulabilir?
7. Daha basit bir tasarım aynı işi daha güvenilir yapabilir mi?

## Sınırlar

- **Rol:** `knowledge/` ve `docs/`'a yazılmaz. Migration Burak onaysız uygulanmaz. `.claude/hooks/koruma.py` ve `.claude/settings.json` yalnız PR ve Burak onayıyla değişir. Bulgu `src/` ya da `supabase/` düzeltmesi gerektiriyorsa önce etki alanı yazılır.
- **Canlı:** yalnız salt okuma. Test verisi geri alınır (`BEE_TEST_SONUC` kalıbı, sayaçlar `setval` ile yerine). Yıkıcı SQL'in onay sorusu bu oturumdan cevaplanamaz: önce `node araclar/mcp-soru-tahmini.mjs`.
- **Gizlilik:** kayda anahtar, token, müşteri adı ya da telefonu yazılmaz. Örnek veri uydurmadır ve öyle işaretlenir.
- **Güven etiketi:** her iddia Yüksek / Orta / Doğrulanmadı taşır. Test edilemeyen hipotez "Doğrulanmadı" diye açıkça bırakılır.
- **Çakışma:** bu skill teşhis katmanıdır; hangi işin yapılacağı, kabul kriteri ve "bitti" kararı `AKTIF.md`'dedir. Bu skill yöntemi tanımlar. Kayıt biçimi `_SABLON.md`'de, görülmüş belirtiler `BELIRTILER.md`'de, denetim `teshis.mjs`'tedir. Aynı kural ikinci yere kopyalanmaz.

## Rapor (her vaka sonunda, sohbete)

| Analiz | Çıktı |
|---|---|
| Görünen problem | … |
| Kod kanıtı | `dosya:satır` ve ölçülen davranış |
| Ishikawa | olası teknik nedenler (dal başına bir satır) |
| 5 Neden | doğrulanmış zincir |
| RCA | gerçek kök neden ve güveni |
| FMEA | en yüksek iki risk (Ş/O/T/RPN) |
| Çözüm | önerilen kod ya da mimari değişiklik |
| Test | doğrulama sonucu (komut + çıktı) |
| Önleme | eklenen kalıcı kontrol |
