// Explicitly invoked after reviewing a handoff. Does not infer editorial success.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
const [editor,review,...files]=process.argv.slice(2);
if(!editor||!review||!files.length)throw Error('Usage: editor-report reviewer-report file...');
for(const p of [editor,review,...files])if(!fs.existsSync(p))throw Error('Missing '+p);
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));const dest='audit/review-status.json';
const ledger=fs.existsSync(dest)?JSON.parse(fs.readFileSync(dest)):{schema:1,notice:'Verified scope is limited to the exact file hash and the named independent review. Read source issues and rendering limitations in the reports. Structural inventory is not an editorial verdict.',files:{}};
const deps=(file,seen=new Set())=>{
 const result={};if(seen.has(file))return result;seen.add(file);
 for(const [,rel]of fs.readFileSync(file,'utf8').matchAll(/"([^"\n]+\.(?:typ|svg|png|jpg|jpeg))"/g)){
  if(rel.startsWith('@')||/^[a-z]+:/.test(rel))continue;
  const target=rel.startsWith('/')?rel.slice(1):path.normalize(path.join(path.dirname(file),rel));
  if(!fs.existsSync(target)||target==='template.typ'||target.startsWith('styles/'))continue;
  result[target]=crypto.createHash('sha256').update(fs.readFileSync(target)).digest('hex');
  if(target.endsWith('.typ'))Object.assign(result,deps(target,seen));
 }
 return result;
};
for(const file of files){const source=inv.pages.find(p=>p.local===file);if(!source)throw Error('No original page mapping '+file);ledger.files[file]={status:'source_compared_and_independently_reviewed',included_files:deps(file),local_sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'),source:source.source,source_sha256:source.source_sha256,editor_report:editor,independent_review_report:review,unresolved_issues:'See named reports; no claim that original-source defects are resolved',rendering:'See named reports; whole-book release acceptance remains pending'}};
fs.writeFileSync(dest,JSON.stringify(ledger,null,2)+'\n');console.log('Recorded independently reviewed file hashes:',files.length);
