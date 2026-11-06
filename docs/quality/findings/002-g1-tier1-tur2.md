# 002 — G1 denetimi, Tier-1 turu 2 (commit 3105734, dal setup/foundation)

Tarih: 2026-11-07 · Denetçi: ayrı ajan (işi üretmemiş) · Kapsam: 30b66ba..3105734

## Sonuç: GEÇMEDİ

2 engelleyici, 9 düzeltilmeli, 3 not. Engelleyiciler kapanana kadar G1 geçilmez.

Dosya sahipliği: temiz. `git diff 30b66ba..3105734 --stat` 11 dosya; `src/`, `supabase/`, `index.html` yok. Tümü `knowledge/` ve `docs/briefs/` (sohbet alanı).

## URL doğrulama özeti (WebFetch)

| Kaynak | Sonuç |
|---|---|
| src-siedle-servicehandbuch | Açıldı. Bölüm "Logische Fehlersuche im neuen Siedle HT 711 System" doğrulandı |
| src-elektrikforum-siedle-coklu-calma-2019 | Açıldı, not büyük ölçüde doğru (bkz. D3) |
| src-mikrocontroller-str-tuersprechanlage-2019 | Açıldı, not kısmen şişirilmiş (bkz. D2) |
| src-golmar-4n-kurulum | Açıldı, not doğru ama kapsam sınırı eksik (bkz. D4) |
| src-fermax-citymax-4n-semalar | Açıldı, not bağlamından koparılmış (bkz. D5) |
| src-elektrikforen-etagenruf-glimmlampe-2014 | **Doğrulanamadı.** WebFetch "client_error" verdi, sayfa alınamadı. Bu kaydın notundaki hiçbir iddia (ışıklı lamba, sonsuz direnç, "kendi önceki vakası") doğrulanmadı. Not zaten "Arama özetinden" demiyor; tek kaynaklı H4 analojisi bu haliyle denetlenemez (bkz. N1) |
| elektroda.pl #3796225 (PL satırı) | Doğrulanamadı: arama bu başlığı döndürmedi; sonuç listesi çok sayıda ilgisiz/ilgili elektroda konusu gösterdi (bkz. D8) |

## Engelleyici

### E1 — F3 ailesinin kaynak eşlemesi kaynak kaydıyla desteklenmiyor
Dosya: `knowledge/fault-families/sesli-diafon-analog.md:19`
F3 "Sürekli/kendiliğinden çalma (dış zil durmadan)" belirtisi `src-kontrolkalemi-netelsan-ariza-2021`'e dayandırılıyor ve "Netelsan" marka kaydı veriliyor. Kaynak kaydının notu (`src-kontrolkalemi-netelsan-ariza-2021.md:9`) yalnız "iç zil bağlanınca panel butonuyla farklı daireler çalıyor; çözüm yok" diyor. Sürekli çalma / dış zilin durmaması hiçbir kayıtta (`knowledge/` genelinde `kendiliğinden|sürekli|durmadan` araması) geçmiyor. Aile, kaynakta olmayan bir belirtiye "kayıtlı olduğu yer" atfediyor; satır uydurma.
Düzeltme: F3 satırında "Kayıtlı olduğu yerler" = "yok (Doğrulanmadı)", marka kaydı "yok"; ya da kaynak açılıp belirtinin geçtiği yer alıntısız belirtilsin. Aksi halde F3'ü `status: kaldirildi` değil, "kaynaksız taslak" olarak işaretle. Q-TETIK'teki "kendiliğinden" seçeneği Doğrulanmadı yöntemdir, kalabilir.

### E2 — Arama günlüğü: "Bulunamadı" ve durma kuralı iddiası sorgu sayısıyla uyuşmuyor
Dosya: `knowledge/sources/arama-gunlugu.md:38` (ve 47-55 sorgu listesi)
Satır "Netelsan şube kart şeması (3 sorgu) ... Bulunamadı ... Durma kuralı (3 sorguda yeni bilgi yok) uygulandı" diyor. Sorgu listesinde kart şemasına yönelik tek sorgu var (`...H.E.PCB.01032 devre şeması servis kılavuzu`). Diğer ikisi ayrı konular: SMA.00005 şube bağlantısı (satır 39) ve daire içi bas-konuş devresi (satır 40), bunlar kendi satırlarında da sayılmış. Yani aynı üç sorgu hem "3 sorgu" diye kart şemasına, hem ayrı satırlara yazılmış; "3 sorguda yeni bilgi yok" durma kuralı kart şeması için uygulanmadı. Oturum 1 günlüğü (satır 30) kart şemasını açıkça "aranmadı, bulunamadı değil" diye ayırmıştı; bu tur tek sorguyla "Bulunamadı"ya çevrildi. Ayrıca sorgudaki `H.E.PCB.01032` parça numarası tahmin (günlük notu satır 57 bunu doğru söylüyor), ama tahmin numarayla yapılan tek sorgunun boş dönmesi şemanın bulunmadığını göstermez.
Düzeltme: Satırı "tek sorgu (tahmini parça no ile), sonuç yok; kart şeması **yeterince aranmadı**" yap; durma kuralı cümlesini sil ya da gerçekten 3 ayrı kart şeması sorgusu yapıp listele. "Henüz taranmayan" satırına Netelsan kart şemasını (yetersiz arandı) geri koy.

## Düzeltilmeli

### D1 — fault_family satırlarında satır sonu güven etiketi yok; dosya geneli Orta
Dosya: `sesli-diafon-analog.md:6, 17-23`
G1 "her iddia satır sonunda etiketli" diyor. F1-F7 satırları etiketsiz; "analoji" kelimesi var ama Yüksek/Orta/Doğrulanmadı yok (yalnız F4'te Doğrulanmadı). Dosya geneli `confidence: Orta`, oysa kaynaklarının çoğu forum (Doğrulanmadı) ve analoji; Orta "birden fazla bağımsız vaka/analoji ile tutarlı" ister. Taksonomi yapı kararı olduğu için kabul edilebilir ama etiket gerekli.
Düzeltme: aile tablosuna "Etiket" sütunu (F1 Orta: üç bağımsız kaynakta belirti var; F2, F6, F7 analoji → Orta/Doğrulanmadı; F3 Doğrulanmadı; F5 Doğrulanmadı) ya da dosya geneli `confidence: Doğrulanmadı`.

### D2 — STR kaydı ve H1'de "kısa devre bulundu" abartısı
Dosya: `src-mikrocontroller-str-tuersprechanlage-2019.md:9`; `fc-zil-capraz-calma-001.md:37` (H1 hücresi)
Kaynakta konu sahibi hatlara dağıtım kutusuna kadar izledi ve kısanın kutunun ardında olduğunu yazıyor; süpürgelik çivileme yalnızca şüphe ("emin değilim"). Kayıt "kısa devre ... bulundu" diyor, vaka dosyası "kısa dağıtım kutusunun ardında bulundu" diyor. Bu konu sahibinin kendi değerlendirmesi, ölçüm/teyit yok, çözüm yok. Ayrıca belirti çapraz çalma değil (54 çalmıyor, 56 çalıyor); H1 dayanağı olarak yalnız "butonlar arası kısa" mekanizma sınıfı için zayıf.
Düzeltme: "konu sahibine göre kısa devre dağıtım kutusunun ardındaki hatta (teyit yok)". H1 hücresinde "bulundu" kelimesi kalksın.

### D3 — Siedle forum kaydı: "1+n", "Katılımcılar" ve "öneriliyor" kaynakta yok/farklı
Dosya: `src-elektrikforum-siedle-coklu-calma-2019.md:9`; `fc-zil-capraz-calma-001.md:37`; `sesli-diafon-analog.md:37`
Sayfada model TLM 511 NG 402-2, 11 ev telefonu ve "ERT" geçiyor; "1+n" sistem adı çıkarılamadı (Doğrulanmadı). Çağrı telleri 7.1-7.11 ve değme yorumu tek katılımcıdan (Pumukel), "katılımcılar" çoğul değil. Ortak dönüşün havada olması bir soru/ipucu (patois), "öneriliyor" fazla. Notun kalan kısmı (kök neden bildirilmedi) doğru. Asıl sorun: `sesli-diafon-analog.md:37` Q-ONCESI etiketi "Siedle ve STR forumlarında tadilat/çivileme şüphesi" diyor; Siedle forum konusunda tadilat/çivileme yok, yalnız bükme-bantlı eklerin zamanla bozulması var. Tadilat/çivileme yalnız STR'de.
Düzeltme: "1+n"i kaldır ya da Doğrulanmadı yaz; "bir katılımcı"; Q-ONCESI etiketi "STR forumunda çivileme şüphesi; Siedle forumunda zamanla bozulan bükme-bant ekler" olsun. (Elektrikforen kaydı doğrulanamadığı için "Siedle" adı altında üçüncü forum sayılamaz.)

### D4 — Golmar kaydında kapsam sınırı eksik
Dosya: `src-golmar-4n-kurulum.md:9`
Kılavuzda "çağrı alınmıyor → ses modülünün CP klemensine bağlantı" adımı yalnız Stadio Plus kapı panelleri için geçerli; not bunu genelleştiriyor. Paralel cihazda çağrı teli kesitinin ikiye katlanması ve daire başına 3 cihaz doğru. `language: en` ama metinde Fransızca terim (borne CP) var; önemsiz.
Düzeltme: nota "yalnız Stadio Plus paneli" ekle. Ayrıca F6 için Golmar'ın asıl desteği (trafo TF-104 SEC çıkışı 12-17 V AC, aralık dışıysa trafoyu ayırıp tekrar ölç, kısa devre şüphesi) nota yazılsın; şu an F6/Q-KAPSAM dayanağı notta görünmüyor.

### D5 — Fermax tanılama önerisi bağlamından koparılmış
Dosya: `src-fermax-citymax-4n-semalar.md:9`
Kaynakta "arızalı telefonu doğrudan amplifikatöre (uç 1, 2, 3, 6) bağla" önerisi **ses sorunları** içindir ve sonuç genelde "kullanılan kablolarda kesit yetersizliği"dir. Not bunu genel "kurulumu eleme" tanılaması gibi veriyor; çapraz çalma bağlamında yanıltıcı. Çağrı sinyalinin amplifikatörde üretilmesi (Cp1, C ortak uç) doğru. Ayrıca bu kayıt `sesli-diafon-analog.md`'de hiçbir ailede referanslanmıyor (öksüz).
Düzeltme: nota "ses sorunları için" ve "genelde kesit yetersizliği" ekle; F4 (konuşma yok) satırına analoji olarak bağla ya da neden bağlanmadığını yaz.

### D6 — Siedle servis el kitabı kaydı ve H1'e aktarımı fazla geniş
Dosya: `src-siedle-servicehandbuch.md:9`; `fc-zil-capraz-calma-001.md:37`
Kılavuz: "bir telefon çalmıyor, diğerleri çalışıyor ama başka işlevleri yok → 1 ile 7 arası kısa" ve ayrı satırda "bir telefon çalmıyor, diğerleri düzgün → 1 ve 7 yer değiştirmiş ya da ahize oturmamış". Kayıt "diğerleri çalıyor" diyor, "başka işlevleri yok" kaydı düşmüş. En önemlisi H1'e "iletkenler arası kısayı belgelenmiş arıza sınıfı olarak veriyor" diye eklenmiş: 1 ve 7 HT 711'de iki dairenin çağrı dönüş teli olarak değil bu tek telefonun iletkenleri olarak geçiyor; "iki dairenin zil dönüş teli arasında kaçak" için doğrudan dayanak değil, yalnız "iletkenler arası kısa" genel sınıfı. Doğru: servis kitabı gerçekten açıldı ve bölüm var (Yüksek güvenilirlik), "tam PDF açılmadı" notu artık güncel değil (bu denetimde açıldı).
Düzeltme: nota "diğerlerinin başka işlevi yok" ve "1/7 aynı telefonun iletkenleri" ekle; H1 hücresinde "iki dairenin dönüş teli" ifadesine bağlama, "genel iletkenler arası kısa sınıfı (analoji)" yaz. Bu yüzden H1'in "Doğrulanmadı" etiketi doğru kalıyor.

### D7 — Aile tablosundaki kaynak-aile eşlemelerinden desteklenmeyenler
Dosya: `sesli-diafon-analog.md:17, 20, 21, 23`
- F1 Audio: `src-kontrolkalemi-audio-ariza-notlari` kaydı çapraz çalma belirtisi içermiyor (yalnız "ışıklı buton olmamalı" notu, `audio-as202-sesli-diafon.md:39`). Oturum 1 günlüğü (`arama-gunlugu.md:18`) "Audio notları s.19" vakasını anıyor; destek olabilir ama kaynak kaydında yazılı değil. Kayda yaz ya da F1'den çıkar.
- F5 Audio: `src-audio-as202-kilavuz` için "kapı açılmıyor" arıza satırı Audio marka dosyasında yok (`grep açılm` sonuçsuz). F5'te Simge 7/8 kuru kontak desteği var, Audio kısmı doğrulanamadı.
- F7 Audio: AS-202 için uğultu desteği Audio marka dosyasında yalnız uç 2 satırında ("konuşmada kapıda uğultu varsa 2 kopuk olabilir", Orta, çelişkili). Bu "Vızıltı/ıslık" ailesini besler ama "ıslık" için kayıt yok.
- F4: "Kayıttaki tablo F4'e eşlenmedi, yeniden okunmalı" diyor ama Audio marka dosyası uç 2 satırı zaten "ses yokluğunda 1-2 arası kısa devre kontrolü" içeriyor; iç tutarsızlık, dürüst ama güncel değil.
Düzeltme: desteği yazılı olmayanlar için "kayıtta yazılı değil (Doğrulanmadı)" ya da kaynak kaydına ilgili satırı ekle.

### D8 — PL/RU satırları: "dil taraması" tek sorguya dayanıyor, PL örneği doğrulanamadı
Dosya: `arama-gunlugu.md:41-42, 58`
Her dil için tek sorgu (satır 51 PL, 52 RU). Satır 41'deki "elektroda #3796225" doğrulanamadı: arama bu numarayı vermedi, elektroda'da aynı belirtiyle ilgili çok sayıda konu çıkıyor (arama listesinde ~20 konu); hiçbiri açılıp incelenmemiş görünüyor. "Eşleşen vaka yok" iddiası "tek sorguda 1 konu incelendi, eşleşme yok" olmalı. RU satırı tutarlı ve temkinli ("paralel hatlı analog çağrı teli ile eşleşmiyor"), ama yine tek sorgu. Satır 58 "Henüz taranmayan: IT, FR" PL/RU/DE'yi tam taranmış gibi gösteriyor; satır 32 (eski) ile çelişiyor: satır 32 hâlâ "PL, RU, DE, IT taranmadı" diyor.
Düzeltme: satır 32'yi "Oturum 2'de kapandı/değişti" notuyla güncelle; PL/RU/DE için "tek sorgu, sınırlı" yaz; elektroda numarasını kaynak ve inceleme sayısıyla destekle ya da çıkar.

### D9 — Brief 002 ile _SPEC çözüm kaydı sözlüğü arasındaki tutarsızlıklar
Dosya: `_SPEC.md:88, 93`; `docs/briefs/002-...md:10, 12, 19`
1. `outcome` değeri: SPEC `cozulmedi`, brief `çözülemedi` (aynı kavram, iki ad). Kimlik sözlüğü tek kaynak olmalı.
2. SPEC kuralı (satır 93): "`cozuldu` yalnız `field_verified = true` ile ya da 'doğrulanmadı' işaretiyle saklanır". `field_verified` bool; üçüncü bir "doğrulanmadı" durumu yok. Bu haliyle `field_verified = false` ile `cozuldu` zaten serbest, kural boş. Tanım: ya `field_verified` üç değerli (dogrulandi / dogrulanmadi / bilinmiyor) olsun ya da kural "false iken analizde ayrı sayılır" desin.
3. Brief madde 1.2: "cevaplara göre hangi hipotezlerin canlı/elenmiş olduğunu göstermeli" ile parantez "hipotez durumu elle işaretlenir" birbirini zorluyor; ayrıca fault_family "Ne ayırır" sütunu serbest metin, soru cevabı → hipotez etkisi makine okunur bir eşleme olarak hiçbir yerde yok. Code ya tanı mantığı uydurur (brief §4 "tanı koymaz" ile çelişir) ya da hiç gösteremez.
4. Brief §2 "aile/soru/hipotez kodları kalıcıdır"; SPEC yalnız aile ve soru kodlarını kalıcı ilan ediyor (satır 78). Hipotez ve `step_id` için kalıcılık yok, üstelik vaka dosyası bu kapıda bile test numaralarını değiştirdi (001 bulguları: test 6/7 yeniden yazıldı, 7b eklendi). Kayıtlar bozulabilir.
Düzeltme: SPEC'e hipotez/step kimlik kuralı (eklenir, yeniden numaralanmaz) ve tek `outcome` değer listesi; brief'te `cozulmedi`; hipotez etkisini ya "elle işaretle, uygulama göstermez" yap ya da SPEC'e `answer → hypothesis_effect` tablosu şablonu ekle (G2 işi).

## Not

### N1 — elektrikforen kaydı (H4 analojisi) denetlenemiyor
`src-elektrikforen-etagenruf-glimmlampe-2014.md:9`, `fc-zil-capraz-calma-001.md:40`. URL açılamadı. Kayıt Doğrulanmadı + "tek kaynak" olarak doğru etiketli ve H4 hücresinde bu kaynak kullanılmıyor (H4 hücresi hâlâ yalnız Audio notuna dayanıyor), yani zarar yok. Ama günlük (`arama-gunlugu.md:43`) "3 kullanılabilir kayıt" sayıyor: bu kayıt doğrulanmadan sayıldı. Yeniden denenmeli ya da "içerik doğrulanamadı" notu eklenmeli.

### N2 — Q-KAPSAM etiketi
`sesli-diafon-analog.md:33`: "Orta" Siedle ve Golmar için kabul edilebilir (Siedle: tüm telefonlar ölü → ortak besleme, 24 V altı; Golmar: sistem çalışmıyorsa trafo çıkışı). Ama "şaft grubu" seçeneği için kaynak yok ve Q-KAPSAM cevabı çapraz çalmayı değil "ölü sistem"i ayıran kaynaklara dayanıyor. Etikette "yalnız tümü/ortak kısım yönü için" yazılsın. Q-… sayısı (7) şişirilmemiş; kaynaksız olanlar zaten Doğrulanmadı.

### N3 — Kök CLAUDE.md etiket ve analoji kuralları
(1) Başka marka şemaları: Siedle, Golmar, Fermax, Commax, Tektone kayıtlarının hepsi notta "başka marka, analoji" diyor; hiçbiri Netelsan ucu diye yazılmamış (Netelsan marka dosyası 'okunabilen' kısmı ayrı). Kablo renginden işlev çıkarımı bu diff'te yok. "Yüksek" yalnız `uretici` sınıfı kayıtlarda (Siedle, Golmar, Fermax); Fermax ve Golmar üçüncü taraf barındırılan üretici belgesi, notlar bunu söylüyor. Tahmin yok, uyuyor. Fermax/Golmar'ın hosting kaynağının üretici baskısı olduğu doğrulanamadı (not: "üçüncü taraf barındırma"). Sorun yok.
