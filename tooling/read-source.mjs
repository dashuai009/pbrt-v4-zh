import fs from 'node:fs';import {parse} from 'parse5';
const file=process.argv[2],pattern=process.argv[3];
const doc=parse(fs.readFileSync(file,'utf8'),{sourceCodeLocationInfo:true});
const walk=function*(n){yield n;for(const c of n.childNodes||[])yield*walk(c)};
const txt=n=>n.nodeName==='#text'?n.value:(n.childNodes||[]).filter(c=>!['script','style','defs','path','use'].includes(c.tagName)).map(txt).join('');
for(const n of walk(doc)){if(!['p','h1','h2','h3','h4','pre','li'].includes(n.tagName))continue;const t=txt(n).replace(/\s+/g,' ').trim();if(t&&(!pattern||new RegExp(pattern,'i').test(t)))console.log(`${file}:${n.sourceCodeLocation?.startLine} ${t}`)}
