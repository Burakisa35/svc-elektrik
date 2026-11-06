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
Santral (DT8 ile şubelere) + zil paneli + daire şubeleri. Konuşma bas-konuş/bırak-dinle (yarı çift yönlü). Zil için DT8 dışında ayrı zil telleri çekilir: panel butonundan her daireye bir dönüş teli, ortak uç santralde. "Çift zilli": dış (panel) ve iç (daire kapısı butonu) farklı seste çalar. Kapı otomatiği şube üzerindeki röle kontağıyla açılır (harici trafo, sistem dışı). (Yüksek: Netelsan, Audio, Simge şemaları)

Uyarı: Bu dosyadaki Netelsan satırlarının önemli kısmı Audio/Simge kılavuzlarından **analojiyle** gelir (aynı 1-8 + ZİL şube yapısı). Netelsan'ın kendi çizimi metin çıkarımında okunamadı; doğrudan teyit için görsel okuma gerekir (açık sorular).

## Santral klemens adları (Netelsan şemasından)
DZL1 (Dış Zil1), DZL2 (Dış Zil2; iki kapı seçmeli sistemde 2. zil paneli ortağı, Orta), İç Zil, KPC HP / KPC ŞASİ (kapıcı hoparlör), KAPI HP / KAPI HP2 / KAPI ŞASİ (kapı hoparlörü), KİLİT, 1-8 (DT8). (Yüksek: adlar; Orta: DZL2 rolü)

## Uçlar (santral ↔ daire şubesi, DT8)

| uç | renk | işlev | sinyal | akım yolu | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|---|---|
| 1 | Kırmızı | Güç hattı; zil panelindeki fotosel/aydınlatmaya da gider | DC, kutup: Audio forumunda 1 = +, 6 = −; gerilim değeri ölçülmedi | Santral → tüm şubeler paralel → zil paneli 12V/1 | Bir dairede kopuksa o şube çalışmaz; 1-6 kısa devre → santral kırmızı LED söner/koruma (Audio/Simge) | Orta (analoji) | src-simge-daire-subesi-2020, src-kontrolkalemi-audio-ariza-notlari |
| 2 | Mavi | Ses/konuşma yolu (santral amfisi ↔ şube); tam rol **Doğrulanmadı** | Ses + kontrol; DC/AC ayrımı Doğrulanmadı | Santral → şube | Kopuksa: konuşma basılınca dış kapıda uğultu, daireye ses gitmez (Audio) | Orta (analoji) | src-audio-as202-kilavuz |
| 3 | Beyaz | **Doğrulanmadı** | Doğrulanmadı | Doğrulanmadı | Kopuksa: "tık-tık", yeşil LED sürekli yanık (Audio, tek kaynak) | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 4 | Yeşil | Kapıcı hattı; kapıcısızda **bağlanmaz** | — | — | — | Yüksek | src-simge-kapicili-2016, src-audio-as202-kilavuz |
| 5 | Sarı | **Doğrulanmadı** | Doğrulanmadı | Doğrulanmadı | Kopuksa: yeşil LED kısa yanıp söner, yeniden basmak için ~15 sn beklemek gerekir (Audio, tek kaynak) | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 6 | Pembe | Güç hattı (−); zil paneli fotosel/aydınlatma | DC | Santral → şubeler paralel → panel 12V/6 | Kopuksa: kırmızı LED sönük yanar (Audio forum) | Orta (analoji) | src-simge-daire-subesi-2020, src-kontrolkalemi-audio-ariza-notlari |
| 7 | Gri | Kapı otomatiği röle kontağı ucu (kuru kontak) | Anahtarlanan AC (harici 12/15 V AC trafo) | Şube kontağı → kilit/trafo devresi | Sistem arızalansa bile kapı otomatiği devresi trafoyla ayrıdır | Yüksek (kontak); sıra markaya göre değişir | src-simge-daire-subesi-2020, src-audio-as202-kilavuz |
| 8 | Siyah | 7 ile birlikte kontağın ikinci ucu | aynı | aynı | aynı | Yüksek | aynı |
| ZİL | — | Şubede dış zil panel butonu dönüş telinin ve iç zil butonu telinin geldiği giriş (Simge/Audio'da **ikisi aynı klemense**) | Santral zil ortak uçlarından (Dış Zil1 / İç Zil) buton kapanınca gelen çağrı; sinyal türü Doğrulanmadı | Santral ortak uç → buton → daire telinin ZİL girişi | Tek şubede zil çalmıyorsa o dairenin zil teli ve şube kontrol edilir (Audio). Zil ortak uçlarına harici voltaj girmesi zilleri bozar | Yüksek (Simge/Audio); Netelsan için Orta (analoji) | src-simge-daire-subesi-2020, src-audio-as202-kilavuz |
| K.ZİL | — | Eski kısa zil bağlantısı; yeni sistemlerde kullanılmaz | Doğrulanmadı | Doğrulanmadı | Yanlış tele bağlanırsa davranışı Doğrulanmadı | Yüksek (kullanılmaz notu); davranış tamamlanmadı | src-netelsan-diafon-kapicili-2kapi-r01 |

**Tamamlanmadı satırlar:** 2 (kısmen), 3, 5, ZİL (sinyal türü), K.ZİL (davranış). Eksik belge: Netelsan şube kart şeması.

## Kurulum mantığı
- DT8 (8 damar) santral ↔ şubeler arası, renk renge. Zil telleri ayrı: panelden her daireye bir tel (Audio: 0,50 mm²; Simge: DT8 + 0,75 mm² bandajlı kablo önerir). (Yüksek: Audio/Simge)
- Santralden zil panelinin ortak ucuna tek ortak tel; iç zil için ayrı ortak tel (Audio: 16 iç, 17 dış). (Yüksek: Audio)
- Kapı hoparlör hattı (Audio 14-15) ekranlı. (Yüksek: Audio)
- Zillere harici zil trafosundan gerilim verilmemeli. (Yüksek: Audio)
- Santral kartlarından biri çıkarılır/oturmazsa sistem arızaya geçer. (Yüksek: Netelsan notu)
- Kilit trafosu: 12 daireye kadar 15 V × 15 W, üstü 24 V × 50 W. (Yüksek: Netelsan notu; hangi devreye ait olduğu çizimden teyit edilmeli)

## Bilinen arızalar
- [fc-zil-capraz-calma-001](../fault-cases/fc-zil-capraz-calma-001.md)

## Açık sorular
1. Netelsan şube kart şeması (2/3/5'in PTT, mikrofon, hoparlörle ilişkisi). Aranan yer: Netelsan servis, kart fotoğrafı + iz sürme.
2. Netelsan çiziminde iç zil butonu teli ZİL'e mi, K.ZİL'e mi bağlı? Çizim görsel okunmalı (diafon1.pdf).
3. Dış Zil1 ve İç Zil ortak uçlarının elektrik niteliği (DC/AC/darbe) ve boşta gerilimi: sahada ölçülecek.
4. H.M.SMA.00005 şeması yeniden açılıp 1/6 fotosel notu doğrulanmalı (önceki oturumdan Orta).
