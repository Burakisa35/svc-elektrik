---
id: ff-sesli-diafon-analog
type: fault_family
title: Analog sesli diafon — arıza aileleri ve soru parametreleri
brands: [netelsan, audio, simge]
confidence: Doğrulanmadı
status: taslak
updated: 2026-11-07
---

Amaç: sahada belirti → aile → ayırt edici sorular → ilgili vaka/hipotez eşlemesi. Aile **belirti sınıfıdır**, neden değildir; nedenler H-numaralı hipotezlerle vaka dosyalarında tutulur. Bu dosyadaki aile listesi taksonomidir (yapı kararı); "Kaynak" sütunu ailenin belirtisinin kayıtlı olduğu yerleri gösterir, nedenini kanıtlamaz.

## Aileler

| Kod | Belirti sınıfı | Kayıtlı olduğu yerler | Marka kaydı | Açık vaka | Etiket |
|---|---|---|---|---|---|
| **F1** | Çapraz çalma: bir daireye basınca başka daire(ler) de çalıyor | src-kontrolkalemi-netelsan-ariza-2021, src-yoreparo-commax-8 (analoji), src-elektrikforum-siedle-coklu-calma-2019 (analoji), src-elektroda-domofon-7-16-2021 (sistem bilinmiyor) | Netelsan (1 forum), diğerleri analoji. Audio notlarındaki ilgili vaka (Oturum 1 günlüğü) kaynak kaydında yazılı değil → F1'e Audio **yazılmadı** | fc-zil-capraz-calma-001 | Orta (dört bağımsız forum bildirimi; hepsi çözümsüz ya da tek vaka) |
| **F2** | Çağrı yok: bir dairenin zili çalmıyor, diğerleri çalıyor | src-siedle-servicehandbuch (analoji, aynı telefonun iletkenleri), src-golmar-4n-kurulum (analoji, CP adımı yalnız Stadio Plus) | Yalnız analoji | yok | Orta (üretici belgesi, ama başka marka) |
| **F3** | Sürekli çalma: dış zil bağlanınca birkaç daire durmadan çalıyor | src-kontrolkalemi-netelsan-ariza-2021 (konu sahibi bildirimi) | Netelsan (tek forum, çözümsüz) | yok | Doğrulanmadı |
| **F4** | Konuşma yok / tek yön / zayıf ses | knowledge/brands/audio-as202-sesli-diafon.md (uç 2: ses yokluğunda 1-2 arası kısa devre kontrolü, marka dosyasında Orta), src-fermax-citymax-4n-semalar (analoji: ses sorunu genelde kablo kesiti yetersizliği) | Audio, analoji | yok | Doğrulanmadı |
| **F5** | Kapı açılmıyor | src-simge-daire-subesi-2020 (7/8 kuru kontak). Audio için kayıtta yazılı satır yok | Simge | yok | Doğrulanmadı |
| **F6** | Sistem tümüyle ölü / düşük gerilim | src-golmar-4n-kurulum (TF-104 SEC 12-17 V AC; aralık dışıysa trafoyu ayırıp tekrar ölç), src-siedle-servicehandbuch (tüm telefonlar ölü → gerilim 24 V DC altı; analoji), src-netelsan-diafon1-kapicisiz-cift-zilli (trafo seçim notu) | Netelsan (yalnız trafo notu), analoji | yok | Orta (iki üretici belgesi, başka marka) |
| **F7** | Uğultu / vızıltı | knowledge/brands/audio-as202-sesli-diafon.md (uç 2: "konuşmada kapıda uğultu varsa 2 kopuk olabilir", marka dosyasında Orta ve çelişkili), src-tektone-buzzing (analoji) | Audio, analoji | yok | Doğrulanmadı |

Etiketler ailenin **belirtisinin** kayıtlı olduğunu söyler, nedenini kanıtlamaz. F1-F3 dışındaki ailelerde kaynaklar başka marka ya da marka dosyasındaki tek satırdır.

Her ailenin içeriği (nedenler, test sırası) yalnız bir vaka dosyası açıldığında doldurulur. Vakasız ailede neden listesi **yazılmaz** (tahminle doldurma yasağı).

## Soru parametreleri

Cevap önceden tanımlı seçimdir; seçim, hangi hipotezlerin canlı kaldığını değiştirir. Kimlikler kalıcıdır (Code bunları kayıtlarda kullanır; yeniden numaralanmaz).

| Kod | Soru | Cevap türü | Ne ayırır | Etiket |
|---|---|---|---|---|
| **Q-KAPSAM** | Kaç daire etkileniyor? | tek / şaft grubu / tümü | Ortak kısım mı (santral, trafo, ortak tel) tek daire kolu mu | Orta yalnız "tümü ölü → ortak besleme" yönü için (Siedle: 24 V altı gerilim; Golmar: trafo çıkışı). "Şaft grubu" seçeneği ve çapraz çalma için kaynak yok: Doğrulanmadı |
| **Q-TETIK** | Hangi butonlara basınca sorun oluyor? | panel butonu / iç zil butonu / bas-konuş / kendiliğinden | Panel zil hattı mı, iç zil hattı mı | Doğrulanmadı (yöntem, kaynak yok; fc-zil-capraz-calma-001 S2-S4 ile gerekçeli) |
| **Q-YON** | Çapraz çalma tek yönlü mü, karşılıklı mı? | tek yön / karşılıklı | Diyot/yarı iletken yolu mu, simetrik kaçak mı | Doğrulanmadı (tek yönlü örnek var: src-elektroda-domofon-7-16-2021, sistem bilinmiyor, mekanizma kanıtı yok) |
| **Q-DEGISIM** | Bir daireyi devre dışı bırakınca (kendisi dışında) çalanlar değişti mi? | evet / hayır / denenmedi | Kaynak mı kurban mı (fc-zil-capraz-calma-001 adım 1) | Doğrulanmadı |
| **Q-ONCESI** | Arıza öncesi ne yapıldı (tadilat, daire telefonu değişimi, kablo işi)? | serbest + tarih | Zamansal tetik. STR forumunda çivileme şüphesi; Siedle forumunda zamanla bozulan bükme-bantlı ekler | Doğrulanmadı (forum yorumu) |
| **Q-ISIK** | Butonlarda ışık/LED var mı? | var / yok | H4 | Doğrulanmadı |
| **Q-HAVA** | Nem/yağmur/soğuk ile ilişki var mı? | var / yok / bilinmiyor | Nem kaynaklı kaçak | Doğrulanmadı (yalnız SEO yazılarında geçiyor, kaynak olarak kullanılmadı) |

## Çözüm kaydı ile bağ

Ailenin, sorunun ve hipotezin kimlikleri uygulamadaki çözüm kayıtlarına bağlanır (sözlük `_SPEC.md` "Çözüm kaydı sözlüğü"). Bir ailenin tanısı kaydedilen sonuçlarla doğrulanana kadar bu dosyadaki güven etiketi **Orta**'yı geçmez.
