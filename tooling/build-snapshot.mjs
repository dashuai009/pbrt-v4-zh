// A live editing session must not be presented as an immutable build acceptance.
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {sha256} from './review-state.mjs';
const mode=process.argv[2];
const files=[...new Set(execFileSync('git',['ls-files','-co','--exclude-standard'],{encoding:'utf8'}).trim().split('\n'))].filter(f=>/\.(typ|svg|css|js|mjs|sh)$/.test(f)&&!f.startsWith('Scripts/')&&!f.startsWith('audit/')&&f!=='book.typ'&&!f.startsWith('audit-')).sort();
const snapshot=Object.fromEntries(files.map(f=>[f,sha256(fs.readFileSync(f))]));
fs.mkdirSync('output',{recursive:true});
if(mode==='start')fs.writeFileSync('output/build-inputs.json',JSON.stringify(snapshot,null,2)+'\n');
else if(mode==='end'){
 const before=JSON.parse(fs.readFileSync('output/build-inputs.json'));
 const changed=[...new Set([...Object.keys(before),...files])].filter(f=>before[f]!==snapshot[f]);
 fs.writeFileSync('output/build-consistency.json',JSON.stringify({stable:!changed.length,changed},null,2)+'\n');
 if(changed.length){console.error('Build inputs changed during compilation; rebuild the released snapshot:',changed);process.exitCode=1;}
 else console.log('Build inputs remained unchanged throughout validation.');
}else throw Error('Expected start or end');
