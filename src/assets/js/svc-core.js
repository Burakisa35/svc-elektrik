export const DURUM_ETIKET = {
  yeni: { ad: 'Yeni', renk: 'amber' },
  planlandi: { ad: 'Planlandı', renk: 'amber' },
  yolda: { ad: 'Yolda', renk: 'amber' },
  devam: { ad: 'Devam Ediyor', renk: 'amber' },
  tamamlandi: { ad: 'Tamamlandı', renk: 'green' },
  iptal: { ad: 'İptal', renk: 'red' },
};

export function escapeHTML(value) {
  const div = document.createElement('div');
  div.textContent = String(value == null ? '' : value);
  return div.innerHTML;
}

export function formatPhoneDisplay(digits) {
  const d = String(digits || '').replace(/\D/g, '');
  if (!d.startsWith('905') || d.length !== 12) return digits;
  return `+90 ${d.slice(2, 5)} ${d.slice(5, 8)} ${d.slice(8, 10)} ${d.slice(10, 12)}`;
}

export async function apiFetch(url, opts = {}) {
  const res = await fetch(url, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...(opts.headers || {}) },
    ...opts,
  });
  const body = await res.json().catch(() => null);
  if (!res.ok) throw new Error(body?.error || `İstek başarısız (${res.status})`);
  return body;
}
