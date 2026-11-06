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

## fault_family (v0.2 eki)

Belirti sınıfı dosyası: `knowledge/fault-families/*.md`, `type: fault_family`. Front matter: `id` (ff-…), `brands`, `confidence`, `status`. Gövde: aile tablosu (kod F1…, belirti, kayıtlı olduğu yerler, marka kaydı, açık vaka) ve soru parametreleri tablosu (kod Q-…, soru, cevap türü, ne ayırır, etiket). Vakasız ailede neden yazılmaz. Aile, soru, hipotez (H…) ve test adımı (`step_id`) kodları **kalıcı kimliktir**: yeniden numaralanmaz, silinmez; yeni olan yeni kimlik alır (örn. araya giren adım `7b`), kullanımdan kalkan `status: kaldirildi` olur. `fc-zil-capraz-calma-001` için kimlikler 2026-11-07 itibarıyla donmuştur (öncesi taslaktı, G1 sırasında yeniden numaralandı).

## Çözüm kaydı sözlüğü (v0.2 eki)

Çözüm kayıtları bilgi tabanında değil, uygulamada (Supabase) tutulur; bilgi tabanı yalnız **kimlik sözlüğünü** sağlar ki kayıtlar analize bağlanabilsin. Sözlük:

- `family_id`: F1…F7 (fault_family dosyasından)
- `question_id` + `answer`: Q-… ve seçilen cevap
- `hypothesis_id`: H1… (ilgili fault_case dosyasından; durum: canlı / elendi / doğrulandı)
- `step_id`: vaka dosyasındaki test adımı (1, 2, … 7b)
- `outcome`: cozuldu / kismen / cozulmedi / bekliyor
- `root_cause_class`: `kisa_devre_iletkenler_arasi` / `yari_iletken_yolu` / `baglanti_hatasi` / `ek_yeri` / `komponent_arizasi` / `besleme` / `diger` / `bilinmiyor` (liste açık uçludur, ekleme bu dosyada yapılır)
- `field_verification`: `dogrulandi` / `dogrulanmadi` — çözümün sahada (dönüş testi) doğrulanıp doğrulanmadığı
- Zaman damgaları: vaka açılışı, her adımın bitişi, çözüm anı, **tekrar kontrol tarihi** (arıza geri geldi mi). Saat dilimi Europe/Istanbul; saat:dakika düzeyi yeterli.

Kural: `outcome = cozuldu` her iki `field_verification` değeriyle saklanabilir; analizde `dogrulanmadi` olanlar ayrı sayılır ve çözüm oranına katılmaz. Saha sonucu araştırma çıkarımının üstündedir (kök CLAUDE.md).
