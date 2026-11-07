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
| Mobil düzen: taşma, 44 px hedef, 16 px yazı | 2 | Tarayıcı (Chromium 375×667 ve iPhone 11 boyutu) | ekran ölçümü |

### Bağımlılık sırası
1. [ ] `0006` canlıda. 07:2x'teki ilk deneme veritabanına ulaşmadı (`postgres_logs`, `log_statement=ddl`; TEHAİ'de de iz yok)
2. [ ] Önce test: `db-is.sql` ve yarış testi yazılır, ilk koşuda kırmızı
3. [ ] `0007`: Vaka 1 ve Vaka 3 düzeltmesi, testler yeşil. Burak onayıyla uygulanır
4. [ ] API: giriş/çıkış, iş aç, güncelle, oku (`svc_*` sözleşmesi, service_role yok)
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
- Vaka 2, tutar: NaN kabulü ve virgüllü tutarın kaydı düşürmesi (`araclar/teshis/ADAYLAR.md`). Sonraki dilim.
- C5 kararı: iptal edilmiş iş tamamlanabilir mi? (Burak)
- Skill'i üçe bölme (goal-planner / code-executor / root-cause). 2026-11-07 ertelendi; bu dosya ilk ikisinin işini görüyor.
- HTML kalite kapıları briefinin (2026-11-07) kalanı. Bu dilime uygulanan kısmı yukarıdaki risk tablosu ve bitti tanımı. Core Web Vitals ölçümü, görsel regresyon ve çok sayfalı akış testleri sonraki dilimlerde.
- Müşteri linki `/is`, talep formu, notlar ve görevler.
- Legacy `anon` ve `service_role` anahtarlarının kapatılması (Burak, dashboard).
- `svc_musteri_bul_ac`: aynı yeni telefonla iki eşzamanlı iş (ADAY, ölçülmedi).
