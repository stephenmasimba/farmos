        </main>
    </div>
</div>
<script>
    // Mobile menu toggle logic
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');

    if (mobileMenuButton) {
        mobileMenuButton.addEventListener('click', () => {
            sidebar.classList.toggle('-translate-x-full');
            overlay.classList.toggle('hidden');
        });
    }

    if (overlay) {
        overlay.addEventListener('click', () => {
            sidebar.classList.add('-translate-x-full');
            overlay.classList.add('hidden');
        });
    }

    (function initGlobalNoticeSystem() {
        const el = document.getElementById('global-app-notice');
        if (!el) {
            return;
        }

        const styles = {
            success: 'border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300',
            error: 'border-red-200 bg-red-50 text-red-700 dark:border-red-700 dark:bg-red-900/30 dark:text-red-300',
            warning: 'border-amber-200 bg-amber-50 text-amber-700 dark:border-amber-700 dark:bg-amber-900/30 dark:text-amber-300',
            info: 'border-blue-200 bg-blue-50 text-blue-700 dark:border-blue-700 dark:bg-blue-900/30 dark:text-blue-300'
        };

        let hideTimer = null;

        function showNotice(message, kind = 'info', timeoutMs = 6000) {
            if (!message) return;
            if (hideTimer) {
                clearTimeout(hideTimer);
                hideTimer = null;
            }

            el.className = `mb-4 rounded-lg border px-4 py-3 text-sm ${styles[kind] || styles.info}`;
            el.textContent = String(message);
            el.classList.remove('hidden');

            if (timeoutMs > 0) {
                hideTimer = setTimeout(() => {
                    el.classList.add('hidden');
                }, timeoutMs);
            }
        }

        function hideNotice() {
            if (hideTimer) {
                clearTimeout(hideTimer);
                hideTimer = null;
            }
            el.classList.add('hidden');
        }

        window.AppNotice = {
            show: showNotice,
            hide: hideNotice,
            success: (message, timeoutMs = 5000) => showNotice(message, 'success', timeoutMs),
            error: (message, timeoutMs = 7000) => showNotice(message, 'error', timeoutMs),
            warning: (message, timeoutMs = 7000) => showNotice(message, 'warning', timeoutMs),
            info: (message, timeoutMs = 5000) => showNotice(message, 'info', timeoutMs)
        };

        const nativeAlert = window.alert.bind(window);
        window.alert = function appAlertReplacement(message) {
            if (!message) {
                nativeAlert(message);
                return;
            }
            showNotice(message, 'info', 6000);
        };

        window.addEventListener('offline', () => showNotice('You are offline. Changes may be queued for sync.', 'warning', 8000));
        window.addEventListener('online', () => showNotice('Connection restored. You are back online.', 'success', 4000));

        document.addEventListener('submit', (event) => {
            const form = event.target;
            if (!(form instanceof HTMLFormElement)) {
                return;
            }

            if (!form.checkValidity()) {
                event.preventDefault();
                form.reportValidity();
                showNotice('Please correct highlighted fields before submitting.', 'warning', 6000);
            }
        }, true);
    })();
</script>
</body>
</html>
