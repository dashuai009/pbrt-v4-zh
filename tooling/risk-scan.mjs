// Review candidates, not automated fixes or proof of correctness.
import fs from 'node:fs';
const inv=JSON.parse(fs.readFileSync('audit/inventory.json')),issues=[];
for(const p of inv.pages.filter(p=>p.local)){
 const s=fs.readFileSync(p.local,'utf8');
 for(const [i,line]of s.split('\n').entries()){
  const reasons=[];
  if(/partial[^$\n]{0,70}\/\s*partial/.test(line))reasons.push('un-grouped partial derivative division; inspect rendered fraction');
  if(/^\s*```(?:tex|latex)/.test(line))reasons.push('TeX shown as code; compare with original mathematical display');
  if(/@[A-Za-z0-9_:.\-]+[\u3400-\u9fff]/.test(line))reasons.push('reference label touches Chinese text');
  if(/^\[#raw\(/.test(line))reasons.push('literal square brackets around a fragment heading');
  if(reasons.length)issues.push({file:p.local,line:i+1,reasons,snippet:line.slice(0,240),status:'needs_source_and_render_review'});
 }
}
fs.writeFileSync('audit/render-risk-candidates.json',JSON.stringify({notice:'Candidates require source comparison and actual rendering. They are not automated verdicts, and are never mass-replaced.',issues},null,2)+'\n');console.log('Rendered-math/structure review candidates:',issues.length);
