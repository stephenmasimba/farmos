// State Persistence for User Preferences

const Preferences = {
    key: 'farmos_preferences',
    
    defaults: {
        theme: 'light', // 'light' or 'dark'
        sidebar: 'expanded' // 'expanded' or 'collapsed'
    },

    get: function() {
        const stored = localStorage.getItem(this.key);
        return stored ? { ...this.defaults, ...JSON.parse(stored) } : this.defaults;
    },

    set: function(key, value) {
        const prefs = this.get();
        prefs[key] = value;
        localStorage.setItem(this.key, JSON.stringify(prefs));
        this.apply();
    },

    apply: function() {
        const prefs = this.get();
        
        // Apply Theme
        const html = document.documentElement;
        if (prefs.theme === 'dark') {
            html.classList.add('dark');
        } else {
            html.classList.remove('dark');
        }

        // Apply other preferences if needed
        console.log('Preferences applied:', prefs);
    },

    init: function() {
        this.apply();
        // Add listener for system theme changes if user hasn't set a preference?
        // For now, stick to manual toggle.
    },
    
    toggleTheme: function() {
        const current = this.get().theme;
        const next = current === 'light' ? 'dark' : 'light';
        this.set('theme', next);
        return next;
    }
};

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    Preferences.init();
    
    // Bind toggle button if it exists
    const themeToggle = document.getElementById('theme-toggle');
    if (themeToggle) {
        themeToggle.addEventListener('click', (e) => {
            e.preventDefault();
            Preferences.toggleTheme();
        });
    }
});
