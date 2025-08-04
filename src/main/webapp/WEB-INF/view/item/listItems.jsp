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
            max-width: 1400px;
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
            margin-bottom: 1rem;
        }

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .search-form {
            display: flex;
            gap: 0.5rem;
        }

        .search-form input {
            padding: 0.7rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            min-width: 250px;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
            font-size: 0.9rem;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
        }

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.8rem;
        }

        .alert {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .table-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th,
        .table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #ddd;
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

        .stock-status {
            display: inline-block;
            padding: 0.25rem 0.5rem;
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
        }

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
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

            .table-container {
                overflow-x: auto;
            }

            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Item Management</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="customer?action=list">Customers</a>
            <a href="bill?action=list">Bills</a>
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list">Users</a>
            <% } %>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Item Management</h2>
            <div class="header-actions">
                <form class="search-form" action="item" method="get">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="searchTerm" placeholder="Search by name, code, or category..." 
                           value="<%= searchTerm != null ? searchTerm : "" %>">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <% if (searchTerm != null) { %>
                    <a href="item?action=list" class="btn btn-warning">Clear</a>
                    <% } %>
                </form>
                <a href="item?action=add" class="btn btn-success">Add New Item</a>
            </div>
        </div>

        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <%= successMessage %>
        </div>
        <% } %>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="table-container">
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
                                   class="btn btn-primary btn-sm">View</a>
                                <a href="item?action=edit&id=<%= item.getItemId() %>" 
                                   class="btn btn-warning btn-sm">Edit</a>
                                <a href="item?action=delete&id=<%= item.getItemId() %>" 
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Are you sure you want to delete this item?')">Delete</a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state">
                <h3>No items found</h3>
                <p>
                    <% if (searchTerm != null) { %>
                    No items match your search criteria.
                    <% } else { %>
                    Start by adding your first item to the inventory.
                    <% } %>
                </p>
                <a href="item?action=add" class="btn btn-success">Add Item</a>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Add confirmation for delete actions
            const deleteLinks = document.querySelectorAll('.btn-danger');
            deleteLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    if (!confirm('Are you sure you want to delete this item? This action cannot be undone.')) {
                        e.preventDefault();
                    }
                });
            });

            // Auto-focus search input
            const searchInput = document.querySelector('input[name="searchTerm"]');
            if (searchInput && !searchInput.value) {
                searchInput.focus();
            }

            // Add loading state to buttons
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(btn => {
                btn.addEventListener('click', function() {
                    if (!this.classList.contains('btn-danger')) {
                        this.style.opacity = '0.7';
                        this.style.pointerEvents = 'none';
                    }
                });
            });

            // Highlight low stock items
            const stockElements = document.querySelectorAll('.stock-low');
            stockElements.forEach(element => {
                const row = element.closest('tr');
                row.style.backgroundColor = '#fdf2f2';
            });
        });
    </script>
</body>
</html>