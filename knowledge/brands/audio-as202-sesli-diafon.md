---
id: audio-as202-sesli-diafon
type: brand_model
title: Audio AS-202 / 8+nD sesli diafon (kapıcısız çift zilli)
status: taslak
updated: 2026-11-07
confidence: Orta
sources: [src-audio-as202-kilavuz, src-audio-8nd-diafoncu, src-kontrolkalemi-audio-ariza-notlari, src-simge-daire-subesi-2020]
---

## Özet
Netelsan ile aynı yapı. Elektriksel prensip karşılaştırması için referans; Netelsan'a **uç olarak taşınmaz**. Kayıt genel güveni Orta çünkü uç 3, 5 ve birçok belirti tek forum kaynaklı.

## Santral klemensleri
| klemens | görev | güven | kaynak |
|---|---|---|---|
| 14-15 | Kapı hoparlör hattı, ekranlı kablo zorunlu | Yüksek | src-audio-as202-kilavuz |
| 16 | İç zil ortağı | Yüksek | aynı |
| 17 | Dış zil ortağı | Yüksek | aynı |
| 18-19 | Kapıcı hoparlör | Doğrulanmadı (bu oturumda metinde teyit edilemedi) | src-audio-8nd-diafoncu |
| 11-12 | Kapı otomatiği testi: değdirince açılıyorsa sistem arızasız | Orta (forum arıza listesi) | src-kontrolkalemi-audio-ariza-notlari |

## Uçlar (DT8, şube)
| uç | renk | işlev | sinyal | akım yolu | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|---|---|
| 1 | Kırmızı | Güç | DC; kutup Doğrulanmadı (forumlarda çelişkili) | Santral → şubeler → panel fotosel | 1-6 kısa devre kontrolü kılavuzda "hiç çalışmıyor" başlığında; LED sönmesi Simge/forumdan | Orta | src-audio-as202-kilavuz, src-simge-daire-subesi-2020 |
| 2 | Mavi | Ses/konuşma hattı | Doğrulanmadı | Santral ↔ şube | Kılavuz: "hiç ses yok" için 1-2 arası kısa devre kontrolü; "konuşmada kapıda uğultu varsa 2 kopuk olabilir". Forum tablosu bunun tersini yazar (çelişki) | Orta; tamamlanmadı | src-audio-as202-kilavuz, src-kontrolkalemi-audio-ariza-notlari |
| 3 | Beyaz | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | Forum: kopukken tık-tık, yeşil LED sürekli | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 4 | Yeşil | Kapıcı; kapıcısızda bağlanmaz | — | — | — | Yüksek | src-audio-as202-kilavuz |
| 5 | Sarı | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | Forum: kopukken yeşil LED kısa, ~15 sn bekleme | tamamlanmadı | src-kontrolkalemi-audio-ariza-notlari |
| 6 | Pembe | Güç | DC; kutup Doğrulanmadı | Santral → şubeler → panel | Forum: kopukken kırmızı LED sönük | Orta | src-kontrolkalemi-audio-ariza-notlari |
| 7 Gri / 8 Siyah | | Kapı otomatiği kuru kontağı: gri → harici trafo, siyah → kilit | Anahtarlanan düşük gerilim AC | Şube kontağı → trafo → kilit | Diafon arızalansa da otomatik çalışır | Yüksek | src-audio-as202-kilavuz |
| ZİL (şube klemens 10) | | Panel zil teli ile iç zil butonu teli **birleştirilip** 10'a | Zil ortağından buton kapanınca gelen çağrı | Ortak → buton → daire teli → şube | Tek şubede çalmıyorsa o dairenin zil teli/şubesi | Yüksek | src-audio-as202-kilavuz |

Çelişki: forumlarda polarite bir yerde "1 +, 6 −", başka yerde tersi yazılı; kılavuz polarite vermiyor.

## Kurulum mantığı
- Panelden her daireye ayrı 0,50 mm² zil teli; santralden tek ortak tel (17), iç zil için ortak (16). (Yüksek)
- Sistem zilliyse daire önü butonları ışıklı olmamalı. (Orta, tek kaynak)
- Zil ortak uçlarına harici gerilim karışmış olabilir: 16-17'yi sökerek kontrol. (Yüksek)
- Sigorta: kılavuz 500 mA; forumda 200 mA geçiyor, model farkı Doğrulanmadı.

## Açık sorular
- Beyaz ve sarı hattın işlevi Audio'da da belgelenmemiş.
