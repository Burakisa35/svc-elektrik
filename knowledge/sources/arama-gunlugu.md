---
id: arama-gunlugu
type: log
title: Arama günlüğü
updated: 2026-11-07
---

Importer bu dosyayı atlar (`type: log`).

## Oturum 1 (2026-11-07) — Brief 001, S1-S3

| Sorgu amacı | Dil | Sonuç |
|---|---|---|
| Netelsan sesli diafon şube/santral şeması | tr | Netelsan bağlantı şemaları bulundu (diafon1-4.pdf, R01); metin çıkarımı çizimi vermiyor |
| Audio AS-202 kılavuz, DT8 | tr | Üretici kılavuz + arıza tablosu bulundu |
| Simge şube bağlantı | tr | Simge PDF'leri bulundu (ZİL klemensi, 7/8, 1/6) |
| Panelden basınca başka daire çalıyor | en | Doğrudan eşleşen çözümlü vaka yok; tipik ilgili sonuçlar crosstalk/ses sızıntısı |
| Aynı belirti | tr | 3 vaka (Netelsan 2021, DonanımHaber 2016, Audio notları s.19); hiçbirinde kök neden yazılı |
| Aynı belirti, ES (YoReparo) | es | Çözümlü Commax vakası bulundu |

### Kullanılan sorgu metinleri
- `Netelsan sesli diafon daire şubesi bağlantı şeması santral klemens zil iç zil dış zil`
- `Audio Elektronik AS-202 sesli diafon santral kılavuzu DT8 kablo daire şubesi bağlantı`
- `Simge diafon sesli santral daire şube bağlantı şeması zil kablosu`
- `intercom pressing one apartment button rings other apartments bell wires crosstalk fault cause`
- `diafon bir daireye basınca diğer daireler çalıyor zil çapraz çalma arıza sebebi`
- `Commax 8 phone porter rings in 2 departments` (YoReparo, es sayfası; sorgu metni özet olarak kaydedildi)
- Araç rehberleri: `Claude Code memory CLAUDE.md best practices ...`, `Supabase row level security best practices migrations ...`, `Vercel environment variables preview production ...`

Netelsan şube kart şeması için ayrı bir sorgu yapılmadı; Netelsan teknik belgelerinde yalnız montaj bağlantı şemaları göründü. Kart şeması "bulunamadı" değil, **aranmadı**: Tier-1 turu 2'de aranacak. H.M.SMA.00005 şeması önceki oturumdan; URL elde olmadığı için kaynak kaydı yok.

Bu satır Oturum 2'de kısmen değişti: PL/RU/DE birer sorguyla soruldu (aşağıya bak), kart şeması yetersiz arandı. Henüz taranmayan: IT, FR; Netelsan H.M.SMA.00005 belgesinin kendisi; kart şeması (yetersiz arandı).

## Oturum 2 (2026-11-07) — Tier-1 kapanış + çok dilli tarama

| Sorgu amacı | Dil | Sonuç |
|---|---|---|
| Netelsan şube kart şeması (1 sorgu, **tahmini** parça numarasıyla) | tr | Sonuç yok: yalnız montaj bağlantı şemaları (diafon1-4, nextel5), kod çözücü, garanti belgesi çıktı. **Kart şeması yeterince aranmadı** (tahmini numara geçerli kanıt değil); açık kalem |
| H.M.SMA.00005 (1 sorgu) | tr | Bulunamadı: netelsan.com.tr/sema/diafon listesinde santral şemaları var, SMA.00005 görünmüyor |
| Daire içi bas-konuş devre şeması/tamir (1 sorgu) | tr | Yeni kaynak yok; Kontrol Kalemi 2021 konusu zaten kayıtlı |
| Çapraz çalma, PL (1 sorgu, sınırlı) | pl | 1 ilgili forum konusu: Elektroda #3796225, tek yönlü çapraz çalma, çözüm arama özetinde yok → `src-elektroda-domofon-7-16-2021`. SEO yazıları kullanılmadı; diğer Elektroda konuları açılıp incelenmedi |
| Çapraz çalma, RU (1 sorgu, sınırlı) | ru | Koordinat/dijital sistem adresleme vakaları (Vizit/Cyfral); paralel hatlı analog çağrı teli ile eşleşmiyor. Kaynak kaydı alınmadı |
| Çapraz çalma, DE (1 sorgu) | de | 3 forum kaydı + Siedle servis el kitabı (src-siedle-*, src-elektrikforum-*, src-mikrocontroller-*, src-elektrikforen-*; sonuncusunun içeriği doğrulanamadı) |
| 4+N Fermax/Golmar | en/es | Üretici belgeleri: src-golmar-4n-kurulum, src-fermax-citymax-4n-semalar |
| 2 telli BUS | en/de | Bticino, Fermax BUS2, Hager Elcom bulundu; **Tier-2 işi, henüz kaynak kaydı açılmadı** |

Sorgu metinleri:
- `Netelsan diafon şube kart şeması H.E.PCB.01032 devre şeması servis kılavuzu`
- `Netelsan H.M.SMA.00005 sesli diafon daire şubesi bağlantı şeması fotosel 1 6`
- `Netelsan sesli diafon daire telefonu iç devre şeması bas konuş butonu mikrofon hoparlör devre elemanları tamir`
- `domofon dzwoni w innych mieszkaniach po naciśnięciu przycisku jednego lokalu przyczyna usterka przewody dzwonka`
- `домофон при нажатии на кнопку квартиры звонят другие квартиры причина неисправность общий провод`
- `Klingelanlage Türsprechanlage Klingeltaster betätigt mehrere Wohnungen klingeln Fehlersuche Nebenschluss Ader Ursache`
- `Fermax Golmar 4+n intercom wiring terminals common call wire per apartment fault finding manual`
- `two-wire BUS door entry system principle address coding cabling limits troubleshooting manufacturer technical manual audio`

Not: "H.E.PCB.01032" sorgudaki parça numarası tahminidir, kaynaktan alınmadı; sonuç vermedi.
Henüz taranmayan: IT, FR; PL/RU/DE yalnız birer sorguyla soruldu (sınırlı kapsam).
