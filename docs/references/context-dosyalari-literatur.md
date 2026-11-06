---
title: Bağlam dosyaları (CLAUDE.md, AGENTS.md, rules, skills, hooks) — literatür taraması
retrieved: 2026-11-07
status: tur 1 (taslak, denetlenmedi)
---

# Bağlam dosyaları literatürü — tur 1

Etiketler: **Yüksek** = Anthropic resmî dokümanı; **Orta** = ön baskı/çalışma, bağımsız tekrar var ama sonuçlar kısmen çelişiyor; **Doğrulanmadı** = ikincil kaynak/ben doğrulamadım. Özetler paraphrase'tir.

## A. Bağlam dosyaları gerçekten işe yarıyor mu? (ölçümler)

| Bulgu | Kaynak | Güven |
|---|---|---|
| Bağlam dosyası görev başarısını genel olarak artırmıyor, çıkarım maliyetini ortalama %20'nin üstünde artırıyor. LLM üretimi dosyalar başarıyı hafif düşürüyor (SWE-bench'te ~0,5, CTXbench'te ~2 puan; ikisi de anlamsız fark). Geliştirici yazısı dosyalar ~%2,4 artış (p=0,21, anlamsız), Claude Code'da artış yok. Talimatlar iyi izleniyor (daha çok test, daha çok keşif); **depo genel bakışı bölümleri yardımcı olmuyor** | Gloaguen vd., arXiv:2602.11988 | Orta |
| 17 görev, iki ajan (Claude Code, Codex), 288 değerlendirilmiş koşu: bağlam enjeksiyon stratejisi doğruluğu ölçülebilir biçimde oynatmıyor (fark ≤ 10–15 puan sınırı, güç yetersiz). Görevler çoğunlukla "depo bilgisi eksikliği"nden değil uygulama becerisinden başarısız oluyor | Khatri, ACL Anthology REALM 2026 (2026.realm-1.5) | Orta |
| Farklı yönde: AGENTS.md ile medyan süre %28,6, çıktı token'ı %16,6 düşük (124 PR, 10 depo); toplam token medyanı ise +%1,3 | Chatlatanagulchai vd., arXiv:2601.20404 | Orta |
| Özet: dosya doğruluğu belirgin artırmıyor, **hızı/süreci** etkileyebilir; içerik yönü belirliyor; ajan talimata neredeyse mekanik uyuyor | Orvii/context-file-evidence (derleme, ben doğrulamadım) | Doğrulanmadı |

Sınır: çalışmalar çoğunlukla Python kütüphane depolarında görev çözme ölçüyor. Bizim depo bilgi tabanı + rol sınırı içeriyor; bu, "standart olmayan kural" sınıfına giriyor ve çalışmaların önerdiği tek faydalı içerik türü bu.

## B. Resmî mekanizmalar (Yüksek)

- CLAUDE.md oturum başında yüklenir; kök dosya sıkıştırmadan (compaction) sonra diskten yeniden okunur. **Alt dizin CLAUDE.md, o dizine dokunulana kadar yüklenmez ve sıkıştırmadan sonra o dizine tekrar dokunulana kadar kaybolur.** `.claude/rules/` kuralları sıkıştırmada yeniden enjekte edilir; `paths:` ile yalnız eşleşen dosya açılınca yüklenir. (code.claude.com/docs/en/memory; claude.com "Steering Claude Code" makalesi)
- `@yol` ile içe aktarma, en çok 4 atlama derinliği; içe aktarılan dosyalar bağlama tam girer (token tasarrufu yok).
- Hedef: dosya başına < 200 satır; süreç/prosedür skill'e, "her zaman bil" kuralları CLAUDE.md'ye. Skill: yalnız ad+açıklama oturum başında bağlamda, gövde çağrılınca yüklenir; açıklama + `when_to_use` listede 1.536 karakterde kesilir.
- Subagent: kendi bağlam penceresinde çalışır, ana oturuma yalnız özet döner.
- Auto memory (Claude'un kendi notları): her oturumda ilk 200 satır/25 KB.

## C. Zorlama (hook / izin kuralları)

- İzin kuralları Claude Code tarafından uygulanır, model tarafından değil; CLAUDE.md "ne denesin"i şekillendirir, "ne yapabilir"i değiştirmez. Sıra: deny → ask → allow, ilk eşleşen kazanır (Yüksek).
- PreToolUse hook `deny` kararı `bypassPermissions` dahil her modda geçerli; exit kodu 2 engeller, stderr mesajı Claude'a geri bildirim olur. Aynı olay için eşleşen tüm hook'lar çalışır; en kısıtlayıcı karar geçer (Yüksek).
- **Sınır (önemli):** `Read`/`Edit` deny kuralları yerleşik dosya araçlarını ve `cat/head/tail/sed` gibi yaygın komutları kapsıyor, ama dosyayı kendisi açan keyfî bir Python/Node betiğini kapsamıyor. Bash komutu da yazma yolu olduğundan `Edit|Write` eşleştiricisi tek başına `echo > knowledge/x.md` gibi yazmaları yakalamaz; Bash komut metnini inceleyen hook veya sandbox gerekir (castel.studio, anomity.ai ikincil kaynaklar: Orta; sandbox'ın Bash ve alt süreçlere uygulandığı resmî izin dokümanında geçiyor: Yüksek).
- `permissions.deny` kurallarının bazı sürümlerde sessizce uygulanmadığına dair GitHub issue bildirimleri (#27040, #6699) var (agentpatterns.ai üzerinden): **Doğrulanmadı**, ben issue'ları açmadım. Sonuç: hook'u kurunca *denenmeli* (Claude'a yasak dosyaya yazdırıp engellendiği görülmeli).

## D. Bu depo için çıkarımlar (Orta, ölçülmedi)

1. Kök CLAUDE.md'deki **"Dizin haritası"** bir depo genel bakışıdır; ölçümler bu tür içeriğin faydasız olduğunu gösteriyor ve her satır bağlam harcıyor. Aday: kısalt veya kaldır; karar için ölçüm (aşağıda brief 003, soru K3).
2. **Rol tablosu ve "Code knowledge/'a yazmaz"** standart olmayan, koddan çıkarılamayan kural: tutmaya değer; ama metin yetmez, hook gerekir ve Bash yolu dahil denenmeli.
3. `/init` ile üretilmiş dosya önerisi, ölçümler karşısında zayıf: LLM üretimli bağlam dosyaları gerçek fayda göstermedi. Code'dan `src/CLAUDE.md`'yi **/init çıktısı olarak değil**, yalnız koddan çıkarılamayan komut/tuzak satırlarıyla yazması istenmeli.
4. Alt dizin CLAUDE.md'ler sıkıştırmada kaybolur → *rol sınırı gibi her zaman geçerli kurallar kök dosyada veya yol kapsamsız `.claude/rules/` içinde* durmalı; `knowledge/CLAUDE.md` yalnız knowledge'a özgü yazım kurallarını taşımalı.
5. Knowledge dosyaları **web kaynaklı metin** içeriyor; importer/ajan bunları talimat değil veri sayar. Bu güvenlik kuralı henüz hiçbir md dosyasında yazılı değil (brief 003, soru K5).

## E. Bu turda bakılmayanlar

Skill açıklaması tetikleme güvenilirliği ölçümü; Türkçe talimatların model uyumu üzerine veri (arama yapılmadı: **Doğrulanmadı**); ADR/brief biçimi literatürü (Nygard ADR, spec-driven geliştirme); mobil/bulut oturumda hook çalışması; AGENTS.md ↔ CLAUDE.md birlikte kullanım ayrıntıları.
