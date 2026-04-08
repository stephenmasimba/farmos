<?php
require_once 'pure_auth.php';

$error = null;

// Check if user is already logged in
if (is_logged_in_pure()) {
    header('Location: dashboard_pure.php');
    exit;
}

// Handle login
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    $user = authenticate_user_pure($email, $password);
    
    if ($user) {
        $_SESSION['user'] = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ];
        header('Location: dashboard_pure.php');
        exit;
    } else {
        $error = 'Invalid email or password';
    }
}
?>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FarmOS - Smart Agriculture Platform</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        display: ['Space Grotesk', 'sans-serif'],
                    },
                    colors: {
                        primary: {
                            50: '#f0fdf4',
                            500: '#22c55e',
                            600: '#16a34a',
                            700: '#15803d',
                        }
                    },
                    animation: {
                        'float': 'float 3s ease-in-out infinite',
                        'gradient': 'gradient 8s ease infinite',
                        'slideUp': 'slideUp 0.5s ease-out',
                        'glow': 'glow 2s ease-in-out infinite',
                    },
                    keyframes: {
                        float: {
                            '0%, 100%': { transform: 'translateY(0px)' },
                            '50%': { transform: 'translateY(-20px)' },
                        },
                        gradient: {
                            '0%, 100%': { backgroundPosition: '0% 50%' },
                            '50%': { backgroundPosition: '100% 50%' },
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(20px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' },
                        },
                        glow: {
                            '0%': { boxShadow: '0 0 20px rgba(34, 197, 94, 0.3)' },
                            '50%': { boxShadow: '0 0 30px rgba(34, 197, 94, 0.6)' },
                            '100%': { boxShadow: '0 0 20px rgba(34, 197, 94, 0.3)' },
                        }
                    }
                }
            }
        }
    </script>
    <style>
        .glass-effect {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .neon-text {
            text-shadow: 0 0 10px rgba(34, 197, 94, 0.8),
                         0 0 20px rgba(34, 197, 94, 0.6),
                         0 0 30px rgba(34, 197, 94, 0.4);
        }
        
        .juicy-button {
            background: linear-gradient(45deg, #22c55e, #16a34a);
            position: relative;
            overflow: hidden;
        }
        
        .juicy-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }
        
        .juicy-button:hover::before {
            left: 100%;
        }
        
        .animated-bg {
            background: linear-gradient(-45deg, #22c55e, #16a34a, #15803d, #22c55e);
            background-size: 400% 400%;
            animation: gradient 8s ease infinite;
        }
        
        .floating-shape {
            position: absolute;
            opacity: 0.1;
            animation: float 3s ease-in-out infinite;
        }
    </style>
</head>
<body class="animated-bg min-h-screen flex items-center justify-center relative overflow-hidden">
    <!-- Floating Background Shapes -->
    <div class="floating-shape top-10 left-10 w-20 h-20 bg-white rounded-full"></div>
    <div class="floating-shape top-20 right-20 w-32 h-32 bg-white rounded-full" style="animation-delay: 1s;"></div>
    <div class="floating-shape bottom-20 left-20 w-16 h-16 bg-white rounded-full" style="animation-delay: 2s;"></div>
    <div class="floating-shape bottom-10 right-10 w-24 h-24 bg-white rounded-full" style="animation-delay: 0.5s;"></div>

    <!-- Login Container -->
    <div class="w-full max-w-md mx-auto p-4 relative z-10">
        <!-- Logo Section -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-white/20 rounded-full mb-4">
                <svg class="w-10 h-10 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                </svg>
            </div>
            <h1 class="text-4xl font-bold text-white font-display neon-text mb-2">FarmOS</h1>
            <p class="text-white/80 text-lg">Smart Agriculture Platform</p>
            <p class="text-white/60 text-sm mt-2">Pure PHP Authentication</p>
        </div>

        <!-- Login Form -->
        <div class="glass-effect rounded-3xl p-8 shadow-2xl">
            <?php if ($error): ?>
                <div class="mb-6 p-4 bg-red-500/20 border border-red-500/30 rounded-xl">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <h3 class="text-sm font-medium text-red-300">Login failed</h3>
                            <div class="mt-1 text-sm text-red-200">
                                <p><?= htmlspecialchars($error) ?></p>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endif; ?>

            <form method="POST" action="" class="space-y-6">
                <!-- Email Input -->
                <div class="space-y-2">
                    <label for="email" class="block text-sm font-medium text-white/90">
                        Email Address
                    </label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <svg class="h-5 w-5 text-white/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                            </svg>
                        </div>
                        <input 
                            id="email" 
                            name="email" 
                            type="email" 
                            autocomplete="email" 
                            required 
                            value="manager@masimba.farm"
                            class="block w-full pl-10 pr-3 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-300"
                            placeholder="Enter your email"
                        >
                    </div>
                </div>

                <!-- Password Input -->
                <div class="space-y-2">
                    <label for="password" class="block text-sm font-medium text-white/90">
                        Password
                    </label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <svg class="h-5 w-5 text-white/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                            </svg>
                        </div>
                        <input 
                            id="password" 
                            name="password" 
                            type="password" 
                            autocomplete="current-password" 
                            required 
                            value="manager123"
                            class="block w-full pl-10 pr-3 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-300"
                            placeholder="Enter your password"
                        >
                    </div>
                </div>

                <!-- Remember Me -->
                <div class="flex items-center">
                    <input 
                        id="remember-me" 
                        name="remember-me" 
                        type="checkbox" 
                        class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-white/30 rounded bg-white/10"
                    >
                    <label for="remember-me" class="ml-2 block text-sm text-white/70">
                        Remember me for 30 days
                    </label>
                </div>

                <!-- Submit Button -->
                <div>
                    <button 
                        type="submit" 
                        class="w-full juicy-button text-white font-semibold py-4 px-6 rounded-xl shadow-lg transform transition-all duration-300 hover:scale-105"
                    >
                        <span class="relative z-10">Sign In to FarmOS</span>
                    </button>
                </div>
            </form>

            <!-- Test Credentials Info -->
            <div class="mt-6 p-4 bg-white/10 rounded-xl">
                <p class="text-white/80 text-sm font-medium mb-2">🔑 Test Credentials:</p>
                <p class="text-white/60 text-xs">Email: manager@masimba.farm</p>
                <p class="text-white/60 text-xs">Password: manager123</p>
            </div>
        </div>
    </div>
</body>
</html>
