const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('notes', {
  search: (query) => ipcRenderer.invoke('notes:search', query),
});
