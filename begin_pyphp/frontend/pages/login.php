<?php
require_once __DIR__ . '/../simple_auth.php';

$error = null;

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Check if user is already logged in
if (isset($_SESSION['user'])) {
    header('Location: ../public/index.php?page=dashboard');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $email = $_POST['email'] ?? '';
  $password = $_POST['password'] ?? '';
  
  // Debug: Log the attempt
  error_log("Login attempt: email=" . $email . ", password_length=" . strlen($password));
  
  // Try Python API first
  $api_response = call_api('/api/auth/login', 'POST', ['email' => $email, 'password' => $password]);
  
  if ($api_response['status'] === 200 && !empty($api_response['data']['access_token'])) {
    error_log("Python API login successful for: " . $email);
    $_SESSION['access_token'] = $api_response['data']['access_token'];
    $_SESSION['user'] = $api_response['data']['user'];
    
    // Redirect to dashboard
    $redirect_url = '../public/index.php?page=dashboard';
    error_log("Redirecting to: " . $redirect_url);
    header('Location: ' . $redirect_url);
    exit;
  } else {
    error_log("Python API login failed for: " . $email);
    // Fallback to pure PHP authentication
    $user = authenticate_user($email, $password);
    
    if ($user) {
      error_log("Pure PHP fallback successful for: " . $email);
      $_SESSION['user'] = [
          'id' => $user['id'],
          'name' => $user['name'],
          'email' => $user['email'],
          'role' => $user['role']
      ];
      header('Location: ../public/index.php?page=dashboard');
      exit;
    } else {
      error_log("Both API and PHP auth failed for: " . $email);
      $error = 'Invalid email or password';
    }
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
                            100: '#dcfce7',
                            200: '#bbf7d0',
                            300: '#86efac',
                            400: '#4ade80',
                            500: '#22c55e',
                            600: '#16a34a',
                            700: '#15803d',
                            800: '#166534',
                            900: '#14532d',
                        },
                        accent: {
                            50: '#fef3c7',
                            100: '#fde68a',
                            200: '#fcd34d',
                            300: '#fbbf24',
                            400: '#f59e0b',
                            500: '#d97706',
                            600: '#b45309',
                            700: '#92400e',
                            800: '#78350f',
                            900: '#451a03',
                        }
                    },
                    animation: {
                        'float': 'float 6s ease-in-out infinite',
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                        'gradient': 'gradient 8s ease infinite',
                        'slide-up': 'slideUp 0.5s ease-out',
                        'glow': 'glow 2s ease-in-out infinite alternate',
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
                            '100%': { boxShadow: '0 0 30px rgba(34, 197, 94, 0.6)' },
                        }
                    }
                }
            }
        }
    </script>
    <style>
        .gradient-bg {
            background: linear-gradient(-45deg, #22c55e, #16a34a, #15803d, #14532d);
            background-size: 400% 400%;
            animation: gradient 15s ease infinite;
        }
        
        .glass-effect {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .dark .glass-effect {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .neon-text {
            text-shadow: 0 0 10px rgba(34, 197, 94, 0.8),
                         0 0 20px rgba(34, 197, 94, 0.6),
                         0 0 30px rgba(34, 197, 94, 0.4);
        }
        
        .juicy-button {
            background: linear-gradient(45deg, #22c55e, #16a34a);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .juicy-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(34, 197, 94, 0.4);
        }
        
        .juicy-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .juicy-button:hover::before {
            left: 100%;
        }
        
        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 0;
        }
        
        .shape {
            position: absolute;
            background: rgba(34, 197, 94, 0.1);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
        }
        
        .shape:nth-child(1) {
            width: 80px;
            height: 80px;
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }
        
        .shape:nth-child(2) {
            width: 120px;
            height: 120px;
            top: 60%;
            right: 10%;
            animation-delay: 2s;
        }
        
        .shape:nth-child(3) {
            width: 60px;
            height: 60px;
            bottom: 20%;
            left: 20%;
            animation-delay: 4s;
        }
        
        .input-glow:focus {
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.2),
                        0 0 20px rgba(34, 197, 94, 0.1);
        }
        
        .dark .input-glow:focus {
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.3),
                        0 0 20px rgba(34, 197, 94, 0.2);
        }
    </style>
</head>
<body class="h-full gradient-bg flex items-center justify-center p-4">
    <!-- Floating Shapes Background -->
    <div class="floating-shapes">
        <div class="shape"></div>
        <div class="shape"></div>
        <div class="shape"></div>
    </div>

    <!-- Main Container -->
    <div class="relative z-10 w-full max-w-md animate-slide-up">
        <!-- Logo/Brand Section -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-white/20 rounded-2xl glass-effect mb-4 animate-float">
                <svg class="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                </svg>
            </div>
            <h1 class="text-4xl font-bold text-white font-display neon-text mb-2">FarmOS</h1>
            <p class="text-white/80 text-lg">Smart Agriculture Platform</p>
            <p class="text-white/60 text-sm mt-2">Next-Gen Farm Management System</p>
        </div>

        <!-- Login Form -->
        <div class="glass-effect rounded-3xl p-8 shadow-2xl">
            <form class="space-y-6" method="POST" action="">
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
                            class="w-full pl-10 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:border-white/40 input-glow transition-all"
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
                            class="w-full pl-10 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:border-white/40 input-glow transition-all"
                            placeholder="Enter your password"
                        >
                    </div>
                </div>

                <!-- Remember Me & Forgot Password -->
                <div class="flex items-center justify-between">
                    <div class="flex items-center">
                        <input 
                            id="remember-me" 
                            name="remember-me" 
                            type="checkbox" 
                            class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-white/30 rounded bg-white/10"
                        >
                        <label for="remember-me" class="ml-2 block text-sm text-white/80">
                            Remember me
                        </label>
                    </div>

                    <div class="text-sm">
                        <a href="#" class="font-medium text-white/90 hover:text-white transition-colors">
                            Forgot password?
                        </a>
                    </div>
                </div>

                <!-- Error Message -->
                <?php if ($error): ?>
                <div class="rounded-xl bg-red-500/20 border border-red-500/30 p-4 animate-slide-up">
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

            <!-- Social Login Divider -->
            <div class="mt-6">
                <div class="relative">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-white/20"></div>
                    </div>
                    <div class="relative flex justify-center text-sm">
                        <span class="px-4 bg-transparent text-white/60">Or continue with</span>
                    </div>
                </div>

                <!-- Social Login Buttons -->
                <div class="mt-6 grid grid-cols-2 gap-3">
                    <button class="flex items-center justify-center px-4 py-3 bg-white/10 border border-white/20 rounded-xl hover:bg-white/20 transition-all duration-300 group">
                        <svg class="w-5 h-5 text-white/80 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 8.6-8.72c2.6 0 4.507 1.027 5.907 2.347l2.307-2.307C18.747 1.44 16.133 0 12.48 0 5.867 0 .307 5.387.307 12s5.56 12 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/>
                        </svg>
                        <span class="ml-2 text-white/80 group-hover:text-white text-sm font-medium">Google</span>
                    </button>

                    <button class="flex items-center justify-center px-4 py-3 bg-white/10 border border-white/20 rounded-xl hover:bg-white/20 transition-all duration-300 group">
                        <svg class="w-5 h-5 text-white/80 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M11.4 24H0V12.6h11.4V24zM24 24H12.6V12.6H24V24zM11.4 11.4H0V0h11.4v11.4zM24 11.4H12.6V0H24v11.4z"/>
                        </svg>
                        <span class="ml-2 text-white/80 group-hover:text-white text-sm font-medium">Microsoft</span>
                    </button>
                </div>
            </div>

            <!-- Sign Up Link -->
            <div class="mt-8 text-center">
                <p class="text-white/60 text-sm">
                    Don't have an account? 
                    <a href="#" class="font-medium text-white/90 hover:text-white transition-colors">
                        Start your free trial
                    </a>
                </p>
            </div>
        </div>

        <!-- Footer -->
        <div class="mt-8 text-center">
            <p class="text-white/40 text-xs">
                © 2026 FarmOS. Smart Agriculture for Tomorrow.
            </p>
        </div>
    </div>

    <!-- Dark Mode Toggle -->
    <script>
        // Add some interactive effects
        document.addEventListener('DOMContentLoaded', function() {
            // Add ripple effect to buttons
            const buttons = document.querySelectorAll('button');
            buttons.forEach(button => {
                button.addEventListener('click', function(e) {
                    const ripple = document.createElement('span');
                    ripple.classList.add('absolute', 'bg-white', 'rounded-full', 'opacity-30', 'animate-ping');
                    ripple.style.width = ripple.style.height = '20px';
                    ripple.style.left = e.offsetX - 10 + 'px';
                    ripple.style.top = e.offsetY - 10 + 'px';
                    this.appendChild(ripple);
                    setTimeout(() => ripple.remove(), 600);
                });
            });
        });
    </script>
</body>
</html>