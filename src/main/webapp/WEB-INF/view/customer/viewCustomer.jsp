<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Customer customer = (Customer) request.getAttribute("customer");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "customer");
    request.setAttribute("pageTitle", "Customer Details");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Customer - Redupahana</title>
    
    <!-- Simple page-specific styles -->
    <style>
        .customer-profile {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .profile-header {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
            border: 3px solid rgba(255, 255, 255, 0.3);
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .profile-id {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        .profile-content {
            padding: 2rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .info-section {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }

        .info-section:nth-child(2) { border-left-color: #27ae60; }
        .info-section:nth-child(3) { border-left-color: #f39c12; }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.8rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }

        .info-row:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .info-value {
            color: #2c3e50;
            font-weight: 500;
        }

        .info-value.empty {
            color: #bdc3c7;
            font-style: italic;
        }

        .contact-link {
            color: #3498db;
            text-decoration: none;
        }

        .contact-link:hover {
            text-decoration: underline;
        }

        .status-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            background: #d4edda;
            color: #155724;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
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
                gap: 0.3rem;
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
                <h1>👁️ Customer Profile</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="customer?action=list">Customer Management</a> &gt; 
                    Customer Details
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <% if (customer != null) { %>
            <!-- Customer Profile -->
            <div class="customer-profile">
                <div class="profile-header">
                    <div class="profile-avatar">
                        👤
                    </div>
                    <div class="profile-name"><%= customer.getName() %></div>
                    <div class="profile-id">Account: <%= customer.getAccountNumber() %></div>
                </div>

                <div class="profile-content">
                    <div class="info-grid">
                        <!-- Basic Information -->
                        <div class="info-section">
                            <h4>📋 Basic Information</h4>
                            <div class="info-row">
                                <span class="info-label">Customer ID:</span>
                                <span class="info-value">#<%= customer.getCustomerId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Account Number:</span>
                                <span class="info-value"><%= customer.getAccountNumber() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Full Name:</span>
                                <span class="info-value"><%= customer.getName() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="status-badge">✅ Active</span>
                                </span>
                            </div>
                        </div>

                        <!-- Contact Information -->
                        <div class="info-section">
                            <h4>📞 Contact Information</h4>
                            <div class="info-row">
                                <span class="info-label">Phone:</span>
                                <span class="info-value">
                                    <a href="tel:<%= customer.getPhone() %>" class="contact-link">
                                        📱 <%= customer.getPhone() %>
                                    </a>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Email:</span>
                                <span class="info-value">
                                    <% if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) { %>
                                        <a href="mailto:<%= customer.getEmail() %>" class="contact-link">
                                            📧 <%= customer.getEmail() %>
                                        </a>
                                    <% } else { %>
                                        <span class="empty">Not provided</span>
                                    <% } %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Address:</span>
                                <span class="info-value">
                                    <% if (customer.getAddress() != null && !customer.getAddress().trim().isEmpty()) { %>
                                        🏠 <%= customer.getAddress() %>
                                    <% } else { %>
                                        <span class="empty">Not provided</span>
                                    <% } %>
                                </span>
                            </div>
                        </div>

                        <!-- Account Details -->
                        <div class="info-section">
                            <h4>📅 Account Details</h4>
                            <div class="info-row">
                                <span class="info-label">Created Date:</span>
                                <span class="info-value">
                                    <%= customer.getCreatedDate() != null ? customer.getCreatedDate().toString().substring(0, 10) : "N/A" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Last Updated:</span>
                                <span class="info-value">
                                    <%= customer.getUpdatedDate() != null ? customer.getUpdatedDate().toString().substring(0, 10) : "Never" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Account Age:</span>
                                <span class="info-value" id="accountAge">Calculating...</span>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="action-buttons">
                        <a href="customer?action=edit&id=<%= customer.getCustomerId() %>" class="btn btn-warning">
                            ✏️ Edit Customer
                        </a>
                        <a href="bill?action=create&customerId=<%= customer.getCustomerId() %>" class="btn btn-success">
                            💳 Create Bill
                        </a>
                        <a href="customer?action=list" class="btn btn-secondary">
                            📋 Back to List
                        </a>
                        <a href="customer?action=delete&id=<%= customer.getCustomerId() %>" 
                           class="btn btn-danger"
                           onclick="return confirmDelete('<%= customer.getName() %>', '<%= customer.getAccountNumber() %>')">
                            🗑️ Delete Customer
                        </a>
                    </div>
                </div>
            </div>

            <% } else { %>
            <!-- Customer Not Found -->
            <div class="customer-profile">
                <div class="profile-content" style="text-align: center; padding: 3rem;">
                    <div style="font-size: 4rem; margin-bottom: 1rem; opacity: 0.3;">❌</div>
                    <h3 style="color: #e74c3c; margin-bottom: 1rem;">Customer Not Found</h3>
                    <p style="color: #7f8c8d; margin-bottom: 2rem;">
                        The requested customer could not be found or may have been deleted.
                    </p>
                    <a href="customer?action=list" class="btn btn-primary">📋 Back to Customer List</a>
                </div>
            </div>
            <% } %>
        </main>
    </div>

    <!-- Simple JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('👁️ View Customer page loaded');
            
            <% if (customer != null) { %>
            // Calculate account age
            const createdDate = new Date('<%= customer.getCreatedDate() %>');
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
            
            document.getElementById('accountAge').textContent = ageText;

            // Simple keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // E key for edit
                if (e.key === 'e' || e.key === 'E') {
                    if (!e.ctrlKey && !e.altKey) {
                        window.location.href = 'customer?action=edit&id=<%= customer.getCustomerId() %>';
                    }
                }
                
                // B key for back
                if (e.key === 'b' || e.key === 'B') {
                    if (!e.ctrlKey && !e.altKey) {
                        window.location.href = 'customer?action=list';
                    }
                }
                
                // N key for new bill
                if (e.key === 'n' || e.key === 'N') {
                    if (!e.ctrlKey && !e.altKey) {
                        window.location.href = 'bill?action=create&customerId=<%= customer.getCustomerId() %>';
                    }
                }
            });

            console.log('💡 Keyboard shortcuts: E=Edit, B=Back, N=New Bill');
            <% } %>
        });
    </script>
</body>
</html>