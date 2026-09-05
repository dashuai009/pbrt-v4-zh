// Find gross chapter misplacements for human review; similarity never marks content complete.
import fs from 'node:fs';import {execFileSync} from 'node:child_process';import {parse} from 'parse5';
const base='9e0ba8bd373932cd5fbab2d4ad9b13b1788b2d4e';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const pages=inv.pages.filter(p=>p.local&&!p.local.startsWith('backmatter/'));
const text=n=>n.nodeName==='#text'?n.value:['nav','script','style','svg','footer'].includes(n.tagName)?'':(n.childNodes||[]).map(text).join(' ');
const tokens=s=>{const m=new Map();for(const w of s.toLowerCase().match(/[a-z][a-z0-9_]{2,}/g)||[])m.set(w,(m.get(w)||0)+1);return m;};
const originals=pages.map(p=>tokens(text(parse(fs.readFileSync('pbr-book-website/'+p.source,'utf8')))));
const df=new Map();for(const m of originals)for(const w of m.keys())df.set(w,(df.get(w)||0)+1);
const vector=m=>{const v=new Map();let norm=0;for(const [w,n]of m){if(!df.has(w))continue;const x=Math.log1p(n)*Math.log(1+pages.length/df.get(w));v.set(w,x);norm+=x*x;}if(norm)for(const [w,x]of v)v.set(w,x/Math.sqrt(norm));return v;};
const sources=originals.map(vector),similarity=(a,b)=>{let s=0;for(const [w,x]of a)s+=x*(b.get(w)||0);return s;};
const results=[];
for(const [index,p]of pages.entries()){
 const baseline=execFileSync('git',['show',base+':'+p.local],{encoding:'utf8',maxBuffer:20e6});
 const v=vector(tokens(baseline));const scores=sources.map((s,i)=>({source:pages[i].source,score:similarity(v,s)})).sort((a,b)=>b.score-a.score);
 const expected=scores.find(s=>s.source===p.source),best=scores[0];
 if(!baseline.trim()||best.source!==p.source&&best.score>expected.score+.12)results.push({local:p.local,expected_source:p.source,expected_score:expected.score,best,kind:!baseline.trim()?'empty_baseline':'possible_misplaced_content',status:'candidate_requires_original_comparison'});
}
fs.writeFileSync('audit/transcript-baseline-candidates.json',JSON.stringify({baseline:base,notice:'Lexical candidates only. Absence from this list does not prove completeness or translation accuracy.',results},null,2)+'\n');console.log(JSON.stringify(results,null,2));
