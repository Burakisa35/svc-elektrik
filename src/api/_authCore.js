// Tek kullanıcılı (Burak) parola doğrulama çekirdeği. PBKDF2 + satır-başı rastgele salt (TEHAİ kuralı,
// bkz. tehai/AGENTS.md "Güvenlik" — düz veya sabit paylaşılan salt yasak).
import { pbkdf2Sync, timingSafeEqual, randomBytes } from 'node:crypto';

const ITERS = 100_000;
const HASH_BYTES = 32;

export function hashPassword(pw, salt) {
  return pbkdf2Sync(String(pw), String(salt), ITERS, HASH_BYTES, 'sha256').toString('hex');
}

export function randomSalt(bytes = 16) {
  return randomBytes(bytes).toString('hex');
}

export function credEquals(a, b) {
  try {
    const bufA = Buffer.from(String(a || ''), 'hex');
    const bufB = Buffer.from(String(b || ''), 'hex');
    return bufA.length === bufB.length && bufA.length > 0 && timingSafeEqual(bufA, bufB);
  } catch {
    return false;
  }
}
