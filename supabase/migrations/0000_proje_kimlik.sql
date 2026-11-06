-- 0000_proje_kimlik.sql — BEE veritabanı kimliği ve migration kimlik kapısı.
-- Neden: aynı hesapta iki Supabase projesi var (TEHAİ `ofgenhpryssfznslxdkp`, BEE
-- `uwmbtaxxdcjumxbnigpy`). Bir BEE migration'ı TEHAİ'de çalışırsa iki işin verisi karışır.
-- Sonraki her migration'ın İLK satırı:  select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');
-- Yanlış veritabanında raise eder → örtük transaction abort → dosyanın geri kalanı uygulanmaz.

-- Ekim kapısı: kimlik zaten varsa doğru olmalı; yoksa public şeması boş olmalı (yeni proje).
-- TEHAİ'de public dolu olduğu için bu dosya orada ilk satırda ölür.
do $$
begin
  if to_regclass('public.svc_proje_kimlik') is not null then
    if not exists (select 1 from public.svc_proje_kimlik where ref = 'uwmbtaxxdcjumxbnigpy') then
      raise exception 'BEE KİMLİK: svc_proje_kimlik var ama ref farklı — yanlış veritabanı.';
    end if;
  elsif exists (select 1 from information_schema.tables where table_schema = 'public') then
    raise exception using
      message = 'BEE KİMLİK EKİMİ REDDEDİLDİ: public şeması boş değil.',
      hint    = 'Bu dosya yalnız burak-elektrik projesinde (uwmbtaxxdcjumxbnigpy) ilk kez çalışır.';
  end if;
end $$;

create table if not exists public.svc_proje_kimlik (
  ref        text primary key,
  ad         text not null,
  kurulum_at timestamptz not null default now()
);
create unique index if not exists uq_svc_proje_kimlik_tek on public.svc_proje_kimlik ((true));
alter table public.svc_proje_kimlik enable row level security;

insert into public.svc_proje_kimlik (ref, ad)
values ('uwmbtaxxdcjumxbnigpy', 'burak-elektrik (BEE)')
on conflict (ref) do nothing;

create or replace function public.svc_kimlik_dogrula(beklenen text)
returns void
language plpgsql
set search_path = public, pg_temp
as $$
declare bulunan text;
begin
  select ref into bulunan from public.svc_proje_kimlik limit 1;
  if bulunan is distinct from beklenen then
    raise exception 'BEE KİMLİK KAPISI: bağlı veritabanı "%", beklenen "%". Migration UYGULANMADI.',
      coalesce(bulunan, 'yok'), beklenen;
  end if;
end $$;

revoke all on table public.svc_proje_kimlik from anon, authenticated;
revoke all on function public.svc_kimlik_dogrula(text) from public, anon, authenticated;
