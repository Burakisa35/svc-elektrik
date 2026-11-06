# Brief 003 — Code'un verimi için md dosyası tasarımı: literatür araştırması

Yazan: Rol 1 (brief yazarı) · Uygulayan: Rol 2 (araştırmacı) · Denetçi: ayrı oturum (G1) · Karar: Burak
Tarih: 2026-11-07 · Mod: derin ama sınırlı (tur 2 kapsamı aşağıda) · Durum: tur 1 yapıldı, tur 2 bekliyor

Burak'ın isteği (01:35): Code'un en verimli çalışması için CLAUDE.md ve diğer md dosyalarının tasarımına yönelik genel literatür araştırması; (1) başarı çıktısı, (2) eksik kalan konuların sonuçları ve eklenecekler, (3) "senin ekleyeceğin…" (cümle yarım kaldı; aşağıda "benim eklediklerim" olarak yorumlandı).

## 1. Başarı çıktısı (Soru 1)

Araştırma bitmiş sayılır, eğer şu dört çıktı **ve** kabul ölçütü sağlanıyorsa:

| Çıktı | İçerik | Nerede |
|---|---|---|
| A. Yerleştirme tablosu | Her bilgi türü için nereye konur: kök CLAUDE.md / alt dizin CLAUDE.md / `.claude/rules` / skill / subagent / hook / settings; her satırda yüklenme zamanı, sıkıştırmada kalıp kalmadığı, bağlam maliyeti, kanıt etiketi | `docs/references/context-dosyalari-literatur.md` |
| B. Bu depo için md haritası | Hangi md dosyaları olacak, sahibi kim, en çok kaç satır, ne zaman yüklenir; mevcut kök CLAUDE.md için sil/kısalt/koru kararı ve gerekçesi | `docs/decisions/0002-md-haritasi.md` |
| C. Hafif ölçüm protokolü | Bir md değişikliğinin işe yarayıp yaramadığını **iki gerçek görevde önce/sonra** karşılaştırma yöntemi (bir sayfa, rapor yığını değil) | aynı referans dosyası |
| D. Code uygulama brief'i | Hook, komutlar bölümü, `src/CLAUDE.md` yazım kuralı, güvenilmeyen içerik kuralı: Code'un yapacağı iş listesi | `docs/briefs/004-code-md-uygulama.md` |

**Kabul ölçütü ("Burak/Code şunu yapabilmeli"):**
1. Code yeni bir oturumda görev alınca build/test/deploy komutlarını ve rol sınırını md'den bilir; Burak ayrıca anlatmaz.
2. Code'a `knowledge/` içine **Bash ile bile** yazdırılmaya çalışıldığında engellendiği bir denemeyle gösterilmiş olmalı (metin kuralı kabul edilmez).
3. Toplam yüklenen md miktarı `/context` ile görülebilir ve belirlenen sınırın altında.
4. Aynı hata ikinci kez olduğunda tek satırın **nereye** ekleneceği belli.
5. Her tasarım kararında "kanıt: Yüksek/Orta/Doğrulanmadı" ve "bu depoda ölçüldü mü" yazıyor.

## 2. Eksik kalırsa ne olur, ne eklenmeli (Soru 2)

| Kod | Konu | Eksik kalırsa olumsuzluk | Tur 1 durumu | Eklenecek |
|---|---|---|---|---|
| K1 | md dosyalarının gerçek etkisi | Şişirilmiş md: ölçümlerde maliyet ~%20 artıyor, başarı artmıyor; "iyi görünen" dosya zarar verir | **Yapıldı** (Orta, çelişkili ölçümler) | — |
| K2 | Yükleme ve sıkıştırma (compaction) davranışı | Alt dizin kuralı sıkıştırmada kaybolur; rol sınırı sessizce unutulur | **Yapıldı** (resmî doküman, Yüksek) | Kendi depoda `/context` ile doğrulama |
| K3 | Zorlama katmanı ve atlatma yolları | `knowledge/` bütünlüğü Bash yazmasıyla bozulur; `permissions.deny` bazı sürümlerde uygulanmamış olabilir (Doğrulanmadı) | Kısmen (resmî mekanizma var, atlatma yolları ikincil kaynak) | Hook'u Bash dahil **deneyerek** doğrulama, sandbox seçeneği |
| K4 | Etki ölçümü | md değişiklikleri körlemesine; hangisi işe yaradı bilinmez | Yok | Hafif protokol (Çıktı C). Not: Burak test/rapor yığınından yorulur, protokol iki görev ve bir sayfa ile sınırlı |
| K5 | Güvenilmeyen içerik | `knowledge/` web kaynaklı metin içerir; importer/ajan bunu talimat sanabilir (prompt injection). Hiçbir md bunu söylemiyor | Yok | Kural: kaynak metni = veri; importer'da talimat/veri ayrımı; Anthropic'in ajan güvenliği rehberi taranacak |
| K6 | Bakım ve eskime | md eskir, birbirini çelişir; ajan rastgele birini seçer | Kısmen (`/doctor prompt-audit`) | Sahiplik + gözden geçirme ritmi + "ikinci hata → tek satır" kuralı |
| K7 | Roller arası md'ler (brief, ADR, bulgu) | Code brief'i yanlış anlar; karar gerekçesi kaybolur | Yok | ADR (Nygard), spec-driven geliştirme, brief şablonu |
| K8 | Dil | Türkçe talimat uyumu ölçülmedi (Doğrulanmadı); komut ve kod İngilizce karışımı çelişki üretebilir | Yok | Arama + aynı kuralın TR/EN karşılaştırması |
| K9 | Mobil/bulut çalışma | Burak yalnız iPhone; hook/settings bulut oturumunda çalışmazsa tüm zorlama boşa gider | Yok | Bulut oturumda hook ve `.claude/settings.json` davranışı, commit edilen ayarların yüklenmesi |
| K10 | Skill/subagent seçimi | Tekrarlayan işler (G1 denetimi, importer) CLAUDE.md'yi şişirir ya da tetiklenmez | Kısmen (resmî karşılaştırma tablosu) | Tetikleme güvenilirliği; hangi iş skill, hangisi subagent |
| K11 | Auto memory ve `CLAUDE.local.md` | Burak'ın kişisel tercihi repoya sızar ya da auto memory ile CLAUDE.md çelişir | Yok | Ne nerede durur kuralı |
| K12 | Gizli anahtar | Anahtar md'ye ya da bağlama girer | Kısmen (references/supabase.md, vercel.md) | `Read` deny + sandbox kimlik bilgisi kuralı |

## 3. Benim eklediklerim (Soru 3 yorumu)

Cümle "Senin ekleyeceğin…" diye yarım kaldığından, "senin istediğin konulara **benim** eklediğim" diye yorumladım: **K4** (ölçüm; çünkü literatür md'nin kendiliğinden iyi olmadığını gösteriyor), **K5** (güvenilmeyen içerik; bu depoya özgü risk), **K9** (iPhone/bulut kısıtı), **K11** (kişisel tercih sızıntısı). Başka bir şeyi kastettiysen söyle, brief'e eklenir.

## 4. Tur 2 kapsamı ve durma kuralı

- Tur 2 yalnız **K3, K5, K7, K8, K9, K10** konularını araştırır. Her konuya en çok 3 sorgu; üçünde yeni bilgi çıkmazsa "bulunamadı" yazılır ve durulur.
- Kapsam dışı: başka araçların kural dosyaları (Cursor, Copilot), API ile ajan geliştirme, görüntülü diafon.
- Kaynak hiyerarşisi: (1) Anthropic resmî dokümanı, (2) tekrarlanabilir ölçüm/makale, (3) uygulayıcı yazıları (Orta'yı geçmez), (4) tek kaynaklı iddia = Doğrulanmadı.
- Tahminle doldurma yok; ölçülmemiş şey "Doğrulanmadı" kalır.

## 5. Denetim

Her teslim G1'den ayrı bir denetçiyle geçer (üreten denetlemez). Tur 1 dosyası şu an denetimde; tur 2, bulgular kapanmadan başlamaz.
