/**
 * FarmOS QR Scanner Component
 * Mobile QR code scanning for livestock identification and tracking
 */

class FarmOSQRScanner {
    constructor() {
        this.scanner = null;
        this.isScanning = false;
        this.lastScanResult = null;
        this.scanHistory = [];
        this.cameraActive = false;
    }

    async init() {
        try {
            // Check if camera is available
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                console.error('Camera API not available');
                this.showNotification('Camera not available', 'error');
                return;
            }

            // Initialize UI
            this.setupScannerUI();
            this.setupEventListeners();
            
            console.log('QR Scanner initialized');
        } catch (error) {
            console.error('Error initializing QR scanner:', error);
            this.showNotification('Failed to initialize scanner', 'error');
        }
    }

    setupScannerUI() {
        // Create scanner modal
        const scannerHTML = `
            <div id="qr-scanner-modal" class="fixed inset-0 bg-black bg-opacity-75 z-50 hidden flex items-center justify-center">
                <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-gray-900">Livestock QR Scanner</h3>
                        <button onclick="farmOSQRScanner.closeScanner()" class="text-gray-400 hover:text-gray-600">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>
                    
                    <div class="mb-4">
                        <video id="qr-video" class="w-full h-64 bg-black rounded-lg" autoplay muted playsinline></video>
                        <canvas id="qr-canvas" class="hidden"></canvas>
                    </div>
                    
                    <div class="mb-4">
                        <div class="flex space-x-2">
                            <button onclick="farmOSQRScanner.startScanning()" id="start-scan-btn" class="flex-1 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500">
                                Start Scanning
                            </button>
                            <button onclick="farmOSQRScanner.stopScanning()" id="stop-scan-btn" class="flex-1 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500" disabled>
                                Stop Scanning
                            </button>
                        </div>
                    </div>
                    
                    <div id="scan-result" class="mb-4 p-4 bg-gray-50 rounded-lg hidden">
                        <h4 class="font-semibold text-gray-900 mb-2">Scan Result</h4>
                        <div id="scan-result-content"></div>
                    </div>
                    
                    <div class="mb-4">
                        <h4 class="font-semibold text-gray-900 mb-2">Recent Scans</h4>
                        <div id="scan-history" class="max-h-32 overflow-y-auto space-y-2">
                            <p class="text-gray-500 text-sm">No scans yet</p>
                        </div>
                    </div>
                    
                    <div class="flex justify-end space-x-2">
                        <button onclick="farmOSQRScanner.clearHistory()" class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-green-500">
                            Clear History
                        </button>
                        <button onclick="farmOSQRScanner.exportHistory()" class="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500">
                            Export History
                        </button>
                    </div>
                </div>
            </div>
        `;

        // Add to page
        const scannerContainer = document.createElement('div');
        scannerContainer.innerHTML = scannerHTML;
        document.body.appendChild(scannerContainer);
    }

    setupEventListeners() {
        // Keyboard shortcuts
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                this.closeScanner();
            } else if (event.key === 'Enter' && this.isScanning) {
                this.stopScanning();
            } else if (event.key === ' ' && !this.isScanning) {
                this.startScanning();
            }
        });

        // Handle visibility change (pause scanning when tab is not visible)
        document.addEventListener('visibilitychange', () => {
            if (document.hidden && this.isScanning) {
                this.pauseScanning();
            } else if (!document.hidden && this.scanner && this.isScanning) {
                this.resumeScanning();
            }
        });
    }

    async startScanning() {
        try {
            if (this.isScanning) {
                console.log('Scanning already in progress');
                return;
            }

            // Request camera access
            const stream = await navigator.mediaDevices.getUserMedia({
                video: { 
                    facingMode: 'environment', // Prefer rear camera
                    width: { ideal: 640 },
                    height: { ideal: 480 }
                }
            });

            // Setup video stream
            const video = document.getElementById('qr-video');
            video.srcObject = stream;
            video.play();

            this.cameraActive = true;
            this.isScanning = true;

            // Update UI
            document.getElementById('start-scan-btn').disabled = true;
            document.getElementById('stop-scan-btn').disabled = false;

            // Start QR code scanning
            this.startQRCodeScanning();

            this.showNotification('Scanner started', 'success');

        } catch (error) {
            console.error('Error starting scanner:', error);
            this.showNotification('Failed to start camera', 'error');
        }
    }

    stopScanning() {
        try {
            if (!this.isScanning) {
                console.log('No scanning in progress');
                return;
            }

            // Stop video stream
            const video = document.getElementById('qr-video');
            if (video.srcObject) {
                video.srcObject.getTracks().forEach(track => track.stop());
                video.srcObject = null;
            }

            this.cameraActive = false;
            this.isScanning = false;

            // Update UI
            document.getElementById('start-scan-btn').disabled = false;
            document.getElementById('stop-scan-btn').disabled = true;

            this.showNotification('Scanner stopped', 'info');

        } catch (error) {
            console.error('Error stopping scanner:', error);
            this.showNotification('Failed to stop scanner', 'error');
        }
    }

    pauseScanning() {
        // Pause scanning when tab is not visible
        if (this.scanner) {
            this.scanner.pause();
            this.showNotification('Scanner paused (tab inactive)', 'info');
        }
    }

    resumeScanning() {
        // Resume scanning when tab becomes visible
        if (this.scanner) {
            this.scanner.resume();
            this.showNotification('Scanner resumed', 'info');
        }
    }

    startQRCodeScanning() {
        // Initialize QR code scanner (using html5-qrcode library)
        if (typeof Html5Qrcode === 'undefined') {
            // Load the library if not available
            this.loadQRCodeLibrary(() => {
                this.initializeScanner();
            });
        } else {
            this.initializeScanner();
        }
    }

    loadQRCodeLibrary(callback) {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js';
        script.onload = callback;
        script.onerror = () => {
            console.error('Failed to load QR code library');
            this.showNotification('Failed to load QR scanner library', 'error');
        };
        document.head.appendChild(script);
    }

    initializeScanner() {
        try {
            const video = document.getElementById('qr-video');
            const canvas = document.getElementById('qr-canvas');
            const context = canvas.getContext('2d');

            this.scanner = new Html5Qrcode(
                video,
                {
                    verbose: false,
                    experimentalFeatures: {
                        useBarCodeDetectorIfSupport: true
                    }
                },
                true,
                (decodedText, decodedResult) => {
                    this.handleQRCodeScan(decodedText, decodedResult);
                }
            );

            // Start scanning loop
            const scan = () => {
                if (video.readyState === video.HAVE_STATE) {
                    canvas.height = video.videoHeight;
                    canvas.width = video.videoWidth;
                    context.drawImage(video, 0, 0, canvas.width, canvas.height);
                    
                    try {
                        this.scanner.scan();
                    } catch (e) {
                        // Scan error, continue
                    }
                }

                if (this.isScanning) {
                    requestAnimationFrame(scan);
                }
            };

            requestAnimationFrame(scan);

        } catch (error) {
            console.error('Error initializing QR scanner:', error);
            this.showNotification('Failed to initialize QR scanner', 'error');
        }
    }

    handleQRCodeScan(decodedText, decodedResult) {
        if (!decodedText) {
            return;
        }

        // Prevent duplicate scans
        if (this.lastScanResult === decodedText) {
            return;
        }

        this.lastScanResult = decodedText;

        // Parse QR code data
        const scanData = this.parseQRCodeData(decodedText);

        // Add to scan history
        this.addToScanHistory(scanData);

        // Show result
        this.displayScanResult(scanData);

        // Process the scan (send to server)
        this.processScanResult(scanData);

        // Vibrate/haptic feedback
        if (navigator.vibrate) {
            navigator.vibrate(200);
        }

        console.log('QR Code scanned:', decodedText);
    }

    parseQRCodeData(qrText) {
        try {
            // Try to parse as JSON first
            const jsonData = JSON.parse(qrText);
            return {
                type: 'structured',
                data: jsonData,
                raw: qrText,
                scanTime: new Date().toISOString()
            };
        } catch (e) {
            // If not JSON, treat as simple text
            return {
                type: 'simple',
                data: qrText,
                raw: qrText,
                scanTime: new Date().toISOString()
            };
        }
    }

    addToScanHistory(scanData) {
        this.scanHistory.unshift(scanData);
        
        // Keep only last 50 scans
        if (this.scanHistory.length > 50) {
            this.scanHistory = this.scanHistory.slice(0, 50);
        }

        this.updateScanHistoryUI();
    }

    updateScanHistoryUI() {
        const historyContainer = document.getElementById('scan-history');
        
        if (this.scanHistory.length === 0) {
            historyContainer.innerHTML = '<p class="text-gray-500 text-sm">No scans yet</p>';
            return;
        }

        const historyHTML = this.scanHistory.slice(0, 10).map((scan, index) => `
            <div class="flex items-center justify-between p-2 bg-gray-50 rounded hover:bg-gray-100 cursor-pointer" onclick="farmOSQRScanner.viewScanDetails(${index})">
                <div class="flex-1">
                    <div class="font-medium text-gray-900">${this.formatScanData(scan.data)}</div>
                    <div class="text-xs text-gray-500">${new Date(scan.scanTime).toLocaleString()}</div>
                </div>
                <div class="text-xs text-gray-400">
                    ${scan.type === 'structured' ? '📋' : '📝'}
                </div>
            </div>
        `).join('');

        historyContainer.innerHTML = historyHTML;
    }

    formatScanData(data) {
        if (typeof data === 'object') {
            if (data.type === 'livestock') {
                return `${data.breed} - ${data.id} (${data.quantity} units)`;
            } else if (data.type === 'feed') {
                return `Feed: ${data.name} (${data.batch})`;
            } else if (data.type === 'equipment') {
                return `Equipment: ${data.name} (${data.id})`;
            }
            return JSON.stringify(data);
        }
        return data;
    }

    displayScanResult(scanData) {
        const resultContainer = document.getElementById('scan-result');
        const resultContent = document.getElementById('scan-result-content');

        resultContainer.classList.remove('hidden');

        if (scanData.type === 'structured') {
            resultContent.innerHTML = `
                <div class="space-y-2">
                    <div class="flex items-center space-x-2">
                        <span class="px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded">Livestock</span>
                        <span class="font-medium">Breed: ${scanData.data.breed || 'Unknown'}</span>
                    </div>
                    <div class="flex items-center space-x-2">
                        <span class="px-2 py-1 bg-blue-100 text-blue-800 text-xs font-medium rounded">ID: ${scanData.data.id || 'Unknown'}</span>
                        <span class="font-medium">Quantity: ${scanData.data.quantity || 'Unknown'}</span>
                    </div>
                    <div class="flex items-center space-x-2">
                        <span class="px-2 py-1 bg-purple-100 text-purple-800 text-xs font-medium rounded">Location: ${scanData.data.location || 'Unknown'}</span>
                        <span class="font-medium">Age: ${scanData.data.age || 'Unknown'}</span>
                    </div>
                    ${scanData.data.notes ? `<div class="text-sm text-gray-600">Notes: ${scanData.data.notes}</div>` : ''}
                </div>
            `;
        } else {
            resultContent.innerHTML = `
                <div class="space-y-2">
                    <div class="p-3 bg-yellow-50 border border-yellow-200 rounded">
                        <div class="text-sm font-medium text-yellow-800">Simple QR Code</div>
                        <div class="text-xs text-gray-600 mt-1">${scanData.raw}</div>
                    </div>
                </div>
            `;
        }
    }

    viewScanDetails(index) {
        const scan = this.scanHistory[index];
        alert(`Scan Details:\n\nType: ${scan.type}\nData: ${JSON.stringify(scan.data, null, 2)}\nTime: ${new Date(scan.scanTime).toLocaleString()}`);
    }

    async processScanResult(scanData) {
        try {
            // Send scan data to server
            const response = await fetch('/api/livestock/qr-scan', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-API-Key': localStorage.getItem('api_key') || 'local-dev-key',
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                },
                body: JSON.stringify(scanData)
            });

            const result = await response.json();

            if (response.ok) {
                this.showNotification('Scan processed successfully', 'success');
                
                // Trigger WebSocket update
                if (window.farmOSWebSocket) {
                    window.farmOSWebSocket.send({
                        type: 'livestock_scan',
                        data: {
                            scanData: scanData,
                            serverResponse: result
                        }
                    });
                }
            } else {
                this.showNotification('Failed to process scan', 'error');
            }

        } catch (error) {
            console.error('Error processing scan result:', error);
            this.showNotification('Failed to process scan', 'error');
        }
    }

    clearHistory() {
        this.scanHistory = [];
        this.updateScanHistoryUI();
        this.showNotification('Scan history cleared', 'info');
    }

    exportHistory() {
        if (this.scanHistory.length === 0) {
            this.showNotification('No scans to export', 'warning');
            return;
        }

        const csvContent = this.generateCSV();
        this.downloadCSV(csvContent);
        this.showNotification('Scan history exported', 'success');
    }

    generateCSV() {
        const headers = ['Scan Time', 'Type', 'Data', 'Raw Text'];
        const rows = this.scanHistory.map(scan => [
            new Date(scan.scanTime).toLocaleString(),
            scan.type,
            JSON.stringify(scan.data),
            scan.raw
        ]);

        return [headers, ...rows].map(row => row.join(',')).join('\n');
    }

    downloadCSV(csvContent) {
        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `farmos_qr_scans_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    showScanner() {
        document.getElementById('qr-scanner-modal').classList.remove('hidden');
    }

    closeScanner() {
        this.stopScanning();
        document.getElementById('qr-scanner-modal').classList.add('hidden');
    }

    showNotification(message, type = 'info') {
        // Create notification
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 p-4 rounded-lg shadow-lg z-50 max-w-sm ${
            type === 'success' ? 'bg-green-50 border-green-200' :
            type === 'error' ? 'bg-red-50 border-red-200' :
            type === 'warning' ? 'bg-yellow-50 border-yellow-200' :
            'bg-blue-50 border-blue-200'
        }`;
        
        notification.innerHTML = `
            <div class="flex">
                <div class="flex-shrink-0">
                    ${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}
                </div>
                <div class="ml-3">
                    <p class="text-sm font-medium text-gray-900">${message}</p>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-gray-400 hover:text-gray-600">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
        `;

        document.body.appendChild(notification);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.parentElement.removeChild(notification);
            }
        }, 5000);
    }

    // Public method to open scanner from external calls
    openScanner() {
        this.showScanner();
    }
}

// Initialize global instance
window.farmOSQRScanner = new FarmOSQRScanner();

// Auto-initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.farmOSQRScanner.init();
});
