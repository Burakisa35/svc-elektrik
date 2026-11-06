---
id: simge-sesli-diafon
type: brand_model
title: Simge sesli diafon (kapısız ve kapıcılı, çift zilli)
status: taslak
updated: 2026-11-07
confidence: Orta
sources: [src-simge-daire-subesi-2020, src-simge-kapicili-2016]
---

## Özet
Netelsan/Audio ile aynı 1-8 + ZİL şube yapısı. Üretici metni uç bağlantısını sözle verdiği için analoji için değerli. Netelsan'a uç olarak taşınmaz. Kayıt geneli Orta: yalnız bağlantı yönergesi var, şube iç devresi ve sinyal türleri yok.

## Uçlar
| uç | renk | işlev | sinyal | akım yolu | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|---|---|
| 1 | Kırmızı | Santral ↔ şube hattı; santral 1 panel 12V/1'e de gider (fotosel) | Doğrulanmadı | Santral → şube; ayrıca panel | — (LED bilgisi uca özgü değil, aşağıya bkz.) | Yüksek (bağlantı), tamamlanmadı (sinyal) | src-simge-daire-subesi-2020 |
| 2 | Mavi | Santral ↔ şube hattı | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | tamamlanmadı | aynı |
| 3 | Beyaz | Santral ↔ şube hattı | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | tamamlanmadı | aynı |
| 4 | Yeşil | Kapıcı; kapıcısızda hiçbir şekilde kullanılmaz | — | — | — | Yüksek | src-simge-kapicili-2016 |
| 5 | Sarı | Santral ↔ şube hattı | Doğrulanmadı | Doğrulanmadı | Doğrulanmadı | tamamlanmadı | src-simge-daire-subesi-2020 |
| 6 | Pembe | Santral ↔ şube hattı; santral 6 panel 12V/6'ya da gider | Doğrulanmadı | Santral → şube; panel | — (LED bilgisi uca özgü değil, aşağıya bkz.) | Yüksek (bağlantı), tamamlanmadı (sinyal) | aynı |
| 7 / 8 | Gri / Siyah | Kapı otomatiği: harici 12/15 V AC trafonun bir ucu şubede 8'e, otomatiğin diğer ucu şubede 7'ye | AC, anahtarlanan | Şube kontağı → trafo → kilit | — | Yüksek | aynı |
| ZİL | — | Panel butonunun boşta ucu ve iç zil butonunun boşta ucu **şubenin Zil bölümüne** | Doğrulanmadı | Santral Dış Zil1 / İç Zil → buton → şube ZİL | — | Yüksek (bağlantı), tamamlanmadı (sinyal) | aynı |

Diğer üretici ifadeleri: santral Dış Zil1 → zil panelinin ortak ucu; Genel LED anlamı (uca özgü değil): kırmızı+yeşil yanarsa sistem sağlam, yeşil sönerse 500 mA sigorta; DT8 + 0,75 mm² bandajlı kablo önerisi. (Yüksek)

## Açık sorular
Şube iç devresi (ZİL girişi yapısı) ve 2/3/5 işlevleri yayımlanmamış.
