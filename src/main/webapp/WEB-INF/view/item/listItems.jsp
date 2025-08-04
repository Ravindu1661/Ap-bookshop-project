<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Item"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Item> items = (List<Item>) request.getAttribute("items");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Item Management - Redupahana</title>
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
            margin-bottom: 1rem;
        }

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
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

        /* Search Form */
        .search-form {
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        .search-form input {
            padding: 0.7rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            min-width: 250px;
            font-size: 0.9rem;
        }

        .search-form input:focus {
            outline: none;
            border-color: #2c3e50;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            text-align: center;
            border-left: 4px solid #2c3e50;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        /* Alert Messages */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid;
            animation: slideIn 0.3s ease;
        }

        .alert-success {
            background-color: #d4edda;
            border-left-color: #27ae60;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #e74c3c;
            color: #721c24;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Buttons */
        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 0.9rem;
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

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
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

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
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

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.8rem;
        }

        /* Table Styles */
        .table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
        }

        .table-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-header h2 {
            color: #2c3e50;
            font-size: 1.3rem;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th,
        .table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        /* Stock Status */
        .stock-status {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .stock-low {
            background-color: #f8d7da;
            color: #721c24;
        }

        .stock-medium {
            background-color: #fff3cd;
            color: #856404;
        }

        .stock-good {
            background-color: #d4edda;
            color: #155724;
        }

        .price {
            font-weight: 600;
            color: #27ae60;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state h3 {
            margin-bottom: 1rem;
            color: #2c3e50;
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
            
            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-form {
                flex-direction: column;
            }
            
            .search-form input {
                min-width: auto;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .table-container {
                overflow-x: auto;
            }
            
            .action-buttons {
                flex-direction: column;
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
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list" class="menu-item">
                <i class="icon-users"></i>
                User Management
            </a>
            <% } %>
            <a href="item?action=list" class="menu-item active">
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
                <h1 class="page-title">Item Management</h1>
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
                <h1>Item Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Item Management
                </div>
                <div class="header-actions">
                    <form class="search-form" action="item" method="get">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="searchTerm" placeholder="Search by name, code, or category..." 
                               value="<%= searchTerm != null ? searchTerm : "" %>">
                        <button type="submit" class="btn btn-primary">🔍 Search</button>
                        <% if (searchTerm != null) { %>
                        <a href="item?action=list" class="btn btn-secondary">❌ Clear</a>
                        <% } %>
                    </form>
                    <a href="item?action=add" class="btn btn-success">➕ Add New Item</a>
                </div>
            </div>

            <!-- Stats Cards -->
            <%
                int totalItems = 0;
                int lowStockItems = 0;
                int outOfStockItems = 0;
                
                if (items != null) {
                    totalItems = items.size();
                    for (Item item : items) {
                        if (item.getStockQuantity() == 0) {
                            outOfStockItems++;
                        } else if (item.getStockQuantity() <= 10) {
                            lowStockItems++;
                        }
                    }
                }
            %>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= totalItems %></h3>
                    <p>Total Items</p>
                </div>
                <div class="stat-card">
                    <h3><%= lowStockItems %></h3>
                    <p>Low Stock Items</p>
                </div>
                <div class="stat-card">
                    <h3><%= outOfStockItems %></h3>
                    <p>Out of Stock</p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success" id="successAlert">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="alert alert-error" id="errorAlert">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Items Table -->
            <div class="table-container">
                <div class="table-header">
                    <h2>Inventory Items</h2>
                    <% if (searchTerm != null) { %>
                    <span style="color: #7f8c8d; font-size: 0.9rem;">Search results for: "<%= searchTerm %>"</span>
                    <% } %>
                </div>

                <% if (items != null && !items.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Item Code</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Description</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Item item : items) { %>
                        <tr>
                            <td><strong><%= item.getItemCode() %></strong></td>
                            <td><%= item.getName() %></td>
                            <td><%= item.getCategory() %></td>
                            <td class="price">Rs. <%= String.format("%.2f", item.getPrice()) %></td>
                            <td>
                                <span class="stock-status <%= 
                                    item.getStockQuantity() == 0 ? "stock-low" :
                                    item.getStockQuantity() <= 10 ? "stock-low" : 
                                    item.getStockQuantity() <= 50 ? "stock-medium" : "stock-good" 
                                %>">
                                    <%= item.getStockQuantity() %> units
                                </span>
                            </td>
                            <td>
                                <%= item.getDescription() != null && item.getDescription().length() > 50 
                                    ? item.getDescription().substring(0, 50) + "..." 
                                    : (item.getDescription() != null ? item.getDescription() : "-") %>
                            </td>
                            <td><%= item.getCreatedDate() %></td>
                            <td>
                                <div class="action-buttons">
                                    <a href="item?action=view&id=<%= item.getItemId() %>" 
                                       class="btn btn-primary btn-sm">👁️ View</a>
                                    <a href="item?action=edit&id=<%= item.getItemId() %>" 
                                       class="btn btn-warning btn-sm">✏️ Edit</a>
                                    <a href="item?action=delete&id=<%= item.getItemId() %>" 
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirmDelete('<%= item.getName() %>')">🗑️ Delete</a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <h3>No Items Found</h3>
                    <p>
                        <% if (searchTerm != null) { %>
                        No items match your search criteria for "<%= searchTerm %>".
                        <% } else { %>
                        Start by adding your first item to the inventory.
                        <% } %>
                    </p>
                    <a href="item?action=add" class="btn btn-success" style="margin-top: 1rem;">Add Item</a>
                </div>
                <% } %>
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

        // Confirm delete function
        function confirmDelete(itemName) {
            return confirm('Are you sure you want to delete item "' + itemName + '"? This action cannot be undone.');
        }

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.opacity = '0';
                alert.style.transform = 'translateY(-10px)';
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 300);
            });
        }, 5000);

        // Add loading states to buttons
        document.querySelectorAll('.btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                if (!this.onclick && !this.href.includes('delete')) {
                    this.style.opacity = '0.7';
                    this.innerHTML = this.innerHTML + '...';
                }
            });
        });

        // Auto-focus search input
        const searchInput = document.querySelector('input[name="searchTerm"]');
        if (searchInput && !searchInput.value) {
            searchInput.focus();
        }

        // Highlight low stock items
        const stockElements = document.querySelectorAll('.stock-low');
        stockElements.forEach(function(element) {
            const row = element.closest('tr');
            if (row) {
                row.style.backgroundColor = '#fdf2f2';
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Item Management page loaded');
        });
    </script>
</body>
</html>