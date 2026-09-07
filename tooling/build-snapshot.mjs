// Compare source inputs and, separately, generated inputs consumed by shiroa.
import fs from 'node:fs';import path from 'node:path';import {execFileSync} from 'node:child_process';
import {sha256} from './review-state.mjs';
const mode=process.argv[2];
const generatedNames=new Set(['book.typ','audit/citation-map.json','audit/citation-map-issues.json','audit/original-citations.json','audit/original-citation-issues.json','audit/source-numbers.json','audit/source-number-evidence.json','audit/source-link-issues.json']);
const listed=(dir='.')=>execFileSync('git',['-C',dir,'ls-files','-co','--exclude-standard','-z'],{encoding:'utf8'}).split('\0').filter(Boolean);
function sourceSnapshot(){
 const names=listed().filter(f=>!generatedNames.has(f)&&!f.startsWith('Scripts/')&&!f.startsWith('audit-')&&f!=='pbr-book-website');
 if(fs.existsSync('pbr-book-website'))names.push(...listed('pbr-book-website').map(f=>'pbr-book-website/'+f));
 return Object.fromEntries([...new Set(names)].sort().filter(f=>fs.existsSync(f)&&fs.statSync(f).isFile()).map(f=>[f,sha256(fs.readFileSync(f))]));
}
function generatedSnapshot(){
 const names=[...generatedNames];
 const walk=d=>{if(fs.existsSync(d))for(const e of fs.readdirSync(d,{withFileTypes:true})){const f=path.join(d,e.name);if(e.isDirectory())walk(f);else names.push(f);}};
 walk('web/generated');
 for(const f of ['output/link-labels.json','output/references-en.json','output/references-zh.json','output/link-targets-en.json','output/link-targets-zh.json'])names.push(f);
 return Object.fromEntries([...new Set(names)].sort().filter(f=>fs.existsSync(f)).map(f=>[f,sha256(fs.readFileSync(f))]));
}
const compare=(before,after)=>[...new Set([...Object.keys(before),...Object.keys(after)])].filter(f=>before[f]!==after[f]);
fs.mkdirSync('output',{recursive:true});
if(mode==='start')fs.writeFileSync('output/build-inputs.json',JSON.stringify(sourceSnapshot(),null,2)+'\n');
else if(mode==='generated')fs.writeFileSync('output/build-generated-inputs.json',JSON.stringify(generatedSnapshot(),null,2)+'\n');
else if(mode==='end'){
 const source=compare(JSON.parse(fs.readFileSync('output/build-inputs.json')),sourceSnapshot());
 const generated=compare(JSON.parse(fs.readFileSync('output/build-generated-inputs.json')),generatedSnapshot());
 const result={stable:!source.length&&!generated.length,changed:source,changed_generated:generated};
 fs.writeFileSync('output/build-consistency.json',JSON.stringify(result,null,2)+'\n');
 if(!result.stable){console.error('Build inputs changed during validation:',result);process.exitCode=1;}
 else console.log('Source assets and generated rendering inputs remained unchanged during validation.');
}else throw Error('Expected start, generated, or end');
