<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Redupahana</title>
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
            position: relative;
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
        .icon-items::before { content: "📦"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
        .icon-logout::before { content: "🚪"; }

        /* Main Content Styles */
        .main-content {
            margin-left: 0;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        .main-content.shifted {
            margin-left: 280px;
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

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #2c3e50;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: #2c3e50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }

        .logout-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 0.6rem 1.2rem;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9rem;
            transition: background-color 0.3s ease;
        }

        .logout-btn:hover {
            background: #c0392b;
        }

        /* Dashboard Content */
        .dashboard-content {
            padding: 2rem;
        }

        .welcome-section {
            background: #2c3e50;
            color: white;
            padding: 2.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            text-align: center;
        }

        .welcome-section h1 {
            font-size: 2.2rem;
            margin-bottom: 0.5rem;
        }

        .welcome-section p {
            opacity: 0.9;
            font-size: 1.1rem;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .stat-card-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin-bottom: 1rem;
            background: #ecf0f1;
            color: #2c3e50;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            color: #7f8c8d;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }

        .card-link {
            display: inline-block;
            background: #2c3e50;
            color: white;
            padding: 0.8rem 1.8rem;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .card-link:hover {
            background: #34495e;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(44, 62, 80, 0.3);
        }

        /* Quick Actions Section */
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 1.5rem;
            font-size: 1.4rem;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .action-btn {
            background: #2c3e50;
            color: white;
            padding: 1rem 1.5rem;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .action-btn:hover {
            background: #34495e;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(44, 62, 80, 0.3);
        }

        .action-btn.secondary {
            background: #7f8c8d;
        }

        .action-btn.secondary:hover {
            background: #95a5a6;
            box-shadow: 0 6px 20px rgba(127, 140, 141, 0.3);
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
            
            .dashboard-content {
                padding: 1rem;
            }
            
            .welcome-section {
                padding: 1.5rem;
            }
            
            .welcome-section h1 {
                font-size: 1.8rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .user-info span {
                display: none;
            }
        }

        /* Loading Animation */
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }

        .loading::after {
            content: "...";
            animation: dots 1.5s infinite;
        }

        @keyframes dots {
            0%, 20% { content: ""; }
            40% { content: "."; }
            60% { content: ".."; }
            80%, 100% { content: "..."; }
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
            <a href="#" class="menu-item active">
                <i class="icon-dashboard"></i>
                Dashboard
            </a>
            <a href="user?action=list" class="menu-item">
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
            <button class="menu-toggle" id="menuToggle">☰</button>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span>Welcome, <%= loggedUser.getFullName() %></span>
                <a href="auth?action=logout" class="logout-btn">Logout</a>
            </div>
        </header>

        <!-- Dashboard Content -->
        <main class="dashboard-content">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <h1>Welcome Back, <%= loggedUser.getFullName() %></h1>
                <p>Manage your business operations efficiently from this central hub</p>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card" onclick="navigateTo('user?action=list')">
                    <div class="stat-card-icon">👥</div>
                    <h3>User Management</h3>
                    <p>Manage system users, roles, and permissions. Add new users and control access levels.</p>
                    <a href="user?action=list" class="card-link">Manage Users</a>
                </div>

                <div class="stat-card" onclick="navigateTo('item?action=list')">
                    <div class="stat-card-icon">📦</div>
                    <h3>Item Management</h3>
                    <p>Add, edit, and manage your inventory items. Track stock levels and product information.</p>
                    <a href="item?action=list" class="card-link">Manage Items</a>
                </div>

                <div class="stat-card" onclick="navigateTo('customer?action=list')">
                    <div class="stat-card-icon">🏢</div>
                    <h3>Customer Management</h3>
                    <p>Manage customer information, accounts, and maintain client relationships effectively.</p>
                    <a href="customer?action=list" class="card-link">Manage Customers</a>
                </div>

                <div class="stat-card" onclick="navigateTo('bill?action=list')">
                    <div class="stat-card-icon">🧾</div>
                    <h3>Bill Management</h3>
                    <p>View, create, and manage all transactions. Generate reports and track payments.</p>
                    <a href="bill?action=list" class="card-link">View Bills</a>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions">
                <h2>Quick Actions</h2>
                <div class="action-buttons">
                    <a href="customer?action=add" class="action-btn">➕ Add New Customer</a>
                    <a href="item?action=add" class="action-btn">📦 Add New Item</a>
                    <a href="bill?action=create" class="action-btn secondary">🧾 Create New Bill</a>
                    <a href="user?action=add" class="action-btn secondary">👤 Add New User</a>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Sidebar Toggle Functionality
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');
        const mainContent = document.getElementById('mainContent');

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

        // Menu item active state
        const menuItems = document.querySelectorAll('.menu-item');
        menuItems.forEach(item => {
            item.addEventListener('click', function(e) {
                if (!this.getAttribute('href').includes('logout')) {
                    menuItems.forEach(i => i.classList.remove('active'));
                    this.classList.add('active');
                }
            });
        });

        // Card navigation function
        function navigateTo(url) {
            window.location.href = url;
        }

        // Add loading effect to buttons and links
        const actionElements = document.querySelectorAll('.action-btn, .card-link, .menu-item');
        actionElements.forEach(element => {
            element.addEventListener('click', function(e) {
                if (!this.classList.contains('loading')) {
                    this.classList.add('loading');
                    // Remove loading class after 2 seconds (in case navigation fails)
                    setTimeout(() => {
                        this.classList.remove('loading');
                    }, 2000);
                }
            });
        });

        // Smooth scrolling for better UX
        document.documentElement.style.scrollBehavior = 'smooth';

        // Add keyboard navigation
        document.addEventListener('keydown', function(e) {
            // ESC key closes sidebar on mobile
            if (e.key === 'Escape' && sidebar.classList.contains('active')) {
                toggleSidebar();
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Admin Dashboard Loaded Successfully');
            
            // Add fade-in animation to cards
            const cards = document.querySelectorAll('.stat-card');
            cards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                setTimeout(() => {
                    card.style.transition = 'all 0.6s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 100);
            });
        });
    </script>
</body>
</html>