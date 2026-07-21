const { app, BrowserWindow, ipcMain, dialog, globalShortcut } = require('electron');
const path = require('path');
const fs   = require('fs');
const os   = require('os');
let mm = null;
import('music-metadata').then(mod => { mm = mod; }).catch(() => {});

// Dev: app/../data  |  Packaged: Colm's OneDrive library if present, else Documents/Electron App Data/FlashJam/data
const WORKSPACE_DATA = path.join(os.homedir(), 'Library', 'CloudStorage', 'OneDrive-Adobe', 'Work', 'Development', 'claude-workspace', 'FlashJam', 'data');
const SHARED_APP_DATA = path.join(app.getPath('documents'), 'Electron App Data', 'FlashJam', 'data');
const DATA_DIR = !app.isPackaged
  ? path.join(__dirname, '..', 'data')
  : fs.existsSync(WORKSPACE_DATA) ? WORKSPACE_DATA : SHARED_APP_DATA;

let mainWindow   = null;
let currentFile  = null; // active playlist file path

function createWindow() {
  mainWindow = new BrowserWindow({
    width:  580,
    height: 500,
    minWidth:  520,
    minHeight: 420,
    title: 'FlashJam',
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 14, y: 14 },
    vibrancy: 'under-window',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  mainWindow.loadFile('flashjam.html');
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createWindow();
  globalShortcut.register('MediaPlayPause',    () => mainWindow?.webContents.send('media-key', 'play-pause'));
  globalShortcut.register('MediaNextTrack',    () => mainWindow?.webContents.send('media-key', 'next'));
  globalShortcut.register('MediaPreviousTrack',() => mainWindow?.webContents.send('media-key', 'prev'));
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});
app.on('will-quit', () => globalShortcut.unregisterAll());
app.on('window-all-closed', () => app.quit());

// ── Playlist management ──
ipcMain.handle('list-playlists', () => {
  try {
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    return fs.readdirSync(DATA_DIR)
      .filter(f => f.endsWith('.json'))
      .map(f => {
        const fp   = path.join(DATA_DIR, f);
        const stat = fs.statSync(fp);
        return { name: f.replace(/\.json$/, ''), filename: f, modified: stat.mtimeMs };
      })
      .sort((a, b) => b.modified - a.modified);
  } catch { return []; }
});

ipcMain.handle('load-playlist', (e, filename) => {
  try {
    const fp = path.join(DATA_DIR, filename);
    currentFile = fp;
    if (fs.existsSync(fp)) return JSON.parse(fs.readFileSync(fp, 'utf8'));
    return null;
  } catch { return null; }
});

ipcMain.handle('create-playlist', (e, name) => {
  try {
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    const filename = `${name.replace(/[^a-z0-9 _-]/gi, '_')}.json`;
    const fp = path.join(DATA_DIR, filename);
    if (!fs.existsSync(fp)) fs.writeFileSync(fp, JSON.stringify({ playlist: [], volume: 0.8, shuffle: false }, null, 2));
    currentFile = fp;
    return filename;
  } catch { return null; }
});

ipcMain.handle('save-data', (e, data) => {
  try {
    if (!currentFile) return false;
    if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
    fs.writeFileSync(currentFile, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch { return false; }
});

ipcMain.handle('delete-playlist', (e, filename) => {
  try {
    const fp = path.join(DATA_DIR, filename);
    if (fs.existsSync(fp)) fs.unlinkSync(fp);
    if (currentFile === fp) currentFile = null;
    return true;
  } catch { return false; }
});

ipcMain.handle('set-mini-mode', (e, enabled) => {
  if (!mainWindow) return;
  if (enabled) {
    mainWindow.setMinimumSize(580, 80);
    mainWindow.setSize(580, 80);
    mainWindow.setAlwaysOnTop(true, 'floating');
  } else {
    mainWindow.setAlwaysOnTop(false);
    mainWindow.setMinimumSize(520, 420);
    mainWindow.setSize(580, 500);
  }
});

ipcMain.handle('rename-playlist', (e, oldFilename, newName) => {
  try {
    const oldPath = path.join(DATA_DIR, oldFilename);
    const newFilename = `${newName.replace(/[^a-z0-9 _-]/gi, '_')}.json`;
    const newPath = path.join(DATA_DIR, newFilename);
    if (!fs.existsSync(oldPath)) return null;
    fs.renameSync(oldPath, newPath);
    if (currentFile === oldPath) currentFile = newPath;
    return newFilename;
  } catch { return null; }
});

// ── File helpers ──
ipcMain.handle('file-exists', (e, filePath) => {
  try { return fs.existsSync(filePath); } catch { return false; }
});

const MEDIA_EXT = new Set(['mp3','mp4','wav','ogg','m4a','flac','aac','webm','mov','m4v']);

function scanDir(dir, results = [], visited = new Set()) {
  try {
    const real = fs.realpathSync(dir);
    if (visited.has(real)) return results;
    visited.add(real);
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isSymbolicLink()) continue; // skip aliases/symlinks
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        scanDir(full, results, visited);
      } else if (entry.isFile()) {
        const ext = entry.name.split('.').pop().toLowerCase();
        if (MEDIA_EXT.has(ext)) results.push(full);
      }
    }
  } catch { /* skip unreadable dirs */ }
  return results;
}

// Returns media files from a folder path (recursive) or confirms a file path
ipcMain.handle('scan-paths', (e, paths) => {
  const results = [];
  for (const p of paths) {
    try {
      const stat = fs.statSync(p);
      if (stat.isDirectory()) {
        scanDir(p, results);
      } else {
        const ext = p.split('.').pop().toLowerCase();
        if (MEDIA_EXT.has(ext)) results.push(p);
      }
    } catch { /* skip */ }
  }
  return results;
});

ipcMain.handle('read-tags', async (e, filePath) => {
  try {
    if (!mm) mm = await import('music-metadata');
    const meta = await mm.parseFile(filePath, { skipCovers: true });
    const c = meta.common;
    return {
      title:   c.title   || null,
      artist:  c.artist  || null,
      album:   c.album   || null,
      genre:   (c.genre  || []).join(', ') || null,
      track:   c.track?.no ? `${c.track.no}${c.track.of ? '/' + c.track.of : ''}` : null,
      year:    c.year    || null,
      duration: meta.format.duration || null,
    };
  } catch { return null; }
});

ipcMain.handle('get-default-art', () => {
  try {
    const imgPath = path.join(__dirname, 'default-art.png');
    const data = fs.readFileSync(imgPath);
    return `data:image/png;base64,${data.toString('base64')}`;
  } catch { return null; }
});

ipcMain.handle('read-art', async (e, filePath) => {
  try {
    if (!mm) mm = await import('music-metadata');
    const meta = await mm.parseFile(filePath, { skipCovers: false });
    const pic = meta.common.picture?.[0];
    if (!pic) return null;
    const buf = Buffer.isBuffer(pic.data) ? pic.data : Buffer.from(pic.data);
    const mime = pic.format.includes('/') ? pic.format : `image/${pic.format}`;
    return `data:${mime};base64,${buf.toString('base64')}`;
  } catch { return null; }
});

ipcMain.handle('write-art', async (e, filePath, imagePath) => {
  try {
    const NodeID3 = require('node-id3');
    const imageData = fs.readFileSync(imagePath);
    const ext  = imagePath.split('.').pop().toLowerCase();
    const mime = ext === 'png' ? 'image/png' : 'image/jpeg';
    const result = NodeID3.update({
      image: { mime, type: { id: 3, name: 'front cover' }, description: 'Cover', imageBuffer: imageData }
    }, filePath);
    return result !== false;
  } catch { return false; }
});

ipcMain.handle('open-image-dialog', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile'],
    filters: [{ name: 'Images', extensions: ['jpg','jpeg','png','webp'] }],
  });
  return result.canceled ? null : result.filePaths[0];
});

ipcMain.handle('write-tags', async (e, filePath, tags) => {
  try {
    const NodeID3 = require('node-id3');
    const payload = {};
    if (tags.title  != null) payload.title       = tags.title;
    if (tags.artist != null) payload.artist      = tags.artist;
    if (tags.album  != null) payload.album       = tags.album;
    if (tags.genre  != null) payload.genre       = tags.genre;
    if (tags.year   != null) payload.year        = String(tags.year);
    if (tags.track  != null) payload.trackNumber = String(tags.track);
    const result = NodeID3.update(payload, filePath);
    return result !== false;
  } catch { return false; }
});

ipcMain.handle('open-file-dialog', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile', 'multiSelections'],
    filters: [{ name: 'Audio / Video', extensions: ['mp3', 'mp4', 'wav', 'ogg', 'm4a', 'flac', 'aac', 'webm', 'mov'] }],
  });
  return result.canceled ? [] : result.filePaths;
});
