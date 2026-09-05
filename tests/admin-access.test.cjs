const {test}=require('node:test');
const assert=require('node:assert/strict');
const vm=require('node:vm');
const fs=require('node:fs');
const source=fs.readFileSync(require('node:path').join(__dirname,'../js/admin.js'),'utf8');
function setup(){
  const nodes=new Map();
  const context=vm.createContext({window:{},document:{addEventListener(){},querySelector(s){if(!nodes.has(s))nodes.set(s,{hidden:false});return nodes.get(s)}},setTimeout,clearTimeout,URL,console});
  vm.runInContext(source,context);
  return {run:code=>vm.runInContext(code,context),nodes};
}
test('club and league admins cannot navigate to superadmin panels',()=>{
  const {run}=setup();
  for(const role of ['club_admin','league_admin',null]){
    run(`state.adminRole=${JSON.stringify(role)}`);
    assert.equal(run('allowedTab("access")'),false);
    assert.doesNotThrow(()=>run('openTab("access")'));
  }
  run('state.adminRole="super_admin"');
  assert.equal(run('allowedTab("access")'),true);
});
test('failed scope queries reject instead of silently accepting empty permissions',async()=>{
  const {run}=setup();
  run('state.session={user:{id:"test"}};state.client={from(){return {select(){return {eq:async()=>({error:{message:"missing migration"}})}}}}}');
  await assert.rejects(run('loadScopes()'),/Unable to load administrator assignments/);
});
test('sign out clears scopes and hides the dashboard',async()=>{
  const {run,nodes}=setup();
  run('state.adminRole="super_admin";state.competitionScope=["mpl"];state.clubScope=["club"]');
  await run('session(null)');
  assert.equal(run('state.adminRole'),null);
  assert.equal(run('state.competitionScope.length+state.clubScope.length'),0);
  assert.equal(nodes.get('#dashboard').hidden,true);
});
test('auth callback schedules session work after callback returns',async()=>{
  const {run}=setup();
  run('globalThis.called=false;session=async()=>{called=true};scheduleSession(null)');
  assert.equal(run('called'),false);
  await new Promise(resolve=>setTimeout(resolve,20));
  assert.equal(run('called'),true);
});
