-- 0005 testi: parola doğrulaması ve oturum DB'de. Tek DO bloğu, sonda kasıtlı raise → iz kalmaz.
-- Beklenen çıktı: "BEE_TEST_SONUC kalan=0". Oturum başlığı PostgREST'teki gibi request.headers ile taklit edilir.
do $$
declare
  rapor text := ''; kalan int := 0;
  k_sahip constant text := 'test-sahip-anahtari';
  salt constant text := repeat('ab', 16);
  dk constant text := repeat('5a', 32);            -- PBKDF2 çıktısını temsil eder (sunucuda üretilir)
  yanlis constant text := repeat('00', 32);
  r jsonb; tok text; n int;
begin
  insert into svc_ayarlar (anahtar, deger) values ('sahip_hash', encode(sha256(convert_to(k_sahip, 'UTF8')), 'hex'))
  on conflict (anahtar) do update set deger = excluded.deger;

  -- Kurulum anahtar-yalnız çalışmalı (henüz oturum yok)
  begin
    set local role anon;
    perform svc_s_sifre_kur(k_sahip, encode(sha256(decode(dk, 'hex')), 'hex'), salt, 600000);
    r := svc_s_kurulum_baslat(k_sahip);
    reset role;
    if r->>'kurulu' = 'true' then rapor := rapor || E'\nGEÇTİ K1 kurulum oturumsuz çalışıyor';
    else rapor := rapor || E'\nKALDI K1 ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI K1 ' || sqlerrm; kalan := kalan + 1; end;

  if (select password_hash from svc_giris where id = 1) <> dk then rapor := rapor || E'\nGEÇTİ K2 türetilmiş anahtar saklanmıyor, yalnız özeti';
  else rapor := rapor || E'\nKALDI K2 türetilmiş anahtar düz saklanıyor'; kalan := kalan + 1; end if;

  begin
    set local role anon;
    r := svc_s_giris_baslat(k_sahip);
    reset role;
    if r ? 'salt' and r ? 'iterasyon' and not r ? 'hash' and r::text not like '%' || encode(sha256(decode(dk, 'hex')), 'hex') || '%'
    then rapor := rapor || E'\nGEÇTİ G1 giriş başlangıcı özeti döndürmüyor';
    else rapor := rapor || E'\nKALDI G1 ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI G1 ' || sqlerrm; kalan := kalan + 1; end;

  if to_regprocedure('public.svc_s_giris_basarili(text)') is null then rapor := rapor || E'\nGEÇTİ G2 parolasız "giriş başarılı" kapısı kaldırıldı';
  else rapor := rapor || E'\nKALDI G2 svc_s_giris_basarili hâlâ var'; kalan := kalan + 1; end if;

  -- Oturumsuz sahip çağrısı reddedilir (anahtar doğru olsa bile)
  begin
    set local role anon;
    perform svc_s_ozet(k_sahip);
    reset role;
    rapor := rapor || E'\nKALDI O1 oturumsuz sahip çağrısı geçti'; kalan := kalan + 1;
  exception when insufficient_privilege then
    if sqlerrm like 'BEE_OTURUM%' then rapor := rapor || E'\nGEÇTİ O1 anahtar tek başına yetmiyor (oturum gerekli)';
    else rapor := rapor || E'\nKALDI O1 ' || sqlerrm; kalan := kalan + 1; end if;
  end;

  -- 5 yanlış deneme → kilit; kilitliyken doğru anahtar da reddedilir
  begin
    set local role anon;
    for i in 1..4 loop r := svc_s_giris_tamamla(k_sahip, yanlis); end loop;
    r := svc_s_giris_tamamla(k_sahip, yanlis);
    reset role;
    if r->>'neden' = 'kilitlendi' then rapor := rapor || E'\nGEÇTİ G3 5. yanlış denemede kilit';
    else rapor := rapor || E'\nKALDI G3 ' || r::text; kalan := kalan + 1; end if;
    set local role anon;
    r := svc_s_giris_tamamla(k_sahip, dk);
    reset role;
    if r->>'neden' = 'kilitli' and not r ? 'oturum' then rapor := rapor || E'\nGEÇTİ G4 kilitliyken doğru parola da oturum vermiyor';
    else rapor := rapor || E'\nKALDI G4 ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI G3/G4 ' || sqlerrm; kalan := kalan + 1; end;

  update svc_giris set kilit_bitis = null, hata_sayisi = 0 where id = 1;

  begin
    set local role anon;
    r := svc_s_giris_tamamla(k_sahip, dk, 'test');
    reset role;
    tok := r->>'oturum';
    if r->>'ok' = 'true' and tok ~ '^[0-9a-f]{64}$'
       and not exists (select 1 from svc_oturumlar where token_hash = tok)
       and exists (select 1 from svc_oturumlar where token_hash = encode(sha256(convert_to(tok, 'UTF8')), 'hex'))
    then rapor := rapor || E'\nGEÇTİ G5 doğru parola oturum veriyor; token DB''de yalnız özet';
    else rapor := rapor || E'\nKALDI G5 ' || r::text; kalan := kalan + 1; end if;
  exception when others then rapor := rapor || E'\nKALDI G5 ' || sqlerrm; kalan := kalan + 1; end;

  begin
    perform set_config('request.headers', json_build_object('x-bee-oturum', tok)::text, true);
    set local role anon;
    r := svc_s_ozet(k_sahip);
    reset role;
    rapor := rapor || E'\nGEÇTİ O2 geçerli oturumla sahip çağrısı çalışıyor';
  exception when others then rapor := rapor || E'\nKALDI O2 ' || sqlerrm; kalan := kalan + 1; end;

  begin
    perform set_config('request.headers', json_build_object('x-bee-oturum', tok)::text, true);
    set local role anon;
    perform svc_s_ozet('yanlis-anahtar');
    reset role;
    rapor := rapor || E'\nKALDI O3 oturum var ama anahtar yanlışken geçti'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O3 oturum tek başına da yetmiyor (anahtar gerekli)'; end;

  begin
    perform set_config('request.headers', json_build_object('x-bee-oturum', repeat('f', 64))::text, true);
    set local role anon;
    perform svc_s_ozet(k_sahip);
    reset role;
    rapor := rapor || E'\nKALDI O4 uydurma oturumla geçti'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O4 uydurma oturum reddedildi'; end;

  begin
    update svc_oturumlar set bitis = now() - interval '1 minute';
    perform set_config('request.headers', json_build_object('x-bee-oturum', tok)::text, true);
    set local role anon;
    perform svc_s_ozet(k_sahip);
    reset role;
    rapor := rapor || E'\nKALDI O5 süresi dolmuş oturumla geçti'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O5 süresi dolan oturum reddedildi'; end;

  update svc_oturumlar set bitis = now() + interval '1 day';
  begin
    perform set_config('request.headers', json_build_object('x-bee-oturum', tok)::text, true);
    set local role anon;
    perform svc_s_cikis(k_sahip);
    perform svc_s_ozet(k_sahip);
    reset role;
    rapor := rapor || E'\nKALDI O6 çıkıştan sonra oturum çalışıyor'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O6 çıkış oturumu gerçekten kapatıyor'; end;

  begin
    set local role anon;
    select count(*) into n from svc_oturumlar;
    reset role;
    rapor := rapor || E'\nKALDI O7 anon oturum tablosunu okudu'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O7 anon oturum tablosunu okuyamaz'; end;

  begin
    set local role anon;
    perform svc_oturum_dogrula();
    reset role;
    rapor := rapor || E'\nKALDI O8 iç kapı anon''a açık'; kalan := kalan + 1;
  exception when insufficient_privilege then rapor := rapor || E'\nGEÇTİ O8 iç kapı fonksiyonları anon''a kapalı'; end;

  raise exception 'BEE_TEST_SONUC kalan=% %', kalan, rapor;
end $$;
