# Teşhis protokolü (Claude Code'un kendi aracı)

**Ne zaman:** bir belirti gördüğümde. Örnekler: araç hatası, zaman aşımı, kırmızı test, beklenmeyen canlı değer, "çalışıyor" sandığım bir şeyin çalışmaması.
**Neden var:** 2026-11-07'de "soru yalnız DROP'ta çıkar" varsayımını ölçmeden kesin saydım ve bir uygulama turu boşa gitti (T-001).

**Saha kuralı:** belirti, olası neden, doğrulama yöntemi ve önleyici çözüm ayrı yazılır. Ölçülmeyen neden ne DOĞRULANDI ne ELENDİ olur, ADAY kalır. Bunu `node araclar/teshis.mjs` denetler, `dogrula.sh` de çağırır.

## Dört yöntemin bende karşılığı

| Yöntem | Sorduğum soru | Kayıtta zorunlu biçimi |
|---|---|---|
| RCA | Görünen şey arıza mı, yoksa başka bir arızanın sonucu mu? Asıl arızayı hangi ölçüm gösterir? | "Olası nedenler" tablosu: her neden ADAY / DOĞRULANDI / ELENDİ ve ölçümü |
| 5 Neden | Bu neden oldu, onun nedeni ne? | Numaralı zincir; her halkada `test:` (o halkayı neyin çürütebileceği) |
| Ishikawa | Hangi bağımsız etkenler buna yol açabilir? | 6 dal: İnsan, Araç, Yöntem, Girdi, Ölçüm, Ortam. En az 4'ü dolu (tek dala saplanmayı engeller) |
| FMEA | Hangi olası hata en riskli, önce hangisini doğrulamalı/önlemeliyim? | Ş (şiddet) × O (olasılık) × T (tespit edilemezlik), her biri 1–5. RPN çarpımla tutmalı |

Sıra: belirtiyi ham yaz → Ishikawa ile genişlet → FMEA ile önceliklendir → en yüksek RPN'li adayı ölç → 5 Neden ile köke in → önleyici çözümü **mekanizma** olarak yaz (kural metni değil: araç, test, kontrol).

## Kayıt biçimi (`araclar/teshis/T-NNN-kisa-ad.md`)

```
# T-NNN · Başlık
Tarih: YYYY-AA-GG · Durum: AÇIK | KAPANDI

## Belirti
Ne görüldü. Ham hata metni, yorum yok.

## Olası nedenler
| # | Neden | Durum | Güven | Ölçüm |
|---|---|---|---|---|
| N1 | … | ADAY / DOĞRULANDI / ELENDİ | Yüksek / Orta / Doğrulanmadı | komut ya da kaynak → sonuç (ADAY'da —) |

## 5 Neden
1. … test: …

## Ishikawa
- İnsan: …
- Araç: …
- Yöntem: …
- Girdi: …
- Ölçüm: …
- Ortam: …

## FMEA
| # | Olası hata | Ş | O | T | RPN | Önlem |
|---|---|---|---|---|---|---|
| F1 | … | 1–5 | 1–5 | 1–5 | Ş×O×T | … |

## Doğrulama
Çalıştırılan ölçümler ve çıktıları.

## Önleyici çözüm
Mekanizma (dosya/komut/commit). Burak kararı bekleyen kısım ayrıca belirtilir.

## Çöken varsayım
Kesin sandığım ama ölçümle çöken şey. Yoksa "yok".
```

**KAPANDI** için: en az bir DOĞRULANDI neden ve dolu bir önleyici çözüm şart. ADAY kalan neden, kapanışı engellemez ama kayıtta açıkça durur.
