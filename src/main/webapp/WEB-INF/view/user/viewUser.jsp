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
    request.setAttribute("pageTitle", "User Profile");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View User - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        /* User Profile Card */
        .user-profile {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .profile-header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 2.5rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .profile-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
            border: 4px solid rgba(255, 255, 255, 0.3);
            position: relative;
            z-index: 1;
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            position: relative;
            z-index: 1;
        }

        .profile-role {
            font-size: 1.1rem;
            opacity: 0.9;
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            background-color: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            position: relative;
            z-index: 1;
        }

        .profile-content {
            padding: 2rem;
        }

        /* Info Grid */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .info-section {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }

        .info-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e9ecef;
        }

        .info-row:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #6c757d;
            flex: 1;
            font-size: 0.9rem;
        }

        .info-value {
            color: #2c3e50;
            flex: 2;
            text-align: right;
            font-weight: 500;
        }

        .info-value.empty {
            color: #bdc3c7;
            font-style: italic;
        }

        /* Badges */
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

        .status-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-active {
            background-color: #d4edda;
            color: #155724;
        }

        /* Current user indicator */
        .current-user-indicator {
            background: #ffc107;
            color: #212529;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }

        /* Contact Info */
        .contact-info {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem;
            background: white;
            border-radius: 6px;
            border: 1px solid #e9ecef;
        }

        .contact-icon {
            width: 20px;
            text-align: center;
            color: #007bff;
        }

        .contact-link {
            color: #2c3e50;
            text-decoration: none;
            font-weight: 500;
        }

        .contact-link:hover {
            text-decoration: underline;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #e9ecef;
        }

        .btn-disabled {
            background-color: #6c757d;
            color: white;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .btn-disabled:hover {
            transform: none;
            background-color: #6c757d;
        }

        /* Not Found State */
        .not-found {
            background: white;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            text-align: center;
        }

        .not-found h3 {
            color: #dc3545;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }

        .not-found p {
            color: #6c757d;
            margin-bottom: 2rem;
        }

        /* Account Age Animation */
        .account-age {
            animation: fadeInUp 0.6s ease;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .profile-header {
                padding: 1.5rem;
            }
            
            .profile-name {
                font-size: 1.5rem;
            }
            
            .profile-content {
                padding: 1rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .info-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.25rem;
            }
            
            .info-value {
                text-align: left;
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
                <h1>👁️ User Profile</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    User Details
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <% if (user != null) { %>
            <!-- User Profile -->
            <div class="user-profile">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "👑" : "💼" %>
                    </div>
                    <div class="profile-name">
                        <%= user.getFullName() %>
                        <% if (user.getUserId() == loggedUser.getUserId()) { %>
                        <span class="current-user-indicator">You</span>
                        <% } %>
                    </div>
                    <div class="profile-role">
                        <span class="role-badge <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" %>">
                            <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "👑 " + user.getRole() : "💼 " + user.getRole() %>
                        </span>
                    </div>
                </div>

                <div class="profile-content">
                    <div class="info-grid">
                        <div class="info-section">
                            <h4>📋 Basic Information</h4>
                            <div class="info-row">
                                <span class="info-label">User ID:</span>
                                <span class="info-value">#<%= user.getUserId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Username:</span>
                                <span class="info-value"><%= user.getUsername() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Full Name:</span>
                                <span class="info-value"><%= user.getFullName() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="status-badge status-active">✅ Active</span>
                                </span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📞 Contact Information</h4>
                            <div class="contact-info">
                                <div class="contact-item">
                                    <span class="contact-icon">📧</span>
                                    <% if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) { %>
                                        <a href="mailto:<%= user.getEmail() %>" class="contact-link"><%= user.getEmail() %></a>
                                    <% } else { %>
                                        <span class="info-value empty">No email provided</span>
                                    <% } %>
                                </div>
                                <div class="contact-item">
                                    <span class="contact-icon">📱</span>
                                    <% if (user.getPhone() != null && !user.getPhone().trim().isEmpty()) { %>
                                        <a href="tel:<%= user.getPhone() %>" class="contact-link"><%= user.getPhone() %></a>
                                    <% } else { %>
                                        <span class="info-value empty">No phone provided</span>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📅 Account Details</h4>
                            <div class="info-row">
                                <span class="info-label">Role:</span>
                                <span class="info-value">
                                    <span class="role-badge <%= Constants.ROLE_ADMIN.equals(user.getRole()) ? "role-admin" : "role-cashier" %>">
                                        <%= user.getRole() %>
                                    </span>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Created Date:</span>
                                <span class="info-value"><%= user.getCreatedDate().toString().substring(0, 10) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Account Age:</span>
                                <span class="info-value account-age" id="accountAge">Calculating...</span>
                            </div>
                        </div>
                    </div>

                    <div class="action-buttons">
                        <% if (user.getUserId() != loggedUser.getUserId()) { %>
                        <a href="user?action=edit&id=<%= user.getUserId() %>" 
                           class="btn btn-warning" title="Edit User Details">
                           ✏️ Edit User
                        </a>
                        <a href="user?action=delete&id=<%= user.getUserId() %>" 
                           class="btn btn-danger" title="Delete User"
                           onclick="return confirmDelete('<%= user.getFullName() %>')">
                           🗑️ Delete User
                        </a>
                        <% } else { %>
                        <span class="btn btn-disabled" title="Cannot edit/delete your own account">
                            🔒 Current User (Protected)
                        </span>
                        <% } %>
                        <a href="user?action=list" class="btn btn-primary" title="Back to User List">
                            📋 Back to List
                        </a>
                    </div>
                </div>
            </div>

            <% } else { %>
            <!-- User Not Found -->
            <div class="not-found">
                <h3>❌ User Not Found</h3>
                <p>The requested user could not be found or may have been deleted.</p>
                <a href="user?action=list" class="btn btn-primary">📋 Back to User List</a>
            </div>
            <% } %>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('👁️ View User page loaded');
            <% if (user != null) { %>
            console.log('Viewing user: <%= user.getUsername() %>');
            
            // Calculate account age
            const createdDate = new Date('<%= user.getCreatedDate() %>');
            const now = new Date();
            const diffTime = Math.abs(now - createdDate);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            let ageText;
            if (diffDays < 30) {
                ageText = diffDays + ' days';
            } else if (diffDays < 365) {
                const months = Math.floor(diffDays / 30);
                ageText = months + ' month' + (months > 1 ? 's' : '');
            } else {
                const years = Math.floor(diffDays / 365);
                ageText = years + ' year' + (years > 1 ? 's' : '');
            }
            
            const accountAgeElement = document.getElementById('accountAge');
            if (accountAgeElement) {
                setTimeout(() => {
                    accountAgeElement.textContent = ageText;
                }, 500);
            }
            <% } %>
            
            // Simple keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // E key for edit (if edit button exists)
                if (e.key === 'e' || e.key === 'E') {
                    const editBtn = document.querySelector('.btn-warning');
                    if (editBtn) {
                        e.preventDefault();
                        editBtn.click();
                    }
                }
                
                // B key for back
                if (e.key === 'b' || e.key === 'B') {
                    e.preventDefault();
                    window.location.href = 'user?action=list';
                }
                
                // Escape key for back
                if (e.key === 'Escape') {
                    e.preventDefault();
                    window.location.href = 'user?action=list';
                }
            });
            
            console.log('💡 Shortcuts: E=Edit, B=Back, Escape=Back');
        });

        // Confirm delete function
        function confirmDelete(userName) {
            return confirm('Are you sure you want to delete user "' + userName + '"?\n\nThis action cannot be undone and will remove all access for this user.');
        }
    </script>
</body>
</html>