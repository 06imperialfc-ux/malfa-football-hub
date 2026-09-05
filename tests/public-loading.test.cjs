const {test}=require('node:test');
const assert=require('node:assert/strict');
const vm=require('node:vm');
const fs=require('node:fs');
const source=fs.readFileSync(require('node:path').join(__dirname,'../js/site.js'),'utf8');
function setup(page,fetch){
 const context=vm.createContext({window:{LEAGUE_CONFIG:{season:'2026'},MALFA_CMS:{supabaseUrl:'https://example.com',supabasePublishableKey:'public'}},document:{body:{dataset:{page}},addEventListener(){}},location:{search:''},URL,URLSearchParams,AbortController,setTimeout,clearTimeout,fetch});
 vm.runInContext(source,context);return code=>vm.runInContext(code,context);
}
test('static pages make no database requests',async()=>{
 const run=setup('about',()=>{throw Error('unexpected request')});await run('loadRemoteData()');
});
test('fixtures request only relevant tables and current season',async()=>{
 const calls=[];const run=setup('fixtures',async url=>{calls.push(url);return {ok:true,json:async()=>[]}});
 await run('loadRemoteData()');assert.equal(calls.length,3);
 assert.equal(calls.find(u=>u.pathname.endsWith('/fixtures')).searchParams.get('season'),'eq.2026');
 assert(!calls.some(u=>u.pathname.endsWith('/news_posts')));
});
test('request failures are surfaced without publishing partial state',async()=>{
 const run=setup('fixtures',async url=>({ok:!url.pathname.endsWith('/fixtures'),json:async()=>[{id:'x'}]}));
 await assert.rejects(run('loadRemoteData()'),/request failed/);
 assert.equal(run('state.competitions.length'),0);
});
test('page chrome renders before a pending database request',async()=>{
 const run=setup('home',()=>{});
 run('globalThis.calls=[];renderHeader=()=>calls.push("header");renderFooter=()=>calls.push("footer");observe=()=>calls.push("visible");dataMessage=()=>{};loadRemoteData=()=>new Promise(()=>{});init()');
 assert.equal(run('calls.join(",")'),'header,footer,visible');
});
