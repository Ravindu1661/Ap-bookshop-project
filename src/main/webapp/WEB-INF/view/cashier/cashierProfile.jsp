<!-- cashierProfile.jsp - Cashier Profile Management -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Redupahana Cashier</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; }
        .navbar { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { font-size: 1.5rem; }
        .nav-links { display: flex; gap: 1rem; }
        .nav-links a { color: white; text-decoration: none; padding: 0.5rem 1rem; border-radius: 4px; transition: background-color 0.3s; }
        .nav-links a:hover { background-color: rgba(255,255,255,0.2); }
        .container { max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        .profile-card { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); overflow: hidden; }
        .profile-header { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); color: white; padding: 2rem; text-align: center; }
        .profile-avatar { width: 120px; height: 120px; background-color: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1rem; font-size: 4rem; }
        .profile-name { font-size: 2rem; font-weight: 600; margin-bottom: 0.5rem; }
        .profile-role { font-size: 1.1rem; opacity: 0.9; }
        .profile-content { padding: 2rem; }
        .info-section { margin-bottom: 2rem; }
        .info-section h3 { color: #2c3e50; margin-bottom: 1rem; font-size: 1.2rem; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 0.8rem; padding-bottom: 0.5rem; border-bottom: 1px solid #ecf0f1; }
        .info-label { font-weight: 600; color: #7f8c8d; }
        .info-value { color: #2c3e50; }
        .btn { padding: 0.8rem 1.5rem; border: none; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-block; font-size: 0.9rem; margin-right: 1rem; transition: all 0.3s; }
        .btn-primary { background-color: #27ae60; color: white; }
        .btn-primary:hover { background-color: #229954; transform: translateY(-2px); }
        .btn-secondary { background-color: #95a5a6; color: white; }
        .btn-secondary:hover { background-color: #7f8c8d; }
        .alert { padding: 1rem; border-radius: 6px; margin-bottom: 1rem; }
        .alert-success { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .alert-error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>My Profile</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="bill?action=create">New Bill</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <% if (successMessage != null) { %>
        <div class="alert alert-success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>

        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar">💼</div>
                <div class="profile-name"><%= loggedUser.getFullName() %></div>
                <div class="profile-role">Cashier</div>
            </div>

            <div class="profile-content">
                <div class="info-section">
                    <h3>👤 Personal Information</h3>
                    <div class="info-row">
                        <span class="info-label">Username:</span>
                        <span class="info-value"><%= loggedUser.getUsername() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Full Name:</span>
                        <span class="info-value"><%= loggedUser.getFullName() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Email:</span>
                        <span class="info-value"><%= loggedUser.getEmail() != null ? loggedUser.getEmail() : "Not provided" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Phone:</span>
                        <span class="info-value"><%= loggedUser.getPhone() != null ? loggedUser.getPhone() : "Not provided" %></span>
                    </div>
                </div>

                <div class="info-section">
                    <h3>💼 Work Information</h3>
                    <div class="info-row">
                        <span class="info-label">Role:</span>
                        <span class="info-value">Cashier</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Employee ID:</span>
                        <span class="info-value">#<%= loggedUser.getUserId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Join Date:</span>
                        <span class="info-value"><%= loggedUser.getCreatedDate() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Status:</span>
                        <span class="info-value" style="color: #27ae60; font-weight: 600;">Active</span>
                    </div>
                </div>

                <div style="text-align: center; margin-top: 2rem;">
                    <a href="javascript:void(0)" onclick="requestProfileUpdate()" class="btn btn-primary">Request Profile Update</a>
                    <a href="dashboard" class="btn btn-secondary">Back to Dashboard</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        function requestProfileUpdate() {
            alert('Please contact your administrator to update your profile information.');
        }
    </script>
</body>
</html>