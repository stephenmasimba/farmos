// IndexedDB-backed Offline Service (no external libraries)
(function() {
  const DB_NAME = 'BeginMasimbaFarmOS';
  const DB_VERSION = 2;
  let db;
  let isOnline = navigator.onLine;
  let syncQueue = JSON.parse(localStorage.getItem('syncQueue') || '[]');
  let lastSyncTime = localStorage.getItem('lastSyncTime') || null;

  function openDB() {
    return new Promise((resolve, reject) => {
      const req = window.indexedDB.open(DB_NAME, DB_VERSION);
      req.onupgradeneeded = (e) => {
        db = e.target.result;
        const stores = [
          'transactions',
          'inventory',
          'livestock_batches',
          'breeding_records',
          'sensor_data',
          'tasks',
          'timesheets',
          'fields',
          'financial_budgets',
          'financial_invoices',
          'field_history',
          'field_soil',
          'field_harvest',
          'field_rotation',
          'sync_queue',
          'conflicts'
        ];
        stores.forEach((name) => {
          if (!db.objectStoreNames.contains(name)) {
            db.createObjectStore(name, { keyPath: 'id', autoIncrement: true });
          }
        });
      };
      req.onsuccess = (e) => {
        db = e.target.result;
        resolve(db);
      };
      req.onerror = (e) => reject(e);
    });
  }

  function tx(storeName, mode = 'readonly') {
    return db.transaction(storeName, mode).objectStore(storeName);
  }

  async function ensureDB() {
    if (!db) await openDB();
  }

  async function storeData(storeName, data) {
    await ensureDB();
    return new Promise((resolve, reject) => {
      const request = tx(storeName, 'readwrite').put(data);
      request.onsuccess = () => resolve(true);
      request.onerror = (e) => reject(e);
    });
  }

  async function getData(storeName, key = null) {
    await ensureDB();
    const store = tx(storeName, 'readonly');
    return new Promise((resolve, reject) => {
      if (key !== null && key !== undefined) {
        const req = store.get(key);
        req.onsuccess = () => resolve(req.result);
        req.onerror = (e) => reject(e);
      } else {
        const req = store.getAll();
        req.onsuccess = () => resolve(req.result);
        req.onerror = (e) => reject(e);
      }
    });
  }

  async function clearStore(storeName) {
    await ensureDB();
    return new Promise((resolve, reject) => {
      const request = tx(storeName, 'readwrite').clear();
      request.onsuccess = () => resolve(true);
      request.onerror = (e) => reject(e);
    });
  }

  async function queueForSync(operation) {
    const item = {
      ...operation,
      id: Date.now(),
      timestamp: new Date().toISOString()
    };
    syncQueue.push(item);
    saveSyncQueue();
    if (isOnline) {
      await syncPendingData();
    }
    return item;
  }

  async function performSyncOperation(operation) {
    const token = localStorage.getItem('token');
    const headers = {
      'Content-Type': 'application/json',
    };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const resp = await fetch(`/api${operation.endpoint}`, {
      method: operation.method || 'POST',
      headers,
      body: JSON.stringify(operation.data || {})
    });
    if (!resp.ok) {
      const err = new Error(`Sync failed: ${resp.statusText}`);
      err.status = resp.status;
      if (resp.status === 409) err.isConflict = true;
      else if (resp.status >= 400 && resp.status < 500) err.isFatal = true;
      throw err;
    }
    return resp.json();
  }

  async function syncPendingData() {
    if (!isOnline || syncQueue.length === 0) return;
    const remaining = [];
    for (const op of syncQueue) {
      try {
        await performSyncOperation(op);
      } catch (e) {
        if (e.isConflict) {
          await storeData('conflicts', { ...op, error: e.message, conflictTime: new Date().toISOString() });
        } else if (e.isFatal) {
          // drop
        } else {
          remaining.push(op);
        }
      }
    }
    syncQueue = remaining;
    saveSyncQueue();
    lastSyncTime = new Date().toISOString();
    localStorage.setItem('lastSyncTime', lastSyncTime);
  }

  function saveSyncQueue() {
    localStorage.setItem('syncQueue', JSON.stringify(syncQueue));
  }

  async function getOfflineStatus() {
    const conflicts = await getData('conflicts');
    return {
      isOnline,
      pendingSyncCount: syncQueue.length,
      conflictCount: (conflicts || []).length,
      lastSyncTime
    };
  }

  async function forceSync() {
    if (!isOnline) throw new Error('Cannot sync while offline');
    await syncPendingData();
    return true;
  }

  async function clearLocalData() {
    const stores = ['transactions', 'inventory', 'livestock_batches', 'breeding_records', 'sensor_data', 'tasks', 'timesheets', 'fields', 'financial_budgets', 'financial_invoices', 'field_history', 'field_soil', 'field_harvest', 'field_rotation', 'sync_queue', 'conflicts'];
    for (const name of stores) {
      try { await clearStore(name); } catch (e) {}
    }
    syncQueue = [];
    saveSyncQueue();
    localStorage.removeItem('lastSyncTime');
  }

  async function getCachedData(endpoint, storeName, key = null) {
    const token = localStorage.getItem('token');
    const cached = await getData(storeName, key);
    if (cached && ((Array.isArray(cached) && cached.length) || (!Array.isArray(cached)))) {
      return { data: cached, fromCache: true };
    }
    if (isOnline) {
      const headers = {};
      if (token) headers['Authorization'] = `Bearer ${token}`;
      const resp = await fetch(`/api${endpoint}`, { headers });
      if (resp.ok) {
        const data = await resp.json();
        if (Array.isArray(data)) {
          for (const item of data) await storeData(storeName, item);
        } else if (data) {
          await storeData(storeName, data);
        }
        return { data, fromCache: false };
      }
    }
    return { data: cached || null, fromCache: true };
  }

  window.addEventListener('online', () => { isOnline = true; syncPendingData(); });
  window.addEventListener('offline', () => { isOnline = false; });

  window.OfflineService = { storeData, getData, queueForSync, performSyncOperation, syncPendingData, getOfflineStatus, forceSync, clearLocalData, getCachedData };
})();
