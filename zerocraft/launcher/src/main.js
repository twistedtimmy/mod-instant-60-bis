const { app, BrowserWindow, ipcMain, dialog, safeStorage, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const https = require('https');
const http = require('http');
const { spawn } = require('child_process');

const SETTINGS = path.join(app.getPath('userData'), 'settings.json');
const DEFAULTS = {
  wowPath: 'C:\\Games\\WoW335\\ChromieCraft_3.3.5a',
  updateSource: 'C:\\azerothcore\\zc_client',
  account: '',
  password: '',          // encrypted with Windows (DPAPI) via safeStorage
  autoLogin: false,
  loginDelay: 6,
  serverPath: 'C:\\azerothcore'
};
function loadSettings() {
  try { return Object.assign({}, DEFAULTS, JSON.parse(fs.readFileSync(SETTINGS, 'utf8'))); }
  catch { return Object.assign({}, DEFAULTS); }
}
function saveSettings(s) { fs.mkdirSync(path.dirname(SETTINGS), { recursive: true }); fs.writeFileSync(SETTINGS, JSON.stringify(s, null, 2)); }
function encrypt(pw) { return pw && safeStorage.isEncryptionAvailable() ? safeStorage.encryptString(pw).toString('base64') : ''; }
function decrypt(b64) { try { return b64 ? safeStorage.decryptString(Buffer.from(b64, 'base64')) : ''; } catch { return ''; } }

let splash, win;

function createWindows() {
  splash = new BrowserWindow({ icon: path.join(__dirname, 'icon.ico'), width: 300, height: 400, frame: false, resizable: false, transparent: false,
    backgroundColor: '#1a120d', show: true, webPreferences: { contextIsolation: true } });
  splash.loadFile(path.join(__dirname, 'splash.html'));

  win = new BrowserWindow({ width: 1280, height: 720, minWidth: 1100, minHeight: 640, frame: false, show: false,
    backgroundColor: '#140e0a', icon: path.join(__dirname, 'icon.ico'), webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true } });
  win.loadFile(path.join(__dirname, 'index.html'));
  win.once('ready-to-show', () => setTimeout(() => { if (splash) splash.close(); splash = null; win.show(); }, 1600));
}
app.setAppUserModelId('com.zerocraft.launcher');
app.whenReady().then(createWindows);
app.on('window-all-closed', () => app.quit());

// ---------- window controls ----------
ipcMain.on('win:min', () => win.minimize());
ipcMain.on('win:close', () => win.close());
ipcMain.on('open:url', (_e, url) => shell.openExternal(url));

// ---------- settings / login ----------
ipcMain.handle('settings:get', () => {
  const s = loadSettings();
  return { wowPath: s.wowPath, updateSource: s.updateSource, account: s.account, hasPassword: !!s.password,
           autoLogin: s.autoLogin, loginDelay: s.loginDelay, version: app.getVersion() };
});
ipcMain.handle('settings:set', (_e, patch) => {
  const s = loadSettings();
  for (const k of ['wowPath', 'updateSource', 'loginDelay']) if (patch[k] !== undefined) s[k] = patch[k];
  saveSettings(s); return true;
});
ipcMain.handle('login:save', (_e, { account, password, autoLogin }) => {
  const s = loadSettings();
  s.account = account; s.autoLogin = !!autoLogin;
  s.password = autoLogin ? encrypt(password) : '';
  saveSettings(s); return true;
});
ipcMain.handle('login:logout', () => { const s = loadSettings(); s.password = ''; s.autoLogin = false; saveSettings(s); return true; });
ipcMain.handle('pick:wow', async () => {
  const r = await dialog.showOpenDialog(win, { title: 'Select your WoW 3.3.5a folder', properties: ['openDirectory'] });
  return r.canceled ? null : r.filePaths[0];
});

// ---------- updates ----------
function isWeb(src) { return /^https?:\/\//i.test(src); }
function fetchBuf(url) {
  return new Promise((resolve, reject) => {
    (url.startsWith('https') ? https : http).get(url, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) return resolve(fetchBuf(res.headers.location));
      if (res.statusCode !== 200) return reject(new Error('HTTP ' + res.statusCode + ' for ' + url));
      const chunks = []; res.on('data', c => chunks.push(c)); res.on('end', () => resolve(Buffer.concat(chunks)));
    }).on('error', reject);
  });
}
async function readSource(src, rel) {
  if (isWeb(src)) return fetchBuf(src.replace(/\/+$/, '') + '/' + rel);
  return fs.readFileSync(path.join(src, rel));
}
async function getManifest(src) {
  const text = (await readSource(src, 'manifest.txt')).toString('utf8');
  const m = { version: 0, files: [], remove: [], news: [] };
  for (const line of text.split(/\r?\n/)) {
    let r;
    if ((r = line.match(/^version=(\d+)/))) m.version = +r[1];
    else if ((r = line.match(/^file=(.+)$/))) m.files.push(r[1].trim());
    else if ((r = line.match(/^remove=(.+)$/))) m.remove.push(r[1].trim());
    else if ((r = line.match(/^news=([^|]*)\|([^|]*)\|(.*)$/))) m.news.push({ date: r[1].trim(), title: r[2].trim(), text: r[3].trim() });
  }
  return m;
}
function localVersion(wow) { try { return parseInt(fs.readFileSync(path.join(wow, 'zerocraft_version.txt'), 'utf8').trim()) || 0; } catch { return 0; } }

ipcMain.handle('update:check', async () => {
  const s = loadSettings();
  if (!fs.existsSync(path.join(s.wowPath, 'Wow.exe'))) return { error: 'nowow', wowPath: s.wowPath };
  try {
    const m = await getManifest(s.updateSource);
    return { remote: m.version, local: localVersion(s.wowPath), news: m.news, files: m.files.length };
  } catch (e) { return { error: 'offline', message: e.message, local: localVersion(s.wowPath) }; }
});
ipcMain.handle('update:run', async (e) => {
  const s = loadSettings();
  const m = await getManifest(s.updateSource);
  const send = (pct, text) => e.sender.send('update:progress', { pct, text });
  for (const r of m.remove) { const p = path.join(s.wowPath, r); if (fs.existsSync(p)) fs.rmSync(p, { recursive: true, force: true }); }
  let i = 0;
  for (const f of m.files) {
    send(Math.round(100 * i / (m.files.length + 1)), 'Downloading ' + f);
    const data = await readSource(s.updateSource, 'files/' + f);
    const dest = path.join(s.wowPath, f);
    fs.mkdirSync(path.dirname(dest), { recursive: true }); fs.writeFileSync(dest, data); i++;
  }
  send(95, 'Clearing cache...');
  fs.rmSync(path.join(s.wowPath, 'Cache'), { recursive: true, force: true });
  fs.writeFileSync(path.join(s.wowPath, 'zerocraft_version.txt'), String(m.version));
  send(100, 'Up to date');
  return { local: m.version };
});

// ---------- play ----------
function setAccountName(wow, account) {
  const dir = path.join(wow, 'WTF'); fs.mkdirSync(dir, { recursive: true });
  const cfg = path.join(dir, 'Config.wtf');
  let lines = fs.existsSync(cfg) ? fs.readFileSync(cfg, 'utf8').split(/\r?\n/).filter(l => l && !/^SET accountName /.test(l)) : [];
  lines.push('SET accountName "' + account + '"');
  fs.writeFileSync(cfg, lines.join('\r\n') + '\r\n');
}
const TYPE_PASSWORD_PS = String.raw`
$log = Join-Path $env:ZC_WOW 'zerocraft_login.log'
function L($m) { Add-Content -Path $log -Value ((Get-Date -Format 'HH:mm:ss') + ' ' + $m) }
Set-Content -Path $log -Value 'ZeroCraft auto-login'
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class ZcWin {
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
}
"@
$p = Get-Process -Id ([int]$env:ZC_PID) -ErrorAction SilentlyContinue
if (-not $p) { $p = Get-Process -Name Wow -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $p) { L 'WoW process not found'; exit }
$end = (Get-Date).AddSeconds(90)
while (-not $p.HasExited -and $p.MainWindowHandle -eq 0 -and (Get-Date) -lt $end) { Start-Sleep -Milliseconds 400; $p.Refresh() }
$h = $p.MainWindowHandle
L ('window handle ' + $h)
if ($h -eq 0) { L 'no WoW window'; exit }
Start-Sleep -Seconds ([int]$env:ZC_DELAY)
[void][ZcWin]::SetForegroundWindow($h)
Start-Sleep -Milliseconds 300
foreach ($ch in $env:ZC_PW.ToCharArray()) {
  [void][ZcWin]::PostMessage($h, 0x0102, [IntPtr][int]$ch, [IntPtr]1)   # WM_CHAR
  Start-Sleep -Milliseconds 25
}
Start-Sleep -Milliseconds 200
[void][ZcWin]::PostMessage($h, 0x0100, [IntPtr]0x0D, [IntPtr]0x001C0001) # WM_KEYDOWN Enter
[void][ZcWin]::PostMessage($h, 0x0102, [IntPtr]0x0D, [IntPtr]0x001C0001) # WM_CHAR Enter
[void][ZcWin]::PostMessage($h, 0x0101, [IntPtr]0x0D, [IntPtr]0xC01C0001) # WM_KEYUP Enter
L ('typed ' + $env:ZC_PW.Length + ' characters and pressed Enter')
`;
// ---------- patch-Y swap: delete patch-Y.MPQ, rename patch-Y.new to patch-Y.MPQ ----------
function swapPatchY(wowPath) {
  const dir = path.join(wowPath, 'Data');
  const nw = path.join(dir, 'patch-Y.new'), mpq = path.join(dir, 'patch-Y.MPQ');
  if (!fs.existsSync(nw)) return { ok: true, note: 'No new patch waiting - ' + mpq + ' is already the newest.' };
  try {
    if (fs.existsSync(mpq)) fs.rmSync(mpq, { force: true });
    fs.renameSync(nw, mpq);
    return { ok: true, note: 'Swapped in the new patch: ' + mpq };
  } catch (e) {
    return { error: 'Could not swap ' + mpq + ' - WoW is using it. Close WoW and click again.' };
  }
}
ipcMain.handle('dev:patch', () => swapPatchY(loadSettings().wowPath));

ipcMain.handle('game:play', () => {
  const s = loadSettings();
  swapPatchY(s.wowPath); // always start with the newest patch-Y
  const exe = path.join(s.wowPath, 'Wow.exe');
  if (!fs.existsSync(exe)) return { error: 'Wow.exe not found in ' + s.wowPath };
  if (s.account) setAccountName(s.wowPath, s.account);
  const game = spawn(exe, [], { cwd: s.wowPath, detached: true, stdio: 'ignore' });
  game.unref();
  const pw = decrypt(s.password);
  if (!(s.autoLogin && pw)) fs.writeFileSync(path.join(s.wowPath, 'zerocraft_login.log'), 'auto-login skipped: autoLogin=' + s.autoLogin + ' savedPassword=' + !!pw + '\r\n');
  if (s.autoLogin && pw) {
    const ps = spawn('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-Command', TYPE_PASSWORD_PS],
      { detached: true, stdio: 'ignore', env: Object.assign({}, process.env, { ZC_PID: String(game.pid), ZC_DELAY: String(s.loginDelay || 6), ZC_PW: pw, ZC_WOW: s.wowPath }) });
    ps.unref();
  }
  game.on('exit', () => { if (win) win.webContents.send('game:exit'); });
  return { ok: true };
});

// ---------- dev tools ----------
ipcMain.handle('dev:paths', () => {
  const s = loadSettings();
  return { update: path.join(s.serverPath || 'C:\\azerothcore', 'update.bat'), cache: path.join(s.wowPath, 'Cache') };
});
ipcMain.handle('dev:update', async () => {
  const s = loadSettings();
  const bat = path.join(s.serverPath || 'C:\\azerothcore', 'update.bat');
  if (!fs.existsSync(bat)) return { error: 'Not found: ' + bat };
  return await new Promise((resolve) => {
    // detached, so it keeps going even if it has to close the launcher to rebuild it
    const p = spawn('cmd.exe', ['/c', bat], { cwd: path.dirname(bat), windowsHide: true, detached: true });
    p.on('exit', (code) => {
      let log = '';
      try { log = fs.readFileSync(path.join(path.dirname(bat), 'update.log'), 'utf8'); } catch (e) {}
      if (/FAILED/.test(log)) resolve({ error: 'Build failed - see ' + path.join(path.dirname(bat), 'update.log') });
      else resolve(code === 0 ? { ok: true } : { error: bat + ' exited with code ' + code });
    });
    p.on('error', (e) => resolve({ error: e.message }));
  });
});
ipcMain.handle('dev:restart', async () => {
  return await new Promise((resolve) => {
    const p = spawn('docker', ['restart', 'ac-worldserver'], { windowsHide: true });
    let err = '';
    p.stderr.on('data', (d) => { err += d; });
    p.on('exit', (code) => resolve(code === 0 ? { ok: true } : { error: 'docker restart ac-worldserver failed: ' + (err.trim() || 'code ' + code) }));
    p.on('error', (e) => resolve({ error: 'Could not run docker - is Docker Desktop running? (' + e.message + ')' }));
  });
});
ipcMain.handle('dev:cache', () => {
  const s = loadSettings();
  const dir = path.join(s.wowPath, 'Cache');
  if (!fs.existsSync(dir)) return { ok: true, note: dir + ' was already empty.' };
  try { fs.rmSync(dir, { recursive: true, force: true }); return { ok: true, note: 'Deleted ' + dir }; }
  catch (e) { return { error: 'Could not delete ' + dir + ' - close WoW first.' }; }
});
ipcMain.handle('server:clearChars', async () => {
  const s = loadSettings();
  const r = await dialog.showMessageBox(win, { type: 'warning', buttons: ['Delete my characters', 'Cancel'], defaultId: 1, cancelId: 1,
    title: 'Delete my characters', message: 'Permanently delete ALL characters on account "' + s.account + '"?',
    detail: 'Log out of WoW first. This cannot be undone.' });
  if (r.response !== 0) return { cancelled: true };
  const bat = path.join(s.serverPath || 'C:\\azerothcore', 'clear_characters.bat');
  if (!fs.existsSync(bat)) return { error: 'Not found: ' + bat };
  return await new Promise((resolve) => {
    if (!s.account) return { error: 'Log in to the launcher first.' };
    const p = spawn('cmd.exe', ['/c', bat, s.account], { cwd: path.dirname(bat), windowsHide: true });
    p.on('exit', (code) => resolve(code === 0 ? { ok: true } : { error: 'Script exited with code ' + code }));
    p.on('error', (e) => resolve({ error: e.message }));
  });
});
