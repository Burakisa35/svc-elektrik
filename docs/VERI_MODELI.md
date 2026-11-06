# BEE — Veri Modeli ve Erişim Mimarisi

> **Durum (2026-11-06):** 1. migration (operasyon çekirdeği) yazıldı ve `burak-elektrik`
> projesine (`uwmbtaxxdcjumxbnigpy`) uygulandı. Bunun kanıtı dosyanın kendisi değil,
> `tests/db-erisim.sql` koşumu ve sonundaki ölçüm notları.
> **2. migration (ölçüm · malzeme · finans) YAZILMADI ve UYGULANMADI.** Buradaki 2. aşama
> bölümü yalnız ilişki tasarımıdır.
>
> Etiketler: `KARAR` (Burak verdi) · `TASARIM` (önerildi, kod/şemada var) ·
> `2.AŞAMA` (tasarlandı, şemada yok) · `DOĞRULANMADI` (sınanmadı).

---

## 1. Erişim modeli — üç kullanıcı, üç kapı

| Kim | Ne yapabilir | Nasıl uygulanıyor |
|---|---|---|
| **Sahip (Burak)** | Her şey | Panel sunucusu (`api/panel.js`) şifre + JWT ile kimliği doğrular, veritabanına `service_role` ile gider. Tek sahip; rol sistemi yok. `KARAR` |
| **Anonim ziyaretçi** | Yalnız talep **gönderir**; hiçbir şeyi okuyamaz | Veritabanında `anon` rolünün **hiçbir tabloda yetkisi yok** (revoke). Tek kapısı `svc_talep_olustur()` fonksiyonu. `TASARIM` |
| **Paylaşım linki sahibi** | Tek bir işin, Burak'ın seçtiği alanlarını **okur** | Tek kapısı `svc_paylasim_oku()`. Fonksiyon yalnız `alanlar` dizisindeki alanları döndürür; tabloya doğrudan erişim yok. `TASARIM` |

### Neden "yalnız arayüzde değil" — katmanlar

1. **Veritabanı yetkisi:** `anon` ve `authenticated` rollerinin bütün `svc_` tablolarındaki
   yetkileri geri alındı. Varsayılan yetkiler de geri alındı: 2. aşamada eklenecek tablolar da
   otomatik kapalı doğar. Supabase'in varsayılanı bunun tersiydi; TEHAİ projesinde ölçüldü,
   anon rolünde tam yetki vardı.
2. **RLS açık, politika yok:** yetki bir gün yanlışlıkla geri verilse bile satırlar okunamaz.
   Bu ikinci kilit.
3. **Kapı anahtarı:** iki herkese açık fonksiyon, sunucunun bildiği bir anahtarı (`p_kapi`)
   ister. Anahtarın yalnız SHA-256 özeti `svc_ayarlar`'da durur. Sonuç: publishable key'i bilen
   biri Supabase'e doğrudan istek atıp sunucudaki spam korumasını atlayamaz. Gerçek istemci
   IP'sini yalnız sunucu görür, bu yüzden IP sınırı da yalnız sunucu üzerinden anlamlıdır.
4. **Değişmezlikler veritabanında:** talebin kabulü, iş emrinin varlığı, olay kaydının
   silinemezliği ve paylaşım alanlarının sınırı tetikleyici ve kısıtla (constraint) korunur.
   Sunucu kodundaki bir hata bunları delemez.

**Bilinen sınır:** Vercel ortam değişkenleri projedeki bütün fonksiyonlarda ortak. Herkese
açık uç (`api/public.js`) çalışma anında ele geçirilirse (RCE) `SUPABASE_SERVICE_ROLE_KEY`'i
de okuyabilir. Ayrım, **mantık hatalarına** karşı korur (yanlış sorgu, eksik filtre, injection).
RCE'ye karşı korumaz; bunun için iki ayrı Vercel projesi gerekir. `DOĞRULANMADI`

**Supabase Auth:** yeni projelerde kayıt (signup) **varsayılan olarak açık**. Publishable
key'le herkes kullanıcı açıp `authenticated` rolüne geçebilir. Bu yüzden `authenticated`
rolünün yetkileri de geri alındı. Ayrıca panelden kaydın kapatılması önerilir: Authentication
→ Sign In / Providers → "Allow new users to sign up" kapalı. (Güven: Orta — ayar adı
dashboard sürümüne göre değişebilir.)

---

## 2. İş akışı → veri

```
Ziyaretçi ──svc_talep_olustur()──▶ svc_talepler (durum: yeni)
                                        │  Burak değerlendirir
                                        ├─ beklemede / red  (svc_talep_karar)
                                        └─ kabul  ── svc_talep_kabul_et() ──┐  tek transaction
                                                                             ▼
             svc_musteriler ◀─ telefonla bul/oluştur ─ svc_adresler ◀─ svc_isler (talep_id = talep)
                                                                             │
Burak kendi işini de açar (talep_id NULL) ──────────────────────────────────┘
                                                                             │
                     asama: planlama → uygulama → olcum → raporlama → tamamlandi
                     durum: acik · beklemede · kapandi · iptal
                                                                             │
                                svc_paylasimlar (token özeti, alanlar[], süre, iptal)
                                                                             │
Müşteri ──svc_paylasim_oku(token)──▶ yalnız alanlar[] içindeki iş alanları
```

### Talep değerlendirmesi ayrı tablo olmalı mı? (istenen araştırma)

**Sonuç: Hayır, ama geçmiş kayıtsız da kalmaz.** Değerlendirme bir *karar*. Kararın şu anki
hâli talebin üstünde durur (`durum`, `karar_notu`, `karar_at`). Geçmişi ise ortak, silinemez
`svc_olaylar` tablosunda tutulur.

Ayrı bir `svc_talep_degerlendirmeleri` tablosu, ancak bir talebe birden fazla kişi karar
verseydi ya da karar bir puanlama veya form içerseydi gerekli olurdu. Tek sahip ve üç
seçenekli (kabul, beklet, reddet) bir kararda bu tablo yalnız birleştirme (join) maliyeti
ekler. "Beklet, sonra kabul et" gibi karar dizileri olay kaydından eksiksiz okunur.

Aynı olay tablosu iş aşamalarını ve paylaşım iptallerini de taşır. 2. aşamada stok
hareketleri için ayrı ve özel bir hareket tablosu kurulacak (§4), çünkü o hareketler **miktar**
taşır. Olay kaydı ise yalnız durum geçişlerini tutar.

Veritabanının zorladığı kurallar:
- Talebin müşteri tarafından gönderilen içeriği (ad, telefon, adres, açıklama) **sonradan
  değiştirilemez.** Sahip de değiştiremez; asıl kayıt korunur.
- `kabul` durumu ancak o talebe bağlı bir iş emri varsa yazılabilir. "Talep otomatik iş
  olmaz" ile "kabul = iş emri" birlikte sağlanır.
- `kabul` geri alınamaz. `red` ise tekrar `beklemede`ye alınabilir.
- Bir talepten en fazla bir iş emri çıkar (`svc_isler.talep_id UNIQUE`).

---

## 3. Dokuz veri grubu — ilişkiler

```
svc_talepler 1 ─── 0..1 svc_isler                 (kabul edilen talep → tek iş)
svc_musteriler 1 ── * svc_adresler                (adres geçmişi)
svc_musteriler 1 ── * svc_isler                   (iş müşterisiz de olabilir: kendi işin)
svc_adresler   1 ── * svc_isler                   (adres, işin müşterisine ait olmak ZORUNDA)
svc_isler      1 ── * svc_paylasimlar             (bir işe birden çok link: komşu, yönetici…)
svc_isler      1 ── * svc_gorevler   (opsiyonel)  (görev işe bağlanabilir, bağlanmak zorunda değil)
svc_isler      1 ── * svc_notlar     (opsiyonel)
svc_musteriler 1 ── * svc_notlar     (opsiyonel)
── 2. AŞAMA ────────────────────────────────────────────────
svc_isler      1 ── * svc_olcumler                (ölçüm işe ve/veya adrese bağlı)
svc_adresler   1 ── * svc_olcumler                (aynı tesisatın zamanla değişimi)
svc_ekipmanlar 1 ── * svc_olcumler                (hangi cihazla ölçüldü)
svc_isler      * ── * svc_malzemeler  via svc_is_malzemeleri
svc_malzemeler 1 ── * svc_stok_hareketleri ── * svc_stok_konumlari
svc_isler      1 ── * svc_finans     (opsiyonel)  (bağımsız gelir/gider de olur)
svc_is_malzemeleri 1 ── 0..1 svc_finans           (tüketimden doğan maliyet satırı)
```

| # | Tablo | Aşama | Görev | İlk aşamadaki bağlantı noktası |
|---|---|---|---|---|
| 1 | `svc_talepler` | 1 ✅ | Herkese açık başvuru + değerlendirme durumu | — |
| 2 | `svc_musteriler` | 1 ✅ | Kişi (telefon tekil) | — |
| ↳ | `svc_adresler` | 1 ✅ | Müşterinin adres geçmişi | `svc_isler.adres_id`, 2. aşamada `svc_olcumler.adres_id` |
| 3 | `svc_isler` | 1 ✅ | İş emri — yalnız Burak açar | 2. aşamadaki her tablonun `is_id`'si buraya bakar |
| 4 | `svc_paylasimlar` | 1 ✅ | Özetlenmiş token, alan beyaz listesi, süre, iptal | — |
| 5 | `svc_gorevler` | 1 ✅ | Görev ve hedef (`hedef_deger`/`gerceklesen` ile ölçülebilir) | `is_id` opsiyonel |
| 6 | `svc_notlar` | 1 ✅ | Teknik veya kişisel not | `is_id`, `musteri_id` opsiyonel |
| ↳ | `svc_olaylar` | 1 ✅ | Silinemez durum geçmişi | 2. aşama olayları da buraya yazar |
| 7 | `svc_olcumler` | 2 ⬜ | Ölçüm | — |
| 8 | `svc_malzemeler` + 5 yardımcı | 2 ⬜ | Bkz. §4 | — |
| 9 | `svc_finans` | 2 ⬜ | Gelir, gider, tahsilat | — |

**İlk aşamada bilerek EKLENMEYEN alanlar:**
- **`svc_isler`'de fiyat ve tutar yok.** Teklif, gelir ve tahsilat `svc_finans`'a ait. Şimdi
  işe bir `fiyat` sütunu koysak, 2. aşamada ya iki kaynaklı para bilgisi olurdu ya da bir veri
  taşıma işi doğardı.
- **Ziyaret ve tekrar gitme kaydı yok.** Malzeme belgesindeki "ikinci ziyaret nedeni" analizi
  ayrı bir ziyaret kaydı ister (§4.3). Bunu iş kaydına bir sayaç olarak eklemek, nedeni
  kaybettirirdi.

**Bilinçli kısıtlar ve takasları:**
- `svc_musteriler.telefon` tekil. Aynı telefonu paylaşan aile bireyleri tek kayıt olur.
  Apartman işinde yönetici ile daire sakini ayrı telefonla ayrı kişidir. Sorun çıkarsa kısıt
  kaldırılabilir.
- Adres müşteriye bağlı. Apartman gibi **birçok müşterinin ortak adresi** şu an her müşteri
  için ayrı adres satırıdır. Bina düzeyinde bir "tesis" varlığı (bina, şaft, merkezi sistem)
  ölçüm ve malzeme analizinde değerli olur. Ama gerçek talep görülmeden eklenmedi. Gerekirse
  `svc_tesisler` olarak açılır ve `svc_adresler.tesis_id` ile bağlanır; mevcut ilişki kırılmaz.

---

## 4. 2. aşama — ilişki tasarımı (şema YOK)

Burak'ın "BEE — Malzeme ve Saha Kaynak Yönetimi" belgesindeki ilkeler veri ilişkilerine
çevrildi. Alanlar kesinleşmedi; aşağıdakiler 1. aşamanın **bunları taşıyabildiğinin**
kanıtıdır, bir şema değildir.

### 4.1 Malzeme — "tek büyük tablo değil"

| Yapı | Sorumluluk | 1. aşamaya bağı |
|---|---|---|
| `svc_malzemeler` | Ürün kartı: `kaynak_turu` (sarf · montaj · olcum_ekipmani · alet · ise_ozel), birim (adet/metre), stok sınıfı A/B/C | — |
| `svc_ekipmanlar` | Tekrar kullanılan cihaz: durum (mevcut/planlanan/sipariş), konum, bakım. **Stoktan düşmez.** | `svc_olcumler.ekipman_id` |
| `svc_stok_konumlari` | Çanta, kutu, depo, "işe ayrılmış", "adreste bırakıldı" | — |
| `svc_stok_hareketleri` | Giriş · ayırma · sahaya çıkış · tüketim · iade · fire · düzeltme. **Satır başına `birim_maliyet` anlık kopyası** ve **idempotency anahtarı** | `is_id` opsiyonel |
| `svc_is_malzemeleri` | İş başına planlanan / ayrılan / kullanılan / iade | `is_id` → `svc_isler` |
| `svc_tedarik` | Satın alma ihtiyacı ve kaydı. **Öneri üretir, sipariş açmaz.** | — |

Belgedeki kurallar veri modelinde şöyle karşılanacak:
- **Fiziksel, ayrılmış ve kullanılabilir miktar ayrı:** `fiziksel = Σ hareket (giriş − tüketim − fire ± düzeltme)`,
  `ayrılmış = Σ açık işlerin ayrılan − kullanılan − iade`, `kullanılabilir = fiziksel − ayrılmış`.
  Ayırma **fiziksel stoğu azaltmaz** (belgedeki 30 / 12 / 18 örneği).
- **Kablo:** birim metre. Makara veya parça kimliği ayrı bir `svc_kablo_parcalari` tablosunda
  tutulur (uzunluk, kaynak makara). "38 m kaldı ama tek parça mı?" sorusunu yalnız bu cevaplar.
  Belgenin ifadesiyle **ihtiyaç doğarsa** açılır. `2.AŞAMA`
- **Geçmiş maliyet değişmez:** tüketim hareketi, birim maliyeti o anki değeriyle kopyalar.
  Sonradan değişen alış fiyatı eski işi etkilemez.
- **Çift kayıt engeli:** sahada çift dokunuş veya ağ tekrarı stoğu iki kez düşürmesin diye
  hareketlerde `UNIQUE(idempotency_key)`.
- **V0'da stok gösterilmez:** V0 yalnız `svc_is_malzemeleri` (ihtiyaç: var/eksik/alınacak)
  kullanır. Fiziksel miktar yokken "stokta 10 var" gösterilmez. Belgenin kabul kriteri buydu.

### 4.2 Ölçüm
`svc_olcumler`: `is_id`, `adres_id`, `ekipman_id`, ölçüm noktası, büyüklük, değer + birim,
koşullar, gözlem, zaman. Adrese bağlanması, aynı tesisatın aylar sonra tekrar ölçülüp
karşılaştırılmasını sağlar.

### 4.3 Finans
`svc_finans`: `tur` (gelir · gider), kategori (işçilik · malzeme · yol · genel gider…),
tutar, `is_id` opsiyonel (bağımsız gelir/gider de olur), opsiyonel `is_malzeme_id`.
**Talep edilen ve tahsil edilen tutar ayrı satırlardır**; tahsilat ayrı tabloya ya da türe
ayrılır. İş katkısı = iş gelirleri − iş bazlı malzeme tüketim maliyeti − diğer doğrudan iş
giderleri. Satın alma bir gider değil, bir **stok girişidir**; maliyet ancak tüketildiğinde
işe yazılır (belgedeki 2.000 TL / 600 TL örneği).

**Tekrar ziyaret** (belge §10): ölçülebilmesi için iş başına **ziyaret** kaydı gerekir
(`svc_ziyaretler`: `is_id`, tarih, sıra, `tekrar_nedeni`: yanlış teşhis · eksik malzeme ·
yanlış ürün · ekipman yok · beklenmeyen tesisat · müşteri kaynaklı · diğer). 2. aşamada malzeme
ile birlikte açılır.

### 4.4 Belgenin kör alanları
Belgenin 13. bölümündeki on soru **veriyle cevaplanacak**, varsayımla kesinleştirilmeyecek.
İlk ikisi (fiziksel stok hangi hacimde anlamlı · sarf girişi zaman kaybettiriyor mu) V0'ın
çıkış kriteridir. V0'da `svc_is_malzemeleri` kayıtlarının girilip girilmediği ve ne kadar
sürdüğü izlenmeden V1'e (gerçek stok) geçilmez.

---

## 5. Herkese açık talep — kötüye kullanım koruması

| Katman | Kural | Nerede |
|---|---|---|
| Kapı anahtarı | Doğrudan Supabase çağrısı reddedilir | DB (`svc_talep_olustur`) |
| IP sınırı | Saatte 3 talep / IP özeti | DB (IP özeti sunucudan gelir) |
| Telefon sınırı | 24 saatte 3 talep / telefon | DB |
| Genel sınır | Saatte toplam 40 talep (sel koruması) | DB |
| Uzunluk ve biçim | Ad ≤60, açıklama ≤2000, telefon `^905\d{9}$`, hizmet türü listeden | DB kısıtı |
| Eşzamanlılık | Sayım + ekleme tek kilit altında (`pg_advisory_xact_lock`) | DB |
| Bal küpü + süre | Görünmez alan dolu ya da form 3 sn'den kısa sürede gönderildiyse sessizce reddedilir | Sunucu (`api/public.js`, **henüz yazılmadı**) |

Talepler müşteri tablosunu kirletmez. Spam yalnız `svc_talepler`'e düşer; müşteri kaydı
**kabulde** doğar.

## 6. Paylaşım linki

- Token veritabanında üretilir (iki rastgele UUID → 64 hex, ~244 bit). **Düz metni
  saklanmaz**, yalnız SHA-256 özeti tutulur. Veritabanı sızsa bile çalışan bir link elde
  edilemez.
- `alanlar` beyaz listesi bir kısıtla korunur: `baslik · asama · planlanan_tarih ·
  musteri_aciklamasi · rapor_ozeti · bitis_at`. **`aciklama` (iç not), müşteri kaydı,
  adres, görev, not ve 2. aşama tabloları listede yok.** Sahip istese de bunlar paylaşılamaz.
- Süre: varsayılan 30 gün, en fazla 365 gün, ya da bilinçli olarak süresiz. İptal geri
  alınamaz; yeniden paylaşmak için yeni link açılır.
- Süresi dolmuş, iptal edilmiş ve hiç var olmamış link **aynı cevabı** verir (bulunamadı).
  Hangisi olduğu dışarıdan anlaşılamaz.

## 7. Sahip girişi
`svc_giris` tek satırlı (PBKDF2 + rastgele salt + kademeli kilit). Passkey ve TOTP için
`svc_giris` değişmez; ileride `svc_giris_anahtarlari` (WebAuthn credential) ve `svc_giris`'e
TOTP sırrı eklenir. Bu ayrı bir karar ve tasarım işidir. `2.AŞAMA`
