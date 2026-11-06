# BEE

**Burak Elektrik ve Elektronik** — Güvenlik Sistemleri ve Teknik Servis
Kemalpaşa / İzmir

| Kullanım | İsim |
|---|---|
| Kısa marka | **BEE** |
| Tam marka | **Burak Elektrik ve Elektronik** |
| Faaliyet tanımı | Güvenlik Sistemleri ve Teknik Servis |
| PWA | BEE Teknik Servis |
| Kişisel çalışma alanı | BEE Çalışma Alanım |
| Proje deposu | `svc-elektrik` (şimdilik korunuyor) |

Tasarım ilkesi: müşteri için bir **teknik servis platformu**, sahip için bir **kişisel işletme ve
saha çalışma sistemi**. İkisi aynı PWA'da çalışır ama erişim sınırları farklıdır.

## Üç kullanım alanı

| Alan | Kim | İçerik |
|---|---|---|
| Müşteri | Herkese açık | Hizmetler · talep formu · iletişim |
| BEE Çalışma Alanım | Yalnız sahip | İşlerim · hedeflerim · notlarım · (2. aşama: gelir/stok/ölçüm) |
| Paylaşım | Özel bağlantıya sahip olan | İş durumu · ilerleme · seçili rapor (yalnız sahibin seçtiği alanlar) |

## Kesin mimari kurallar

- Tek sistem sahibi vardır; rol veya hesap sistemi yoktur. Müşteri hesap açmaz.
- Müşteri talebi otomatik iş emri oluşturmaz. Talep, sahibin değerlendirme havuzuna düşer
  (Kabul · Beklet · Reddet).
- İş emrini yalnız sahip onaylar, oluşturur ve yönetir. Talep olmadan da iş açılabilir.
- Paylaşım bağlantısını yalnız sahip oluşturur ve iptal eder. Bağlantılar tahmin edilemez,
  süreli ve iptal edilebilirdir.
- Müşteri kişisel notları, finans bilgilerini veya başka müşteri kayıtlarını göremez.
- Yetkilendirme yalnız arayüzde değil, **sunucu ve veritabanı** seviyesinde uygulanır.

## Altyapı

- **Supabase projesi:** `burak-elektrik` · ref **`uwmbtaxxdcjumxbnigpy`** · Frankfurt (`eu-central-1`).
  **TEHAİ'den bağımsızdır** (Burak kararı, 2026-11-06). Önceki "TEHAİ ile aynı Supabase
  projesi, `svc_` önekiyle ayrım" kararı **geçersiz**. Gerekçe: aynı projede `service_role` key
  ortak olurdu ve anon rolü `public` tablolarında varsayılan olarak tam yetkiliydi (TEHAİ'de
  ölçüldü). Önek bir izolasyon değildir.
- Her migration'ın ilk satırı kimlik kapısıdır: `select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');`
  Yanlış veritabanında çalışırsa hiçbir satır uygulanmaz.
- Ücretsiz plan: bir hafta istek gelmeyen proje uyku moduna alınabilir (Supabase genel kuralı,
  hesap ayarında doğrulanmadı).
- Vercel serverless (`api/`), vanilla HTML/CSS/JS, build adımı yok.

## Durum (2026-11-06)

| Katman | Durum | Kanıt |
|---|---|---|
| Veri modeli (9 grup) | Tasarlandı | `docs/VERI_MODELI.md` |
| Migration 0000 (kimlik) + 0001 (operasyon çekirdeği) | **Canlıda uygulandı** | `list_migrations` · uygulanan SQL'in MD5'i repodaki dosyayla birebir aynı |
| Migration 0002 (sahip işlemleri veritabanı fonksiyonu, service_role yok) | **Canlıda uygulandı** | MD5 dosyayla aynı |
| Migration 0003 (PBKDF2 600k giriş) | ⚠️ **YAZILDI, UYGULANMADI** — Supabase onay sorusu cevapsız kaldı | `list_migrations`'ta yok |
| Veritabanı erişim testleri | **38/38 geçti** · 3 bozma testiyle sınandı (0001 için) | `tests/db-erisim.sql` |
| Dışarıdan HTTP erişimi (publishable key) | Bütün tablolar 401 · kapısız RPC 401 | Bkz. "Doğrulama" |
| 2. aşama (ölçüm · malzeme · finans) | **Yalnız tasarım — şema YOK** | `docs/VERI_MODELI.md` §4 |
| API (`api/panel.js`, `api/public.js`) | ⚠️ **Eski şemaya bakıyor, çalışmaz** | Yeni tablolara taşınacak |
| Ekranlar (panel, giriş, paylaşım, PWA manifest/SW) | Yok | — |
| Ana sayfa formu | ⚠️ Olmayan `/api/submit`'e gidiyor | API ile birlikte düzeltilecek |

## Kurulum notları (sahip yapar)

1. **Supabase Auth kaydını kapat:** Authentication → Sign In / Providers → "Allow new users to
   sign up" kapalı. Veritabanı `authenticated` rolüne zaten hiçbir yetki vermiyor; bu ikinci önlem.
2. **Vercel ortam değişkenleri** (değerler sohbete veya repoya yazılmaz):
   `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `JWT_SECRET`,
   `PANEL_ILK_SIFRE`, `BEE_KAPI_ANAHTARI`. Kapı anahtarının özeti, ilk sahip girişinde sunucu
   tarafından `svc_ayarlar`'a yazılır (API güncellemesinde).

## Doğrulama

```bash
# Veritabanı erişim testleri: SQL Editor'de tests/db-erisim.sql'i çalıştır.
# Beklenen: "BEE_TEST_SONUC kalan=0" (kasıtlı hata — test verisi geri alınır).
```
