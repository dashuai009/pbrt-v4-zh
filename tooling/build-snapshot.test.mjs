import {test} from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawnSync} from 'node:child_process';
const script=path.resolve(import.meta.dirname,'build-snapshot.mjs');
test('source PNG/JSON/submodule assets and generated book changes invalidate snapshots',()=>{
 const root=fs.mkdtempSync(path.join(os.tmpdir(),'pbrt-build-snapshot-'));
 const run=mode=>spawnSync(process.execPath,[script,mode],{cwd:root,encoding:'utf8'});
 const write=(f,text)=>{fs.mkdirSync(path.dirname(path.join(root,f)),{recursive:true});fs.writeFileSync(path.join(root,f),text);};
 try{
  spawnSync('git',['init','-q'],{cwd:root});write('.gitignore','output/\nweb/generated/\n');write('chapter.typ','body');write('figure.png','png bytes');write('data.json','{"x":1}');write('book.typ','generated book');write('web/generated/map.json','{"id":1}');
  fs.mkdirSync(path.join(root,'pbr-book-website'));spawnSync('git',['init','-q'],{cwd:path.join(root,'pbr-book-website')});write('pbr-book-website/source.png','original image');
  for(const file of ['figure.png','data.json','book.typ','web/generated/map.json','pbr-book-website/source.png']){
   assert.equal(run('start').status,0);assert.equal(run('generated').status,0);assert.equal(run('end').status,0);
   fs.appendFileSync(path.join(root,file),'changed');const result=run('end');assert.equal(result.status,1,file+' '+result.stderr);
  }
 }finally{fs.rmSync(root,{recursive:true,force:true});}
});
