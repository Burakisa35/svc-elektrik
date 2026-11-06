-- 0003_giris_pbkdf2.sql — Sahip parolası: PBKDF2-SHA256 600.000 iterasyon, sunucuda (Node) hesaplanır.
-- Burak kuralı (2026-11-06): bcrypt değil PBKDF2; satır-başı rastgele salt; timingSafeEqual.
-- Postgres PBKDF2 hesaplayamaz, bu yüzden doğrulama sunucuda yapılır. Deneme sayacı ise
-- doğrulamadan ÖNCE ve atomik olarak artar; eşzamanlı denemeler kilidi aşamaz.
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

drop function if exists public.svc_s_giris(text, text);
drop function if exists public.svc_kurulum(text, boolean);

alter table public.svc_giris add column if not exists iterasyon int not null default 600000 check (iterasyon >= 600000);
-- Çıkış = sürüm +1 → o ana kadar verilmiş TÜM oturum token'ları geçersiz (JWT tek başına geri alınamaz).
alter table public.svc_giris add column if not exists oturum_surumu int not null default 1;
comment on column public.svc_giris.password_hash is 'PBKDF2-SHA256 (hex). salt = satır-başı rastgele (hex). Doğrulama sunucuda, timingSafeEqual.';

-- Kurulum: yalnız sunucu sırlarını üretir (SQL Editor / postgres). Parolayı sahip ilk girişte belirler.
create function public.svc_kurulum(p_yenile boolean default false)
returns table (kapi_anahtari text, sahip_anahtari text)
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_kapi text; v_sahip text;
begin
  if exists (select 1 from svc_ayarlar where anahtar = 'sahip_hash') and not p_yenile then
    raise exception 'BEE_KURULUM: kurulum zaten yapılmış. Yenilemek için p_yenile => true';
  end if;
  v_kapi  := encode(extensions.gen_random_bytes(32), 'hex');
  v_sahip := encode(extensions.gen_random_bytes(32), 'hex');
  insert into svc_ayarlar (anahtar, deger) values
    ('kapi_hash',  encode(sha256(convert_to(v_kapi,  'UTF8')), 'hex')),
    ('sahip_hash', encode(sha256(convert_to(v_sahip, 'UTF8')), 'hex'))
  on conflict (anahtar) do update set deger = excluded.deger;
  return query select v_kapi, v_sahip;
end $$;
revoke all on function public.svc_kurulum(boolean) from public, anon, authenticated, service_role;

-- İlk parola: yalnız henüz parola yoksa yazılabilir (bir kez).
create function public.svc_s_sifre_kur(p_sahip text, p_hash text, p_salt text, p_iterasyon int)
returns boolean
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  if p_hash !~ '^[0-9a-f]{64}$' or p_salt !~ '^[0-9a-f]{32,}$' then raise exception 'BEE_GECERSIZ: özet/salt'; end if;
  insert into svc_giris (id, password_hash, salt, iterasyon) values (1, p_hash, p_salt, p_iterasyon)
  on conflict (id) do nothing;
  return found;
end $$;

-- Deneme başlat: kilitliyse reddeder; değilse sayacı ÖNCE artırır, sonra özet+salt'ı verir.
create function public.svc_s_giris_baslat(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare g svc_giris; v_tur int; v_bitis timestamptz;
begin
  perform svc_sahip_dogrula(p_sahip);
  select * into g from svc_giris where id = 1 for update;
  if not found then return jsonb_build_object('kurulu', false); end if;
  if g.kilit_bitis is not null and g.kilit_bitis > now() then
    return jsonb_build_object('kurulu', true, 'kilitli', true, 'kilit_bitis', g.kilit_bitis);
  end if;
  if g.hata_sayisi >= 5 then
    v_tur := g.kilit_sayisi + 1;
    v_bitis := now() + least(interval '15 minutes' * power(2, v_tur - 1), interval '24 hours');
    update svc_giris set hata_sayisi = 0, kilit_sayisi = v_tur, kilit_bitis = v_bitis, updated_at = now() where id = 1;
    return jsonb_build_object('kurulu', true, 'kilitli', true, 'kilit_bitis', v_bitis);
  end if;
  update svc_giris set hata_sayisi = hata_sayisi + 1, updated_at = now() where id = 1;
  return jsonb_build_object('kurulu', true, 'kilitli', false,
                            'hash', g.password_hash, 'salt', g.salt, 'iterasyon', g.iterasyon);
end $$;

create function public.svc_s_giris_basarili(p_sahip text) returns int
language plpgsql security definer set search_path = public, pg_temp as $$
declare v int;
begin
  perform svc_sahip_dogrula(p_sahip);
  update svc_giris set hata_sayisi = 0, kilit_sayisi = 0, kilit_bitis = null, updated_at = now()
   where id = 1 returning oturum_surumu into v;
  return v;
end $$;

-- Her sahip isteğinde: token'daki sürüm hâlâ geçerli mi?
create function public.svc_s_oturum_surumu(p_sahip text) returns int
language plpgsql security definer set search_path = public, pg_temp as $$
declare v int;
begin
  perform svc_sahip_dogrula(p_sahip);
  select oturum_surumu into v from svc_giris where id = 1;
  return v;
end $$;

create function public.svc_s_cikis(p_sahip text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  update svc_giris set oturum_surumu = oturum_surumu + 1, updated_at = now() where id = 1;
end $$;

grant execute on function public.svc_s_sifre_kur(text, text, text, int) to anon;
grant execute on function public.svc_s_giris_baslat(text)              to anon;
grant execute on function public.svc_s_giris_basarili(text)            to anon;
grant execute on function public.svc_s_oturum_surumu(text)             to anon;
grant execute on function public.svc_s_cikis(text)                     to anon;
