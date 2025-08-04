<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    User user = (User) request.getAttribute("user");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Redupahana</title>
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

        /* Sidebar Styles (same as previous pages) */
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

        .sidebar.active { left: 0; }

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

        .sidebar-menu { padding: 1rem 0; }

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

        /* Icon classes using Unicode */
        .icon-dashboard::before { content: "📊"; }
        .icon-users::before { content: "👥"; }
        .icon-books::before { content: "📚"; }
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

        .menu-toggle:hover { background: #34495e; }

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

        /* Overlay */
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
        .content-area { padding: 2rem; }

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

        .breadcrumb a:hover { text-decoration: underline; }

        /* User Info Card */
        .user-info-card {
            background: #e8f4fd;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border-left: 4px solid #2c3e50;
        }

        .user-info-card h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 0.25rem;
        }

        .info-value {
            color: #2c3e50;
            font-size: 1rem;
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

        .form-group { margin-bottom: 1.5rem; }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #2c3e50;
        }

        .required { color: #e74c3c; }

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

        .form-control:disabled {
            background-color: #f8f9fa;
            cursor: not-allowed;
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

        .role-option input[type="radio"] { display: none; }

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

        /* Responsive Design */
        @media (min-width: 1024px) {
            .sidebar { left: 0; }
            .main-content { margin-left: 280px; }
            .menu-toggle { display: none; }
        }

        @media (max-width: 768px) {
            .topbar { padding: 1rem; }
            .content-area { padding: 1rem; }
            .page-header { padding: 1.5rem; }
            .form-container { padding: 1.5rem; }
            .form-row { grid-template-columns: 1fr; gap: 1rem; }
            .role-selection { grid-template-columns: 1fr; }
            .btn { display: block; margin-bottom: 0.5rem; margin-right: 0; text-align: center; }
            .info-grid { grid-template-columns: 1fr; }
            .user-info span { display: none; }
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
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list" class="menu-item">
                <i class="icon-users"></i>
                User Management
            </a>
            <% } %>
            <a href="book?action=list" class="menu-item active">
                <i class="icon-books"></i>
                Book Management
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
                <h1 class="page-title">Edit User</h1>
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
                <h1>Edit User</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    Edit User
                </div>
            </div>

            <% if (user != null) { %>
            <!-- Current User Info -->
            <div class="user-info-card">
                <h4>📝 Current User Information</h4>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">User ID</span>
                        <span class="info-value">#<%= user.getUserId() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Username</span>
                        <span class="info-value"><%= user.getUsername() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Current Role</span>
                        <span class="info-value"><%= user.getRole() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Created Date</span>
                        <span class="info-value"><%= user.getCreatedDate() %></span>
                    </div>
                </div>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Edit User Form -->
            <div class="form-container">
                <form action="user" method="post" id="editUserForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                    
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" class="form-control" id="username" name="username" 
                               value="<%= user.getUsername() %>" disabled>
                        <div class="form-text">Username cannot be changed</div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">Full Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   value="<%= user.getFullName() %>" required 
                                   placeholder="Enter full name">
                        </div>

                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                                   placeholder="Enter email address (optional)">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" class="form-control" id="phone" name="phone" 
                               value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                               placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                        <div class="form-text">Enter a valid 10-digit phone number</div>
                    </div>

                    <div class="form-group">
                        <label>User Role <span class="required">*</span></label>
                        <div class="role-selection">
                            <div class="role-option <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "selected" : "" %>" onclick="selectRole('ADMIN')">
                                <input type="radio" name="role" value="ADMIN" id="roleAdmin" 
                                       <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "checked" : "" %> required>
                                <div class="role-icon">👑</div>
                                <h4>Administrator</h4>
                                <p>Full system access including user management</p>
                            </div>
                            <div class="role-option <%= Constants.ROLE_CASHIER.equals(user.getRole()) ? "selected" : "" %>" onclick="selectRole('CASHIER')">
                                <input type="radio" name="role" value="CASHIER" id="roleCashier" 
                                       <%= Constants.ROLE_CASHIER.equals(user.getRole()) ? "checked" : "" %> required>
                                <div class="role-icon">💼</div>
                                <h4>Cashier</h4>
                                <p>Access to billing and customer management</p>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">💾 Update User</button>
                        <a href="user?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>

            <% } else { %>
            <!-- User Not Found -->
            <div class="alert alert-error">
                ❌ User not found or invalid user ID.
            </div>
            <div style="text-align: center; margin-top: 2rem;">
                <a href="user?action=list" class="btn btn-primary">Back to User List</a>
            </div>
            <% } %>
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

        // Form Validation
        document.getElementById('editUserForm').addEventListener('submit', function(e) {
            const fullName = document.getElementById('fullName').value.trim();
            const role = document.querySelector('input[name="role"]:checked');

            let isValid = true;
            let errorMessage = '';

            if (!fullName) {
                errorMessage += 'Full name is required. ';
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
            submitBtn.innerHTML = '⏳ Updating User...';
            submitBtn.disabled = true;
        });

        // Phone number formatting
        const phoneInput = document.getElementById('phone');
        if (phoneInput) {
            phoneInput.addEventListener('input', function() {
                this.value = this.value.replace(/\D/g, '').substring(0, 10);
            });
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Edit User page loaded');
            
            // Focus on full name field
            document.getElementById('fullName').focus();
        });
    </script>
</body>
</html>