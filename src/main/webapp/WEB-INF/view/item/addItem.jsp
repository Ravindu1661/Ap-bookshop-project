<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
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
            background-color: #f5f5f5;
        }

        .navbar {
            background-color: #2c3e50;
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h1 {
            font-size: 1.5rem;
        }

        .nav-links {
            display: flex;
            gap: 1rem;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .nav-links a:hover {
            background-color: #34495e;
        }

        .container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .page-header h2 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .breadcrumb a {
            color: #3498db;
            text-decoration: none;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        .form-container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }

        .form-control.error {
            border-color: #e74c3c;
            box-shadow: 0 0 0 2px rgba(231, 76, 60, 0.2);
        }

        .form-text {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.25rem;
        }

        .field-error {
            color: #e74c3c;
            font-size: 0.8rem;
            margin-top: 0.25rem;
            display: block;
        }

        .category-selection {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .category-option {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .category-option:hover {
            border-color: #3498db;
            background-color: #f8f9fa;
        }

        .category-option.selected {
            border-color: #3498db;
            background-color: #e3f2fd;
        }

        .category-option.error {
            border-color: #e74c3c !important;
            background-color: #fdf2f2;
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

        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
            font-size: 1rem;
            margin-right: 1rem;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        .btn:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            pointer-events: none;
        }

        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #7f8c8d;
        }

        .alert {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .form-actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }

        /* Loading spinner */
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

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }

            .container {
                margin: 1rem auto;
            }

            .form-container {
                padding: 1rem;
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
        }

        @media (max-width: 480px) {
            .category-selection {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Add Item</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="item?action=list">Items</a>
            <a href="customer?action=list">Customers</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Add New Item</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="item?action=list">Items</a> &gt; 
                Add Item
            </div>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="form-container">
            <form action="item" method="post" id="addItemForm">
                <input type="hidden" name="action" value="add">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="itemCode">Item Code</label>
                        <input type="text" class="form-control" id="itemCode" name="itemCode" 
                               placeholder="Leave blank for auto-generation">
                        <div class="form-text">Item code will be auto-generated if left blank</div>
                    </div>

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
                        Add Item
                    </button>
                    <a href="item?action=list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <!-- Include external JavaScript file -->
    <script src="js/additem.js"></script>
</body>
</html>