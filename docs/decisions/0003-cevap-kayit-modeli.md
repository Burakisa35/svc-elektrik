# 0003 — Soru cevaplarının kayıt modeli

Tarih: 2026-11-07 · Durum: **öneri, Burak onayı bekliyor** · Yazan: sohbet Claude'u · Uygulayan: Claude Code (migration yalnız Burak onayıyla)

## Sorun
Cevaplar Supabase'e kaydolacak. Soru metni 3 günde değişecek. Model, değişen soruyu eski cevapla yanlış karşılaştırmamalı; cevaplanmayan istemi de saymalı (cevap oranı ölçüsü).

## Seçenekler

| | A. Tek tablo, serbest jsonb | B. Soru başına sütun | C. Olay günlüğü (yalnız ekleme) + analiz görünümleri |
|---|---|---|---|
| Soru değişince | Eski/yeni karışır, sürüm tutulmazsa karşılaştırma bozulur | Her değişiklikte migration gerekir (Burak onayı) | Soru kimliği + sürüm her satırda; migration gerekmez |
| Cevaplanmayanı sayar | Hayır (satır yok) | Hayır | Evet: durum = cevaplandı / atlandı / süresi doldu |
| Çevrimdışı eşitleme | Tekrar riski | Tekrar riski | İstemci üretimli UUID ile tekrarsız |
| Denetim izi | Zayıf | Zayıf | Güçlü: satır silinmez, düzeltme yeni satır |
| Analiz kolaylığı | Zor | Kolay | Görünümle (view) kolay |

## Öneri: C
Tek tablo `cevap_olaylari` (ad önerisi; ASCII). Alanlar (spec, migration değil):

| Alan | Anlam |
|---|---|
| `id` | İstemcide üretilen UUID (eşitleme tekrarsız) |
| `soru_id`, `soru_surumu` | Hangi soru, hangi metin sürümüyle. Cevap sürümle birlikte saklanır |
| `banka_surumu` | Hangi soru bankasından |
| `slot` | sabah / aksam / gun_sonu_geri_bildirim / cuma |
| `durum` | cevaplandi / atlandi / suresi_doldu |
| `gosterildi_at`, `cevaplandi_at` | Zaman damgası, Europe/Istanbul; gecikme buradan hesaplanır |
| `yerel_tarih` | Gün sınırı için |
| `deger` (jsonb) | Seçilen seçenek(ler); serbest metin ayrı alanda |
| `serbest_metin`, `kaynak` | Dikte veya yazı; `kaynak` = dokunus / dikte |
| `is_id` (boş olabilir) | Brief 002 çözüm kaydına bağ |
| `hassas_olabilir` | Serbest metinde müşteri bilgisi olabilir; analizde ve dışa aktarmada varsayılan gizli |

Değişmez kurallar:
1. Satır güncellenmez/silinmez; düzeltme yeni satırdır.
2. Soru kimliğinde yalnız **ifade netleştirme** sürüm artırır. Seçenek ekleme/çıkarma veya anlam değişikliği **yeni soru kimliğidir**. Karşılaştırma yalnız aynı kimlik için yapılır.
3. RLS her tabloda; tek kullanıcı kimliğine bağlı; varsayılan yetkiler geri alınır; gizli anahtar istemcide yok.
4. Repoya cevap, döküm veya örnek veri girmez (repo public).

## Güven
Seçenek karşılaştırması mühendislik gerekçesi: **Orta** (ölçülmedi). ESM'de kaçan istemin planlanması gerektiği: Fritz ve ark. 2024 (Orta).
