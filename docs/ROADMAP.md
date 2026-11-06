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
| `svc_linkler` | `svc_paylasimlar`: token özeti, `alanlar` izin listesi, etiket, `son_gecerlilik`, `iptal_at`, `erisim_sayisi`, `son_erisim_at` | **Ad korunur.** Eksikler (`tur` ortak/daire, `ilk_erisim_at`) Modül 3'te eklenecek; mevcut satırlar `tur='ortak'` varsayılanıyla bozulmadan kalır |
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
- Linkte ek iş görünür (kalem ve tutar, sahip seçerse). Bu, izin listesine `ek_isler` alanı eklenerek
  yapılır.
- **Fotoğraf — RİSK:** service_role olmadan Supabase Storage'a imzalı URL üretilemez (Doğrulanmadı;
  Storage politikaları anon'a açılırsa kapı anahtarı mantığı Storage'a uzanamaz). Seçenekler: Vercel
  Blob, ya da yalnız Storage için daraltılmış bir anahtar. **Modül 3 başında karar gerekir.**
- Apartman: varsayım **tek ortak link** (iş durumu, genel not, ilerleme; daireye özel bilgi yok).
  Daire başına link gerekirse `svc_paylasimlar.tur='daire'` + etiket eklenir. Mevcut model iki seçeneği
  de taşıyor.

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
