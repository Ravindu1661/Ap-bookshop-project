<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - R-edupahana Online Billing System</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-blue: #2B6CB0;
            --secondary-blue: #3182CE;
            --light-blue: #4299E1;
            --darker-blue: #2A4365;
            --success-color: #10b981;
            --info-color: #3b82f6;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--light-blue) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }

        /* Background Geometric Shapes */
        body::before,
        body::after {
            content: '';
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            z-index: 0;
        }

        body::before {
            width: 400px;
            height: 400px;
            top: -200px;
            left: -200px;
            animation: float 6s ease-in-out infinite;
        }

        body::after {
            width: 300px;
            height: 300px;
            bottom: -150px;
            right: -150px;
            animation: float 8s ease-in-out infinite reverse;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .login-container {
            width: 100%;
            max-width: 900px;
            height: auto;
            max-height: 600px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
            display: flex;
            overflow: hidden;
            position: relative;
            z-index: 1;
            animation: slideUp 0.8s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px) scale(0.95);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* Left Welcome Section */
        .welcome-section {
            flex: 0 0 45%;
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            color: white;
            padding: 50px 35px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .welcome-section::before {
            content: '';
            position: absolute;
            width: 200px;
            height: 200px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            top: -100px;
            left: -100px;
        }

        .welcome-section::after {
            content: '';
            position: absolute;
            width: 150px;
            height: 150px;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 50%;
            bottom: -75px;
            right: -75px;
        }

        .welcome-content {
            position: relative;
            z-index: 2;
        }

        .welcome-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
        }

        .welcome-subtitle {
            font-size: 1rem;
            opacity: 0.9;
            margin-bottom: 25px;
            line-height: 1.5;
        }

        .welcome-features {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .welcome-features li {
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .welcome-features i {
            color: #FFD700;
            font-size: 1.2rem;
        }

        /* Right Login Section */
        .login-section {
            flex: 0 0 55%;
            padding: 25px 20px;
            background: #fafafa;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            overflow-y: auto;
        }

        .login-header {
            text-align: center;
            margin-bottom: 15px;
        }

        .login-title {
            font-size: 1.4rem;
            color: var(--darker-blue);
            font-weight: 700;
            margin-bottom: 4px;
        }

        .login-subtitle {
            color: #666;
            font-size: 0.75rem;
        }

        /* Tab System */
        .login-tabs {
            display: flex;
            margin-bottom: 14px;
            background: white;
            border-radius: 6px;
            padding: 3px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .tab-button {
            flex: 1;
            background: transparent;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            color: #666;
            font-size: 0.75rem;
        }

        .tab-button.active {
            background: var(--primary-blue);
            color: white;
            box-shadow: 0 4px 15px rgba(43, 108, 176, 0.3);
        }

        .tab-button:hover:not(.active) {
            color: var(--primary-blue);
            background: rgba(43, 108, 176, 0.05);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
            animation: fadeIn 0.4s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Form Styles */
        .form-group {
            margin-bottom: 12px;
        }

        .form-label {
            display: block;
            margin-bottom: 4px;
            font-weight: 600;
            color: var(--darker-blue);
            font-size: 0.75rem;
        }

        .input-group {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
            font-size: 0.85rem;
            z-index: 2;
        }

        .form-control {
            width: 100%;
            padding: 10px 10px 10px 32px;
            border: 2px solid #e5e7eb;
            border-radius: 6px;
            font-size: 13px;
            transition: all 0.3s ease;
            background: white;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-blue);
            box-shadow: 0 0 0 3px rgba(43, 108, 176, 0.1);
        }

        .form-control:valid {
            border-color: var(--success-color);
        }

        /* Buttons */
        .btn-login {
            width: 100%;
            padding: 10px;
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            border: none;
            color: white;
            font-size: 13px;
            font-weight: 600;
            border-radius: 6px;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 35px rgba(43, 108, 176, 0.4);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .btn-customer {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
        }

        .btn-customer:hover {
            box-shadow: 0 15px 35px rgba(16, 185, 129, 0.4);
        }

        /* Alert Messages */
        .alert {
            padding: 8px 10px;
            border-radius: 6px;
            margin-bottom: 12px;
            border: none;
            font-size: 0.75rem;
            animation: slideIn 0.4s ease;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.1);
            color: #dc2626;
            border-left: 4px solid #dc2626;
        }

        .alert-info {
            background: rgba(59, 130, 246, 0.1);
            color: #2563eb;
            border-left: 4px solid #2563eb;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            border-left: 4px solid #059669;
        }

        /* Demo Accounts */
        .demo-accounts {
            margin-top: 12px;
            padding: 10px;
            background: white;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .demo-title {
            text-align: center;
            font-weight: 700;
            margin-bottom: 8px;
            color: var(--darker-blue);
            font-size: 0.7rem;
        }

        .demo-account {
            background: #f8fafc;
            padding: 8px;
            border-radius: 4px;
            margin-bottom: 4px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .demo-account:hover {
            border-color: var(--primary-blue);
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(43, 108, 176, 0.12);
            background: white;
        }

        .demo-account:last-child {
            margin-bottom: 0;
        }

        .demo-icon {
            width: 28px;
            height: 28px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            color: white;
            flex-shrink: 0;
        }

        .admin-icon {
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
        }

        .cashier-icon {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
        }

        .customer-icon {
            background: linear-gradient(135deg, var(--info-color) 0%, #1d4ed8 100%);
        }

        .demo-info {
            flex: 1;
        }

        .demo-role {
            font-weight: 600;
            color: var(--darker-blue);
            font-size: 0.7rem;
        }

        .demo-credentials {
            font-size: 0.65rem;
            color: #6b7280;
            margin-top: 0px;
        }

        /* Customer Info */
        .customer-info {
            background: rgba(16, 185, 129, 0.1);
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 12px;
            border-left: 3px solid var(--success-color);
        }

        .customer-info-text {
            font-size: 0.75rem;
            color: #065f46;
            margin: 0;
            font-weight: 500;
        }

        /* Feature Highlight */
        .feature-highlight {
            background: rgba(43, 108, 176, 0.1);
            padding: 10px;
            border-radius: 6px;
            margin-top: 10px;
            border: 1px solid rgba(43, 108, 176, 0.2);
        }

        .feature-text {
            font-size: 0.7rem;
            color: var(--darker-blue);
            text-align: center;
            margin: 0;
        }

        /* Loading */
        .loading {
            display: none;
            text-align: center;
            margin-top: 8px;
        }

        .spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid var(--primary-blue);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.02); }
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .login-container {
                max-width: 800px;
                max-height: 550px;
            }
        }

        @media (max-width: 768px) {
            .login-container {
                flex-direction: column;
                max-width: 100%;
                max-height: none;
                border-radius: 15px;
            }

            .welcome-section {
                flex: none;
                padding: 40px 30px;
                order: 2;
            }

            .login-section {
                flex: none;
                padding: 40px 30px;
                order: 1;
            }

            .welcome-title {
                font-size: 2.2rem;
            }

            .login-title {
                font-size: 1.6rem;
            }

            body {
                padding: 10px;
            }
        }

        @media (max-width: 480px) {
            .welcome-section,
            .login-section {
                padding: 30px 20px;
            }

            .welcome-title {
                font-size: 1.8rem;
            }

            .login-title {
                font-size: 1.4rem;
            }
        }

        /* Additional Micro-animations */
        .form-control:focus + .input-icon {
            color: var(--primary-blue);
        }

        .demo-account:active {
            transform: scale(0.98);
        }

        .tab-button:active {
            transform: scale(0.98);
        }
    </style>
</head>
<body>
    <div class="login-container">
        <!-- Left Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-content">
                <h1 class="welcome-title">WELCOME</h1>
                <p class="welcome-subtitle">Your Complete Library & Billing Management System</p>
                
                <ul class="welcome-features">
                    <li><i class="fas fa-book"></i> Comprehensive Book Management</li>
                    <li><i class="fas fa-users"></i> Customer Portal Access</li>
                    <li><i class="fas fa-chart-line"></i> Advanced Analytics & Reports</li>
                    <li><i class="fas fa-mobile-alt"></i> Mobile-Friendly Interface</li>
                    <li><i class="fas fa-shield-alt"></i> Secure & Reliable System</li>
                </ul>
            </div>
        </div>

        <!-- Right Login Section -->
        <div class="login-section">
            <div class="login-header">
                <h2 class="login-title">Sign In</h2>
                <p class="login-subtitle">Please enter your credentials to access your account</p>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    ${errorMessage}
                </div>
            </c:if>
            
            <c:if test="${not empty infoMessage}">
                <div class="alert alert-info">
                    <i class="fas fa-info-circle me-2"></i>
                    ${infoMessage}
                </div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success" id="successAlert">
                    <i class="fas fa-check-circle me-2"></i>
                    ${successMessage}
                </div>
            </c:if>

            <!-- Login Tabs -->
            <div class="login-tabs">
                <button type="button" class="tab-button active" onclick="switchTab('staff')">
                    <i class="fas fa-user-tie me-2"></i>Staff Login
                </button>
                <button type="button" class="tab-button" onclick="switchTab('customer')">
                    <i class="fas fa-users me-2"></i>Customer Access
                </button>
            </div>

            <!-- Staff Login Tab -->
            <div id="staff-tab" class="tab-content active">
                <form action="auth" method="post" id="staffLoginForm">
                    <input type="hidden" name="action" value="login">
                    <input type="hidden" name="loginType" value="staff">
                    
                    <div class="form-group">
                        <label for="username" class="form-label">User Name</label>
                        <div class="input-group">
                            <i class="fas fa-user input-icon"></i>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   class="form-control" 
                                   placeholder="Enter your username"
                                   required
                                   autocomplete="username">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="password" class="form-label">Password</label>
                        <div class="input-group">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   class="form-control" 
                                   placeholder="Enter your password"
                                   required
                                   autocomplete="current-password">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-login">
                        <i class="fas fa-sign-in-alt me-2"></i>
                        Sign In
                    </button>
                </form>

                <!-- Demo Accounts for Staff -->
                <div class="demo-accounts">
                    <div class="demo-title">🎯 Demo Accounts</div>
                    
                    <div class="demo-account" onclick="fillStaffLogin('admin', 'admin123')">
                        <div class="demo-icon admin-icon">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <div class="demo-info">
                            <div class="demo-role">Administrator</div>
                            <div class="demo-credentials">admin / admin123</div>
                        </div>
                    </div>
                    
                    <div class="demo-account" onclick="fillStaffLogin('cashier1', 'cash123')">
                        <div class="demo-icon cashier-icon">
                            <i class="fas fa-cash-register"></i>
                        </div>
                        <div class="demo-info">
                            <div class="demo-role">Cashier</div>
                            <div class="demo-credentials">cashier1 / cash123</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Customer Access Tab -->
            <div id="customer-tab" class="tab-content">
                <div class="customer-info">
                    <p class="customer-info-text">
                        <i class="fas fa-info-circle me-2"></i>
                        Enter your account number to access your customer portal and view your billing history.
                    </p>
                </div>

                <form action="auth" method="post" id="customerLoginForm">
                    <input type="hidden" name="action" value="customerLogin">
                    <input type="hidden" name="loginType" value="customer">
                    
                    <div class="form-group">
                        <label for="accountNumber" class="form-label">Account Number</label>
                        <div class="input-group">
                            <i class="fas fa-hashtag input-icon"></i>
                            <input type="text" 
                                   id="accountNumber" 
                                   name="accountNumber" 
                                   class="form-control" 
                                   placeholder="Enter your account number (e.g., ACC001)"
                                   required
                                   pattern="[A-Za-z0-9]+"
                                   title="Account number should contain only letters and numbers">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-login btn-customer">
                        <i class="fas fa-user-check me-2"></i>
                        Access Customer Portal
                    </button>
                </form>

                <!-- Customer Demo Account -->
                <div class="demo-accounts">
                    <div class="demo-title">🎯 Demo Customer Account</div>
                    
                    <div class="demo-account" onclick="fillCustomerLogin('ACC001')">
                        <div class="demo-icon customer-icon">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="demo-info">
                            <div class="demo-role">Sample Customer</div>
                            <div class="demo-credentials">Account: ACC001</div>
                        </div>
                    </div>
                </div>

                <div class="feature-highlight">
                    <p class="feature-text">
                        <i class="fas fa-sparkles me-2"></i>
                        View your purchase history, download invoices, and track your orders in your personal customer portal.
                    </p>
                </div>
            </div>

            <!-- Loading indicator -->
            <div class="loading" id="loadingIndicator">
                <div class="spinner"></div>
                <span class="ms-2">Signing in...</span>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tab switching functionality
        function switchTab(tabName) {
            // Remove active class from all tabs and contents
            document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            
            // Add active class to selected tab
            event.target.classList.add('active');
            document.getElementById(tabName + '-tab').classList.add('active');
            
            // Focus on the first input of active tab
            setTimeout(() => {
                const activeTab = document.getElementById(tabName + '-tab');
                const firstInput = activeTab.querySelector('input[type="text"], input[type="password"]');
                if (firstInput) firstInput.focus();
            }, 100);
        }

        // Auto-fill staff login credentials
        function fillStaffLogin(username, password) {
            document.getElementById('username').value = username;
            document.getElementById('password').value = password;
            document.getElementById('username').focus();
        }

        // Auto-fill customer login
        function fillCustomerLogin(accountNumber) {
            document.getElementById('accountNumber').value = accountNumber;
            document.getElementById('accountNumber').focus();
        }

        // Form submission handling
        document.getElementById('staffLoginForm').addEventListener('submit', function(e) {
            showLoading();
        });

        document.getElementById('customerLoginForm').addEventListener('submit', function(e) {
            showLoading();
        });

        // Show loading indicator
        function showLoading() {
            document.getElementById('loadingIndicator').style.display = 'block';
            document.querySelectorAll('.btn-login').forEach(btn => {
                btn.disabled = true;
                btn.style.opacity = '0.7';
            });
        }

        // Form validation
        document.getElementById('accountNumber').addEventListener('input', function(e) {
            const value = e.target.value;
            const pattern = /^[A-Za-z0-9]*$/;
            
            if (!pattern.test(value)) {
                e.target.value = value.replace(/[^A-Za-z0-9]/g, '');
            }
        });

        // Auto-focus functionality and success redirect
        document.addEventListener('DOMContentLoaded', function() {
            // Focus on username field when page loads
            document.getElementById('username').focus();
            
            // Handle success message and auto-redirect
            const showSuccess = '<c:out value="${showSuccess}" />';
            const redirectUrl = '<c:out value="${redirectUrl}" />';
            
            if (showSuccess === 'true' && redirectUrl) {
                // Show success message with animation
                const successAlert = document.getElementById('successAlert');
                if (successAlert) {
                    successAlert.style.background = 'linear-gradient(135deg, #10b981 0%, #059669 100%)';
                    successAlert.style.color = 'white';
                    successAlert.style.borderLeft = '4px solid #065f46';
                    successAlert.style.animation = 'pulse 0.5s ease-in-out';
                    
                    // Disable all form inputs and buttons
                    document.querySelectorAll('input, button').forEach(element => {
                        element.disabled = true;
                        element.style.opacity = '0.6';
                    });
                    
                    // Show loading spinner in the success alert
                    setTimeout(() => {
                        successAlert.innerHTML = `
                            <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
                                <div class="spinner" style="border-color: rgba(255,255,255,0.3); border-top-color: white;"></div>
                                <span>Redirecting...</span>
                            </div>
                        `;
                    }, 1500);
                    
                    // Redirect after 3 seconds
                    setTimeout(() => {
                        window.location.href = redirectUrl;
                    }, 3000);
                }
            }
            
            // Add enter key navigation
            document.querySelectorAll('input').forEach(input => {
                input.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        const form = e.target.closest('form');
                        const inputs = Array.from(form.querySelectorAll('input:not([type="hidden"])'));
                        const currentIndex = inputs.indexOf(e.target);
                        
                        if (currentIndex < inputs.length - 1) {
                            e.preventDefault();
                            inputs[currentIndex + 1].focus();
                        }
                    }
                });
            });
        });

        // Add subtle animations on input focus
        document.querySelectorAll('.form-control').forEach(input => {
            input.addEventListener('focus', function() {
                this.closest('.input-group').style.transform = 'scale(1.02)';
                this.closest('.input-group').style.transition = 'transform 0.2s ease';
            });
            
            input.addEventListener('blur', function() {
                this.closest('.input-group').style.transform = 'scale(1)';
            });
        });

        // Add click effect for interactive elements
        document.querySelectorAll('.demo-account, .tab-button').forEach(element => {
            element.addEventListener('click', function() {
                this.style.transform = 'scale(0.98)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 100);
            });
        });
    </script>
</body>
</html>