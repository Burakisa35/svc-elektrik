# Brief 005 — Günlük soru-cevap sistemi (deneyim örnekleme + Cuma özeti)

Yazan: sohbet Claude'u · Uygulayan: Claude Code · Karar: Burak · Tarih: 2026-11-07 · Durum: taslak (brief 002'nin uzantısı; kayıt modeli: `docs/decisions/0003-cevap-kayit-modeli.md`)
Kaynaklar: Eisele ve ark. (soru uzunluğu), Williams ve ark. 2021 (uyum), Wrzus ve Neubauer 2022 (uyum ortalaması ~%80), Fritz ve ark. 2024 (istem süresi dolar), Di Stefano ve ark. (yansıtma), Uhlig ve ark. (haftalık plan). Hepsi **Orta**.

## 1. Amaç
Burak uygulamayı açtığında kısa sorular gelsin; cevaplar Supabase'e kaydolsun; Cuma günü tek ekranlık özet çıksın. İlk 3 gün soruları netleştirme günleridir. Bu sistem "son işlerde zamanı ne yedi" sorusunun (S1) cevabını hafızadan değil kayıttan üretir.

## 2. Tasarım ilkesi
"Çoklu soru" = gün içine yayılmış çok istem, **istem başına en fazla 3 soru**, hepsi tek dokunuş. Tek istemde uzun anket yok (uzun anket yükü ve dikkatsiz cevabı artırıyor, Orta).

## 3. Soru bankası
`docs/soru-bankasi/v1.json` (sahibi sohbet Claude'u; Code okur). 10 soru, 4 slot (sabah, akşam, gün sonu geri bildirim, Cuma). Derinleştirme: bir cevap, tetik kuralıyla en fazla 2 seviye ek soru açar (örn. kayıp 60 dk ve üstü → "önceden bilinebilir miydi"; ek iş sözlü → "neden yazılı değil").

## 4. Uygulama davranışı (Code)

| # | Gereksinim | Kabul ölçütü |
|---|---|---|
| 1 | Soru bankası uygulamayla birlikte dağıtılan statik dosyadan okunur (migration yok); çevrimdışı önbellekte durur | Uçak modunda sorular açılır |
| 2 | Tetik: slot koşulu + ilk açılış. İstem **süresi dolar** (sabah: öğlene, akşam: gün sonuna), birikmez | Dolan istem `suresi_doldu` olarak kaydolur |
| 3 | Her cevap `soru_id` + `soru_surumu` + `banka_surumu` ile kaydolur (0003) | Sürüm değişince eski cevap sürümünü korur |
| 4 | Atlanan/dolan istem de satır olur (cevap oranı hesaplanır) | Oran ekranda görünür |
| 5 | Çevrimdışı cevap cihazda UUID ile tutulur, bağlantı gelince eşitlenir; tekrar kayıt yok | Aynı UUID iki kez yazılmaz |
| 6 | Cevap süresi hedefi: tek istem ≤ 15 sn; serbest metin alanı **dikteyle** doldurulabilir (iOS klavyesi yeterli, ek bağımlılık yok) | Tek elle kullanılır |
| 7 | **Dışa aktar:** son N günün anonim JSON'u panoya kopyalanır (müşteri alanı ve `hassas_olabilir` serbest metin varsayılan dışarıda) | Burak sohbete yapıştırabilir |
| 8 | Cuma özeti (aşağıda) | n<5 ise "yetersiz veri" |

## 5. Üç günlük pilot protokolü

| Gün | Burak | Sohbet Claude'u | Code |
|---|---|---|---|
| 1–3, akşam | Akşam sorularından sonra Q-M1: "hangisi net değildi" (tek istem, serbest metin/dikte isteğe bağlı) | — | — |
| 1–3, gece/ertesi sabah | Dışa aktarıp sohbete yapıştırır | Veriyi okur: "diğer" oranı, atlanan, belirsiz işaretlenen. Değişiklik önerir, yeni `v1.x` yazar | Yeni bank dosyası birleşince dağıtılır |
| 3 sonu | Pilot kararı | Pilot raporu: tek sayfa | — |

Değişiklik kuralları:
- Günde en fazla **2** soru değişir (karşılaştırılabilirlik).
- Yalnız ifade netleştirme → aynı `id`, `surum` +1.
- Seçenek ekleme/çıkarma veya anlam değişikliği → **yeni `id`**, eskisi `kullanimdan_kalkti`; silinmez.
- "Diğer" cevabı > %30 olan sorunun seçenekleri gözden geçirilir.

## 6. Cuma özeti (en fazla 5 öğe)
1. Kategori başına kayıp dakika (n ile)
2. Ek iş sayısı ve yazılı onay oranı (n ile)
3. Cevap oranı (istem kaç kez cevaplandı)
4. Geçen haftayla fark
5. "Bu hafta şunu dene": tek öneri. Otomatik teşhis yok; öneri **kural tabanlı** ve dayandığı sayıyı gösterir. Hipotez durumu ("ek iş onaysızlığı ödeme gecikmesini açıklıyor" gibi) elle işaretlenir, sistem kendi kendine "doğrulandı" demez.

## 7. Pilot sonunda kararlar ve öldürme ölçütü (bizim tasarım tercihimiz)
- Sabah+akşam cevap oranı < %50 ise (2 hafta): soru sayısı azaltılır veya sistem durdurulur.
- Hedef ≥ %70 (literatür ortalaması ~%80 ama senin teşvikin yok: Orta).
- Median cevap süresi > 15 sn ise sorular sadeleştirilir.

## 8. Önyargı uyarısı
Sorular yalnız uygulamayı açtığında gelir; açılmayan yoğun günler eksik kalır. Cevap oranı ve "bugün hiç açılmadı" günleri Cuma özetinde görünmelidir.

## 9. Gizlilik ve repo
Repo public: cevap, döküm, örnek veri, anahtar girmez. Serbest metin müşteri adı/adres içerebilir: `hassas_olabilir`, analizde varsayılan gizli (brief 002 kararı).

## 10. Açık sorular (Burak)
1. Soru bankası dağıtımı: repo dosyası (önerilen: migration yok, her güncelleme tek birleştirme) mi, uygulama içinde Burak'ın düzenlediği ekran mı (daha hızlı, ama Code'un ek işi)?
2. Akşam eşiği 16:00 mı?
3. Sorular yalnız BEE için mi, TEHAİ teknisyenlerine de mi? (Bu brief BEE'yi varsayar.)
