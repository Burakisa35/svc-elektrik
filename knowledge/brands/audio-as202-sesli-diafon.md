---
id: audio-as202-sesli-diafon
type: brand_model
title: Audio AS-202 / 8+nD sesli diafon (kapıcısız çift zilli)
status: taslak
updated: 2026-11-07
confidence: Yüksek
sources: [src-audio-as202-kilavuz, src-audio-8nd-diafoncu, src-kontrolkalemi-audio-ariza-notlari]
---

## Özet
Netelsan ile aynı yapı: santral + DT8 + zil paneli + şube. Elektriksel prensip karşılaştırması için en iyi belgelenmiş referans. Netelsan'a **uç olarak taşınmaz**, yalnız analoji.

## Santral klemensleri (kılavuzdan)
| klemens | görev | güven | kaynak |
|---|---|---|---|
| 14-15 | Kapı hoparlör hattı, ekranlı kablo zorunlu | Yüksek | src-audio-as202-kilavuz |
| 16 | İç zil ortağı (daire önü iç zil butonlarının ortak teli) | Yüksek | aynı |
| 17 | Dış zil ortağı (zil panelinin ortak ucu) | Yüksek | aynı |
| 18-19 | Kapıcı hoparlör (kapıcılı sistem) | Yüksek | src-audio-8nd-diafoncu |
| 11-12 | Merdiven/kapı otomatiği test ucu (arıza notu: bu ikisini değdirince kapı açılıyorsa sistem arızasız) | Orta | src-kontrolkalemi-audio-ariza-notlari |

## Uçlar (DT8, şube)
| uç | renk | işlev | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|
| 1 | Kırmızı | Güç (+) | Kopuk: o şube çalışmaz. 1-6 kısa devre: santral kırmızı LED söner | Yüksek (kısa devre kontrolü); Orta (kutup) | src-audio-as202-kilavuz, src-kontrolkalemi-audio-ariza-notlari |
| 2 | Mavi | Ses/konuşma hattı | Kopuk: uğultu dış kapıda, daireye ses yok. 1-2 kısa devre: ses yok | Yüksek (belirti) / Doğrulanmadı (sinyal türü) | src-audio-as202-kilavuz |
| 3 | Beyaz | Doğrulanmadı | Kopuk: tık-tık, yeşil LED sürekli | Orta (belirti) | src-kontrolkalemi-audio-ariza-notlari |
| 4 | Yeşil | Kapıcı; kapıcısızda bağlanmaz | — | Yüksek | src-audio-as202-kilavuz |
| 5 | Sarı | Doğrulanmadı | Kopuk: yeşil LED kısa, ~15 sn bekleme | Orta (belirti, tek kaynak) | src-kontrolkalemi-audio-ariza-notlari |
| 6 | Pembe | Güç (−) | Kopuk: kırmızı LED sönük | Orta | src-kontrolkalemi-audio-ariza-notlari |
| 7 Gri / 8 Siyah | | Kapı otomatiği kuru kontağı: gri → harici trafo, siyah → kilit | Diafon arızalansa da kapı otomatiği çalışır | Yüksek | src-audio-as202-kilavuz |
| ZİL (şube klemens 10) | | Panel zil teli ile iç zil butonu teli **birleştirilip** 10 numaralı klemense | Tek şubede çalmıyorsa o dairenin zil teli/şubesi | Yüksek | src-audio-as202-kilavuz |

## Kurulum mantığı
- Zil paneli → her daireye ayrı 0,50 mm² zil teli; santralden boydan boya tek ortak tel (17). İç zil: tek ortak tel (16). (Yüksek)
- Sistem zilliyse daire önü butonları ışıklı olmamalı. (Orta: forum notu, tek kaynak)
- Zillere harici trafo gerilimi verilmemeli; "zil ortak uçlarına voltaj karışmış olabilir, 16-17'yi sökün". (Yüksek: kılavuz)
- Santral LED'leri ve sigorta: kılavuz 500 mA; forumda 200 mA geçiyor, model farkı Doğrulanmadı.

## Açık sorular
- Beyaz ve sarı hattın işlevi Audio'da da belgelenmemiş.
