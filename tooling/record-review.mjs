// Invoke only after accepting actual source comparison and independent review.
import fs from 'node:fs';
import {dependencies,sha256} from './review-state.mjs';
const [editor,review,...files]=process.argv.slice(2);
if(!editor||!review||!files.length)throw Error('Usage: editor-report reviewer-report file...');
for(const p of [editor,review,...files])if(!fs.existsSync(p)||!fs.readFileSync(p,'utf8').trim())throw Error('Missing or empty '+p);
if(fs.realpathSync(editor)===fs.realpathSync(review))throw Error('Independent report must be a different file');
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));const dest='audit/review-status.json';
const ledger=JSON.parse(fs.readFileSync(dest));
for(const file of files){
 const source=inv.pages.find(p=>p.local===file);if(!source)throw Error('No original mapping '+file);
 if(sha256(fs.readFileSync('pbr-book-website/'+source.source))!==source.source_sha256)throw Error('Source changed since inventory');
 const included=dependencies(file);const shared='audit/reports/review-shared-content.md';if(fs.existsSync(shared))included[shared]=sha256(fs.readFileSync(shared));
 ledger.files[file]={status:'source_compared_and_independently_reviewed',included_files:included,local_sha256:sha256(fs.readFileSync(file)),source:source.source,source_sha256:source.source_sha256,editor_report:editor,independent_review_report:review,report_sha256:{[editor]:sha256(fs.readFileSync(editor)),[review]:sha256(fs.readFileSync(review))},unresolved_issues:'See named reports; no claim that original-source defects are resolved',rendering:'See named reports; whole-book release acceptance remains pending'};
}
fs.writeFileSync(dest,JSON.stringify(ledger,null,2)+'\n');console.log('Recorded independently reviewed file hashes:',files.length);
