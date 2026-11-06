GEÇMEDİ

# 003 — G1 yeniden denetim (tur 2 düzeltmeleri) + yeni referans dosyaları (commit e0d34df, dal setup/foundation)

Tarih: 2026-11-07 · Denetçi: ayrı ajan (işi üretmemiş) · Kapsam: `git diff 3105734..e0d34df`

## Sonuç

- **(A) Yeniden denetim: GEÇTİ.** 002'deki E1, E2, D1-D9, N1-N2 kapandı; kalan küçük sorunlar aşağıda (A-notları), engelleyici yok.
- **(B) Yeni dosya denetimi: GEÇMEDİ.** 1 engelleyici (yanlış yazar atfı), 6 düzeltilmeli, 2 not.
- Genel karar GEÇMEDİ: B-E1 kapanana kadar `context-dosyalari-literatur.md` kaynak olarak kullanılmamalı. Bu dosya `docs/` altında; düzeltme sohbet Claude'unun işi.

Dosya sahipliği: temiz. Diff 16 dosya, hepsi `knowledge/`, `docs/`; `src/`, `supabase/`, `index.html` yok.

## Doğrulama özeti (WebFetch)

| Kaynak | Sonuç |
|---|---|
| kontrolkalemi Netelsan 2021 konusu | Açıldı. "Birkaç daire dış zili durmadan çalıyor" ifadesi **var** (iç zil bağlanınca ayrı belirti). Konu sahibi şüpheyi daire içi diafonlara yöneltiyor. Çözüm yok |
| elektroda.pl topic3796225 | Açıldı. 16. daire sahibi; 7 seçilince 7 ve 16 çalıyor, 16 seçilince yalnız 16. Konu çözülmemiş. Bir katılımcı (suworow) bunu **dijital sistemde arızalı ahize dekoderi** olarak yorumluyor ve unifon öneriyor |
| arXiv:2602.11988 (abs + HTML v3) | Açıldı. Gloaguen vd. Rakamlar büyük ölçüde doğru (bkz. B-D1) |
| arXiv:2601.20404 (abs + HTML v2) | Açıldı. **Yazarlar Lulla vd.**, dosyadaki "Chatlatanagulchai vd." yanlış (bkz. B-E1) |
| ACL REALM 2026.realm-1.5 | Açıldı. Khatri; 17 görev, 3 depo, 2 ajan, 288 koşu, fark sınırı ~10-15 puan: doğru |
| claude.com "Steering Claude Code" | Açıldı. Sıkıştırma davranışı doğrulandı (bkz. B-D3) |
| code.claude.com/docs/en/hooks-guide, /permissions | Açıldı, ilgili cümleler bulundu |
| code.claude.com/docs/en/memory | **Doğrulanamadı.** WebFetch bu sayfa için izin reddi döndürdü (kullanıcı onayı yok); kurala göre tekrar denenmedi. Memory sayfasına özgü iddialar (4 atlama, <200 satır, skill 1.536 karakter, auto memory 200 satır/25 KB) denetlenmedi |
| src-elektrikforen-etagenruf-glimmlampe-2014 | Bu turda yeniden denenmedi (istenmedi); N1 açık notu aşağıda |

---

# A. Yeniden denetim

| Bulgu | Durum | Not |
|---|---|---|
| E1 (F3 kaynak eşlemesi) | **Kapandı** | Sayfa açıldı: "bir kaç daire dış zili durmadan çalıyor" kaynakta var. F3 satırı ve kaynak notu artık doğru. Küçük sapma: A-N1 |
| E2 (arama günlüğü sayıları) | **Kapandı** | Tablo 8 sorguyla uyumlu: Netelsan 3 (her biri 1), PL 1, RU 1, DE 1, Fermax/Golmar 1, BUS 1. Kart şeması "yeterince aranmadı" olarak açık kalem; durma kuralı cümlesi silinmiş. Satır 32 güncellendi |
| D1 (aile etiketleri) | **Kapandı** (notla) | `sesli-diafon-analog.md:17-23` Etiket sütunu var; dosya geneli `confidence: Doğrulanmadı` (en düşük) tutarlı. F1 gerekçesi yeterli ama bkz. A-D1 |
| D2 (STR "bulundu") | **Kapandı** | Not ve H1 hücresi "konu sahibine göre ... teyit yok" |
| D3 (Siedle forum) | **Kapandı** | "1+n" kalktı, "bir katılımcı", Q-ONCESI düzeltildi. "Aralıklı havada kalma" ifadesini bu turda yeniden doğrulamadım |
| D4 (Golmar) | **Kapandı** | "yalnız Stadio Plus" ve TF-104 12-17 V AC eklenmiş; F6'ya bağlı |
| D5 (Fermax) | **Kapandı** | "SES sorunları için", "kesit yetersizliği", F4'e bağlandı (öksüz değil) |
| D6 (Siedle servis kitabı) | **Kapandı** | İki satır ve "aynı telefonun iletkenleri" doğru; H1'de analoji olarak daraltıldı |
| D7 (aile-kaynak eşlemeleri) | **Kapandı** (notla) | F1 ve F5'ten Audio çıkarıldı, F7 "ıslık" gitti. Bkz. A-D7 |
| D8 (PL/RU/DE) | **Kapandı** | "1 sorgu, sınırlı", Elektroda numarası artık kaynak kaydıyla destekli, satır 32/58 tutarlı. Ama bkz. A-D8 |
| D9 (SPEC/brief) | **Kapandı** (notla) | `cozulmedi` tek ad (brief görünen etiket "çözülemedi" ile eşleme açıkça yazılı: brief:12); `field_verification` iki değerli; kural SPEC:93 anlamlı; H/step_id kalıcılığı SPEC'e girmiş; brief 1.2 "elle işaretler, otomatik eşleme yok" SPEC "Ne ayırır" serbest metniyle tutarlı. Bkz. A-D9 |
| N1 (elektrikforen) | **Kısmen** | Not artık "içerik doğrulanmadı" diyor, vaka dosyasında kullanılmıyor; günlük satırı da uyarıyor. URL hâlâ doğrulanmadı (bu turda denenmedi) |
| N2 (Q-KAPSAM) | **Kapandı** | "Yalnız tümü ölü → ortak besleme yönü için" ve "şaft grubu: Doğrulanmadı" |

## A ile ilgili yeni/artık bulgular (hiçbiri engelleyici değil)

### A-D1 — F1 "dört bağımsız forum bildirimi" sayımı şişik
Dosya: `knowledge/fault-families/sesli-diafon-analog.md:17`
Dördüncü kayıt Elektroda; sayfada bir katılımcı sorunu dijital sistemde arızalı ahize dekoderine bağlıyor. Satır "sistem bilinmiyor" diyor (doğru), ama yine de "dört bağımsız" sayılıyor; paralel hatlı analog çağrı teli ailesine uyumu belirsiz. Ayrıca yalnız biri Netelsan, diğerleri analoji/ tek vaka. Orta etiketi (kök kural: analoji ile tutarlı, doğrudan kanıt yok) hâlâ savunulabilir, ama sayı abartı.
Düzeltme: "üç forum bildirimi + bir sistemi belirsiz (muhtemelen dijital)". Düzeltilmeli, küçük.

### A-D1b — Etiket altı cümle yanlış kapsıyor
Dosya: `sesli-diafon-analog.md:25`
"F1-F3 dışındaki ailelerde kaynaklar başka marka ya da tek satırdır" der; oysa F2 (F1-F3 içinde) yalnız analoji (başka marka), F3 tek forum. Cümle F2'yi yanlış tarafa koyuyor. Ayrıca F2 "Orta" gerekçesinde Golmar kaydı "çağrı/çağrı onayı yok" diyor, "tek dairenin zili çalmıyor" demiyor; F2'nin Orta dayanağı fiilen yalnız Siedle satırı.
Düzeltme: "F1 dışındaki ailelerin Netelsan'a doğrudan dayanağı yok/tek satır"; F2'yi "Orta" yerine "Doğrulanmadı" yap veya gerekçeye "yalnız Siedle HT 711 satırı, Golmar kapsam dışı" ekle.

### A-D7 — F4 aynı uç-2 hücresini çelişki notu olmadan kullanıyor
Dosya: `sesli-diafon-analog.md:20` (F4) ve `:23` (F7)
F7 "marka dosyasında Orta ve çelişkili" diyor; F4 aynı hücreye ("uç 2: ses yokluğunda 1-2 arası kısa devre") çelişki notu olmadan dayanıyor. `knowledge/brands/audio-as202-sesli-diafon.md:27`: forum tablosu bunun tersini yazıyor.
Düzeltme: F4 satırına "kılavuz/forum çelişkili" ekle. Düzeltilmeli, küçük.

### A-D8 — Elektroda kaydı H1 dayanağı olarak sistem uyarısı olmadan geçiyor
Dosya: `knowledge/fault-cases/fc-zil-capraz-calma-001.md:37` (H1), `knowledge/sources/src-elektroda-domofon-7-16-2021.md:9`
H1 hücresi "Elektroda PL vakası: tek yönlü çapraz çalma, çözüm yok" diye zil teli kaçağı hipotezinin dayanakları arasında sayıyor. Sayfada tek yorum dijital sistem/ahize dekoderi yönünde ve sistem tipi bilinmiyor; zil teli kaçağını destekleyen hiçbir şey yok. Kaynak notu "sistem türü bilinmiyor" diyor (doğru) ama "(ya da 7'nin giriş kodunu)" ve "kod tuşlu panel olabilir" ifadeleri sayfadan doğrulanamadı (tahmin); not katılımcı yorumunu (dijital dekoder) hiç anmıyor.
Düzeltme: H1 hücresinden Elektroda'yı çıkar veya "mekanizma desteği yok, sistem belirsiz" yaz; kaynak notuna "bir katılımcı dijital sistemde arızalı ahize dekoderi diyor (yorum)" ekle, tahmini ifadeleri "Doğrulanmadı" işaretle. Not: kayıt "Arama özetinden okundu, tam sayfa açılmadı" diyor; bu denetimde sayfa açıldı, not güncellenebilir. Düzeltilmeli.

### A-N1 — Netelsan notunda "şubelerden şüpheleniyor"
Dosya: `knowledge/sources/src-kontrolkalemi-netelsan-ariza-2021.md:9`
Kaynakta konu sahibi daire içi diafon cihazlarından şüpheleniyor; "şube" bu depoda belirli bir komponent (şube kartı) anlamına geliyor, kaynak o ayrımı yapmıyor. Düzeltme: "dairelerdeki diafon cihazlarından". Not.

### A-D9 — Küçük SPEC boşluğu
Dosya: `knowledge/_SPEC.md:90, 93`
`field_verification` yalnız `cozuldu` için anlamlı; `outcome = bekliyor/kismen` iken değeri ne olacak yazılı değil (zorunlu mu, boş mu). Importer/uygulama için belirsiz. Düzeltme: "outcome ≠ cozuldu iken boş (null)". Not.

### A-N2 — N1 açık
`src-elektrikforen-etagenruf-glimmlampe-2014` URL'si doğrulanmamış kalıyor; kayıt dürüstçe işaretli. Yeniden denenmeli; engelleyici değil.

---

# B. Yeni dosyalar

## Engelleyici

### B-E1 — arXiv:2601.20404'ün yazarı yanlış
Dosya: `docs/references/context-dosyalari-literatur.md:17`
"Chatlatanagulchai vd." yazıyor. arXiv sayfası (v2): Lulla, Mohsenimofidi, Galster, Zhang, Baltes, Treude; başlık "On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents". Rakamlar (süre -%28,64; çıktı token -%16,58; 124 PR/10 depo; toplam token medyanı +%1,29) doğru, atıf yanlış. Yanlış atıf kaynak izlenebilirliğini bozar (kök CLAUDE.md: kaynak doğrulanabilir olmalı).
Düzeltme: "Lulla vd." ve arXiv numarasıyla başlık.

## Düzeltilmeli

### B-D1 — "anlamsız" ifadesi anlam tersliği
Dosya: `context-dosyalari-literatur.md:15`
"ikisi de anlamsız fark", "(p=0,21, anlamsız)": Türkçede "anlamsız" = manasız. Kaynak "istatistiksel olarak anlamlı değil" diyor (SWE-bench -0,5, p=0,87; CTXbench -2, p=0,37; geliştirici +2,4, p=0,21; hepsi anlamlı değil). Rakamlar doğru. Ayrıca birim karışık: LLM satırında "puan", geliştirici satırında "%" (kaynak % yazıyor, puan olup olmadığı belirsiz). SWE-bench'in "Lite" olduğu ve geliştirici etkisinin yalnız CTXbench'e ait olduğu yazılmamış.
Düzeltme: "anlamlı değil (p=…)" ; birimi kaynaktaki gibi "%" yaz; benchmark adlarını ekle; sürüm (v3) belirt, çünkü makale revize edilmiş.

### B-D2 — Maliyet iddiası geliştirici dosyalarına fazla genelleniyor; "talimat" ayrıntısı doğrulanmadı
Dosya: `context-dosyalari-literatur.md:15`
Satır başı "çıkarım maliyetini ortalama %20'nin üstünde artırıyor" özet (abstract) cümlesi; ayrıntıda LLM üretimli dosyalar +%20 (SWE-bench) / +%23 (CTXbench); geliştirici dosyaları "en fazla %19". "Talimatlar iyi izleniyor (daha çok test, daha çok keşif)": özet yalnız "talimatları iyi izliyor" diyor; adım sayısı artışı (+2,45 ... +3,92 adım) doğrulandı, "test/keşif" ayrıntısı bu denetimde doğrulanmadı. "Depo genel bakışı yardımcı olmuyor": makale bunu "ilgili dosyalara ulaşma adımlarını anlamlı azaltmıyor" diye ölçüyor; dosya bu kapsamı yazmıyor.
Düzeltme: maliyeti dosya türüne göre ayır; "test/keşif" kaldır ya da "doğrulanmadı"; genel bakış iddiasına ölçüt (adım sayısı) ekle.

### B-D3 — Aynı satırda (17) "Farklı yönde" ve ölçüt farkı
Dosya: `context-dosyalari-literatur.md:17` (satır "AGENTS.md ile medyan süre...")
Lulla çalışması doğruluk değil verimlilik ölçüyor; yalnız süre ve çıktı token farkı anlamlı (Wilcoxon p<0,05), girdi/önbellek/toplam token farkları anlamlı değil, görev tamamlama karşılaştırılabilir. Satır "toplam token +%1,3" diyor ama bunun anlamlı olmadığını yazmıyor; "Farklı yönde" etiketi gerçek bir çelişki varmış gibi okunuyor (A satırı: maliyet artar, burada çıktı token düşer; farklı metrikler). Bölüm başlığındaki Orta tanımındaki "sonuçlar kısmen çelişiyor" bu yüzden abartılı.
Düzeltme: "Tamamlayıcı ölçüt (verimlilik): yalnız süre ve çıktı token anlamlı; toplam token farkı anlamlı değil".

### B-D4 — REALM satırı: örneklem ve yorum
Dosya: `context-dosyalari-literatur.md:16`
"17 görev, iki ajan, 288 koşu, fark sınırı ≤10-15 puan" doğru. Eksik: görevler yalnız **3 depodan**; makalenin asıl bulgusu "gerçek AGENTS.md hiçbir ajanda yakın-başarısız görevi geçer yapmadı" ve görev zorluğunun ajana göre değişmesi (ρ=0,75). "güç yetersiz" yorum; kaynak "etki ~10-15 puanla sınırlandı" diyor (yani daha küçük etki dışlanamaz). Orta etiketi uygun, ama küçük örnek açıkça yazılmalı.
Düzeltme: "3 depo, 17 görev" ekle; "güç yetersiz" yerine "daha küçük etkiler dışlanamıyor (eşdeğerlik sınırı ~10-15 puan)".

### B-D5 — Bölüm B "rules yeniden enjekte edilir" yol kapsamlılar için kesin değil
Dosya: `context-dosyalari-literatur.md:24`
Doğrulanan (claude.com makalesi, Anthropic): kök CLAUDE.md sıkıştırmada yeniden okunur; alt dizin CLAUDE.md yeniden okunmaz, o dizine dokunulana kadar kaybolur (cümle birebir mevcut); yol kapsamsız rules yeniden enjekte edilir. Ama makale yol kapsamlı (`paths:`) rules'ın sıkıştırma sonrası davranışını ayrıca açıklamıyor ve alt dizin CLAUDE.md'yi "yol kapsamlı rules ile aynı davranış" diye anıyor; yani yol kapsamlılar da kaybolur olabilir. Dosyadaki "`.claude/rules/` kuralları sıkıştırmada yeniden enjekte edilir; `paths:` ile ... yüklenir" ifadesi bu ayrımı yapmıyor. D4 çıkarımı ("yol kapsamsız rules") doğru, B cümlesi değil. Memory sayfası doğrulanamadığı için "Yüksek" etiketinin yarısı (memory) benim tarafımdan teyit edilmedi.
Düzeltme: "yol kapsamsız rules yeniden enjekte edilir; yol kapsamlıların sonrası doğrulanmadı". Ek: hooks-guide'a göre `SessionStart` hook'u `compact` eşleştiricisiyle sıkıştırma sonrası kritik bağlamı yeniden enjekte etmek için resmî yol; `InstructionsLoaded` olayında `compact` yükleme nedeni var. Bu, rol sınırı kuralları için kullanılabilir bir seçenek, dosyada yok.

### B-D6 — C "Sınır" paragrafı: resmî olanı ikincil kaynağa ve Orta'ya bağlıyor; deny kuralı yolunu atlıyor
Dosya: `context-dosyalari-literatur.md:34`; ilgili `docs/references/claude-md.md` "Bu proje için uygulama" madde 1
Soru: "Edit|Write eşleştiricisi Bash yazmalarını yakalamaz" resmî mi çıkarım mı? **Eşleştirici kısmı resmî:** hooks-guide, "`Edit|Write` eşleştiricisi yalnız `Edit` veya `Write` aracı kullanıldığında çalışır; `Bash`, `Read` ya da başka araçta çalışmaz". "`echo > knowledge/x.md` bunu atlatır" ise bu resmî cümleden **doğrudan mantıksal çıkarım** (Bash'in yazma yolu olduğu zaten bilinir). Dosya bunu castel.studio/anomity.ai'ye dayandırıp Orta yazıyor; resmî dokümana dayanıp Yüksek olmalı.
Daha önemlisi eksik: izin dokümanına göre Edit/Read deny kuralları Bash'te tanınan dosya komutlarını (`cat, head, tail, sed, tee`) **ve yönlendirme hedeflerini (`> dosya`)** da kapsıyor; kapsamayan yalnız dosyayı kendisi açan keyfî alt süreçler (Python/Node betiği) ve dosya adı vermeyen komutlar; tam kapsama için sandbox. Dosyadaki cümle `cat/head/tail/sed` sayıp `tee` ve yönlendirmeyi atlıyor, bu yüzden "Bash yolu açık, hook'la kapatılmalı" izlenimi veriyor. Pratik öneri: `permissions.deny` içinde `Edit(knowledge/**)` ve `Edit(docs/**)` + sandbox, hook'a ek olarak. Ayrıca izin dokümanında Write aracı için deny denetiminin v2.1.228+ gerektiği ve NotebookEdit'in kapsam dışı olduğu yazıyor; GitHub issue notundaki "sessizce uygulanmıyor" şüphesi sürüm farkı olabilir (dosyada Doğrulanmadı, uygun).
Doğrulanan diğer C cümleleri (hepsi **Yüksek** olarak doğru): izin kuralları Claude Code tarafından uygulanır, CLAUDE.md "ne yapabilir"i değiştirmez; sıra deny→ask→allow, ilk eşleşen belirler; PreToolUse `deny` `bypassPermissions` ve `--dangerously-skip-permissions` dahil her modda (`dontAsk` dahil) engeller; exit 2 engeller ve stderr geri bildirim olur (bazı olaylarda engellenemez); eşleşen tüm hook'lar çalışır, en kısıtlayıcı karar (`deny, defer, ask, allow`) geçerli; sandbox Bash/PowerShell/Monitor ve alt süreçlerine uygulanır.
Düzeltme: eşleştirici cümlesini hooks-guide'a bağla (Yüksek); `tee`/yönlendirme kapsamını ekle; deny-kuralı + sandbox seçeneğini yaz; `claude-md.md` madde 1'e aynı alternatifi ekle.

## Düzeltilmeli (D bölümü)

### B-D7 — Bölüm D: "ölçümler faydasız gösteriyor" ve "Orta, ölçülmedi" etiketi
Dosya: `context-dosyalari-literatur.md:20, 37, 39, 41`
- Başlık "Orta, ölçülmedi": kök kuralda Orta = birden fazla bağımsız vaka/analoji ile tutarlı; "ölçülmedi" bu depo için doğru, o hâlde çıkarımlar **Doğrulanmadı** (analoji) etiketi taşımalı; ölçüm dayanağı olan yalnız "LLM üretimli dosya ve genel bakış genel olarak fayda göstermedi" kısmı.
- Madde 1: Makalenin ölçtüğü şey "genel bakış, ilgili dosyaya ulaşma adımını anlamlı azaltmıyor" (Python/SWE-bench tarzı kod depoları; 12 geliştirici dosyasından 8'i genel bakış içeriyor). "Bu tür içeriğin faydasız olduğunu gösteriyor" fazla geniş; bu depo az sayıda dosyalı, kod dışı içerik ağırlıklı bir bilgi tabanı, ve kök "Dizin haritası" **sahiplik bilgisi** de taşıyor (`knowledge/` kimin), yani saf genel bakış değil. Kök kural dosyasında tek başına kaldırılacak bir sonuç çıkmaz. Madde "Aday ... karar için ölçüm" diye ihtiyatlı, bu iyi; ama ilk cümle "ölçümler ... gösteriyor" diyor.
- Sınır (satır 20): "çalışmalar çoğunlukla Python kütüphane depolarında" yalnız Gloaguen/SWE-bench için teyit edildi; diğer ikisi için teyit yok. "Çalışmaların önerdiği **tek** faydalı içerik türü" abartı: Gloaguen "standart olmayan uygulamaları belirtmede faydalı" diyor, "tek" demiyor.
- Madde 3 ("/init ile üretilmiş dosya"): makalede LLM üretimli dosyalar ajanların kendi üretim istemleriyle yapıldı; Claude Code `/init`'in birebir bu olduğu doğrulanmadı. "gerçek fayda göstermedi" anlamlı değil sonuç; "zararlı" demiyor. Madde ihtiyatlı yazılmış, yalnız "/init" eşitlemesi Doğrulanmadı.
- Madde 4: `knowledge/CLAUDE.md` yalnız knowledge'a özgü kural taşısın önerisi doğru; ancak B-D5 nedeniyle "yol kapsamsız rules" ek seçeneği kaynaklı.
Düzeltme: başlığı "Doğrulanmadı (çıkarım; ölçüm yalnız A'daki kısım için)" yap; madde 1'in ilk cümlesine ölçüt ve kapsam ekle ("genel bakış, ilgili dosyaya ulaşma adımı azaltmadı, Python depolarında"); "tek faydalı" → "faydalı bulunan tür".

### B-D8 — `claude-md.md` uyarısı etiketsiz ve "/init gibi" genelleştirmesi
Dosya: `docs/references/claude-md.md:21`
Tablodaki satırlar Yüksek (resmî dokümana) bağlı; eklenen uyarı ön baskıya (arXiv, v3) dayanıyor, etiket yok ve atıf dosyası "tur 1, taslak, denetlenmedi" (literatür başlığı). "`/init` gibi" Claude Code `/init`'i doğrudan kapsamadığı için kesin değil. Ölçülen: LLM üretimli dosyalar başarıyı anlamlı değiştirmedi, maliyet +%20/+%23.
Düzeltme: sonuna "(Orta: ön baskı, `/init` ile birebir aynı üretim değil)" ekle; "olduğu gibi kullanma" tavsiyesi kalabilir (öneri, iddia değil).

## Not

### B-N1 — Bölüm A etiket tanımı kök kuralla çakışıyor
`context-dosyalari-literatur.md:9`: "Orta = ön baskı/çalışma, bağımsız tekrar var ama sonuçlar kısmen çelişiyor". Kök CLAUDE.md'de Yüksek "üretici dokümanı veya ölçümle doğrulanmış"; hakemli bir çalıştay makalesi (REALM) tek başına ölçümdür. Etiketleme kaynak sınıfına göre yapılmış ve tutarlı kullanılmış, kabul edilebilir; ama tanım farklı olduğunu "bu dosyaya özgü" diye belirtmek iyi olur.

### B-N2 — Doğrulanamayan Bölüm B maddeleri
`context-dosyalari-literatur.md:25-28` (4 atlama, <200 satır, skill 1.536 karakter, auto memory 200 satır/25 KB, subagent): memory sayfası açılamadığı için bu denetimde teyit edilmedi. Bunlar "Yüksek" etiketli; sonraki turda aynı sayfa tekrar açılabilirse doğrulanmalı (alt dizin CLAUDE.md satırı claude.com makalesiyle teyitli).
