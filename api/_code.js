import { randomBytes } from 'node:crypto';

const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // karışan 0/O, 1/I yok

export function randomCode(len = 6) {
  const bytes = randomBytes(len);
  let out = '';
  for (let i = 0; i < len; i++) out += ALPHABET[bytes[i] % ALPHABET.length];
  return out;
}

export function normalizePhone(raw) {
  const digits = String(raw || '').replace(/\D/g, '');
  if (digits.startsWith('905') && digits.length === 12) return digits;
  if (digits.startsWith('5') && digits.length === 10) return `90${digits}`;
  if (digits.startsWith('05') && digits.length === 11) return `9${digits}`;
  return digits;
}

export function isValidPhone(phone) {
  return /^905\d{9}$/.test(phone);
}
