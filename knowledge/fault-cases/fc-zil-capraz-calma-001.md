---
id: fc-zil-capraz-calma-001
type: fault_case
title: Panelden basınca başka dairelerin zili de çalıyor (iç zil butonu etkilemiyor)
status: taslak
updated: 2026-11-07
system: [netelsan-sesli-diafon]
symptom: Panelden bir daireye basılınca başka dairelerin zili de çalıyor; daire kapısı iç zil butonu bunu yapmıyor
confidence: Orta
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
- DT8'i sökmek şubenin güç (1/6) ve ses/kontrol hattını da keser. O şube artık çalamaz bile: "arıza kayboldu" ifadesi, iptal edilen dairenin **kaynak mı kurban mı** olduğuna bağlı. Bu ayrım yapılmadıkça S1 hiçbir hipotezi tek başına desteklemez.
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
| **H1** İki dairenin zil dönüş teli arasında kaçak (ek yeri, hasarlı yalıtım) | Orta | Commax vakasında dönüşlerin kısa olması, çözümün gizli kayıt kutusundaki ek yerleri olması (tek vaka bildirimi); Bell System: kopuk damar, yalıtkana sıkılmış konnektör, çivilenmiş kablo (genel arıza listesi, çapraz çalma değil) | S4'e karşı: Simge/Audio topolojisinde iç buton teli de aynı şube klemensine geldiğinden kaçak iç zilde de beklenirdi; Netelsan topolojisi Doğrulanmadı. S1 ile bağı yok (zil teli DT8'de değil) |
| **H2** Zil dönüş teli ile DT8 iletkenleri arasında kaçak | Doğrulanmadı | Doğrudan kaynak yok | S1 ile uyumlu olabilir (kaynak/kurban sorusuna bağlı) |
| **H3** Şube ZİL girişinde yarı iletken geri yolu | Doğrulanmadı | Analoji: Zintercom'da çapraz çağrı bir transistörün ters diyodundan kapanıyor; çözüm diyot eklemek (tek DIY kaynak) | S2'ye karşı: sağlam ve yeni şube de aynı sonucu veriyor; tüm şubelerde ortak tasarım ihtimali kalır |
| **H4** Işıklı buton/lamba üzerinden geri besleme | Doğrulanmadı | Audio notu yalnız ışıklı buton olmaması gerektiğini söyler; mekanizma söylenmez | Soru 5 ile test edilir |
| **H5** Kapasitif/indüktif kuplaj | Doğrulanmadı | Tektone: kalitesiz kablo uğultu/sızıntı yapar; zil çaldırdığı söylenmiyor | Düşük olasılık; zili tetiklemek için eşik aşılması gerekir |
| **H6** İç zil ortak teli yolunun katkısı | Doğrulanmadı | Netelsan 2021 forum bildirimi, çözümsüz | Soru 6 ile test edilir |

## Test adımları
"Güç" sütunu: **K** kapalı (santral 220 V ve trafo kesik), **A** açık. Sonuçlar `field_report` olarak kaydedilir.

| # | Güç | Yap | Beklenen / yorum | Neyi eler |
|---|---|---|---|---|
| 1 | A | Kaynak/kurban ayrımı: iptal ettiğin daireyi geri bağla, sırayla başka bir daireyi iptal et; arıza hangi iptalle kayboluyor? | Aynı daire iptali her seferinde arızayı bitiriyorsa o daire kaynak/yol; farklı daireler farklı etki ediyorsa kurban etkisi | S1'in belirsizliğini giderir |
| 2 | A | Matris: sorunlu dairelerde tek tek panelden bas, kim çalıyor yaz; her çiftte iki yönü de dene | Karşılıklı çalma: metalik yol (H1/H2) daha olası; tek yönlü: H3 daha olası. Kesin sonuç değil, yön gösterir | H1/H2 ↔ H3 ayrımına yön verir |
| 3 | A | Ses şiddeti ve butonlarda ışık/LED var mı yaz | Işık varsa H4 canlı; yoksa H4 elenir | H4 |
| 4 | K | Şubede panel dönüş teli ve iç zil teli hangi klemenste, fotoğrafla | Fark çıkarsa yanlış bağlantı; aynıysa topoloji Simge/Audio ile uyumlu | yanlış bağlantı (K.ZİL) |
| 5 | K | **Boşta ölçüm:** panel, şube, santral bağlantılarını söküp hat boşta ölç: (a) dönüş A ↔ dönüş B, (b) dönüş A ↔ DT8'in her damarı, (c) DT8 damarları arası | Beklenen: açık devre. Sonlu değer = kaçak yolu iki iletkenle belirlenmiş: zil-zil → H1, zil-DT8 → H2. Açık devre gelirse H1/H2 hat boşken **elenmiş** sayılmaz (kaçak nemli/gerilimli olabilir); H3/H4/H5'i **elemez** | H1/H2 (pozitif sonuçta) |
| 6 | A | Şaft buatındaki burgulu-bantlı ekleri aç, WAGO tipi bağlantıyla değiştir, yeniden dene | Arıza kayboluyorsa kaçak o ek yerlerindeydi | H1 (pozitif sonuçta) |
| 7 | A | Yalnız sorunlu dairenin zil dönüş telini şubeden ayır (DT8 bağlı) | Arıza gidiyorsa kaçak o zil telini içeriyor (H1 **veya** H2; ayrımı adım 5 yapar). Gitmiyorsa: kaçak başka telde ya da başka noktada, sonuç tek başına bir şey eleyemez | "Zil teli içeriyor mu?" sorusunu cevaplar |
| 8 | K | Şubeyi tek başına çıkar, ZİL ucu ile 1 ve 6 arasında diyot modunda iki yönde ölç | Yön farkı varsa yarı iletken yolu göstergesi; fark yoksa H3'ü zayıflatır ama elemez. Yöntem kaynaksız, keşif amaçlı: Doğrulanmadı | H3 (zayıf) |
| 9 | A | Dış Zil1 ve İç Zil ortak uçlarının boşta ve basılıyken DC/AC gerilimi | Sayısal değer kaydedilir; Netelsan sinyal türü sorusu kapanır. Eleme yapmaz, bilgi toplar | — |
| 10 | A | Santralde İç Zil ortağını geçici sök, panel çapraz çalmasını tekrar dene | Değişiyorsa H6 canlı; değişmiyorsa H6 elenir | H6 |

Megger (250-500 V) yalnız elektronik tamamen ayrıldıysa; pratik için kaynak yok (Doğrulanmadı).

## Sonuç / kök neden
(Saha doğrulaması gelene dek boş.)

## Kaynaklar
Ön ek `src-`; ayrıntı `knowledge/sources/`.
