// Bağımlılıksız HS256 JWT (npm install yok — Tehai'nin api/_token.js deseniyle aynı mantık).
import { createHmac, timingSafeEqual } from 'node:crypto';

const SECRET = process.env.JWT_SECRET;

function b64u(input) {
  return Buffer.from(input).toString('base64url');
}

export function signToken(payload, ttlSeconds = 8 * 60 * 60) {
  if (!SECRET) throw new Error('JWT_SECRET yok');
  const now = Math.floor(Date.now() / 1000);
  const full = { ...payload, iat: now, exp: now + ttlSeconds };
  const header = b64u(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = b64u(JSON.stringify(full));
  const sig = createHmac('sha256', SECRET).update(`${header}.${body}`).digest('base64url');
  return `${header}.${body}.${sig}`;
}

export function verifyToken(token) {
  if (!SECRET) return { valid: false, error: 'JWT_SECRET yapılandırılmamış' };
  const parts = String(token || '').split('.');
  if (parts.length !== 3) return { valid: false, error: 'Token formatı geçersiz' };

  const [header, body, signature] = parts;
  const expected = createHmac('sha256', SECRET).update(`${header}.${body}`).digest('base64url');
  const givenBuf = Buffer.from(signature);
  const expectedBuf = Buffer.from(expected);
  if (givenBuf.length !== expectedBuf.length || !timingSafeEqual(givenBuf, expectedBuf)) {
    return { valid: false, error: 'İmza geçersiz' };
  }

  let payload;
  try { payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8')); }
  catch { return { valid: false, error: 'Payload geçersiz' }; }

  if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) {
    return { valid: false, error: 'Token süresi dolmuş' };
  }
  return { valid: true, user: payload };
}

export function bearer(req) {
  const h = req.headers?.authorization || '';
  if (h.startsWith('Bearer ')) return h.slice(7);
  const cookie = req.headers?.cookie || '';
  const m = cookie.match(/svc_session=([^;]+)/);
  return m ? decodeURIComponent(m[1]) : '';
}

export function requireSahip(req) {
  const v = verifyToken(bearer(req));
  if (!v.valid) return { ok: false, error: v.error };
  if (v.user.role !== 'sahip') return { ok: false, error: 'Yetki yetersiz' };
  return { ok: true, user: v.user };
}
