# Brief 007 — Tasarım kimliği: keşif ve 3 yön denemesi

Yazan: sohbet Claude (tasarım mimarisi). Alıcı: Claude Code. Karar: Burak (ES-6).
Ön koşul: brief 006 madde 1–2 kapanmış olmalı. Bu brief Modül 1 ilk diliminin (giriş + iş aç) **görsel dilini** belirler; işlevi değiştirmez.

## 1. Burak'ın isteği (02:25)
Tamamen profesyonel, zorlayıcı teknikte, taklit edilmesi zor, uğraştırıcı, "bize has". Keşif amaçlı: bildiklerim + dışarıdan öğrenilenler.

## 2. Önce dürüst sınır (Yüksek, mantıksal)
Repo **halka açık**. CSS, renkler, düzen görünür; görsel katman tek başına taklit edilmesi zor **olamaz**. Zor taklit edilen şey görsel değil **anlamsal sistemdir**: her bilginin kanıt ağırlığını, kaynağını ve belirsizliğini ekranda taşıyan tutarlı dil; bu dil `knowledge/` ve saha verisine bağlıdır, kopyalanan sadece kabuğunu alır. Bu yüzden "bize has" = **alan sözlüğünden türeyen** (klemens, etiket, uç, kanıt) + **disiplinle uygulanan** (renk, hareket, dil) bir sistem. Süs değil.

## 3. Keşfin bulguları (kaynaklı, güven etiketli)

| # | Bulgu | Tasarıma etkisi | Kaynak | Güven |
|---|---|---|---|---|
| K1 | Yüksek performanslı HMI (ISA-101): gri/nötr zemin, renk **yalnız anormal durum** için, alarm renkleri başka amaçla kullanılmaz, renk tek ayırt edici olamaz, hareket yalnız alarmda, kritik değer normal/anormal aralığına göre bağlam içinde gösterilir | Renk disiplini: nötr palet + tek vurgu; kırmızı/sarı **yalnız** gerçek sorun (kaçırıldı, engel, hata) | ISA "High Performance HMI Overview v2.01" (isa.org), ISA InTech Nisan 2023 | **Yüksek** (kural metni), BEE'ye uyarlama **Orta** |
| K2 | Dış mekânda W3C 7:1 yetmeyebilir; bir laboratuvar çalışması (LCD, simüle dış ışık) 18:1 öneriyor | Gün teması için hedef: metin kontrastı mümkün olan en yüksek (≥ 12:1 hedef, 4.5:1 yalnız alt sınır) | Pignoni 2018, doi:10.1109/cvcs.2018.8496507 | **Orta** (tek çalışma, simülasyon, iPhone 11 ölçümü yok) |
| K3 | Ekran üzerindeki aydınlatma okunabilirliği en çok etkileyen etken; ~10.000 lx üstünde kontrast düşüşü; karanlığa uyum parlama rahatsızlığını artırır, çok düşük arka plan ışığı bile azaltır | Tek tema yetmez: **gün** (açık zemin, koyu yazı, yüksek kontrast) ve **loş** (koyu gri, saf siyah değil) ayrı token seti | Okumura & Okajima 2026, doi:10.2352/ei.2026.38.10.hvei-223 | **Yüksek** (çalışmanın bulgusu), tema kararı **Orta** |
| K4 | Alternatif renk modları (açık/koyu/yüksek kontrast) yararlı ama uygulaması sorunlu; görme engelli olmayanlar da kullanıyor | Tema seçimi kullanıcıda; sistem varsayılanı + elle geçiş | ACM HCI 2025, doi:10.1145/3743704 | **Yüksek** (yayın), yorum **Orta** |
| K5 | Saha teknisyeni sezgileri (sekiz heuristik): çoklu giriş yolu (fotoğraf, ses, yapılandırılmış metin), çevrimdışı çalışma, **girilen verinin ne için kullanıldığını göstermek**, teknik dokümana uygulamadan erişim, geçmiş iş bilgisi | Alan sayısı minimum; her alanın yanında "neden soruluyor"; bilgi tabanı uygulama içinden açılır | Johnston & Pickrell 2016, doi:10.1145/3010915.3011003 | **Yüksek** (yayın) |
| K6 | Tek el / başparmak bölgesi, güneşte kontrast, senkron durumu görünür olsun (kuyrukta / yükleniyor / başarısız) | UI-2 ve PF-2 ile uyumlu; **senkron çipi** zorunlu bileşen | Tarka Labs EAM360, Team400 blog, Simplileap vaka | **Orta/Doğrulanmadı** (satıcı blogu ve anonim vaka; Simplileap'in sayısal sonuçları kullanılmaz) |
| K7 | Belirsizlik gösterimi: türetilmiş/yorumlanmış değer, doğrudan gözlenmiş değer kadar "kesin" görünmemeli; tarama (hatching), saydamlık, **sözel bant** (yüzde değil); doku kaynağa/kalite alanına bağlı, çıkarılabilir | **Kanıt ağırlığı işareti** (bölüm 4/imza 1) | Bathyl 2026 blog (Orta), Abstractopedia (Orta), Probabilistic-UI deposu (fikir kaynağı, otorite değil: Doğrulanmadı) | **Orta** |
| K8 | Klemens/iletken etiketleme: IEC 60445 terminal ve iletken tanımlama; IEC 62491 kablo/damar etiketleme (kimlik etiketi uçta aynı, bağlantı etiketi uca özgü); numara şeması bir **proje sözleşmesidir**, ne zaman değişeceği yazılı olmalı | Görsel sözlüğün kaynağı: numaralı klemens, etiket şeridi, "bu uç / öbür uç" ayrımı | IEC webstore (60445:2021), Tagsight 2026 blog (Orta) | **Yüksek** (standart kapsamı), blog yorumu **Orta** |
| K9 | Inter (OFL 1.1) Türkçe karakterleri (ı İ ş ğ ö ç ü) içerir, sıfır işaretli ve tablo rakamları var; kendi sunucundan sunulabilir | Yazı tipi seçimi **zayıf ayırt edicidir**; asıl iş rakam okunurluğu | rsms/inter, thatsmyfont.com | **Yüksek** (lisans), IBM Plex Türkçe desteği **Doğrulanmadı** |

Keşifte **bulunamayan / doğrulanmayan**: iPhone 11 üzerinde gerçek güneş testi, Türk tesisat sektöründe tasarım kimliği örnekleri, Dynamic Island olmayan cihaza özel bulgu. Bunlar Burak'ın sahasına kalır.

## 4. "Bize has" imza öğeleri (öneri; her biri alan sözlüğünden)

1. **Kanıt ağırlığı işareti.** Üç hâl, hem biçim hem **yazı**: Yüksek = dolu blok · Orta = yarım dolu/çizgili · Doğrulanmadı = tarama + "doğrulanmadı". Renkten bağımsız (ES-5). İş ekranında karşılığı: **Ölçüldü / Tahmin** (örn. `tahmini_bedel`, arıza nedeni). Eksik veri sıfır değil, "bilinmiyor" (UX-8).
2. **Klemens yerleşimi.** Listeler ve alan grupları numaralı klemens sırası gibi: sabit sütunlu numara etiketi (1, 2, 3…), her satır bir "uç". Numara kararlıdır; yeniden numaralanmaz (K8: sözleşme).
3. **Etiket şeridi tipografisi.** Kimlikler ve rakamlar (iş no, telefon, tutar) tablo rakamlı, sıfırı ayırt edilebilir ve ayrı bir "etiket" kutusunda; el yazısı karışıklığı (1/7, 0/O) yaşanmasın diye.
4. **Renk disiplini (ISA).** Nötr zemin + **tek** vurgu rengi. Kırmızı/sarı yalnız gerçek sorunda ve yalnız orada. Normal ekran neredeyse renksiz.
5. **Hareket disiplini.** Animasyon yok; yalnız durum değişimi (kaydedildi, sıraya alındı, başarısız) ve `prefers-reduced-motion` saygılı. Pil ve dikkat tasarrufu.
6. **Senkron çipi.** Her ekranda görünür: `Kaydedildi` · `Sırada (şebeke yok)` · `Gönderilemedi — tekrar dene`. Sessiz başarısızlık yok (UX-4).
7. **Ses (dil).** Kısa emir kipi, sahada kullanılan sözcük, özür/dolgu yok. Örn. "Kaydedildi." / "Şebeke yok, sıraya alındı." (TR-3).

## 5. Üç aday yön (Burak seçer; ben dayatmam)

| | A · Klemens | B · Pano | C · Etiket |
|---|---|---|---|
| Fikir | Numaralı klemens şeridi; açık zemin, kalın çizgiler | ISA tarzı gri enstrüman panosu; renk yalnız anormalde | Etiket makinesi estetiği: siyah-beyaz, mono rakam, sarı yalnız uyarı |
| Gün teması | Açık, yüksek kontrast (varsayılan) | Açık gri (Gray 3 civarı) | Beyaz, saf siyah yazı |
| Loş tema | Koyu gri zemin | Koyu antrasit | Siyah zemin yerine koyu gri, ters etiket |
| Güçlü yanı | Alana en yakın, kanıt işareti doğal oturur | Renk disiplini en sıkı, kanıtlı (K1) | En az yer, en hızlı yüklenir |
| Riski | Sıkıcı/ağır görünebilir | Düz kalabilir, "soğuk" | Sert, uzun kullanımda yorucu olabilir |
| Güven | Orta | Orta/Yüksek (K1) | Orta |

**Benim önerim (Orta, Burak'ın saha deneyimi bunu çürütebilir):** A'nın yapısı + B'nin renk disiplini + C'nin rakam tipografisi, iki token seti (gün/loş). Ama önce üçünü ayrı gör.

## 6. Keşif sınırı (Burak "keşif" dedi, sınır koyuyorum)
- **Kapsam:** 3 yön × 2 ekran (giriş, iş aç) = 6 statik prototip. Backend yok, sahte veri.
- **Tur:** en çok **1** deneme turu + 1 düzeltme turu. Üçüncü tur gerekirse Burak ayrıca onaylar.
- **Konum:** `src/` içinde dağıtılmayan bir klasör (örn. `src/_deneme/`); canlı rotalara dokunma. Yer ve ad Code'un kararı, `src/CLAUDE.md`'ye yazılır.
- **Çıktı:** Burak'ın iPhone 11'inde aynı sayfadan 6 ekranı gün ışığında ve loşta karşılaştırması. Seçilen yön `docs/decisions/` altında karar kaydı olur (ben yazarım, Burak onayı ile).
- **Bitiş ölçütü:** ES-6 Burak'ın yazılı onayı. Onaysız yön `tokens.css`'e girmez.

## 7. Code'a görevler

1. Her yön için `tokens.css` benzeri **ayrı** token dosyası (gün + loş). Bileşen CSS'i token dışı sabit değer içermez (ES-1, ES-4).
2. Her ekran için `ekran-sablonu.md` A bölümünü doldur (ekran adı, bağlam, tek birincil eylem, süre, durumlar, gösterilmeyecekler).
3. 6 durumu her ekranda zorla göster (UX-5): boş, yükleniyor, hata, başarı, çevrimdışı, oturum bitti.
4. Kanıt ağırlığı işareti, senkron çipi, klemens satırı: **tek bileşen** olarak yaz, üç yönde yalnız token farkı olsun.
5. Ölçümleri tarayıcıda yap (375×667 ve 414): hedef boyutu (UI-1), yatay kaydırma (UI-6), yazı boyutu (UI-3), kontrast çiftleri (EA-1/2). Sonuç tek sayfa, kanıtlı.
6. İşaretlenemeyen satırlar "el" etiketli kalır; Safari/güneş bunlardan.

## 8. Açık kararlar (Burak)
- **Yazı tipi:** `PF-3` sistem yazı tipi diyor. Varsayılan: sistem sans + sistem mono (`ui-monospace`) + `font-variant-numeric: tabular-nums`. Inter kendi sunucundan sunulabilir (OFL, Türkçe var, ~189 KB Latin alt kümesi) ama bu **zayıf ayırt edici** ve PF-3'ü değiştirir. Onayın olmadıkça sistem yazı tipi. Onay verirsen ES-2 ("tek ailesi") ve PF-3'ü ben güncellerim.
- **Tema:** otomatik (sistem) + elle geçiş mi, yoksa gün varsayılan mı? Öneri: otomatik + elle.
- **Kanıt ağırlığı işareti** iş verisinde (Ölçüldü/Tahmin) kullanılsın mı yoksa yalnız bilgi tabanı görünümünde mi?

## 9. Denetim
Üretimi Code yapar, denetimi üretmeyen taraf: `ekran-sablonu.md` B ve C satırları, G3 (ekran içeren PR). K2/K3'ün BEE için geçerliliği ancak Burak'ın gün ışığı denemesiyle **Yüksek** olur; o zamana kadar **Orta**.

## 10. Kaynaklar
- ISA, High Performance HMI Overview v2.01: https://www.isa.org/getmedia/06130a38-f7af-4b35-8c9c-2c34f25c1977/The-High-Performance-HMI-Overview-v2-01.pdf
- ISA InTech, Nisan 2023: https://www.isa.org/intech-home/2023/april-2023/features/how-dcs-migration-improves-operator-experience
- Pignoni 2018: https://doi.org/10.1109/cvcs.2018.8496507
- Okumura & Okajima 2026: https://doi.org/10.2352/ei.2026.38.10.hvei-223
- Alternatif renk modları, ACM HCI 2025: https://dl.acm.org/doi/full/10.1145/3743704
- Johnston & Pickrell 2016: https://doi.org/10.1145/3010915.3011003
- Tarka Labs EAM360: https://tarkalabs.com/design/eam360-field-operations/
- Team400, saha servis desenleri: https://team400.ai/blog/2025-07-field-service-mobile-apps
- Bathyl 2026 (belirsizlik kodlama): https://www.bathyl.com/en/blog/map-storytelling-without-oversimplifying-science
- Abstractopedia, veri-kalite dokusu: https://abstractopedia.org/mechanisms/data_quality_texture_overlay/
- IEC 60445:2021: https://webstore.iec.ch/en/publication/66712
- Tagsight, tel numaralama: https://tagsight.io/blog/wire-numbering-convention
- Inter: https://github.com/rsms/Inter
