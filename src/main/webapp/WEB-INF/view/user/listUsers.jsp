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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Redupahana</title>
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

        .admin-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            border-left: 4px solid #f39c12;
        }

        .admin-warning h4 {
            color: #856404;
            margin-bottom: 0.5rem;
        }

        .admin-warning p {
            color: #856404;
            font-size: 0.9rem;
        }

        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .stat-card.total {
            border-left: 4px solid #3498db;
        }

        .stat-card.admins {
            border-left: 4px solid #e74c3c;
        }

        .stat-card.cashiers {
            border-left: 4px solid #27ae60;
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

        .role-badge {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
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

        .user-status {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-active {
            background-color: #d4edda;
            color: #155724;
        }

        .status-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }

        .current-user {
            background-color: #e3f2fd !important;
            border-left: 4px solid #3498db;
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

            .stats-cards {
                grid-template-columns: 1fr;
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
        <h1>User Management</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="customer?action=list">Customers</a>
            <a href="item?action=list">Items</a>
            <a href="bill?action=list">Bills</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>User Management</h2>
            <div class="header-actions">
                <div>
                    <span style="color: #7f8c8d;">Logged in as: <strong><%= loggedUser.getFullName() %></strong> (Admin)</span>
                </div>
                <a href="user?action=add" class="btn btn-success">Add New User</a>
            </div>
        </div>

        <div class="admin-warning">
            <h4>⚠️ Administrator Access</h4>
            <p>You are accessing the user management system. Please be careful when modifying user accounts and permissions.</p>
        </div>

        <%
            // Calculate statistics
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

        <div class="stats-cards">
            <div class="stat-card total">
                <h3><%= totalUsers %></h3>
                <p>Total Users</p>
            </div>
            <div class="stat-card admins">
                <h3><%= adminCount %></h3>
                <p>Administrators</p>
            </div>
            <div class="stat-card cashiers">
                <h3><%= cashierCount %></h3>
                <p>Cashiers</p>
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
            <% if (users != null && !users.isEmpty()) { %>
            <table class="table">
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Role</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Status</th>
                        <th>Created Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (User user : users) { %>
                    <tr <%= user.getUserId() == loggedUser.getUserId() ? "class='current-user'" : "" %>>
                        <td>
                            <strong><%= user.getUsername() %></strong>
                            <% if (user.getUserId() == loggedUser.getUserId()) { %>
                            <span style="color: #3498db; font-size: 0.8rem;">(You)</span>
                            <% } %>
                        </td>
                        <td><%= user.getFullName() %></td>
                        <td>
                            <span class="role-badge <%= 
                                Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" 
                            %>">
                                <%= user.getRole() %>
                            </span>
                        </td>
                        <td><%= user.getEmail() != null ? user.getEmail() : "-" %></td>
                        <td><%= user.getPhone() != null ? user.getPhone() : "-" %></td>
                        <td>
                            <span class="user-status <%= user.isActive() ? "status-active" : "status-inactive" %>">
                                <%= user.isActive() ? "Active" : "Inactive" %>
                            </span>
                        </td>
                        <td><%= user.getCreatedDate() %></td>
                        <td>
                            <div class="action-buttons">
                                <a href="user?action=view&id=<%= user.getUserId() %>" 
                                   class="btn btn-primary btn-sm">View</a>
                                <a href="user?action=edit&id=<%= user.getUserId() %>" 
                                   class="btn btn-warning btn-sm">Edit</a>
                                <% if (user.getUserId() != loggedUser.getUserId()) { %>
                                <a href="user?action=delete&id=<%= user.getUserId() %>" 
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Are you sure you want to delete this user? This action cannot be undone.')">Delete</a>
                                <% } else { %>
                                <span class="btn btn-sm" style="background-color: #ecf0f1; color: #7f8c8d; cursor: not-allowed;">Current User</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state">
                <h3>No users found</h3>
                <p>Start by adding your first user to the system.</p>
                <a href="user?action=add" class="btn btn-success">Add User</a>
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
                    const row = this.closest('tr');
                    const username = row.querySelector('td:first-child strong').textContent;
                    
                    if (!confirm(`Are you sure you want to delete user "${username}"? This action cannot be undone and will remove all access for this user.`)) {
                        e.preventDefault();
                    }
                });
            });

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

            // Highlight current user row
            const currentUserRow = document.querySelector('.current-user');
            if (currentUserRow) {
                currentUserRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }

            // Role badge click for filtering (future enhancement)
            const roleBadges = document.querySelectorAll('.role-badge');
            roleBadges.forEach(badge => {
                badge.style.cursor = 'pointer';
                badge.title = 'Click to filter by role';
                badge.addEventListener('click', function() {
                    const role = this.textContent.trim();
                    filterByRole(role);
                });
            });

            function filterByRole(role) {
                const rows = document.querySelectorAll('tbody tr');
                rows.forEach(row => {
                    const userRole = row.querySelector('.role-badge').textContent.trim();
                    if (userRole === role) {
                        row.style.display = '';
                        row.style.backgroundColor = '#fff3cd';
                    } else {
                        row.style.display = 'none';
                    }
                });

                // Add clear filter button
                if (!document.getElementById('clearFilter')) {
                    const clearBtn = document.createElement('button');
                    clearBtn.id = 'clearFilter';
                    clearBtn.className = 'btn btn-secondary btn-sm';
                    clearBtn.textContent = `Clear ${role} Filter`;
                    clearBtn.style.margin = '1rem 0';
                    clearBtn.onclick = function() {
                        rows.forEach(row => {
                            row.style.display = '';
                            row.style.backgroundColor = '';
                        });
                        this.remove();
                    };
                    
                    const tableContainer = document.querySelector('.table-container');
                    tableContainer.parentNode.insertBefore(clearBtn, tableContainer);
                }
            }

            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Ctrl + N for new user
                if (e.ctrlKey && e.key === 'n') {
                    e.preventDefault();
                    window.location.href = 'user?action=add';
                }
            });

            // Add tooltips for action buttons
            const actionButtons = document.querySelectorAll('.action-buttons .btn');
            actionButtons.forEach(btn => {
                if (btn.textContent.includes('View')) {
                    btn.title = 'View user details';
                } else if (btn.textContent.includes('Edit')) {
                    btn.title = 'Edit user information';
                } else if (btn.textContent.includes('Delete')) {
                    btn.title = 'Delete user (cannot be undone)';
                }
            });
        });
    </script>
</body>
</html>