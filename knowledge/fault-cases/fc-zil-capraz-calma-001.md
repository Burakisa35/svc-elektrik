---
id: fc-zil-capraz-calma-001
type: fault_case
system: [netelsan-sesli-diafon]
symptom: Panelden bir daireye basılınca başka dairelerin zili de çalıyor; daire kapısı iç zil butonu bunu yapmıyor
confidence: Orta
sources: [src-simge-daire-subesi-2020, src-audio-as202-kilavuz, src-yoreparo-commax-8, src-zintercom, src-tektone-buzzing, src-bellsystem-pd178, src-kontrolkalemi-audio-ariza-notlari, src-kontrolkalemi-netelsan-ariza-2021, src-donanimhaber-diafon-ariza-2016]
---

## Belirti
Zil panelindeki bir daire butonuna basılınca basılan daire ile birlikte bazı başka dairelerin zili çalıyor. Etkilenen daireler şaft/hat gruplarına göre. Daire kapısı önündeki iç zil butonuna basınca bu olmuyor. Eski dönemde "bas-konuş" basılınca tüm dairelerin zili çalmıştı (saha, Burak).

### Saha gözlemleri (kaynak sınıfı: saha, Burak, 2026-11-06/07)
- Bir şaftın DT8'i sökülünce o şafttaki daireler normale dönüyor; iki daire devre dışı bırakılınca da normale dönüyor.
- Başka bir daireye **yeni şube** takılınca da arıza sürüyor; bilinen sağlam, aşağıda çalışan şube takılınca da sürüyor. → Arıza dairenin hattında, şubede değil (Orta: iki şube denemesi).
- Zil panelinde kırık/ek yok, kablolar kontrol edildi.
- **Sınır:** DT8'in tamamını sökmek, DT8 iletkenlerini zil teli ile **ayırt etmez**. Yalnız zil telini ayırma testi henüz yapılmadı.

## Ayırt edici sorular
1. Matris: hangi daireye basınca hangileri çalıyor? Karşılıklı mı (A→B ve B→A) tek yönlü mü? Tek yönlü vakalar yayımlanmış (Audio notları s.19, DonanımHaber 2016; çözümleri yazılı değil); karşılıklı vaka çözülmüş (Commax).
2. Çapraz çalan zil tam sesle mi, düşük sesle mi çalıyor? (Düşük sesli çalma kaçak/kuplaj; tam ses metalik temas yönünde, Orta. Düşük sesli vaka başka sistemde: kaynak analoji.)
3. Şubede panel dönüş teli ile iç zil butonu teli hangi klemenste? Audio/Simge'de **ikisi aynı ZİL klemensi**; Netelsan çiziminde Doğrulanmadı. K.ZİL'e bağlı tel var mı? (K.ZİL yeni sistemde kullanılmaz.)
4. Panel butonları ve daire kapısı butonları ışıklı mı? (Audio notu: zilli sistemde ışıklı buton olmamalı; Orta, tek kaynak.)
5. Şaftlarda ve buatlarda zil teli ile DT8 aynı yerde mi ekleniyor, ek tipi ne (burgulu + bant)?

## Olası nedenler (olasılık sırasıyla; hiçbiri saha ölçümüyle doğrulanmadı)
- **H1 — İki dairenin zil dönüş teli arasında metalik/dirençli kaçak** (şaft buatı, burgulu-bantlı ek, hasarlı yalıtım). Orta. Dayanak: Commax vakasında iki dönüşün kısa olması ve çözümün gizli kayıt kutusundaki ek yerleri olması; Bell System: kopuk damar, yalıtkana sıkılmış konnektör, çivilenmiş kablo. Zayıf nokta: iç zil butonu etkilemiyor (Simge/Audio topolojisinde iç buton teli de aynı şube klemensine geldiği için kaçak iç zilde de beklenirdi; Netelsan için topoloji Doğrulanmadı).
- **H2 — Zil dönüş teli ile DT8 iletkenleri (2/3/5 dahil) arasında kaçak.** Doğrulanmadı. Saha gözlemiyle uyumlu (DT8 sökülünce düzeliyor) ama doğrudan kaynak yok.
- **H3 — Şube ZİL girişinde yarı iletken (diyot/transistör) geri yolu.** Doğrulanmadı (Netelsan şube kartı şeması yok). Analoji: Zintercom'da çapraz çağrı bir transistörün ters diyodundan kapanıyordu (Orta, tek kaynak). Zayıf nokta: yeni ve sağlam şube takılınca da sürüyor, yani şubeye özgü değil; tüm şubelerde ortak tasarım ihtimali kalır.
- **H4 — Işıklı buton/lamba üzerinden geri besleme.** Orta, tek kaynak (Audio notu).
- **H5 — Kapasitif/indüktif kuplaj (kalitesiz kablo, uzun paralel hat).** Orta (Tektone: uğultu/sızıntı, seri 1N4003). Düşük olasılık: kuplaj genellikle uğultu yapar; zili tetiklemesi için eşik aşılmalı. Doğrulanmadı.

## Test adımları
Hepsi güç kapalıyken, aksi belirtilmedikçe. Her adım sonucu `field_report` olarak kaydedilir.

1. **Matris çıkar.** Sorunlu dairelerde tek tek panelden bas, kimin çaldığını yaz. Beklenen: tablo. *Karşılıklıysa* H1/H2 (metalik) öne çıkar; *tek yönlüyse* H3 veya tek yönlü yarı iletken yolu. Eler: simetri varsayımına göre H1↔H3.
2. **Ses şiddeti ve ışık.** Çapraz çalanın tam/düşük ses olduğunu ve butonlarda ışık/LED olup olmadığını kaydet. Eler: H4, H5 (ışık yoksa H4 düşer; düşük ses H5/H2'ye kayar).
3. **Şubede klemens kaydı.** Fotoğrafla: panel dönüş teli ve iç zil teli hangi klemenste. Eler: yanlış bağlantı (K.ZİL) ihtimalini.
4. **Boşta ölç (asıl test).** Hat tamamen boşta olacak: her iki uçta (panel, şube, santral) bağlantıdan sök. Ölç: (a) dönüş teli A ↔ dönüş teli B, (b) dönüş teli A ↔ DT8'in her damarı, (c) DT8 damarları arası. Beklenen: açık devre. Sonlu bir değer gelirse kaçak yolu iki iletkenle belirlenmiş olur: zil-zil → H1; zil-DT8 → H2. Not: elektronik bağlıyken yapılan ohm ölçümü yanıltıcıdır (yarı iletken yolu). Megger (250-500 V) yalnızca elektronik tamamen ayrıldıysa; bu pratik için kaynak yok (Doğrulanmadı).
5. **Ek yerlerini aç.** Şaft buatlarındaki burgulu-bantlı ekleri aç, nem/oksit/yalıtım hasarına bak, WAGO tipi bağlantıyla değiştir, tekrar test. Beklenen: arıza kaybolur. Eler/kanıtlar: H1 (Commax çözümü bu yöndeydi).
6. **Yalnız zil teli ayırma.** DT8 bağlı kalsın; sorunlu dairenin zil dönüş telini şubeden ayır. Arıza gidiyorsa kaçak zil telinde; gitmiyorsa DT8 yolu. Eler: H2 ↔ H1.
7. **Şube ZİL girişi diyot-modu ölçümü** (şube santralden ayrık, tek başına). ZİL ucu ile 1 ve 6 arasında iki yönde ölç. Tek yönlü iletim yarı iletken yolu gösterir. Yöntem kaynaksız: Doğrulanmadı, keşif amaçlı.
8. **Ortak uç gerilimleri.** Santral sistemi açıkken Dış Zil1 ve İç Zil ortak uçlarının boşta ve basılıyken DC/AC gerilimi. Sonuç Netelsan sinyal türü sorusunu kapatır.

## Sonuç / kök neden
(Saha doğrulaması gelene dek boş.)

## Kaynaklar
Ön ek `src-`; ayrıntı `knowledge/sources/`.
