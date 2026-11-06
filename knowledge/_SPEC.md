# Bilgi tabanı formatı (v0.1)

Amaç: Markdown dosyalarının hem insan tarafından okunması hem Claude Code importer'ı tarafından Supabase tablolarına yüklenmesi. Bu yüzden front matter **makine okunur**, gövde **insan okunur**.

## Dosya türleri

| Dizin | Tür (`type`) | Tablo karşılığı |
|---|---|---|
| `families/` | `family` | `system_family` |
| `brands/` | `brand_model` | `brand_model`, `terminal_map` |
| `fault-cases/` | `fault_case` | `fault_case`, `test_step` |
| `sources/` | `source` | kaynak kataloğu |
| `sources/arama-gunlugu.md` | `log` | importer atlar |

Saha raporları (`field_report`) uygulamada üretilir, burada dosya olarak tutulmaz; bulgu doğrulanınca ilgili `fault_case` kaydına işlenir.

## Ortak front matter

```yaml
---
id: netelsan-sesli-diafon          # dosya adıyla aynı, benzersiz
type: brand_model                  # family | brand_model | fault_case | source
title: Netelsan kapıcısız çift zilli sesli diafon
status: taslak                     # taslak | gozden-gecirildi | tamam
updated: 2026-11-07
confidence: Orta                   # kayıt geneli: Yüksek | Orta | Doğrulanmadı
sources: [src-netelsan-ham-sma-00005]
---
```

## brand_model — uç tablosu

Gövdede `## Uçlar` başlığı altında tablo; her satır tamamlanma ölçütüne uyar:

| uç | renk | işlev | sinyal | akım yolu | arıza davranışı | güven | kaynak |
|---|---|---|---|---|---|---|---|

Bir sütun bilinmiyorsa hücreye `Doğrulanmadı` yazılır; satır `tamamlanmadı` sayılır.

## fault_case

```yaml
---
id: fc-zil-capraz-calma-001
type: fault_case
system: [netelsan-sesli-diafon]
symptom: Bir daire panelden basılınca başka dairelerin zili de çalıyor
confidence: Orta
sources: [...]
---
```
Gövde bölümleri (sırayla): `## Belirti`, `## Ayırt edici sorular`, `## Olası nedenler` (olasılık sırasıyla, her biri etiketli), `## Test adımları` (numaralı; her adımın **beklenen sonucu** ve **neyi eler** bilgisi), `## Sonuç / kök neden` (saha doğrulaması gelene dek boş), `## Kaynaklar`.

## source

```yaml
---
id: src-netelsan-ham-sma-00005
type: source
url: https://...
class: uretici                     # uretici | kilavuz | forum | devre-analizi | saha
language: tr
retrieved: 2026-11-07
reliability: Yüksek
note: Neden güvenilir / sınırı ne
---
```

## Yazım kuralları

- İçerik paraphrase; uzun alıntı yok.
- Her iddianın etiketi satır sonunda: `(Yüksek)`, `(Orta)`, `(Doğrulanmadı)`.
- Rakip hipotezler ayrı numaralanır (H1, H2…) ve hangi kanıtın hangisini elediği yazılır.
- Değişiklik: dosya içinde tarihli satır eklemek yerine `updated` güncellenir; büyük revizyon commit mesajında anlatılır.
