// Structural import only: no translation or model calls. See independent review.
import fs from 'node:fs';
import crypto from 'node:crypto';
import {parse, serializeOuter} from 'parse5';
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const attr=(n,k)=>n.attrs?.find(a=>a.name===k)?.value;
const plain=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).map(plain).join('');
const specs=[['References','参考文献'],['Index_of_Fragments','代码片段索引'],['Index_of_Identifiers','标识符索引']];
fs.mkdirSync('backmatter/math',{recursive:true});
const records=[];
for(const [name,zh] of specs){
 const source=`4ed/${name}.html`,html=fs.readFileSync(`pbr-book-website/${source}`,'utf8');
 const doc=parse(html,{sourceCodeLocationInfo:true});let items=0;const entries=[];
 function render(n){
  if(n.nodeName==='#text')return '#text('+JSON.stringify(n.value.replace(/\s+/g,' '))+')';
  if(n.tagName==='svg'){
   const svg=serializeOuter(n),hash=crypto.createHash('sha256').update(svg).digest('hex').slice(0,20);
   fs.writeFileSync(`backmatter/math/${hash}.svg`,svg);
   const height=attr(n,'height'),align=attr(n,'style')?.match(/vertical-align:\s*([-.\d]+)ex/);
   if(!height?.endsWith('ex')||!align)throw Error('Unknown original SVG metrics');
   const alt=plain((n.childNodes||[]).find(c=>c.tagName==='title')||{}).trim();
   return `#original-math("/backmatter/math/${hash}.svg",${parseFloat(height)},${-Number(align[1])},${JSON.stringify(alt)})`;
  }
  if(['script','style','defs','path','use'].includes(n.tagName))return '';
  const body=(n.childNodes||[]).map(render).join('');
  if(n.tagName==='a'&&attr(n,'href'))return '#link('+JSON.stringify(new URL(attr(n,'href'),'https://pbr-book.org/'+source).href)+')['+body+']';
  if(['em','i'].includes(n.tagName))return '#emph['+body+']';
  if(['strong','b'].includes(n.tagName))return '#strong['+body+']';
  return body;
 }
 for(const group of walk(doc)){
  if(group.tagName!=='div'||!attr(group,'id')?.match(/^[A-Za-z\\]$/))continue;
  const groupItems=[...walk(group)].filter(n=>n.tagName===(name==='References'?'p':'li'));
  if(!groupItems.length)continue;
  entries.push(`#heading(level:3,numbering:none,outlined:false)[${attr(group,'id')==='\\'?'\\\\':attr(group,'id')}]`);
  for(const n of groupItems){
   const rendered=render(n);if(!rendered.trim())continue;
   items++;let depth=0;for(let p=n.parentNode;p&&p!==group;p=p.parentNode)if(p.tagName==='ul')depth++;
   let entry=`#par(hanging-indent:1em)[#text(size:9pt)[${rendered}]]`;
   if(name==='Index_of_Identifiers'&&depth>1)entry=`#block(inset:(left:1em),above:.4em,below:.4em)[${entry}]`;
   if(name==='References')entry += `\n<original-reference-${items}>`;
   entries.push(entry);
   records.push({source,line:n.sourceCodeLocation?.startLine,local:`backmatter/${name}.typ`,entry:items,status:'imported_awaiting_independent_source_review'});
  }
 }
 const title=name.replaceAll('_',' ');
 fs.writeFileSync(`backmatter/${name}.typ`,`// Generated exactly from ${source} at f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c.\n#import "/template.typ": ez_caption\n#import "math/inline.typ": original-math\n#set par(spacing: .2em, leading: .4em, first-line-indent: 0pt)\n#heading(numbering:none)[#ez_caption[${title}][${zh}]]${name==='References'?' <complete-references>':''}\n#par[#ez_caption[Original bibliographic records and code names are preserved. Editorial verification is recorded separately.][保留原书书目信息和代码名称；对照验收状态另见审校记录。]]\n`+entries.join('\n\n')+'\n');
 console.log(name,items);
}
fs.writeFileSync('audit/backmatter-import.json',JSON.stringify({notice:'Exact import candidates. Independent review evidence and current hashes are recorded separately.',records},null,2)+'\n');
