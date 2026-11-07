# Kod inceleme adayları (kod-analizi skill'inin ilk koşusu, 2026-11-07)

Yalnız inceleme yapıldı. `src/` ve `supabase/migrations/` değiştirilmedi. Davranışlar, canlıya dokunmadan atılabilir yerel PG 16 veritabanında gerçek fonksiyon çağrısıyla ölçüldü (Yüksek). "Bu bir hata mı" sorusunun cevabı iş kuralına bağlı olduğunda öyle yazıldı.
Brief'teki üç örnek vaka koda göre yeniden kuruldu. Kodda malzeme/işçilik hesabı **yok** (finans modülü sonraki faz). Vaka 2, bugün kodda gerçekten bulunan tek para alanı `tahmini_bedel` üzerinden kuruldu.

**Ortak bulgu, üç vakanın da "neden fark edilmedi" cevabı:** `svc_s_is_olustur`, `svc_s_is_guncelle`, `istemci_id`, `tahmini_bedel` ve `'ertelendi'` test dosyalarında 0 kez geçiyor (`grep -c`). `db-erisim.sql` ve `db-oturum.sql` yetkiyi ve oturumu ölçüyor, iş mantığını ölçmüyor.

Öncelik sırası (skill FMEA kuralı: önce Ş = 5, sonra RPN): **Vaka 2 (NaN, Ş5) → Vaka 2 (virgüllü tutar, RPN 48) → Vaka 3 → Vaka 1.**

---

## Vaka 1 · İş kaydı: tekrar deneme kaydı "başarısız" gösteriyor

| Analiz | Çıktı |
|---|---|
| Görünen problem | Sahada iş açılıyor. Zayıf ağda istemci aynı `istemci_id` ile yeniden deniyor, ya da Burak çift dokunuyor. İkinci istek hata alıyor, iş aslında oluşmuş. Kullanıcı "kaydedilmedi" sanıp yeniden açarsa çift kayıt çıkar. Boş `istemci_id` ise kaydı tamamen düşürüyor |
| Kod kanıtı | `supabase/migrations/0004_modul1_saha.sql:175-176` kontrol eder, kilit yoktur, `(p->>'istemci_id')::uuid` korumasızdır. `:208-210` ekleme yapar, `nullif(…)::uuid` korumalıdır. `:14` `unique` kısıttır. **Ölçüldü:** iki eşzamanlı istekte ikincisi `23505 svc_isler_istemci_id_key` aldı, kayıt 1 tane (A2). `"istemci_id":""` verince 22P02 döndü, iş oluşmadı (A1). API katmanı: `src/api/panel.js:93-113` `createJob` canlıda olmayan `svc_jobs`'a yazıyor ve service_role kullanıyor (`src/api/_supa.js:4`). `panel.js:34` DB hata metnini tarayıcıya veriyor |
| Ishikawa | Arayüz: başarı geri bildirimi ve çift dokunuş koruması yok (ekran yok). Veri: `unique` doğru ama ihlal "zaten var" diye ele alınmıyor. İş mantığı: kilitsiz "kontrol et, sonra ekle"; aynı alan iki satırda farklı dönüştürülüyor. Entegrasyon: eski API eski tablolara bakıyor. Mimari: çevrimdışı kuyruk tekrar denemeye dayanıyor. Test: eşzamanlılık testi yok |
| 5 Neden | 1. İkinci istek hata aldı (test: A2). 2. `unique` ihlali yakalanmadı (test: `:208` `on conflict` yok). 3. İlk kontrol ikinci isteğe birincinin kaydını göstermedi (test: A2'de B, A commit etmeden önce okudu). 4. Kontrol ile ekleme arasında kilit yok (test: `:175-210` arasında `advisory_xact_lock` yok). 5. Tekillik "önce bak" diye tasarlandı, eşzamanlılık düşünülmedi (test: kod yorumu `:166` "tekrar denemeyi yutar" diyor) |
| RCA | Kilitsiz kontrol-sonra-ekle ve `unique` ihlalinin tekrar deneme sayılmaması. **Yüksek** (ölçüldü) |
| FMEA | Eşzamanlı tekrar deneme: Ş4 O3 T3 = 36. Boş `istemci_id`: Ş4 O2 T3 = 24. Aile: `svc_talep_olustur` `:43-44` kontrolü `:50` kilidinden önce yapıyor, aynı desen (ADAY, ölçülmedi) |
| Çözüm (önerilir) | `insert … on conflict (istemci_id) do nothing returning id`, boşsa mevcut kaydı `select`. `istemci_id` tek yerde `nullif` ile çözülür. `svc_talep_olustur`'da kontrol kilidin içine alınır. Yeni migration olur, Burak onayı gerekir. `src/api` yeniden yazılırken hata metni `BEE_*` koduna eşlenir |
| Test (önerilir) | Yerel kurulumda iki psql oturumu: aynı `istemci_id` ile ikinci çağrı aynı `id`'yi döndürmeli. Bozma: `on conflict` kaldırılınca kırmızı. Boş `istemci_id` yeni iş açmalı |
| Önleme (önerilir) | `istemci_id` kullanan her fonksiyonda `on conflict` olmasını isteyen bir statik kontrol (`dogrula.sh`). Aile deseni skill'de yazılı |

## Vaka 2 · Tutar: isteğe bağlı bir alan kaydı düşürüyor ya da toplamı zehirliyor

| Analiz | Çıktı |
|---|---|
| Görünen problem | Burak tahmini bedeli Türkçe biçimle yazıyor (`1.250,50`) ve iş kaydı tamamen oluşmuyor. Ya da bozuk bir istemci `"NaN"` gönderiyor, kayıt kabul ediliyor ve bütün toplamlar `NaN` oluyor |
| Kod kanıtı | `0004_modul1_saha.sql:18` `check (tahmini_bedel >= 0)`. `:213` ekleme ve `:262` güncelleme `nullif(p->>'tahmini_bedel','')::numeric(12,2)` kullanıyor. **Ölçüldü:** `"1.250,50"` ve `"12,5"` 22P02 verdi, iş kaydı 0 (B3). `"12.345"` sessizce 12.35'e yuvarlandı. `"NaN"` kaydedildi, `>= 0` kontrolünden geçti, 250 ile toplamı `NaN` çıktı (B4). `Infinity` ve ≥ 10^10 reddedildi. Aile: `oncelik` eklemede `nullif`'li (`:212`), güncellemede `nullif`'siz (`:257`). `""` güncellemeyi 22P02 ile düşürdü (C4) |
| Ishikawa | Arayüz: tutar alanı biçimi tanımsız (ekran yok; TEHAİ'deki `data-alan="tutar"` deseni burada yok). Veri: `check` NaN'ı kabul ediyor (PostgreSQL'de NaN her sayıdan büyük sayılır). İş mantığı: dönüşüm her alanda ayrı yazılmış, aynı alan iki fonksiyonda farklı. Entegrasyon: JSON sayı ile metin ayrımı yok. Mimari: isteğe bağlı bir alanın hatası bütün kaydı düşürüyor. Test: `tahmini_bedel` için test yok |
| 5 Neden | 1. Kayıt oluşmadı (test: B3 kayıt 0). 2. Dönüşüm hatası bütün işlemi geri aldı (test: 22P02 `svc_s_is_olustur line 41`). 3. Girdi normalize edilmeden DB'ye geldi (test: `:213` doğrudan `::numeric`). 4. Normalizasyonun yeri (API mi, DB mi) belirlenmedi (test: `src/api`'de tutar işleyen kod yok, `grep`). 5. Para alanı için tek bir dönüşüm kuralı yok (test: `nullif` deseni alan alan tekrar ediyor) |
| RCA | Para ve sayı alanları için tek bir doğrulama ve dönüştürme kuralı yok. NaN'ı dışlamayan `check`. **Yüksek** (ölçüldü) |
| FMEA | NaN kaydı: Ş5 O1 T5 = 25, ama Ş = 5 olduğu için **önce**. Virgüllü tutar kaydı düşürüyor: Ş4 O4 T3 = **48**. Sessiz yuvarlama: Ş3 O2 T5 = 30. `oncelik` güncellemede boş değer: Ş3 O2 T3 = 18 |
| Çözüm (önerilir) | DB: `check (tahmini_bedel >= 0 and tahmini_bedel <> 'NaN')`, 2 ondalıktan fazlası yuvarlanmaz, reddedilir. API: tek normalizasyon fonksiyonu (TR biçimi → nokta). Hata alan adını taşır (`BEE_GECERSIZ: tahmini_bedel`), böylece ekran hangi alanın yanlış olduğunu söyler. İsteğe bağlı alanların dönüşümü tek yardımcı fonksiyonda toplanır |
| Test (önerilir) | DB testi: `NaN` reddedilir, `"1.250,50"` alan adıyla reddedilir, `12.345` reddedilir, `oncelik:""` eklemede ve güncellemede aynı sonucu verir. Bozma: `<> 'NaN'` kaldırılınca kırmızı |
| Önleme (önerilir) | Statik kontrol: `numeric` sütunlarının `check`'inde NaN dışlaması. Aile deseni `\(p->>'[a-z_]+'\)::` skill'de |

## Vaka 3 · Durum: aynı iş farklı yerlerde farklı ya da hiç görünmüyor

| Analiz | Çıktı |
|---|---|
| Görünen problem | Ertelenen bir iş listede yok. "İptal" denen iş "kapandı" görünüyor. İstemci ekranı başka durum adları gösteriyor |
| Kod kanıtı | Üç sözlük var. DB `asama` (`0001:109`) ve `durum` (`0001:110` canlıda: `acik`, `beklemede`, `kapandi`, `iptal`; `0006:9` sonrası: `acik`, `ertelendi`, `kapandi`, `iptal`, `kacirildi`). İstemci tarafı `src/api/panel.js:11` ve `src/assets/js/svc-core.js:1-8` (`yeni`, `planlandi`, `yolda`, `devam`, `tamamlandi`, `iptal`, eski model). **Ölçüldü, canlı ara durum (0005):** `beklemede` kabul ediliyor ama `svc_s_isler` (`0004:138-139`) ve `svc_s_ozet` (`0004:116-117`) onu iki listede de göstermiyor (C1: 0/0). `ertelendi` reddediliyor (C2: 23514). `svc_s_is_guncelle` `0004:229`: aynı istekte `durum=iptal` ve `asama=tamamlandi` gelince sonuç `kapandi`, iptal sessizce yutuldu (C3). İptal edilmiş iş `asama=tamamlandi` ile `kapandi`'ya döndü (C5) |
| Ishikawa | Arayüz: istemci sözlüğü DB'den kopuk. Veri: CHECK ile fonksiyon filtreleri ara durumda uyuşmuyor. İş mantığı: `asama` ile `durum` arasındaki bağ 4 `elsif` ile elle eşitleniyor (`0004:229-232`), çelişkili istek reddedilmiyor. Entegrasyon: eski API eski durum adlarını kullanıyor. Mimari: aynı bilgi iki sütunda; izinli geçişler tanımlı değil. Test: `'ertelendi'` ve `svc_s_is_guncelle` için test yok |
| 5 Neden | 1. İş listede görünmüyor (test: C1 0/0). 2. Durumu hiçbir liste filtresinde yok (test: `0004:138-139`). 3. CHECK ile filtre farklı migration'larda (test: `0001:110` ile `0006:9` karşılaştırması). 4. Migration bölününce ara durum oluştu (test: `SON=0005` 2 KALDI). 5. Durum sözlüğünün tek kaynağı yok, her katman kendi listesini yazıyor (test: yukarıdaki üç `grep`) |
| RCA | Durumun tek bir kaynağı ve izinli geçiş kuralı yok; iki sütun elle eşitleniyor. **Yüksek** (davranış ölçüldü). C5'in hata olup olmadığı **Doğrulanmadı**: iptal edilmiş iş tamamlanabilir mi, iş kuralı Burak'ta |
| FMEA | Çelişkili istekte sessiz geçersiz sayma (C3): Ş4 O2 T5 = 40. İstemci sözlüğü kayması (API yeniden yazılırken taşınırsa): Ş4 O3 T4 = 48. Ara durumda görünmeyen iş: Ş4 O1 T5 = 20 (canlıda 0 iş, API yok; 0006 ile kapanır) |
| Çözüm (önerilir) | 0006 uygulanır (ara durumu kapatır). İzinli geçişler tek yerde tanımlanır (nereden → nereye), çelişkili istek `BEE_GECERSIZ` ile reddedilir. Daha basit tasarım değerlendirilir: `durum` `asama`'dan türetilebilir mi? İstemci durum adları DB'den okunur ya da testle eşlenir |
| Test (önerilir) | DB testi: çelişkili istek reddedilir, `ertelendi`/`kacirildi` listelerde doğru yerde, her `check` değeri en az bir liste filtresinde. Bozma: bir değer filtreden çıkarılınca kırmızı |
| Önleme (önerilir) | `dogrula.sh` statik kontrolü: DB `check` sözlükleri ile `src/` JS sabitleri ve fonksiyon filtreleri eşleşmeli |

---

**Burak'ın karar vereceği konular:** (1) İptal edilmiş iş tamamlanabilir mi (C5)? (2) Hangi vakadan başlanacak? Öneri: Vaka 2. (3) Düzeltmeler yeni migration ister; uygulama onayı sende.
