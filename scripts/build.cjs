const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const mode=process.env.MALFA_DEPLOYMENT||'public';
if(!['public','admin'].includes(mode))throw new Error('MALFA_DEPLOYMENT must be public or admin');
const output=path.join(root,'dist');
// Only the generated dist directory is replaced.
fs.rmSync(output,{recursive:true,force:true});
fs.mkdirSync(output,{recursive:true});
function copy(file){const to=path.join(output,file);fs.mkdirSync(path.dirname(to),{recursive:true});fs.cpSync(path.join(root,file),to,{recursive:true});}
for(const dir of ['css','assets'])copy(dir);
for(const file of ['js/theme.js','js/cms-config.js','js/data.js'])copy(file);
if(mode==='public'){
  for(const file of fs.readdirSync(root).filter(f=>f.endsWith('.html')&&f!=='admin.html'))copy(file);
  copy('js/site.js');
}else{
  copy('admin.html');copy('js/admin.js');
  fs.copyFileSync(path.join(output,'admin.html'),path.join(output,'index.html'));
}
console.log(`Built ${mode} deployment in dist`);
