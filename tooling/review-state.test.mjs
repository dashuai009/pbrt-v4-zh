import {test} from 'node:test';import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {assessReview,sha256} from './review-state.mjs';
test('an included code or image change invalidates a completed review',()=>{
 const root=fs.mkdtempSync(path.join(os.tmpdir(),'pbrt-review-state-'));
 try{
  const values={'section.typ':'original body','extra.typ':'original extra','edit.md':'edited','review.md':'independent','pbr-book-website/4ed/source.html':'fixed source'};
  for(const [f,v]of Object.entries(values)){fs.mkdirSync(path.dirname(path.join(root,f)),{recursive:true});fs.writeFileSync(path.join(root,f),v);}
  const record={status:"source_compared_and_independently_reviewed",local_sha256:sha256('original body'),included_files:{'extra.typ':sha256('original extra')},editor_report:'edit.md',independent_review_report:'review.md',source:'4ed/source.html',source_sha256:sha256('fixed source')};
  assert.equal(assessReview('section.typ',record,root).status,'independently_reviewed');
  assert.equal(assessReview('section.typ',{...record,source_sha256:undefined},root).status,'changed_since_review');
  assert.equal(assessReview('section.typ',{...record,independent_review_report:'edit.md'},root).status,'changed_since_review');
  fs.writeFileSync(path.join(root,'extra.typ'),'unreviewed change');
  assert.deepEqual(assessReview('section.typ',record,root),{status:'changed_since_review',changes:['extra.typ']});
  assert.equal(assessReview('section.typ',undefined,root).status,'not_reviewed');
 }finally{fs.rmSync(root,{recursive:true,force:true});}
});
