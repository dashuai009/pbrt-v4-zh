// Build thin Typst entry files; never copies or rewrites the translated body.
import fs from 'node:fs';
import {assessReview} from './review-state.mjs';
import crypto from 'node:crypto';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const refs=[...JSON.parse(fs.readFileSync('output/references-en.json')),...JSON.parse(fs.readFileSync('output/references-zh.json'))];
const pages=inv.pages.filter(p=>p.local);
const ledger=fs.existsSync('audit/review-status.json')?JSON.parse(fs.readFileSync('audit/review-status.json')).files:{};
const currentReview=p=>assessReview(p.local,ledger[p.local]).status==='independently_reviewed'?ledger[p.local].independent_review_report:'';
const fileLabels=new Map(pages.map(p=>[p.local,new Set([...fs.readFileSync(p.local,'utf8').matchAll(/<([^<>\n]+)>/g)].map(m=>m[1]))]));
const chapterTitles=['序言','引言','蒙特卡洛积分','几何与变换','辐射度量、光谱与颜色','相机与胶片','形状','图元与求交加速','采样与重建','反射模型','纹理与材质','体散射','光源','光传输 I：表面反射','光传输 II：体渲染','GPU 上的波前渲染','回顾与未来'];
const entries=pages.map((p,i)=>({...p,slug:String(i).padStart(3,'0')+'-'+p.source.replace(/^4ed\//,'').replace(/\.html$/,'').replaceAll('/','--').replace(/[^A-Za-z0-9_-]/g,''),title:p.units.find(u=>u.kind==='heading')?.excerpt||p.source}));
for(const p of entries){
 const body=fs.readFileSync(p.local,"utf8");
 const caption=body.match(/^=+\s*#ez_caption\[[^\]]*\]\[([^\]]*)\]/m);
 const chapter=p.local.match(/^chapter-(\d+)-/);
 const originalNumber=p.title.match(/^([0-9A-C]+(?:\.[0-9]+)*)\s/)?.[1];
 const translated=({"backmatter/References.typ":"参考文献","backmatter/Index_of_Fragments.typ":"代码片段索引","backmatter/Index_of_Identifiers.typ":"标识符索引"})[p.local]||caption?.[1]||(/\.0-/.test(p.local)&&chapter?chapterTitles[Number(chapter[1])]:null)||(/Further_Reading/.test(p.local)?"延伸阅读":/Exercises/.test(p.local)?"习题":null);
 p.navtitle=translated?(originalNumber?originalNumber+" ":"")+translated:p.title;
}
const owners=new Map();for(const r of refs){if(!r["source-file"])continue;if(!owners.has(r.label))owners.set(r.label,new Set());owners.get(r.label).add(r["source-file"]);}
const map={};
for(const ref of refs){
 const label=ref.label, raw=label.replace(/^(eqt:|fig:|tbl:|lst:)/,'');
 if(owners.get(label)?.size>1)continue;
 const targets=ref["source-file"]?entries.filter(p=>p.local===ref["source-file"]):entries.filter(p=>fileLabels.get(p.local).has(label)||fileLabels.get(p.local).has(raw));
 if(targets.length===1)map[label]={...ref,file:targets[0].local,slug:targets[0].slug,anchor:'ref-'+crypto.createHash('sha256').update(label).digest('hex').slice(0,16)};
}
// Original and i-figured labels identify the same visible numbered object.
for(const key of Object.keys(map)){for(const prefix of ['fig:','tbl:','eqt:','lst:'])if(map[prefix+key]&&map[prefix+key].file===map[key].file){map[key]=map[prefix+key];break}}
fs.mkdirSync('web/generated',{recursive:true});
fs.writeFileSync('web/generated/references.json',JSON.stringify(map,null,2));
const localLinks={};
const labelTargets={};
for(const lang of ['zh','en'])for(const r of JSON.parse(fs.readFileSync('output/link-targets-'+lang+'.json'))){
 const owners=[...new Set(r.matches.map(x=>x['source-file']).filter(Boolean))];
 if(owners.length!==1)continue;
 const owner=entries.find(p=>p.local===owners[0]);if(!owner)continue;
 const reference=map[r.key];
 const anchor=reference?.anchor||'local-'+crypto.createHash('sha256').update(r.key).digest('hex').slice(0,16);
 if(!reference)(localLinks[owner.local]||={})[r.key]=anchor;
 labelTargets[r.key]={slug:owner.slug,anchor,file:owner.local};
}
fs.writeFileSync('web/generated/local-links.json',JSON.stringify(localLinks,null,2));
fs.writeFileSync('web/generated/reference-page.json',JSON.stringify(entries.find(p=>p.source==='4ed/References.html').slug));
fs.writeFileSync('web/generated/label-targets.json',JSON.stringify(labelTargets,null,2));
fs.writeFileSync('web/generated/pages.json',JSON.stringify(entries.map(({local,source,slug,title,navtitle})=>({local,source,slug,title,navtitle})),null,2));
const pilot=process.argv.includes('--pilot');
let chosen=pilot?entries.filter(p=>['4ed/Introduction.html','4ed/Introduction/Literate_Programming.html','4ed/Introduction/pbrt_System_Overview.html','4ed/Geometry_and_Transformations/Vectors.html','4ed/Monte_Carlo_Integration.html','4ed/Monte_Carlo_Integration/Monte_Carlo_Basics.html','4ed/Monte_Carlo_Integration/Improving_Efficiency.html'].includes(p.source)):entries;
for(const lang of ['zh','zh-en']){
 fs.mkdirSync(`web/generated/${lang}`,{recursive:true});
 for(const p of chosen){
 fs.writeFileSync(`web/generated/${lang}/${p.slug}.typ`, `#import "/web/page.typ": reader\n#show: reader.with(title: ${JSON.stringify(p.title)}, source: ${JSON.stringify(p.source)}, local-file: ${JSON.stringify(p.local)}, lang: ${JSON.stringify(lang)}, review-report: ${JSON.stringify(currentReview(p))}, section-number: ${JSON.stringify(p.title.match(/^([0-9A-C]+(?:\.[0-9]+)*)\s/)?.[1]||"")})\n#include ${JSON.stringify('/'+p.local)}\n#bibliography("/bibliography.bib")\n`);
 }
}
fs.writeFileSync('book.typ',`#import "@preview/shiroa:0.2.0": *\n#show: book\n#book-meta(title: "PBRT 第四版 · 中文校订", authors: ("Matt Pharr", "Wenzel Jakob", "Greg Humphreys"), summary: [\n#prefix-chapter("web/index.typ")[阅读与校订说明]\n`+['zh','zh-en'].map(lang=>`= ${lang==='zh'?'中文阅读':'中英对照'}\n`+chosen.map(p=>`${/\.0-/.test(p.local)||p.local.startsWith("backmatter/")?"-":"  -"} #chapter("web/generated/${lang}/${p.slug}.typ", section: none)[ ${p.navtitle.replaceAll('[','\\[').replaceAll(']','\\]')}]`).join('\n')).join('\n')+'\n])\n');
fs.writeFileSync('web/generated/base-path.json',JSON.stringify(process.env.PAGES_BASE_PATH||'/pbrt-v4-zh/'));
console.log(JSON.stringify({pages:chosen.length,languages:2,references:Object.keys(map).length,pilot}));
