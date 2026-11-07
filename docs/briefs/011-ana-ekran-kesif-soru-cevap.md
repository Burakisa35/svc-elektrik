# Brief 011 — Ana ekran keşfi: soru-cevapla tasarım

Yazan: sohbet Claude. Cevaplayan: **Burak**. Uygulama: Code (cevaplardan sonra). Cevap kaydı: `docs/decisions/0005-ana-ekran-cevaplari.md`.
Amaç: ekranları "güzel olsun" diye değil, **Burak'ın gerçek iş davranışından** çıkarmak. Önce ana ekran; ondan çıkan cevaplar diğer ekranları (iş aç, iş listesi, iş detayı, müşteri sayfası) türetir.

## 1. Yöntem (neden böyle)
- **Somut davranış sor, özellik isteği sorma.** "Şu özellik olsun mu?" evet'e kayar. "Son 10 işin nasıl geldi?" gerçeği verir. (Orta; anket tasarımı ilkesi, Burak'ın "deneme-yanılma" yaklaşımıyla uyumlu.)
- **Bir seferde bir soru**, tıklanır seçenek + serbest metin. Toplam **8 soru**; cevaplardan doğan, gerekçesi yazılı **en çok 2 ek soru** (ANA-9, ANA-10). Daha fazlası yok.
- **Fikir hakkı (Burak, 2026-11-07):** her soruda seçeneğin yanında **kendi fikrini** yazabilir. Fikir cevaptan ayrı kaydedilir ("Burak'ın fikri" sütunu) ve seçenekten **ağırlıklıdır**: seçenekler benim tahminimdir, fikir senin sahandır. Fikir seçeneklerle çelişirse tasarım fikre göre kurulur, seçenek listesi düzeltilir.
- **Her cevap bir tasarım kuralına dönüşür** (bölüm 3): hangi ekran alanını etkiler, güveni ne.
- **Beyan ≠ davranış.** Cevaplar "beyan"dır ([stated], Orta). Uygulama içi soru sistemi (brief 005) gerçek kullanımı ölçünce çelişki varsa **ölçüm kazanır**.
- Cevap çıkmayan ya da "bilmiyorum" gelen yer tahminle doldurulmaz: "Doğrulanmadı" kalır, ilk sürümde en sade seçenek konur.

## 2. Soru bankası (sıra bağımlılığa göredir)

| ID | Soru | Seçenekler (serbest metin her zaman açık) | Etkilediği şey |
|---|---|---|---|
| ANA-1 | Telefonu ana sayfaya açtığında **ilk** ne yapmak istersin? | Yeni iş aç · Bugünkü işlerime bak · Bir müşteriyi/işi ara · Bekleyen ödemelere bak | Ana ekranın **tek birincil eylemi** (ES-3, UI-2) |
| ANA-2 | Son 10 işin **nasıl** geldi? | Telefonla aradılar · Tavsiye/yüz yüze · Formdan · Platformdan · Başka | İş açma yolu, `talep_kanali` seçenekleri, form ihtiyacı |
| ANA-3 | İş açarken **o an** elinde hangi bilgi oluyor? | Ad · Telefon · Adres/mahalle · Ne arıza olduğu · Hiçbiri, sonra yazarım | Tek zorunlu alan (mevcut: telefon **veya** ad), isteğe bağlı alan sırası |
| ANA-4 | Gün içinde bir bakışta **neyi bilmek** istersin? (en çok 3) | Bugün kaç iş var · Yolda/devam eden · Ödemesi bekleyen · Malzeme eksiği · Yarınki işler | Ana ekran **özet kutuları** (en çok 3) |
| ANA-5 | Seni en çok **hangisi** yoruyor ya da kaçırtıyor? | Unutulan iş/geri arama · Geciken ödeme · Sonradan eklenen ek iş (kapsam büyümesi) · Malzeme/eksik parça · Müşteriyi bulamamak | Uyarı kuralları, durum rengi/çipi, bildirim ihtiyacı |
| ANA-6 | İşin **durumları** hangileri gerçekten kullanılıyor? | Yeni · Planlandı · Yolda · Devam · Tamamlandı · İptal · Kaçırıldı (hangilerini silelim/ekleyelim?) | Durum kümesi, geçiş düğmeleri, iş listesi filtreleri |
| ANA-7 | Sahada telefonu **nasıl tutuyorsun**? | Tek el, başparmak · İki el · Eldivenle · Merdivende/yüksekte | Dokunma hedefi boyutu, alt çubuk, tehlikeli eylemlerin yeri (UI-1, UI-2, UI-7) |
| ANA-8 | İnternet **ne sıklıkla** gidiyor ve ne yaparken? | Her gün (bodrum/kat arası) · Ara sıra · Neredeyse hiç | Çevrimdışı önceliği (PF-2), kuyruğa alma, senkron çipi |

(Müşteri sayfası ve para alanı sorusu **ANA-4/5 cevaplarından sonra** gerekirse eklenir; şimdiden sorulmaz.)

## 3. Cevap → tasarım kuralı (dönüşüm mantığı)

| Cevaptan çıkan | Dönüştüğü kural | Hangi şablon alanı |
|---|---|---|
| ANA-1 | Ana ekran **tek** dolu düğme = seçilen eylem; diğerleri ikincil | A: tek birincil eylem; ES-3 |
| ANA-2 | İş açma kanalı listesi cevaplardan; formdan gelen iş yoksa herkese açık form ertelenir (YAGNI) | A: veri kaynağı |
| ANA-3 | Zorunlu alan = en sık **elde olan** bilgi; geri kalan opsiyonel ve sonradan eklenir | A: zorunlu/opsiyonel; UX-2 |
| ANA-4 | Özet kutusu sayısı ≤ 3 ve cevapla sınırlı; eksik veri "bilinmiyor" (UX-8) | A: durumlar |
| ANA-5 | En çok yoran şey **tek bir uyarı kuralı** olur (örn. "ödemesi 7 gündür bekleyen iş"); renk **yalnız** gerçek sorunda (brief 007 K1) | ES-5 |
| ANA-6 | Durum kümesi = kullanılanlar; kullanılmayan durum kodda tutulup arayüzde gizlenir (geri dönüş kolay) | UX-6 geri alma |
| ANA-7 | Hedef boyutu ≥ 44 pt tabanı; tek elde başparmak bölgesine birincil eylem; eldivende 48+ ve geniş aralık | UI-1, UI-2, UI-7 |
| ANA-8 | Çevrimdışı yazma kuyruğu kapsamı: sık gidiyorsa "iş aç" çevrimdışı çalışır; nadirse yalnız okuma önbelleği | PF-2 (E) |

**Ekran türetme sırası:** ANA-1…8 → (1) ana ekran şartnamesi, (2) iş aç ekranı, (3) iş listesi + durumlar, (4) iş detayı, (5) müşteri sayfası. Her biri `ekran-sablonu.md` A bölümüne dönüşür; estetik yön brief 007 ES-6 ile ayrı onaylanır.

## 4. Kayıt ve güven
- Cevaplar `0005-ana-ekran-cevaplari.md` dosyasında satır satır: soru · cevap · tarih · tasarım kuralı · güven (**beyan = Orta**).
- Uygulama canlıya çıkınca brief 005 soruları bu kuralların bir kısmını **ölçer** (örn. ANA-4: hangi özet kutusuna gerçekten bakılıyor?). Çelişki → kural yeniden açılır.
- Cevaplar karar değil **girdi**; son karar tasarım şartnamesinde Burak onayıyla.

## 5. Kabul ölçütü
Burak 8 soruyu ≤ 10 dakikada cevaplayabilmeli (tek tek tıklayarak); sonunda tek sayfada "ana ekran şartnamesi" taslağını okuyup "evet bu benim işim" ya da neyin yanlış olduğunu söyleyebilmeli.
