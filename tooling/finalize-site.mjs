import fs from 'node:fs';import path from 'node:path';
const root=process.argv[2]||'output/site',base=process.env.PAGES_BASE_PATH||'/pbrt-v4-zh/';
fs.copyFileSync('web/site.css',path.join(root,'theme/reader.css'));fs.copyFileSync('web/site.js',path.join(root,'theme/reader.js'));
function walk(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const f=path.join(d,e.name);if(e.isDirectory()){walk(f);continue}if(!e.name.endsWith('.html'))continue;let s=fs.readFileSync(f,'utf8');s=s.replace(/<link[^>]+href="[^"]*theme\/reader\.css"[^>]*>/g,'').replace(/<script[^>]+src="[^"]*theme\/reader\.js"[^>]*><\/script>/g,'');if(!s.includes('</head>'))continue;s=s.replace(/<script[^>]+src="[^"]*internal\/searcher\.js"[^>]*><\/script>/g,'');s=s.replace('</head>',`<link rel="stylesheet" href="${base}theme/reader.css"></head>`).replace('</body>',`<script src="${base}theme/reader.js" defer></script></body>`);fs.writeFileSync(f,s)}}walk(root);
fs.writeFileSync(path.join(root,'.nojekyll'),'');
