// Index the complete rendered HTML text, not shiroa's 512-character excerpts.
import fs from 'node:fs';import path from 'node:path';import {parseFragment} from 'parse5';
const root=process.argv[2]||'output/site',pages=JSON.parse(fs.readFileSync('web/generated/pages.json'));
const text=n=>n.nodeName==='#text'?n.value:['svg','style','script'].includes(n.tagName)?'':(n.childNodes||[]).map(text).join(['p','div','pre','li'].includes(n.tagName)?' ':'');
const index=[];for(const lang of ['zh','zh-en'])for(const p of pages){const rel=`web/generated/${lang}/${p.slug}`,file=path.join(root,rel+'.light.html');if(!fs.existsSync(file))continue;const body=text(parseFragment(fs.readFileSync(file,'utf8'))).replace(/\s+/g,' ').trim();index.push({url:rel+'.html',title:p.navtitle||p.title,lang,body});}
fs.writeFileSync(path.join(root,'reader-search.json'),JSON.stringify(index));console.log('Full-text search pages:',index.length);
