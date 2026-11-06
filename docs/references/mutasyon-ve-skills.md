---
title: Mutasyon testi ve Claude skills — BEE için kısa not
retrieved: 2026-11-07
---

# Mutasyon testi ve skills

Kaynaklar: [Stryker SSS](https://stryker-mutator.io/docs/General/faq/) · [Stryker giriş](https://stryker-mutator.io/docs/) · [Is mutation testing worth it](https://shoulditestthat.com/should-i-test/mutation-testing/) · [Adam Daw, Mutation Testing](https://adamdaw.com/writing/mutation-testing-who-tests-the-tests/) · Skills için `context-dosyalari-literatur.md` bölüm B.

## 1. Mutasyon testi nedir
Koda tek bir küçük hata (mutant) eklenir, testler çalıştırılır. Test kırılırsa mutant "öldü" (iyi), geçerse "yaşadı" (testin bu hatayı fark etmediği boşluk). Skor = tespit edilen / geçerli mutant. Yüksek satır kapsaması iyi test demek değildir: kaynakta %100 kapsamlı bir dosyada 10 mutantın 10'u yaşadı. (Yüksek: aracın kendi dokümanı + ölçüm örneği, Orta: tek yazarın örneği)

## 2. BEE için ne anlama gelir

| Soru | Cevap | Güven |
|---|---|---|
| Tamamına uygulanır mı? | Hayır. Tüm repoda skor hedefi koymak, mutantı öldürmek için anlamsız test yazdırır; Google da mutlak skoru uygulanamaz bulup yalnız değişen satırlara bakıyor | Orta |
| Nereye uygulanır? | Yalnız hata maliyeti yüksek, küçük saf mantık: md→JSON importer, bilgi tabanı linter'ı (beş alan/etiket kontrolü), çözüm süresi hesabı | Orta (öneri) |
| Nasıl çalıştırılır? | Yalnız değişen dosyada, yaşayan mutantları rapor olarak oku; build'i skorla düşürme | Orta |
| Elle yapılabilir mi? | Evet: şüphelendiğin tek satırı bozup testin kırılıp kırılmadığına bak, geri al. Araç gerekmez | Yüksek |
| Burak'ın isteğiyle çakışır mı? | Evet, yığın test/rapor yorgunluğu var. Bu yüzden varsayılan: **yok**; yalnız importer ve linter'a elle/tek seferlik | — |
| tehai'deki `tests/_mutasyon.mjs` ne yapıyor? | İçeriği bu oturumda incelenmedi: **Doğrulanmadı** | Doğrulanmadı |

## 3. Skills (Claude yetenekleri)
- Skill = talimat klasörü; yalnız ilgili olduğunda yüklenir, CLAUDE.md gibi her oturumda yer tutmaz. Uzun prosedür CLAUDE.md'ye değil skill'e konur. (Yüksek: `claude-md.md`, resmî ilke)
- BEE'de aday skill'ler (hepsi öneri, ölçülmedi):

| Aday | İş | Sahibi |
|---|---|---|
| `bilgi-kaydi-ekle` | Yeni uç/arıza kaydını şablon + beş alan + güven etiketiyle yazdırır | Sohbet tarafı (knowledge/ alanı) |
| `cozum-kaydi` | Sahada çözüm kaydı sözlüğüne uygun giriş (brief 002) | Code |
| `kaynak-denetle` | Kaynak kaydını (URL, etiket, paraphrase) kontrol listesiyle geçirir | Sohbet tarafı |

- Skill ve alt ajan farkı (hangisi ne zaman) tur 2 / K10'da araştırılacak; şimdilik **Doğrulanmadı**.
- `.claude/**` dizini Code'a mı sohbete mi ait, karar bekliyor (brief 004'te soru olarak var).
