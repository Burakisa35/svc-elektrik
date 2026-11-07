-- 0005_oturum_db.sql — Parola doğrulaması ve oturum veritabanında (Burak onayı 2026-11-07).
-- Açık (0003'te): DB yalnız sahip anahtarını doğruluyordu. Anahtar sızarsa svc_s_giris_baslat parola
-- özetini veriyor, svc_s_giris_basarili parolasız "giriş" sayıyordu.
-- Yeni model:
--   * PBKDF2-SHA256 600k sunucuda (Node) hesaplanır; DB yalnız sha256(türetilmiş anahtar) saklar ve
--     karşılaştırmayı KENDİSİ yapar (RFC 5802 StoredKey düzeni). DB özeti hiçbir çağrıda döndürmez.
--   * Başarılı girişte DB oturum token'ı üretir; yalnız sha256'sı svc_oturumlar'da durur.
--   * svc_sahip_dogrula = anahtar + geçerli oturum (başlık: x-bee-oturum). Diğer fonksiyonların imzası değişmez.
--   * Anahtar-yalnız fonksiyonlar: giriş (baslat/tamamla), kurulum (baslat/sifre_kur).
-- Veri etkisi: svc_giris 0 satır (canlıda ölçüldü 2026-11-07).
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

comment on column public.svc_giris.password_hash is
  'Doğrulayıcı: sha256(PBKDF2-SHA256(parola, salt, iterasyon)) hex. Türetilmiş anahtarın kendisi saklanmaz; hiçbir fonksiyon bu değeri döndürmez.';
comment on column public.svc_giris.oturum_surumu is 'KULLANILMIYOR (0005): oturumlar svc_oturumlar tablosunda.';

create table public.svc_oturumlar (
  id            uuid primary key default gen_random_uuid(),
  token_hash    text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  olusturma     timestamptz not null default now(),
  son_kullanim  timestamptz not null default now(),
  bitis         timestamptz not null,
  iptal_at      timestamptz,
  istemci       text check (char_length(istemci) <= 200)
);
alter table public.svc_oturumlar enable row level security;
revoke all on table public.svc_oturumlar from anon, authenticated;
comment on table public.svc_oturumlar is
  'Sahip oturumları. Token düz saklanmaz. Kayan süre 30 gün, mutlak tavan 90 gün (olusturma + 90 gün).';

-- ═══ Kapılar ═════════════════════════════════════════════════════════════════════════════
-- Yalnız anahtar (giriş ve kurulum için).
create function public.svc_anahtar_dogrula(p_sahip text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare beklenen text;
begin
  select deger into beklenen from svc_ayarlar where anahtar = 'sahip_hash';
  if beklenen is null or p_sahip is null
     or encode(sha256(convert_to(p_sahip, 'UTF8')), 'hex') <> beklenen then
    raise exception using errcode = '42501', message = 'BEE_SAHIP: yetkisiz çağrı';
  end if;
end $$;

-- Oturum: PostgREST istek başlığından okunur. Geçerliyse kayan süre uzar (en fazla saatte bir yazılır).
create function public.svc_oturum_dogrula() returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_token text := nullif(current_setting('request.headers', true), '')::json->>'x-bee-oturum';
  o svc_oturumlar;
begin
  if v_token is null or v_token !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '42501', message = 'BEE_OTURUM: oturum geçersiz';
  end if;
  select * into o from svc_oturumlar
   where token_hash = encode(sha256(convert_to(v_token, 'UTF8')), 'hex')
     and iptal_at is null and bitis > now();
  if not found then
    raise exception using errcode = '42501', message = 'BEE_OTURUM: oturum geçersiz';
  end if;
  if o.son_kullanim < now() - interval '1 hour' then
    update svc_oturumlar
       set son_kullanim = now(),
           bitis = least(now() + interval '30 days', olusturma + interval '90 days')
     where id = o.id;
  end if;
end $$;

-- Sahip kapısı artık anahtar + oturum. İmza aynı: bunu çağıran ~15 fonksiyon değişmeden korunur.
create or replace function public.svc_sahip_dogrula(p_sahip text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_anahtar_dogrula(p_sahip);
  perform svc_oturum_dogrula();
end $$;

-- ═══ Giriş ═══════════════════════════════════════════════════════════════════════════════
-- svc_s_giris_basarili ve svc_s_oturum_surumu 0006'da kaldırılır. O ana kadar ikisi de svc_sahip_dogrula'yı
-- çağırdığı için bu migration'dan itibaren geçerli oturum ister: parolasız giriş açığı burada kapanır.

-- Adım 1: yalnız salt ve iterasyon (gizli değil). Özet DÖNMEZ, sayaç burada artmaz.
create or replace function public.svc_s_giris_baslat(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare g svc_giris;
begin
  perform svc_anahtar_dogrula(p_sahip);
  select * into g from svc_giris where id = 1;
  if not found then return jsonb_build_object('kurulu', false); end if;
  if g.kilit_bitis is not null and g.kilit_bitis > now() then
    return jsonb_build_object('kurulu', true, 'kilitli', true, 'kilit_bitis', g.kilit_bitis);
  end if;
  return jsonb_build_object('kurulu', true, 'kilitli', false, 'salt', g.salt, 'iterasyon', g.iterasyon);
end $$;

-- Adım 2: sunucunun türettiği anahtarı DB doğrular. Sayaç, kilit ve oturum üretimi tek transaction'da.
create function public.svc_s_giris_tamamla(p_sahip text, p_turetilmis text, p_istemci text default null)
returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare g svc_giris; v_tur int; v_token text; v_bitis timestamptz;
begin
  perform svc_anahtar_dogrula(p_sahip);
  select * into g from svc_giris where id = 1 for update;
  if not found then return jsonb_build_object('ok', false, 'neden', 'kurulum_yok'); end if;
  if g.kilit_bitis is not null and g.kilit_bitis > now() then
    return jsonb_build_object('ok', false, 'neden', 'kilitli', 'kilit_bitis', g.kilit_bitis);
  end if;

  if p_turetilmis ~ '^[0-9a-f]{64}$'
     and encode(sha256(decode(p_turetilmis, 'hex')), 'hex') = g.password_hash then
    update svc_giris set hata_sayisi = 0, kilit_sayisi = 0, kilit_bitis = null, updated_at = now() where id = 1;
    delete from svc_oturumlar where bitis < now() - interval '30 days';
    v_token := encode(extensions.gen_random_bytes(32), 'hex');
    v_bitis := now() + interval '30 days';
    insert into svc_oturumlar (token_hash, bitis, istemci)
    values (encode(sha256(convert_to(v_token, 'UTF8')), 'hex'), v_bitis, left(p_istemci, 200));
    -- Düz token yalnız BU cevapta döner; sunucu httpOnly çereze koyar.
    return jsonb_build_object('ok', true, 'oturum', v_token, 'bitis', v_bitis);
  end if;

  -- Hatalı: 5. hatada kilit (15 dk'dan başlar, her turda katlanır, en fazla 24 saat).
  if g.hata_sayisi + 1 >= 5 then
    v_tur := g.kilit_sayisi + 1;
    v_bitis := now() + least(interval '15 minutes' * power(2, v_tur - 1), interval '24 hours');
    update svc_giris set hata_sayisi = 0, kilit_sayisi = v_tur, kilit_bitis = v_bitis, updated_at = now() where id = 1;
    return jsonb_build_object('ok', false, 'neden', 'kilitlendi', 'kilit_bitis', v_bitis);
  end if;
  update svc_giris set hata_sayisi = g.hata_sayisi + 1, updated_at = now() where id = 1;
  return jsonb_build_object('ok', false, 'neden', 'hatali');
end $$;

-- Çıkış: bu isteğin oturumunu iptal eder (anahtar + geçerli oturum gerekir).
create or replace function public.svc_s_cikis(p_sahip text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_token text := nullif(current_setting('request.headers', true), '')::json->>'x-bee-oturum';
begin
  perform svc_sahip_dogrula(p_sahip);
  update svc_oturumlar set iptal_at = now()
   where token_hash = encode(sha256(convert_to(v_token, 'UTF8')), 'hex') and iptal_at is null;
end $$;

-- ═══ Kurulum: anahtar-yalnız kalmalı (henüz oturum yok) ═══════════════════════════════════
create or replace function public.svc_s_kurulum_baslat(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_hata int; v_tur int; v_kilit timestamptz;
begin
  perform svc_anahtar_dogrula(p_sahip);
  if exists (select 1 from svc_giris where id = 1) then return jsonb_build_object('kurulu', true); end if;
  perform pg_advisory_xact_lock(hashtext('svc_kurulum'));
  select nullif(deger, '')::timestamptz into v_kilit from svc_ayarlar where anahtar = 'kurulum_kilit';
  if v_kilit is not null and v_kilit > now() then
    return jsonb_build_object('kurulu', false, 'kilitli', true, 'kilit_bitis', v_kilit);
  end if;
  select coalesce((select deger::int from svc_ayarlar where anahtar = 'kurulum_hata'), 0) into v_hata;
  if v_hata >= 5 then
    select coalesce((select deger::int from svc_ayarlar where anahtar = 'kurulum_kilit_turu'), 0) + 1 into v_tur;
    v_kilit := now() + least(interval '1 hour' * power(2, v_tur - 1), interval '24 hours');
    insert into svc_ayarlar (anahtar, deger) values ('kurulum_hata', '0'), ('kurulum_kilit_turu', v_tur::text),
                                                    ('kurulum_kilit', v_kilit::text)
    on conflict (anahtar) do update set deger = excluded.deger;
    return jsonb_build_object('kurulu', false, 'kilitli', true, 'kilit_bitis', v_kilit);
  end if;
  insert into svc_ayarlar (anahtar, deger) values ('kurulum_hata', (v_hata + 1)::text)
  on conflict (anahtar) do update set deger = excluded.deger;
  return jsonb_build_object('kurulu', false, 'kilitli', false);
end $$;

-- p_hash = sha256(PBKDF2 türetilmiş anahtar). Yalnız henüz parola yokken, bir kez.
create or replace function public.svc_s_sifre_kur(p_sahip text, p_hash text, p_salt text, p_iterasyon int)
returns boolean
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_kuruldu boolean;
begin
  perform svc_anahtar_dogrula(p_sahip);
  if p_hash !~ '^[0-9a-f]{64}$' or p_salt !~ '^[0-9a-f]{32,}$' then raise exception 'BEE_GECERSIZ: özet/salt'; end if;
  insert into svc_giris (id, password_hash, salt, iterasyon) values (1, p_hash, p_salt, p_iterasyon)
  on conflict (id) do nothing;
  v_kuruldu := found;
  if v_kuruldu then delete from svc_ayarlar where anahtar in ('kurulum_hata', 'kurulum_kilit', 'kurulum_kilit_turu'); end if;
  return v_kuruldu;
end $$;

-- ═══ Yetkiler ════════════════════════════════════════════════════════════════════════════
revoke all on function public.svc_anahtar_dogrula(text) from public, anon, authenticated;
revoke all on function public.svc_oturum_dogrula()      from public, anon, authenticated;
grant execute on function public.svc_s_giris_tamamla(text, text, text) to anon;
