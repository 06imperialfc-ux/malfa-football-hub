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
test('standings count only valid verified results in the current season',()=>{
  const {run}=setup();
  run(`CONFIG.season='2026';globalThis.crypto={randomUUID:()=> 'id'};
    state.clubs=[{id:'a',name:'A'},{id:'b',name:'B'}];
    state.entries=['a','b'].map(club_id=>({club_id,competition_id:'mpl',season:'2026',active:true}));
    const match={competition_id:'mpl',season:'2026',home_club_id:'a',away_club_id:'b',status:'finished',verified:true,home_score:2,away_score:1};
    state.fixtures=[match,{...match,season:'2025'},{...match,verified:false},{...match,home_score:null},{...match,home_score:1.5}];`);
  assert.equal(run('tableRows("mpl",true)[0].points'),3);
  assert.equal(run('tableRows("mpl",true)[0].played'),1);
  run('state.fixtures[0].verified=false');
  assert.equal(run('tableRows("mpl",true)[0].points'),0);
});
test('failed automatic table publishing propagates to the caller',async()=>{
  const {run}=setup();
  run('tableRows=()=>[];persistTable=async()=>{throw new Error("write denied")}');
  await assert.rejects(run('rebuildTable("mpl",true)'),/write denied/);
});
