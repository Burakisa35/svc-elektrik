# 0004 — Giriş sistemi kararları

Çerçeve: `docs/briefs/010-ilk-giris-tartisma-cercevesi.md`. Karar sahibi: Burak. Satır = tek karar; çürütücü gerçekleşirse yeniden açılır.

| Düğüm | Karar | Tarih | Neden (1 cümle) | Tetikleyici / yeniden aç | Code görüşü |
|---|---|---|---|---|---|
| N6 İlk kurulum | **B:** `svc_kurulum()` yalnız SQL Editor'den Burak çalıştırır; ilk parola orada verilir, hiçbir yerde (ortam değişkeni dahil) saklanmaz | 2026-11-07 | Parola ortamda kalmaz, kurulum yetkisi veritabanı sahibinde | Kurulum ikinci kez çalışıp mevcut satırı ezerse yeniden aç | bekliyor |
| N3, N1, N2, N5, N4, N8, N9, N7, N10 | açık | | | | |
