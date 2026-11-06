// Herkese açık TEK uç: müşterinin iş linki. Müşteri giriş yapmaz; link_token anahtardır.
// Dönen alanlar bilinçli dar: özel not, telefon, adres DÖNMEZ.
import { applyCors, json, supaSelect } from './_supa.js';

export default async function handler(req, res) {
  applyCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.query.fn !== 'job-status' || req.method !== 'GET') return json(res, 404, { error: 'Bilinmeyen uç' });

  try {
    const token = String(req.query.k || '');
    if (!/^[A-Z2-9]{10,12}$/.test(token)) return json(res, 404, { error: 'Talep bulunamadı' });
    const rows = await supaSelect('svc_jobs',
      `?link_token=eq.${token}&select=job_no,baslik,durum,musteri_notu,planlanan_tarih,updated_at`);
    if (!rows?.length) return json(res, 404, { error: 'Talep bulunamadı' });
    res.setHeader('Cache-Control', 'no-store');
    return json(res, 200, rows[0]);
  } catch (e) {
    return json(res, 500, { error: 'Şu an durum alınamıyor' });
  }
}
