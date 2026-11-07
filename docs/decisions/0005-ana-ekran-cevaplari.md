# 0005 — Ana ekran keşfi: Burak'ın cevapları

Çerçeve: `docs/briefs/011-ana-ekran-kesif-soru-cevap.md`. Cevap = girdi (beyan, güven **Orta**); ölçümle çelişirse ölçüm kazanır.

| Soru | Cevap (Burak) | Burak'ın fikri | Tarih | Tasarım kuralı | Şablon alanı |
|---|---|---|---|---|---|
| ANA-1 | "İlk ne yapmak istediğim gibi bir şey yok, çoklu seçenek olması gerekiyor" | (cevabın kendisi fikirdir) | 2026-11-07 | Ana ekran **yönlendirme ekranıdır**: tek baskın eylem yok; eşit ağırlıklı en çok 4 giriş (Yeni iş · Bugün · Ara · Ödemeler). Sıra ve konum ANA-2/4/7 cevaplarından. ES-3 yönlendirme ekranı için güncellendi | A: tek birincil eylem (eylem ekranları için kalır); ES-3 |
| ANA-2 | Telefonla arıyorlar · Tavsiye / yüz yüze (Formdan ve platformdan **seçilmedi**) | | 2026-11-07 | İş, **anında ve elle** açılır (arama sırasında ya da yüz yüze). Herkese açık talep formu ve platform entegrasyonu **ertelenir** (YAGNI); `talep_kanali` = telefon · tavsiye/yüz yüze · diğer. İş aç ekranı konuşurken **tek elle, en az yazıyla** çalışmalı (hipotez, ANA-3 ve ANA-7 ile sınanır) | A: veri kaynağı; UX-2 |
| ANA-3 | Ad · Telefon · Adres/mahalle · Ne arızası/işi (**dördü de** elde) | | 2026-11-07 | Bilgi yokluğu sorun değil; sorun **yazma süresi**. Tek zorunlu alan kalır (telefon **veya** ad, 0004 ile aynı); diğer üçü aynı ekranda opsiyonel ve **dokunarak** doldurulur: arıza türü seçim düğmeleri, mahalle listeden seçim (serbest yazı yok). Hangi alanın zorunlu olacağı bu cevapla ayrışmadı; ANA-7 ve süre ölçümü (UX-1) belirler | A: zorunlu/opsiyonel; UX-2 |
| ANA-4 | Bugün kaç iş var · Ödemesi bekleyen (seçilen 2) | **Uzun fikir, bölüm "Fikir havuzu"nda** (sektör akışı, vaka güncellemeleri + puanlama, saha soru-cevap, 30 günlük plan, son 2 gün başarı şeridi, ileride birkaç kişiye açma) | 2026-11-07 | İki seçilen kutu, ANA-1'in yönlendirme girişleriyle **birleşir**: "Bugün" ve "Ödemeler" girişleri canlı sayı taşır (ayrı özet kutusu yok). Fikirler 4 küme olarak ayrıldı, ilk sürüme yalnız A (+ kişisel şerit B) girer | A: durumlar; ES-3 |

## Fikir havuzu (ANA-4, Burak 2026-11-07; cevap değil girdi)

| Küme | Burak'ın fikri | İlk değerlendirme | Ne zaman |
|---|---|---|---|
| **A · İş özeti** | Bugün kaç iş, ödemesi bekleyen | Modül 1; olaydan türetilir | **İlk sürüm** |
| **B · Kişisel ilerleme şeridi (yalnız Burak görür)** | Sağda son 2 gün: ne başardım, hangi arızayı çözdüm; "Bugün de başaracağız" hatırlatıcı; Gün 1–30 hedef çizelgesi, içeriği değiştirilebilir | Veri `svc_olaylar` kapanışlarından **türetilir**, ek alan sormaz. Slogan yerine **veriye dayalı cümle** önerilir ("Dün 3 iş kapattın") | İlk sürüme basit hâli (2 gün) · Gün 1–30 için **ANA-9 cevabı gerekli** |
| **C · Bilgi akışı** | Sektör/Oda duyuruları, teknoloji gelişmeleri, arıza tiplerine göre vaka çözümleri (diafon kontrol kalemi gibi), yurt dışı örnekler, 3 günde bir/haftalık güncelleme, zaman gruplu, **Burak puanlar** | Kaynak `knowledge/` (sohbet tarafı üretir), uygulama **yalnız okur**. Dış siteden otomatik çekim yok (hukuk/emek **Doğrulanmadı**). **Puan = ilgi sinyali, doğruluk kanıtı değil**: güven etiketini yalnız `field_report` (ölçüm/fotoğraf) yükseltir | Modül 1'den **sonra** |
| **D · Saha soru-cevap** | "Bugün anten işi yaptım, karşılaştığım problemler neler?" tarzı sorular; cevaplar işlenip sistem buna göre çalışır | Brief 005 soru sistemi ile aynı; cevaplar `cevap_olaylari` + gerekirse `field_report` | 005 düzeltmeler bittikten **sonra** |
| **E · Başkalarına açma** | Yakın birkaç kişiye ilerde verilecek; önce Burak deneyimleyecek | **Mimari karar**: bugünkü tasarım tek kullanıcı (`svc_giris` tek satır, rol yok). Çok kullanıcı ayrı karar kaydı ister (0006) | Burak deneyimledikten **sonra**, tetikleyici: "A+B 2 hafta kullanıldı" |
