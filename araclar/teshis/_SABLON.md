# Teşhis kaydı şablonu (tek kaynak)

Yöntem ve kipler: `.claude/skills/kod-analizi/SKILL.md`. Görülmüş belirtiler: `BELIRTILER.md`. Denetim: `node araclar/teshis.mjs` (`dogrula.sh` de çağırır).
**Saha kuralı:** belirti, kanıt, olası neden, düzeltme ve önleme ayrı yazılır. Ölçülmeyen neden ne DOĞRULANDI ne ELENDİ olur, ADAY kalır.
**Neden var:** 2026-11-07'de "soru yalnız DROP'ta çıkar" varsayımı ölçülmeden kesin sayıldı ve bir uygulama turu boşa gitti (T-001).

Dosya: `araclar/teshis/T-NNN-kisa-ad.md`. Başlıklar aynen kalır; denetleyici onları arar.

```
# T-NNN · Başlık
Tarih: YYYY-AA-GG · Kip: Arıza | Yeni özellik | İyileştirme | Bağımlılık · Durum: AÇIK | KAPANDI

## Belirti
Kullanıcının gördüğü sonuç. Ham metin, yorum yok.

## Kanıt
`dosya:satır` ve çalıştırılmış ölçüm (komut → çıktı). En az bir `…` referansı.

## Ishikawa
- Arayüz: …
- Veri: …
- İş mantığı: …
- Entegrasyon: …
- Mimari: …
- Test: …

## 5 Neden
1. … test: …

## RCA
| # | Neden | Durum | Güven | Ölçüm |
|---|---|---|---|---|
| N1 | … | ADAY / DOĞRULANDI / ELENDİ | Yüksek / Orta / Doğrulanmadı | komut ya da kaynak → sonuç (ADAY'da —) |

## FMEA
| # | Olası hata | Ş | O | T | RPN | Önlem |
|---|---|---|---|---|---|---|
| F1 | … | 1–5 | 1–5 | 1–5 | Ş×O×T | … |

## Düzeltme
En düşük riskli kalıcı çözüm ve etki alanı. Uygulanmadıysa "önerilir" yazılır.

## Doğrulama
Çözümü kanıtlayan test ve bozma testi (komut → çıktı).

## Öğrenim
Tekrarı engelleyen mekanizma (dosya, komut, commit). Burak kararı bekleyen kısım ayrıca belirtilir.

## Eleştirel sorular
1. Neden daha önce fark edilmedi? …
2. Aynı mantık kaç yerde? …
3. Düzeltme başka işlemi bozar mı? …
4. Karmaşıklık katkısı? …
5. Tekil mi, mimari mi? …
6. İleride aynı nedenle ne bozulur? …
7. Daha basit tasarım? …
```

**KAPANDI** için: en az bir DOĞRULANDI neden, dolu Düzeltme ve Öğrenim şart. ADAY kalan neden kapanışı engellemez ama kayıtta açıkça durur. Ölçekler (Ş/O/T) skill dosyasındadır.
