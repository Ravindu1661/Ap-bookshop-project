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
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "user");
    request.setAttribute("pageTitle", "Edit User");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        /* User Info Card */
        .user-info-card {
            background: #e8f4fd;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border-left: 4px solid #007bff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .user-info-card h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
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
            color: #6c757d;
            font-size: 0.85rem;
            margin-bottom: 0.25rem;
        }

        .info-value {
            color: #2c3e50;
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Role Selection */
        .role-selection {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .role-option {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 1.5rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            background: white;
        }

        .role-option:hover {
            border-color: #007bff;
            background-color: #f8f9fa;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.15);
        }

        .role-option.selected {
            border-color: #007bff;
            background-color: #e8f4fd;
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.2);
        }

        .role-option input[type="radio"] {
            display: none;
        }

        .role-option h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .role-option p {
            color: #6c757d;
            font-size: 0.9rem;
            margin: 0;
        }

        .role-icon {
            font-size: 2rem;
            margin-bottom: 1rem;
            display: block;
        }

        /* Disabled field styling */
        .form-control:disabled {
            background-color: #f8f9fa;
            cursor: not-allowed;
            opacity: 0.8;
        }

        /* Loading button state */
        .btn.loading {
            opacity: 0.7;
            pointer-events: none;
        }

        /* Current user badge */
        .current-user-badge {
            background: #ffc107;
            color: #212529;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .role-selection {
                grid-template-columns: 1fr;
            }
            
            .user-info-card {
                padding: 1rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
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
                <h1>✏️ Edit User</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    Edit User
                </div>
            </div>

            <% if (user != null) { %>
            <!-- Current User Info -->
            <div class="user-info-card">
                <h4>📝 Current User Information 
                    <% if (user.getUserId() == loggedUser.getUserId()) { %>
                    <span class="current-user-badge">Current User</span>
                    <% } %>
                </h4>
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
                        <span class="info-value">
                            <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "👑 " + user.getRole() : "💼 " + user.getRole() %>
                        </span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Created Date</span>
                        <span class="info-value"><%= user.getCreatedDate().toString().substring(0, 10) %></span>
                    </div>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Edit User Form -->
            <div class="form-container">
                <form action="user" method="post" id="editUserForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="username">👤 Username</label>
                            <input type="text" class="form-control" id="username" name="username" 
                                   value="<%= user.getUsername() %>" disabled>
                            <div class="form-text">Username cannot be changed</div>
                        </div>

                        <div class="form-group">
                            <label for="fullName">📝 Full Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   value="<%= user.getFullName() %>" required 
                                   placeholder="Enter full name">
                        </div>

                        <div class="form-group">
                            <label for="email">📧 Email Address</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                                   placeholder="Enter email address (optional)">
                        </div>

                        <div class="form-group">
                            <label for="phone">📞 Phone Number</label>
                            <input type="tel" class="form-control" id="phone" name="phone" 
                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                                   placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                            <div class="form-text">Enter a valid 10-digit phone number</div>
                        </div>

                        <div class="form-group full-width">
                            <label>🔑 User Role <span class="required">*</span></label>
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
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-success">💾 Update User</button>
                        <a href="user?action=view&id=<%= user.getUserId() %>" class="btn btn-primary">👁️ View Details</a>
                        <a href="user?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>

            <% } else { %>
            <!-- User Not Found -->
            <div class="empty-state">
                <div class="icon">❌</div>
                <h3>User Not Found</h3>
                <p>The requested user could not be found or may have been deleted.</p>
                <a href="user?action=list" class="btn btn-primary">📋 Back to User List</a>
            </div>
            <% } %>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('✏️ Edit User page loaded');
            <% if (user != null) { %>
            console.log('Editing user: <%= user.getUsername() %>');
            <% } %>
            
            // Focus on full name field
            const fullNameField = document.getElementById('fullName');
            if (fullNameField) {
                fullNameField.focus();
                fullNameField.select();
            }
            
            // Simple keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Escape key to cancel
                if (e.key === 'Escape') {
                    e.preventDefault();
                    window.location.href = 'user?action=list';
                }
                
                // Ctrl+S to save
                if (e.ctrlKey && e.key === 's') {
                    e.preventDefault();
                    document.getElementById('editUserForm').submit();
                }
                
                // Alt+V to view details
                if (e.altKey && e.key === 'v') {
                    e.preventDefault();
                    <% if (user != null) { %>
                    window.location.href = 'user?action=view&id=<%= user.getUserId() %>';
                    <% } %>
                }
            });
            
            console.log('💡 Shortcuts: Escape=Cancel, Ctrl+S=Save, Alt+V=View Details');
        });

        // Role Selection
        function selectRole(role) {
            // Remove selected class from all options
            document.querySelectorAll('.role-option').forEach(function(option) {
                option.classList.remove('selected');
            });
            
            // Add selected class to clicked option
            event.currentTarget.classList.add('selected');
            
            // Check the radio button
            if (role === 'ADMIN') {
                document.getElementById('roleAdmin').checked = true;
            } else {
                document.getElementById('roleCashier').checked = true;
            }
        }

        // Form Validation
        document.getElementById('editUserForm').addEventListener('submit', function(e) {
            const fullName = document.getElementById('fullName').value.trim();
            const role = document.querySelector('input[name="role"]:checked');

            let isValid = true;

            if (!fullName) {
                isValid = false;
            }

            if (!role) {
                isValid = false;
            }

            if (!isValid) {
                e.preventDefault();
                return false;
            }

            // Add loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.classList.add('loading');
            submitBtn.innerHTML = '⏳ Updating User...';
            submitBtn.disabled = true;
        });

        // Phone number formatting
        const phoneInput = document.getElementById('phone');
        if (phoneInput) {
            phoneInput.addEventListener('input', function() {
                this.value = this.value.replace(/\D/g, '').substring(0, 10);
            });
        }
    </script>
</body>
</html>