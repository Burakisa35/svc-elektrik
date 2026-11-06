---
id: netelsan-sesli-diafon
type: brand_model
title: Netelsan kapıcısız çift zilli sesli diafon (bas-konuş)
status: taslak
updated: 2026-11-07
confidence: Orta
sources: [src-netelsan-diafon1-kapicisiz-cift-zilli, src-netelsan-diafon-kapicili-2kapi-r01, src-simge-daire-subesi-2020, src-audio-as202-kilavuz, src-kontrolkalemi-audio-ariza-notlari]
---

## Özet
Santral + DT8 ile şubeler + zil paneli. Netelsan'ın kendi çizimlerinden **okunabilen**: santral ve şube terminal adları (DZL1/DZL2, KPC HP/ŞASİ, KAPI HP/HP2/ŞASİ, 1-8, ZİL, K.ZİL), 12 daireye kadar 15 V×15 W / üstü 24 V×50 W trafo notu, "santral kartı çıkarılırsa sistem arızaya geçer" notu. (Yüksek: src-netelsan-diafon1-kapicisiz-cift-zilli)

Geri kalan her şey (hangi renk hangi uç, zil teli topolojisi, 7/8 kontağı, fotosel beslemesi) **Simge ve Audio kılavuzlarından analojiyle** gelir. Aynı 1-8 + ZİL şube yapısı ortak, fakat Netelsan çizimindeki bağlantılar metin çıkarımında okunamadı. Bu yüzden aşağıda Netelsan'a ait iddiaların üst sınırı **Orta (analoji)**dır. (Orta)

## Santral klemens adları
DZL1 (Dış Zil1), DZL2 (Dış Zil2), KPC HP, KPC ŞASİ, KAPI HP, KAPI HP2, KAPI ŞASİ (Yüksek: adlar, Netelsan çizimi). "İç Zil" adı PDF metninde çıkmadı; saha fotoğrafında görülmüştü, dosyalanmadı (Doğrulanmadı). DZL2'nin ikinci kapı zil paneli ortağı olduğu çıkarımdır (Doğrulanmadı). Çizimde ayrıca +15V, −15V, SANTRAL, SİGORTA, KİLİT terminalleri görünüyor; 1/6 güç hattıyla ilişkileri **Doğrulanmadı** (açık soru 5).

## Uçlar (santral ↔ daire şubesi, DT8)
Renk–uç eşlemesi: Simge/Audio analojisi. Burak'ın santral/şube fotoğraflarında renk etiketleri görülmüştü (önceki oturum) ama bu fotoğraflar henüz `field_report` olarak dosyalanmadı, bu yüzden kanıt sayılmıyor (Doğrulanmadı). Netelsan PDF'inden okunamadı. Tüm satırlar "Orta" üst sınırlıdır.

| uç | renk | işlev | sinyal | akım yolu | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|---|---|
| 1 | Kırmızı | Güç hattı; zil paneli fotosel/aydınlatmaya da gider | DC; kutup **Doğrulanmadı** (forumlarda çelişki) | Santral → şubeler paralel → panel 12V/1 | Simge: santral kırmızı LED sönerse tesisatta sorun (genel ifade, uca özgü değil) | Orta (analoji); kutup Doğrulanmadı | src-simge-daire-subesi-2020 |
| 2 | Mavi | Ses/konuşma yolu; tam rol Doğrulanmadı | Doğrulanmadı | Santral ↔ şube | Audio kılavuzu "konuşmada dış kapıda uğultu varsa 2 numaralıyı kontrol et" der; forum tersini söyler (çelişki) | Orta (analoji); tamamlanmadı | src-audio-as202-kilavuz, src-kontrolkalemi-audio-ariza-notlari |
| 3 | Beyaz | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | Audio forum: kopukken "tık-tık", yeşil LED sürekli (tek kaynak) | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 4 | Yeşil | Kapıcı hattı; kapıcısızda bağlanmaz | — | — | — | Orta (analoji: Simge/Audio kapıcısızda kullanılmaz) | src-simge-kapicili-2016, src-audio-as202-kilavuz |
| 5 | Sarı | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | Audio forum: kopukken yeşil LED kısa yanar, ~15 sn bekleme (tek kaynak) | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 6 | Pembe | Güç hattı; zil paneli fotosel/aydınlatma | DC; kutup Doğrulanmadı | Santral → şubeler paralel → panel 12V/6 | Audio forum: kopukken kırmızı LED sönük | Orta (analoji) | src-simge-daire-subesi-2020, src-kontrolkalemi-audio-ariza-notlari |
| 7 | Gri | Kapı otomatiği röle kontağının ucu | Anahtarlanan düşük gerilim AC (harici 12/15 V AC trafo) | Şube kontağı → harici trafo + kilit | Diafon arızalansa da otomatik devresi trafoyla ayrıdır (Audio) | Orta (analoji) | src-simge-daire-subesi-2020, src-audio-as202-kilavuz |
| 8 | Siyah | Kontağın ikinci ucu | aynı | aynı | aynı | Orta (analoji) | aynı |
| ZİL | — | Şubede panel butonu dönüş teli + iç zil butonu teli girişi (Simge/Audio'da **aynı klemens**) | Santral zil ortak ucundan buton kapanınca gelen çağrı; sinyal türü Doğrulanmadı | Dış Zil1 / İç Zil ortağı → buton → daire teli → ZİL | Tek şubede zil çalmıyorsa o dairenin zil teli ve şubesi (Audio) | Orta (analoji); sinyal tamamlanmadı | src-simge-daire-subesi-2020, src-audio-as202-kilavuz |
| K.ZİL | — | Eski kısa zil bağlantısı; yeni sistemlerde kullanılmaz | Doğrulanmadı | Doğrulanmadı | Yanlış bağlanırsa davranış Doğrulanmadı | Yüksek (kullanılmaz notu, Netelsan); davranış tamamlanmadı | src-netelsan-diafon-kapicili-2kapi-r01 |

**Tamamlanmadı:** 2, 3, 5, ZİL (sinyal), K.ZİL (davranış). Eksik belge: Netelsan şube kart şeması.

## Kurulum mantığı
- DT8 santral ↔ şube; zil telleri ayrı: panelden her daireye bir tel, santralden ortak tel (Dış Zil1) ve iç zil için ayrı ortak (İç Zil). Audio'da 0,50 mm² zil teli; Simge DT8 + 0,75 mm² bandajlı kablo. (Orta, analoji)
- Zillere harici zil trafosundan gerilim verilmemeli (Audio). (Orta, analoji)
- Santral kartlarından biri çıkarılır/oturmazsa sistem arızaya geçer. (Yüksek, Netelsan)
- Trafo: 12 daireye kadar 15 V×15 W, üstü 24 V×50 W. Netelsan notu; hangi devreye ait olduğu ve kapıcısız modele uygulanışı çizimden teyit edilmeli. (Orta)
- "Çift zilli" adı dış (panel) ve iç (daire kapısı) zil ayrımını belirtir; iki farklı seste çalındığı Netelsan için Doğrulanmadı.

## Bilinen arızalar
- [fc-zil-capraz-calma-001](../fault-cases/fc-zil-capraz-calma-001.md)

## Açık sorular
1. Netelsan şube kart şeması (2/3/5'in PTT, mikrofon, hoparlörle ilişkisi).
2. Netelsan çiziminde iç zil butonu teli ZİL'e mi K.ZİL'e mi bağlı? diafon1.pdf görsel okunmalı.
3. Dış Zil1 ve İç Zil ortak uçlarının elektrik niteliği (DC/AC/darbe) ve boşta gerilimi: sahada ölçülecek.
4. H.M.SMA.00005 (fotosel notu) yeniden açılıp kaynak kaydı eklenmeli; bu oturumda URL elde yok.
5. Çizimdeki +15V/−15V ve KİLİT terminalleri ile 1/6 hattının ilişkisi.
