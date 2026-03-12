/**
 * FarmOS Enhanced API Client with WebSocket Support
 * Handles real-time updates and improved error handling
 */

// WebSocket connection management
class FarmOSWebSocket {
    constructor() {
        this.ws = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.reconnectInterval = 5000;
        this.subscriptions = new Set();
        this.messageQueue = [];
        this.isConnected = false;
        this.heartbeatInterval = null;
    }

    async connect(userId, token) {
        try {
            const wsUrl = `ws://localhost:8001/ws/${userId}?token=${token}`;
            this.ws = new WebSocket(wsUrl);
            
            this.ws.onopen = () => {
                console.log('WebSocket connected');
                this.isConnected = true;
                this.reconnectAttempts = 0;
                this.startHeartbeat();
                
                // Send queued messages
                while (this.messageQueue.length > 0) {
                    const message = this.messageQueue.shift();
                    this.send(message);
                }
                
                // Resubscribe to previous subscriptions
                this.subscriptions.forEach(sub => {
                    this.subscribe(sub);
                });
                
                // Update UI
                this.updateConnectionStatus(true);
            };
            
            this.ws.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.handleMessage(data);
                } catch (error) {
                    console.error('WebSocket message error:', error);
                }
            };
            
            this.ws.onclose = () => {
                console.log('WebSocket disconnected');
                this.isConnected = false;
                this.stopHeartbeat();
                this.updateConnectionStatus(false);
                this.attemptReconnect();
            };
            
            this.ws.onerror = (error) => {
                console.error('WebSocket error:', error);
                this.isConnected = false;
                this.updateConnectionStatus(false);
            };
            
        } catch (error) {
            console.error('WebSocket connection error:', error);
            this.attemptReconnect();
        }
    }

    send(message) {
        if (this.isConnected && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(message));
        } else {
            // Queue message for when connection is restored
            this.messageQueue.push(message);
        }
    }

    subscribe(type) {
        this.subscriptions.add(type);
        this.send({
            type: 'subscribe',
            subscription: type
        });
    }

    unsubscribe(type) {
        this.subscriptions.delete(type);
    }

    startHeartbeat() {
        this.heartbeatInterval = setInterval(() => {
            if (this.isConnected) {
                this.send({ type: 'ping' });
            }
        }, 30000); // Send ping every 30 seconds
    }

    stopHeartbeat() {
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
            this.heartbeatInterval = null;
        }
    }

    attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`Attempting to reconnect (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
            
            setTimeout(() => {
                // Get current user credentials
                const userId = localStorage.getItem('user_id') || 'demo';
                const token = localStorage.getItem('access_token') || 'demo';
                this.connect(userId, token);
            }, this.reconnectInterval);
        } else {
            console.error('Max reconnection attempts reached');
            this.updateConnectionStatus(false, true);
        }
    }

    handleMessage(data) {
        switch (data.type) {
            case 'connection':
                console.log('Connected to real-time updates');
                break;
            
            case 'pong':
                // Heartbeat response
                break;
            
            case 'dashboard_update':
                this.updateDashboard(data.data);
                break;
            
            case 'notification':
                this.showNotification(data.notification);
                break;
            
            case 'livestock_update':
                this.updateLivestockData(data.data);
                break;
            
            case 'inventory_alert':
                this.showInventoryAlert(data.alert);
                break;
            
            case 'dashboard_data':
                this.refreshDashboard(data.data);
                break;
            
            default:
                console.log('Unknown message type:', data.type);
        }
    }

    updateConnectionStatus(connected, failed = false) {
        const statusElement = document.getElementById('websocket-status');
        if (statusElement) {
            if (connected) {
                statusElement.className = 'flex items-center text-green-600 text-sm';
                statusElement.innerHTML = `
                    <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                    Real-time updates active
                `;
            } else if (failed) {
                statusElement.className = 'flex items-center text-red-600 text-sm';
                statusElement.innerHTML = `
                    <span class="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                    Real-time updates failed
                `;
            } else {
                statusElement.className = 'flex items-center text-yellow-600 text-sm';
                statusElement.innerHTML = `
                    <span class="w-2 h-2 bg-yellow-500 rounded-full mr-2"></span>
                    Reconnecting...
                `;
            }
        }
    }

    updateDashboard(data) {
        // Update dashboard KPIs
        if (data.alerts !== undefined) {
            const alertsElement = document.querySelector('[data-metric="alerts"]');
            if (alertsElement) alertsElement.textContent = data.alerts;
        }
        
        if (data.tasks_due !== undefined) {
            const tasksElement = document.querySelector('[data-metric="tasks"]');
            if (tasksElement) tasksElement.textContent = data.tasks_due;
        }
        
        if (data.livestock_batches !== undefined) {
            const livestockElement = document.querySelector('[data-metric="livestock"]');
            if (livestockElement) livestockElement.textContent = data.livestock_batches;
        }
        
        if (data.inventory_low !== undefined) {
            const inventoryElement = document.querySelector('[data-metric="inventory"]');
            if (inventoryElement) inventoryElement.textContent = data.inventory_low;
        }
    }

    showNotification(notification) {
        // Create notification element
        const notificationElement = document.createElement('div');
        notificationElement.className = 'fixed top-4 right-4 bg-white shadow-lg rounded-lg p-4 z-50 max-w-sm border-l-4 border-blue-500';
        notificationElement.innerHTML = `
            <div class="flex items-start">
                <div class="flex-shrink-0">
                    <svg class="h-6 w-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h4 class="text-sm font-medium text-gray-900">${notification.title || 'Notification'}</h4>
                    <p class="text-sm text-gray-500">${notification.message || ''}</p>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-gray-400 hover:text-gray-600">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
        `;
        
        document.body.appendChild(notificationElement);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notificationElement.parentElement) {
                notificationElement.remove();
            }
        }, 5000);
    }

    updateLivestockData(data) {
        // Update livestock-related UI elements
        console.log('Livestock update:', data);
        // Implementation depends on your UI structure
    }

    showInventoryAlert(alert) {
        // Show inventory alert
        console.log('Inventory alert:', alert);
        // Implementation depends on your UI structure
    }

    refreshDashboard(data) {
        // Refresh entire dashboard with new data
        console.log('Dashboard refresh:', data);
        // Reload page or update specific elements
        if (typeof refreshDashboardData === 'function') {
            refreshDashboardData(data);
        }
    }

    disconnect() {
        if (this.ws) {
            this.ws.close();
            this.ws = null;
        }
        this.isConnected = false;
        this.stopHeartbeat();
    }
}

// Global WebSocket instance
let farmOSWebSocket = null;

// Initialize WebSocket when page loads
document.addEventListener('DOMContentLoaded', function() {
    // Check if user is logged in
    const userId = localStorage.getItem('user_id');
    const token = localStorage.getItem('access_token');
    
    if (userId && token) {
        farmOSWebSocket = new FarmOSWebSocket();
        farmOSWebSocket.connect(userId, token);
        
        // Subscribe to dashboard updates
        farmOSWebSocket.subscribe('dashboard');
        farmOSWebSocket.subscribe('notifications');
    }
});

// WebSocket connection status indicator
function addWebSocketStatusIndicator() {
    const header = document.querySelector('header');
    if (header && !document.getElementById('websocket-status')) {
        const statusDiv = document.createElement('div');
        statusDiv.id = 'websocket-status';
        statusDiv.className = 'flex items-center text-gray-600 text-sm ml-4';
        statusDiv.innerHTML = `
            <span class="w-2 h-2 bg-gray-500 rounded-full mr-2"></span>
            Connecting...
        `;
        
        const headerActions = header.querySelector('.flex.items-center.justify-end');
        if (headerActions) {
            headerActions.appendChild(statusDiv);
        }
    }
}

// Add status indicator to page
addWebSocketStatusIndicator();
