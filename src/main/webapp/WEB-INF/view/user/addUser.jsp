<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add User - Redupahana</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: -280px;
            width: 280px;
            height: 100vh;
            background: #2c3e50;
            transition: left 0.3s ease;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }

        .sidebar.active {
            left: 0;
        }

        .sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }

        .sidebar-header h2 {
            color: #fff;
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
        }

        .sidebar-header p {
            color: #bdc3c7;
            font-size: 0.9rem;
        }

        .sidebar-menu {
            padding: 1rem 0;
        }

        .menu-item {
            display: block;
            padding: 1rem 1.5rem;
            color: #ecf0f1;
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .menu-item:hover,
        .menu-item.active {
            background-color: rgba(255,255,255,0.1);
            border-left-color: #95a5a6;
            color: #fff;
        }

        .menu-item i {
            margin-right: 0.8rem;
            font-size: 1.1rem;
            width: 20px;
            text-align: center;
        }

        .icon-dashboard::before { content: "📊"; }
        .icon-users::before { content: "👥"; }
        .icon-items::before { content: "📦"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
        .icon-logout::before { content: "🚪"; }

        /* Main Content */
        .main-content {
            margin-left: 0;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        /* Top Navigation */
        .topbar {
            background: #fff;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 999;
        }

        .menu-toggle {
            background: #2c3e50;
            color: white;
            border: none;
            padding: 0.8rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s ease;
        }

        .menu-toggle:hover {
            background: #34495e;
        }

        .page-title {
            font-size: 1.5rem;
            color: #2c3e50;
            font-weight: 600;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #2c3e50;
        }

        .user-avatar {
            width: 35px;
            height: 35px;
            background: #2c3e50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 0.9rem;
        }

        /* Overlay for mobile */
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .overlay.active {
            opacity: 1;
            visibility: visible;
        }

        /* Content Area */
        .content-area {
            padding: 2rem;
        }

        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .page-header h1 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .breadcrumb a {
            color: #2c3e50;
            text-decoration: none;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* Alert Messages */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #e74c3c;
            color: #721c24;
        }

        /* Form Styles */
        .form-container {
            background: white;
            padding: 2.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #2c3e50;
        }

        .required {
            color: #e74c3c;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #2c3e50;
            box-shadow: 0 0 0 2px rgba(44, 62, 80, 0.1);
        }

        .form-control.error {
            border-color: #e74c3c;
        }

        .form-text {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.25rem;
        }

        /* Role Selection */
        .role-selection {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .role-option {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 1.5rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .role-option:hover {
            border-color: #2c3e50;
            background-color: #f8f9fa;
        }

        .role-option.selected {
            border-color: #2c3e50;
            background-color: #e8f4fd;
        }

        .role-option input[type="radio"] {
            display: none;
        }

        .role-option h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .role-option p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .role-icon {
            font-size: 2rem;
            margin-bottom: 1rem;
        }

        /* Password Strength */
        .password-strength {
            margin-top: 0.5rem;
        }

        .strength-bar {
            height: 4px;
            background-color: #e0e0e0;
            border-radius: 2px;
            overflow: hidden;
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
        }

        .strength-weak { background-color: #e74c3c; }
        .strength-medium { background-color: #f39c12; }
        .strength-strong { background-color: #27ae60; }

        .strength-text {
            font-size: 0.8rem;
            margin-top: 0.25rem;
            color: #7f8c8d;
        }

        /* Buttons */
        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 1rem;
            font-weight: 500;
            margin-right: 1rem;
        }

        .btn-primary {
            background-color: #2c3e50;
            color: white;
        }

        .btn-primary:hover {
            background-color: #34495e;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: #7f8c8d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #95a5a6;
            transform: translateY(-2px);
        }

        .form-actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
            text-align: center;
        }

        /* Info Notice */
        .info-notice {
            background-color: #e8f4fd;
            border: 1px solid #bee5eb;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            border-left: 4px solid #2c3e50;
        }

        .info-notice h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .info-notice p {
            color: #2c3e50;
            font-size: 0.9rem;
        }

        /* Responsive Design */
        @media (min-width: 1024px) {
            .sidebar {
                left: 0;
            }
            
            .main-content {
                margin-left: 280px;
            }
            
            .menu-toggle {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .topbar {
                padding: 1rem;
            }
            
            .content-area {
                padding: 1rem;
            }
            
            .page-header {
                padding: 1.5rem;
            }
            
            .form-container {
                padding: 1.5rem;
            }
            
            .form-row {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .role-selection {
                grid-template-columns: 1fr;
            }
            
            .btn {
                display: block;
                margin-bottom: 0.5rem;
                margin-right: 0;
                text-align: center;
            }
            
            .user-info span {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>Redupahana</h2>
            <p>Admin Panel</p>
        </div>
        <nav class="sidebar-menu">
            <a href="dashboard" class="menu-item">
                <i class="icon-dashboard"></i>
                Dashboard
            </a>
            <a href="user?action=list" class="menu-item active">
                <i class="icon-users"></i>
                User Management
            </a>
            <a href="item?action=list" class="menu-item">
                <i class="icon-items"></i>
                Item Management
            </a>
            <a href="customer?action=list" class="menu-item">
                <i class="icon-customers"></i>
                Customer Management
            </a>
            <a href="bill?action=list" class="menu-item">
                <i class="icon-bills"></i>
                Bill Management
            </a>
            <a href="auth?action=logout" class="menu-item" style="margin-top: 2rem; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 1rem;">
                <i class="icon-logout"></i>
                Logout
            </a>
        </nav>
    </div>

    <!-- Overlay for mobile -->
    <div class="overlay" id="overlay"></div>

    <!-- Main Content -->
    <div class="main-content" id="mainContent">
        <!-- Top Navigation -->
        <header class="topbar">
            <div style="display: flex; align-items: center; gap: 1rem;">
                <button class="menu-toggle" id="menuToggle">☰</button>
                <h1 class="page-title">Add New User</h1>
            </div>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span><%= loggedUser.getFullName() %></span>
            </div>
        </header>

        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>Add New User</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    Add User
                </div>
            </div>

            <!-- Info Notice -->
            <div class="info-notice">
                <h4>👤 Create New User Account</h4>
                <p>You are creating a new user account. Please ensure all information is accurate and assign appropriate permissions.</p>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Add User Form -->
            <div class="form-container">
                <form action="user" method="post" id="addUserForm">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Username <span class="required">*</span></label>
                            <input type="text" class="form-control" id="username" name="username" required 
                                   placeholder="Enter unique username" autocomplete="username">
                            <div class="form-text">Username must be unique and cannot be changed later</div>
                        </div>

                        <div class="form-group">
                            <label for="fullName">Full Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" required 
                                   placeholder="Enter full name" autocomplete="name">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="Enter email address (optional)" autocomplete="email">
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" class="form-control" id="phone" name="phone" 
                                   placeholder="Enter 10-digit phone number" pattern="[0-9]{10}" autocomplete="tel">
                            <div class="form-text">Enter a valid 10-digit phone number</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Password <span class="required">*</span></label>
                        <input type="password" class="form-control" id="password" name="password" required 
                               placeholder="Enter secure password" autocomplete="new-password">
                        <div class="password-strength">
                            <div class="strength-bar">
                                <div class="strength-fill" id="strengthFill"></div>
                            </div>
                            <div class="strength-text" id="strengthText">Password strength will be shown here</div>
                        </div>
                        <div class="form-text">Password should be at least 8 characters with letters and numbers</div>
                    </div>

                    <div class="form-group">
                        <label>User Role <span class="required">*</span></label>
                        <div class="role-selection">
                            <div class="role-option" onclick="selectRole('ADMIN')">
                                <input type="radio" name="role" value="ADMIN" id="roleAdmin" required>
                                <div class="role-icon">👑</div>
                                <h4>Administrator</h4>
                                <p>Full system access including user management, reports, and all features</p>
                            </div>
                            <div class="role-option" onclick="selectRole('CASHIER')">
                                <input type="radio" name="role" value="CASHIER" id="roleCashier" required>
                                <div class="role-icon">💼</div>
                                <h4>Cashier</h4>
                                <p>Access to billing, customer management, and inventory operations</p>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">✅ Create User</button>
                        <a href="user?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        // Sidebar Toggle
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        function toggleSidebar() {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        menuToggle.addEventListener('click', toggleSidebar);
        overlay.addEventListener('click', toggleSidebar);

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });

        // Role Selection
        function selectRole(role) {
            // Remove selected class from all options
            document.querySelectorAll('.role-option').forEach(function(option) {
                option.classList.remove('selected');
            });
            
            // Add selected class to clicked option
            event.currentTarget.classList.add('selected');
            
            // Check the radio button
            if (role === 'ADMIN') {
                document.getElementById('roleAdmin').checked = true;
            } else {
                document.getElementById('roleCashier').checked = true;
            }
        }

        // Password Strength Checker
        const passwordInput = document.getElementById('password');
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');

        passwordInput.addEventListener('input', function() {
            const password = this.value;
            const strength = checkPasswordStrength(password);
            
            strengthFill.style.width = strength.percentage + '%';
            strengthFill.className = 'strength-fill strength-' + strength.level;
            strengthText.textContent = strength.text;
            strengthText.style.color = strength.color;
        });

        function checkPasswordStrength(password) {
            let score = 0;
            let feedback = [];

            if (password.length >= 8) score += 2;
            else feedback.push('at least 8 characters');

            if (password.match(/[a-z]/)) score += 1;
            else feedback.push('lowercase letter');

            if (password.match(/[A-Z]/)) score += 1;
            else feedback.push('uppercase letter');

            if (password.match(/[0-9]/)) score += 1;
            else feedback.push('number');

            if (password.match(/[^a-zA-Z0-9]/)) score += 1;

            if (score < 3) {
                return {
                    level: 'weak',
                    percentage: 25,
                    text: 'Weak - Add ' + feedback.slice(0, 2).join(', '),
                    color: '#e74c3c'
                };
            } else if (score < 5) {
                return {
                    level: 'medium',
                    percentage: 60,
                    text: 'Medium - ' + (feedback.length > 0 ? 'Add ' + feedback[0] : 'Good progress'),
                    color: '#f39c12'
                };
            } else {
                return {
                    level: 'strong',
                    percentage: 100,
                    text: 'Strong - Good password!',
                    color: '#27ae60'
                };
            }
        }

        // Form Validation
        document.getElementById('addUserForm').addEventListener('submit', function(e) {
            const username = document.getElementById('username').value.trim();
            const fullName = document.getElementById('fullName').value.trim();
            const password = document.getElementById('password').value;
            const role = document.querySelector('input[name="role"]:checked');

            let isValid = true;
            let errorMessage = '';

            if (!username) {
                errorMessage += 'Username is required. ';
                isValid = false;
            }

            if (!fullName) {
                errorMessage += 'Full name is required. ';
                isValid = false;
            }

            if (!password || password.length < 6) {
                errorMessage += 'Password must be at least 6 characters. ';
                isValid = false;
            }

            if (!role) {
                errorMessage += 'Please select a user role. ';
                isValid = false;
            }

            if (!isValid) {
                e.preventDefault();
                alert('Please fix the following errors:\n' + errorMessage);
                return false;
            }

            // Add loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.style.opacity = '0.7';
            submitBtn.innerHTML = '⏳ Creating User...';
            submitBtn.disabled = true;
        });

        // Phone number formatting
        document.getElementById('phone').addEventListener('input', function() {
            this.value = this.value.replace(/\D/g, '').substring(0, 10);
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Add User page loaded');
            
            // Focus on username field
            document.getElementById('username').focus();
        });
    </script>
</body>
</html>