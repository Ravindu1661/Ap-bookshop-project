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
    <title>Add Customer - Redupahana</title>
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
            max-width: 800px;
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

        .form-group {
            margin-bottom: 1.5rem;
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
        }

        .form-text {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.25rem;
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

            .btn {
                display: block;
                margin-bottom: 0.5rem;
                margin-right: 0;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Add Customer</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="customer?action=list">Customers</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Add New Customer</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="customer?action=list">Customers</a> &gt; 
                Add Customer
            </div>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="form-container">
            <form action="customer" method="post" id="addCustomerForm">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label for="accountNumber">Account Number</label>
                    <input type="text" class="form-control" id="accountNumber" name="accountNumber" 
                           placeholder="Leave blank for auto-generation">
                    <div class="form-text">Account number will be auto-generated if left blank</div>
                </div>

                <div class="form-group">
                    <label for="name">Customer Name <span class="required">*</span></label>
                    <input type="text" class="form-control" id="name" name="name" required 
                           placeholder="Enter customer full name">
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number <span class="required">*</span></label>
                    <input type="tel" class="form-control" id="phone" name="phone" required 
                           placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                    <div class="form-text">Enter a valid 10-digit phone number</div>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="Enter email address (optional)">
                </div>

                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea class="form-control" id="address" name="address" rows="3" 
                              placeholder="Enter customer address (optional)"></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Customer</button>
                    <a href="customer?action=list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
<script src="js/addCustomer.js"></script>
</body>
</html>