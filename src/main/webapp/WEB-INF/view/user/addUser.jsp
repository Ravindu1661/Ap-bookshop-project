<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
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
    <title>Add User - Redupahana</title>
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

        .admin-notice {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            border-left: 4px solid #f39c12;
        }

        .admin-notice h4 {
            color: #856404;
            margin-bottom: 0.5rem;
        }

        .admin-notice p {
            color: #856404;
            font-size: 0.9rem;
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
        }

        .form-text {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.25rem;
        }

        .role-selection {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .role-option {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 1.5rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .role-option:hover {
            border-color: #3498db;
            background-color: #f8f9fa;
        }

        .role-option.selected {
            border-color: #3498db;
            background-color: #e3f2fd;
        }

        .role-option input[type="radio"] {
            display: none;
        }

        .role-option h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .role-option p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .role-icon {
            font-size: 2rem;
            margin-bottom: 1rem;
        }

        .password-strength {
            margin-top: 0.5rem;
        }

        .strength-bar {
            height: 4px;
            background-color: #e0e0e0;
            border-radius: 2px;
            overflow: hidden;
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
        }

        .strength-weak { background-color: #e74c3c; }
        .strength-medium { background-color: #f39c12; }
        .strength-strong { background-color: #27ae60; }

        .strength-text {
            font-size: 0.8rem;
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

            .form-row {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .role-selection {
                grid-template-columns: 1fr;
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
        <h1>Add User</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="user?action=list">Users</a>
            <a href="customer?action=list">Customers</a>
            <a href="item?action=list">Items</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Add New User</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="user?action=list">Users</a> &gt; 
                Add User
            </div>
        </div>

        <div class="admin-notice">
            <h4>👤 Admin Access Required</h4>
            <p>You are creating a new user account. Please ensure all information is accurate and assign appropriate permissions.</p>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="form-container">
            <form action="user" method="post" id="addUserForm">
                <input type="hidden" name="action" value="add">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username <span class="required">*</span></label>
                        <input type="text" class="form-control" id="username" name="username" required 
                               placeholder="Enter unique username" autocomplete="username">
                        <div class="form-text">Username must be unique and cannot be changed later</div>
                    </div>

                    <div class="form-group">
                        <label for="fullName">Full Name <span class="required">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName" required 
                               placeholder="Enter full name" autocomplete="name">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" class="form-control" id="email" name="email" 
                               placeholder="Enter email address (optional)" autocomplete="email">
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" class="form-control" id="phone" name="phone" 
                               placeholder="Enter 10-digit phone number" pattern="[0-9]{10}" autocomplete="tel">
                        <div class="form-text">Enter a valid 10-digit phone number</div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password <span class="required">*</span></label>
                    <input type="password" class="form-control" id="password" name="password" required 
                           placeholder="Enter secure password" autocomplete="new-password">
                    <div class="password-strength">
                        <div class="strength-bar">
                            <div class="strength-fill" id="strengthFill"></div>
                        </div>
                        <div class="strength-text" id="strengthText">Password strength will be shown here</div>
                    </div>
                    <div class="form-text">Password should be at least 8 characters with letters and numbers</div>
                </div>

                <div class="form-group">
                    <label>User Role <span class="required">*</span></label>
                    <div class="role-selection">
                        <div class="role-option" onclick="selectRole('ADMIN')">
                            <input type="radio" name="role" value="ADMIN" id="roleAdmin" required>
                            <div class="role-icon">👑</div>
                            <h4>Administrator</h4>
                            <p>Full system access including user management, reports, and all features</p>
                        </div>
                        <div class="role-option" onclick="selectRole('CASHIER')">
                            <input type="radio" name="role" value="CASHIER" id="roleCashier" required>
                            <div class="role-icon">💼</div>
                            <h4>Cashier</h4>
                            <p>Access to billing, customer management, and inventory operations</p>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Create User</button>
                    <a href="user?action=list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    <script src="js/addUser.js"></script>
</body>
</html>