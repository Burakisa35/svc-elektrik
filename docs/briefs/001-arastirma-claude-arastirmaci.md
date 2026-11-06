# Brief 001 — Küresel diafon/zil/interkom araştırması

Yazan: Rol 1 (brief yazarı) · Uygulayan: Rol 2 (araştırmacı) · Denetçi: ayrı oturum (G1) · Karar: Burak
Tarih: 2026-11-07 · Mod: derin · Durum: taslak

## 1. Amaç

BEE bilgi tabanını besleyecek, **sahada karar verdiren** bilgi: bir diafon/zil sisteminde hangi uç ne yapar, kablo neyi taşır, hangi belirti hangi arızaya işaret eder, hangi testle hangi hipotez elenir. Genel "nasıl çalışır" anlatısı değil, test edilebilir bilgi.

## 2. Başarı ölçütü

Her uç için beş alan dolu olmalı: **işlev + elektriksel sinyal + akım yolu + arıza davranışı + kanıt**. Biri bilinmiyorsa uç "tamamlanmadı" kalır ve neden bilinmediği yazılır. Her arıza vakası için: belirti, ayırt edici soru, sıralı olası nedenler, her adımın **neyi elediği**.

## 3. Soru ağacı (bu sırayla)

**S1 — Canlı arıza (öncelik):** Panelden bir daireye basılınca başka dairelerin zili de çalıyor; daire kapı butonundan çalmıyor; arıza hatta bağlı, şubeye değil.
- S1.1 Zil çağrı devresi topolojisi (ortak dönüş, daire başına dönüş teli, tek yönlü yarı iletken yolu).
- S1.2 Çapraz çalma mekanizmaları: metalik kaçak, kapasitif/indüktif kuplaj, ortak iletkene sızıntı, yarı iletken geri yol.
- S1.3 Dünyadaki aynı belirtili vakalar ve kök nedenleri (hangi test neyi çözdü).

**S2 — Netelsan sesli diafon (Tier-1):** santral/şube uçları 1–8, ZİL/K.ZİL, kapı açıcı rölesi; 2/3/5'in işlevi. Şube kart şeması bulunabiliyor mu?

**S3 — Audio ve Simge (Tier-1):** aynı soru seti, DT8 kablosu, kapıcılı/kapıcısız varyantlar.

**S4 — Küresel aileler (Tier-2):** 4+n (Fermax/Golmar/Tegui), 1+n (Siedle/Elvox benzeri), 2 telli BUS, 3-4-5 telli Alpha/Bell System, Cyfral/ACO tipi, IP/SIP. Her aile için: iletken sayısı/rolü, topoloji, tipik mesafe sınırı, tipik arızalar.

**S5 — Kurulum mantığı:** kablo tipi/kesiti, buat/şaft kuralları, gerilim türleri (DC/AC/ses), ekranlı çift, topraklama; hangi hata hangi belirtiyi üretir.

## 4. Kaynak hiyerarşisi (üstten aşağı güven)

1. Üretici doküman/şema/kılavuz (PDF, montaj şeması, servis notu) — **Yüksek** olabilir
2. Bileşen düzeyinde devre analizi / teardown (şematik, ölçümlü)
3. Teknik forum, yetkili servis blogu, kullanıcı vakaları (çoklu bağımsız teyit → Orta)
4. Tek kaynaklı iddia, satıcı SEO yazısı — en fazla **Doğrulanmadı**; renk tablosu veren SEO sayfaları tek başına işlev kanıtı sayılmaz

Bilinen güvenilmez: Netelsan blogundaki DT8 renk tablosu (ses-yalnız sistemde görüntülü terimler). Kullanma.

## 5. Yöntem kuralları

- Kablo renginden işlev çıkarma; ucu devreye kadar izleyen kanıt ara.
- Başka marka şemasını Netelsan'a uyarlama; yalnız elektriksel prensip karşılaştırması ve "analoji" etiketiyle yaz.
- Kablo sökülünce arıza kesildi = kanıt değil; **hangi akım yolu kesildi** sorusunu yanıtla.
- Rakip hipotezleri numarala (H1, H2…); her kanıtın hangisini elediğini yaz.
- Çok dilli ara: TR, EN, DE, PL, RU, ES, IT (anahtar kelimeler `knowledge/sources/` içine arama günlüğü olarak yazılır).
- Aynı iddia için en az iki bağımsız kaynak yoksa etiket Orta'yı geçmez.
- Tahminle doldurma. Bulunamadıysa "Doğrulanmadı" yaz ve ne aradığını/nerede baktığını not et.

## 6. Durma kuralı (kapsam kayması engeli)

- Tier-1 (S1–S3) bitmeden Tier-2'ye geçilmez.
- Bir soru için art arda 3 aramada yeni bilgi çıkmıyorsa dur, "bulunamadı" kaydet.
- Konu dağılırsa (örn. görüntülü sistemler, IP) kapsam dışı listesine ekle, devam etme.

## 7. Kapsam dışı

Görüntülü diafon (yalnız ses-yalnız sistemle karşılaştırma için gerekirse), kamera/CCTV, kapı kilidi mekaniği, ticari ürün karşılaştırması.

## 8. Teslim biçimi

`knowledge/` içinde `_SPEC.md` formatında: `brands/*.md`, `fault-cases/*.md`, `families/*.md`, `sources/*.md`. Arama günlüğü: `knowledge/sources/arama-gunlugu.md`. Fiyat/satış bilgisi yok.

## 9. Kabul ölçütü ("Burak sahada şunu yapabilmeli")

- Çapraz çalma arızasında, elinde yalnız multimetre ile, sıralı test listesinden hangi iletken/uç ilişkisini ölçeceğini ve beklenen değeri görebilmeli.
- Netelsan uç tablosunda hangi satırın "kanıtlı", hangisinin "Doğrulanmadı" olduğunu tek bakışta ayırt edebilmeli.
- Her teşhis adımı hangi hipotezi elediğini söylemeli.

## 10. Denetim

G1 (`docs/quality/gates.md`) ayrı oturumda uygulanır. Engelleyici bulgu açıkken Tier-2'ye geçilmez.
