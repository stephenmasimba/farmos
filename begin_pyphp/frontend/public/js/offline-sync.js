// offline-sync.js

const DB_NAME = 'FarmOS_DB';
const STORE_NAME = 'offline_actions';
const DB_VERSION = 1;

let db;

// Initialize IndexedDB
const request = indexedDB.open(DB_NAME, DB_VERSION);

request.onupgradeneeded = (event) => {
    db = event.target.result;
    if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, { keyPath: 'id', autoIncrement: true });
    }
};

request.onsuccess = (event) => {
    db = event.target.result;
    console.log('Offline DB initialized');
    // Try to sync on load if online
    if (navigator.onLine) {
        syncOfflineActions();
    }
};

request.onerror = (event) => {
    console.error('Offline DB error:', event.target.error);
};

// Function to save action when offline
function saveOfflineAction(url, method, data) {
    const transaction = db.transaction([STORE_NAME], 'readwrite');
    const store = transaction.objectStore(STORE_NAME);
    const action = {
        url: url,
        method: method,
        data: data,
        timestamp: new Date().toISOString()
    };
    store.add(action);
    console.log('Action saved offline:', action);
}

// Function to sync data when back online
async function syncOfflineActions() {
    const transaction = db.transaction([STORE_NAME], 'readonly');
    const store = transaction.objectStore(STORE_NAME);
    const request = store.getAll();

    request.onsuccess = async () => {
        const actions = request.result;
        if (actions.length === 0) return;

        console.log(`Syncing ${actions.length} offline actions...`);

        for (const action of actions) {
            try {
                const response = await fetch(action.url, {
                    method: action.method,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-API-Key': 'local-dev-key' // Or get from session
                    },
                    body: JSON.stringify(action.data)
                });

                if (response.ok) {
                    // Remove from DB if successful
                    const deleteTx = db.transaction([STORE_NAME], 'readwrite');
                    deleteTx.objectStore(STORE_NAME).delete(action.id);
                }
            } catch (error) {
                console.error('Sync failed for action:', action, error);
            }
        }
    };
}

// Listen for online status
window.addEventListener('online', syncOfflineActions);
window.addEventListener('offline', () => console.log('App is offline'));
