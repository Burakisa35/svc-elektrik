GEÇMEDİ (kısmen)

# 004 — Code'un brief 004 teslimi: bağımsız inceleme

Tarih: 2026-11-07 · İnceleyen: sohbet Claude'u (dosyaları üretmeyen taraf, salt okuma) · Kapsam: `origin/claude/jolly-allen-7gfz46` @ `7efd02d`, Code'un raporu · Kod ve migration'a yazılmadı.
Yöntem: dosyalar `git show` ile okundu; hook (`koruma.py`) kendi JSON girdisiyle çalıştırıldı (Yüksek: bu oturumda ölçüldü).

## Özet
Teslim iyi ve dürüst yazılmış, ama "bitti" iddiası iki maddede kanıtın önüne geçmiş, hook iki yönde hatalı ve en büyük sorun benim brief'imden geliyor.

## Hak edilen güçlü yönler
| # | Ne | Kanıt |
|---|---|---|
| G1 | Bilmediğini "Doğrulanmadı" bıraktı (Vercel bağlı repo/plan/deploy) | `src/CLAUDE.md` durum tablosu |
| G2 | Kendi sınırını yazdı (betikle yazma yakalanmaz, hook canlıda çalışmadı) | rapor, `koruma.py` başlık yorumu |
| G3 | Hook'u bozarak sınadı (Bash dalı kapatılınca 13 vaka kırmızı) | rapor; bu kendi başına bir mutasyon yaklaşımıdır |
| G4 | Alt dizin CLAUDE.md'leri kısa ve koddan çıkarılamayan içerik (31/32 satır) | `src/CLAUDE.md`, `supabase/CLAUDE.md` |
| G5 | Migration'ları MD5 ile canlıyla karşılaştırdı, "sicilde var ≠ eser var" tuzağını yazdı | `supabase/CLAUDE.md` |

## Bulgular

| # | Önem | Bulgu | Kanıt | Sorumlu |
|---|---|---|---|---|
| B1 | **Engelleyici** | **Hook ve izinler `docs/**`'ın tamamını kapatıyor; Code'un kendi teknik belgeleri (`docs/VERI_MODELI.md`, `docs/ROADMAP.md`) artık güncellenemiyor.** Kaynak: brief 004 ve kök kuralın `docs/**` demesi. Kuralın kendisi fazla geniş | `settings.json` deny `docs/**`; rapor "kilitli" | **Sohbet Claude'u (benim hatam)** |
| B2 | Yüksek | **Hook yanlış pozitif veriyor: salt okuma komutlarını engelliyor.** `node ... knowledge/` (planlanan linter/importer) ve `grep ... docs/ > /tmp/o` ve `git show HEAD:docs/x > /tmp/r` kod 2 döndü. Sebep: korunan yol + herhangi bir yorumlayıcı adı veya `>` | `koruma.py` `YAZMA` ifadesi; bu oturumdaki çalıştırma | Code |
| B3 | Yüksek | **Hook kaçak veriyor:** `curl -o knowledge/x`, `wget -O docs/x`, `echo x > kn*/y` ve `'know'+'ledge'` birleştirmesi kod 0 döndü | aynı çalıştırma | Code (sınır kabul edilebilir, ama CI ile kapatılmalı) |
| B4 | Yüksek | **"Bitti" iddiası kanıtın önünde:** rapor "1–5 ve 7. madde bitti" diyor; ama 5 (hook'un telefon/bulut oturumunda çalıştığının kanıtı) yapılmadı, 3 ("PR ile") yapılmadı | rapor satır 51, 57 | Code |
| B5 | Yüksek | **Kök `CLAUDE.md` bağlayıcı metinde doğrulanmamış iddia, etiketsiz:** "hook ... engeller" yazıyor; canlıda engellemediği ölçülmüş. Kök kural: her teknik iddia etiket taşır | `CLAUDE.md` Komutlar bölümü | Code |
| B6 | Orta | **Test canlı veritabanında koşuyor.** Test geri alınıyor ama sıra numaraları geri alınmıyor (rapor: ilk gerçek talep T26-0010). Gerçek veri girince canlıda test koşmak riskli. Çıkarım rapordan: Orta | `supabase/CLAUDE.md` tuzaklar | Code |
| B7 | Orta | **0004 `drop function` içeriyor** (bu yüzden onay penceresi çıkıyor). Veri etkisi "0 satır" beyanına dayanıyor; bu beyan uygulama anında yeniden ölçülmeli. 0004'ün tamamını okumadım (yalnız ilk 60 satır ve komut taraması): **tam inceleme yapılmadı** | `0004_modul1_saha.sql` | Code / Burak |
| B8 | Düşük | Rapor uzun ve süreç anlatımı ağır; Burak'ın tercihi çalışan çıktı | rapor | Code |

## Karar bekleyen
1. `docs/**` kilidinin kapsamı (B1) ve Code'un teknik belgelerinin yeri
2. `.claude/**` sahibi
3. `0004` uygulama yolu
