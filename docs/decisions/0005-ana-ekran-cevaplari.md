# 0005 — Ana ekran keşfi: Burak'ın cevapları

Çerçeve: `docs/briefs/011-ana-ekran-kesif-soru-cevap.md`. Cevap = girdi (beyan, güven **Orta**); ölçümle çelişirse ölçüm kazanır.

| Soru | Cevap (Burak) | Burak'ın fikri | Tarih | Tasarım kuralı | Şablon alanı |
|---|---|---|---|---|---|
| ANA-1 | "İlk ne yapmak istediğim gibi bir şey yok, çoklu seçenek olması gerekiyor" | (cevabın kendisi fikirdir) | 2026-11-07 | Ana ekran **yönlendirme ekranıdır**: tek baskın eylem yok; eşit ağırlıklı en çok 4 giriş (Yeni iş · Bugün · Ara · Ödemeler). Sıra ve konum ANA-2/4/7 cevaplarından. ES-3 yönlendirme ekranı için güncellendi | A: tek birincil eylem (eylem ekranları için kalır); ES-3 |
| ANA-2 | Telefonla arıyorlar · Tavsiye / yüz yüze (Formdan ve platformdan **seçilmedi**) | | 2026-11-07 | İş, **anında ve elle** açılır (arama sırasında ya da yüz yüze). Herkese açık talep formu ve platform entegrasyonu **ertelenir** (YAGNI); `talep_kanali` = telefon · tavsiye/yüz yüze · diğer. İş aç ekranı konuşurken **tek elle, en az yazıyla** çalışmalı (hipotez, ANA-3 ve ANA-7 ile sınanır) | A: veri kaynağı; UX-2 |
