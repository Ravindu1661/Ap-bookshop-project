<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
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
    <title>Add Item - Redupahana</title>
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

        .category-option input[type="radio"] {
            display: none;
        }

        .category-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .category-name {
            color: #2c3e50;
            font-weight: 600;
            font-size: 0.9rem;
        }

        /* Price Input */
        .price-input-group {
            position: relative;
        }

        .price-input-group::before {
            content: "Rs.";
            position: absolute;
            left: 0.8rem;
            top: 50%;
            transform: translateY(-50%);
            color: #7f8c8d;
            font-weight: 600;
        }

        .price-input-group .form-control {
            padding-left: 3rem;
        }

        /* Stock Indicator */
        .stock-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }

        .stock-level {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
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

        .btn:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            pointer-events: none;
        }

        .form-actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
            text-align: center;
        }

        /* Loading Spinner */
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #ffffff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 0.5rem;
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
            
            .category-selection {
                grid-template-columns: repeat(2, 1fr);
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

        @media (max-width: 480px) {
            .category-selection {
                grid-template-columns: 1fr;
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
                <h1 class="page-title">Add New Item</h1>
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
                <h1>Add New Item</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="item?action=list">Item Management</a> &gt; 
                    Add Item
                </div>
            </div>

            <!-- Info Notice -->
            <div class="info-notice">
                <h4>📦 Add New Inventory Item</h4>
                <p>Fill in the details below to add a new item to your inventory. Required fields are marked with an asterisk (*).</p>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Add Item Form -->
            <div class="form-container">
                <form action="item" method="post" id="addItemForm">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Item Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" required 
                                   placeholder="Enter item name">
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" 
                                  placeholder="Enter item description (optional)"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="price">Price <span class="required">*</span></label>
                            <div class="price-input-group">
                                <input type="number" class="form-control" id="price" name="price" required 
                                       min="0.01" step="0.01" placeholder="0.00">
                            </div>
                            <div class="form-text">Enter price in Sri Lankan Rupees</div>
                        </div>

                        <div class="form-group">
                            <label for="stockQuantity">Stock Quantity <span class="required">*</span></label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" required 
                                   min="0" placeholder="Enter quantity">
                            <div class="stock-indicator">
                                <span>Stock Level:</span>
                                <span class="stock-level" id="stockLevel">-</span>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Category <span class="required">*</span></label>
                        <div class="category-selection">
                            <div class="category-option" onclick="selectCategory('Electronics')">
                                <input type="radio" name="category" value="Electronics" id="categoryElectronics" required>
                                <div class="category-icon">📱</div>
                                <div class="category-name">Electronics</div>
                            </div>
                            <div class="category-option" onclick="selectCategory('Clothing')">
                                <input type="radio" name="category" value="Clothing" id="categoryClothing" required>
                                <div class="category-icon">👕</div>
                                <div class="category-name">Clothing</div>
                            </div>
                            <div class="category-option" onclick="selectCategory('Books')">
                                <input type="radio" name="category" value="Books" id="categoryBooks" required>
                                <div class="category-icon">📚</div>
                                <div class="category-name">Books</div>
                            </div>
                            <div class="category-option" onclick="selectCategory('Home')">
                                <input type="radio" name="category" value="Home" id="categoryHome" required>
                                <div class="category-icon">🏠</div>
                                <div class="category-name">Home & Garden</div>
                            </div>
                            <div class="category-option" onclick="selectCategory('Sports')">
                                <input type="radio" name="category" value="Sports" id="categorySports" required>
                                <div class="category-icon">⚽</div>
                                <div class="category-name">Sports</div>
                            </div>
                            <div class="category-option" onclick="selectCategory('Other')">
                                <input type="radio" name="category" value="Other" id="categoryOther" required>
                                <div class="category-icon">📦</div>
                                <div class="category-name">Other</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            ✅ Add Item
                        </button>
                        <a href="item?action=list" class="btn btn-secondary">❌ Cancel</a>
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

        // Category Selection
        function selectCategory(category) {
            // Remove selected class from all options
            document.querySelectorAll('.category-option').forEach(function(option) {
                option.classList.remove('selected');
            });
            
            // Add selected class to clicked option
            event.currentTarget.classList.add('selected');
            
            // Check the radio button
            document.getElementById('category' + category).checked = true;
        }

        // Stock Level Indicator
        const stockQuantityInput = document.getElementById('stockQuantity');
        const stockLevelSpan = document.getElementById('stockLevel');

        stockQuantityInput.addEventListener('input', function() {
            const quantity = parseInt(this.value) || 0;
            
            stockLevelSpan.className = 'stock-level';
            
            if (quantity === 0) {
                stockLevelSpan.textContent = 'Out of Stock';
                stockLevelSpan.classList.add('stock-low');
            } else if (quantity <= 10) {
                stockLevelSpan.textContent = 'Low Stock';
                stockLevelSpan.classList.add('stock-low');
            } else if (quantity <= 50) {
                stockLevelSpan.textContent = 'Medium Stock';
                stockLevelSpan.classList.add('stock-medium');
            } else {
                stockLevelSpan.textContent = 'Good Stock';
                stockLevelSpan.classList.add('stock-good');
            }
        });

        // Form Validation
        document.getElementById('addItemForm').addEventListener('submit', function(e) {
            const name = document.getElementById('name').value.trim();
            const price = parseFloat(document.getElementById('price').value);
            const stockQuantity = parseInt(document.getElementById('stockQuantity').value);
            const category = document.querySelector('input[name="category"]:checked');

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

            if (!category) {
                errorMessage += 'Please select a category. ';
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
            submitBtn.innerHTML = '⏳ Adding Item...';
            submitBtn.disabled = true;
        });

        // Price input formatting
        document.getElementById('price').addEventListener('input', function() {
            const value = parseFloat(this.value);
            if (!isNaN(value) && value > 0) {
                this.style.borderColor = '#27ae60';
            } else {
                this.style.borderColor = '#ddd';
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Add Item page loaded');
            
            // Focus on item name field
            document.getElementById('name').focus();
            
            // Initialize stock level indicator
            stockQuantityInput.dispatchEvent(new Event('input'));
        });
    </script>
</body>
</html>