// araclar/teshis/T-*.md teşhis kayıtlarını denetler. Amaç: ölçülmeyen nedenin "kesin" yazılmasını mekanik olarak engellemek.
// Kurallar (_SABLON.md; yöntem .claude/skills/kod-analizi/SKILL.md): 10 zorunlu bölüm (9 protokol adımı + eleştirel
// sorular) · Kanıt'ta en az bir `…` referansı · RCA nedenleri ADAY/DOĞRULANDI/ELENDİ, ADAY dışındaki her neden ölçümlü ·
// 5 Neden'in her halkasında "test:" · Ishikawa'da 6 daldan en az 4'ü dolu · FMEA puanları 1–5 ve RPN = Ş×O×T ·
// 7 eleştirel soru cevaplı · KAPANDI için en az bir DOĞRULANDI, dolu Düzeltme ve Öğrenim.
// Kullanım: node araclar/teshis.mjs [dizin]   (varsayılan araclar/teshis). Çıkış kodu = kalan kayıt sayısı.
import { readFileSync, readdirSync } from 'node:fs';

const dizin = process.argv[2] || 'araclar/teshis';
const ZORUNLU = ['Belirti', 'Kanıt', 'Ishikawa', '5 Neden', 'RCA', 'FMEA', 'Düzeltme', 'Doğrulama', 'Öğrenim', 'Eleştirel sorular'];
const DALLAR = ['Arayüz', 'Veri', 'İş mantığı', 'Entegrasyon', 'Mimari', 'Test'];
const BOS = /^\s*(—|-|–)?\s*$/;
const hucreler = satir => satir.split('|').slice(1, -1).map(h => h.trim());

let kalan = 0;
const kayitlar = readdirSync(dizin).filter(f => /^T-\d{3}.*\.md$/.test(f)).sort();
for (const ad of kayitlar) {
  const md = readFileSync(`${dizin}/${ad}`, 'utf8');
  const sorun = [];
  const bolum = {};
  for (const parca of md.split(/^## /m).slice(1)) {
    const [baslik, ...govde] = parca.split('\n');
    bolum[baslik.trim()] = govde.join('\n').trim();
  }
  for (const z of ZORUNLU) if (!bolum[z]) sorun.push(`bölüm yok ya da boş: ${z}`);

  const durum = md.match(/Durum:\s*(AÇIK|KAPANDI)\b/)?.[1];
  if (!durum) sorun.push('Durum: AÇIK | KAPANDI satırı yok');

  if (bolum['Kanıt'] && !/`[^`]+`/.test(bolum['Kanıt'])) sorun.push('Kanıt: `dosya:satır` ya da komut referansı yok');

  const nedenler = (bolum['RCA'] || '').split('\n').filter(s => /^\|\s*N\d+/.test(s)).map(hucreler);
  if (!nedenler.length) sorun.push('olası neden tablosu boş');
  for (const [no, , d, guven, olcum] of nedenler) {
    if (!['ADAY', 'DOĞRULANDI', 'ELENDİ'].includes(d)) sorun.push(`${no}: durum "${d}" geçersiz`);
    if (!['Yüksek', 'Orta', 'Doğrulanmadı'].includes(guven)) sorun.push(`${no}: güven "${guven}" geçersiz`);
    if (d !== 'ADAY' && BOS.test(olcum || '')) sorun.push(`${no}: ${d} ama ölçüm yok`);
    if (d !== 'ADAY' && guven === 'Doğrulanmadı') sorun.push(`${no}: ${d} ile "Doğrulanmadı" çelişiyor`);
  }
  if (durum === 'KAPANDI' && !nedenler.some(n => n[2] === 'DOĞRULANDI')) sorun.push('KAPANDI ama DOĞRULANDI neden yok');
  for (const b of ['Düzeltme', 'Öğrenim']) if (durum === 'KAPANDI' && BOS.test(bolum[b] || '')) sorun.push(`KAPANDI ama ${b} boş`);

  const sorular = (bolum['Eleştirel sorular'] || '').split('\n').filter(s => /^[1-7]\.\s*\S/.test(s));
  if (bolum['Eleştirel sorular'] && sorular.length < 7) sorun.push(`Eleştirel sorular: ${sorular.length}/7 cevaplı`);

  const halkalar = (bolum['5 Neden'] || '').split('\n').filter(s => /^\d+\./.test(s));
  if (!halkalar.length) sorun.push('5 Neden zinciri yok');
  halkalar.forEach((h, i) => { if (!/\btest:/.test(h)) sorun.push(`5 Neden ${i + 1}. halka: "test:" yok`); });

  const dolu = DALLAR.filter(d => new RegExp(`^- ${d}:\\s*\\S`, 'm').test(bolum['Ishikawa'] || ''));
  if (dolu.length < 4) sorun.push(`Ishikawa: ${dolu.length}/6 dal dolu (en az 4)`);

  const fmea = (bolum['FMEA'] || '').split('\n').filter(s => /^\|\s*F\d+/.test(s)).map(hucreler);
  if (!fmea.length) sorun.push('FMEA tablosu boş');
  for (const [no, , s, o, t, rpn] of fmea) {
    const [S, O, T, R] = [s, o, t, rpn].map(Number);
    if (![S, O, T].every(x => Number.isInteger(x) && x >= 1 && x <= 5)) sorun.push(`${no}: Ş/O/T 1–5 değil`);
    else if (R !== S * O * T) sorun.push(`${no}: RPN ${rpn} ≠ ${S * O * T}`);
  }

  if (sorun.length) { kalan++; console.log(`KALDI  ${ad} — ${sorun.join(' · ')}`); }
  else console.log(`GEÇTİ  ${ad} (${durum}; ${nedenler.length} neden, ${nedenler.filter(n => n[2] === 'ADAY').length} ADAY)`);
}
if (!kayitlar.length) console.log('kayıt yok');
process.exit(kalan);
