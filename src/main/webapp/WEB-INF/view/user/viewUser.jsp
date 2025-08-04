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
    <title>View User - Redupahana</title>
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

        /* User Profile Card */
        .user-profile {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .profile-header {
            background: #2c3e50;
            color: white;
            padding: 2.5rem;
            text-align: center;
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .profile-role {
            font-size: 1.1rem;
            opacity: 0.9;
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            background-color: rgba(255, 255, 255, 0.2);
        }

        .profile-content { padding: 2rem; }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .info-section {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid #2c3e50;
        }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e9ecef;
        }

        .info-row:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            flex: 1;
        }

        .info-value {
            color: #2c3e50;
            flex: 2;
            text-align: right;
        }

        .info-value.empty {
            color: #bdc3c7;
            font-style: italic;
        }

        /* Badges */
        .role-badge {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .role-admin {
            background-color: #f8d7da;
            color: #721c24;
        }

        .role-cashier {
            background-color: #d4edda;
            color: #155724;
        }

        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-active {
            background-color: #d4edda;
            color: #155724;
        }

        /* Contact Info */
        .contact-info {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .contact-icon {
            width: 20px;
            text-align: center;
        }

        .contact-link {
            color: #2c3e50;
            text-decoration: none;
        }

        .contact-link:hover { text-decoration: underline; }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }

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
        }

        .btn-primary {
            background-color: #2c3e50;
            color: white;
        }

        .btn-primary:hover {
            background-color: #34495e;
            transform: translateY(-2px);
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
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

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
        }

        .btn-disabled {
            background-color: #7f8c8d;
            color: white;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .btn-disabled:hover {
            transform: none;
            background-color: #7f8c8d;
        }

        /* Not Found State */
        .not-found {
            background: white;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            text-align: center;
        }

        .not-found h3 {
            color: #e74c3c;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }

        .not-found p {
            color: #7f8c8d;
            margin-bottom: 2rem;
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
            .profile-header { padding: 1.5rem; }
            .profile-name { font-size: 1.5rem; }
            .profile-content { padding: 1rem; }
            .info-grid { grid-template-columns: 1fr; gap: 1rem; }
            .action-buttons { flex-direction: column; }
            .info-row { flex-direction: column; align-items: flex-start; gap: 0.25rem; }
            .info-value { text-align: left; }
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
                <h1 class="page-title">User Profile</h1>
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
                <h1>User Profile</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    User Details
                </div>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <% if (user != null) { %>
            <!-- User Profile -->
            <div class="user-profile">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "👑" : "💼" %>
                    </div>
                    <div class="profile-name"><%= user.getFullName() %></div>
                    <div class="profile-role">
                        <span class="role-badge <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" %>">
                            <%= user.getRole() %>
                        </span>
                    </div>
                </div>

                <div class="profile-content">
                    <div class="info-grid">
                        <div class="info-section">
                            <h4>📋 Basic Information</h4>
                            <div class="info-row">
                                <span class="info-label">User ID:</span>
                                <span class="info-value">#<%= user.getUserId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Username:</span>
                                <span class="info-value"><%= user.getUsername() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Full Name:</span>
                                <span class="info-value"><%= user.getFullName() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="status-badge status-active">Active</span>
                                </span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📞 Contact Information</h4>
                            <div class="contact-info">
                                <% if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) { %>
                                <div class="contact-item">
                                    <span class="contact-icon">📱</span>
                                    <span class="info-value empty">No phone provided</span>
                                </div>
                                <% } %>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📅 Account Details</h4>
                            <div class="info-row">
                                <span class="info-label">Role:</span>
                                <span class="info-value">
                                    <span class="role-badge <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" %>">
                                        <%= user.getRole() %>
                                    </span>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Created Date:</span>
                                <span class="info-value"><%= user.getCreatedDate() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Account Age:</span>
                                <span class="info-value" id="accountAge">Calculating...</span>
                            </div>
                        </div>
                    </div>

                    <div class="action-buttons">
                        <% if (user.getUserId() != loggedUser.getUserId()) { %>
                        <a href="user?action=edit&id=<%= user.getUserId() %>" class="btn btn-warning">
                            ✏️ Edit User
                        </a>
                        <a href="user?action=delete&id=<%= user.getUserId() %>" 
                           class="btn btn-danger"
                           onclick="return confirmDelete('<%= user.getFullName() %>')">
                            🗑️ Delete User
                        </a>
                        <% } else { %>
                        <span class="btn btn-disabled">
                            👤 Current User (Cannot Edit/Delete)
                        </span>
                        <% } %>
                        <a href="user?action=list" class="btn btn-primary">
                            📋 Back to List
                        </a>
                    </div>
                </div>
            </div>

            <% } else { %>
            <!-- User Not Found -->
            <div class="not-found">
                <h3>User Not Found</h3>
                <p>The requested user could not be found or may have been deleted.</p>
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

        // Calculate account age
        <% if (user != null) { %>
        const createdDate = new Date('<%= user.getCreatedDate() %>');
        const now = new Date();
        const diffTime = Math.abs(now - createdDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        let ageText;
        if (diffDays < 30) {
            ageText = diffDays + ' days';
        } else if (diffDays < 365) {
            const months = Math.floor(diffDays / 30);
            ageText = months + ' month' + (months > 1 ? 's' : '');
        } else {
            const years = Math.floor(diffDays / 365);
            ageText = years + ' year' + (years > 1 ? 's' : '');
        }
        
        document.getElementById('accountAge').textContent = ageText;
        <% } %>

        // Confirm delete function
        function confirmDelete(userName) {
            return confirm('Are you sure you want to delete user "' + userName + '"? This action cannot be undone and will remove all access for this user.');
        }

        // Add loading state to action buttons
        document.querySelectorAll('.btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                if (!this.onclick && !this.href.includes('delete') && !this.href.includes('tel:') && !this.href.includes('mailto:') && !this.classList.contains('btn-disabled')) {
                    this.style.opacity = '0.7';
                    this.innerHTML = this.innerHTML + '...';
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // E key for edit (if edit button exists)
            if (e.key === 'e' || e.key === 'E') {
                const editBtn = document.querySelector('.btn-warning');
                if (editBtn) editBtn.click();
            }
            
            // B key for back
            if (e.key === 'b' || e.key === 'B') {
                const backBtn = document.querySelector('.btn-primary');
                if (backBtn) backBtn.click();
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('View User page loaded');
        });
    </script>
</body>
</html>