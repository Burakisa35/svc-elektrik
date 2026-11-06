-- 0002_sahip_api.sql — Sahibin işlemleri veritabanı fonksiyonu olarak; service_role KULLANILMAZ.
-- Neden: sunucu (Vercel) yalnız publishable key + iki sır taşır. Sahip fonksiyonları sahip
-- anahtarını, herkese açık fonksiyonlar kapı anahtarını ister; ikisinin de yalnız SHA-256 özeti
-- svc_ayarlar'da durur. Yetki kuralı veritabanındadır; sunucu kodu atlayamaz.
-- Yeni TABLO yok. Kurulum: select * from public.svc_kurulum('<panel şifresi>');  (yalnız SQL Editor)
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

-- Supabase performans denetçisi: (adres_id, musteri_id) yabancı anahtarında indeks yoktu.
create index if not exists svc_isler_adres_musteri_idx on public.svc_isler (adres_id, musteri_id);

-- bcrypt salt'ı özetin içinde taşır; ayrı salt sütunu artık gerekmez.
alter table public.svc_giris alter column salt drop not null;
comment on column public.svc_giris.password_hash is 'bcrypt (extensions.crypt, gen_salt(bf,12)) — salt özetin içinde.';

-- ═══ Kurulum (yalnız postgres / SQL Editor; hiçbir role EXECUTE verilmez) ═══════════════
create function public.svc_kurulum(p_sifre text, p_yenile boolean default false)
returns table (kapi_anahtari text, sahip_anahtari text)
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_kapi text; v_sahip text;
begin
  if p_sifre is null or char_length(p_sifre) < 10 or p_sifre !~ '[A-Za-zÇĞİÖŞÜçğıöşü]' or p_sifre !~ '\d' then
    raise exception 'BEE_KURULUM: şifre en az 10 karakter, en az 1 harf ve 1 rakam içermeli';
  end if;
  if exists (select 1 from svc_ayarlar where anahtar = 'sahip_hash') and not p_yenile then
    raise exception 'BEE_KURULUM: kurulum zaten yapılmış. Anahtarları yenilemek için p_yenile => true';
  end if;
  v_kapi  := encode(extensions.gen_random_bytes(32), 'hex');
  v_sahip := encode(extensions.gen_random_bytes(32), 'hex');
  insert into svc_ayarlar (anahtar, deger) values
    ('kapi_hash',  encode(sha256(convert_to(v_kapi,  'UTF8')), 'hex')),
    ('sahip_hash', encode(sha256(convert_to(v_sahip, 'UTF8')), 'hex'))
  on conflict (anahtar) do update set deger = excluded.deger;
  insert into svc_giris (id, password_hash, salt) values (1, extensions.crypt(p_sifre, extensions.gen_salt('bf', 12)), null)
  on conflict (id) do update set password_hash = excluded.password_hash, salt = null,
                                 hata_sayisi = 0, kilit_sayisi = 0, kilit_bitis = null, updated_at = now();
  -- Düz anahtarlar YALNIZ bu cevapta görünür; Vercel ortam değişkenlerine kopyalanır.
  return query select v_kapi, v_sahip;
end $$;

create function public.svc_sahip_dogrula(p_sahip text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare beklenen text;
begin
  select deger into beklenen from svc_ayarlar where anahtar = 'sahip_hash';
  if beklenen is null or p_sahip is null
     or encode(sha256(convert_to(p_sahip, 'UTF8')), 'hex') <> beklenen then
    raise exception using errcode = '42501', message = 'BEE_SAHIP: yetkisiz çağrı';
  end if;
end $$;

-- ═══ Giriş: şifre + kademeli kilit, tek transaction ══════════════════════════════════════
create function public.svc_s_giris(p_sahip text, p_sifre text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare g svc_giris; v_hata int; v_tur int;
begin
  perform svc_sahip_dogrula(p_sahip);
  select * into g from svc_giris where id = 1 for update;
  if not found then return jsonb_build_object('ok', false, 'neden', 'kurulum_yok'); end if;
  if g.kilit_bitis is not null and g.kilit_bitis > now() then
    return jsonb_build_object('ok', false, 'neden', 'kilitli', 'kilit_bitis', g.kilit_bitis);
  end if;
  if g.password_hash = extensions.crypt(coalesce(p_sifre, ''), g.password_hash) then
    update svc_giris set hata_sayisi = 0, kilit_sayisi = 0, kilit_bitis = null, updated_at = now() where id = 1;
    return jsonb_build_object('ok', true);
  end if;
  v_hata := g.hata_sayisi + 1;
  if v_hata >= 5 then
    v_tur := g.kilit_sayisi + 1;
    update svc_giris set hata_sayisi = 0, kilit_sayisi = v_tur, updated_at = now(),
           kilit_bitis = now() + least(interval '15 minutes' * power(2, v_tur - 1), interval '24 hours')
     where id = 1;
    return jsonb_build_object('ok', false, 'neden', 'kilitlendi');
  end if;
  update svc_giris set hata_sayisi = v_hata, updated_at = now() where id = 1;
  return jsonb_build_object('ok', false, 'neden', 'hatali');
end $$;

-- ═══ Özet ══════════════════════════════════════════════════════════════════════════════
create function public.svc_s_ozet(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  perform svc_sahip_dogrula(p_sahip);
  return jsonb_build_object(
    'bugun', bugun,
    'yeni_talep', (select count(*) from svc_talepler where durum = 'yeni'),
    'bekleyen_talep', (select count(*) from svc_talepler where durum = 'beklemede'),
    'acik_is', (select count(*) from svc_isler where durum in ('acik','beklemede')),
    'bugun_is', (select count(*) from svc_isler where durum in ('acik','beklemede')
                   and (planlanan_tarih at time zone 'Europe/Istanbul')::date = bugun),
    'acik_gorev', (select count(*) from svc_gorevler where durum = 'acik' and (tarih is null or tarih <= bugun)));
end $$;

-- ═══ Talepler ═══════════════════════════════════════════════════════════════════════════
create function public.svc_s_talepler(p_sahip text, p_durum text default null) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', t.id, 'talep_no', t.talep_no, 'ad', t.ad, 'soyad', t.soyad, 'telefon', t.telefon,
      'ilce', t.ilce, 'mahalle', t.mahalle, 'adres_detay', t.adres_detay, 'kat', t.kat, 'daire', t.daire,
      'hizmet_turu', t.hizmet_turu, 'aciklama', t.aciklama, 'tercih_zamani', t.tercih_zamani,
      'durum', t.durum, 'karar_notu', t.karar_notu, 'created_at', t.created_at,
      'is_id', (select i.id from svc_isler i where i.talep_id = t.id),
      'is_no', (select i.is_no from svc_isler i where i.talep_id = t.id))
      order by t.created_at desc)
    from (select * from svc_talepler
           where p_durum is null or durum = p_durum
           order by created_at desc limit 200) t), '[]'::jsonb);
end $$;

create function public.svc_s_talep_karar(p_sahip text, p_talep_id uuid, p_karar text, p_not text default null)
returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  perform svc_talep_karar(p_talep_id, p_karar, p_not);
end $$;

create function public.svc_s_talep_kabul(p_sahip text, p_talep_id uuid, p_baslik text default null,
                                         p_planlanan timestamptz default null, p_not text default null)
returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return svc_talep_kabul_et(p_talep_id, p_baslik, p_planlanan, p_not);
end $$;

-- ═══ İş emirleri ════════════════════════════════════════════════════════════════════════
create function public.svc_s_isler(p_sahip text, p_kapsam text default 'acik') returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', i.id, 'is_no', i.is_no, 'baslik', i.baslik, 'hizmet_turu', i.hizmet_turu,
      'asama', i.asama, 'durum', i.durum, 'oncelik', i.oncelik, 'planlanan_tarih', i.planlanan_tarih,
      'musteri', case when m.id is null then null else jsonb_build_object('ad', m.ad, 'soyad', m.soyad, 'telefon', m.telefon) end,
      'ilce', a.ilce, 'talep_no', t.talep_no, 'updated_at', i.updated_at)
      order by i.planlanan_tarih nulls last, i.created_at desc)
    from svc_isler i
    left join svc_musteriler m on m.id = i.musteri_id
    left join svc_adresler a on a.id = i.adres_id
    left join svc_talepler t on t.id = i.talep_id
    where (p_kapsam = 'acik' and i.durum in ('acik','beklemede'))
       or (p_kapsam = 'kapali' and i.durum in ('kapandi','iptal'))
       or p_kapsam = 'hepsi'), '[]'::jsonb);
end $$;

create function public.svc_s_is(p_sahip text, p_id uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare sonuc jsonb;
begin
  perform svc_sahip_dogrula(p_sahip);
  select to_jsonb(i) || jsonb_build_object(
      'musteri', to_jsonb(m),
      'adres', to_jsonb(a),
      'talep_no', t.talep_no,
      'olaylar', coalesce((select jsonb_agg(jsonb_build_object('olay', o.olay, 'eski', o.eski, 'yeni', o.yeni,
                                     'aciklama', o.aciklama, 'zaman', o.created_at) order by o.created_at)
                           from svc_olaylar o where o.kayit_turu = 'is' and o.kayit_id = i.id), '[]'::jsonb),
      'paylasimlar', coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'alanlar', p.alanlar, 'etiket', p.etiket,
                                     'son_gecerlilik', p.son_gecerlilik, 'iptal_at', p.iptal_at,
                                     'erisim_sayisi', p.erisim_sayisi, 'son_erisim_at', p.son_erisim_at,
                                     'created_at', p.created_at) order by p.created_at desc)
                               from svc_paylasimlar p where p.is_id = i.id), '[]'::jsonb))
    into sonuc
    from svc_isler i
    left join svc_musteriler m on m.id = i.musteri_id
    left join svc_adresler a on a.id = i.adres_id
    left join svc_talepler t on t.id = i.talep_id
   where i.id = p_id;
  if sonuc is null then raise exception 'BEE_YOK: iş'; end if;
  return sonuc;
end $$;

-- Talepsiz iş: müşteri telefonla bulunur ya da açılır; müşterisiz iş de olur (kendi işin).
create function public.svc_s_is_olustur(p_sahip text, p jsonb) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_tel text := regexp_replace(coalesce(p #>> '{musteri,telefon}', ''), '\D', '', 'g');
  v_musteri uuid; v_adres uuid; v_is uuid;
begin
  perform svc_sahip_dogrula(p_sahip);
  if v_tel ~ '^5\d{9}$' then v_tel := '90' || v_tel; elsif v_tel ~ '^05\d{9}$' then v_tel := '9' || v_tel; end if;

  if v_tel <> '' then
    select id into v_musteri from svc_musteriler where telefon = v_tel;
    if v_musteri is null then
      insert into svc_musteriler (ad, soyad, telefon, kaynak)
      values (btrim(p #>> '{musteri,ad}'), btrim(p #>> '{musteri,soyad}'), v_tel, 'manuel')
      returning id into v_musteri;
    end if;
  end if;

  if nullif(btrim(p #>> '{adres,adres_detay}'), '') is not null then
    if v_musteri is null then raise exception 'BEE_GECERSIZ: adres için müşteri telefonu gerekli'; end if;
    select id into v_adres from svc_adresler
     where musteri_id = v_musteri and lower(adres_detay) = lower(btrim(p #>> '{adres,adres_detay}'))
       and coalesce(kat, '') = coalesce(nullif(btrim(p #>> '{adres,kat}'), ''), '')
       and coalesce(daire, '') = coalesce(nullif(btrim(p #>> '{adres,daire}'), ''), '')
     limit 1;
    if v_adres is null then
      insert into svc_adresler (musteri_id, ilce, mahalle, adres_detay, kat, daire)
      values (v_musteri, nullif(btrim(p #>> '{adres,ilce}'), ''), nullif(btrim(p #>> '{adres,mahalle}'), ''),
              btrim(p #>> '{adres,adres_detay}'), nullif(btrim(p #>> '{adres,kat}'), ''), nullif(btrim(p #>> '{adres,daire}'), ''))
      returning id into v_adres;
    end if;
  end if;

  insert into svc_isler (musteri_id, adres_id, baslik, hizmet_turu, aciklama, oncelik, planlanan_tarih)
  values (v_musteri, v_adres, btrim(p->>'baslik'), p->>'hizmet_turu', nullif(btrim(p->>'aciklama'), ''),
          coalesce((p->>'oncelik')::smallint, 2), nullif(p->>'planlanan_tarih', '')::timestamptz)
  returning id into v_is;
  return v_is;
end $$;

-- Yalnız beyaz listedeki alanlar; asama/durum tutarlılığı burada kurulur.
create function public.svc_s_is_guncelle(p_sahip text, p_id uuid, p jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare i svc_isler; v_asama text; v_durum text;
begin
  perform svc_sahip_dogrula(p_sahip);
  select * into i from svc_isler where id = p_id for update;
  if not found then raise exception 'BEE_YOK: iş'; end if;

  v_asama := coalesce(p->>'asama', i.asama);
  v_durum := coalesce(p->>'durum', i.durum);
  if p ? 'asama' and v_asama = 'tamamlandi' then v_durum := 'kapandi';
  elsif p ? 'asama' and i.asama = 'tamamlandi' and v_asama <> 'tamamlandi' and v_durum = 'kapandi' then v_durum := 'acik';
  elsif p ? 'durum' and v_durum = 'kapandi' then v_asama := 'tamamlandi';
  end if;

  update svc_isler set
    baslik             = case when p ? 'baslik' then btrim(p->>'baslik') else baslik end,
    aciklama           = case when p ? 'aciklama' then nullif(btrim(p->>'aciklama'), '') else aciklama end,
    hizmet_turu        = case when p ? 'hizmet_turu' then p->>'hizmet_turu' else hizmet_turu end,
    oncelik            = case when p ? 'oncelik' then (p->>'oncelik')::smallint else oncelik end,
    planlanan_tarih    = case when p ? 'planlanan_tarih' then nullif(p->>'planlanan_tarih', '')::timestamptz else planlanan_tarih end,
    musteri_aciklamasi = case when p ? 'musteri_aciklamasi' then nullif(btrim(p->>'musteri_aciklamasi'), '') else musteri_aciklamasi end,
    rapor_ozeti        = case when p ? 'rapor_ozeti' then nullif(btrim(p->>'rapor_ozeti'), '') else rapor_ozeti end,
    asama              = v_asama,
    durum              = v_durum,
    baslama_at         = case when v_asama <> 'planlama' and baslama_at is null then now() else baslama_at end,
    bitis_at           = case when v_asama = 'tamamlandi' then coalesce(bitis_at, now()) else bitis_at end
  where id = p_id;
end $$;

-- ═══ Paylaşım ═══════════════════════════════════════════════════════════════════════════
create function public.svc_s_paylasim_olustur(p_sahip text, p_is_id uuid, p_alanlar text[],
                                              p_gecerlilik_gun int default 30, p_etiket text default null)
returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return svc_paylasim_olustur(p_is_id, p_alanlar, p_gecerlilik_gun, nullif(btrim(p_etiket), ''));
end $$;

create function public.svc_s_paylasim_iptal(p_sahip text, p_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  perform svc_paylasim_iptal(p_id);
end $$;

-- ═══ Görevler / hedefler ════════════════════════════════════════════════════════════════
create function public.svc_s_gorevler(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  perform svc_sahip_dogrula(p_sahip);
  return coalesce((
    select jsonb_agg(to_jsonb(g) order by g.durum <> 'acik', g.tarih nulls last, g.created_at)
    from svc_gorevler g
    where g.durum = 'acik' or (g.tamamlandi_at at time zone 'Europe/Istanbul')::date = bugun), '[]'::jsonb);
end $$;

create function public.svc_s_gorev_kaydet(p_sahip text, p jsonb) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  perform svc_sahip_dogrula(p_sahip);
  if p ? 'id' then
    update svc_gorevler set
      baslik        = case when p ? 'baslik' then btrim(p->>'baslik') else baslik end,
      tarih         = case when p ? 'tarih' then nullif(p->>'tarih', '')::date else tarih end,
      gerceklesen   = case when p ? 'gerceklesen' then (p->>'gerceklesen')::numeric else gerceklesen end,
      durum         = coalesce(p->>'durum', durum),
      tamamlandi_at = case when coalesce(p->>'durum', durum) = 'tamam' then coalesce(tamamlandi_at, now()) else null end
    where id = (p->>'id')::uuid
    returning id into v_id;
    if v_id is null then raise exception 'BEE_YOK: görev'; end if;
    return v_id;
  end if;
  insert into svc_gorevler (baslik, tur, tarih, periyot, hedef_deger, hedef_birim, is_id)
  values (btrim(p->>'baslik'), coalesce(p->>'tur', 'gorev'), nullif(p->>'tarih', '')::date,
          nullif(p->>'periyot', ''), nullif(p->>'hedef_deger', '')::numeric, nullif(btrim(p->>'hedef_birim'), ''),
          nullif(p->>'is_id', '')::uuid)
  returning id into v_id;
  return v_id;
end $$;

-- ═══ Notlar ═════════════════════════════════════════════════════════════════════════════
create function public.svc_s_notlar(p_sahip text, p_is_id uuid default null) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return coalesce((
    select jsonb_agg(to_jsonb(n) order by n.sabit desc, n.updated_at desc)
    from (select * from svc_notlar where p_is_id is null or is_id = p_is_id
           order by sabit desc, updated_at desc limit 200) n), '[]'::jsonb);
end $$;

create function public.svc_s_not_kaydet(p_sahip text, p jsonb) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  perform svc_sahip_dogrula(p_sahip);
  if p ? 'id' then
    update svc_notlar set
      baslik = case when p ? 'baslik' then nullif(btrim(p->>'baslik'), '') else baslik end,
      icerik = case when p ? 'icerik' then p->>'icerik' else icerik end,
      tur    = coalesce(p->>'tur', tur),
      sabit  = coalesce((p->>'sabit')::boolean, sabit)
    where id = (p->>'id')::uuid
    returning id into v_id;
    if v_id is null then raise exception 'BEE_YOK: not'; end if;
    return v_id;
  end if;
  insert into svc_notlar (baslik, icerik, tur, is_id)
  values (nullif(btrim(p->>'baslik'), ''), p->>'icerik', coalesce(p->>'tur', 'kisisel'), nullif(p->>'is_id', '')::uuid)
  returning id into v_id;
  return v_id;
end $$;

-- ═══ Yetkiler ═══════════════════════════════════════════════════════════════════════════
-- svc_s_* fonksiyonları anon'a açık AMA sahip anahtarı olmadan ilk satırda 42501 ile reddeder.
-- Sunucu publishable key ile çağırır; service_role hiçbir yerde kullanılmaz.
revoke all on function public.svc_kurulum(text, boolean)  from public, anon, authenticated, service_role;
revoke all on function public.svc_sahip_dogrula(text)     from public, anon, authenticated;

grant execute on function public.svc_s_giris(text, text)                                    to anon;
grant execute on function public.svc_s_ozet(text)                                           to anon;
grant execute on function public.svc_s_talepler(text, text)                                 to anon;
grant execute on function public.svc_s_talep_karar(text, uuid, text, text)                  to anon;
grant execute on function public.svc_s_talep_kabul(text, uuid, text, timestamptz, text)     to anon;
grant execute on function public.svc_s_isler(text, text)                                    to anon;
grant execute on function public.svc_s_is(text, uuid)                                       to anon;
grant execute on function public.svc_s_is_olustur(text, jsonb)                              to anon;
grant execute on function public.svc_s_is_guncelle(text, uuid, jsonb)                       to anon;
grant execute on function public.svc_s_paylasim_olustur(text, uuid, text[], int, text)      to anon;
grant execute on function public.svc_s_paylasim_iptal(text, uuid)                           to anon;
grant execute on function public.svc_s_gorevler(text)                                       to anon;
grant execute on function public.svc_s_gorev_kaydet(text, jsonb)                            to anon;
grant execute on function public.svc_s_notlar(text, uuid)                                   to anon;
grant execute on function public.svc_s_not_kaydet(text, jsonb)                              to anon;
