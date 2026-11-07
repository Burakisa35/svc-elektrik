// Supabase MCP apply_migration'ın onay sorusu çıkarıp çıkarmayacağını UYGULAMADAN tahmin eder.
// Neden: soru, oturumun koştuğu yerde (bu bulut konteyneri) çıkar, Burak'ın telefonuna ulaşmaz ve araç
// 230 sn sonra zaman aşımına uğrar (supabase/supabase PR 53018). Soru çıkaracak dosya bu oturumdan uygulanamaz.
// Kural (supabase/mcp destructive-sql.ts, Studio'dan uyarlanmış): yorumlar atılır, metin ';' ile bölünür
// (fonksiyon gövdesi DAHİL), bir ifade DROP / DELETE / TRUNCATE ile başlıyorsa ya da
// "alter table … drop column" içeriyorsa soru çıkar. "then delete …" gibi ifade ortasındaki silme yakalanmaz.
// Güven: Orta. Bu, sunucu kodunun yaklaşık taklididir. 2026-11-07'deki 6 gözlemin 6'sıyla tutarlı:
// 0000–0002 ve bölünmüş 0004 sorusuz, eski 0004 ile 0005 soruda kaldı.
// Kullanım: node araclar/mcp-soru-tahmini.mjs [dosya.sql ...]   (varsayılan: supabase/migrations/*.sql)
import { readFileSync, readdirSync } from 'node:fs';

const dosyalar = process.argv.length > 2
  ? process.argv.slice(2)
  : readdirSync('supabase/migrations').filter(f => f.endsWith('.sql')).sort().map(f => `supabase/migrations/${f}`);

for (const yol of dosyalar) {
  const sql = readFileSync(yol, 'utf8').replace(/--[^\n]*/g, '').replace(/\/\*[\s\S]*?\*\//g, '');
  const bulgu = [];
  for (const ifade of sql.split(';')) {
    const m = ifade.match(/^\s*(drop|delete|truncate)\b[^\n]*/i);
    if (m) bulgu.push(m[0].trim().slice(0, 60));
    if (/^\s*alter\s+table[\s\S]*\bdrop\s+column\b/i.test(ifade)) bulgu.push('alter table … drop column');
  }
  console.log(`${bulgu.length ? 'SORU ÇIKAR' : 'sorusuz   '}  ${yol.split('/').pop()}${bulgu.length ? '  ← ' + bulgu.join(' | ') : ''}`);
}
