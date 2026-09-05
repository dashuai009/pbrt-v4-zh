// Resolve retained source links against the pinned original; no model or translation calls.
import fs from 'node:fs';import path from 'node:path';import {parse} from 'parse5';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const refs=JSON.parse(fs.readFileSync('web/generated/references.json'));
const labels=JSON.parse(fs.readFileSync('web/generated/label-targets.json'));
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const cache=new Map(),globalIds=new Map();
for(const p of inv.pages){const ids=new Set([...walk(parse(fs.readFileSync('pbr-book-website/'+p.source,'utf8')))].map(n=>attr(n,'id')).filter(Boolean));cache.set(p.source,ids);for(const id of ids){if(!globalIds.has(id))globalIds.set(id,[]);globalIds.get(id).push(p.source)}}
const routes={},unresolved=[];let internal=0,original=0;
for(const page of inv.pages.filter(p=>p.local)){
 routes[page.local]={};const text=fs.readFileSync(page.local,'utf8');
 for(const [,dest] of text.matchAll(/#link\(\s*"([^"\n]+)"/g)){
  if(/^(https?:|mailto:|data:)/.test(dest))continue;
  let source,hash;
  if(dest.includes('.html')){const [pathname,fragment]=dest.split('#');source=path.posix.normalize(path.posix.join(path.posix.dirname(page.source),pathname));hash=fragment;}
  else {hash=dest.replace(/^<|>$/g,'').replace(/^#/,'');source=cache.get(page.source).has(hash)?page.source:globalIds.get(hash)?.length===1?globalIds.get(hash)[0]:null;}
  if(!source||!cache.has(source)||hash&&!cache.get(source).has(decodeURIComponent(hash))){unresolved.push({local:page.local,dest,reason:'target absent or ambiguous in fixed original'});routes[page.local][dest]={kind:'unresolved'};continue}
  const targetPage=inv.pages.find(p=>p.source===source);
  const matching=hash&&labels[hash]?.file===targetPage?.local?labels[hash]:hash?Object.values(refs).find(r=>r.file===targetPage?.local&&(r.label===hash||r.label.replace(/^(eqt:|fig:|tbl:)/,'')===hash)):null;
  if(matching){routes[page.local][dest]={kind:'internal',slug:matching.slug,anchor:matching.anchor};internal++}
  else {routes[page.local][dest]={kind:'original',url:'https://pbr-book.org/'+source+(hash?'#'+hash:'')};original++}
 }
}
fs.writeFileSync('web/generated/source-links.json',JSON.stringify(routes,null,2));
fs.writeFileSync('audit/source-link-issues.json',JSON.stringify({notice:'These original targets are unresolved. Reader output displays the original link text with an explicit pending-reference marker, never a guessed or broken link.',unresolved},null,2));
console.log(JSON.stringify({internal,original,unresolved:unresolved.length}));
