---
title: Bildiğin dosya türleriyle en verimli üretim — fikirler
retrieved: 2026-11-07
---

# Fikirler (envanter: `dosya-turleri-envanteri.md`)

Kısıtlar: yalnız iPhone, tek kişi, sahada zayıf internet, build adımı yok, public repo. Güven: hepsi **Orta (öneri, ölçülmedi)** sürece belirtilmedikçe. Etki/çaba kendi tahminimdir.

| Sıra | Fikir | Kullanılan türler | Etki | Çaba | Not |
|---|---|---|---|---|---|
| 1 | **Bilgi tabanı linter'ı**: her uçta beş alan, güven etiketi, kaynak URL var mı kontrol eder | `.mjs`, `.md`, GitHub Actions `.yml` | Yüksek | Düşük | "Tamamlanmadı" kayıtları otomatik listelenir; yalnız değişen dosyada mutasyon kontrolü uygulanabilir |
| 2 | **md → JSON importer** (uç/arıza kayıtları Supabase'e) | `.mjs`, `.md`, `.sql` | Yüksek | Orta | Code'un işi; içeriği veri say (XSS) |
| 3 | **Çevrimdışı okuma**: bilgi tabanı JSON'u servis çalışanıyla önbelleğe | `manifest.json`, `sw.js`, JSON | Yüksek | Orta | Sahada internet zayıf; okuma çevrimdışı çalışmalı (CLAUDE.md) |
| 4 | **Çözüm süresi analizi**: görünüm (view) + özet | `.sql`, JSON/CSV | Orta | Orta | Brief 002; n<5 ise "yetersiz veri" |
| 5 | **Uç diyagramı üretimi**: uç tablosundan SVG çizer | `.mjs`, `.svg`, `.md` | Orta | Orta | Şema görseli repoya konmaz kuralı: bu kendi çizimimiz, üretici şeması değil |
| 6 | **Saha fotoğrafı istemcide sıkıştırma** (webp) | JS, `.webp` | Orta | Düşük | Free Storage 1 GB sınırı için |
| 7 | **PDF/Excel/CSV çıktı**: servis raporu, müşteri özeti | jsPDF, CSV | Orta | Orta | Müşteri verisi varsayılan gizli |
| 8 | **Koruma hook'u** (`.sh`) | `.sh`, `.json` | Yüksek | Düşük | Brief 004 iş 4 |
| 9 | **Skills**: bilgi-kaydı ekleme, çözüm kaydı | `.md` (SKILL.md) | Orta | Düşük | `mutasyon-ve-skills.md` |
| 10 | Yedek alma: zamanlanmış `db dump` (public repo dışında saklanır) | `.yml`, `.sh` | Yüksek | Orta | Free'de yedek yok; dump repoya girmez |

## Kaçınılacak
tehai tarzı şişme: 359 satırlık CLAUDE.md, 159 test, 513 md envanterden gözlemdi; literatür bu yönde bir kazanç göstermiyor (Orta). Burak'ın tercihi de çalışan çıktı, test yığını değil.

## Burak'a doğrulama sorusu
Hangi türleri kendi elinle düzenleyebiliyorsun? Cevap bu sıralamayı değiştirir (envanterde de sorulmuştu).
