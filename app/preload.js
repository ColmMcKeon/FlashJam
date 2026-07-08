const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  listPlaylists:  ()              => ipcRenderer.invoke('list-playlists'),
  loadPlaylist:   (filename)      => ipcRenderer.invoke('load-playlist', filename),
  createPlaylist: (name)          => ipcRenderer.invoke('create-playlist', name),
  deletePlaylist: (filename)      => ipcRenderer.invoke('delete-playlist', filename),
  saveData:       (data)          => ipcRenderer.invoke('save-data', data),
  fileExists:     (filePath)      => ipcRenderer.invoke('file-exists', filePath),
  readTags:       (filePath)      => ipcRenderer.invoke('read-tags', filePath),
  openFileDialog: ()              => ipcRenderer.invoke('open-file-dialog'),
  scanPaths:      (paths)         => ipcRenderer.invoke('scan-paths', paths),
  writeTags:      (filePath, tags)=> ipcRenderer.invoke('write-tags', filePath, tags),
  readArt:        (filePath)      => ipcRenderer.invoke('read-art', filePath),
  writeArt:       (filePath, img) => ipcRenderer.invoke('write-art', filePath, img),
  openImageDialog:()              => ipcRenderer.invoke('open-image-dialog'),
  getDefaultArt:  ()              => ipcRenderer.invoke('get-default-art'),
  renamePlaylist: (old, name)     => ipcRenderer.invoke('rename-playlist', old, name),
  setMiniMode:    (enabled)       => ipcRenderer.invoke('set-mini-mode', enabled),
  onMediaKey:     (cb)            => ipcRenderer.on('media-key', (e, key) => cb(key)),
});
