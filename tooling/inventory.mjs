// Deterministic source inventory only: no translation, model calls, or editorial verdicts.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {parse} from 'parse5';
import {assessReview,reviewLabel} from './review-state.mjs';
const root=path.resolve(import.meta.dirname,'..');
process.chdir(root);
const pinned='f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c';
if(execFileSync('git',['-C','pbr-book-website','rev-parse','HEAD'],{encoding:'utf8'}).trim()!==pinned) throw Error('Upstream revision mismatch');
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const text=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).filter(c=>!['script','style','defs','path','use'].includes(c.tagName)).map(text).join('');
const digest=s=>crypto.createHash('sha256').update(s).digest('hex');
const main=fs.readFileSync('main.typ','utf8')+'\n'+fs.readFileSync('content.typ','utf8');
const locals=[...main.matchAll(/^#include "([^"]+\.typ)"/gm)].map(m=>m[1]).filter(f=>f!=='content.typ');
const localMap=new Map();
for(const f of locals){let m=f.match(/^(?:chapter-\d+-|Appendix-[A-Z]-)([^/]+)\/(?:chapter-)?([\dA-Z]+)\.(\d+)-(.+)\.typ$/);if(m)localMap.set(Number(m[3])===0?`${m[1]}.html`:`${m[1]}/${m[4]}.html`,f)}
for(const name of ['References','Index_of_Fragments','Index_of_Identifiers'])localMap.set(name+'.html','backmatter/'+name+'.typ');
const tocDoc=parse(fs.readFileSync('pbr-book-website/4ed/contents.html','utf8'));
const allHtml=execFileSync('git',['-C','pbr-book-website','ls-files','4ed/*.html','4ed/**/*.html'],{encoding:'utf8'}).trim().split('\n').map(f=>f.slice(4));
const toc=[...new Set([...walk(tocDoc)].filter(n=>n.tagName==='a').map(n=>attr(n,'href')).filter(h=>allHtml.includes(h)&&!['contents.html','index.html'].includes(h)))];
const extra=allHtml.filter(f=>!toc.includes(f));
const pages=[];
for(const source of [...toc,...extra]){
 const file='pbr-book-website/4ed/'+source,html=fs.readFileSync(file,'utf8'),doc=parse(html,{sourceCodeLocationInfo:true});
 const units=[];let anchor=null;
 for(const n of walk(doc)){
  const id=attr(n,'id');if(id&&!id.startsWith('MathJax')&&!id.startsWith('E1-'))anchor=id;
  const cls=(attr(n,'class')||'').split(' ');let kind=null;
  if(/^h[1-6]$/.test(n.tagName))kind='heading';
  else if(n.tagName==='p'&&text(n).trim())kind='paragraph';
  else if(n.tagName==='li'&&text(n).trim())kind=source.startsWith('Index_of_')?'index_entry':'list_item';
  else if(n.tagName==='pre'||cls.includes('fragmentcode'))kind='code';
  else if(n.tagName==='img')kind='image';
  else if(n.tagName==='table')kind='table';
  else if(cls.includes('displaymath'))kind='display_equation';
  else if(cls.includes('footnote-button'))kind='footnote';
  else if(['caption','figcaption'].includes(n.tagName)||cls.some(c=>/caption/.test(c)))kind='caption';
  else if(n.tagName==='div'&&attr(n,'style')?.includes('background-image'))kind='opener_image';
  if(!kind)continue;
  const loc=n.sourceCodeLocation;if(!loc)continue;
  const raw=html.slice(loc.startOffset,loc.endOffset);
  let hidden=false;for(let parent=n.parentNode;parent;parent=parent.parentNode)if((attr(parent,"class")||"").split(" ").includes("collapse"))hidden=true;
  units.push({visibility:hidden?"collapsed":"visible",id:`${source}:${loc.startLine}:${kind}`,kind,line:loc.startLine,anchor,sha256:digest(raw),excerpt:text(n).replace(/\s+/g,' ').trim().slice(0,160),asset:attr(n,'src')||null,source_to_english:'unreviewed',english_to_chinese:'unreviewed',independent_review:'unreviewed'});
 }
 const local=localMap.get(source)||null;
 pages.push({source:`4ed/${source}`,in_toc:toc.includes(source),source_sha256:digest(html),local,mapping:local?(fs.readFileSync(local,'utf8').trim()?'candidate':'empty_file'):'missing_or_special',coverage:'unreviewed',units});
}
const ledger=fs.existsSync('audit/review-status.json')?JSON.parse(fs.readFileSync('audit/review-status.json')).files:{};
for(const p of pages){
 if(!p.local){p.editorial_state={status:'source_navigation',changes:[]};continue;}
 const review=ledger[p.local];p.editorial_state=assessReview(p.local,review);
 if(review){p.editorial_review=review;p.review_is_current=p.editorial_state.status==='independently_reviewed';}
}
const result={schema:1,upstream_commit:pinned,notice:'Structural candidates only. Every unit is unreviewed until source comparison and independent review are recorded. HTML navigation paragraphs may appear and require explicit scope decisions.',pages,local_extras:locals.filter(f=>![...localMap.values()].includes(f))};
fs.mkdirSync('audit',{recursive:true});fs.writeFileSync('audit/inventory.json',JSON.stringify(result,null,2)+'\n');
fs.writeFileSync('audit/COVERAGE.md','# 全书结构候选清单\n\n固定原书 '+pinned+'。结构映射与审校状态分开记录；审校状态依据报告和当前正文、补充/资源指纹，不由数量推断。逐单元本地位置映射仍需逐项证据，不能用整节状态替代；逐单元行号、锚点和指纹见 inventory.json。报告与后续审校记录独立保存，重新生成不会给内容授予通过状态。\n\n| 原书页面 | 本地入口 | 候选单元数 | 状态 |\n|---|---|---:|---|\n'+pages.map(p=>`| ${p.source} | ${p.local||'缺失或特殊页面，待判定'} | ${p.units.length} | ${p.local?reviewLabel(p.editorial_state):'目录/重定向辅助页，另验导航'} |`).join('\n')+'\n\n本地附加页面：'+result.local_extras.join('、')+'\n');
console.log(JSON.stringify({pages:pages.length,toc:toc.length,units:pages.reduce((s,p)=>s+p.units.length,0),unmapped:pages.filter(p=>!p.local).map(p=>p.source)},null,2));
