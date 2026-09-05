// Exact original-anchor matching only. No positional or semantic guesses.
import fs from 'node:fs';import {parse} from 'parse5';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const text=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).filter(c=>!['script','style','svg'].includes(c.tagName)).map(text).join('');
const map={},evidence=[];
for(const page of inv.pages.filter(p=>p.local)){
 const doc=parse(fs.readFileSync('pbr-book-website/'+page.source,'utf8'),{sourceCodeLocationInfo:true});const table={};let figureAnchor=null;
 for(const n of walk(doc)){
  const id=attr(n,'id');if(id&&/^(fig:|tab:|tbl:|table:)/.test(id))figureAnchor=id;
  const cls=(attr(n,'class')||'').split(' ');
  if(cls.includes('eqno')){
   const a=[...walk(n)].find(c=>c.tagName==='a'&&attr(c,'href')?.startsWith('#'));
   if(a){const anchor=attr(a,'href').slice(1),num=text(a).trim();const key='eqt:'+anchor.replace(/^(eq:|eqt:)/,'');table[key]='('+num+')';evidence.push({local:page.local,key,number:table[key],source:page.source,line:n.sourceCodeLocation?.startLine,anchor});}
  }
  if((n.tagName==='figcaption'||n.tagName==='caption')&&figureAnchor){const match=text(n).trim().match(/^(Figure|Table)\s+([0-9A-C]+\.[0-9]+)/);if(match){const key=(match[1]==='Table'?'tbl:':'fig:')+figureAnchor.replace(/^(fig:|tab:|tbl:|table:)/,'');table[key]=match[2];evidence.push({local:page.local,key,number:match[2],source:page.source,line:n.sourceCodeLocation?.startLine,anchor:figureAnchor});}}
 }
 map[page.local]=table;
}
fs.writeFileSync('audit/source-numbers.json',JSON.stringify(map,null,2)+'\n');fs.writeFileSync('audit/source-number-evidence.json',JSON.stringify(evidence,null,2)+'\n');console.log('Pinned original numbered targets:',evidence.length);
