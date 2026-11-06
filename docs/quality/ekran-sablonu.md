# Ekran şablonu: şartname + denetim (VAR / YOK mantığı)

Amaç: Code bir ekranı tasarlamadan önce bu şablonla **şartname** yazar; üretimden sonra **üreten olmayan taraf** aynı şablonla denetler. Her satır **VAR / YOK / KISMEN / DOĞRULANMADI** olarak işaretlenir ve kanıtı yazılır ("baktım" kanıt değildir: ölçüm çıktısı, ekran görüntüsü, komut çıktısı).
**E = engelleyici:** E satırı YOK veya DOĞRULANMADI ise modül kapanmaz (gates.md G3'e ek).
Ölçüm sınırı: ortamda yalnız Chromium var; Safari (iOS) davranışı **Burak'ın telefonunda** doğrulanır, o satırlar "el" etiketlidir.
Test genişlikleri: 375 px (küçük iPhone), 414 px (iPhone 11 CSS genişliği, Orta). Düzen kaynak okunarak değil tarayıcıda ölçülür.

## A. Ekran şartnamesi (her ekran için, üretimden ÖNCE doldurulur)

| Alan | Doldurulacak |
|---|---|
| Ekran adı ve adresi | örn. `panel` / `/panel` |
| Kullanıcı ve bağlam | kim, nerede, hangi elle, internet nasıl |
| **Tek birincil eylem** | ekranın bir cümlelik işi (varsa ikincil eylemler ayrı) |
| Süre hedefi | örn. iş aç ≤ 30 sn |
| Zorunlu / opsiyonel alanlar | zorunlu en az sayıda |
| Durumlar | boş · yükleniyor · hata · başarı · çevrimdışı · oturum bitti |
| Veri kaynağı | hangi `svc_*` fonksiyonu / API ucu |
| Gösterilmeyecekler | gizli alanlar (telefon, adres, fiyat...) |
| Estetik yön | **Burak'ın kararı** (bkz. B1); tek kaynak `src/styles/tokens.css` |

## B. Denetim satırları

### B1. Estetik (görsel dil)
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| ES-1 | Renkler, yazı boyutları, boşluklar yalnız `tokens.css` değişkenlerinden gelir (satır içi sabit renk yok) | kaynak taraması (grep) | | ☐ |
| ES-2 | Tek yazı tipi ailesi, en çok 3 boyut kademesi; başlık/gövde/ikincil ayrımı net | ekran görüntüsü, 375 ve 414 | | ☐ |
| ES-3 | Görsel hiyerarşi: ekranda yalnız **bir** baskın (dolu) düğme, o da birincil eylem | ekran görüntüsü | | ☐ |
| ES-4 | Boşluk ölçeği tutarlı (tokens'taki kademeler dışında değer yok) | grep | | ☐ |
| ES-5 | Durum renkleri anlamla eşleşir (yeni/devam/tamam/iptal) ve **yalnız renkle** anlatılmaz (yazı da var) | ekran görüntüsü | | ☐ |
| ES-6 | Estetik yön Burak tarafından yazılı onaylandı (renk, ton, 2–3 örnek ekran) | karar kaydı | **E** | ☐ |

### B2. UX (görev akışı)
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| UX-1 | Birincil görev süre hedefini tutuyor (iş aç ≤ 30 sn) | Burak telefonda kronometre, 3 deneme (el) | **E** | ☐ |
| UX-2 | Zorunlu alan sayısı şartnamedekiyle aynı (iş aç: tek alan) | form taraması | **E** | ☐ |
| UX-3 | Hata önleme: yanlış girişi yazarken uyarır, gönderince değil; çift gönderme engelli (istemci UUID) | davranış testi | | ☐ |
| UX-4 | Her eylem geri bildirim verir (kaydedildi, hata, bekleme) ve **sessiz başarısızlık yok** | davranış testi, ağı kapat | **E** | ☐ |
| UX-5 | Şartnamedeki 6 durum (boş, yükleniyor, hata, başarı, çevrimdışı, oturum bitti) ekranda tasarlanmış | her durumu zorla, ekran görüntüsü | **E** | ☐ |
| UX-6 | Geri alma/iptal: yanlış durum değişimi tek adımda geri alınabilir | davranış testi | | ☐ |
| UX-7 | Sistem kendi kararıyla iş kapatmaz/mesaj atmaz (yalnız uyarı ve taslak) | kod taraması + davranış | **E** | ☐ |
| UX-8 | Eksik veri sıfır gibi gösterilmez ("bilinmiyor" ile ayrılır) | veri boşken ekran | | ☐ |

### B3. UI / etkileşim (tek el)
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| UI-1 | Tüm dokunma hedefleri ≥ 44×44 pt (Apple); alt sınır WCAG 2.2 AA ≥ 24×24 CSS px | tarayıcıda hedef boyutu ölçümü | **E** | ☐ |
| UI-2 | Birincil eylem ekranın alt yarısında, başparmak erişimindedir; üst köşelerde kritik düğme yok | ekran görüntüsü, 375×667 | | ☐ |
| UI-3 | Form yazı boyutu ≥ 16 px (iOS odakta zoom yapmasın) | hesaplanan stil ölçümü | **E** | ☐ |
| UI-4 | Doğru klavye: telefon `inputmode="tel"`, sayı, not alanı büyük; otomatik tamamlama uygun | kaynak + el | | ☐ |
| UI-5 | `100dvh`, `viewport-fit=cover`, `env(safe-area-inset-*)` kullanılır; alt çubuk çentiğe/ana çubuğa binmez | kaynak + **el (Safari)** | | ☐ |
| UI-6 | Yatay kaydırma yok (375 ve 414) | tarayıcı ölçümü | **E** | ☐ |
| UI-7 | Yanlış dokunmaya karşı bitişik hedefler arasında boşluk; yıkıcı eylem ayrı ve onaylı | ekran görüntüsü | | ☐ |

### B4. Erişilebilirlik
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| EA-1 | Metin kontrastı ≥ 4.5:1 (büyük metin ≥ 3:1), WCAG 2.2 AA | renk çifti hesabı (token çiftleri) | **E** | ☐ |
| EA-2 | Girdi sınırları, düğme kenarlıkları, durum göstergeleri ≥ 3:1 (1.4.11) | renk çifti hesabı | | ☐ |
| EA-3 | `<html lang="tr">`; her girdinin görünür etiketi (yalnız yer tutucu değil) | kaynak taraması | **E** | ☐ |
| EA-4 | Odak görünür, klavye/ekran okuyucuyla ana görev yapılabilir | el (VoiceOver kısa deneme) | | ☐ |
| EA-5 | Sayfa yakınlaştırılabilir (`user-scalable=no` yok) | kaynak | | ☐ |

### B5. Performans ve çevrimdışı
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| PF-1 | Zayıf ağda (yavaş 3G ayarı) ilk içerik görünür ve düğme basılabilir | tarayıcı ağ kısıtlama | | ☐ |
| PF-2 | Ağ yokken okuma çalışır (önbellek); yazma kuyruğa alınır veya açıkça reddedilir | uçak modu denemesi (el) | **E** | ☐ |
| PF-3 | Dış yazı tipi/CDN bağımlılığı yok (sistem yazı tipi) | ağ isteği listesi | | ☐ |

### B6. Güvenlik ve gizlilik
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| GG-1 | Müşteri sayfasının ham API yanıtında telefon, adres, özel not, fiyat yok | yanıt gövdesi incelemesi | **E** | ☐ |
| GG-2 | Kullanıcı verisi `innerHTML`'e basılmaz (`textContent` / `escapeHTML`) | kod taraması | **E** | ☐ |
| GG-3 | Gizli anahtar istemci kodunda ve repoda yok; hata metni DB'den tarayıcıya aktarılmaz | grep + hata zorlama | **E** | ☐ |
| GG-4 | Müşteri sayfası: `noindex`, `no-referrer`, `no-store`; geçersiz link tek tip cevap | yanıt başlıkları | **E** | ☐ |

### B7. Türkçe ve yerelleştirme
| ID | Ölçüt | Nasıl ölçülür | E | Durum |
|---|---|---|---|---|
| TR-1 | Karakterler tam (ı ş ğ ö ç ü İ); `uppercase` dönüşümü `lang="tr"` ile doğru (i→İ) | ekran görüntüsü | | ☐ |
| TR-2 | Telefon ekranda `+90 5__ ___ __ __`, modelde `905XXXXXXXXX`; tutar TL, tarih gün.ay.yıl | çıktı örnekleri | | ☐ |
| TR-3 | Metinler Türkçe, kısa, dolgusuz; teknik kelime sahada kullanılan hâliyle | okuma | | ☐ |

## C. Dosya türüne göre varlık kontrolü (VAR / YOK)

| Tür | Olması gerekenler | Durum |
|---|---|---|
| HTML | `lang="tr"`, `viewport` (`viewport-fit=cover`), tek `<h1>`, etiketli form alanları, satır içi stil/betik yok (CSP kolaylığı, Orta) | ☐ |
| CSS | yalnız `tokens.css` değişkenleri, `@import` yok, `100dvh`, `prefers-reduced-motion` saygısı | ☐ |
| JS (tarayıcı) | ES modül, `escapeHTML`, tek `apiFetch`, hata durumları ekranda, çift gönderme koruması | ☐ |
| JS (sunucu) | her ucun ilk adımı yetki kontrolü, sabit hata mesajları, ham DB hatası dönmez, sır yalnız ortam değişkeninde | ☐ |
| SQL | ilk satır kimlik kapısı, RLS açık, `security definer` fonksiyonda `search_path`, geri alınabilir, Burak onayı | ☐ |
| Manifest / `sw.js` (sonra) | yalnız okuma önbelleği, sürüm numarası, çıkışta temizlik; iOS çerez ayrımı notu | ☐ |

## D. Kullanım
1. Code ekranı yazmadan önce **A** bölümünü doldurur; Burak estetik yönü (ES-6) onaylar.
2. Üretimden sonra denetçi (üreten değil) **B** ve **C**'yi işaretler; E satırları kapanmadan modül kapanmaz.
3. Her ekran tek sayfa rapor: işaretli satırlar + kanıt bağlantısı. Yeni rapor yığını yok.

Kaynak ve güven: WCAG 2.2 SC 1.4.3 (4.5:1), 1.4.11 (3:1), 2.5.8 (24×24 CSS px), W3C: **Yüksek**. Apple "hit targets ≥ 44×44 pt": developer.apple.com/design/tips: **Yüksek**. Diğer satırlar (başparmak bölgesi, kademe sayısı, `viewport-fit` kullanımı, 414 px): mühendislik uygulaması, **Orta**, ölçülmedi.
