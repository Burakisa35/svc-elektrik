---
title: CLAUDE.md ve Claude Code yapılandırması — proje rehberi
retrieved: 2026-11-07
---

# CLAUDE.md nasıl kullanılır

Kaynaklar: [Memory](https://code.claude.com/docs/en/memory) · [Best practices](https://code.claude.com/docs/en/best-practices) · [.claude dizini](https://code.claude.com/docs/en/claude-directory)

## Resmî ilkeler
| İlke | Güven |
|---|---|
| CLAUDE.md her oturumda yüklenir; her satır dikkat tüketir. Yalnız koddan çıkarılamayanı yaz: doğrulama komutları, yanıltıcı yerler, repoda olmayan kararlar, iki kez düzeltmek zorunda kaldığın şeyler | Yüksek |
| Hedef: dosya başına 200 satırdan az. Uzun içerik yol-kapsamlı kurallara (`.claude/rules/`) veya skill'e taşınır | Yüksek |
| CLAUDE.md bağlamdır, zorlama değildir. İstisnasız kural (ör. "şu dizine yazma") **hook** olmalı (PreToolUse); `IMPORTANT` eklemek çözmez | Yüksek |
| Alt dizindeki CLAUDE.md açılışta değil, o dizinden dosya okunduğunda yüklenir | Yüksek |
| Kişisel tercih `CLAUDE.local.md` (gitignore'da) | Yüksek |
| Somut yaz: "2 boşluk girinti" iyi, "düzgün biçimle" kötü; çelişen talimatlar rastgele seçilir | Yüksek |
| `/init` başlangıç üretir, `/doctor prompt-audit` eskimiş/çelişen satırları bulur, `/context all` yüklendiğini doğrular | Yüksek |

Uyarı (2026-11-07): LLM üretimli bağlam dosyalarının (`/init` gibi) görev başarısını artırmadığı, maliyeti yükselttiği ölçümleri var; bkz. `context-dosyalari-literatur.md` bölüm A (Orta). `/init` çıktısını olduğu gibi kullanma, yalnız koddan çıkarılamayanı tut.

## Bu proje için uygulama
1. **Rol sınırı hook'a bağlanmalı.** Kök `CLAUDE.md`'deki "Code `knowledge/`'a yazmaz" kuralı istisnasız; yalnız metin olarak bırakılırsa "çoğu zaman" uyulur. Claude Code görevi: `.claude/settings.json` içinde `knowledge/**` ve `docs/**` yazımını engelleyen PreToolUse hook; Bash yazmaları da kapsanmalı (`Edit|Write` eşleştirici Bash'i yakalamaz) veya `permissions.deny Edit(knowledge/**)` + sandbox. (Orta: ilkeden uyarlama)
2. **Komut bölümü eksik.** Kök CLAUDE.md'de build/test/deploy komutları yok çünkü yığın henüz belli değil (Doğrulanmadı). Code'un ilk işi: komutları `## Komutlar` altına eklemek, 200 satır sınırını korumak. (Orta)
3. **Dizin başına küçük CLAUDE.md.** `knowledge/CLAUDE.md` mevcut. Code kendi dizinlerine `src/CLAUDE.md`, `supabase/CLAUDE.md` yazar. Alt dizin dosyaları isteğe bağlı yüklendiği için kök dosyayı şişirmez. (Yüksek: yükleme davranışı)
4. **Düzeltme döngüsü.** Aynı hata ikinci kez olursa ilgili CLAUDE.md'ye tek satır eklenir; her ay `/doctor prompt-audit`. (Yüksek: öneri)
5. **Sohbet Claude'u için:** kök CLAUDE.md aynı zamanda sohbet tarafının kural kitabıdır; Burak'ın kişisel tercihleri repoya girmez. (Orta)

## Yapılmayacaklar
- Koddan okunabilecek şeyi (dosya listesi, API şeması) CLAUDE.md'ye kopyalama.
- Uzun prosedürü CLAUDE.md'ye gömme; skill yap.
- Gizli anahtar/URL yazma.
