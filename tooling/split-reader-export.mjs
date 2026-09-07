// Split data from one shared full-book layout; never infer numbering from source order.
import fs from 'node:fs';
const lang=process.argv[2];if(!['zh','en'].includes(lang))throw Error('Expected zh or en');
const data=JSON.parse(fs.readFileSync(`output/reader-${lang}.json`));
if(!Array.isArray(data.references)||!data.references.length||!Array.isArray(data.targets)||!data.targets.length)throw Error('Incomplete full-book export');
for(const [name,value]of [['references',data.references],['link-targets',data.targets]]){
 const file=`output/${name}-${lang}.json`;fs.writeFileSync(file+'.tmp',JSON.stringify(value));fs.renameSync(file+'.tmp',file);
}
