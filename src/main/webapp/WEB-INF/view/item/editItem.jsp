<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Item"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Item item = (Item) request.getAttribute("item");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Item - Redupahana</title>
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

        /* Sidebar Styles (same as other pages) */
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

        /* Item Info Card */
        .item-info-card {
            background: #e8f4fd;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border-left: 4px solid #2c3e50;
        }

        .item-info-card h4 {
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

        /* Category Selection */
        .category-selection {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .category-option {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .category-option:hover {
            border-color: #2c3e50;
            background-color: #f8f9fa;
        }

        .category-option.selected {
            border-color: #2c3e50;
            background-color: #e8f4fd;
        }

        .category-option input[type="radio"] { display: none; }

        .category-option h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .category-option p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .category-icon {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
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
            .category-selection { grid-template-columns: repeat(2, 1fr); }
            .btn { display: block; margin-bottom: 0.5rem; margin-right: 0; text-align: center; }
            .info-grid { grid-template-columns: 1fr; }
            .user-info span { display: none; }
        }

        @media (max-width: 480px) {
            .category-selection { grid-template-columns: 1fr; }
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
                <h1 class="page-title">Edit Item</h1>
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
                <h1>Edit Item</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="item?action=list">Item Management</a> &gt; 
                    Edit Item
                </div>
            </div>

            <% if (item != null) { %>
            <!-- Current Item Info -->
            <div class="item-info-card">
                <h4>📝 Current Item Information</h4>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Item Code</span>
                        <span class="info-value"><%= item.getItemCode() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Current Category</span>
                        <span class="info-value"><%= item.getCategory() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Current Price</span>
                        <span class="info-value">Rs. <%= String.format("%.2f", item.getPrice()) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Created Date</span>
                        <span class="info-value"><%= item.getCreatedDate() %></span>
                    </div>
                </div>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Edit Item Form -->
            <div class="form-container">
                <form action="item" method="post" id="editItemForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
                    
                    <div class="form-group">
                        <label for="itemCode">Item Code</label>
                        <input type="text" class="form-control" value="<%= item.getItemCode() %>" disabled>
                        <div class="form-text">Item code cannot be changed</div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Item Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="<%= item.getName() %>" required placeholder="Enter item name">
                        </div>

                        <div class="form-group">
                            <label for="price">Price (Rs.) <span class="required">*</span></label>
                            <input type="number" class="form-control" id="price" name="price" 
                                   value="<%= item.getPrice() %>" required min="0.01" step="0.01">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" 
                                  placeholder="Enter item description (optional)"><%= item.getDescription() != null ? item.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="stockQuantity">Stock Quantity <span class="required">*</span></label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" 
                                   value="<%= item.getStockQuantity() %>" required min="0">
                        </div>

                        <div class="form-group">
                            <label>Category <span class="required">*</span></label>
                            <select class="form-control" name="category" id="category" required>
                                <option value="Electronics" <%= "Electronics".equals(item.getCategory()) ? "selected" : "" %>>📱 Electronics</option>
                                <option value="Clothing" <%= "Clothing".equals(item.getCategory()) ? "selected" : "" %>>👕 Clothing</option>
                                <option value="Books" <%= "Books".equals(item.getCategory()) ? "selected" : "" %>>📚 Books</option>
                                <option value="Home" <%= "Home".equals(item.getCategory()) ? "selected" : "" %>>🏠 Home & Garden</option>
                                <option value="Sports" <%= "Sports".equals(item.getCategory()) ? "selected" : "" %>>⚽ Sports</option>
                                <option value="Other" <%= "Other".equals(item.getCategory()) ? "selected" : "" %>>📦 Other</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">💾 Update Item</button>
                        <a href="item?action=view&id=<%= item.getItemId() %>" class="btn btn-secondary">👁️ View Details</a>
                        <a href="item?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>

            <% } else { %>
            <!-- Item Not Found -->
            <div class="alert alert-error">
                ❌ Item not found or invalid item ID.
            </div>
            <div style="text-align: center; margin-top: 2rem;">
                <a href="item?action=list" class="btn btn-primary">Back to Item List</a>
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

        // Form Validation
        document.getElementById('editItemForm').addEventListener('submit', function(e) {
            const name = document.getElementById('name').value.trim();
            const price = parseFloat(document.getElementById('price').value);
            const stockQuantity = parseInt(document.getElementById('stockQuantity').value);

            let isValid = true;
            let errorMessage = '';

            if (!name) {
                errorMessage += 'Item name is required. ';
                isValid = false;
            }

            if (!price || price <= 0) {
                errorMessage += 'Valid price is required. ';
                isValid = false;
            }

            if (isNaN(stockQuantity) || stockQuantity < 0) {
                errorMessage += 'Valid stock quantity is required. ';
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
            submitBtn.innerHTML = '⏳ Updating Item...';
            submitBtn.disabled = true;
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Edit Item page loaded');
            
            // Focus on item name field
            document.getElementById('name').focus();
        });
    </script>
</body>
</html>