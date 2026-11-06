---
id: fc-zil-capraz-calma-001
type: fault_case
title: Panelden basınca başka dairelerin zili de çalıyor (iç zil butonu etkilemiyor)
status: taslak
updated: 2026-11-07
system: [netelsan-sesli-diafon]
symptom: Panelden bir daireye basılınca başka dairelerin zili de çalıyor; daire kapısı iç zil butonu bunu yapmıyor
confidence: Doğrulanmadı
sources: [src-simge-daire-subesi-2020, src-audio-as202-kilavuz, src-yoreparo-commax-8, src-zintercom, src-tektone-buzzing, src-bellsystem-pd178, src-kontrolkalemi-audio-ariza-notlari, src-kontrolkalemi-netelsan-ariza-2021, src-donanimhaber-diafon-ariza-2016]
---

## Belirti
Zil panelindeki bir daire butonuna basılınca basılan daire ile birlikte bazı başka dairelerin zili çalıyor. Etkilenenler şaft/hat gruplarına göre. Daire kapısı iç zil butonuna basınca olmuyor. Eskiden bas-konuş basılınca tüm daireler çalmıştı.

### Saha gözlemleri (sınıf: saha, Burak, 2026-11-06/07; etiket yerine sınıf)
- **S1** Bir şaftın DT8'i sökülünce o şaftta arıza kayboluyor; bir şafttan iki daire devre dışı bırakılınca sistem normale dönüyor.
- **S2** Başka bir daireye yeni şube takılınca da arıza sürüyor; bilinen sağlam şube takılınca da sürüyor.
- **S3** Panelde kırık yok, kablolar görsel kontrol edildi.
- **S4** İç zil butonu çapraz çaldırmıyor.

### Gözlemlerin sınırı (G1 denetimi sonrası)
- DT8'i sökmek şubenin güç (1/6) ve ses/kontrol hattını da keser. O dairenin zil sesini hâlâ duyup duymayacağı Doğrulanmadı (zil sesinin şubeye hangi yoldan geldiği kaynaksız). "Arıza kayboldu" ifadesi, iptal edilen dairenin **kaynak mı kurban mı** olduğuna bağlı. Bu ayrım yapılmadıkça S1 hiçbir hipotezi tek başına desteklemez.
- Zil teli yalnız başına ayrılıp denenmedi.

## Ayırt edici sorular
1. İptal edilen daire çapraz çalmanın **kaynağı** mıydı (onu iptal edince diğerleri sustu) yoksa **kurbanı** mıydı (kendisi artık çalamadığı için arıza ortadan kalktı)?
2. Matris: hangi daireye basınca hangileri çalıyor; karşılıklı mı, tek yönlü mü? Yayımlanmış tek yönlü vakalar var (Audio notları s.19, DonanımHaber 2016; çözüm yazılmamış).
3. Çapraz çalan zil tam sesle mi, zayıf mı? (Yorum yok; yalnız kaydedilecek. Yorumu Doğrulanmadı.)
4. Şubede panel dönüş teli ve iç zil teli hangi klemenste (ZİL / K.ZİL)? Audio/Simge'de ikisi aynı ZİL klemensi, Netelsan'da Doğrulanmadı.
5. Panel ve daire butonları ışıklı mı?
6. Santralde İç Zil ortak ucu bağlıyken/sökülüyken panel çapraz çalması değişiyor mu? (Netelsan 2021 forum vakası iç zil bağlanınca farklı dairelerin çaldığını bildiriyor; çözüm yok, Doğrulanmadı.)

## Olası nedenler (sıra olasılık değildir; hiçbiri ölçümle doğrulanmadı)
| Hipotez | Etiket | Dayanak | Saha gözlemiyle ilişki |
|---|---|---|---|
| **H1** İki dairenin zil dönüş teli arasında kaçak (ek yeri, hasarlı yalıtım) | Doğrulanmadı (tek analoji vakası) | Commax vakasında dönüşlerin kısa olması, çözümün gizli kayıt kutusundaki ek yerleri olması (tek vaka bildirimi); Bell System: kopuk damar, yalıtkana sıkılmış konnektör, çivilenmiş kablo (genel arıza listesi, çapraz çalma değil); Siedle 1+n forum vakası: iki çağrı telinin değmesinin ikisini de çaldıracağı yorumu, kök neden bildirilmedi (src-elektrikforum-siedle-coklu-calma-2019); STR forum vakası: butonlar arası kısa dağıtım kutusunun ardında bulundu, belirti tek taraflı (src-mikrocontroller-str-tuersprechanlage-2019); Siedle servis el kitabı iletkenler arası kısayı belgelenmiş arıza sınıfı olarak veriyor (src-siedle-servicehandbuch) | S4'e karşı: Simge/Audio topolojisinde iç buton teli de aynı şube klemensine geldiğinden kaçak iç zilde de beklenirdi; Netelsan topolojisi Doğrulanmadı. S1 ile bağı yok (zil teli DT8'de değil) |
| **H2** Zil dönüş teli ile DT8 iletkenleri arasında kaçak | Doğrulanmadı | Doğrudan kaynak yok | S1 ile uyumlu olabilir (kaynak/kurban sorusuna bağlı) |
| **H3** Şube ZİL girişinde yarı iletken geri yolu | Doğrulanmadı | Analoji: Zintercom'da çapraz çağrı bir transistörün ters diyodundan kapanıyor; çözüm diyot eklemek (tek DIY kaynak) | S2'ye karşı: sağlam ve yeni şube de aynı sonucu veriyor; tüm şubelerde ortak tasarım ihtimali kalır |
| **H4** Işıklı buton/lamba üzerinden geri besleme | Doğrulanmadı | Audio notu yalnız ışıklı buton olmaması gerektiğini söyler; mekanizma söylenmez | Soru 5 ile test edilir |
| **H5** Kapasitif/indüktif kuplaj | Doğrulanmadı | Tektone: kalitesiz kablo uğultu/sızıntı yapar; zil çaldırdığı söylenmiyor | Düşük olasılık; zili tetiklemek için eşik aşılması gerekir |
| **H6** İç zil ortak teli yolunun katkısı | Doğrulanmadı | Netelsan 2021 forum bildirimi, çözümsüz | Soru 6 ile test edilir |

## Test adımları
"Güç" sütunu: **K** kapalı (santral 220 V ve trafo kesik), **A** açık. Sonuçlar `field_report` olarak kaydedilir.

| # | Güç | Yap | Beklenen / yorum | Neyi eler |
|---|---|---|---|---|
| 1 | A | Kaynak/kurban ayrımı. Önce 'arıza' tanımı: bir butona basınca hangi dairelerin çalması sorun sayılıyor, listele. Sonra her sorunlu daireyi tek tek devre dışı bırak (DT8'ini sök), her iptalden sonra aynı butonlara bas, çalanların listesi nasıl değişiyor yaz | Dairenin iptali **kendisi dışında** başkalarını da susturuyorsa o daire çalmanın **yolunda**. Yalnız kendi çalışması kayboluyorsa **kurbandır**. Sınır: DT8'i sökmek zil teline dokunmaz; bu test H2/H3 türü yolları gösterir, tel-tel kaçağını (H1) göstermez. Birden fazla kurban varsa tek iptal listeyi tamamen bitirmez; bu beklenen | Eleme yapmaz, bilgi toplar; adım 7'nin yorumunu mümkün kılar |
| 2 | A | Matris: sorunlu dairelerde tek tek panelden bas, kim çalıyor yaz; her çiftte iki yönü de dene | Veri toplar. Karşılıklı/tek yönlü ayrımının neyi gösterdiği Doğrulanmadı (tek yönlülük eşik veya direnç farkından da çıkabilir); yalnız sonraki testleri yönlendirir | Eleme yapmaz |
| 3 | A | Ses şiddeti ve butonlarda ışık/LED var mı yaz | Işık varsa H4 canlı; yoksa H4 elenir | H4 |
| 4 | K | Şubede panel dönüş teli ve iç zil teli hangi klemenste, fotoğrafla | Fark çıkarsa yanlış bağlantı; aynıysa topoloji Simge/Audio ile uyumlu | yanlış bağlantı (K.ZİL) |
| 5 | K | **Boşta ölçüm:** panel, şube, santral bağlantılarını söküp hat boşta ölç: (a) dönüş A ↔ dönüş B, (b) dönüş A ↔ DT8'in her damarı, (c) DT8 damarları arası | Beklenen: açık devre. Sonlu değer = kaçak yolu iki iletkenle belirlenmiş: zil-zil → H1, zil-DT8 → H2. Açık devre gelirse H1/H2 hat boşken **elenmiş** sayılmaz (kaçak nemli/gerilimli olabilir); H3/H4/H5'i **elemez** | H1/H2 (pozitif sonuçta) |
| 6 | K, sonra A | Şaft buatındaki burgulu-bantlı ekleri aç, WAGO tipi bağlantıyla değiştir, yeniden dene | Arıza kayboluyorsa kaçak o ek yerlerindeydi | H1 (pozitif sonuçta) |
| 7 | K, sonra A | Yalnız sorunlu dairenin zil dönüş telini **şube ucundan** ayır (DT8 bağlı), adım 1'deki aynı butonlara bas | Gidiyorsa: bu daire yalnızca **kurban** olabilir (telin ayrılması onun çalmasını keser) **veya** kaçak şubenin ZİL giriş yolundadır (H3). Gitmiyorsa: bu şubenin ZİL girişi ve kurban etkisi sebep değil; kaçak telin kablo gövdesinde (H1/H2) ise şube ucunu ayırmak onu kesmez, yani **bu sonuç bu daireyi kaynak olmaktan çıkarmaz**. Ayrım için: kurban → adım 1, H3 → adım 8, H1/H2 → adım 5 ve adım 7b | Tek başına eleme yapmaz; yalnız 'şube giriş yolu mu' sorusunu daraltır |
| 7b | K, sonra A | Aynı zil telini **panel ucundan** da ayır (iki ucu da boşta), aynı butonlara bas | Kaynak daireyse ve kaçak telin gövdesindeyse bu adımdan sonra çapraz çalma biter (tel her iki uçtan beslenmez). Bitmiyorsa kaçak bu telde değildir | 7 ile birlikte okunur: H1/H2'nin bu telle ilgisini belirler (çalma bitmesi tek başına eleme yapmaz; kurban ve H3 de aynı sonucu verir) |
| 8 | K | Şubeyi tek başına çıkar, ZİL ucu ile 1 ve 6 arasında diyot modunda iki yönde ölç | Yön farkı varsa yarı iletken yolu göstergesi; fark yoksa H3'ü zayıflatır ama elemez. Yöntem kaynaksız, keşif amaçlı: Doğrulanmadı | H3 (zayıf) |
| 9 | A | Dış Zil1 ve İç Zil ortak uçlarının boşta ve basılıyken DC/AC gerilimi | Sayısal değer kaydedilir; Netelsan sinyal türü sorusu kapanır. Eleme yapmaz, bilgi toplar | — |
| 10 | A | Santralde İç Zil ortağını geçici sök, panel çapraz çalmasını tekrar dene | Değişiyorsa H6 canlı; değişmiyorsa H6 zayıflar (tek deney elemez) | H6 (yalnız zayıflatır) |

Megger (250-500 V) yalnız elektronik tamamen ayrıldıysa; pratik için kaynak yok (Doğrulanmadı).

## Sonuç / kök neden
(Saha doğrulaması gelene dek boş.)

## Kaynaklar
Ön ek `src-`; ayrıntı `knowledge/sources/`.
