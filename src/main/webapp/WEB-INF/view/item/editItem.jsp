<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Item"%>
<%@ page import="com.redupahana.model.User"%>
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
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; }
        .navbar { background-color: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { font-size: 1.5rem; }
        .nav-links { display: flex; gap: 1rem; }
        .nav-links a { color: white; text-decoration: none; padding: 0.5rem 1rem; border-radius: 4px; transition: background-color 0.3s; }
        .nav-links a:hover { background-color: #34495e; }
        .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
        .page-header { background: white; padding: 2rem; border-radius: 8px; margin-bottom: 1rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .page-header h2 { color: #2c3e50; margin-bottom: 0.5rem; }
        .breadcrumb { color: #7f8c8d; font-size: 0.9rem; }
        .breadcrumb a { color: #3498db; text-decoration: none; }
        .item-info { background-color: #e8f4fd; padding: 1.5rem; border-radius: 8px; margin-bottom: 2rem; border-left: 4px solid #3498db; }
        .form-container { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 1.5rem; }
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: #2c3e50; }
        .required { color: #e74c3c; }
        .form-control { width: 100%; padding: 0.8rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; transition: border-color 0.3s; }
        .form-control:focus { outline: none; border-color: #3498db; box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2); }
        .form-control:disabled { background-color: #f8f9fa; cursor: not-allowed; }
        .btn { padding: 0.8rem 2rem; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; transition: background-color 0.3s; font-size: 1rem; margin-right: 1rem; }
        .btn-primary { background-color: #3498db; color: white; }
        .btn-primary:hover { background-color: #2980b9; }
        .btn-secondary { background-color: #95a5a6; color: white; }
        .btn-secondary:hover { background-color: #7f8c8d; }
        .alert-error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Edit Item</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="item?action=list">Items</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Edit Item</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="item?action=list">Items</a> &gt; 
                Edit Item
            </div>
        </div>

        <% if (item != null) { %>
        <div class="item-info">
            <h4>Current Item Information</h4>
            <p><strong>Item Code:</strong> <%= item.getItemCode() %> | 
               <strong>Created:</strong> <%= item.getCreatedDate() %></p>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert-error"><%= errorMessage %></div>
        <% } %>

        <div class="form-container">
            <form action="item" method="post" id="editItemForm">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
                
                <div class="form-group">
                    <label for="itemCode">Item Code</label>
                    <input type="text" class="form-control" value="<%= item.getItemCode() %>" disabled>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Item Name <span class="required">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="<%= item.getName() %>" required>
                    </div>
                    <div class="form-group">
                        <label for="category">Category <span class="required">*</span></label>
                        <select class="form-control" id="category" name="category" required>
                            <option value="Electronics" <%= "Electronics".equals(item.getCategory()) ? "selected" : "" %>>Electronics</option>
                            <option value="Clothing" <%= "Clothing".equals(item.getCategory()) ? "selected" : "" %>>Clothing</option>
                            <option value="Books" <%= "Books".equals(item.getCategory()) ? "selected" : "" %>>Books</option>
                            <option value="Home" <%= "Home".equals(item.getCategory()) ? "selected" : "" %>>Home & Garden</option>
                            <option value="Sports" <%= "Sports".equals(item.getCategory()) ? "selected" : "" %>>Sports</option>
                            <option value="Other" <%= "Other".equals(item.getCategory()) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3"><%= item.getDescription() != null ? item.getDescription() : "" %></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="price">Price (Rs.) <span class="required">*</span></label>
                        <input type="number" class="form-control" id="price" name="price" 
                               value="<%= item.getPrice() %>" required min="0.01" step="0.01">
                    </div>
                    <div class="form-group">
                        <label for="stockQuantity">Stock Quantity <span class="required">*</span></label>
                        <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" 
                               value="<%= item.getStockQuantity() %>" required min="0">
                    </div>
                </div>

                <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #eee;">
                    <button type="submit" class="btn btn-primary">Update Item</button>
                    <a href="item?action=view&id=<%= item.getItemId() %>" class="btn btn-secondary">View Details</a>
                    <a href="item?action=list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
        <% } else { %>
        <div class="alert-error">Item not found.</div>
        <% } %>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('editItemForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    const name = document.getElementById('name').value.trim();
                    const price = parseFloat(document.getElementById('price').value);
                    const stock = parseInt(document.getElementById('stockQuantity').value);

                    if (!name || isNaN(price) || price <= 0 || isNaN(stock) || stock < 0) {
                        e.preventDefault();
                        alert('Please fill all required fields with valid values.');
                        return;
                    }

                    const submitBtn = form.querySelector('button[type="submit"]');
                    submitBtn.textContent = 'Updating...';
                    submitBtn.disabled = true;
                });
            }
        });
    </script>
</body>
</html>