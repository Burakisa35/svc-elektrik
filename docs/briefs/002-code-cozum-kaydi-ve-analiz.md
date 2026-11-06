# Brief 002 — Arıza çözüm kaydı ve gelişim analizi (Claude Code için)

Yazan: Claude (sohbet) · Uygulayan: Claude Code · Karar: Burak
Tarih: 2026-11-07 · Durum: taslak (Burak onayı ve kapı G2/G3 bekler)
Kaynak istek: Burak, 2026-11-07 01:30 — marka arıza ailelerinin listelenmesi, çözüm soru-cevap parametreleri, çözüm saat/dakika kaydı, gelişimsel analiz.

## 1. Burak sahada şunu yapabilmeli (kabul ölçütü)

1. Bir arıza vakası açıp **belirtiyi aileden** seçebilmeli (F1…), sonra **soruları** (Q-…) seçmeli cevapla, tek elle, yazı yazmadan yanıtlayabilmeli.
2. Uygulama, vakanın hipotezlerini (H1…) ve her test adımının "neyi eler" metnini göstermeli; hipotez durumunu (canlı / elendi / doğrulandı) **Burak elle işaretler**. Cevap → hipotez otomatik eşlemesi yoktur ve uygulama tanı **koymaz**; böyle bir eşleme gerekirse önce bilgi tabanına makine okunur biçimde eklenir (G2 işi).
3. Her test adımını bitirdiğinde tek dokunuşla işaretleyebilmeli; **saat:dakika** otomatik kaydedilmeli, elle düzeltilebilmeli.
4. Vakayı "çözüldü / kısmen / çözülemedi / bekliyor" ile kapatabilmeli (kayıt değerleri `cozuldu / kismen / cozulmedi / bekliyor`), kök neden sınıfını ve **sahada doğrulandı mı** (`field_verification`) bilgisini girebilmeli.
5. Kapanıştan sonra **tekrar kontrol tarihi** koyabilmeli; arıza geri geldiyse aynı vakayı yeniden açabilmeli (yeni vaka değil, zincir).
6. Zayıf internette vaka açabilmeli ve adımları kaydedebilmeli; bağlantı gelince eşitlenmeli.
7. Geçmiş vakalardan şunu görebilmeli: marka/aile bazında **çözüm süresi**, **hangi hipotez kaç kez doğrulandı**, **hangi adım çözümü en çok getirdi**, tekrar eden arızalar.

## 2. Bilgi tabanından gelen kimlikler (değiştirme)

`knowledge/_SPEC.md` "Çözüm kaydı sözlüğü" ve `knowledge/fault-families/*.md`: `family_id`, `question_id`+cevap, `hypothesis_id`, `step_id`, `outcome`, `root_cause_class`, `field_verification`. Importer bu dosyaları okur; **içeriği düzenlemez**. Aile/soru/hipotez/adım kodları kalıcıdır (SPEC'te tanımlı); kaldırılanlar `status: kaldirildi` ile gelir, kayıtlar bozulmamalı.

Çözüm kayıtları bilgi tabanına **yazılmaz**; uygulama verisidir. Bilgi tabanına geri dönüş yolu: Burak onaylar, ben (sohbet) `field_report`/vaka sonucu olarak knowledge/ içine işlerim.

## 3. İş gereksinimleri (nasıl yapılacağı Code'un kararı)

- **Zaman**: UTC saklama, gösterim Europe/Istanbul. Süre = çözüm anı − vaka açılışı; **adım süreleri** ardışık damgalardan türetilir. "Aktif çalışma süresi" ile "bekleme" (örn. malzeme, ertesi gün) ayrılabilmeli: kullanıcı vakayı duraklatabilmeli.
- **Denetim izi**: damgalar silinmez; elle düzeltme yeni değer + eski değer olarak saklanır.
- **Cevap değişikliği**: bir soruya verilen cevap sonradan değişirse önceki cevap saklanır (hipotez durumu neden değişti sorulabilsin).
- **Kanıt eki**: fotoğraf/ölçüm değeri vaka adımına eklenebilmeli (ölçüm: iletkenler, değer, birim). Bunlar kaynak sınıfı "saha"dır ve `field_report` olarak knowledge'a dönüşe aday.
- **Analiz** (kayıt sayısı azken yanıltıcıdır): her metrikte örnek sayısı (n) gösterilmeli; n < 5 iken "yetersiz veri" etiketi. Önerilen görünümler: aile/marka başına medyan çözüm süresi; hipotez doğrulanma/elenme sayıları; adım başına "çözüme götürdü" sayısı; tekrar açılma oranı; doğrulanmamış çözümler ayrı sayım.
- **Gizlilik**: müşteri adresi/ismi analiz görünümlerine ve dışa aktarıma varsayılan olarak girmez; bu kararı Burak verir.

## 4. Sınırlar

- Uygulama tanı **koymaz**, yalnız kayıt, süre ve istatistik tutar. "Muhtemel neden" gösterimi, dayanak knowledge'daki etiketli hipotezdir; etiket (Yüksek/Orta/Doğrulanmadı) ekranda görünür kalır.
- Mevcut `index.html`'e yama yok; tasarım sıfırdan (kök CLAUDE.md).
- Migration dosya olarak yazılır, uygulama önce Burak'a sorulur (kök CLAUDE.md kural 4).

## 5. Açık sorular ve kararlar

1. ~~Müşteri/adres bilgisi vakada tutulsun mu?~~ **Karar (Burak, 2026-11-07 01:33):** tutulur; analiz görünümlerinde ve dışa aktarımda varsayılan olarak gizli.
2. "Aktif süre" için duraklatma düğmesi yeterli mi, yoksa yalnız açılış-kapanış farkı mı yeter?
3. Eski (kağıtta/bellekte) vakalar geriye dönük girilecek mi? Girilirse damgalar "tahmini" işaretlenmeli.

## 6. Denetim

Her PR G3 kapısından geçer (Vercel önizlemesi iPhone'da test). Bu brief'in kabul ölçütü maddeleri G4 saha testinde Burak tarafından işaretlenir.
