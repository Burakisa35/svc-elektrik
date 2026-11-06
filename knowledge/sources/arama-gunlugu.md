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

Henüz taranmayan: PL, RU, DE, IT sorguları; Netelsan H.M.SMA.00005 yeniden açılması; Netelsan şube kart şeması (aranmadı).

## Oturum 2 (2026-11-07) — Tier-1 kapanış + çok dilli tarama

| Sorgu amacı | Dil | Sonuç |
|---|---|---|
| Netelsan şube kart şeması (3 sorgu) | tr | **Bulunamadı.** Yalnız montaj bağlantı şemaları (diafon1-4, nextel5), kod çözücü, garanti belgesi çıktı. Durma kuralı (3 sorguda yeni bilgi yok) uygulandı |
| H.M.SMA.00005 | tr | **Bulunamadı** (netelsan.com.tr/sema/diafon listesinde diafon santral şemaları var, SMA.00005 görünmüyor) |
| Daire içi bas-konuş devre şeması/tamir | tr | Bulunamadı; Kontrol Kalemi 2021 konusu zaten kayıtlı |
| Çapraz çalma, PL | pl | Eşleşen vaka yok (elektroda #3796225 gibi sonuçlar kod/hat karışması, kök neden yok); SEO yazıları kullanılmadı |
| Çapraz çalma, RU | ru | Koordinat/dijital sistem adresleme vakaları (Vizit/Cyfral); paralel hatlı analog çağrı teli ile eşleşmiyor. Bağlantı kaydı alınmadı |
| Çapraz çalma, DE | de | 3 kullanılabilir kayıt + Siedle servis el kitabı (src-siedle-*, src-elektrikforum-*, src-mikrocontroller-*, src-elektrikforen-*) |
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
Henüz taranmayan: IT, FR.
