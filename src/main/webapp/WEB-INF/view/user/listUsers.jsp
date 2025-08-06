<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    List<User> users = (List<User>) request.getAttribute("users");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "user");
    request.setAttribute("pageTitle", "User Management");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        /* Additional styles for user list specific features */
        .current-user {
            background-color: #e8f4fd !important;
            border-left: 4px solid #007bff !important;
        }

        .current-user:hover {
            background-color: #e8f4fd !important;
        }

        .role-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .role-admin {
            background-color: #f8d7da;
            color: #721c24;
        }

        .role-cashier {
            background-color: #d4edda;
            color: #155724;
        }

        .user-name {
            font-weight: 600;
            color: #2c3e50;
        }

        .current-user-indicator {
            color: #007bff;
            font-size: 0.8rem;
            font-weight: 500;
            margin-left: 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>👥 User Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; User Management
                </div>
            </div>

            <!-- Stats Cards -->
            <%
                int totalUsers = 0;
                int adminCount = 0;
                int cashierCount = 0;
                
                if (users != null) {
                    totalUsers = users.size();
                    for (User user : users) {
                        if (Constants.ROLE_ADMIN.equals(user.getRole())) {
                            adminCount++;
                        } else if (Constants.ROLE_CASHIER.equals(user.getRole())) {
                            cashierCount++;
                        }
                    }
                }
            %>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= totalUsers %></h3>
                    <p>📊 Total Users</p>
                </div>
                <div class="stat-card">
                    <h3><%= adminCount %></h3>
                    <p>👑 Administrators</p>
                </div>
                <div class="stat-card">
                    <h3><%= cashierCount %></h3>
                    <p>💼 Cashiers</p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Users Table -->
            <div class="table-container">
                <div class="table-header">
                    <h2>👥 System Users (<%= totalUsers %>)</h2>
                    <a href="user?action=add" class="btn btn-success">➕ Add New User</a>
                </div>

                <% if (users != null && !users.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>👤 Username</th>
                            <th>📝 Full Name</th>
                            <th>🔑 Role</th>
                            <th>📧 Email</th>
                            <th>📞 Phone</th>
                            <th>📅 Created Date</th>
                            <th>⚡ Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (User user : users) { %>
                        <tr <%= user.getUserId() == loggedUser.getUserId() ? "class='current-user'" : "" %>>
                            <td>
                                <span class="user-name"><%= user.getUsername() %></span>
                                <% if (user.getUserId() == loggedUser.getUserId()) { %>
                                <span class="current-user-indicator">(You)</span>
                                <% } %>
                            </td>
                            <td><%= user.getFullName() %></td>
                            <td>
                                <span class="role-badge <%= 
                                    Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" 
                                %>">
                                    <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? user.getRole() : user.getRole() %>
                                </span>
                            </td>
                            <td>
                                <% if (user.getEmail() != null && !user.getEmail().isEmpty()) { %>
                                    <span class="contact-info"><%= user.getEmail() %></span>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (user.getPhone() != null && !user.getPhone().isEmpty()) { %>
                                    <span class="contact-info"><%= user.getPhone() %></span>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (user.getCreatedDate() != null) { %>
                                    <%= user.getCreatedDate().toString().substring(0, 10) %>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="user?action=view&id=<%= user.getUserId() %>" 
                                       class="btn btn-primary btn-sm" title="View User Details">
                                       👁️ View
                                    </a>
                                    <a href="user?action=edit&id=<%= user.getUserId() %>" 
                                       class="btn btn-warning btn-sm" title="Edit User">
                                       ✏️ Edit
                                    </a>
                                    <% if (user.getUserId() != loggedUser.getUserId()) { %>
                                    <a href="user?action=delete&id=<%= user.getUserId() %>" 
                                       class="btn btn-danger btn-sm" title="Delete User"
                                       onclick="return confirmDelete('<%= user.getUsername() %>', '<%= user.getUserId() %>')">
                                       🗑️ Delete
                                    </a>
                                    <% } else { %>
                                    <span class="btn btn-secondary btn-sm" style="opacity: 0.5; cursor: not-allowed;" title="Cannot delete your own account">
                                        🔒 Protected
                                    </span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <div class="icon">👥</div>
                    <h3>No Users Found</h3>
                    <p>Start by adding your first user to the system.</p>
                    <a href="user?action=add" class="btn btn-success">➕ Add User</a>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('👥 User Management page loaded');
            console.log('Total users: <%= totalUsers %>');
            console.log('Current user: <%= loggedUser.getUsername() %>');
            
            // Simple keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Alt+N for new user
                if (e.altKey && e.key === 'n') {
                    e.preventDefault();
                    window.location.href = 'user?action=add';
                }
                
                // Ctrl+U for user management
                if (e.ctrlKey && e.key === 'u') {
                    e.preventDefault();
                    window.location.href = 'user?action=list';
                }
            });
            
            console.log('💡 Shortcuts: Alt+N=New User, Ctrl+U=User Management');
        });
    </script>
</body>
</html>