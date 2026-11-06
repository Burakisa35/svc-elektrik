-- 0004_modul1_saha.sql — Modül 1: sahada ≤30 sn iş açma, çift kayıt engeli, kaçan iş alanları, kurulum kodu sayacı.
-- Burak'ın düzeltmeleri (2026-11-06) #1 #6 #7. Girilmeyen alan BOŞ kalır: hiçbir yeni alanın varsayılanı yok.
-- Veri etkisi (canlıda ölçüldü, uygulama öncesi): bütün svc_ tabloları 0 satır; drop/kısıt değişikliği veri kaybettirmez.
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

-- ═══ Müşteri: telefon VEYA ad yeterli ═══════════════════════════════════════════════════
alter table public.svc_musteriler alter column ad drop not null,
                                  alter column soyad drop not null,
                                  alter column telefon drop not null;
alter table public.svc_musteriler add constraint svc_musteriler_tanimli check (telefon is not null or ad is not null);

-- ═══ İş: tekillik, durum seti, kaçan iş alanları ═══════════════════════════════════════
alter table public.svc_isler add column istemci_id uuid unique;
-- 'beklemede' kaldırıldı: 'ertelendi' ile aynı şeyi anlatıyordu; NEDEN'i 'engel' taşır. Tabloda 0 satır vardı.
alter table public.svc_isler drop constraint svc_isler_durum_check;
alter table public.svc_isler add constraint svc_isler_durum_check
  check (durum in ('acik','ertelendi','kapandi','iptal','kacirildi'));
alter table public.svc_isler
  add column engel text check (engel in ('ekipman','bilgi','ulasim','malzeme','zaman','fiyat','diger')),
  add column tahmini_bedel numeric(12,2) check (tahmini_bedel >= 0),
  add column talep_kanali text check (talep_kanali in ('telefon','whatsapp','yuz_yuze','referans','form','diger'));
comment on column public.svc_isler.tahmini_bedel is
  'TL, TAHMİN, finans kaydı DEĞİL. Kaçan işin değerini görmek için. Gelire sayılmaz, paylaşılamaz (izin listesinde yok).';
comment on column public.svc_isler.engel is 'Ertelenen/kaçırılan işin nedeni. Boşsa bilinmiyor demektir.';

alter table public.svc_talepler add column istemci_id uuid unique;

-- ═══ Herkese açık talep: istemci_id ile tekrar deneme aynı kaydı döndürür ═══════════════
drop function public.svc_talep_olustur(text,text,text,text,text,text,text,text,text,text,text,text,text);
create function public.svc_talep_olustur(
  p_kapi text, p_ip_hash text,
  p_ad text, p_soyad text, p_telefon text, p_hizmet_turu text,
  p_aciklama text default null, p_ilce text default null, p_mahalle text default null,
  p_adres_detay text default null, p_kat text default null, p_daire text default null,
  p_tercih_zamani text default null, p_istemci_id uuid default null
) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_tel text := regexp_replace(coalesce(p_telefon, ''), '\D', '', 'g');
  v_no  text;
begin
  perform svc_kapi_dogrula(p_kapi);
  if p_ip_hash is null or p_ip_hash !~ '^[0-9a-f]{64}$' then raise exception 'BEE_GECERSIZ: ip_hash'; end if;
  -- Tekrar deneme: sınır sayacına girmeden önceki kaydı döndür.
  if p_istemci_id is not null then
    select talep_no into v_no from svc_talepler where istemci_id = p_istemci_id;
    if v_no is not null then return jsonb_build_object('talep_no', v_no); end if;
  end if;
  if v_tel ~ '^5\d{9}$' then v_tel := '90' || v_tel;
  elsif v_tel ~ '^05\d{9}$' then v_tel := '9' || v_tel; end if;

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
                            adres_detay, kat, daire, tercih_zamani, ip_hash, istemci_id)
  values (btrim(p_ad), btrim(p_soyad), v_tel, p_hizmet_turu, nullif(btrim(p_aciklama), ''),
          nullif(btrim(p_ilce), ''), nullif(btrim(p_mahalle), ''), nullif(btrim(p_adres_detay), ''),
          nullif(btrim(p_kat), ''), nullif(btrim(p_daire), ''), nullif(btrim(p_tercih_zamani), ''),
          p_ip_hash, p_istemci_id)
  returning talep_no into v_no;
  return jsonb_build_object('talep_no', v_no);
end $$;
grant execute on function public.svc_talep_olustur(text,text,text,text,text,text,text,text,text,text,text,text,text,uuid) to anon;

-- Kabul edilen talepten doğan işin kanalı 'form'dur (bilinen bilgi, uydurma değil).
create or replace function public.svc_talep_kabul_et(
  p_talep_id uuid, p_baslik text default null, p_planlanan timestamptz default null, p_not text default null
) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare t svc_talepler; v_musteri uuid; v_adres uuid; v_is uuid;
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
     where musteri_id = v_musteri and lower(adres_detay) = lower(t.adres_detay)
       and coalesce(kat, '') = coalesce(t.kat, '') and coalesce(daire, '') = coalesce(t.daire, '')
     limit 1;
    if v_adres is null then
      insert into svc_adresler (musteri_id, ilce, mahalle, adres_detay, kat, daire)
      values (v_musteri, t.ilce, t.mahalle, t.adres_detay, t.kat, t.daire) returning id into v_adres;
    end if;
  end if;
  insert into svc_isler (talep_id, musteri_id, adres_id, baslik, hizmet_turu, aciklama, planlanan_tarih, talep_kanali)
  values (t.id, v_musteri, v_adres, coalesce(nullif(btrim(p_baslik), ''), t.talep_no || ' — ' || t.hizmet_turu),
          t.hizmet_turu, t.aciklama, p_planlanan, 'form')
  returning id into v_is;
  update svc_talepler set durum = 'kabul', karar_notu = nullif(btrim(p_not), '') where id = t.id;
  return v_is;
end $$;

-- ═══ Sahip: özet ve iş listesi yeni durum setiyle ═══════════════════════════════════════
create or replace function public.svc_s_ozet(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare bugun date := (now() at time zone 'Europe/Istanbul')::date;
begin
  perform svc_sahip_dogrula(p_sahip);
  return jsonb_build_object(
    'bugun', bugun,
    'yeni_talep', (select count(*) from svc_talepler where durum = 'yeni'),
    'bekleyen_talep', (select count(*) from svc_talepler where durum = 'beklemede'),
    'acik_is', (select count(*) from svc_isler where durum in ('acik','ertelendi')),
    'bugun_is', (select count(*) from svc_isler where durum in ('acik','ertelendi')
                   and (planlanan_tarih at time zone 'Europe/Istanbul')::date = bugun),
    'acik_gorev', (select count(*) from svc_gorevler where durum = 'acik' and (tarih is null or tarih <= bugun)));
end $$;

create or replace function public.svc_s_isler(p_sahip text, p_kapsam text default 'acik') returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform svc_sahip_dogrula(p_sahip);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', i.id, 'is_no', i.is_no, 'baslik', i.baslik, 'hizmet_turu', i.hizmet_turu,
      'asama', i.asama, 'durum', i.durum, 'engel', i.engel, 'oncelik', i.oncelik,
      'planlanan_tarih', i.planlanan_tarih,
      'musteri', case when m.id is null then null else jsonb_build_object('ad', m.ad, 'soyad', m.soyad, 'telefon', m.telefon) end,
      'ilce', a.ilce, 'talep_no', t.talep_no, 'updated_at', i.updated_at)
      order by i.planlanan_tarih nulls last, i.created_at desc)
    from svc_isler i
    left join svc_musteriler m on m.id = i.musteri_id
    left join svc_adresler a on a.id = i.adres_id
    left join svc_talepler t on t.id = i.talep_id
    where (p_kapsam = 'acik' and i.durum in ('acik','ertelendi'))
       or (p_kapsam = 'kapali' and i.durum in ('kapandi','iptal','kacirildi'))
       or p_kapsam = 'hepsi'), '[]'::jsonb);
end $$;

-- Müşteriyi telefonla bul; yoksa (telefon ya da ad varsa) aç. Var olan dolu alanın üstüne YAZMAZ, yalnız boşu doldurur.
create function public.svc_musteri_bul_ac(p_tel text, p_ad text, p_soyad text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_tel text := regexp_replace(coalesce(p_tel, ''), '\D', '', 'g');
  v_ad text := nullif(btrim(p_ad), ''); v_soyad text := nullif(btrim(p_soyad), '');
  v_id uuid;
begin
  if v_tel ~ '^5\d{9}$' then v_tel := '90' || v_tel; elsif v_tel ~ '^05\d{9}$' then v_tel := '9' || v_tel; end if;
  v_tel := nullif(v_tel, '');
  if v_tel is null and v_ad is null then return null; end if;
  if v_tel is not null then
    select id into v_id from svc_musteriler where telefon = v_tel;
    if v_id is not null then
      update svc_musteriler set ad = coalesce(ad, v_ad), soyad = coalesce(soyad, v_soyad) where id = v_id;
      return v_id;
    end if;
  end if;
  insert into svc_musteriler (ad, soyad, telefon, kaynak) values (v_ad, v_soyad, v_tel, 'manuel') returning id into v_id;
  return v_id;
end $$;
revoke all on function public.svc_musteri_bul_ac(text,text,text) from public, anon, authenticated;

-- Sahada iş açma: zorunlu olan yalnız bir şey (telefon, ad ya da not). istemci_id tekrar denemeyi yutar.
create or replace function public.svc_s_is_olustur(p_sahip text, p jsonb) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_musteri uuid; v_adres uuid; v_is uuid;
  v_not text := nullif(btrim(coalesce(p->>'aciklama', '')), '');
  v_baslik text := nullif(btrim(coalesce(p->>'baslik', '')), '');
begin
  perform svc_sahip_dogrula(p_sahip);
  if p ? 'istemci_id' then
    select id into v_is from svc_isler where istemci_id = (p->>'istemci_id')::uuid;
    if v_is is not null then return v_is; end if;
  end if;

  v_musteri := svc_musteri_bul_ac(p #>> '{musteri,telefon}', p #>> '{musteri,ad}', p #>> '{musteri,soyad}');
  if v_musteri is null and v_not is null and v_baslik is null then
    raise exception 'BEE_GECERSIZ: telefon, ad ya da not gerekli';
  end if;

  if nullif(btrim(p #>> '{adres,adres_detay}'), '') is not null then
    if v_musteri is null then raise exception 'BEE_GECERSIZ: adres için müşteri gerekli'; end if;
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

  -- Başlık boşsa: notun ilk satırı → müşteri adı → telefon. Uydurma metin yok.
  if v_baslik is null then
    v_baslik := left(split_part(coalesce(v_not, ''), E'\n', 1), 60);
    if v_baslik = '' then
      select coalesce(nullif(btrim(concat_ws(' ', ad, soyad)), ''), telefon) into v_baslik from svc_musteriler where id = v_musteri;
    end if;
  end if;

  insert into svc_isler (istemci_id, musteri_id, adres_id, baslik, hizmet_turu, aciklama, oncelik,
                         planlanan_tarih, talep_kanali, tahmini_bedel)
  values (nullif(p->>'istemci_id', '')::uuid, v_musteri, v_adres, v_baslik,
          coalesce(nullif(p->>'hizmet_turu', ''), 'diger'), v_not,
          coalesce(nullif(p->>'oncelik', '')::smallint, 2), nullif(p->>'planlanan_tarih', '')::timestamptz,
          nullif(p->>'talep_kanali', ''), nullif(p->>'tahmini_bedel', '')::numeric(12,2))
  returning id into v_is;
  return v_is;
end $$;

-- Güncelleme: durum + olay kaydı TEK transaction'da (olay tetikleyicisi aynı ifadede çalışır).
create or replace function public.svc_s_is_guncelle(p_sahip text, p_id uuid, p jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare i svc_isler; v_asama text; v_durum text; v_musteri uuid;
begin
  perform svc_sahip_dogrula(p_sahip);
  select * into i from svc_isler where id = p_id for update;
  if not found then raise exception 'BEE_YOK: iş'; end if;

  v_asama := coalesce(p->>'asama', i.asama);
  v_durum := coalesce(p->>'durum', i.durum);
  if p ? 'asama' and v_asama = 'tamamlandi' then v_durum := 'kapandi';
  elsif p ? 'asama' and i.asama = 'tamamlandi' and v_asama <> 'tamamlandi' and v_durum = 'kapandi' then v_durum := 'acik';
  elsif p ? 'durum' and v_durum = 'kapandi' then v_asama := 'tamamlandi';
  elsif p ? 'durum' and i.durum = 'kapandi' and v_durum <> 'kapandi' and v_asama = 'tamamlandi' then v_asama := 'raporlama';
  end if;

  -- Müşteri bilgisi sonradan eklenebilir (sahada yalnız ad yazılmış işe telefon gibi).
  v_musteri := i.musteri_id;
  if p ? 'musteri' then
    if v_musteri is null then
      v_musteri := svc_musteri_bul_ac(p #>> '{musteri,telefon}', p #>> '{musteri,ad}', p #>> '{musteri,soyad}');
    else
      update svc_musteriler set
        ad      = case when p->'musteri' ? 'ad' then nullif(btrim(p #>> '{musteri,ad}'), '') else ad end,
        soyad   = case when p->'musteri' ? 'soyad' then nullif(btrim(p #>> '{musteri,soyad}'), '') else soyad end,
        telefon = case when p->'musteri' ? 'telefon' then nullif(
                    (select case when x ~ '^5\d{9}$' then '90' || x when x ~ '^05\d{9}$' then '9' || x else x end
                       from regexp_replace(coalesce(p #>> '{musteri,telefon}', ''), '\D', '', 'g') as x), '')
                  else telefon end
      where id = v_musteri;
    end if;
  end if;

  update svc_isler set
    musteri_id          = v_musteri,
    baslik              = case when p ? 'baslik' then btrim(p->>'baslik') else baslik end,
    aciklama            = case when p ? 'aciklama' then nullif(btrim(p->>'aciklama'), '') else aciklama end,
    hizmet_turu         = case when p ? 'hizmet_turu' then p->>'hizmet_turu' else hizmet_turu end,
    oncelik             = case when p ? 'oncelik' then (p->>'oncelik')::smallint else oncelik end,
    planlanan_tarih     = case when p ? 'planlanan_tarih' then nullif(p->>'planlanan_tarih', '')::timestamptz else planlanan_tarih end,
    musteri_aciklamasi  = case when p ? 'musteri_aciklamasi' then nullif(btrim(p->>'musteri_aciklamasi'), '') else musteri_aciklamasi end,
    rapor_ozeti         = case when p ? 'rapor_ozeti' then nullif(btrim(p->>'rapor_ozeti'), '') else rapor_ozeti end,
    engel               = case when p ? 'engel' then nullif(p->>'engel', '') else engel end,
    tahmini_bedel       = case when p ? 'tahmini_bedel' then nullif(p->>'tahmini_bedel', '')::numeric(12,2) else tahmini_bedel end,
    talep_kanali        = case when p ? 'talep_kanali' then nullif(p->>'talep_kanali', '') else talep_kanali end,
    asama               = v_asama,
    durum               = v_durum,
    baslama_at          = case when v_asama <> 'planlama' and baslama_at is null then now() else baslama_at end,
    bitis_at            = case when v_asama = 'tamamlandi' then coalesce(bitis_at, now()) else bitis_at end
  where id = p_id;
end $$;

-- ═══ İlk parola: kurulum kodu denemeleri sayılır (#1) ═══════════════════════════════════
-- Kod Vercel'de (PANEL_KURULUM_KODU) durur, DB onu bilmez; karşılaştırma sunucuda timingSafeEqual ile.
-- Sayaç doğrulamadan ÖNCE artar; 5 hatadan sonra 1 saat kilit, her turda katlanır (≤24 saat).
create function public.svc_s_kurulum_baslat(p_sahip text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_hata int; v_tur int; v_kilit timestamptz;
begin
  perform svc_sahip_dogrula(p_sahip);
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

create or replace function public.svc_s_sifre_kur(p_sahip text, p_hash text, p_salt text, p_iterasyon int)
returns boolean
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_kuruldu boolean;
begin
  perform svc_sahip_dogrula(p_sahip);
  if p_hash !~ '^[0-9a-f]{64}$' or p_salt !~ '^[0-9a-f]{32,}$' then raise exception 'BEE_GECERSIZ: özet/salt'; end if;
  insert into svc_giris (id, password_hash, salt, iterasyon) values (1, p_hash, p_salt, p_iterasyon)
  on conflict (id) do nothing;
  v_kuruldu := found;
  if v_kuruldu then delete from svc_ayarlar where anahtar in ('kurulum_hata', 'kurulum_kilit', 'kurulum_kilit_turu'); end if;
  return v_kuruldu;
end $$;

grant execute on function public.svc_s_kurulum_baslat(text) to anon;

-- ═══ Silinmezlik: olay kaydı olan iş ve talep silinemez (kapatılır/iptal edilir) ═══════════
-- Her iş ve talep doğduğunda bir olay satırı aldığı için bu pratikte "hiç silinmez" demektir.
create function public.svc_olayli_kayit_silinmez() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if exists (select 1 from public.svc_olaylar where kayit_id = old.id) then
    raise exception 'BEE_SILINMEZ: olay kaydı olan kayıt silinemez; kapatın veya iptal edin';
  end if;
  return old;
end $$;
create trigger svc_isler_silinmez before delete on public.svc_isler
  for each row execute function public.svc_olayli_kayit_silinmez();
create trigger svc_talepler_silinmez before delete on public.svc_talepler
  for each row execute function public.svc_olayli_kayit_silinmez();
create index svc_olaylar_kayit_id_idx on public.svc_olaylar (kayit_id);
