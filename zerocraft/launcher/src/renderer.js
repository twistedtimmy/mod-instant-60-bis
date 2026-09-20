const $ = (id) => document.getElementById(id);
let settings, state = 'checking', autoTimer = null;

function show(view) {
  for (const v of ['login', 'home']) $(v).classList.toggle('hidden', v !== view);
}
function setButton(big, small, enabled = true) {
  $('btnBig').textContent = big; $('btnSmall').textContent = small; $('btnMain').disabled = !enabled;
}
function status(t) { $('status').textContent = t || ''; }

function renderNews(list) {
  const cards = (list && list.length ? list : [
    { date: 'Pre-alpha', title: 'Welcome to ZeroCraft', text: 'Everyone starts at 60. Deploy guards, heroes and flight masters, and build your guild\'s network.' },
    { date: 'Pre-alpha', title: 'Dungeons drop armies', text: 'Every boss now drops deployable NPCs instead of gear. Heroes are legendary.' },
    { date: 'Pre-alpha', title: 'Flight networks', text: 'Flight points only exist where your guild holds a Flight Master.' },
    { date: 'Pre-alpha', title: 'Commander\'s Banner', text: 'Point, click, and your army marches - on foot or from the back of a drake.' }
  ]);
  const html = (c) => `<div class="card"><div class="art">ZEROCRAFT</div><div class="body"><small>${c.date}</small><b>${c.title}</b><p>${c.text}</p></div></div>`;
  if ($('newsList')) $('newsList').innerHTML = cards.slice(0, 4).map(html).join('');
  $('newsAll').innerHTML = cards.map(html).join('');
}

async function check() {
  state = 'checking'; setButton('CHECKING', 'Looking for updates...', false); status('');
  const r = await zc.checkUpdate();
  if (r.error === 'nowow') { state = 'nowow'; setButton('SET UP', 'Choose your WoW folder'); status('Wow.exe was not found in ' + r.wowPath); return; }
  if (r.error === 'offline') { state = 'play'; setButton('PLAY', 'Update server unreachable'); status(r.message); renderNews(); return; }
  renderNews(r.news);
  if (r.remote > r.local) { state = 'update'; setButton('UPDATE', `Version ${r.remote} available`); status(`You have version ${r.local}.`); }
  else { state = 'play'; setButton('PLAY', `Up to date · version ${r.local}`); }
}

async function play() {
  setButton('LAUNCHING', settings.autoLogin && settings.hasPassword ? 'Logging you in...' : 'Starting World of Warcraft...', false);
  const r = await zc.play();
  if (r.error) { setButton('PLAY', 'Try again'); status(r.error); return; }
  state = 'playing'; setButton('PLAYING', 'World of Warcraft is running', false); status('');
  if (settings.autoLogin && settings.hasPassword) watchLogin();
}
// show what the auto-login helper is doing (it writes zerocraft_login.log in the WoW folder)
let loginWatch = null;
function watchLogin() {
  if (loginWatch) clearInterval(loginWatch);
  const until = Date.now() + 120000;
  loginWatch = setInterval(async () => {
    const line = await zc.loginLog();
    if (line) status(line);
    if (Date.now() > until || state !== 'playing' || /Logged in|Gave up|Not retrying|Auto-login is off|Could not start|closed/.test(line)) { clearInterval(loginWatch); loginWatch = null; }
  }, 700);
}

$('btnMain').onclick = async () => {
  if (autoTimer) { clearTimeout(autoTimer); autoTimer = null; }
  if (state === 'update') {
    setButton('UPDATING', 'Please wait...', false); $('prog').classList.remove('hidden');
    try { await zc.runUpdate(); } catch (e) { status('Update failed: ' + e.message); }
    $('prog').classList.add('hidden'); check();
  } else if (state === 'play') play();
  else if (state === 'nowow') openTab('settings');
};
zc.onGameExit(() => { state = 'play'; check(); });
zc.onProgress(({ pct, text }) => { $('progBar').style.width = pct + '%'; status(text); });

$('btnLogin').onclick = async () => {
  const account = $('acc').value.trim(), password = $('pw').value;
  if (!account) { $('acc').focus(); return; }
  if ($('remember').checked && !password) { $('pw').focus(); return; }
  await zc.saveLogin({ account, password, autoLogin: $('remember').checked });
  settings = await zc.getSettings();
  enterHome();
};
$('pw').addEventListener('keydown', (e) => { if (e.key === 'Enter') $('btnLogin').click(); });
$('navLogout').onclick = async () => { await zc.logout(); settings = await zc.getSettings(); $('acc').value = settings.account; $('pw').value = ''; show('login'); };

function openTab(name) {
  document.querySelectorAll('nav a[data-tab]').forEach(a => a.classList.toggle('active', a.dataset.tab === name));
  for (const t of ['home', 'news', 'settings']) $('tab-' + t).classList.toggle('hidden', t !== name);
}
document.querySelectorAll('nav a[data-tab]').forEach(a => a.onclick = () => openTab(a.dataset.tab));

$('btnPick').onclick = async () => { const p = await zc.pickWow(); if (p) $('setWow').value = p; };
$('btnSave').onclick = async () => {
  await zc.setSettings({ wowPath: $('setWow').value.trim(), updateSource: $('setSrc').value.trim(), loginWait: Math.max(0, +$('setDelay').value || 0) });
  settings = await zc.getSettings(); $('saved').textContent = 'Saved'; setTimeout(() => $('saved').textContent = '', 2000);
  openTab('home'); check();
};

$('btnClear').onclick = async () => {
  $('btnClear').disabled = true; $('clearMsg').style.color = '#eadcc2'; $('clearMsg').textContent = 'Working...';
  const r = await zc.clearChars();
  $('btnClear').disabled = false;
  if (r.cancelled) { $('clearMsg').textContent = ''; return; }
  $('clearMsg').style.color = r.ok ? '#8fd48f' : '#ff8a7a';
  $('clearMsg').textContent = r.ok ? 'Done - your characters were deleted. The server is back in about 30 seconds.' : r.error;
};

zc.devPaths().then(p => { $('pUpdate').textContent = p.update; $('pCache').textContent = p.cache; });
function devMsg(r, okText) {
  $('devMsg').style.color = r.ok ? '#8fd48f' : '#ff8a7a';
  $('devMsg').textContent = r.ok ? okText || r.note : r.error;
}
$('btnUpdate').onclick = async () => {
  $('btnUpdate').disabled = true; $('devMsg').style.color = '#eadcc2';
  $('devMsg').textContent = 'Running ' + $('pUpdate').textContent + ' - this takes 1 to 3 minutes...';
  const r = await zc.devUpdate();
  $('btnUpdate').disabled = false;
  devMsg(r, 'Done - ' + $('pUpdate').textContent + ' finished. The server is back in about 30 seconds.');
};
$('btnCache').onclick = async () => { devMsg(await zc.devCache()); };
$('btnPatch').onclick = async () => { devMsg(await zc.devPatch()); };
$('btnRestart').onclick = async () => {
  $('btnRestart').disabled = true; $('devMsg').style.color = '#eadcc2'; $('devMsg').textContent = 'Restarting the server...';
  const r = await zc.devRestart();
  $('btnRestart').disabled = false;
  devMsg(r, 'Server restarted - it is back in about 30 seconds.');
};

function enterHome() {
  $('whoName').textContent = settings.account || '-';
  $('whoAuto').textContent = settings.autoLogin && settings.hasPassword ? 'Automatic login on' : 'Automatic login off';
  $('setWow').value = settings.wowPath; $('setSrc').value = settings.updateSource; $('setDelay').value = settings.loginWait;
  show('home'); openTab('home'); check();
}

(async () => {
  settings = await zc.getSettings();
  document.querySelectorAll('.ver').forEach(e => e.textContent = 'v' + settings.version);
  $('acc').value = settings.account;
  if (settings.account && (settings.hasPassword || !settings.autoLogin)) enterHome(); else show('login');
})();
