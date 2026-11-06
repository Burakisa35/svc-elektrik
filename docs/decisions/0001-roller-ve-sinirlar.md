# 0001 — Roller ve sınırlar

Tarih: 2026-11-07 · Durum: kabul (taslak, Burak onayı bekliyor)

**Karar:** `knowledge/` ve `docs/` sohbet Claude'unun; `src/` ve `supabase/` Claude Code'un alanıdır. Brief'ler dosya olarak repoda durur, Burak taşır.

**Neden:** İçerik doğruluğu (araştırma, güven etiketi) ile uygulama doğruluğu (kod, şema) farklı denetim ister; aynı dosyada iki yazar çakışma ve sessiz bozulma üretir.

**Sonuç:** Code içerikte hata bulursa düzeltmez, brief notu düşer. Sohbet Claude'u şema/kod ihtiyacını brief ile ister.
