<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>R-edupahana - Online Billing System</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #2B6CB0 0%, #4299E1 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
            position: relative;
        }

        /* Floating background elements */
        .bg-shapes {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 0;
        }

        .shape {
            position: absolute;
            opacity: 0.1;
            border-radius: 50%;
            background: white;
            animation: floatShape 20s infinite linear;
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
            animation-delay: -7s;
        }

        .shape:nth-child(3) {
            width: 60px;
            height: 60px;
            top: 80%;
            left: 80%;
            animation-delay: -14s;
        }

        @keyframes floatShape {
            0% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
            100% { transform: translateY(0) rotate(360deg); }
        }

        .main-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 1200px;
            min-height: 500px;
            padding: 40px;
            position: relative;
            z-index: 1;
            animation: slideIn 0.8s ease-out;
            display: grid;
            grid-template-columns: 300px 1fr 300px;
            grid-template-rows: auto 1fr auto;
            gap: 30px;
            align-items: start;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(30px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .logo-section {
            grid-column: 1;
            grid-row: 1;
            text-align: center;
        }

        .logo-img {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #2B6CB0 0%, #3182CE 100%);
            border-radius: 20px;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            color: white;
            box-shadow: 0 8px 25px rgba(43, 108, 176, 0.4);
            animation: pulse 3s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .system-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2A4365;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }

        .system-subtitle {
            font-size: 0.9rem;
            color: #718096;
            margin-bottom: 25px;
            font-weight: 500;
        }

        .hero-section {
            grid-column: 2;
            grid-row: 1 / 3;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .library-bg {
            background-image: url('https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600&h=400&fit=crop&crop=center');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            border-radius: 12px;
            height: 200px;
            width: 100%;
            margin-bottom: 20px;
            position: relative;
        }

        .library-bg::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, rgba(43, 108, 176, 0.8), rgba(50, 130, 206, 0.8));
            border-radius: 12px;
        }

        .library-bg-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 1.2rem;
            font-weight: 600;
            text-align: center;
            z-index: 2;
        }

        .features-section {
            grid-column: 3;
            grid-row: 1;
        }

        .features-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
            margin-bottom: 25px;
        }

        .feature-card {
            background: #f7fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 15px;
            transition: all 0.3s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .feature-card:hover {
            background: linear-gradient(135deg, #2B6CB0 0%, #3182CE 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(43, 108, 176, 0.3);
        }

        .feature-icon {
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .feature-content {
            flex: 1;
        }

        .feature-title {
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 3px;
        }

        .feature-desc {
            font-size: 0.75rem;
            opacity: 0.8;
        }

        .access-info {
            grid-column: 1;
            grid-row: 2;
            background: linear-gradient(135deg, rgba(43, 108, 176, 0.1) 0%, rgba(66, 153, 225, 0.1) 100%);
            border: 1px solid rgba(43, 108, 176, 0.2);
            border-radius: 10px;
            padding: 20px;
            height: fit-content;
        }

        .access-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2A4365;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .role-tags {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .role-tag {
            background: #2B6CB0;
            color: white;
            padding: 8px 15px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            text-align: center;
        }

        .role-tag.admin {
            background: #2c3e50;
        }

        .role-tag.cashier {
            background: #2F5249;
        }

        .login-section {
            grid-column: 3;
            grid-row: 2;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .login-button {
            width: 100%;
            background: linear-gradient(135deg, #2B6CB0 0%, #3182CE 100%);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 16px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(43, 108, 176, 0.4);
        }

        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(43, 108, 176, 0.5);
        }

        .login-button:active {
            transform: translateY(0);
        }

        .system-stats {
            display: flex;
            justify-content: space-around;
            padding: 15px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            background: #f7fafc;
        }

        .stat-item {
            text-align: center;
        }

        .stat-number {
            font-size: 1rem;
            font-weight: 700;
            color: #2B6CB0;
        }

        .stat-label {
            font-size: 0.75rem;
            color: #718096;
            margin-top: 3px;
        }

        .footer-section {
            grid-column: 1 / 4;
            grid-row: 3;
            text-align: center;
            border-top: 1px solid #e2e8f0;
            padding-top: 20px;
        }

        .copyright {
            font-size: 0.8rem;
            color: #a0aec0;
        }

        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #2B6CB0 0%, #4299E1 100%);
            display: none;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 10000;
            color: white;
        }

        .loading-overlay.show {
            display: flex;
        }

        .loading-spinner {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-text {
            font-size: 1rem;
            font-weight: 500;
        }

        /* Responsive adjustments */
        @media (max-width: 1024px) {
            .main-container {
                grid-template-columns: 1fr;
                grid-template-rows: auto auto auto auto;
                max-width: 800px;
                gap: 20px;
            }

            .logo-section,
            .hero-section,
            .features-section,
            .access-info,
            .login-section {
                grid-column: 1;
            }

            .hero-section {
                grid-row: 2;
            }

            .features-section {
                grid-row: 3;
            }

            .access-info {
                grid-row: 4;
            }

            .login-section {
                grid-row: 5;
            }

            .footer-section {
                grid-column: 1;
                grid-row: 6;
            }

            .features-grid {
                grid-template-columns: 1fr 1fr;
            }

            .role-tags {
                flex-direction: row;
            }
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 25px 20px;
            }

            .system-title {
                font-size: 1.5rem;
            }

            .logo-img {
                width: 70px;
                height: 70px;
                font-size: 2rem;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .feature-card {
                padding: 12px;
            }

            .library-bg {
                height: 150px;
            }
        }
    </style>
</head>
<body>
    <!-- Background Shapes -->
    <div class="bg-shapes">
        <div class="shape"></div>
        <div class="shape"></div>
        <div class="shape"></div>
    </div>

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
        <div class="loading-text">Initializing System...</div>
    </div>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Logo Section -->
        <div class="logo-section">
            <div class="logo-img">📚</div>
            <h1 class="system-title">R-edupahana</h1>
            <p class="system-subtitle">Library & Billing Management</p>
        </div>

        <!-- Hero Section -->
        <div class="hero-section">
            <div class="library-bg">
                <div class="library-bg-text">Modern POS System</div>
            </div>
        </div>

        <!-- Features Section -->
        <div class="features-section">
            <div class="features-grid">
                <div class="feature-card">
                    <i class="fas fa-book feature-icon"></i>
                    <div class="feature-content">
                        <div class="feature-title">Books</div>
                        <div class="feature-desc">Inventory Management</div>
                    </div>
                </div>
                <div class="feature-card">
                    <i class="fas fa-users feature-icon"></i>
                    <div class="feature-content">
                        <div class="feature-title">Customers</div>
                        <div class="feature-desc">Account Management</div>
                    </div>
                </div>
                <div class="feature-card">
                    <i class="fas fa-receipt feature-icon"></i>
                    <div class="feature-content">
                        <div class="feature-title">Billing</div>
                        <div class="feature-desc">POS Operations</div>
                    </div>
                </div>
                <div class="feature-card">
                    <i class="fas fa-chart-bar feature-icon"></i>
                    <div class="feature-content">
                        <div class="feature-title">Reports</div>
                        <div class="feature-desc">Analytics & Insights</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Access Information -->
        <div class="access-info">
            <div class="access-title">
                <i class="fas fa-users-cog"></i>
                Role-Based Access
            </div>
            <div class="role-tags">
                <span class="role-tag admin">Administrator</span>
                <span class="role-tag cashier">Cashier</span>
            </div>
        </div>

        <!-- Login Section -->
        <div class="login-section">
            <a href="#" onclick="goToAuth(); return false;" class="login-button">
                <i class="fas fa-sign-in-alt"></i>
                Access System
            </a>

            <!-- System Stats -->
            <div class="system-stats">
                <div class="stat-item">
                    <div class="stat-number">24/7</div>
                    <div class="stat-label">Available</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">Secure</div>
                    <div class="stat-label">Platform</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">Cloud</div>
                    <div class="stat-label">Based</div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer-section">
            <div class="copyright">© 2025 R-edupahana Systems</div>
        </div>
    </div>

    <script>
        function goToAuth() {
            // Show loading overlay
            const loadingOverlay = document.getElementById('loadingOverlay');
            loadingOverlay.classList.add('show');
            
            // Navigate after delay
            setTimeout(() => {
                var contextPath = '<%= request.getContextPath() %>';
                if (contextPath && contextPath !== '') {
                    window.location.href = contextPath + '/auth';
                } else {
                    window.location.href = 'auth';
                }
            }, 1200);
        }

        // Add interactive animations
        document.addEventListener('DOMContentLoaded', function() {
            // Feature cards hover effect
            const featureCards = document.querySelectorAll('.feature-card');
            featureCards.forEach(card => {
                card.addEventListener('click', function() {
                    this.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 150);
                });
            });

            // Logo pulse on click
            const logo = document.querySelector('.logo-img');
            logo.addEventListener('click', function() {
                this.style.animation = 'none';
                setTimeout(() => {
                    this.style.animation = 'pulse 1s ease-in-out';
                }, 10);
            });

            // Role tags click animation
            const roleTags = document.querySelectorAll('.role-tag');
            roleTags.forEach(tag => {
                tag.addEventListener('click', function() {
                    this.style.transform = 'scale(1.1)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 200);
                });
            });
        });

        // Add some dynamic 
        setInterval(() => {
            const shapes = document.querySelectorAll('.shape');
            shapes.forEach(shape => {
                const randomX = Math.random() * 20 - 10;
                const randomY = Math.random() * 20 - 10;
                shape.style.transform = `translate(${randomX}px, ${randomY}px)`;
            });
        }, 5000);
    </script>
</body>
</html>