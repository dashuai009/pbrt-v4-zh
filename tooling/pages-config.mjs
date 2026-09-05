import {spawnSync} from 'node:child_process';import fs from 'node:fs';
const repo='dashuai009/pbrt-v4-zh';
const r=spawnSync('git',['credential','fill'],{input:'protocol=https\nhost=github.com\n\n',encoding:'utf8',timeout:15000,env:{...process.env,GIT_TERMINAL_PROMPT:'0'}});
const password=r.stdout?.split('\n').find(s=>s.startsWith('password='))?.slice(9);
if(!password){console.log(JSON.stringify({authenticated:false,reason:'No GitHub credential available via configured git credential helper'}));process.exit(2)}
let response=await fetch(`https://api.github.com/repos/${repo}/pages`,{headers:{Authorization:`Bearer ${password}`,Accept:'application/vnd.github+json','X-GitHub-Api-Version':'2022-11-28'}});
let body=await response.json();
if(response.status===404&&process.argv.includes("--create")){
 response=await fetch(`https://api.github.com/repos/${repo}/pages`,{method:"POST",headers:{Authorization:`Bearer ${password}`,Accept:"application/vnd.github+json","Content-Type":"application/json"},body:JSON.stringify({build_type:"workflow"})});
 body=await response.json();
}
const repository=await (await fetch(`https://api.github.com/repos/${repo}`,{headers:{Authorization:`Bearer ${password}`,Accept:'application/vnd.github+json'}})).json();
const result={repository_permissions:repository.permissions,repository_default_branch:repository.default_branch,authenticated:true,http_status:response.status,...(response.ok?{html_url:body.html_url,build_type:body.build_type,source:body.source,cname:body.cname,status:body.status}:{message:body.message})};
fs.mkdirSync('output',{recursive:true});fs.writeFileSync('output/pages-config.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
