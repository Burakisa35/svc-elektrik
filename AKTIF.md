# AKTİF — tek aktif iş (WIP = 1)

**Kural (Burak, 2026-11-07):** bu dosyada tek bir `## Aktif:` bölümü olur. Yeni fikir ya da brief gelirse "Bekleyenler"e yazılır; aktif iş kapanmadan yenisine başlanmaz. Sırayı Burak seçer. `bash araclar/dogrula.sh` bu kuralı denetler.
**Karar zinciri (Burak, 2026-11-07):** Kabul kriteri → Risk-temelli test → Kalite kapısı → Bitti tanımı → Durdurma kuralı. Yol üstünde hata çıkarsa teşhis katmanı devreye girer: `.claude/skills/kod-analizi/SKILL.md`.

## Aktif: Modül 1 · Dilim 1 — giriş → iş aç → tamamla → yeniden oku (Burak'ın telefonunda)
Başlangıç: 2026-11-07 · Durum: sürüyor

### Kabul kriterleri (Burak telefonda dener)
- K1 Önizleme adresinden parolayla giriş yapılır.
- K2 Yalnız telefon numarasıyla iş açılır, 30 sn içinde.
- K3 İş "tamamlandı" yapılır.
- K4 Sayfa yenilenince durum doğru görünür.
- K5 Beşinci yanlış parolada giriş kilitlenir.
- K6 Çıkıştan sonra panel açılmaz (geri tuşu ve yenileme dahil).

### Risk-temelli test (her risk en ucuz yeterli seviyede)
| Risk | Ş | Seviye | Test |
|---|---|---|---|
| Yetkisiz ya da oturumsuz erişim | 5 | DB (var) + API sözleşmesi | `db-erisim.sql`, `db-oturum.sql` (var); API testi (yazılacak) |
| Yeniden deneme veya çift dokunuş: çift kayıt ya da "başarısız" görünen başarılı kayıt (ADAYLAR Vaka 1) | 4 | DB + eşzamanlılık | `db-is.sql` + yarış testi (yazılacak, önce kırmızı) |
| Çelişkili durum isteği sessizce yutuluyor (ADAYLAR Vaka 3) | 4 | DB | `db-is.sql` (yazılacak, önce kırmızı) |
| DB hata metni tarayıcıya sızıyor (`src/api/panel.js:34`) | 3 | API sözleşmesi | yanıt yalnız `BEE_*` eşlemesi taşır |
| iOS'a özgü: çerez, Safari, ana ekran | 3 | Gerçek cihaz | Burak, K1–K6 |
| Gateway başlığı geçirmezse oturum modeli hiç çalışmaz (D8) | 5 | Canlı HTTP | `svc_saglik`: **geçiyor** (ölçüldü). Her deploy'dan sonra duman testi |
| Kilit süresi 35. turda taşıyor, kilit hiç devreye girmiyor: sınırsız deneme (D1) | 5 | DB | 35. tur testi |
| Çıkış reddedilse de "çıkıldı" görünüyor (O6 ölçütü, D2) | 4 | DB + API | çıkış sonucu ayrıca doğrulanır |
| Herkese açık girişte 5 yanlışla Burak 24 saate kadar dışarıda kalır (D6) | 4 | API | IP başına ön sınır |
| Mobil düzen: taşma, 44 px hedef, 16 px yazı | 2 | Tarayıcı (Chromium 375×667 ve iPhone 11 boyutu) | ekran ölçümü |

### Bağımlılık sırası (denetim sonrası, 2026-11-07: `araclar/teshis/DENETIM-2026-11-07.md`)
1. [x] Başlık yoklaması (D8): gateway `x-bee-oturum`'u veritabanına **geçiriyor** (2026-11-07 08:0x UTC, gerçek HTTP: başlıksız false, doğru başlık true, büyük harfli ad true, bozuk değer false, anahtarsız 401). `0007_saglik` canlıda, MD5 `644af796…` = dosya
2. [x] Önce test, ilk koşuda kırmızı (2026-11-07): `db-is.sql` I3, I4, I7; `db-oturum.sql` G6, G7; `yaris-is.sh` Y1 kırmızıydı. I1, I2, I5, I6, I8, O6a, O6, Y2 geçiyordu. Y1, `svc_musteri_bul_ac`'taki müşteri yarışını da gösterdi
3. [ ] `0008_dilim1_duzeltme`: bu davranışların düzeltmesi. Yerelde bütün testler yeşil; canlı modeli (`ATLA=0006`) yalnız 0006'ya bağlı 2 bilinen KALDI. B17 öldü; B04 ve B14 0008'e hedeflenince öldü (G3, G4, G6 / I2, Y1). **Canlıya uygulama Burak onayı bekliyor**
4. [ ] API: giriş/çıkış, iş aç, güncelle, oku (`svc_*` sözleşmesi, service_role yok, IP başına giriş ön sınırı)
5. [ ] Tek ekran (panel)
6. [ ] Kurulum: `svc_kurulum` anahtarları, Vercel ortam değişkenleri, önizleme adresi
7. [ ] Burak telefon testi, K1–K6

### Bitti tanımı
- K1–K6 Burak'ın telefonunda geçti (Burak beyanı).
- `bash araclar/dogrula.sh` yeşil. Risk tablosundaki her satırın testi var ve geçiyor.
- Kapsam dışı iş eklenmedi. Kalan riskler `TESLIMLER.md`'de.

### Durdurma kuralı
Bitti tanımı sağlanınca dilim kapanır. Yeni iyileştirme fikri "Bekleyenler"e gider. Bu dilimde yok: görsel cila, tutar alanı, müşteri linki, talep formu.

## Bekleyenler (sırayı Burak seçer)
- `0006`: talep formu ve `ertelendi`/`kacirildi` için gerekli, dilim 1 için değil (D7). Mobilde Run yok; yol Burak kararı: masaüstü, yıkıcı olmayan sürüm (`rename` + `revoke`) ya da Management API.
- Test borcu (`bozma.sh`'ta yaşayanlar): B07 (O8 iki kapıyı da denemeli), B09 (olay kaydı: silme ve `postgres` rolü), B10 (iş silinmezliği), B15 (kurulum kilidi).
- D4 kararı: yeniden açılan işte bitiş zamanı silinsin mi, "ilk bitiş" mi kalsın? (Burak)
- D5: koruma hook'u canlıda çalışmıyor (3. oturum). ADAY: `settings.json` yüklenmiyor.
- D6: kilit tasarımı (global ya da istemci başına) karşılaştırması.
- "Bütün oturumları kapat" yolu yok (kayıp telefon).
- Vaka 2, tutar: NaN kabulü ve virgüllü tutarın kaydı düşürmesi (`araclar/teshis/ADAYLAR.md`). Sonraki dilim.
- C5 kararı: iptal edilmiş iş tamamlanabilir mi? (Burak)
- Skill'i üçe bölme (goal-planner / code-executor / root-cause). 2026-11-07 ertelendi; bu dosya ilk ikisinin işini görüyor.
- HTML kalite kapıları briefinin (2026-11-07) kalanı. Bu dilime uygulanan kısmı yukarıdaki risk tablosu ve bitti tanımı. Core Web Vitals ölçümü, görsel regresyon ve çok sayfalı akış testleri sonraki dilimlerde.
- Müşteri linki `/is`, talep formu, notlar ve görevler.
- Legacy `anon` ve `service_role` anahtarlarının kapatılması (Burak, dashboard).
- `svc_musteri_bul_ac`: aynı yeni telefonla iki eşzamanlı iş (ADAY, ölçülmedi).
