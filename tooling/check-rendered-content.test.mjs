import {test} from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {checkRendered} from './check-rendered-content.mjs';
test('empty sites and partial zero dimensions cannot pass rendering checks',()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'pbrt-render-check-'));
 try{
  assert.ok(checkRendered(dir).issues.length);
  for(const html of ['<svg viewBox="0 0 0 20"></svg>','<svg viewBox="0 0 20 0"></svg>','<img width="0" height="0">','<svg><image width="0px" height="20px"></image></svg>','<span class="inline-math extra">missing</span>']){
   fs.writeFileSync(path.join(dir,'probe.light.html'),html);assert.ok(checkRendered(dir).issues.length,html);
  }
  fs.writeFileSync(path.join(dir,'probe.light.html'),'<figure><svg viewBox="0 0 20 20" width="20pt" height="20pt"><path d="M0 0L1 1"/></svg><figcaption>caption</figcaption></figure>');
  assert.equal(checkRendered(dir).issues.length,0);
 }finally{fs.rmSync(dir,{recursive:true,force:true});}
});
