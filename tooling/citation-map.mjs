// Conservative identity matching for routing citations to the complete original bibliography.
// Exact normalized title + year + first author, unique source record only; ambiguity stays explicit.
import fs from 'node:fs';import {parse} from 'parse5';
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const txt=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).filter(c=>!['script','style','defs','path','use'].includes(c.tagName)).map(txt).join('');
const doc=parse(fs.readFileSync('pbr-book-website/4ed/References.html','utf8'),{sourceCodeLocationInfo:true});
const norm=s=>s.normalize('NFKD').replace(/\\[a-zA-Z]+/g,'').replace(/[^\p{L}\p{N}]/gu,'').toLowerCase();
const records=[];for(const g of walk(doc))if(g.tagName==='div'&&/^[A-Za-z]$/.test(attr(g,'id')||''))for(const p of walk(g))if(p.tagName==='p'&&txt(p).trim())records.push({index:records.length+1,text:txt(p).replace(/\s+/g,' ').trim(),line:p.sourceCodeLocation?.startLine});
const bib=fs.readFileSync('bibliography.bib','utf8');const entries=[];
for(const match of bib.matchAll(/@\w+\s*\{\s*([^,]+),/g)){
 let start=match.index+match[0].length,i=start,depth=1;for(;i<bib.length&&depth;i++){if(bib[i]==='\\'){i++;continue}if(bib[i]==='{')depth++;if(bib[i]==='}')depth--;}
 const body=bib.slice(start,i-1),fields={};
 for(const field of body.matchAll(/(\w+)\s*=\s*\{/g)){let j=field.index+field[0].length,k=j,d=1;for(;k<body.length&&d;k++){if(body[k]==='\\'){k++;continue}if(body[k]==='{')d++;if(body[k]==='}')d--;}fields[field[1].toLowerCase()]=body.slice(j,k-1);}
 entries.push({key:match[1].trim(),...fields});
}
const map={},issues=[];
for(const e of entries){const title=norm(e.title||''),year=e.year?.match(/\d{4}/)?.[0],author=norm((e.author||'').split(' and ')[0].split(',')[0]);
 const candidates=title.length>=12&&year&&author?records.filter(r=>norm(r.text).includes(title)&&r.text.includes(year)&&norm(r.text.split('.')[0]).includes(author)):[];
 if(candidates.length===1){const r=candidates[0];map[e.key]={index:r.index,anchor:'original-reference-'+r.index,source_line:r.line,source_text:r.text,title:e.title,year:r.text.match(/\b(?:18|19|20)\d{2}[a-z]?\b/)?.[0]||year,first_author:author};}
 else issues.push({key:e.key,title:e.title||'',reason:candidates.length>1?'ambiguous source identity':'no exact unique title/year/author identity'});
}
const aliases=JSON.parse(fs.readFileSync('audit/citation-key-aliases.json'));
const original=JSON.parse(fs.readFileSync('audit/original-citations.json'));
for(const [key,alias]of Object.entries(aliases)){
 const record=original[alias.source_id];if(!record||!entries.some(e=>e.key===key))throw Error('Invalid explicit citation alias '+key);
 map[key]={index:record.index,anchor:record.anchor,source_line:record.source_line,source_text:record.text,year:record.year,basis:alias.basis};
 const at=issues.findIndex(e=>e.key===key);if(at>=0)issues.splice(at,1);
}
fs.writeFileSync('audit/citation-map.json',JSON.stringify(map,null,2)+'\n');fs.writeFileSync('audit/citation-map-issues.json',JSON.stringify(issues,null,2)+'\n');console.log(JSON.stringify({entries:entries.length,mapped:Object.keys(map).length,unresolved:issues.length}));
