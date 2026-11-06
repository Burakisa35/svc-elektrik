-- BEE erişim testleri — sahip · anonim ziyaretçi · paylaşım linki.
-- Çalıştırma: Supabase SQL Editor ya da MCP execute_sql (proje uwmbtaxxdcjumxbnigpy).
-- Tek DO bloğu; sonunda KASITLI raise ile her şey geri alınır, sayaçlar da eski değerine döner → iz kalmaz.
-- Beklenen çıktı: "BEE_TEST_SONUC kalan=0 ..." hata mesajı. kalan>0 ise KALDI satırları okunur.
do $$
declare
  rapor text := '';
  kalan int := 0;
  kapi constant text := 'test-kapi-anahtari';
  ip1 constant text := repeat('a', 64);
  ip2 constant text := repeat('b', 64);
  ip3 constant text := repeat('c', 64);
  r jsonb; t_id uuid; t2_id uuid; is_id uuid; kendi_is uuid; pay jsonb; pay2 jsonb; n int; tablo text;
  hata text;
  -- Sayaçlar transaction geri alınsa da ilerler; test sonunda setval ile eski hâline döner (setval kalıcıdır).
  olay_seq constant text := pg_get_serial_sequence('public.svc_olaylar', 'id');
  s_talep bigint; c_talep boolean; s_is bigint; c_is boolean; s_olay bigint; c_olay boolean;
begin
  select last_value, is_called into s_talep, c_talep from public.svc_talep_no_seq;
  select last_value, is_called into s_is, c_is from public.svc_is_no_seq;
  execute format('select last_value, is_called from %s', olay_seq) into s_olay, c_olay;

  -- Hazırlık (postgres): kapı anahtarının özeti.
  insert into svc_ayarlar (anahtar, deger) values ('kapi_hash', encode(sha256(convert_to(kapi, 'UTF8')), 'hex'))
  on conflict (anahtar) do update set deger = excluded.deger;

  -- ═══ ANONİM ═══
  foreach tablo in array array['svc_talepler','svc_musteriler','svc_adresler','svc_isler','svc_paylasimlar',
                               'svc_gorevler','svc_notlar','svc_olaylar','svc_giris','svc_ayarlar','svc_proje_kimlik'] loop
    begin
      set local role anon;
      execute format('select count(*) from public.%I', tablo);
      reset role;
      rapor := rapor || E'\nKALDI A1 anon ' || tablo || ' okuyabildi'; kalan := kalan + 1;
    exception when insufficient_privilege then
      rapor := rapor || E'\nGEÇTİ A1 anon ' || tablo || ' okuyamaz';
    end;
  end loop;

  begin
    set local role anon;
    insert into svc_talepler (ad, soyad, telefon, hizmet_turu) values ('X','Y','905000000000','diger');
    reset role;
    rapor := rapor || E'\nKALDI A2 anon doğrudan talep ekledi'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ A2 anon tabloya doğrudan yazamaz'; end;

  begin
    set local role anon;
    perform svc_talep_kabul_et(gen_random_uuid());
    reset role;
    rapor := rapor || E'\nKALDI A3 anon sahip fonksiyonunu çağırdı'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ A3 anon sahip fonksiyonlarını çağıramaz'; end;

  begin
    set local role anon;
    perform svc_talep_olustur('yanlis', ip1, 'Ali', 'Veli', '05321112233', 'elektrik');
    reset role;
    rapor := rapor || E'\nKALDI A4 yanlış kapı anahtarı kabul edildi'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ A4 kapı anahtarı olmadan talep yok'; end;

  begin
    set local role anon;
    r := svc_talep_olustur(kapi, ip1, ' Ali ', 'Veli', '0532 111 22 33', 'elektrik', 'Priz yanık kokuyor', 'Kemalpaşa', 'Armutlu', 'Cumhuriyet Cd. 5', '2', '4');
    reset role;
    if r ? 'talep_no' and r - 'talep_no' = '{}'::jsonb then
      rapor := rapor || E'\nGEÇTİ A5 talep oluştu, yalnız talep_no döndü (' || (r->>'talep_no') || ')';
    else rapor := rapor || E'\nKALDI A5 dönüş: ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI A5 ' || sqlerrm; kalan := kalan + 1; end;

  select id into t_id from svc_talepler where telefon = '905321112233';
  if (select ad from svc_talepler where id = t_id) = 'Ali' then rapor := rapor || E'\nGEÇTİ A5b ad kırpıldı, telefon 905 biçiminde';
  else rapor := rapor || E'\nKALDI A5b normalize'; kalan := kalan + 1; end if;

  -- IP sınırı: ip1 ile 2 talep daha (toplam 3) geçer, 4. reddedilir.
  begin
    set local role anon;
    perform svc_talep_olustur(kapi, ip1, 'A', 'B', '05320000001', 'kamera');
    perform svc_talep_olustur(kapi, ip1, 'A', 'B', '05320000002', 'kamera');
    reset role;
  exception when others then rapor := rapor || E'\nKALDI A6 hazırlık ' || sqlerrm; kalan := kalan + 1; end;
  begin
    set local role anon;
    perform svc_talep_olustur(kapi, ip1, 'A', 'B', '05320000003', 'kamera');
    reset role;
    rapor := rapor || E'\nKALDI A6 IP sınırı aşıldı'; kalan := kalan + 1;
  exception when others then
    if sqlerrm like 'BEE_SINIR_IP%' then rapor := rapor || E'\nGEÇTİ A6 4. talep aynı IP''den reddedildi';
    else rapor := rapor || E'\nKALDI A6 ' || sqlerrm; kalan := kalan + 1; end if;
  end;

  -- Telefon sınırı: aynı telefon, farklı IP'ler.
  begin
    set local role anon;
    perform svc_talep_olustur(kapi, ip2, 'A', 'B', '05329999999', 'uydu');
    perform svc_talep_olustur(kapi, ip2, 'A', 'B', '05329999999', 'uydu');
    perform svc_talep_olustur(kapi, ip3, 'A', 'B', '05329999999', 'uydu');
    perform svc_talep_olustur(kapi, ip3, 'A', 'B', '05329999999', 'uydu');
    reset role;
    rapor := rapor || E'\nKALDI A7 telefon sınırı aşıldı'; kalan := kalan + 1;
  exception when others then
    if sqlerrm like 'BEE_SINIR_TELEFON%' then rapor := rapor || E'\nGEÇTİ A7 aynı telefondan 4. talep reddedildi';
    else rapor := rapor || E'\nKALDI A7 ' || sqlerrm; kalan := kalan + 1; end if;
  end;

  begin
    set local role anon;
    perform svc_talep_olustur(kapi, repeat('d',64), 'A', 'B', '12345', 'elektrik');
    reset role;
    rapor := rapor || E'\nKALDI A8 geçersiz telefon kabul edildi'; kalan := kalan + 1;
  exception when check_violation then rapor := rapor || E'\nGEÇTİ A8 geçersiz telefon reddedildi'; end;

  begin
    set local role anon;
    perform svc_talep_olustur(kapi, repeat('e',64), repeat('x', 61), 'B', '05321230000', 'elektrik');
    reset role;
    rapor := rapor || E'\nKALDI A9 61 karakterlik ad kabul edildi'; kalan := kalan + 1;
  exception when check_violation then rapor := rapor || E'\nGEÇTİ A9 uzunluk sınırı veritabanında'; end;

  begin
    set local role anon;
    r := svc_paylasim_oku(kapi, repeat('0', 64));
    reset role;
    if r is null then rapor := rapor || E'\nGEÇTİ A10 var olmayan link → boş';
    else rapor := rapor || E'\nKALDI A10'; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI A10 ' || sqlerrm; kalan := kalan + 1; end;

  -- ═══ SAHİP (service_role) ═══
  begin
    set local role service_role;
    update svc_talepler set durum = 'kabul' where id = t_id;
    reset role;
    rapor := rapor || E'\nKALDI O1 iş emri olmadan kabul yazıldı'; kalan := kalan + 1;
  exception when others then
    if sqlerrm like 'BEE_TALEP_KABUL_IS_YOK%' then rapor := rapor || E'\nGEÇTİ O1 talep iş emri olmadan kabul edilemez (sunucu bile)';
    else rapor := rapor || E'\nKALDI O1 ' || sqlerrm; kalan := kalan + 1; end if;
  end;

  begin
    set local role service_role;
    update svc_talepler set ad = 'Değişti' where id = t_id;
    reset role;
    rapor := rapor || E'\nKALDI O2 talep içeriği değişti'; kalan := kalan + 1;
  exception when others then
    if sqlerrm like 'BEE_TALEP_KORUNUR%' then rapor := rapor || E'\nGEÇTİ O2 müşterinin talep içeriği değiştirilemez';
    else rapor := rapor || E'\nKALDI O2 ' || sqlerrm; kalan := kalan + 1; end if;
  end;

  begin
    set local role service_role;
    perform svc_talep_karar(t_id, 'beklemede', 'Malzeme sorulacak');
    is_id := svc_talep_kabul_et(t_id, 'Priz arızası', now() + interval '1 day');
    reset role;
    if (select durum from svc_talepler where id = t_id) = 'kabul'
       and (select talep_id from svc_isler where id = is_id) = t_id
       and (select count(*) from svc_musteriler where telefon = '905321112233') = 1
       and (select count(*) from svc_adresler a join svc_musteriler m on m.id = a.musteri_id where m.telefon = '905321112233') = 1
    then rapor := rapor || E'\nGEÇTİ O3 beklet → kabul: müşteri + adres + iş tek adımda';
    else rapor := rapor || E'\nKALDI O3 kabul sonucu tutarsız'; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI O3 ' || sqlerrm; kalan := kalan + 1; end;

  select count(*) into n from svc_olaylar where kayit_turu = 'talep' and kayit_id = t_id;
  if n = 3 then rapor := rapor || E'\nGEÇTİ O4 karar geçmişi: oluşturuldu → beklemede → kabul';
  else rapor := rapor || E'\nKALDI O4 talep olay sayısı ' || n; kalan := kalan + 1; end if;

  begin
    set local role service_role;
    perform svc_talep_kabul_et(t_id);
    reset role;
    rapor := rapor || E'\nKALDI O5 talep iki kez kabul edildi'; kalan := kalan + 1;
  exception when others then rapor := rapor || E'\nGEÇTİ O5 bir talepten ikinci iş açılamaz'; end;

  begin
    set local role service_role;
    update svc_talepler set durum = 'red' where id = t_id;
    reset role;
    rapor := rapor || E'\nKALDI O6 kabul geri alındı'; kalan := kalan + 1;
  exception when others then rapor := rapor || E'\nGEÇTİ O6 kabul geri alınamaz'; end;

  begin
    set local role service_role;
    insert into svc_isler (baslik, hizmet_turu) values ('Depo düzeni', 'diger') returning id into kendi_is;
    insert into svc_gorevler (baslik) values ('Fatura kes');
    insert into svc_gorevler (baslik, tur, periyot, hedef_deger, hedef_birim) values ('Haftalık iş', 'hedef', 'hafta', 8, 'iş');
    insert into svc_notlar (icerik, tur) values ('Knipex pense bakım', 'kisisel');
    reset role;
    rapor := rapor || E'\nGEÇTİ O7 talepsiz iş, işe bağsız görev/hedef/not açılabiliyor';
  exception when others then rapor := rapor || E'\nKALDI O7 ' || sqlerrm; kalan := kalan + 1; end;

  -- Başka müşterinin adresi bu işe bağlanamaz.
  begin
    select id into t2_id from svc_talepler where telefon = '905320000001';
    set local role service_role;
    perform svc_talep_kabul_et(t2_id);
    update svc_isler set adres_id = (select a.id from svc_adresler a join svc_musteriler m on m.id = a.musteri_id
                                     where m.telefon = '905321112233' limit 1)
     where talep_id = t2_id;
    reset role;
    rapor := rapor || E'\nKALDI O8 başka müşterinin adresi bağlandı'; kalan := kalan + 1;
  exception when foreign_key_violation then rapor := rapor || E'\nGEÇTİ O8 iş yalnız kendi müşterisinin adresini alır'; end;

  begin
    set local role service_role;
    update svc_olaylar set aciklama = 'x' where kayit_id = t_id;
    reset role;
    rapor := rapor || E'\nKALDI O9 olay kaydı değişti'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O9 olay kaydı sunucu için de silinemez/değişmez'; end;

  begin
    set local role service_role;
    pay := svc_paylasim_olustur(is_id, array['ozel_not']);
    reset role;
    rapor := rapor || E'\nKALDI O10 izinsiz alan paylaşıldı'; kalan := kalan + 1;
  exception when check_violation then rapor := rapor || E'\nGEÇTİ O10 beyaz liste dışı alan paylaşılamaz'; end;

  -- ═══ PAYLAŞIM LİNKİ ═══
  begin
    set local role service_role;
    update svc_isler set musteri_aciklamasi = 'Yarın 10:00', rapor_ozeti = 'gizli rapor' where id = is_id;
    pay := svc_paylasim_olustur(is_id, array['baslik','asama','musteri_aciklamasi'], 7, 'Ali Bey');
    reset role;
  exception when others then rapor := rapor || E'\nKALDI P0 ' || sqlerrm; kalan := kalan + 1; end;

  if exists (select 1 from svc_paylasimlar where token_hash = pay->>'token') then
    rapor := rapor || E'\nKALDI P1 düz token saklanıyor'; kalan := kalan + 1;
  else rapor := rapor || E'\nGEÇTİ P1 veritabanında yalnız token özeti var'; end if;

  begin
    set local role anon;
    r := svc_paylasim_oku(kapi, pay->>'token');
    reset role;
    if (select array_agg(k order by k) from jsonb_object_keys(r->'alanlar') k) = array['asama','baslik','musteri_aciklamasi']
       and r::text not like '%gizli rapor%' and r::text not like '%905321112233%' and r::text not like '%Priz yanık%'
    then rapor := rapor || E'\nGEÇTİ P2 link yalnız seçilen 3 alanı gösteriyor (iç açıklama, rapor, telefon yok)';
    else rapor := rapor || E'\nKALDI P2 dönüş: ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI P2 ' || sqlerrm; kalan := kalan + 1; end;

  begin
    set local role anon;
    r := svc_paylasim_oku('yanlis', pay->>'token');
    reset role;
    rapor := rapor || E'\nKALDI P3 kapısız okuma'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ P3 link de kapı anahtarı olmadan okunamaz'; end;

  if (select erisim_sayisi from svc_paylasimlar where id = (pay->>'id')::uuid) = 1 then
    rapor := rapor || E'\nGEÇTİ P4 erişim sayıldı';
  else rapor := rapor || E'\nKALDI P4 erişim sayacı'; kalan := kalan + 1; end if;

  begin
    set local role service_role;
    pay2 := svc_paylasim_olustur(is_id, array['asama'], 3);
    reset role;
    update svc_paylasimlar set created_at = now() - interval '5 days', son_gecerlilik = now() - interval '1 day'
     where id = (pay2->>'id')::uuid;
    set local role anon;
    r := svc_paylasim_oku(kapi, pay2->>'token');
    reset role;
    if r is null then rapor := rapor || E'\nGEÇTİ P5 süresi dolan link boş döner';
    else rapor := rapor || E'\nKALDI P5'; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI P5 ' || sqlerrm; kalan := kalan + 1; end;

  begin
    set local role service_role;
    perform svc_paylasim_iptal((pay->>'id')::uuid);
    reset role;
    set local role anon;
    r := svc_paylasim_oku(kapi, pay->>'token');
    reset role;
    if r is null then rapor := rapor || E'\nGEÇTİ P6 iptal edilen link boş döner';
    else rapor := rapor || E'\nKALDI P6'; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI P6 ' || sqlerrm; kalan := kalan + 1; end;

  begin
    set local role service_role;
    update svc_paylasimlar set iptal_at = null where id = (pay->>'id')::uuid;
    reset role;
    rapor := rapor || E'\nKALDI P7 iptal geri alındı'; kalan := kalan + 1;
  exception when others then rapor := rapor || E'\nGEÇTİ P7 iptal geri alınamaz'; end;

  perform setval('public.svc_talep_no_seq', s_talep, c_talep);
  perform setval('public.svc_is_no_seq', s_is, c_is);
  perform setval(olay_seq, s_olay, c_olay);
  raise exception 'BEE_TEST_SONUC kalan=% %', kalan, rapor;
end $$;
