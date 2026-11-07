-- 0007_saglik.sql — Başlık yoklaması ve sağlık ucu (AKTIF.md dilim 1, adım 1; araclar/teshis/DENETIM-2026-11-07.md D8).
-- Soru: Supabase gateway'i istemcinin gönderdiği x-bee-oturum başlığını PostgREST'e, oradan request.headers'a geçiriyor mu?
-- 0005'in bütün oturum modeli buna dayanıyor ve bu ölçülmedi.
-- Fonksiyon başlığın DEĞERİNİ döndürmez; yalnız "geldi mi ve biçimi doğru mu". Tablo okumaz, yazmaz; anahtar istemez (gizli bilgi yok).
-- Kalıcıdır: her deploy'dan sonra duman testi. Beklenen: başlıkla {"db":true,"baslik":true}, başlıksız {"db":true,"baslik":false}.
-- 0006 (temizlik) canlıda yok (mobilde Run yok); bu dosya ondan bağımsızdır, sırası önemli değil.
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

create function public.svc_saglik() returns jsonb
language sql stable security invoker set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'db', true,
    'baslik', coalesce(nullif(current_setting('request.headers', true), '')::json->>'x-bee-oturum', '') ~ '^[0-9a-f]{64}$');
$$;
comment on function public.svc_saglik() is
  'Duman testi: gateway x-bee-oturum başlığını geçiriyor mu. Değeri döndürmez. Anon çalıştırır (gizli bilgi yok).';
grant execute on function public.svc_saglik() to anon;
