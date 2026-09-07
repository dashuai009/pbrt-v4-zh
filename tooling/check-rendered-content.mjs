// Structural rendering diagnostics; actual visual inspection remains required.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';import {parseFragment} from 'parse5';
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const classes=n=>(attr(n,'class')||'').split(/\s+/);
const visible=n=>n.tagName==='figcaption'?false:n.nodeName==='#text'?!!n.value.trim():['img','svg','table','pre','code'].includes(n.tagName)||(n.childNodes||[]).some(visible);
export function checkRendered(root){
 const issues=[];let figures=0,math=0,files=0;
 function visit(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){
  const file=path.join(d,e.name);if(e.isDirectory()){visit(file);continue;}if(!file.endsWith('.light.html'))continue;files++;
  for(const n of walk(parseFragment(fs.readFileSync(file,'utf8')))){
   if(['svg','image','img'].includes(n.tagName)){
    const view=attr(n,'viewBox');if(view){const v=view.trim().split(/[\s,]+/).map(Number);if(v.length!==4||v.some(x=>!Number.isFinite(x))||v[2]<=0||v[3]<=0)issues.push({file,reason:'SVG has invalid or zero-sized viewBox'});}
    for(const dim of ['width','height']){const value=attr(n,dim);if(value!==undefined&&Number.parseFloat(value)<=0)issues.push({file,reason:`${n.tagName} has nonpositive ${dim}`});}
   }
   if(n.tagName==='figure'){figures++;if(!(n.childNodes||[]).some(visible))issues.push({file,reason:'Figure has no rendered body'});}
   if(classes(n).includes('inline-math')){math++;if(![...walk(n)].some(c=>c.tagName==='svg'))issues.push({file,reason:'Inline math has no SVG'});}
  }
 }}
 visit(root);if(!files)issues.push({file:root,reason:'No rendered content pages were found'});
 return {files,figures,math,issues};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const root=process.argv[2]||'output/site';const result=checkRendered(root);
 const manifest='web/generated/pages.json';
 if(!fs.existsSync(manifest))result.issues.push({file:manifest,reason:'Missing full-book page manifest'});
 else {for(const p of JSON.parse(fs.readFileSync(manifest)))for(const lang of ['zh','zh-en']){const file=path.join(root,'web/generated',lang,p.slug+'.light.html');if(!fs.existsSync(file))result.issues.push({file,reason:'Missing required full-book language page'});}}
 if(!fs.existsSync(path.join(root,'web/index.light.html')))result.issues.push({file:root,reason:'Missing reader landing page'});
 fs.mkdirSync('output',{recursive:true});fs.writeFileSync('output/rendered-content-report.json',JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({...result,issues:undefined,errors:result.issues.length,sample:result.issues.slice(0,6)}));if(result.issues.length)process.exitCode=1;
}
