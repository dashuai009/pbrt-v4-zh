// These are integrity checks for an explicit editorial decision, not semantic review.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
export const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
export function dependencies(file, root=process.cwd(), seen=new Set()) {
  const entry=seen.size===0;
  file=path.normalize(file);if(seen.has(file))return {};seen.add(file);
  const result={};
  // main.typ supplies the bibliography registry used by chapter citations.
  if(entry&&fs.existsSync(path.resolve(root,'bibliography.bib')))result['bibliography.bib']=sha256(fs.readFileSync(path.resolve(root,'bibliography.bib')));
  for(const [,rel] of fs.readFileSync(path.resolve(root,file),'utf8').matchAll(/"([^"\n]+\.(?:typ|svg|png|jpe?g|webp|gif|json|csv|ya?ml|txt|bib))"/gi)) {
    if(rel.startsWith('@')||/^[a-z]+:/i.test(rel))continue;
    const name=path.normalize(rel.startsWith('/')?rel.slice(1):path.join(path.dirname(file),rel));
    // Generated Web routing is sealed by build-snapshot after generation.
    if(name===file||name.startsWith('web/generated/')||!fs.existsSync(path.resolve(root,name)))continue;
    result[name]=sha256(fs.readFileSync(path.resolve(root,name)));
    if(name.endsWith('.typ'))Object.assign(result,dependencies(name,root,seen));
  }
  return result;
}
export function assessReview(file, record, root=process.cwd()) {
  const resolve=name=>path.resolve(root,name);
  if(!fs.existsSync(resolve(file)))return {status:'missing',changes:[file]};
  if(!fs.readFileSync(resolve(file),'utf8').trim())return {status:'empty',changes:[file]};
  if(!record)return {status:'not_reviewed',changes:[]};
  const changes=[];
  const matches=(name,hash)=>fs.existsSync(resolve(name))&&sha256(fs.readFileSync(resolve(name)))===hash;
  if(record.status!=='source_compared_and_independently_reviewed')changes.push('review verdict not established');
  if(!record.source||!record.source_sha256)changes.push('missing source snapshot');
  if(!matches(file,record.local_sha256))changes.push(file);
  for(const [name,hash]of Object.entries(record.included_files||{})){
    if(resolve(name)===resolve(file))changes.push('dependency overrides main file');
    if(!matches(name,hash))changes.push(name);
  }
  for(const name of Object.keys(dependencies(file,root)))if(!Object.hasOwn(record.included_files||{},name))changes.push('unrecorded dependency: '+name);
  const reports=[record.editor_report,record.independent_review_report];const real=[];
  for(const report of reports){
    if(!report||!fs.existsSync(resolve(report))){changes.push(report||'missing review report');continue;}
    real.push(fs.realpathSync(resolve(report)));
    if(!fs.readFileSync(resolve(report),'utf8').trim())changes.push('empty report: '+report);
    if(!matches(report,record.report_sha256?.[report]))changes.push('report changed or not sealed: '+report);
  }
  if(real.length===2&&real[0]===real[1])changes.push('editor and independent report are the same');
  if(record.source&&record.source_sha256&&!matches('pbr-book-website/'+record.source,record.source_sha256))changes.push(record.source);
  return {status:changes.length?'changed_since_review':'independently_reviewed',changes:[...new Set(changes)]};
}
export const reviewLabel=state=>({missing:'缺失',empty:'空文件',not_reviewed:'待原文对照及独立复核',changed_since_review:'复核后内容、依赖或证据变化，需复查',independently_reviewed:'已原文对照及独立复核（源问题见报告）'})[state.status];
