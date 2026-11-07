-- 0008_dilim1_duzeltme.sql — Dilim 1 düzeltmeleri; testleri önce yazıldı ve kırmızıydı (AKTIF.md adım 2–3).
-- Burak onayı gerekir. Veri etkisi: tablo yapısı değişmez, yalnız 4 fonksiyonun gövdesi değişir.
--  1. svc_s_is_olustur: boş istemci_id iş açar, bozuk olan BEE_GECERSIZ verir; eşzamanlı tekrar deneme tek iş üretir (I3, I4, Y1).
--  2. svc_s_is_guncelle: çelişkili aşama + durum reddedilir (I7).
--  3. svc_s_giris_tamamla: kilit süresinin üssü çarpımdan önce sınırlanır; 35. turda taşıp kilidi kapatmıyordu (G6, DENETIM D1).
--  4. svc_s_kurulum_baslat: aynı taşma, 33. tur (G7).
-- Gövdeler 0004/0005'ten programla kopyalandı, yalnız yukarıdaki satırlar değişti. Yetkiler korunur (create or replace).
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

create or replace function public.svc_s_is_olustur(p_sahip text, p jsonb) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_musteri uuid; v_adres uuid; v_is uuid;
  v_istemci text := nullif(btrim(coalesce(p->>'istemci_id', '')), '');
  v_not text := nullif(btrim(coalesce(p->>'aciklama', '')), '');
  v_baslik text := nullif(btrim(coalesce(p->>'baslik', '')), '');
begin
  perform svc_sahip_dogrula(p_sahip);
  -- Tekrar deneme: boş istemci_id "yok" sayılır, bozuk olan alan adıyla reddedilir. Kilit, kontrol ve
  -- eklemeyi (müşteri oluşturma dahil) tek sıraya sokar: eşzamanlı ikinci istek birincinin işini döndürür (yaris-is.sh).
  if v_istemci is not null then
    if v_istemci !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
      raise exception 'BEE_GECERSIZ: istemci_id';
    end if;
    perform pg_advisory_xact_lock(hashtext('svc_s_is_olustur:' || lower(v_istemci)));
    select id into v_is from svc_isler where istemci_id = v_istemci::uuid;
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
  values (v_istemci::uuid, v_musteri, v_adres, v_baslik,
          coalesce(nullif(p->>'hizmet_turu', ''), 'diger'), v_not,
          coalesce(nullif(p->>'oncelik', '')::smallint, 2), nullif(p->>'planlanan_tarih', '')::timestamptz,
          nullif(p->>'talep_kanali', ''), nullif(p->>'tahmini_bedel', '')::numeric(12,2))
  returning id into v_is;
  return v_is;
end $$;

create or replace function public.svc_s_is_guncelle(p_sahip text, p_id uuid, p jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare i svc_isler; v_asama text; v_durum text; v_musteri uuid;
begin
  perform svc_sahip_dogrula(p_sahip);
  select * into i from svc_isler where id = p_id for update;
  if not found then raise exception 'BEE_YOK: iş'; end if;

  -- Aynı istekte gelen aşama ve durum birbirini tutmalı: "tamamlandı" yalnız "kapandı" ile gelir.
  -- Önceden çelişki sessizce "kapandı"ya çevriliyordu (ADAYLAR C3).
  if p ? 'asama' and p ? 'durum' and ((p->>'asama') = 'tamamlandi') <> ((p->>'durum') = 'kapandi') then
    raise exception 'BEE_GECERSIZ: asama ve durum çelişiyor';
  end if;
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

create or replace function public.svc_s_giris_tamamla(p_sahip text, p_turetilmis text, p_istemci text default null)
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
    v_bitis := now() + least(interval '15 minutes' * power(2, least(v_tur - 1, 7)), interval '24 hours');
    update svc_giris set hata_sayisi = 0, kilit_sayisi = v_tur, kilit_bitis = v_bitis, updated_at = now() where id = 1;
    return jsonb_build_object('ok', false, 'neden', 'kilitlendi', 'kilit_bitis', v_bitis);
  end if;
  update svc_giris set hata_sayisi = g.hata_sayisi + 1, updated_at = now() where id = 1;
  return jsonb_build_object('ok', false, 'neden', 'hatali');
end $$;

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
    v_kilit := now() + least(interval '1 hour' * power(2, least(v_tur - 1, 5)), interval '24 hours');
    insert into svc_ayarlar (anahtar, deger) values ('kurulum_hata', '0'), ('kurulum_kilit_turu', v_tur::text),
                                                    ('kurulum_kilit', v_kilit::text)
    on conflict (anahtar) do update set deger = excluded.deger;
    return jsonb_build_object('kurulu', false, 'kilitli', true, 'kilit_bitis', v_kilit);
  end if;
  insert into svc_ayarlar (anahtar, deger) values ('kurulum_hata', (v_hata + 1)::text)
  on conflict (anahtar) do update set deger = excluded.deger;
  return jsonb_build_object('kurulu', false, 'kilitli', false);
end $$;
