# Kapı kontrol listeleri

## G0 — İskelet
- [ ] `CLAUDE.md` rol tablosu ile `knowledge/CLAUDE.md` çelişmiyor
- [ ] `_SPEC.md` ile üç şablon aynı alan adlarını kullanıyor
- [ ] Her dizinin README'si var; sahibi belli

## G1 — Bilgi dosyası
- [ ] Front matter eksiksiz, `id` dosya adıyla aynı
- [ ] Her iddia satır sonunda etiketli (Yüksek / Orta / Doğrulanmadı)
- [ ] Kaynak URL'leri `sources/` kaydına bağlı; uzun alıntı yok
- [ ] Uç satırlarında işlev + sinyal + akım yolu + arıza davranışı + kanıt dolu; boşsa "tamamlanmadı"
- [ ] Kablo renginden işlev çıkarılmamış; başka marka şeması "analoji" olarak işaretli
- [ ] Rakip hipotezler numaralı ve eleyici kanıt yazılı

## G2 — Şartname
- [ ] Her tablo ve alan, bilgi tabanı front matter'ına eşleniyor
- [ ] Her özellik için "Burak sahada şunu yapabilmeli" cümlesi var ve denenebilir
- [ ] Kapsam dışı açıkça listeli

## G3 — Code PR
- [ ] `knowledge/`, `docs/` değişmemiş (veya brief ile onaylı)
- [ ] Migration dosyası geri alınabilir, uygulanmadan önce Burak onayı
- [ ] 390 px genişlikte tek elle kullanılabilir; dokunma hedefleri yeterli
- [ ] Çevrimdışı/zayıf internette bilgi okunabiliyor
- [ ] Gizli anahtar repoda yok
- [ ] Ekran içeren PR: `ekran-sablonu.md` B ve C bölümleri işaretli; **E** satırlarının hepsi VAR (kanıtlı)

## G4 — Saha
- [ ] Gerçek bir arızada akış baştan sona denendi
- [ ] Sonuç `fault_case` kaydına işlendi
