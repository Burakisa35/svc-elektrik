# Brief 008 — Bütünleşik test düzeni (en az test, en çok sinyal)

Yazan: sohbet Claude (mühendislik). Alıcı: Claude Code. Karar: Burak.
Ön koşul: brief 006 madde 1–2 kapanmış. Kapsam: DB, koruma hook'u, ekran, canlı, el testi **tek düzende**.
Burak'ın kısıtı: yığın test ve rapor istemiyor; denenebilir, çalışan çıktı istiyor. Bu brief test **eklemek** için değil, her testi bir riske bağlayıp gerisini eklememek için.

## 1. Neye dayanıyor
Bu inceleme dalın `7efd02d` hâlindeki dosyalara dayanır: `supabase/tests/db-erisim.sql` (273 satır), `.claude/hooks/koruma-test.sh` (24 vaka). "Test koşuyorum" dediği yeni çalışmayı **görmedim**; 0004 testleri varsa aşağıdaki maddeler onlara da uygulanır, çakışanı Code atlar.

## 2. Mevcut durumun dürüst değerlendirmesi

| Varlık | İyi olan | Boşluk | Güven |
|---|---|---|---|
| `db-erisim.sql` | Rol bazlı (`set local role anon`), sonda kasıtlı `raise` ile geri alma, "iz kalmaz", her satır GEÇTİ/KALDI, 38/38 | (a) **Tek canlı veritabanında** koşuyor; sıra sayaçları geri alınmıyor (talep no T26-0010'dan başladı). (b) Testin kırılabildiği kanıtlanmamış (bozma testi yok). (c) Şema genelinde "RLS her tabloda açık" tek sorguyla doğrulanmıyor, tablo listesi elle yazılı: yeni tablo listeye girmezse sessizce denetsiz kalır. (d) Migration'ların **sıfırdan** kurulabildiği hiç denenmedi | Yüksek (dosya okundu) |
| `koruma-test.sh` | JSON girdiyi taklit ediyor, 16 engel + 8 izin, bozma testi yapılmış | Bilinen atlatmalar (`curl -o`, `wget -O`, glob, dize birleştirme) ve yanlış pozitifler **testte yok**, yani bilinen açıklar görünmüyor. Hook'un gerçek oturumda **yüklü olduğu** doğrulanmadı (canlı deneme engellenmedi) | Yüksek (dosya + Code raporu) |
| Ekran testi | Henüz yok | `ekran-sablonu.md` B satırlarının hiçbirinin otomatik karşılığı yok | Yüksek |
| Canlı duman testi | Henüz yok | Deploy sonrası "açıldı mı" bakılmıyor | Yüksek |

## 3. Dışarıdan öğrenilenler (kaynaklı)

| # | Bulgu | Etkisi | Güven |
|---|---|---|---|
| D1 | Supabase'in RLS test rehberi: pgTAP, `begin … rollback`, `set local role` + `request.jwt.claim.sub`, **kuralı yaz → kural başına test**, ve **"politikayı bozup testin kırıldığını gör"**: geçici `using (true)` politikası ekle, test kırılmalı, sonra kaldır. Politikayı silmek kanıt değildir, çünkü politikasız her okuma reddedilir ve ret testleri geçer | Mevcut `db-erisim.sql`'e **bozma adımı** eklenir; RLS için mutasyon testi budur | Yüksek (resmî rehber) |
| D2 | Şema genelinde RLS kontrolü tek çağrı (`tests.rls_enabled('public')`, basejump yardımcıları) | Elle tablo listesi yerine sistem kataloğundan otomatik liste | Yüksek (resmî rehber), yardımcı paket kullanımı Orta |
| D3 | Engellenen `update`/`delete` **hata vermez**, 0 satır etkiler; `returning` ile boşluk kontrolü gerekir | `db-erisim.sql` içindeki yazma-ret testlerinin hata beklemediği kontrol edilsin | Yüksek (rehber + Basejump yazısı) |
| D4 | `supabase test db` yerel yığın ister; bulutta Code'un çalıştığı ortamda Docker olup olmadığı ve `--linked` ile uzak DB'de çalışıp çalışmadığı | **Doğrulanmadı**. Doğrulanana kadar mevcut `DO` bloğu biçimi korunur, pgTAP'e geçiş zorunlu değil | Doğrulanmadı |
| D5 | Playwright çevrimdışı emülasyon yerleşik; **ağ yavaşlatma yerleşik değil** (CDP, yalnız Chromium ya da `page.route`) | PF-1 (yavaş ağ) Chromium-CDP ile ölçülür, "yaklaşık" etiketli | Yüksek (belge) / Orta (blog doğrulaması) |
| D6 | axe-core: etiketsiz girdi, kontrast, ARIA, hedef boyutu yakalar; WCAG ölçütlerinin yaklaşık üçte birini kapsar, kalan el ister | Otomatik tarama EA-1/EA-3/UI-1'in bir kısmını kapatır, **EA-4/EA-5 ve odak sırası el kalır** | Orta (tek CI rehberi blogu; rakamlar doğrulanmadı) |
| D7 | Test stratejisi yüzde/şekil değil **risk dağıtımıdır**: sonuç, hata nerede, en ucuz güvenilir gözlem, bakım maliyeti. Küçük ekipte en yüksek kaldıraç: kritik yol uçtan uca (az sayıda), yetki testleri, para kodu, **her canlı hata için bir regresyon testi**, deploy başı duman testi; kapsama yüzdesi hedef değil | Bütçeli, riske bağlı düzen (bölüm 4) | Orta (Fowler/web.dev tartışması Yüksek; EvolRed ve MetronForge blogları Orta) |
| D8 | Playwright `devices['iPhone 11']` varsayılan tarayıcı olarak **WebKit** ister; bu ortamda yalnız Chromium var | Chromium + elle `viewport`/`isMobile`/`hasTouch` kullan; sonucu "iPhone kılığında Android motoru" diye etiketle (AGENTS.md K3 ile aynı dürüstlük) | Orta (cihaz tanımı bilgisi; bu ortamda denenmedi) |

## 4. Önerilen düzen: 6 katman, bütçeli

Her satır `ekran-sablonu.md` satırına ya da `docs/decisions/` kuralına bağlıdır. Bağlanamayan test yazılmaz (KBMY).

| Katman | Ne | Neyi kapatır | Nasıl koşar | Bütçe |
|---|---|---|---|---|
| **T0 Statik** | Tek betik: `innerHTML` yasağı (GG-2), sabit renk/boşluk (ES-1/ES-4), sır taraması (GG-3), her migration'ın ilk satırı kimlik kapısı, `lang="tr"`, `user-scalable=no` yok, `100vh` yasak | 10+ E satırı, saniyeler | `node` betiği | ≤ 5 sn |
| **T1 Veritabanı** | Mevcut `db-erisim.sql` korunur, üç ekleme: (1) **şema geneli RLS** katalogdan otomatik; (2) **bozma adımı** (D1); (3) her 0004+ migration'ın yeni davranışı için 1–3 vaka (istemci_id çift gönderme tek kayıt, tek zorunlu alanla iş aç, `kacirildi` durumu geçişi). Her canlı DB hatası için **bir** regresyon vakası | GG-1, UX-2, UX-3, yetki | SQL Editor / MCP `execute_sql`, sonuç tek satır | Mevcut + ≤ 15 vaka |
| **T1b Sıfırdan kurulum** | Boş bir (ikinci, ücretsiz) projede 0000→son migration'ı sırayla uygula, ardından T1'i koş. Migration'ların **tam ve sıralı** olduğunu kanıtlar | tehai'de 044/045/046 olayı: "uygulandı" iddiası yanlıştı. Burada kanıt ölçümdür | Elle/MCP, **Burak onayı gerekir** (yeni proje, migration uygulaması) | Her büyük migration sonrası bir kez |
| **T2 Saf mantık** | Küçük, hata maliyeti yüksek saf fonksiyonlar: kontrast hesabı (EA-1, token çiftleri), telefon normalizasyonu, importer, bilgi tabanı linter'ı. **Elle bozma** (mutasyon): her dosyada 3–5 anlamlı bozma, test kırılmalı. Stryker zorunlu değil | EA-1/EA-2, TR-2, veri bütünlüğü | `node --test` | ≤ 10 sn; skor hedefi yok |
| **T3 Ekran (Chromium)** | Her ekran için tek betik: 375×667 ve 414, 6 durumu zorla (UX-5), ağı kapat (UX-4, PF-2), yatay kaydırma (UI-6), hedef boyutu (UI-1), hesaplanan yazı boyutu (UI-3), `elementFromPoint` ile "parmak oraya basınca düğme mi" (AGENTS.md), axe taraması, her durum için ekran görüntüsü | UI-1/3/6, UX-4/5, EA-1/3, PF-2 (kısmen) | Playwright + Chromium | Ekran başı ≤ 30 sn |
| **T4 Canlı duman** | Deploy sonrası 5–8 istek: sayfa 200; anon doğrudan tablo reddi; sahip fonksiyonu anon'a kapalı; müşteri linki başlıkları (`noindex`, `no-referrer`, `no-store`) ve geçersiz link tek tip cevap; ham hata sızmıyor | GG-1, GG-4, "açıldı mı" | `curl`/`node` | ≤ 10 sn |
| **T5 El (Burak)** | Tek kartta 6 madde, ≤ 5 dk: iş aç kronometre ×3 (UX-1), uçak modu (PF-2), Safari düzeni/çentik (UI-5), güneşte okunabilirlik, yazım/Türkçe karakter (TR-1), odak/VoiceOver kısa deneme (EA-4) | Otomatiğin göremediği | iPhone 11 | ≤ 5 dk |
| **T6 Koruma** | `koruma-test.sh`'ye **bilinen açık** vakaları ekle, beklenen "KAÇAR" etiketli (xfail), böylece açıklar görünür, ve sunucu tarafı yol denetimi Actions'ta (`setup/foundation` main'e birleşince) | Hook'un söz verdiğini ve vermediğini ayırır | `bash` | ≤ 5 sn |

**Toplam hedef:** otomatik katmanlar (T0, T2, T3, T4, T6) tek komutla ≤ 2 dk; DB (T1) ayrı. Rapor tek satır/katman: `T0 GEÇTİ · T1 GEÇTİ 52/52 · T3 KALDI UI-1 (panel, 38×40)`. Ayrı rapor dosyası yok; ayrıntı yalnızca KALAN için.

## 5. Bağımsızlık ("üreten denetlemez")
Code hem kodu hem testi yazıyor; tek başına yetmez. Üç önlem:
1. **Kural kaynağı Code değil:** testlerin beklentisi `ekran-sablonu.md`, `docs/decisions/` ve bilgi tabanı şemasından gelir (benim alanım). Code beklentiyi değiştirirse ayrı brief/karar ister.
2. **Test kırılabildiğini kanıtlar:** her yeni test için bir bozma (D1 biçimi), çıktıda "bozdum → KALDI → geri aldım → GEÇTİ".
3. **Örnekleme:** her faz sonunda ben 3–5 testi rastgele seçip bozarak denetlerim (`docs/quality/findings/`).

## 6. Sıra (Modül 1 ilk dilimine göre)
1. T0 + T6'nın xfail eklemesi (en ucuz, en çok E satırı).
2. T1 eklemeleri (şema geneli RLS, bozma adımı, 0004 vakaları). Burak 0004'ü uyguluyor; vakalar o hâle göre.
3. T3'ü `giris` ve `panel` için; brief 007'deki 6 prototip için aynı betik yeterli (ekran listesi parametre).
4. T4 ilk deploy ile birlikte.
5. T1b yalnız Burak ikinci proje ve onayı verirse.
6. T2 yalnız o fonksiyonlar yazıldığında (importer, kontrast hesabı).

## 7. Durdurma ölçütleri (yığılmayı önlemek için)
- Bir test üç ayda bir kez bile kırılmadı **ve** bağlı olduğu risk kapandıysa kaldırılır.
- Dalgalı (bazen geçen, bazen kalan) test: aynı gün düzeltilir ya da silinir; "tekrar çalıştır" yok.
- Süre bütçesi aşılırsa yeni test eklenmez, mevcut biri çıkarılır.
- Kapsama yüzdesi hedef konulmaz.

## 8. Açık kararlar (Burak)
- **İkinci ücretsiz Supabase projesi** (yalnız test için): Free planda 2 aktif proje hakkı var (resmî, Yüksek). T1b ve canlı veritabanının test sayaçlarıyla kirlenmemesi için öneri **evet**. Dezavantajı: bir parola/anahtar daha, bir uyarı daha. Karar sende.
- **pgTAP'e geçiş:** D4 doğrulanana kadar yok. Code ortamında `supabase test db` ve `--linked` denenip sonucu `supabase/CLAUDE.md`'ye yazılsın.
- **T5 kartı:** Burak her büyük teslimde 5 dk ayırır mı? Ayırmazsa UX-1, PF-2, UI-5 satırları "DOĞRULANMADI" kalır ve E olduğu için modül kapanmaz.

## 9. Kaynaklar
- Supabase, RLS testi (pgTAP): https://supabase.com/docs/guides/database/postgres/testing-row-level-security
- Supabase, pgTAP genişletilmiş: https://supabase.com/docs/guides/local-development/testing/pgtap-extended
- Basejump, Supabase test yardımcıları: https://github.com/usebasejump/supabase-test-helpers
- Basejump, pgTAP rehberi: https://usebasejump.com/blog/testing-on-supabase-with-pgtap
- Playwright, emülasyon: https://playwright.dev/docs/emulation
- Playwright, erişilebilirlik testi: https://playwright.dev/docs/accessibility-testing
- Ağ yavaşlatma sınırı: https://jignect.tech/blogs/playwright-network-throttling-offline-testing-a-complete-guide (Orta)
- web.dev, test stratejileri: https://web.dev/articles/ta-strategies
- Fowler, test şekilleri: https://martinfowler.com/articles/2021-test-shapes.html
- Risk dağıtımı olarak test stratejisi: https://metronforge.dev/posts/test-strategy-is-risk-allocation-not-a-shape/ (Orta)
- Küçük ekip için pratik test: https://evolred.com/blog/pragmatic-testing-small-teams (Orta)
- Playwright + axe CI rehberi: https://dev.to/veduis/playwright-axe-core-accessibility-testing-ci-guide-1k2b (Orta; sayısal iddialar kullanılmadı)
