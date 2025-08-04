<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    User user = (User) request.getAttribute("user");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Redupahana</title>
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

        .user-info {
            background-color: #e8f4fd;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            border-left: 4px solid #3498db;
        }

        .user-info h4 {
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

        .form-control:disabled {
            background-color: #f8f9fa;
            cursor: not-allowed;
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

            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Edit User</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="user?action=list">Users</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Edit User</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="user?action=list">Users</a> &gt; 
                Edit User
            </div>
        </div>

        <% if (user != null) { %>
        <div class="user-info">
            <h4>Current User Information</h4>
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">User ID</span>
                    <span class="info-value">#<%= user.getUserId() %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Username</span>
                    <span class="info-value"><%= user.getUsername() %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Current Role</span>
                    <span class="info-value"><%= user.getRole() %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Created Date</span>
                    <span class="info-value"><%= user.getCreatedDate() %></span>
                </div>
            </div>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="form-container">
            <form action="user" method="post" id="editUserForm">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" class="form-control" id="username" name="username" 
                           value="<%= user.getUsername() %>" disabled>
                    <div class="form-text">Username cannot be changed</div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="fullName">Full Name <span class="required">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName" 
                               value="<%= user.getFullName() %>" required 
                               placeholder="Enter full name">
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" class="form-control" id="email" name="email" 
                               value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                               placeholder="Enter email address (optional)">
                    </div>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="tel" class="form-control" id="phone" name="phone" 
                           value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                           placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                    <div class="form-text">Enter a valid 10-digit phone number</div>
                </div>

                <div class="form-group">
                    <label>User Role <span class="required">*</span></label>
                    <div class="role-selection">
                        <div class="role-option <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "selected" : "" %>" onclick="selectRole('ADMIN')">
                            <input type="radio" name="role" value="ADMIN" id="roleAdmin" 
                                   <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "checked" : "" %> required>
                            <div class="role-icon">👑</div>
                            <h4>Administrator</h4>
                            <p>Full system access including user management</p>
                        </div>
                        <div class="role-option <%= Constants.ROLE_CASHIER.equals(user.getRole()) ? "selected" : "" %>" onclick="selectRole('CASHIER')">
                            <input type="radio" name="role" value="CASHIER" id="roleCashier" 
                                   <%= Constants.ROLE_CASHIER.equals(user.getRole()) ? "checked" : "" %> required>
                            <div class="role-icon">💼</div>
                            <h4>Cashier</h4>
                            <p>Access to billing and customer management</p>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update User</button>
                    <a href="user?action=list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
        <% } else { %>
        <div class="alert alert-error">
            User not found or invalid user ID.
        </div>
        <div style="text-align: center; margin-top: 2rem;">
            <a href="user?action=list" class="btn btn-primary">Back to User List</a>
        </div>
        <% } %>
    </div>

    <script src="js/editUser.js"></script>
</body>
</html>