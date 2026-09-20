const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('zc', {
  min: () => ipcRenderer.send('win:min'),
  close: () => ipcRenderer.send('win:close'),
  openUrl: (u) => ipcRenderer.send('open:url', u),
  getSettings: () => ipcRenderer.invoke('settings:get'),
  setSettings: (p) => ipcRenderer.invoke('settings:set', p),
  saveLogin: (l) => ipcRenderer.invoke('login:save', l),
  logout: () => ipcRenderer.invoke('login:logout'),
  pickWow: () => ipcRenderer.invoke('pick:wow'),
  checkUpdate: () => ipcRenderer.invoke('update:check'),
  runUpdate: () => ipcRenderer.invoke('update:run'),
  onProgress: (cb) => ipcRenderer.on('update:progress', (_e, d) => cb(d)),
  clearChars: () => ipcRenderer.invoke('server:clearChars'),
  devPaths: () => ipcRenderer.invoke('dev:paths'),
  devUpdate: () => ipcRenderer.invoke('dev:update'),
  devCache: () => ipcRenderer.invoke('dev:cache'),
  devPatch: () => ipcRenderer.invoke('dev:patch'),
  devRestart: () => ipcRenderer.invoke('dev:restart'),
  play: () => ipcRenderer.invoke('game:play'),
  onGameExit: (cb) => ipcRenderer.on('game:exit', () => cb())
});
