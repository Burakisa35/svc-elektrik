-- Yerel PostgreSQL'i Supabase'e benzetir: roller, extensions şeması, pgcrypto ve Supabase'in public şemasındaki
-- VARSAYILAN geniş yetkileri (migration'lar bunları geri almak zorunda; taklit etmezsek test yanlış yeşil verir).
-- Kanıt değeri: sıfırdan kurulum ve fonksiyon mantığı. Supabase'e özgü katman (PostgREST, gateway) burada YOK.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
grant anon, authenticated, service_role to postgres;
create schema extensions;
create extension pgcrypto with schema extensions;
grant usage on schema public, extensions to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables    to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
