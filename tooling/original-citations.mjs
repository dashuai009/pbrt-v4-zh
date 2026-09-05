// Match section bibliography entries to the complete pinned bibliography by full text.
import fs from 'node:fs';import {parse} from 'parse5';
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const text=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).filter(c=>!['script','style','defs','path','use'].includes(c.tagName)).map(text).join('');
const normalize=s=>s.normalize('NFKC').replace(/\s+/g,' ').trim();
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const root=parse(fs.readFileSync('pbr-book-website/4ed/References.html','utf8'),{sourceCodeLocationInfo:true});
const records=[];for(const g of walk(root))if(g.tagName==='div'&&/^[A-Za-z]$/.test(attr(g,'id')||''))for(const p of walk(g))if(p.tagName==='p'&&text(p).trim())records.push({index:records.length+1,text:normalize(text(p)),line:p.sourceCodeLocation?.startLine});
const map={},issues=[];
for(const page of inv.pages){const doc=parse(fs.readFileSync('pbr-book-website/'+page.source,'utf8'),{sourceCodeLocationInfo:true});for(const n of walk(doc)){const id=attr(n,'id');if(!id?.startsWith('cite:')||n.tagName!=='li')continue;const value=normalize(text(n)),matches=records.filter(r=>r.text===value);if(matches.length===1){const r=matches[0],year=r.text.match(/\b(?:18|19|20)\d{2}[a-z]?\b/)?.[0];if(!year){issues.push({id,source:page.source,reason:'no explicit year'});continue}const record={anchor:'original-reference-'+r.index,index:r.index,year,text:r.text,source_line:r.line};if(map[id]&&map[id].index!==r.index)throw Error('Conflicting original citation ID '+id);map[id]=record;}else issues.push({id,source:page.source,line:n.sourceCodeLocation?.startLine,text:value,reason:matches.length?'duplicate complete records':'no exact complete-record match'});}}
fs.writeFileSync('audit/original-citations.json',JSON.stringify(map,null,2)+'\n');fs.writeFileSync('audit/original-citation-issues.json',JSON.stringify(issues,null,2)+'\n');console.log(JSON.stringify({original_ids:Object.keys(map).length,unresolved_occurrences:issues.length}));
