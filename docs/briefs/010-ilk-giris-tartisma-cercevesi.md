# Brief 010 — İlk giriş sistemi: tartışma çerçevesi

Yazan: sohbet Claude (tasarım mimarisi). Karar: **Burak**. Uygulama: Code (kararlardan sonra).
Bu dosya bir **tasarım dayatması değil**, kararları doğru sırayla ve kanıtlı alabilmek için kurulan tartışma yapısıdır. Karar çıkan her düğüm `docs/decisions/0004-giris-sistemi.md` içine tek satır olarak işlenir (bölüm 6).
Ön koşul: brief 006 madde 1–2. Modül 1 giriş ekranı **bu kararlar çıkmadan yazılmaz**: geri alınması zor olan iki düğüm (N6, N3) önce konuşulur.

## 1. Kapsam
- **İçinde:** Burak'ın (sahip) panele ilk kurulumu ve girişi; oturum; kurtarma; kaba kuvvet koruması; iPhone ana ekran davranışı.
- **Ayrı kısa düğüm (N10):** müşterinin işe özel linki. Giriş değil, ikinci bir erişim yüzeyi.
- **Dışında:** rol sistemi (tek kullanıcı), sosyal giriş, e-posta/SMS kodu, TEHAİ girişi (ayrı proje).

## 2. Mevcut durum (Code'un yazdığı; değiştirmek için karar gerekir)

| Konu | Durum | Kaynak | Güven |
|---|---|---|---|
| Parola | PBKDF2-SHA256, 600.000 iterasyon, sunucuda; `timingSafeEqual` | `src/CLAUDE.md` | Yüksek |
| Oturum | `HttpOnly; Secure; SameSite=Strict` çerez; her istekte `svc_s_oturum_surumu`; çıkış sürümü artırır | `src/CLAUDE.md` | Yüksek |
| Başlangıç | `svc_giris` tek satırlık tablo; `PANEL_ILK_SIFRE` ilk girişte satırı oluşturur (eski taslak `panel.js`, **bozuk, yeniden yazılacak**) | `src/api/panel.js` başlık yorumu | Yüksek (yorum), akış Doğrulanmadı |
| Kurulum | `svc_kurulum()` **çalıştırılmadı**; `svc_ayarlar` boş, bütün fonksiyonlar kapalı | `supabase/CLAUDE.md` | Yüksek |
| Anahtarlar | `BEE_KAPI_ANAHTARI` (herkese açık talep kapısı), `BEE_SAHIP_ANAHTARI` (sahip işlemleri) | `src/CLAUDE.md` | Yüksek |
| Müşteri linki | `/is#k=<token>`; token parçada, POST gövdesinde gider | `src/CLAUDE.md` | Yüksek |
| Bağımlılık | npm bağımlılığı yok | `src/CLAUDE.md` | Yüksek |

## 3. Tehdit modeli (tek kullanıcı, kısa)

| Varlık | Neden değerli | Olası kayıp |
|---|---|---|
| Müşteri adı, telefon, adres | Kişisel veri | Sızıntı, KVKK riski (hukuki değerlendirme bu brief'in dışında, **Doğrulanmadı**) |
| İş kayıtları, tahsilat, maliyet | İşletme verisi | Silinme, değişme, rakibe sızma |
| Sahip anahtarı / oturum | Her şeye erişim | Panel ele geçirilir |

| Saldırgan | Yol | Savunmanın yeri |
|---|---|---|
| Otomatik tarayıcı/bot | Herkese açık giriş ucunu parola deneyerek yoklar | Kaba kuvvet koruması (N5), uzun parola (N2) |
| Kaybolan/çalınan telefon | Açık oturum | Oturum süresi, uzaktan çıkış (N4), cihaz kilidi |
| Yakın kişi/müşteri | Telefona fiziksel erişim | Cihaz kilidi, Face ID (N1) |
| Kendi hatan | Parolayı unutma, telefonu sıfırlama | Kurtarma (N3) |
| Yanlış proje/yanlış migration | Kurulum yanlış yere | Kimlik kapısı (zaten var) |

Bu model, "zorlayıcı ve profesyonel" hedefini **savunmanın gerçekten durduğu yere** koyar: tek kullanıcı sistemde en olası kayıp saldırı değil **kurtarılamayan kilitlenme** ve **telefon kaybıdır**. (Orta, mühendislik yargısı.)

## 4. Tartışma düğümleri (sıra önemlidir)

Sıra: **N6 → N3 → N1 → N2 → N5 → N4 → N8 → N9 → N7 → N10**. İlk ikisi geri alınması en pahalı olanlar. Her düğümde: soru · seçenekler · kanıt · çürütücü · öneri (**yalnız öneri**).

### N6 · İlk kurulum
**Soru:** İlk parola ve sır anahtarları nasıl oluşur, ve kurulum ikinci kez nasıl çalışmaz?
| Seçenek | Artı | Eksi |
|---|---|---|
| A. `PANEL_ILK_SIFRE` ortam değişkeni (mevcut taslak) | Basit | Başlangıç parolası ortamda **kalır**; ilk girişte zorunlu değişim ve değişkenin kaldırılması gerekir |
| B. `svc_kurulum()` yalnız SQL Editor'den Burak çalıştırır; ilk parola orada verilir ve hiçbir yerde saklanmaz | Parola ortamda kalmaz; kurulum yetkisi veritabanı sahibinde | İlk kurulumda bir adım fazla (bir kez) |
| C. İlk girişte "parola belirle" ekranı (token'lı tek seferlik bağlantı) | İyi UX | Bağlantı sızarsa ilk ele geçiren sahip olur: kurulum penceresinde yarış |
**Çürütücü:** Kurulum iki kez çalıştırıldığında ya da kurulum bitmeden bir istek geldiğinde mevcut satır ezilirse (test: ikinci çağrı reddedilmeli) A ve C elenir.
**Öneri (Orta):** B, ardından ilk girişte parola değişimi zorunlu değil çünkü parola hiç dışarıda yok. Karar: Burak.

### N3 · Kurtarma (parolayı ya da telefonu kaybedersen)
**Soru:** Tek kullanıcı sistemde kurtarma yolu ne olmalı?
| Seçenek | Artı | Eksi |
|---|---|---|
| A. Veritabanı sahipliği = kurtarma: `svc_sahip_parola_sifirla` yalnız SQL Editor'den (Supabase hesabı kanıt) | Ek sistem yok, e-posta yok | Supabase hesabına erişim yoksa kurtarma yok (hesap kendi kurtarmasına bağlı) |
| B. Kâğıda yazılı kurtarma kodları (üretilir, bir kez gösterilir, hash saklanır) | Çevrimdışı, bağımsız | Kağıt kaybolabilir; kod yönetimi eklenir |
| C. E-posta bağlantısı | Tanıdık | Ek sağlayıcı ve sır, tek kişi için fazla; e-posta hesabı ikinci kırılma noktası |
| D. Güvenlik soruları | Basit | **Standart yasaklıyor** (NIST 800-63B-4: KBA/güvenlik sorusu istenmemeli) |
**Çürütücü:** A'da Supabase hesabına erişim kaybı senaryosu gerçekleşirse B zorunlu hale gelir.
**Öneri (Orta):** A birincil, B isteğe bağlı sonra. D elenir (standart). Karar: Burak.

### N1 · Birincil doğrulayıcı
**Soru:** Parola mı, passkey (Face ID) mi, ikisi mi?
| Seçenek | Artı | Eksi |
|---|---|---|
| A. Yalnız parola (mevcut) | Mevcut kodla uyumlu, bağımlılık yok | iPhone'da her seferinde yazmak; parola yöneticisi gerekir |
| B. Parola + passkey sonradan | Face ID tek dokunuş; passkey iCloud Anahtarlığı'nda, Safari ve ana ekran uygulamasında aynı RP ID ile çalışır (Orta) | Sunucuda WebAuthn doğrulaması gerekir; **`npm bağımlılığı yok` ilkesiyle çakışır**: kütüphane (örn. SimpleWebAuthn) ya da elle CBOR/COSE ayrıştırma. Elle yazım güvenlik açısından riskli (Orta, yargı). Ek tablo/migration (kimlik, genel anahtar, sayaç) |
| C. Yalnız passkey | En az sürtünme | Kurtarma yolu şart (N3), cihaz değişimi/senkron sorunu |
**Çürütücü:** Burak'ın telefonunda parola yöneticisi (iCloud Anahtarlığı) uzun parolayı tek dokunuşta dolduruyorsa B'nin kazancı küçülür → önce A, YAGNI.
**Öneri (Orta):** **A ile başla, passkey'i "sonra" olarak tut**; ama sunucu tasarımı passkey eklenebilecek şekilde bırakılsın (kimlik doğrulayıcılar ayrı tablo mantığı). Karar: Burak.

### N2 · Parola politikası
**Standart (Yüksek, NIST SP 800-63B-4):** tek faktörlü parola için **en az 15 karakter**; bileşim kuralı (büyük harf+rakam zorunluluğu) **yok**; periyodik değişim zorlanmaz; ipucu yok; yapıştırma ve parola yöneticisine izin; en az 64 karakter kabul.
**Soru:** Mobil tek elle 15+ karakter yazmak sorun mu?
| Seçenek | Not |
|---|---|
| A. 15+ karakter, parola yöneticisi doldurur | Standarda uygun; ilk girişte yazılır, sonra otomatik |
| B. Daha kısa (örn. 10) | Standart tek faktörde izin vermiyor; riski artırır |
**Çürütücü:** Burak parola yöneticisi kullanmıyorsa A zorlaşır → N1'de passkey avantajı artar.
**Öneri (Orta):** A. `autocomplete="current-password"`, yapıştırma serbest, göster/gizle düğmesi. Karar: Burak.

### N5 · Kaba kuvvet koruması
**Soru:** Deneme sınırı nerede ve nasıl tutulur?
- Sunucusuz işlevde bellek içi sayaç **soğuk açılışta sıfırlanır** (Orta; aynı sınıf bir sorun TEHAİ'de ölçüldü). Sayaç **veritabanında** (`svc_giris` yanında deneme sayısı ve son deneme zamanı), `svc_*` fonksiyonu içinde tutulmalı.
- Standart (Yüksek): ardışık başarısız denemeler tek hesapta **en çok 100** ile sınırlanmalı.
- **Kendi kendine hizmet reddi riski:** sınır aşılınca hesap kilitlenirse saldırgan Burak'ı kendi paneline sokmaz. Seçenek: kilit yerine **artan gecikme** (1, 2, 4… sn) ve günlükte uyarı.
**Çürütücü:** Gecikme yöntemi, saldırganın dakikada denemesini yeterince yavaşlatmıyorsa (hesapla: gecikme × deneme sayısı / uzun parola entropisi) kilit eklenir.
**Öneri (Orta):** DB sayaçlı artan gecikme + 10 ardışık hatadan sonra 15 dk bekleme; kurtarma yolu (N3) kilitten bağımsız. Karar: Burak.

### N4 · Oturum
**Soru:** Süre ve çok cihaz?
- Mevcut: tek `oturum_surumu` → "çıkış" **tüm cihazlarda** çıkış yapar. Telefon kaybında bu iyi; ama Safari ve ana ekran uygulaması **ayrı çerez kavanozu** kullanır (Orta; iOS 17.2+'ta kurulum anında Safari çerezleri ana ekran uygulamasına kopyalanır, sonra iki oturum ayrışır).
- Soru: Oturum süresi (örn. 30 gün kayan mı, sabit mi), ana ekran uygulamasında yeniden giriş sıklığı.
**Çürütücü:** Burak ana ekran uygulamasında sık oturum düşüyorsa süre ya da yeniden doğrulama basitleştirilir.
**Öneri (Orta):** 30 gün kayan süre, çıkış hepsini kapatır, cihaz listesi **şimdi yok** (YAGNI). Karar: Burak.

### N8 · iPhone ve ana ekran (el testi zorunlu)
Safari ve ana ekran ayrı depolama kullanır; çerez kopyalanır, `localStorage`/IndexedDB kopyalanmaz (Orta). Bu yüzden oturum **yalnız sunucu çerezinde** durur. Bu düğümün kararı yoktur, **testi vardır**: T5 el kartında "Safari'de giriş → ana ekrana ekle → uygulamadan aç: girişli mi?" (Burak, gerçek telefon). Sonuç `src/CLAUDE.md`'ye "Orta"dan "Yüksek"e çıkar.

### N9 · Giriş ekranı (ekran-sablonu A bölümü)
Tek birincil eylem: **Giriş yap**. Altı durum ekranda: boş · yükleniyor · hata (sabit mesaj, DB metni yok) · başarı · çevrimdışı ("İnternet yok, giriş yapılamaz") · oturum bitti. Alan etiketi görünür; `lang="tr"`; yazı ≥ 16 px; hata mesajı tek tip ve sabit ("Giriş yapılamadı"); neden başarısız olduğunu (yanlış parola, kilit, kurulum yok) ayırt ettirmez. Süre hedefi (öneri, Doğrulanmadı): parola yöneticili giriş ≤ 5 sn.

### N7 · Çevrimdışı
Giriş çevrimdışı **yapılmaz**; okuma önbelleği oturum açıkken çalışır; çıkışta önbellek temizlenir (`ekran-sablonu` C, manifest/sw satırı). Yerel kilit (Face ID ile uygulama içi) **sonra**, YAGNI.

### N10 · Müşteri linki (kısa)
Sorular: token uzunluğu/entropisi (öneri en az 128 bit rastgele, Orta), geçerlilik süresi, iptal etme, tek işe kapsam, WhatsApp→Safari'de `#` kaybı (el testi), geçersiz linkte tek tip cevap (GG-4). Giriş sisteminden bağımsız karar; N1–N9'dan sonra.

## 5. Tartışma protokolü (nasıl konuşulur)
1. **Bir seferde bir düğüm.** Ben düğümü bu şablonla sunarım, sen kararı tek cümleyle verirsin ("A", "B", "sonra", "hiç").
2. Her düğümde **Code görüşü** satırı olur: uygulama maliyeti, bağımlılık, test (Burak iletir; Code `docs/**` yazamaz).
3. Çürütücü gerçekleşirse karar **yeniden açılır**, kayıtta tarihle.
4. "Sonra" kararı kayıtta **tetikleyici** taşır (örn. "parola yöneticisi kullanılmıyorsa passkey'i aç").
5. Karar yoksa uygulama yok. Code bu düğümlerde varsayılan seçmez.

## 6. Karar kaydı (şablon; her düğüm tek satır)
`docs/decisions/0004-giris-sistemi.md` içinde, karar çıkınca:
| Düğüm | Karar | Tarih | Neden (1 cümle) | Tetikleyici/yeniden aç | Code görüşü |
|---|---|---|---|---|---|
| N6 | … | … | … | … | … |

## 7. Test bağlantısı (brief 008)
| Katman | Vaka |
|---|---|
| T1 (DB) | Anon `svc_giris` okuyamaz · yanlış parola kabul edilmez · deneme sayacı DB'de artar ve soğuk açılışla sıfırlanmaz · çıkıştan sonra eski çerez geçersiz (`oturum_surumu`) · kurulum ikinci kez çalışmaz · DB hatası tarayıcıya sızmaz |
| T3 (ekran) | Giriş ekranı 6 durum · 375/414 yatay kaydırma yok · hedef ≥ 44 px · alan etiketi/`lang` · yapıştırma çalışır |
| T4 (canlı) | Giriş ucu başlıkları `no-store`; yanlış parola tek tip cevap; anon sahip fonksiyonunu çağıramaz |
| T5 (el) | Face ID/parola yöneticisi doldurma · ana ekrana ekle sonrası oturum · uçak modunda mesaj · yanlış parola 5 kez |

## 8. Kabul ölçütü (Burak sahada)
- Telefonu açıp parola yöneticisiyle **≤ 5 sn** içinde panele girer (süre Doğrulanmadı, hedef).
- Çıkış yapar, tekrar girer; ana ekran simgesinden açınca oturum beklediği gibidir.
- Yanlış parolayı 5 kez dener: ne olduğunu ekrandan anlar, kilitlenip dışarıda kalmaz.
- Parolayı unuttuğunda (N3 kararına göre) **kendi başına** geri girebilir.

## 9. Kaynaklar
- NIST SP 800-63B-4, parola doğrulayıcıları ve oran sınırlama: https://pages.nist.gov/800-63-4/sp800-63b/authenticators/ (Yüksek)
- Passkey ve PWA, çerez/depolama ayrımı: https://progressivewebapps.com/capabilities/authentication/ (Orta; ikincil kaynak)
- iOS passkey davranışı: https://passkeys.dev/docs/reference/ios/ (Orta/Yüksek)
- Passkey en iyi uygulamalar (yedek yol şart): https://docs.authsignal.com/authentication-methods/passkey/best-practices-web (Orta; satıcı belgesi)
- `src/CLAUDE.md`, `supabase/CLAUDE.md` (Code, `7efd02d`)
