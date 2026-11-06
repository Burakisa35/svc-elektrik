// Burak'ın kendi paneli (tek kullanıcı, rol sistemi yok). İşi yalnız Burak açar;
// müşteri sisteme girmez, yalnız işe özel linki (/is?k=...) görür.
// svc_giris tek satırlık tablo; PANEL_ILK_SIFRE ilk girişte bu satırı oluşturur.
import { applyCors, json, supaSelect, supaInsert, supaUpdate } from './_supa.js';
import { hashPassword, randomSalt, credEquals } from './_authCore.js';
import { signToken, requireSahip } from './_jwt.js';
import { randomCode, normalizePhone, isValidPhone } from './_code.js';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const TARIH = /^\d{4}-\d{2}-\d{2}$/;
const DURUMLAR = ['yeni', 'planlandi', 'yolda', 'devam', 'tamamlandi', 'iptal'];
const MAX_HATA = 5;
const KILIT_TABAN_MS = 15 * 60 * 1000;
const KILIT_TAVAN_MS = 24 * 60 * 60 * 1000;

export default async function handler(req, res) {
  applyCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();

  const fn = req.query.fn;
  try {
    if (fn === 'login' && req.method === 'POST') return await login(req, res);

    const auth = requireSahip(req);
    if (!auth.ok) return json(res, 401, { error: auth.error });

    if (fn === 'jobs' && req.method === 'GET') return await listJobs(req, res);
    if (fn === 'job-create' && req.method === 'POST') return await createJob(req, res);
    if (fn === 'job-update' && req.method === 'PATCH') return await updateJob(req, res);
    if (fn === 'tasks' && req.method === 'GET') return await listTasks(req, res);
    if (fn === 'task-upsert' && req.method === 'POST') return await upsertTask(req, res);
    return json(res, 404, { error: 'Bilinmeyen uç' });
  } catch (e) {
    return json(res, 500, { error: e.message });
  }
}

async function login(req, res) {
  let [row] = await supaSelect('svc_giris', '?select=*&limit=1') || [];
  if (!row) {
    const ilk = process.env.PANEL_ILK_SIFRE;
    if (!ilk) return json(res, 500, { error: 'Panel şifresi kurulmamış (PANEL_ILK_SIFRE tanımsız)' });
    const salt = randomSalt();
    [row] = await supaInsert('svc_giris', { id: 1, password_hash: hashPassword(ilk, salt), salt });
  }

  if (row.kilit_bitis && new Date(row.kilit_bitis) > new Date()) {
    return json(res, 429, { error: 'Çok fazla hatalı deneme. Daha sonra tekrar deneyin.' });
  }

  const { password } = req.body || {};
  if (!credEquals(hashPassword(password || '', row.salt), row.password_hash)) {
    const hata = (row.hata_sayisi || 0) + 1;
    const patch = { hata_sayisi: hata };
    if (hata >= MAX_HATA) {
      const tur = (row.kilit_sayisi || 0) + 1;
      patch.kilit_sayisi = tur;
      patch.hata_sayisi = 0;
      patch.kilit_bitis = new Date(Date.now() + Math.min(KILIT_TABAN_MS * 2 ** (tur - 1), KILIT_TAVAN_MS)).toISOString();
    }
    await supaUpdate('svc_giris', '?id=eq.1', patch);
    return json(res, 401, { error: 'Şifre hatalı' });
  }

  await supaUpdate('svc_giris', '?id=eq.1', { hata_sayisi: 0, kilit_sayisi: 0, kilit_bitis: null });
  const token = signToken({ role: 'sahip' });
  res.setHeader('Set-Cookie', `svc_session=${token}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=28800`);
  return json(res, 200, { ok: true });
}

async function listJobs(req, res) {
  const durum = req.query.durum;
  const filter = DURUMLAR.includes(durum) ? `&durum=eq.${durum}` : '';
  const rows = await supaSelect('svc_jobs',
    `?select=*,svc_customers(ad,soyad,telefon,ilce,mahalle,adres_detay,kat,daire)&order=created_at.desc${filter}`);
  return json(res, 200, rows);
}

async function findOrCreateCustomer(b) {
  const telefon = normalizePhone(b.telefon);
  if (!isValidPhone(telefon)) throw Object.assign(new Error('Telefon geçersiz (05XX XXX XX XX)'), { status: 400 });
  const [existing] = await supaSelect('svc_customers', `?telefon=eq.${telefon}&limit=1`) || [];
  if (existing) return existing;
  if (!b.ad || !b.soyad) throw Object.assign(new Error('Yeni müşteri için ad ve soyad gerekli'), { status: 400 });
  const [created] = await supaInsert('svc_customers', {
    ad: b.ad, soyad: b.soyad, telefon,
    ilce: b.ilce || null, mahalle: b.mahalle || null,
    adres_detay: b.adres_detay || null, kat: b.kat || null, daire: b.daire || null,
  });
  return created;
}

async function createJob(req, res) {
  const b = req.body || {};
  if (!b.baslik) return json(res, 400, { error: 'İş başlığı gerekli' });

  let customer;
  try { customer = await findOrCreateCustomer(b); }
  catch (e) { return json(res, e.status || 500, { error: e.message }); }

  for (let i = 0; i < 5; i++) {
    try {
      const [created] = await supaInsert('svc_jobs', {
        job_no: `BE-${randomCode(5)}`, link_token: randomCode(12),
        customer_id: customer.id, baslik: b.baslik, aciklama: b.aciklama || null,
        planlanan_tarih: b.planlanan_tarih || null,
      });
      return json(res, 201, { ...created, svc_customers: customer });
    } catch (e) {
      if (!String(e.message).includes('23505')) throw e;
    }
  }
  return json(res, 500, { error: 'Kayıt oluşturulamadı, tekrar deneyin' });
}

async function updateJob(req, res) {
  const { id, ...patch } = req.body || {};
  if (!UUID.test(String(id))) return json(res, 400, { error: 'id geçersiz' });
  if ('durum' in patch && !DURUMLAR.includes(patch.durum)) return json(res, 400, { error: 'durum geçersiz' });

  if (patch.durum) {
    const [current] = await supaSelect('svc_jobs', `?id=eq.${id}&select=durum`) || [];
    if (current && current.durum !== patch.durum) {
      await supaInsert('svc_job_durum_log',
        { job_id: id, eski_durum: current.durum, yeni_durum: patch.durum }, { returning: false });
    }
  }

  const allowed = ['durum', 'ozel_not', 'musteri_notu', 'planlanan_tarih', 'baslik', 'aciklama'];
  const safePatch = {};
  for (const k of allowed) if (k in patch) safePatch[k] = patch[k];

  const [updated] = await supaUpdate('svc_jobs', `?id=eq.${id}`, safePatch) || [];
  return json(res, 200, updated);
}

async function listTasks(req, res) {
  const tarih = TARIH.test(String(req.query.tarih)) ? req.query.tarih : bugun();
  const rows = await supaSelect('svc_tasks', `?tarih=eq.${tarih}&order=created_at.asc`);
  return json(res, 200, rows);
}

async function upsertTask(req, res) {
  const b = req.body || {};
  if (b.id != null) {
    if (!/^\d+$/.test(String(b.id))) return json(res, 400, { error: 'id geçersiz' });
    const patch = {};
    if (b.metin != null) patch.metin = String(b.metin);
    if (b.tamam != null) patch.tamam = Boolean(b.tamam);
    const [updated] = await supaUpdate('svc_tasks', `?id=eq.${b.id}`, patch) || [];
    return json(res, 200, updated);
  }
  if (!b.metin) return json(res, 400, { error: 'Metin gerekli' });
  const [created] = await supaInsert('svc_tasks', {
    metin: String(b.metin),
    tur: b.tur === 'hedef' ? 'hedef' : 'not',
    tarih: TARIH.test(String(b.tarih)) ? b.tarih : bugun(),
  });
  return json(res, 201, created);
}

// Vercel UTC çalışır; gün sınırı Türkiye saatine göre (UTC+3) olmalı.
function bugun() {
  return new Date(Date.now() + 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
}
