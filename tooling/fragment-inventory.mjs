// Global source code ownership candidates, including folded panels.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {parse} from 'parse5';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const has=(n,c)=>(attr(n,'class')||'').split(' ').includes(c);
const text=n=>n.nodeName==='#text'?n.value:has(n,'collapse')?'':(n.childNodes||[]).map(text).join('');
const records=[];
for(const p of inv.pages){const doc=parse(fs.readFileSync('pbr-book-website/'+p.source,'utf8'),{sourceCodeLocationInfo:true});for(const n of walk(doc)){if(!has(n,'fragmentcode'))continue;let hidden=false,panel=null;for(let a=n.parentNode;a;a=a.parentNode)if(has(a,'collapse')){hidden=true;panel||=attr(a,'id');}const code=text(n).trim(),normalized=code.replace(/\s+/g,'');records.push({source:p.source,line:n.sourceCodeLocation?.startLine,visibility:hidden?'collapsed':'visible',panel,code,normalized_sha256:crypto.createHash('sha256').update(normalized).digest('hex'),status:'requires_scope_and_translation_review'});}}
fs.writeFileSync('audit/code-fragments.json',JSON.stringify(records,null,2)+'\n');
const visible=records.filter(r=>r.visibility==='visible'&&r.code.replace(/\s+/g,'').length>=120).map(r=>({...r,norm:r.code.replace(/\s+/g,'')}));const overlaps=[];
for(const dir of fs.readdirSync('.').filter(d=>/^(chapter-|Appendix-)/.test(d))){const supplements=path.join(dir,'supplements');if(!fs.existsSync(supplements))continue;for(const entry of fs.readdirSync(supplements).filter(x=>x.endsWith('.typ'))){const f=path.join(supplements,entry),s=fs.readFileSync(f,'utf8');for(const m of s.matchAll(/```(?:cpp|c\+\+)?\n([\s\S]*?)\n```/g)){const code=m[1].replace(/\s+/g,'');for(const r of visible)if(code.includes(r.norm))overlaps.push({supplement:f,line:s.slice(0,m.index).split('\n').length,source:r.source,source_line:r.line,matched_code:r.code,status:'overlap_candidate_not_automatic_deletion'});}}}
fs.writeFileSync('audit/supplement-overlap-candidates.json',JSON.stringify({notice:'Whitespace-insensitive overlap candidates only. Check exact tokens, strings, context and existing local ownership before removing anything.',overlaps},null,2)+'\n');console.log(JSON.stringify({fragments:records.length,visible:records.filter(r=>r.visibility==='visible').length,collapsed:records.filter(r=>r.visibility==='collapsed').length,overlap_candidates:overlaps.length}));
