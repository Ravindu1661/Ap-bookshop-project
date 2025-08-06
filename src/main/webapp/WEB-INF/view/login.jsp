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
            --primary-color: #667eea;
            --secondary-color: #764ba2;
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
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
        }

        .login-wrapper {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            width: 100%;
            max-width: 450px;
            overflow: hidden;
            animation: slideUp 0.6s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            text-align: center;
            padding: 30px;
        }

        .logo {
            font-size: 3.5rem;
            margin-bottom: 10px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .login-title {
            font-size: 1.8rem;
            margin-bottom: 5px;
            font-weight: 700;
        }

        .login-subtitle {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .login-content {
            padding: 40px;
        }

        .login-tabs {
            display: flex;
            margin-bottom: 30px;
            background: #f8fafc;
            border-radius: 12px;
            padding: 4px;
        }

        .tab-button {
            flex: 1;
            background: transparent;
            border: none;
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
        }

        .tab-button.active {
            background: white;
            color: var(--primary-color);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .tab-button:not(.active) {
            color: #64748b;
        }

        .tab-button:hover:not(.active) {
            color: var(--primary-color);
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

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #374151;
            font-size: 0.9rem;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #fafbfc;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .input-group {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            font-size: 1.1rem;
        }

        .form-control.with-icon {
            padding-left: 48px;
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            border: none;
            color: white;
            font-size: 16px;
            font-weight: 600;
            border-radius: 10px;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(102, 126, 234, 0.4);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .btn-customer {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
        }

        .btn-customer:hover {
            box-shadow: 0 12px 30px rgba(16, 185, 129, 0.4);
        }

        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: none;
            font-size: 0.9rem;
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

        .demo-accounts {
            margin-top: 25px;
            padding: 20px;
            background: #f8fafc;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
        }

        .demo-title {
            text-align: center;
            font-weight: 700;
            margin-bottom: 15px;
            color: #374151;
            font-size: 0.9rem;
        }

        .demo-account {
            background: white;
            padding: 14px;
            border-radius: 8px;
            margin-bottom: 8px;
            border: 1px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .demo-account:hover {
            border-color: var(--primary-color);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .demo-account:last-child {
            margin-bottom: 0;
        }

        .demo-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: white;
            flex-shrink: 0;
        }

        .admin-icon {
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
        }

        .cashier-icon {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
        }

        .demo-info {
            flex: 1;
        }

        .demo-role {
            font-weight: 600;
            color: #374151;
            font-size: 0.9rem;
        }

        .demo-credentials {
            font-size: 0.8rem;
            color: #6b7280;
            margin-top: 2px;
        }

        .feature-highlight {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            padding: 16px;
            border-radius: 10px;
            margin-top: 20px;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }

        .feature-text {
            font-size: 0.85rem;
            color: #4b5563;
            text-align: center;
            margin: 0;
        }

        .customer-info {
            background: rgba(16, 185, 129, 0.1);
            padding: 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            border-left: 4px solid var(--success-color);
        }

        .customer-info-text {
            font-size: 0.9rem;
            color: #065f46;
            margin: 0;
            font-weight: 500;
        }

        .footer {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
        }

        .footer-text {
            font-size: 0.8rem;
            color: #6b7280;
        }

        .loading {
            display: none;
            text-align: center;
            margin-top: 10px;
        }

        .spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .login-wrapper {
                max-width: 100%;
            }

            .login-content {
                padding: 30px 25px;
            }

            .logo {
                font-size: 3rem;
            }

            .login-title {
                font-size: 1.5rem;
            }
        }

        /* Micro-interactions */
        .form-control:valid {
            border-color: var(--success-color);
        }

        .form-control:invalid:not(:placeholder-shown) {
            border-color: var(--danger-color);
        }

        .tab-button::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 2px;
            background: var(--primary-color);
            transition: all 0.3s ease;
            transform: translateX(-50%);
        }

        .tab-button.active::after {
            width: 80%;
        }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <!-- Header -->
        <div class="login-header">
            <div class="logo">📚</div>
            <h1 class="login-title">R-edupahana</h1>
            <p class="login-subtitle">Online Billing & Library Management System</p>
        </div>

        <!-- Content -->
        <div class="login-content">
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
                <div class="alert alert-success">
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
                        <label for="username" class="form-label">
                            <i class="fas fa-user me-2"></i>Username
                        </label>
                        <div class="input-group">
                            <i class="fas fa-user input-icon"></i>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   class="form-control with-icon" 
                                   placeholder="Enter your username"
                                   required
                                   autocomplete="username">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="password" class="form-label">
                            <i class="fas fa-lock me-2"></i>Password
                        </label>
                        <div class="input-group">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   class="form-control with-icon" 
                                   placeholder="Enter your password"
                                   required
                                   autocomplete="current-password">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-login">
                        <i class="fas fa-sign-in-alt me-2"></i>
                        Sign In to Dashboard
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
                        <label for="accountNumber" class="form-label">
                            <i class="fas fa-id-card me-2"></i>Account Number
                        </label>
                        <div class="input-group">
                            <i class="fas fa-hashtag input-icon"></i>
                            <input type="text" 
                                   id="accountNumber" 
                                   name="accountNumber" 
                                   class="form-control with-icon" 
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
                        <div class="demo-icon" style="background: linear-gradient(135deg, var(--info-color) 0%, #1d4ed8 100%);">
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

            <!-- Footer -->
            <div class="footer">
                <p class="footer-text">© 2025 R-edupahana. All rights reserved.</p>
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

        // Auto-focus functionality
        document.addEventListener('DOMContentLoaded', function() {
            // Focus on username field when page loads
            document.getElementById('username').focus();
            
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
                this.parentElement.style.transform = 'scale(1.02)';
                this.parentElement.style.transition = 'transform 0.2s ease';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });

        // Add click sound effect (optional)
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