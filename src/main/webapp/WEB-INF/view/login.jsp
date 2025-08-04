<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - R-edupahana</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.1.3/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            font-size: 3rem;
            margin-bottom: 10px;
        }

        .login-title {
            font-size: 2rem;
            color: #333;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .login-subtitle {
            color: #666;
            font-size: 0.9rem;
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }

        .demo-accounts {
            margin-top: 30px;
            padding: 20px;
            background: #f7fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .demo-account {
            background: white;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 10px;
            border: 1px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .demo-account:hover {
            border-color: #667eea;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <div class="logo">📚</div>
            <h1 class="login-title">R-edupahana</h1>
            <p class="login-subtitle">Online Billing System</p>
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

        <!-- Login Form -->
        <form action="auth" method="post" id="loginForm">
            <input type="hidden" name="action" value="login">
            
            <div class="mb-3">
                <label for="username" class="form-label">
                    <i class="fas fa-user me-2"></i>Username
                </label>
                <input type="text" 
                       id="username" 
                       name="username" 
                       class="form-control" 
                       placeholder="Enter your username"
                       required
                       autocomplete="username">
            </div>
            
            <div class="mb-3">
                <label for="password" class="form-label">
                    <i class="fas fa-lock me-2"></i>Password
                </label>
                <input type="password" 
                       id="password" 
                       name="password" 
                       class="form-control" 
                       placeholder="Enter your password"
                       required
                       autocomplete="current-password">
            </div>
            
            <button type="submit" class="btn btn-login">
                <i class="fas fa-sign-in-alt me-2"></i>
                Sign In
            </button>
        </form>

        <!-- Demo Accounts -->
        <div class="demo-accounts">
            <div class="text-center fw-bold mb-3">Demo Accounts</div>
            
            <div class="demo-account" onclick="fillLogin('admin', 'admin123')">
                <div class="fw-bold text-primary">Administrator</div>
                <small class="text-muted">Username: admin | Password: admin123</small>
            </div>
            
            <div class="demo-account" onclick="fillLogin('cashier1', 'cash123')">
                <div class="fw-bold text-success">Cashier</div>
                <small class="text-muted">Username: cashier1 | Password: cash123</small>
            </div>
        </div>

        <div class="text-center mt-3">
            <small class="text-muted">© 2025 R-edupahana. All rights reserved.</small>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.1.3/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-fill login credentials for demo
        function fillLogin(username, password) {
            document.getElementById('username').value = username;
            document.getElementById('password').value = password;
        }

        // Focus on username field when page loads
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('username').focus();
        });
    </script>
</body>
</html>