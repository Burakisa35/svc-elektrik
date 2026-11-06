# BEE — Yol Haritası (Modül 1–5)

> Kanonik veri kararları: `docs/VERI_MODELI.md`. Bu dosya **sıra, kapsam ve kabul ölçütüdür**.
> Burak'ın 2026-11-06 plan brifi, **uygulanmış şemaya** (0000–0003, hepsi canlıda) göre düzeltildi.
> Düzeltilen her yer `DÜZELTME` olarak işaretli. Güven: Yüksek (kodda/DB'de ölçüldü) · Orta · Doğrulanmadı.

## 0. Sabitler
- Ayrı Supabase projesi `burak-elektrik` (`uwmbtaxxdcjumxbnigpy`, Frankfurt) ve ayrı Vercel projesi.
  **Vercel'de service_role yok**: sahip işlemleri sahip anahtarı isteyen DB fonksiyonlarıdır (0002),
  herkese açık iki fonksiyon kapı anahtarı ister.
- Kullanıcı ikiye ayrılır: **sahip** (tek yazan taraf) ve **link okuyucu** (girişsiz, yalnız okur).
  Müşteri tarafında hiçbir yazma yok, "Onaylıyorum" düğmesi yok. `admin` kelimesi kodda geçmez.
- Sistem kendi kararıyla iş kapatmaz, mesaj atmaz, ödeme kaydını değiştirmez; yalnız uyarı ve
  taslak üretir. Eksik veri sıfır olarak gösterilmez.
- Bir modül bitmeden sonrakine geçilmez. Commit yalnız çalışır hâldeyken atılır.

## 1. Plan ↔ gerçek şema farkları — `DÜZELTME`

| Planda | Uygulanmış hâl | Karar |
|---|---|---|
| `svc_isler` müşteri adı, telefon ve adresi kendi içinde tutar | `svc_isler` → `svc_musteriler` + `svc_adresler` (adres geçmişi, telefonla tekil) | **Uygulanmış hâl kalır.** Telefonu iş kaydının içine gömmek, aynı müşterinin ikinci işinde veriyi çoğaltırdı. Ekranda tek form: sunucu telefonla müşteriyi bulur ya da açar (`svc_s_is_olustur`) |
| `svc_linkler` | `svc_paylasimlar`: token özeti, `alanlar` izin listesi, etiket, `son_gecerlilik`, `iptal_at`, `erisim_sayisi`, `son_erisim_at` | **Ad korunur.** `tur` sütunu **eklenmez** (apartman kararı: tek ortak link, §5). `etiket` zaten opsiyonel ("A Blok girişi" gibi, yalnız sahip için). `ilk_erisim_at` Modül 3'te eklenir |
| Token 128 bit | 2 × UUIDv4 = 244 rastgele bit, 64 hex; DB'de yalnız SHA-256 özeti | Gereksinimin üstünde, değişmez (Yüksek) |
| Müşteri sayfası tek allow-list fonksiyonu çağırır | `svc_paylasim_oku()`: sahibin seçtiği alanları döndürür, alanlar bir kısıtla izin listesine bağlı | Plana uygun. Modül 1 ekranı varsayılan olarak yalnız **`asama` + `musteri_aciklamasi`**'ı seçer ("durum + benim notum") |
| `svc_olaylar` Modül 3'te; durum olaylardan türetilir | `svc_olaylar` **zaten var** (0001): silinemez, durum ve aşama geçişlerini tetikleyici yazıyor | **Türetme yok.** Bkz. §3 |
| `svc_hedefler` yeni tablo | `svc_gorevler` (`tur='hedef'`, `periyot='gun'`, `hedef_deger`, `gerceklesen`) var | **Yeni tablo yok.** Para hedefleri (ciro, tahsilat) ise Modül 4'te `svc_finans_hedefleri` olacak; gerçekleşeni hesaplanır, elle girilmez |
| Vitrin formsuz | `VERI_MODELI.md` §2 ve §5: herkese açık talep formu → `svc_talepler` → Kabul/Beklet/Reddet. DB hazır ve test edildi | **Belge esas.** Form, Modül 1'in kabul testini geciktirmesin diye **Modül 1b**'de: vitrin ve telefon/WhatsApp önce, form hemen ardından |

## 2. Modül 1 — Çekirdek (sürüyor)

**Kapsam:** giriş/çıkış · iş aç · aşama ve durum değiştir · link üret/kopyala/iptal · müşteri durum
sayfası · vitrin (telefon/WhatsApp). **1b:** talep formu ve talepleri değerlendirme ekranı.

**Teknik kararlar:**
- **Parola:** PBKDF2-SHA256, 600.000 iterasyon, sunucuda Node `pbkdf2` ile hesaplanır, karşılaştırma
  `timingSafeEqual`. Ölçüm: ~100 ms/deneme (geliştirme makinesi, Xeon 2.1 GHz; Vercel'de doğrulanmadı).
  Deneme sayacı **doğrulamadan önce** atomik olarak artar (`svc_s_giris_baslat`). 5 hatadan sonra kilit
  15 dk'dan başlar, her turda katlanır, en fazla 24 saat.
- **İlk parola:** `svc_s_sifre_kur` yalnız henüz parola yokken bir kez yazar. **Risk:** kurulumdan önce
  sayfayı ilk açan kişi parolayı belirleyebilir. Önlem: ilk parola yalnız `PANEL_KURULUM_ACIK=1`
  ortam değişkeni varken kabul edilir; Burak parolayı kurar, değişken kaldırılıp yeniden deploy edilir.
- **Oturum:** JWT, `HttpOnly; Secure; SameSite=Strict` çerezde; içinde `oturum_surumu` taşır. Her
  sahip isteği sürümü DB'den doğrular; **çıkış sürümü artırır, o ana kadar verilmiş bütün token'lar
  ölür** (0003). JWT tek başına geri alınamazdı; çerez silinse bile çalınmış bir kopya geçerli kalırdı.
- **Müşteri linki: `/is#k=<token>` (parça).** `DÜZELTME` (planda `?k=`). Parça (`#` sonrası) HTTP
  isteğine girmez: Vercel erişim kayıtlarına, ara vekil sunuculara ve Referer başlığına hiç düşmez.
  Sayfadaki JS token'ı okuyup `POST` gövdesinde gönderir.
- **Müşteri yanıt başlıkları** (`/is` ve onun API ucu): `X-Robots-Tag: noindex`,
  `Referrer-Policy: no-referrer`, `Cache-Control: no-store`. Geçersiz, süresi dolmuş, iptal edilmiş ve
  hiç olmamış link **aynı** 404 + "Bağlantı geçersiz" cevabını alır.
- **Bölge:** Vercel fonksiyonları `fra1`. Varsayılan bölge ABD (iad1) olur; her DB çağrısı Atlantik'i
  geçer. Hobby planda tek bölge seçilebiliyor (Orta, doğrulanacak).
- **iOS PWA:** ana ekrandan açılan uygulamanın çerez deposu Safari'den ayrıdır. Yani PWA'da ayrıca
  giriş yapılır (Orta).

**Kabul (Burak telefonda):**
1. Müşteri sayfasının ham API yanıtında telefon, adres, özel not ve fiyat yok.
2. İptal edilen ya da süresi dolan link yalnız "geçersiz" der.
3. Yanlış parolada sayaç artar, 6. denemede kilit devreye girer.
4. Anon key ile tablolara doğrudan istek 401 döner (0001'de ölçüldü, deploy sonrası tekrarlanır).
5. Çıkıştan sonra eski oturum çerezi elle geri yüklense bile 401 döner.
6. **"İş aç" sahada ≤30 saniyede biter.** Zorunlu alan **bir tane**: telefon *veya* ad. Yanında bir
   kısa not kutusu var, geri kalan her şey opsiyonel. Not kutusu büyük, `font-size ≥16px`, iPhone
   klavye diktesine uygun (ayrı ses geliştirmesi yok).

**Kabul 6 için şema değişikliği — Modül 1 şemasını ETKİLER (Modül 1 içinde küçük bir migration):**
uygulanmış şemada `svc_musteriler.ad`, `soyad` ve `telefon` zorunlu; `svc_isler.baslik` ve
`hizmet_turu` da zorunlu. Bu hâliyle tek alanla iş açılamaz.
- `svc_musteriler`: `ad`, `soyad`, `telefon` opsiyonel olur, yerine `check (telefon is not null or ad is not null)`
  gelir. Telefon tekilliği korunur (NULL'lar çakışmaz).
- `svc_isler`: kısıtlar değişmez. `svc_s_is_olustur` boş başlığı notun ilk satırından (≤60 karakter)
  üretir, boş hizmet türünü `diger` yapar.
- Herkese açık talep formu (`svc_talepler`) **değişmez**; orada ad, soyad ve telefon zorunlu kalır.

## 3. Modül 3'e hazırlık: olaylar ve durum — `DÜZELTME`
Plan, Modül 3'te `svc_isler.durum`'un olaylardan türetilen bir önbelleğe dönmesini istiyordu.
**Önerilmez.** Durum hem olaylardan türetilir hem de doğrudan yazılabilirse iki gerçek kaynak oluşur
ve aralarındaki fark sessizce büyür. Uygulanmış model zaten iki şeyi ayırıyor:
- **Yazma yolu:** `svc_isler.durum/asama` güncellenir (tek kaynak).
- **Geçmiş:** tetikleyici her geçişi `svc_olaylar`'a yazar. Tablo silinemez; sahibi bile silemez
  (test edildi).

Modül 3'te yapılacak tek değişiklik **ekleme**: `svc_olaylar`'a `musteriye_gorunur boolean default false`,
`olay` listesine `musteri_notu · ek_is · ziyaret_basla · ziyaret_bitti · fotograf` eklenecek, `is_id`
bağlantısı kurulacak. Var olan satırlar ve tetikleyiciler değişmez; Modül 1 şeması bozulmaz.
`svc_paylasim_oku()` yalnız `musteriye_gorunur = true` olan olayları döndürecek şekilde genişler.
İzin listesi mantığı korunur.

## 4. Modül 2 — Kişisel katman
- Serbest ve işe bağlı notlar (`svc_notlar`, mevcut). Günlük hedefler (`svc_gorevler`, mevcut).
  "Bugün" ekranı (`svc_s_ozet`, mevcut; gün başı ve gün sonu özeti olarak genişler).
- **Bağlantı kopunca not kaybolmaz:** IndexedDB'de giden kuyruğu tutulur. Her not istemcide bir
  UUID alır; kuyruk uygulama açıkken ve `online` olayında yeniden denenir. Sunucuda
  `svc_notlar.istemci_id UNIQUE` olur, aynı not iki kez yazılmaz. **Migration gerekir (Modül 2).**
  iOS Safari Background Sync'i desteklemiyor (Orta, doğrulanacak); tasarım buna dayanmıyor.
- Risk: kuyruk cihazda düz durur. Cihaz Burak'ın; senkron olunca kuyruk silinir.

## 5. Modül 3 — Olay akışı ve ek iş
- Müşteriye görünür not, zaman damgalı kayıt, ziyaret başlangıç ve bitişi (olay çifti). Modül 5'in süre
  verisi buradan doğar.
- **Ek iş tutarı olay kaydına yazılmaz** `DÜZELTME`. `VERI_MODELI.md` §4.3'e göre teklif bağımsız bir
  varlıktır. Ek iş, işe bağlı bir teklif olur: `svc_teklifler` (`is_id`, `tur='ek_is'`, durum taslak ·
  onaylandı · reddedildi) ve `svc_teklif_kalemleri` (kalem, miktar, birim fiyat kuruş).
  **Onayı sahip kaydeder:** kanal (telefon · yüz yüze · mesaj) ve zamanı yazılır. Olay kaydı yalnız
  "ek iş eklendi" ve "onaylandı" bilgisini teklif kimliğiyle tutar. Tutar tek yerde durur; Modül 4
  onu iki kez saymaz.
- Linkte ek iş görünür, yalnız **bina geneli kalem + tutar** olarak (sahip seçerse). Bu, izin listesine
  `ek_isler` alanı eklenerek yapılır. Daire bazlı pay ve tahsilat yalnız sahip panelinde görünür (Modül 4).
- **Fotoğraf — RİSK:** service_role olmadan Supabase Storage'a imzalı URL üretilemez (Doğrulanmadı;
  Storage politikaları anon'a açılırsa kapı anahtarı mantığı Storage'a uzanamaz). Seçenekler: Vercel
  Blob, ya da yalnız Storage için daraltılmış bir anahtar. **Modül 3 başında karar gerekir.**
- **Apartman — `KARAR` (Burak, 2026-11-06): bütün sakinlere TEK ORTAK LİNK.** Daire başına link
  seçeneği tasarımdan çıkarıldı. Ortak sayfada yalnız iş durumu, genel ilerleme ve sahibin genel notu
  görünür. Daire no, kişi adı, telefon, daire bazlı tutar, ödeme ya da borç **asla** görünmez. İzin
  listesinde bunlara karşılık gelen bir alan zaten yok; yani kural yapısal olarak sağlanıyor.
- **Açılış sayaçlarının kanıt değeri zayıf:** `erisim_sayisi`, `son_erisim_at` (ve Modül 3'te
  `ilk_erisim_at`) kişiyi değil **linki** sayar. Linki kimin açtığı bilinmez; ortak linkte herhangi
  bir sakin açmış olabilir. Bu sayaçlar "müşteri bilgilendirildi" kanıtı olarak **kullanılmaz**, yalnız
  "link en az bir kez açıldı" anlamına gelir.

## 6. Modül 4 — Finans
`VERI_MODELI.md` §4.3'teki beş tablo ve üç düzeltme esas. Plandaki "iş tutarı" bir `svc_isler`
sütunu **değil**, satış belgesidir (`DÜZELTME`). Alacak yaşı, vade ve eşleşen tahsilatlardan
hesaplanır. Hatırlatma **taslak** metindir; sahip kopyalayıp kendisi gönderir.

## 7. Modül 5 — Veriyle akıllanan parçalar — `DÜZELTME`
- Her öneri hizmet türü başına **en az 5 kapanmış iş** ister. Altında "yeterli veri yok (n=3)" der.
  Gösterilen her sayının yanında n ve aralık yazar.
- **Hazırlık önerisinin veri kaynağı yok:** malzeme kullanımını hiçbir modül toplamıyor
  (`svc_malzemeler` planda yok). Ya Modül 3'e "işte kullanılan malzeme" listesi eklenir (V0 düzeyi,
  stok yok), ya da bu parça çıkarılır. **Modül 5'ten önce karar gerekir.**
- Süre ve fiyat referansı ziyaret olaylarına (Modül 3) ve satış belgelerine (Modül 4) dayanır.
  Gün planı kümeleme adres verisine (`svc_adresler.ilce/mahalle`) dayanır; koordinat yok, kümeleme
  ilçe ve mahalle düzeyinde olur.

## 8. TEHAİ'den alınacaklar
TEHAİ deposu **salt okunur** tarandı (2026-11-06); dosya kopyalanmadı. Her satır, okunan dosyaya
dayanıyor. Logo, "T" işareti ve TEHAİ/TEHAŞ/Arel adları alınmaz.

| # | Aday | Karar | Gerekçe (koddan) | Modül | M1 şeması |
|---|---|---|---|---|---|
| 1 | "teklif_ozet" görünümü | **AL (kalıp), zaten uygulandı** | Bu adda bir görünüm **yok**. `teklifOzet` adlı bir JS fonksiyonu var (`assets/js/tehai-teklif-hesap.js`) ama o bir hesap fonksiyonu. Kişisel veriyi dışlayan izin listesi kalıbı ise `query_service_request` (001): seçilmiş alanları `json_build_object` ile döndürüyor, telefon/adres yok. BEE'de karşılığı `svc_paylasim_oku()`. Fark: TEHAİ bu fonksiyonda ilçe ve mahalleyi de döndürüyor, BEE döndürmez | 1 | Hayır |
| 2 | `is_kayitlari` zengin alanları | **UYARLA** | Alanlar 024'te var. **Alınmayacak kusur:** varsayılanlar veri uyduruyor: `ilk_ziyarette_cozuldu default true`, `odeme_durumu default 'odendi'`, `durum default 'tamamlandi'`. Girilmemiş bilgi "çözüldü/ödendi" görünüyor; bu, "eksik veri sıfır/doğru gösterilmez" kuralını çiğner. BEE'de hepsi NULL olur. Eşleme: `mahalle` → `svc_adresler`'de zaten var · `bina_tipi`, `sistem_tipi`, `ilk_belirti`, `teshis`, `mudahale`, `talep_kanali` → Modül 3 kapanış formunda `svc_isler`'e **tipli, NULL olabilen sütun** · `olcum_degerleri` → `svc_olcumler` · `kullanilan_malzeme` → `svc_is_malzemeleri` · `calisma_suresi` ve `tekrar_ziyaret` **elle girilmez**, ziyaret olaylarından hesaplanır | 3 | **Hayır.** Modül 1'de yer açmaya gerek yok: Postgres'te NULL olabilen sütun eklemek anlık ve bozucu değil. Tek bir `jsonb` sütun **seçilmedi**, çünkü Modül 5 bu alanlarla gruplama yapacak ve listeden seçim kısıtı (CHECK) isteyecek; `jsonb` ikisine de izin vermez |
| 3 | `musteri_risk` | **UYARLA (tablo değil, hesap)** | 006'da tablo olarak var: sayaçlar artı 0–10 `risk_skoru`, bir RPC ile (`hesapla_musteri_risk`) güncelleniyor. Saklanan sayaç kaynağından kayabilir, puan da uydurmadır. BEE'de puan yok; müşteri başına "vadesi geçmiş ödeme sayısı / toplam satış belgesi" **sorguyla hesaplanır** (vade ve eşleştirmeden) | 4 | Hayır |
| 4 | Ekipman kaydı | **UYARLA** | 024 `ekipmanlar`: tip, marka, model, seri no, konum notu, garanti bitişi; işe ve müşteriye bağlı. **Fotoğraf sütunu yok**, fotoğraf TEHAİ'de ayrı bir kanıt akışında. BEE'de müşteride kurulu cihaz (`svc_kurulu_cihazlar`, adrese bağlı) ile Burak'ın kendi ölçüm aletleri (`svc_ekipmanlar`, VERI_MODELI §4.1) **ayrı** tutulur; TEHAİ ikisini ayırmıyor. Fotoğraf, §5'teki depolama kararına bağlı | 3 | Hayır |
| 5 | Çevrimdışı: SW + manifest + yerel kuyruk | **AL (kalıp) + bir düzeltme** | `sw.js`: `/api/` istekleri önbelleğe hiç alınmıyor, sayfalarda önce ağ, statik dosyalarda önce önbellek stratejisi var. Doğru, aynen alınır. `pages/is-kaydi.html`: IndexedDB kuyruğu (`local_id` anahtarlı) `online` olayında senkronlanıyor, Background Sync kullanılmıyor. **Kusur:** `local_id` sunucuya gitmiyor ve sunucuda tekillik yok (grep: `api/` ve migration'larda yok). Zaman aşımından sonra yeniden deneme aynı kaydı iki kez yazabilir. BEE'de `istemci_id UNIQUE` (bkz. §4). iOS Safari'nin Background Sync desteği **doğrulanmadı** | 2 | Hayır |
| 6 | Tasarım token'ları | **AL (marka dışı olanlar)** | TEHAİ `tokens.css`: yarıçap, `--ease`, `--dur-*`, `prefers-reduced-motion` bloğu. `base.css`: 44px dokunma hedefi. BEE `styles/tokens.css`'te yarıçap, ease ve 44px zaten var; **reduced-motion bloğu eksik**, eklenecek. Renkler alınmaz (TEHAİ mavi, BEE gümüş/grafit) | 1 | Hayır |
| 7 | Teklif üretimi | **SONRA (Modül 4'ten sonra ayrı hedef)** | 042 "teklif motoru" (`teklif_ihaleler`, `teklif_ihale_kalemleri`, şartname okuma, PDF) bir **kamu ihale** modülü, kesin alınmayacaklar listesinde. Kamera teklifi `api/pricing.js` (`fn=kamera`) ve `tehai-teklif-hesap.js` içinde. **Şimdi alınacak tek şey:** 040'taki teklif **sonuç kaydı** (`karar_ts`, `ret_sebebi` sözlüğü, `kabul_bedel`) `svc_teklifler` tasarımına eklenir. 040'ın kendi tespiti: reddedilen teklif kaydedilemediği için "öğrenecek veri" hiç oluşmuyordu. Bir de ilke: `teklifOzet` fiyatı eksik kalem varsa genel toplamı `null` döndürüyor, sıfır değil. **Çakışma yok:** Modül 1–4 şemasında teklif tablosu henüz yok | 3–4 (yalnız tasarım) | Hayır |
| 8 | `customer_pins` | **ALMA** | 017 + `api/customer-auth.js`: telefon + şifreyle **müşteri portal hesabı** (PBKDF2 100k, kilit). BEE'de müşteri hesabı yok. Link için ek koruma olarak da gerekmiyor: token 244 bit, tahmin edilemez. Ortak apartman linkinde bir PIN de linkle birlikte paylaşılacağı için bir şey korumaz, yalnız okuyucuya sürtünme ekler. Kilit fikri zaten `svc_giris`'te var | — | Hayır |
| 9 | Push bildirimleri | **ALMA (şimdilik)** | `api/_webpush.js` bağımlılıksız (Node crypto, 114 satır), `sw.js`'de push dinleyicisi var. İleride yalnız sahibe (alacak hatırlatması) gerekirse referans olur. iOS'ta ana ekrana eklenmiş PWA ister (TEHAİ AGENTS.md K2) | — | Hayır |
