// Renders zerocraft.svg once at 256px with Electron (offscreen, transparent), downsizes to every icon size, packs a .ico
const { app, BrowserWindow } = require('electron');
const fs = require('fs'); const path = require('path');
const dir = __dirname;
const sizes = [16, 24, 32, 48, 64, 128, 256];
app.disableHardwareAcceleration();
app.commandLine.appendSwitch('force-device-scale-factor', '1');

app.whenReady().then(async () => {
  const svg = 'data:image/svg+xml;base64,' + fs.readFileSync(path.join(dir, 'zerocraft.svg')).toString('base64');
  const page = '<!doctype html><html><head><style>html,body{margin:0;padding:0;background:transparent;overflow:hidden}img{display:block;width:256px;height:256px}</style></head><body><img id="i" src="' + svg + '"></body></html>';
  const win = new BrowserWindow({ width: 256, height: 256, useContentSize: true, show: false, frame: false, transparent: true, webPreferences: { offscreen: true } });
  await win.loadURL('data:text/html;base64,' + Buffer.from(page).toString('base64'));
  await win.webContents.executeJavaScript('document.getElementById("i").decode()');
  await new Promise(r => setTimeout(r, 500));
  const full = await win.webContents.capturePage({ x: 0, y: 0, width: 256, height: 256 });
  console.log('captured', JSON.stringify(full.getSize()), 'empty:', full.isEmpty());
  const pngs = [];
  for (const s of sizes) {
    const img = s === 256 ? full : full.resize({ width: s, height: s, quality: 'best' });
    const png = img.toPNG();
    fs.writeFileSync(path.join(dir, 'icon_' + s + '.png'), png);
    pngs.push(png);
    console.log('icon_' + s + '.png ' + png.length + ' bytes');
  }
  // ICO container: 6-byte header, 16-byte directory entry per image, then PNG blobs (Vista+ accepts PNG entries)
  const header = Buffer.alloc(6); header.writeUInt16LE(0, 0); header.writeUInt16LE(1, 2); header.writeUInt16LE(sizes.length, 4);
  const entries = Buffer.alloc(16 * sizes.length);
  let offset = 6 + entries.length;
  sizes.forEach((s, i) => {
    const e = entries.subarray(16 * i);
    e.writeUInt8(s === 256 ? 0 : s, 0); e.writeUInt8(s === 256 ? 0 : s, 1); e.writeUInt8(0, 2); e.writeUInt8(0, 3);
    e.writeUInt16LE(1, 4); e.writeUInt16LE(32, 6); e.writeUInt32LE(pngs[i].length, 8); e.writeUInt32LE(offset, 12);
    offset += pngs[i].length;
  });
  const ico = Buffer.concat([header, entries, ...pngs]);
  fs.writeFileSync(path.join(dir, 'zerocraft.ico'), ico);
  console.log('zerocraft.ico written, ' + ico.length + ' bytes, ' + sizes.length + ' images');
  win.destroy();
  app.quit();
}).catch(e => { console.error(e); app.exit(1); });
