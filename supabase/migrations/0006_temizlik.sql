-- 0006_temizlik.sql — Yalnız silme/değiştirme adımları. Bilerek küçük tutuldu: Supabase onay penceresi DROP
-- içeren migration'da çıkar; büyük dosyada pencere Burak'a ulaşmadı (0004, 5 deneme).
-- Veri etkisi: bütün svc_ tabloları 0 satır (uygulamadan önce yeniden ölçülür). Silinen fonksiyonların çağıranı yok.
select public.svc_kimlik_dogrula('uwmbtaxxdcjumxbnigpy');

-- İş durumları: 'beklemede' kalkar ('ertelendi' ile aynı anlam; neden 'engel'de), 'kacirildi' eklenir.
alter table public.svc_isler drop constraint svc_isler_durum_check;
alter table public.svc_isler add constraint svc_isler_durum_check
  check (durum in ('acik','ertelendi','kapandi','iptal','kacirildi'));

-- Eski 13 parametreli talep fonksiyonu (0004'teki 14 parametreli sürüm yerini aldı).
drop function public.svc_talep_olustur(text,text,text,text,text,text,text,text,text,text,text,text,text);

-- 0003'ün parolasız giriş kapısı ve artık kullanılmayan sürüm okuyucu (0005 oturumu DB'ye taşıdı).
drop function public.svc_s_giris_basarili(text);
drop function public.svc_s_oturum_surumu(text);
