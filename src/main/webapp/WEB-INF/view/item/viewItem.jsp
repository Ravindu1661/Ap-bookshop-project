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
    <title>View Item - Redupahana</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; }
        .navbar { background-color: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { font-size: 1.5rem; }
        .nav-links { display: flex; gap: 1rem; }
        .nav-links a { color: white; text-decoration: none; padding: 0.5rem 1rem; border-radius: 4px; transition: background-color 0.3s; }
        .nav-links a:hover { background-color: #34495e; }
        .container { max-width: 1000px; margin: 2rem auto; padding: 0 1rem; }
        .item-profile { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .profile-header { background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); color: white; padding: 2rem; text-align: center; }
        .item-icon { font-size: 4rem; margin-bottom: 1rem; }
        .item-name { font-size: 2rem; font-weight: 600; margin-bottom: 0.5rem; }
        .item-code { font-size: 1.1rem; opacity: 0.9; }
        .profile-content { padding: 2rem; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; }
        .info-section { background-color: #f8f9fa; padding: 1.5rem; border-radius: 8px; border-left: 4px solid #3498db; }
        .info-section h4 { color: #2c3e50; margin-bottom: 1rem; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 0.8rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e9ecef; }
        .info-row:last-child { border-bottom: none; margin-bottom: 0; }
        .info-label { font-weight: 600; color: #7f8c8d; }
        .info-value { color: #2c3e50; text-align: right; }
        .price { font-weight: 600; color: #27ae60; font-size: 1.2rem; }
        .stock-badge { padding: 0.25rem 0.8rem; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
        .stock-low { background-color: #f8d7da; color: #721c24; }
        .stock-medium { background-color: #fff3cd; color: #856404; }
        .stock-good { background-color: #d4edda; color: #155724; }
        .action-buttons { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #eee; }
        .btn { padding: 0.8rem 2rem; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.3s ease; font-size: 1rem; font-weight: 600; }
        .btn-primary { background-color: #3498db; color: white; }
        .btn-warning { background-color: #f39c12; color: white; }
        .btn-secondary { background-color: #95a5a6; color: white; }
        .btn:hover { transform: translateY(-2px); }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Item Details</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="item?action=list">Items</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <% if (item != null) { %>
        <div class="item-profile">
            <div class="profile-header">
                <div class="item-icon">📦</div>
                <div class="item-name"><%= item.getName() %></div>
                <div class="item-code">Code: <%= item.getItemCode() %></div>
            </div>

            <div class="profile-content">
                <div class="info-grid">
                    <div class="info-section">
                        <h4>📋 Basic Information</h4>
                        <div class="info-row">
                            <span class="info-label">Item ID:</span>
                            <span class="info-value">#<%= item.getItemId() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Name:</span>
                            <span class="info-value"><%= item.getName() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Category:</span>
                            <span class="info-value"><%= item.getCategory() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Description:</span>
                            <span class="info-value"><%= item.getDescription() != null ? item.getDescription() : "No description" %></span>
                        </div>
                    </div>

                    <div class="info-section">
                        <h4>💰 Pricing & Stock</h4>
                        <div class="info-row">
                            <span class="info-label">Price:</span>
                            <span class="info-value price">Rs. <%= String.format("%.2f", item.getPrice()) %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Stock:</span>
                            <span class="info-value">
                                <span class="stock-badge <%= 
                                    item.getStockQuantity() <= 10 ? "stock-low" : 
                                    item.getStockQuantity() <= 50 ? "stock-medium" : "stock-good" 
                                %>">
                                    <%= item.getStockQuantity() %> units
                                </span>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Status:</span>
                            <span class="info-value">
                                <span class="stock-badge stock-good">Active</span>
                            </span>
                        </div>
                    </div>

                    <div class="info-section">
                        <h4>📅 Dates</h4>
                        <div class="info-row">
                            <span class="info-label">Created:</span>
                            <span class="info-value"><%= item.getCreatedDate() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Updated:</span>
                            <span class="info-value"><%= item.getUpdatedDate() != null ? item.getUpdatedDate() : "Never" %></span>
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <a href="item?action=edit&id=<%= item.getItemId() %>" class="btn btn-warning">✏️ Edit Item</a>
                    <a href="item?action=list" class="btn btn-secondary">📋 Back to List</a>
                </div>
            </div>
        </div>
        <% } else { %>
        <div style="background: white; padding: 3rem; text-align: center; border-radius: 8px;">
            <h3 style="color: #e74c3c;">Item Not Found</h3>
            <p style="margin: 1rem 0;">The requested item could not be found.</p>
            <a href="item?action=list" class="btn btn-primary">Back to Items</a>
        </div>
        <% } %>
    </div>
</body>
</html>