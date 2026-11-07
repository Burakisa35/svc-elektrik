# Brief 009 — Mimari keşif: tasarım fırsatları (teknoloji tarafsız; Java bir hipotez)

Kaynak: Burak'ın "SVC Elektrik — Java Tabanlı Yazılım Tasarım ve Mimari Keşif Briefi" metni, sohbet tarafında düzenlendi. Alıcı: Claude Code. Karar: Burak.
Ön koşul: brief 006 madde 1–2 kapanmış; **bu brief Modül 1 ilk diliminin (giriş + iş aç) önüne geçmez**, onunla paralel okunur, kod yazdırmaz.

## 0. Düzenleme notu (neyi, neden değiştirdim)

| # | Değişiklik | Neden | Güven |
|---|---|---|---|
| 1 | Başlıktan "Java Tabanlı" çıkarıldı; Java ayrı bir **hipotez** (bölüm 4) | Orijinalin 10. bölümü "Java'yı zorunlu kabul etme" diyor, başlığı ise Java'yı varsayıyordu: çelişki | Yüksek |
| 2 | **Sabit girdiler** eklendi (bölüm 2) | Orijinal "mevcut kodu incele" diyor ama repoda zaten yazılı kararlar var; Code'un sıfırdan keşfetmesi gereksiz maliyet | Yüksek |
| 3 | "Eleştirel denetçi" rolü **üretim ve karar** ayrımıyla düzeltildi | Üreten denetlemez (kök `CLAUDE.md`): Code alternatif üretir, denetimi sohbet tarafı ve Burak yapar | Yüksek |
| 4 | Yedi alan, **fırsat havuzu** olarak bırakıldı; her alan için "şimdi / sonra / hiç" kararı istendi | Burak tek kişi; YAGNI. Yedi alanın hepsi aynı anda tasarlanırsa Modül 1 geciker | Yüksek (mantık) |
| 5 | Üç vaka **mevcut kurallara bağlandı** (bölüm 5) | Vakalar zaten bilinen ilkelerle kesişiyor; yeni tasarım yerine çelişki/boşluk aranmalı | Yüksek |
| 6 | Çıktı **en çok 3 aday**, süre sınırı ve kabul ölçütü eklendi | Burak "keşif" dedi; sınırsız keşif brief kuralı gereği kapsam kaybettirir | Yüksek |
| 7 | Rapor teslim yolu yazıldı | Code `docs/**` yazamaz (hook); rapor Burak'a tek dosya olarak verilir | Yüksek (hook testi) |

## 1. Rol ve ilke
Code bu keşifte **yazılım mimarı ve sistem tasarımcısıdır**. Soru "ne eklenebilir" değil, **"hangi işletme problemi, hangi yazılım davranışını, hangi en küçük maliyetle gerektirir"**. Önceden dayatılmış sonuç yok; kanıtlanmamış hiçbir şey mevcut özellik gibi raporlanmaz.

## 2. Sabit girdiler (kod ve belge kaynaklı; sorgulanabilir ama sorgulamak karar kaydı ister)

| Konu | Durum | Kaynak | Güven |
|---|---|---|---|
| Yığın | Vanilla HTML/CSS/JS + Vercel serverless (Node ESM), `package.json` yok | `src/CLAUDE.md` | Yüksek |
| Veri | Supabase (Postgres); her veri işlemi `svc_*` DB fonksiyonu; Vercel'de service_role yok | `src/CLAUDE.md`, `supabase/CLAUDE.md` | Yüksek |
| İş kuralı yeri | **Bugün veritabanı fonksiyonlarında.** Hesap ve doğrulama oraya yazılmış | `supabase/migrations/` | Yüksek |
| Olay kaydı | `svc_olaylar` yalnız eklenir; iş ve talep silinmez | `supabase/CLAUDE.md` (0004) | Yüksek |
| Eksik veri | Girilmeyen alanın varsayılan değeri yok, boş kalır ("bilinmiyor") | `supabase/CLAUDE.md`, `ekran-sablonu.md` UX-8 | Yüksek |
| Kullanıcı | Tek kişi (Burak), iPhone 11, tek el, zayıf internet olabilir | kök `CLAUDE.md` | Yüksek |
| Modül 1 hedefi | "İş aç" ≤ 30 sn, tek zorunlu alan | `ekran-sablonu.md`, mevcut görev | Yüksek |
| Kaynaklar | `docs/ROADMAP.md`, `docs/VERI_MODELI.md` (Code yazdı) | dosyalar | Yüksek (var), güncelliği Doğrulanmadı |

## 3. Düşünme yöntemleri (orijinal liste korundu, kısaltıldı)
Domain-Driven Design · olay odaklı tasarım · durum makinesi · sözleşmeyle tasarım · sistem düşüncesi · ilk ilkeler · **karşıt düşünme** (öneri hangi koşulda yanlış sonuç verir?). Kural: yöntem, bir problemi aydınlatıyorsa kullanılır; süs olarak sıralanmaz.

## 4. Java sorusu (ayrı, bir hipotez)

**Hipotez H-Java:** "SVC Elektrik'in bir iş mantığı Java ile Node + Postgres fonksiyonlarından daha iyi çözülür."

| Soru | Mevcut bilgi | Güven |
|---|---|---|
| Vercel Java'yı resmî çalışma zamanı olarak destekliyor mu? | Resmî liste: Node.js, Bun, Python, Rust, Go, Ruby, Wasm, Edge, **Container**. **Java listede yok**; farklı dil için topluluk çalışma zamanı ya da Container | **Yüksek** (vercel.com/docs/functions/runtimes) |
| Container çalışma zamanı bu hesapta (plan) kullanılabilir mi, maliyeti ne? | Okunmadı | **Doğrulanmadı** |
| Java ayrı bir sunucuda çalışırsa ne eklenir? | İkinci dağıtım, ikinci sır yönetimi, soğuk açılış/uyku, güncelleme yükü; tek kişilik işletme için sürekli bakım | Orta (mühendislik yargısı) |
| Java'nın BEE'ye özgü kazancı ne olabilir? | Güçlü tür sistemi, olgun kütüphaneler. Ancak mevcut kurallar (hesap, doğrulama) SQL fonksiyonu ya da saf Node fonksiyonu olarak yazılabiliyor | Orta |

**Çürütme ölçütü (falsifier):** Code, her fırsat için şunu yanıtlar: *"Bu davranış SQL fonksiyonu ya da saf Node fonksiyonu olarak yazılamıyor mu? Yazılamıyorsa neden?"* Cevap kanıtlanamazsa Java önerilmez. Java ancak **kanıtlanmış bir yetersizlik** varsa aday olur; o zaman dağıtım maliyeti (yukarıdaki Doğrulanmadı satırı) ölçülür.

## 5. Tasarım fırsatları ve üç vaka

### 5.1 Fırsat havuzu (yedi alan; hepsi "şimdi / sonra / hiç" olarak etiketlenir)
İş yönetimi · malzeme · finans · planlama · teknik arıza kayıtları · kalite denetimi · raporlama. **Mevcut yazılımda olmayan hiçbir şey var gibi yazılmaz.** Öncelik: Modül 1'in kapsadığı (iş yönetimi) dışındakiler en çok **bir** "sonra" adayı çıkarır.

### 5.2 Vakalar (Burak'ın üç vakası, mevcut kurallara bağlı)

| Vaka | Burak'ın sorusu | Sohbet tarafının bağlantısı | Code'dan beklenen |
|---|---|---|---|
| **1 · İş süresi** | Hazırlık, ulaşım, uygulama, kapanış süreleri ayrı değerlendirilebilir mi? | Her alan bir sürtünmedir (Modül 1: tek zorunlu alan). **Sormadan türet:** `svc_olaylar` zaten zaman damgalı durum geçişlerini tutuyorsa süre parçaları **olaylardan hesaplanır, Burak'a ek alan sorulmaz.** Durum kümesi (yolda, başladı, bitti…) yeterli mi? | Hangi geçişler olaydan süre üretir, hangileri üretmez (boşluk); ek alan gerektiren süre var mı |
| **2 · Malzeme ve kâr** | Eksik maliyet yüzünden yanıltıcı kâr nasıl engellenir? | "Eksik veri sıfır değildir" kuralı zaten var (UX-8). Kâr, tüm maliyet kalemleri **bilinen** ise "kesin", biri bile eksikse "**hesaplanamaz / eksik: N kalem**" gösterir; sıfır varsayımı yok. Kanıt ağırlığı işareti (brief 007) bu ayrımı taşıyabilir | Hesap ile veri saklama ayrımı: saf hesap fonksiyonu + eksik kalem listesi döndüren sözleşme; para `numeric(12,2)` |
| **3 · Arıza bilgisi** | Benzer belirtileri aynı kök neden saymamak | `knowledge/` kayıtları ölçüm/gözlem/hipotez/doğrulanmış ayrımını **zaten** taşıyor (kanıt sınıfı + güven etiketi). **Code `knowledge/` içeriğini değiştirmez, kodlar.** Uygulama tarafında: "benzer vaka" bir **öneridir, teşhis değil**; sistem otomatik kök neden yazmaz (UX-7) | Importer'ın etiketleri bozmadan taşıdığı; "benzer" gösteriminin kanıt etiketiyle birlikte geldiği tasarım adayı |

## 6. Eleştirel denetim (Code her adayda yanıtlar)
Gereklilik (olmazsa ne olur?) · karmaşıklık · bakım maliyeti (tek kişi) · mevcut mimariye etki · test edilebilirlik (brief 008 katmanlarından hangisi?) · değişikliğe uyum · **karşıt hipotez** (hangi gözlem bu adayı eler?) · YAGNI/KISS/Dikey dilim.

Her aday şu yedi parçaya **ayrılır** (karışmasın): koddan doğrulanan mevcut durum · araştırılan fırsat · kanıtlanmamış varsayım · alternatifler · teknik ve işletme etkisi · doğrulama gereksinimi · öncelik.

## 7. Sınır ve durma kuralı
- Süre: **en çok 1 oturum**; kod yazılmaz, üretim koduna dokunulmaz.
- Çıktı: **en çok 3 aday**, her biri bir sayfa. İlk 3 dışındakiler "havuzda" tek satırdır.
- Durma: yeni araştırmanın beklenen katkısı düşükse (aynı sonucu doğrulayan üçüncü kaynak gibi) durulur ve bu raporlanır.
- Kapsam dışı: TEHAİ ve diğer projeler; gereksiz framework ya da bağımlılık önerisi (kanıtlanmış yetersizlik hariç).

## 8. Teslim ve kabul
- Teslim: Code raporu **tek dosya** olarak Burak'a verir (Code `docs/**` yazamaz). Burak bana iletir; ben `docs/decisions/` altına işler ve denetlerim.
- **Kabul ölçütü (Burak'ın 10 dakikasında):** raporu okuyup üç adaydan **birini** seçebilmeli ya da "hiçbiri" diyebilmeli. Okuduktan sonra Java'nın BEE için gerekli olup olmadığını tek cümleyle söyleyebilmeli.
- Denetim: üreten olmayan taraf (sohbet Claude) rapordaki "koddan doğrulanan" satırlarını rastgele 3 tanesinde koda karşı kontrol eder.

## 9. Kaynak
- Vercel resmî çalışma zamanları: https://vercel.com/docs/functions/runtimes (Yüksek)
- Vercel çalışma zamanı yapılandırması: https://vercel.com/docs/functions/configuring-functions/runtime (Yüksek)
- Brief 007 (kanıt işareti), 008 (test düzeni), `ekran-sablonu.md` (UX-7, UX-8)
