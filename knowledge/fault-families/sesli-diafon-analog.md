---
id: ff-sesli-diafon-analog
type: fault_family
title: Analog sesli diafon — arıza aileleri ve soru parametreleri
brands: [netelsan, audio, simge]
confidence: Orta
status: taslak
updated: 2026-11-07
---

Amaç: sahada belirti → aile → ayırt edici sorular → ilgili vaka/hipotez eşlemesi. Aile **belirti sınıfıdır**, neden değildir; nedenler H-numaralı hipotezlerle vaka dosyalarında tutulur. Bu dosyadaki aile listesi taksonomidir (yapı kararı); "Kaynak" sütunu ailenin belirtisinin kayıtlı olduğu yerleri gösterir, nedenini kanıtlamaz.

## Aileler

| Kod | Belirti sınıfı | Kayıtlı olduğu yerler | Marka kaydı | Açık vaka |
|---|---|---|---|---|
| **F1** | Çapraz çalma: bir daireye basınca başka daire(ler) de çalıyor | src-kontrolkalemi-netelsan-ariza-2021, src-kontrolkalemi-audio-ariza-notlari, src-yoreparo-commax-8 (analoji), src-elektrikforum-siedle-coklu-calma-2019 (analoji) | Netelsan, Audio, (Commax, Siedle analoji) | fc-zil-capraz-calma-001 |
| **F2** | Çağrı yok: bir dairenin zili çalmıyor, diğerleri çalıyor | src-siedle-servicehandbuch (analoji), src-golmar-4n-kurulum (analoji) | Yalnız analoji | yok |
| **F3** | Sürekli/kendiliğinden çalma (dış zil durmadan) | src-kontrolkalemi-netelsan-ariza-2021 | Netelsan | yok (F1 vakasıyla aynı kaynakta geçiyor) |
| **F4** | Konuşma yok / tek yön / zayıf ses | src-audio-as202-kilavuz (arıza tablosu) | Audio | yok. Kayıttaki tablo F4'e eşlenmedi: yeniden okunmalı (**Doğrulanmadı**) |
| **F5** | Kapı açılmıyor | src-audio-as202-kilavuz, src-simge-daire-subesi-2020 (7/8 kuru kontak) | Audio, Simge | yok |
| **F6** | Sistem tümüyle ölü / düşük gerilim | src-golmar-4n-kurulum, src-siedle-servicehandbuch (analoji), src-netelsan-diafon1-kapicisiz-cift-zilli (trafo notu) | Netelsan (trafo seçimi), analoji | yok |
| **F7** | Vızıltı, ıslık, uğultu | src-tektone-buzzing (analoji), src-audio-as202-kilavuz | Audio, analoji | yok |

Her ailenin içeriği (nedenler, test sırası) yalnız bir vaka dosyası açıldığında doldurulur. Vakasız ailede neden listesi **yazılmaz** (tahminle doldurma yasağı).

## Soru parametreleri

Cevap önceden tanımlı seçimdir; seçim, hangi hipotezlerin canlı kaldığını değiştirir. Kimlikler kalıcıdır (Code bunları kayıtlarda kullanır; yeniden numaralanmaz).

| Kod | Soru | Cevap türü | Ne ayırır | Etiket |
|---|---|---|---|---|
| **Q-KAPSAM** | Kaç daire etkileniyor? | tek / şaft grubu / tümü | Ortak kısım mı (santral, trafo, ortak tel) tek daire kolu mu | Orta (Siedle servis el kitabı ve Golmar kılavuzu "tümü etkilenir → ortak kısım" mantığıyla uyumlu; Netelsan için doğrudan kaynak yok) |
| **Q-TETIK** | Hangi butonlara basınca sorun oluyor? | panel butonu / iç zil butonu / bas-konuş / kendiliğinden | Panel zil hattı mı, iç zil hattı mı | Doğrulanmadı (yöntem, kaynak yok; fc-zil-capraz-calma-001 S2-S4 ile gerekçeli) |
| **Q-YON** | Çapraz çalma tek yönlü mü, karşılıklı mı? | tek yön / karşılıklı | Diyot/yarı iletken yolu mu, simetrik kaçak mı | Doğrulanmadı |
| **Q-DEGISIM** | Bir daireyi devre dışı bırakınca (kendisi dışında) çalanlar değişti mi? | evet / hayır / denenmedi | Kaynak mı kurban mı (fc-zil-capraz-calma-001 adım 1) | Doğrulanmadı |
| **Q-ONCESI** | Arıza öncesi ne yapıldı (tadilat, daire telefonu değişimi, kablo işi)? | serbest + tarih | Zamansal tetik; Siedle ve STR forumlarında tadilat/çivileme şüphesi | Doğrulanmadı (forum yorumu) |
| **Q-ISIK** | Butonlarda ışık/LED var mı? | var / yok | H4 | Doğrulanmadı |
| **Q-HAVA** | Nem/yağmur/soğuk ile ilişki var mı? | var / yok / bilinmiyor | Nem kaynaklı kaçak | Doğrulanmadı (yalnız SEO yazılarında geçiyor, kaynak olarak kullanılmadı) |

## Çözüm kaydı ile bağ

Ailenin, sorunun ve hipotezin kimlikleri uygulamadaki çözüm kayıtlarına bağlanır (sözlük `_SPEC.md` "Çözüm kaydı sözlüğü"). Bir ailenin tanısı kaydedilen sonuçlarla doğrulanana kadar bu dosyadaki güven etiketi **Orta**'yı geçmez.
