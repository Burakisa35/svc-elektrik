-- 0001_operasyon_cekirdegi.sql — BEE 1. aşama: talep · müşteri · adres · iş · paylaşım · görev · not.
-- Tasarım ve gerekçeler: docs/VERI_MODELI.md. Erişim testleri: tests/db-erisim.sql.
-- 2. aşama (ölçüm · malzeme · finans) BU DOSYADA YOK.
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

-- ═══ 0. Varsayılan yetkiler ══════════════════════════════════════════════════
-- Supabase, public şemasında yeni tabloları anon/authenticated'a otomatik açar.
-- Bundan sonra (2. aşama dahil) bu migration'ı çalıştıran rolün açtığı nesneler kapalı doğar.
alter default privileges in schema public revoke all on tables    from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public revoke all on functions from public, anon, authenticated;
-- Fonksiyonlarda PUBLIC EXECUTE küresel varsayılandır; IN SCHEMA'lı revoke onu KALDIRMAZ (Postgres kuralı).
alter default privileges revoke execute on functions from public;

-- ═══ 1. Ayarlar ve sahip girişi ═══════════════════════════════════════════════
create table public.svc_ayarlar (
  anahtar    text primary key check (anahtar ~ '^[a-z_]{2,40}$'),
  deger      text not null,
  updated_at timestamptz not null default now()
);
comment on table public.svc_ayarlar is
  'Sunucu ayarları. kapi_hash = herkese açık fonksiyonların istediği sunucu anahtarının SHA-256 özeti (düz metin SAKLANMAZ).';

create table public.svc_giris (
  id            smallint primary key default 1 check (id = 1),
  password_hash text not null,
  salt          text not null,
  hata_sayisi   int not null default 0,
  kilit_sayisi  int not null default 0,
  kilit_bitis   timestamptz,
  updated_at    timestamptz not null default now()
);
comment on table public.svc_giris is 'Tek sahip (Burak) girişi. PBKDF2 + satır-başı rastgele salt, kademeli kilit.';

-- ═══ 2. Talepler ═══════════════════════════════════════════════════════════════
create sequence public.svc_talep_no_seq;

create table public.svc_talepler (
  id             uuid primary key default gen_random_uuid(),
  talep_no       text not null unique default (
                   'T' || to_char(now() at time zone 'Europe/Istanbul', 'YY') || '-'
                   || lpad(nextval('public.svc_talep_no_seq')::text, 4, '0')),
  ad             text not null check (char_length(ad) between 1 and 60),
  soyad          text not null check (char_length(soyad) between 1 and 60),
  telefon        text not null check (telefon ~ '^905\d{9}$'),
  ilce           text check (char_length(ilce) <= 60),
  mahalle        text check (char_length(mahalle) <= 80),
  adres_detay    text check (char_length(adres_detay) <= 300),
  kat            text check (char_length(kat) <= 10),
  daire          text check (char_length(daire) <= 10),
  hizmet_turu    text not null check (hizmet_turu in ('elektrik','kamera','uydu','diyafon','ag','diger')),
  aciklama       text check (char_length(aciklama) <= 2000),
  tercih_zamani  text check (char_length(tercih_zamani) <= 120),
  durum          text not null default 'yeni' check (durum in ('yeni','beklemede','kabul','red')),
  karar_notu     text check (char_length(karar_notu) <= 1000),
  karar_at       timestamptz,
  ip_hash        text check (ip_hash ~ '^[0-9a-f]{64}$'),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint svc_talepler_karar_zamani check (durum not in ('kabul','red') or karar_at is not null)
);
create index svc_talepler_durum_idx   on public.svc_talepler (durum, created_at desc);
create index svc_talepler_ip_idx      on public.svc_talepler (ip_hash, created_at desc);
create index svc_talepler_telefon_idx on public.svc_talepler (telefon, created_at desc);
create index svc_talepler_zaman_idx   on public.svc_talepler (created_at desc);

-- ═══ 3. Müşteriler ve adresler ═════════════════════════════════════════════════
create table public.svc_musteriler (
  id         uuid primary key default gen_random_uuid(),
  ad         text not null check (char_length(ad) between 1 and 60),
  soyad      text not null check (char_length(soyad) between 1 and 60),
  telefon    text not null unique check (telefon ~ '^905\d{9}$'),
  eposta     text check (char_length(eposta) <= 120),
  kaynak     text not null default 'manuel' check (kaynak in ('talep','manuel')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.svc_adresler (
  id          uuid primary key default gen_random_uuid(),
  musteri_id  uuid not null references public.svc_musteriler(id) on delete restrict,
  etiket      text check (char_length(etiket) <= 40),
  ilce        text check (char_length(ilce) <= 60),
  mahalle     text check (char_length(mahalle) <= 80),
  adres_detay text not null check (char_length(adres_detay) between 1 and 300),
  kat         text check (char_length(kat) <= 10),
  daire       text check (char_length(daire) <= 10),
  aktif       boolean not null default true,
  created_at  timestamptz not null default now(),
  constraint svc_adresler_id_musteri_uq unique (id, musteri_id)
);
create index svc_adresler_musteri_idx on public.svc_adresler (musteri_id);

-- ═══ 4. İş emirleri ════════════════════════════════════════════════════════════
create sequence public.svc_is_no_seq;

create table public.svc_isler (
  id                  uuid primary key default gen_random_uuid(),
  is_no               text not null unique default (
                        'BEE-' || to_char(now() at time zone 'Europe/Istanbul', 'YY') || '-'
                        || lpad(nextval('public.svc_is_no_seq')::text, 4, '0')),
  talep_id            uuid unique references public.svc_talepler(id) on delete restrict,
  musteri_id          uuid references public.svc_musteriler(id) on delete restrict,
  adres_id            uuid,
  baslik              text not null check (char_length(baslik) between 1 and 160),
  hizmet_turu         text not null check (hizmet_turu in ('elektrik','kamera','uydu','diyafon','ag','diger')),
  aciklama            text check (char_length(aciklama) <= 4000),
  asama               text not null default 'planlama'
                        check (asama in ('planlama','uygulama','olcum','raporlama','tamamlandi')),
  durum               text not null default 'acik' check (durum in ('acik','beklemede','kapandi','iptal')),
  oncelik             smallint not null default 2 check (oncelik between 1 and 3),
  planlanan_tarih     timestamptz,
  baslama_at          timestamptz,
  bitis_at            timestamptz,
  musteri_aciklamasi  text check (char_length(musteri_aciklamasi) <= 2000),
  rapor_ozeti         text check (char_length(rapor_ozeti) <= 4000),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  -- Adres, işin müşterisine ait olmak zorunda (başka müşterinin adresi bağlanamaz).
  constraint svc_isler_adres_musteri_fk foreign key (adres_id, musteri_id)
    references public.svc_adresler (id, musteri_id),
  constraint svc_isler_adres_musterisiz check (adres_id is null or musteri_id is not null),
  constraint svc_isler_kapanis check ((durum = 'kapandi') = (asama = 'tamamlandi')),
  constraint svc_isler_zaman check (bitis_at is null or baslama_at is null or bitis_at >= baslama_at)
);
create index svc_isler_musteri_idx on public.svc_isler (musteri_id);
create index svc_isler_durum_idx   on public.svc_isler (durum, planlanan_tarih);
comment on column public.svc_isler.aciklama is 'İÇ not — paylaşılamaz (svc_paylasimlar.alanlar listesinde yok).';
comment on column public.svc_isler.musteri_aciklamasi is 'Müşteriye gösterilebilir metin — yalnız paylaşımda seçilirse.';

-- ═══ 5. Paylaşım bağlantıları ══════════════════════════════════════════════════
create table public.svc_paylasimlar (
  id              uuid primary key default gen_random_uuid(),
  is_id           uuid not null references public.svc_isler(id) on delete cascade,
  token_hash      text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  alanlar         text[] not null check (
                    cardinality(alanlar) >= 1
                    and alanlar <@ array['baslik','asama','planlanan_tarih',
                                         'musteri_aciklamasi','rapor_ozeti','bitis_at']::text[]),
  etiket          text check (char_length(etiket) <= 80),
  son_gecerlilik  timestamptz,
  iptal_at        timestamptz,
  erisim_sayisi   int not null default 0,
  son_erisim_at   timestamptz,
  created_at      timestamptz not null default now(),
  constraint svc_paylasimlar_sure check (son_gecerlilik is null or son_gecerlilik > created_at)
);
create index svc_paylasimlar_is_idx on public.svc_paylasimlar (is_id);

-- ═══ 6. Görevler / hedefler ve notlar ═════════════════════════════════════════
create table public.svc_gorevler (
  id               uuid primary key default gen_random_uuid(),
  baslik           text not null check (char_length(baslik) between 1 and 200),
  aciklama         text check (char_length(aciklama) <= 2000),
  tur              text not null default 'gorev' check (tur in ('gorev','hedef')),
  tarih            date,
  periyot          text check (periyot in ('gun','hafta','ay')),
  hedef_deger      numeric(12,2) check (hedef_deger > 0),
  hedef_birim      text check (char_length(hedef_birim) <= 20),
  gerceklesen      numeric(12,2) not null default 0 check (gerceklesen >= 0),
  durum            text not null default 'acik' check (durum in ('acik','tamam','iptal')),
  is_id            uuid references public.svc_isler(id) on delete set null,
  tamamlandi_at    timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint svc_gorevler_hedef_alani check (tur = 'hedef' or (periyot is null and hedef_deger is null)),
  constraint svc_gorevler_tamam check ((durum = 'tamam') = (tamamlandi_at is not null))
);
create index svc_gorevler_tarih_idx on public.svc_gorevler (tarih, durum);
create index svc_gorevler_is_idx    on public.svc_gorevler (is_id);

create table public.svc_notlar (
  id          uuid primary key default gen_random_uuid(),
  baslik      text check (char_length(baslik) <= 200),
  icerik      text not null check (char_length(icerik) between 1 and 20000),
  tur         text not null default 'kisisel' check (tur in ('teknik','kisisel')),
  is_id       uuid references public.svc_isler(id) on delete set null,
  musteri_id  uuid references public.svc_musteriler(id) on delete set null,
  etiketler   text[] not null default '{}' check (cardinality(etiketler) <= 20),
  sabit       boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index svc_notlar_is_idx      on public.svc_notlar (is_id);
create index svc_notlar_musteri_idx on public.svc_notlar (musteri_id);
create index svc_notlar_tur_idx     on public.svc_notlar (tur, updated_at desc);

-- ═══ 7. Olay kaydı (silinemez) ═════════════════════════════════════════════════
create table public.svc_olaylar (
  id          bigint generated always as identity primary key,
  kayit_turu  text not null check (kayit_turu in ('talep','is','paylasim')),
  kayit_id    uuid not null,
  olay        text not null check (olay in ('olusturuldu','durum','asama','iptal')),
  eski        text,
  yeni        text,
  aciklama    text,
  created_at  timestamptz not null default now()
);
create index svc_olaylar_kayit_idx on public.svc_olaylar (kayit_turu, kayit_id, created_at);

-- ═══ 8. Tetikleyiciler ═════════════════════════════════════════════════════════
create function public.svc_updated_at() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin new.updated_at := now(); return new; end $$;

create trigger svc_talepler_updated   before update on public.svc_talepler   for each row execute function public.svc_updated_at();
create trigger svc_musteriler_updated before update on public.svc_musteriler for each row execute function public.svc_updated_at();
create trigger svc_isler_updated      before update on public.svc_isler      for each row execute function public.svc_updated_at();
create trigger svc_gorevler_updated   before update on public.svc_gorevler   for each row execute function public.svc_updated_at();
create trigger svc_notlar_updated     before update on public.svc_notlar     for each row execute function public.svc_updated_at();
create trigger svc_ayarlar_updated    before update on public.svc_ayarlar    for each row execute function public.svc_updated_at();

-- Olay kaydı: güncelleme/silme/truncate hiçbir rol için mümkün değil.
create function public.svc_olaylar_degismez() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin raise exception 'BEE_OLAY_DEGISMEZ: olay kaydı değiştirilemez veya silinemez'; end $$;

create trigger svc_olaylar_satir_kilidi before update or delete on public.svc_olaylar
  for each row execute function public.svc_olaylar_degismez();
create trigger svc_olaylar_truncate_kilidi before truncate on public.svc_olaylar
  for each statement execute function public.svc_olaylar_degismez();

-- Talep kuralları: müşteri içeriği korunur · kabul = iş emri var · kabul geri alınmaz.
create function public.svc_talepler_kural() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if (new.ad, new.soyad, new.telefon, new.ilce, new.mahalle, new.adres_detay, new.kat, new.daire,
      new.hizmet_turu, new.aciklama, new.tercih_zamani, new.ip_hash, new.talep_no, new.created_at)
     is distinct from
     (old.ad, old.soyad, old.telefon, old.ilce, old.mahalle, old.adres_detay, old.kat, old.daire,
      old.hizmet_turu, old.aciklama, old.tercih_zamani, old.ip_hash, old.talep_no, old.created_at) then
    raise exception 'BEE_TALEP_KORUNUR: müşterinin gönderdiği talep içeriği değiştirilemez';
  end if;
  if old.durum = 'kabul' and new.durum <> 'kabul' then
    raise exception 'BEE_TALEP_KABUL_KESIN: kabul edilmiş talep geri alınamaz';
  end if;
  if new.durum = 'kabul' and old.durum <> 'kabul'
     and not exists (select 1 from public.svc_isler where talep_id = new.id) then
    raise exception 'BEE_TALEP_KABUL_IS_YOK: kabul yalnız svc_talep_kabul_et() ile, iş emriyle birlikte';
  end if;
  if new.durum is distinct from old.durum and new.durum in ('kabul','red') then
    new.karar_at := now();
  end if;
  return new;
end $$;
create trigger svc_talepler_kural before update on public.svc_talepler
  for each row execute function public.svc_talepler_kural();

create function public.svc_olay_yaz() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_table_name = 'svc_talepler' then
    if tg_op = 'INSERT' then
      insert into svc_olaylar (kayit_turu, kayit_id, olay, yeni) values ('talep', new.id, 'olusturuldu', new.durum);
    elsif new.durum is distinct from old.durum then
      insert into svc_olaylar (kayit_turu, kayit_id, olay, eski, yeni, aciklama)
      values ('talep', new.id, 'durum', old.durum, new.durum, new.karar_notu);
    end if;
  elsif tg_table_name = 'svc_isler' then
    if tg_op = 'INSERT' then
      insert into svc_olaylar (kayit_turu, kayit_id, olay, yeni, aciklama)
      values ('is', new.id, 'olusturuldu', new.asama,
              case when new.talep_id is null then 'sahip açtı' else 'talepten' end);
    else
      if new.asama is distinct from old.asama then
        insert into svc_olaylar (kayit_turu, kayit_id, olay, eski, yeni) values ('is', new.id, 'asama', old.asama, new.asama);
      end if;
      if new.durum is distinct from old.durum then
        insert into svc_olaylar (kayit_turu, kayit_id, olay, eski, yeni) values ('is', new.id, 'durum', old.durum, new.durum);
      end if;
    end if;
  elsif tg_table_name = 'svc_paylasimlar' then
    if tg_op = 'INSERT' then
      insert into svc_olaylar (kayit_turu, kayit_id, olay, yeni) values ('paylasim', new.id, 'olusturuldu', array_to_string(new.alanlar, ','));
    elsif new.iptal_at is not null and old.iptal_at is null then
      insert into svc_olaylar (kayit_turu, kayit_id, olay) values ('paylasim', new.id, 'iptal');
    end if;
  end if;
  return null;
end $$;
create trigger svc_talepler_olay    after insert or update on public.svc_talepler    for each row execute function public.svc_olay_yaz();
create trigger svc_isler_olay       after insert or update on public.svc_isler       for each row execute function public.svc_olay_yaz();
create trigger svc_paylasimlar_olay after insert or update on public.svc_paylasimlar for each row execute function public.svc_olay_yaz();

-- Paylaşım: token, iş ve alanlar sabit; iptal geri alınmaz.
create function public.svc_paylasimlar_kural() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if new.token_hash <> old.token_hash or new.is_id <> old.is_id or new.alanlar <> old.alanlar then
    raise exception 'BEE_PAYLASIM_SABIT: token, iş ve alanlar değiştirilemez — yeni paylaşım açın';
  end if;
  if old.iptal_at is not null and new.iptal_at is distinct from old.iptal_at then
    raise exception 'BEE_PAYLASIM_IPTAL_KESIN: iptal geri alınamaz';
  end if;
  return new;
end $$;
create trigger svc_paylasimlar_kural before update on public.svc_paylasimlar
  for each row execute function public.svc_paylasimlar_kural();

-- ═══ 9. Herkese açık fonksiyonlar (anon'un TEK kapısı) ═══════════════════════════
create function public.svc_kapi_dogrula(p_kapi text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare beklenen text;
begin
  select deger into beklenen from svc_ayarlar where anahtar = 'kapi_hash';
  if beklenen is null or p_kapi is null
     or encode(sha256(convert_to(p_kapi, 'UTF8')), 'hex') <> beklenen then
    raise exception using errcode = '42501', message = 'BEE_KAPI: yetkisiz çağrı';
  end if;
end $$;

create function public.svc_talep_olustur(
  p_kapi text, p_ip_hash text,
  p_ad text, p_soyad text, p_telefon text, p_hizmet_turu text,
  p_aciklama text default null, p_ilce text default null, p_mahalle text default null,
  p_adres_detay text default null, p_kat text default null, p_daire text default null,
  p_tercih_zamani text default null
) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_tel text := regexp_replace(coalesce(p_telefon, ''), '\D', '', 'g');
  v_no  text;
begin
  perform svc_kapi_dogrula(p_kapi);
  if p_ip_hash is null or p_ip_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'BEE_GECERSIZ: ip_hash';
  end if;
  if v_tel ~ '^5\d{9}$' then v_tel := '90' || v_tel;
  elsif v_tel ~ '^05\d{9}$' then v_tel := '9' || v_tel; end if;

  -- Sayım ve ekleme aynı kilit altında: eşzamanlı istekler sınırı aşamaz.
  perform pg_advisory_xact_lock(hashtext('svc_talep_olustur'));
  if (select count(*) from svc_talepler where ip_hash = p_ip_hash and created_at > now() - interval '1 hour') >= 3 then
    raise exception 'BEE_SINIR_IP';
  end if;
  if (select count(*) from svc_talepler where telefon = v_tel and created_at > now() - interval '24 hours') >= 3 then
    raise exception 'BEE_SINIR_TELEFON';
  end if;
  if (select count(*) from svc_talepler where created_at > now() - interval '1 hour') >= 40 then
    raise exception 'BEE_SINIR_GENEL';
  end if;

  insert into svc_talepler (ad, soyad, telefon, hizmet_turu, aciklama, ilce, mahalle,
                            adres_detay, kat, daire, tercih_zamani, ip_hash)
  values (btrim(p_ad), btrim(p_soyad), v_tel, p_hizmet_turu, nullif(btrim(p_aciklama), ''),
          nullif(btrim(p_ilce), ''), nullif(btrim(p_mahalle), ''), nullif(btrim(p_adres_detay), ''),
          nullif(btrim(p_kat), ''), nullif(btrim(p_daire), ''), nullif(btrim(p_tercih_zamani), ''),
          p_ip_hash)
  returning talep_no into v_no;

  return jsonb_build_object('talep_no', v_no);
end $$;

create function public.svc_paylasim_oku(p_kapi text, p_token text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  p svc_paylasimlar;
  i svc_isler;
  sonuc jsonb;
begin
  perform svc_kapi_dogrula(p_kapi);
  if p_token is null or p_token !~ '^[0-9a-f]{64}$' then return null; end if;

  select * into p from svc_paylasimlar
   where token_hash = encode(sha256(convert_to(p_token, 'UTF8')), 'hex')
     and iptal_at is null
     and (son_gecerlilik is null or son_gecerlilik > now());
  if not found then return null; end if;   -- yok / süresi dolmuş / iptal: AYNI cevap

  select * into i from svc_isler where id = p.is_id;

  select coalesce(jsonb_object_agg(a, case a
           when 'baslik'             then to_jsonb(i.baslik)
           when 'asama'              then to_jsonb(i.asama)
           when 'planlanan_tarih'    then to_jsonb(i.planlanan_tarih)
           when 'musteri_aciklamasi' then to_jsonb(i.musteri_aciklamasi)
           when 'rapor_ozeti'        then to_jsonb(i.rapor_ozeti)
           when 'bitis_at'           then to_jsonb(i.bitis_at)
         end), '{}'::jsonb)
    into sonuc
    from unnest(p.alanlar) as a;

  update svc_paylasimlar set erisim_sayisi = erisim_sayisi + 1, son_erisim_at = now() where id = p.id;

  return jsonb_build_object('alanlar', sonuc, 'son_gecerlilik', p.son_gecerlilik);
end $$;

-- ═══ 10. Sahip fonksiyonları (yalnız service_role) ═══════════════════════════════
create function public.svc_talep_karar(p_talep_id uuid, p_karar text, p_not text default null)
returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if p_karar not in ('yeni','beklemede','red') then
    raise exception 'BEE_GECERSIZ: kabul için svc_talep_kabul_et() kullanılır';
  end if;
  update svc_talepler set durum = p_karar, karar_notu = nullif(btrim(p_not), '') where id = p_talep_id;
  if not found then raise exception 'BEE_YOK: talep'; end if;
end $$;

create function public.svc_talep_kabul_et(
  p_talep_id uuid, p_baslik text default null, p_planlanan timestamptz default null, p_not text default null
) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  t svc_talepler;
  v_musteri uuid;
  v_adres uuid;
  v_is uuid;
begin
  select * into t from svc_talepler where id = p_talep_id for update;
  if not found then raise exception 'BEE_YOK: talep'; end if;
  if t.durum = 'kabul' then raise exception 'BEE_TALEP_KABUL_KESIN: talep zaten kabul edildi'; end if;

  select id into v_musteri from svc_musteriler where telefon = t.telefon;
  if v_musteri is null then
    insert into svc_musteriler (ad, soyad, telefon, kaynak) values (t.ad, t.soyad, t.telefon, 'talep')
    returning id into v_musteri;
  end if;

  if t.adres_detay is not null then
    select id into v_adres from svc_adresler
     where musteri_id = v_musteri
       and lower(adres_detay) = lower(t.adres_detay)
       and coalesce(kat, '') = coalesce(t.kat, '') and coalesce(daire, '') = coalesce(t.daire, '')
     limit 1;
    if v_adres is null then
      insert into svc_adresler (musteri_id, ilce, mahalle, adres_detay, kat, daire)
      values (v_musteri, t.ilce, t.mahalle, t.adres_detay, t.kat, t.daire)
      returning id into v_adres;
    end if;
  end if;

  insert into svc_isler (talep_id, musteri_id, adres_id, baslik, hizmet_turu, aciklama, planlanan_tarih)
  values (t.id, v_musteri, v_adres,
          coalesce(nullif(btrim(p_baslik), ''), t.talep_no || ' — ' || t.hizmet_turu),
          t.hizmet_turu, t.aciklama, p_planlanan)
  returning id into v_is;

  update svc_talepler set durum = 'kabul', karar_notu = nullif(btrim(p_not), '') where id = t.id;
  return v_is;
end $$;

create function public.svc_paylasim_olustur(
  p_is_id uuid, p_alanlar text[], p_gecerlilik_gun int default 30, p_etiket text default null
) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_token text := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');
  v_id uuid;
begin
  if p_gecerlilik_gun is not null and p_gecerlilik_gun not between 1 and 365 then
    raise exception 'BEE_GECERSIZ: geçerlilik 1–365 gün ya da NULL (süresiz)';
  end if;
  insert into svc_paylasimlar (is_id, token_hash, alanlar, etiket, son_gecerlilik)
  values (p_is_id, encode(sha256(convert_to(v_token, 'UTF8')), 'hex'), p_alanlar, p_etiket,
          case when p_gecerlilik_gun is null then null else now() + make_interval(days => p_gecerlilik_gun) end)
  returning id into v_id;
  -- Düz token yalnız BU cevapta döner; veritabanında saklanmaz.
  return jsonb_build_object('id', v_id, 'token', v_token);
end $$;

create function public.svc_paylasim_iptal(p_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  update svc_paylasimlar set iptal_at = now() where id = p_id and iptal_at is null;
end $$;

-- ═══ 11. RLS ve yetkiler ════════════════════════════════════════════════════════
alter table public.svc_ayarlar      enable row level security;
alter table public.svc_giris        enable row level security;
alter table public.svc_talepler     enable row level security;
alter table public.svc_musteriler   enable row level security;
alter table public.svc_adresler     enable row level security;
alter table public.svc_isler        enable row level security;
alter table public.svc_paylasimlar  enable row level security;
alter table public.svc_gorevler     enable row level security;
alter table public.svc_notlar       enable row level security;
alter table public.svc_olaylar      enable row level security;
-- Politika YOK: anon/authenticated için RLS de her satırı gizler (ikinci kilit).

revoke all on all tables    in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;

-- Olay kaydı service_role için de salt-ekleme.
revoke update, delete, truncate on public.svc_olaylar from service_role;

grant execute on function public.svc_talep_olustur(text,text,text,text,text,text,text,text,text,text,text,text,text) to anon;
grant execute on function public.svc_paylasim_oku(text,text) to anon;

grant execute on function public.svc_talep_karar(uuid,text,text)                     to service_role;
grant execute on function public.svc_talep_kabul_et(uuid,text,timestamptz,text)      to service_role;
grant execute on function public.svc_paylasim_olustur(uuid,text[],int,text)          to service_role;
grant execute on function public.svc_paylasim_iptal(uuid)                            to service_role;
grant execute on function public.svc_talep_olustur(text,text,text,text,text,text,text,text,text,text,text,text,text) to service_role;
grant execute on function public.svc_paylasim_oku(text,text)                         to service_role;
