// Two bounded-memory passes; never retains all exported DOM trees or data URLs.
import fs from 'node:fs';import path from 'node:path';import {parse} from 'parse5';
const root=path.resolve(process.argv[2]||'output/site'),base=process.env.PAGES_BASE_PATH||'/pbrt-v4-zh/';
const files=[];function scan(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const f=path.join(d,e.name);if(e.isDirectory())scan(f);else if(e.name.endsWith('.html'))files.push(f)}}scan(root);
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const docs=new Map(),issues=[];let checked=0,glyphs=0;
for(const file of files){const ids=new Set();for(const n of walk(parse(fs.readFileSync(file,'utf8')))){if(n.namespaceURI==='http://www.w3.org/2000/svg')continue;for(const a of n.attrs||[])if(a.name==='id')ids.add(Buffer.from(a.value).toString());}docs.set(file,ids);}
for(const file of files){
 const doc=parse(fs.readFileSync(file,'utf8')),localIds=new Set();for(const n of walk(doc))for(const a of n.attrs||[])if(a.name==='id')localIds.add(a.value);
 for(const n of walk(doc))for(const a of n.attrs||[]){
  if(!['href','src'].includes(a.name))continue;const url=a.value;
  if(!url||/^(https?:|mailto:|data:|javascript:|tel:)/.test(url))continue;
  if(n.tagName==='use'&&url.startsWith('#')){glyphs++;if(!localIds.has(url.slice(1)))issues.push({file:path.relative(root,file),url,reason:'missing SVG glyph'});continue;}
  if(/^[a-z]+:/.test(url)){issues.push({file:path.relative(root,file),url,reason:'unsupported local scheme'});continue;}
  const [pathname,fragment]=url.split('#');let target;
  if(pathname.startsWith('/')){if(!pathname.startsWith(base)){issues.push({file:path.relative(root,file),url,reason:'outside Pages base path'});continue;}target=path.resolve(root,decodeURIComponent(pathname.slice(base.length)).split('?')[0]||'index.html');}
  else target=pathname?path.resolve(path.dirname(file),decodeURIComponent(pathname).split('?')[0]):file;
  if(fs.existsSync(target)&&fs.statSync(target).isDirectory())target=path.join(target,'index.html');checked++;
  if(!fs.existsSync(target)){issues.push({file:path.relative(root,file),url,reason:'missing file'});continue;}
  if(fragment&&docs.has(target)&&!(target===file?localIds:docs.get(target)).has(decodeURIComponent(fragment)))issues.push({file:path.relative(root,file),url,reason:'missing anchor'});
 }
}
fs.mkdirSync('output',{recursive:true});fs.writeFileSync('output/link-report.json',JSON.stringify({files:files.length,checked,glyphs,issues},null,2));console.log(JSON.stringify({files:files.length,checked,glyphs,errors:issues.length,sample:issues.slice(0,10)},null,2));if(issues.length)process.exit(1);
