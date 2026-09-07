import {test} from 'node:test';import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {assessReview,dependencies,sha256} from './review-state.mjs';
test('review integrity rejects changed content, evidence, aliases, and overriding dependencies',()=>{
 const root=fs.mkdtempSync(path.join(os.tmpdir(),'pbrt-review-state-'));
 try{
  const body='#import "template.typ": *\n#json("values.json")';
  const values={'section.typ':body,'template.typ':'#import "styles/source-citations.typ": *','styles/source-citations.typ':'#let data=json("/audit/original-citations.json")','audit/original-citations.json':'{"year":1993}','values.json':'{"value":1}','extra.typ':'original extra','edit.md':'Source comparison completed.','review.md':'Independent source review completed.','pbr-book-website/4ed/source.html':'fixed source'};
  for(const [f,v]of Object.entries(values)){fs.mkdirSync(path.dirname(path.join(root,f)),{recursive:true});fs.writeFileSync(path.join(root,f),v);}
  const record={status:'source_compared_and_independently_reviewed',local_sha256:sha256(body),included_files:dependencies('section.typ',root),editor_report:'edit.md',independent_review_report:'review.md',report_sha256:{'edit.md':sha256(values['edit.md']),'review.md':sha256(values['review.md'])},source:'4ed/source.html',source_sha256:sha256('fixed source')};
  assert.equal(assessReview('section.typ',record,root).status,'independently_reviewed');
  assert.equal(assessReview('section.typ',{...record,source_sha256:undefined},root).status,'changed_since_review');
  assert.equal(assessReview('section.typ',{...record,independent_review_report:'./edit.md'},root).status,'changed_since_review');
  assert.equal(assessReview('section.typ',{...record,local_sha256:'wrong',included_files:{'section.typ':sha256(body)}},root).status,'changed_since_review');
  fs.writeFileSync(path.join(root,'audit/original-citations.json'),'{"year":0}');
  assert.ok(assessReview('section.typ',record,root).changes.includes('audit/original-citations.json'));
  fs.writeFileSync(path.join(root,'audit/original-citations.json'),values['audit/original-citations.json']);
  assert.equal(assessReview('section.typ',{...record,included_files:{}},root).status,'changed_since_review');
  fs.writeFileSync(path.join(root,'values.json'),'{"value":2}');
  assert.ok(assessReview('section.typ',record,root).changes.includes('values.json'));
  fs.writeFileSync(path.join(root,'values.json'),values['values.json']);
  fs.writeFileSync(path.join(root,'review.md'),'changes_requested');
  assert.equal(assessReview('section.typ',record,root).status,'changed_since_review');
  fs.writeFileSync(path.join(root,'review.md'),'');
  assert.equal(assessReview('section.typ',{...record,report_sha256:{...record.report_sha256,'review.md':sha256('')}},root).status,'changed_since_review');
  assert.equal(assessReview('section.typ',undefined,root).status,'not_reviewed');
 }finally{fs.rmSync(root,{recursive:true,force:true});}
});
