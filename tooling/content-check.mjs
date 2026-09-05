import fs from 'node:fs';import {execFileSync} from 'node:child_process';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json','utf8'));
const pin=execFileSync('git',['-C','pbr-book-website','rev-parse','HEAD'],{encoding:'utf8'}).trim();
const errors=[];if(pin!==inv.upstream_commit)errors.push('Original book revision differs from audit baseline');
const files=execFileSync('git',['ls-files','*.typ'],{encoding:'utf8'}).trim().split('\n');
for(const f of files){const s=fs.readFileSync(f,'utf8');if(/[\x00-\x08\x0B\x0C\x0E-\x1F]/.test(s))errors.push(`${f}: invalid control character`)}
for(const p of inv.pages){if(!fs.existsSync('pbr-book-website/'+p.source))errors.push('Missing original '+p.source);if(p.local&&!fs.existsSync(p.local))errors.push('Missing local '+p.local);else if(p.local&&!fs.readFileSync(p.local,'utf8').trim())errors.push('Empty local source '+p.local);if(p.in_toc&&!p.local)errors.push('Unmapped original TOC entry '+p.source)}
const unreviewed=inv.pages.filter(p=>p.coverage!=='verified').length;
console.log(`${inv.pages.length} original pages accounted for structurally; ${unreviewed} inventory pages still require editorial evidence. No completeness claim is inferred.`);
if(errors.length){console.error(errors.join('\n'));process.exit(1)}
console.log('Source pin, paths, and control characters checked.');
