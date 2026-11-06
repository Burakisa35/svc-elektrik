// PostgREST'e çıplak fetch ile erişim — SDK yok (npm install yasak, Tehai api/_supa.js deseni).
// Yalnız service_role: RLS'i bypass eder, bu dosya api/ dışına ASLA import edilmez.
const URL = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

function base() {
  if (!URL || !KEY) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY tanımsız');
  return `${URL}/rest/v1`;
}

function headers(extra = {}) {
  return {
    apikey: KEY,
    Authorization: `Bearer ${KEY}`,
    'Content-Type': 'application/json',
    ...extra,
  };
}

async function handle(res) {
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`Supabase ${res.status}: ${text}`);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

export async function supaSelect(table, query = '') {
  const res = await fetch(`${base()}/${table}${query}`, { headers: headers() });
  return handle(res);
}

export async function supaInsert(table, row, { returning = true } = {}) {
  const res = await fetch(`${base()}/${table}`, {
    method: 'POST',
    headers: headers({ Prefer: returning ? 'return=representation' : 'return=minimal' }),
    body: JSON.stringify(row),
  });
  return handle(res);
}

export async function supaUpdate(table, query, patch) {
  const res = await fetch(`${base()}/${table}${query}`, {
    method: 'PATCH',
    headers: headers({ Prefer: 'return=representation' }),
    body: JSON.stringify(patch),
  });
  return handle(res);
}

export function applyCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PATCH,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

export function json(res, status, body) {
  res.status(status).setHeader('Content-Type', 'application/json').end(JSON.stringify(body));
}
