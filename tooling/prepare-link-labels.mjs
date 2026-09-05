import fs from 'node:fs';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json'));
const keys=new Set();
for(const p of inv.pages.filter(p=>p.local)){
 const body=fs.readFileSync(p.local,'utf8');
 for(const [,key]of body.matchAll(/#link\(<([^>]+)>\)/g))keys.add(key);
 for(const [,url]of body.matchAll(/#link\(\s*"([^"\n]+)"/g)){
  if(url.startsWith('<')&&url.endsWith('>'))keys.add(url.slice(1,-1));
  else if(!/^[a-z]+:/.test(url)&&url.includes('.html#'))keys.add(url.split('#')[1]);
 }
}
fs.mkdirSync('output',{recursive:true});fs.writeFileSync('output/link-labels.json',JSON.stringify([...keys]));console.log('Explicit label destinations:',keys.size);
