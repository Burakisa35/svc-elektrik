-- BEE iş testleri — AKTIF.md dilim 1 (K2 iş açma, K3 tamamlama, K4 yeniden okuma) DB katmanında.
-- Çalıştırma: yerel (yerel-kurulum.sh) ya da canlıda MCP execute_sql (proje uwmbtaxxdcjumxbnigpy).
-- Tek DO bloğu; sonunda KASITLI raise ile her şey geri alınır. Sayaçlar transaction'a bağlı değildir:
-- gövde hata verse bile önce setval ile geri yüklenir (db-erisim.sql'de gövde hatası geri yüklemeyi atlıyordu).
-- Beklenen çıktı: "BEE_TEST_SONUC kalan=0 ...". Eşzamanlı tekrar deneme ayrı: yaris-is.sh (iki oturum ister).
do $$
declare
  rapor text := ''; kalan int := 0; hata text;
  k_sahip constant text := 'test-sahip-anahtari';
  tok constant text := repeat('e', 64);
  u1 constant text := '6f1d2c3b-0000-4000-8000-000000000001';
  r jsonb; v1 uuid; v2 uuid; d text; a text; b timestamptz;
  olay_seq constant text := pg_get_serial_sequence('public.svc_olaylar', 'id');
  s_is bigint; c_is boolean; s_olay bigint; c_olay boolean;
begin
  select last_value, is_called into s_is, c_is from public.svc_is_no_seq;
  execute format('select last_value, is_called from %s', olay_seq) into s_olay, c_olay;
  begin
    insert into svc_ayarlar (anahtar, deger) values ('sahip_hash', encode(sha256(convert_to(k_sahip, 'UTF8')), 'hex'))
    on conflict (anahtar) do update set deger = excluded.deger;
    insert into svc_oturumlar (token_hash, bitis) values (encode(sha256(convert_to(tok, 'UTF8')), 'hex'), now() + interval '1 day');
    perform set_config('request.headers', json_build_object('x-bee-oturum', tok)::text, true);

    -- K2: yalnız telefonla iş açılır, telefon 905 biçiminde saklanır
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"musteri":{"telefon":"0532 111 22 33"}}');
      reset role;
      if exists (select 1 from svc_isler i join svc_musteriler m on m.id = i.musteri_id where i.id = v1 and m.telefon = '905321112233')
      then rapor := rapor || E'\nGEÇTİ I1 yalnız telefonla iş açıldı (telefon 905 biçiminde)';
      else rapor := rapor || E'\nKALDI I1 iş ya da müşteri beklendiği gibi değil'; kalan := kalan + 1; end if;
    exception when others then rapor := rapor || E'\nKALDI I1 ' || sqlerrm; kalan := kalan + 1; end;

    -- K2: aynı istemci_id ile ikinci çağrı aynı işi döndürür (sıralı tekrar deneme)
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, jsonb_build_object('istemci_id', u1, 'aciklama', 'tekrar'));
      v2 := svc_s_is_olustur(k_sahip, jsonb_build_object('istemci_id', u1, 'aciklama', 'tekrar'));
      reset role;
      if v1 = v2 and (select count(*) from svc_isler where istemci_id = u1::uuid) = 1
      then rapor := rapor || E'\nGEÇTİ I2 tekrar deneme aynı işi döndürdü, tek kayıt';
      else rapor := rapor || E'\nKALDI I2 tekrar deneme ikinci kayıt ya da farklı id'; kalan := kalan + 1; end if;
    exception when others then rapor := rapor || E'\nKALDI I2 ' || sqlerrm; kalan := kalan + 1; end;

    -- K2: boş istemci_id "yok" sayılır, iş açılır (ADAYLAR A1: 22P02 ile düşüyordu)
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"istemci_id":"","aciklama":"bos istemci"}');
      reset role;
      if v1 is not null and (select istemci_id from svc_isler where id = v1) is null
      then rapor := rapor || E'\nGEÇTİ I3 boş istemci_id işi düşürmüyor';
      else rapor := rapor || E'\nKALDI I3 boş istemci_id'; kalan := kalan + 1; end if;
    exception when others then rapor := rapor || E'\nKALDI I3 ' || sqlerrm; kalan := kalan + 1; end;

    -- K2: biçimi bozuk istemci_id alan adıyla reddedilir (API bunu ekrana "hangi alan" diye eşler)
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"istemci_id":"abc","aciklama":"bozuk istemci"}');
      reset role;
      rapor := rapor || E'\nKALDI I4 bozuk istemci_id kabul edildi'; kalan := kalan + 1;
    exception when others then
      if sqlerrm like 'BEE_GECERSIZ: istemci_id%' then rapor := rapor || E'\nGEÇTİ I4 bozuk istemci_id alan adıyla reddedildi';
      else rapor := rapor || E'\nKALDI I4 ' || sqlerrm; kalan := kalan + 1; end if;
    end;

    -- K3 + K4: tamamlanan iş kapanır, yeniden okununca da kapalıdır ve doğru listededir
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"aciklama":"tamamlanacak"}');
      perform svc_s_is_guncelle(k_sahip, v1, '{"asama":"tamamlandi"}');
      r := svc_s_is(k_sahip, v1);
      reset role;
      select durum, asama, bitis_at into d, a, b from svc_isler where id = v1;
      if d = 'kapandi' and a = 'tamamlandi' and b is not null and r::text like '%kapandi%'
      then rapor := rapor || E'\nGEÇTİ I5 tamamlanan iş kapandı, yeniden okumada da kapalı';
      else rapor := rapor || E'\nKALDI I5 durum=' || coalesce(d, '?') || ' asama=' || coalesce(a, '?'); kalan := kalan + 1; end if;
      set local role anon;
      if (select svc_s_isler(k_sahip, 'kapali'))::text like '%' || v1 || '%'
         and (select svc_s_isler(k_sahip, 'acik'))::text not like '%' || v1 || '%'
      then rapor := rapor || E'\nGEÇTİ I6 tamamlanan iş kapalı listesinde, açık listesinde yok';
      else rapor := rapor || E'\nKALDI I6 liste tutarsız'; kalan := kalan + 1; end if;
      reset role;
    exception when others then rapor := rapor || E'\nKALDI I5/I6 ' || sqlerrm; kalan := kalan + 1; end;

    -- K3: çelişkili istek (tamamlandı + iptal) reddedilir, iş değişmez (ADAYLAR C3: sessizce "kapandi" oluyordu)
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"aciklama":"celiski"}');
      begin
        perform svc_s_is_guncelle(k_sahip, v1, '{"asama":"tamamlandi","durum":"iptal"}');
        hata := null;
      exception when others then hata := sqlerrm; end;
      reset role;
      select durum, asama into d, a from svc_isler where id = v1;
      if hata like 'BEE_GECERSIZ%' and d = 'acik' and a = 'planlama'
      then rapor := rapor || E'\nGEÇTİ I7 çelişkili istek reddedildi, iş değişmedi';
      else rapor := rapor || E'\nKALDI I7 hata=' || coalesce(hata, 'yok') || ' durum=' || d || ' asama=' || a; kalan := kalan + 1; end if;
    exception when others then rapor := rapor || E'\nKALDI I7 ' || sqlerrm; kalan := kalan + 1; end;

    -- K3: tutarlı çift (tamamlandı + kapandı) kabul edilir
    begin
      set local role anon;
      v1 := svc_s_is_olustur(k_sahip, '{"aciklama":"tutarli"}');
      perform svc_s_is_guncelle(k_sahip, v1, '{"asama":"tamamlandi","durum":"kapandi"}');
      reset role;
      if (select durum = 'kapandi' and asama = 'tamamlandi' from svc_isler where id = v1)
      then rapor := rapor || E'\nGEÇTİ I8 tutarlı tamamlandı + kapandı kabul edildi';
      else rapor := rapor || E'\nKALDI I8 tutarlı çift reddedildi ya da değişti'; kalan := kalan + 1; end if;
    exception when others then rapor := rapor || E'\nKALDI I8 ' || sqlerrm; kalan := kalan + 1; end;

  exception when others then rapor := rapor || E'\nKALDI GOVDE ' || sqlerrm; kalan := kalan + 1;
  end;
  perform setval('public.svc_is_no_seq', s_is, c_is);
  perform setval(olay_seq, s_olay, c_olay);
  raise exception 'BEE_TEST_SONUC kalan=% %', kalan, rapor;
end $$;
