<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.User"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Customer customer = (Customer) request.getAttribute("customer");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Customer - Redupahana</title>
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
            max-width: 1000px;
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

        .customer-profile {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
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
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .info-section {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
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
            color: #7f8c8d;
            flex: 1;
        }

        .info-value {
            color: #2c3e50;
            flex: 2;
            text-align: right;
        }

        .info-value.empty {
            color: #bdc3c7;
            font-style: italic;
        }

        .status-badge {
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

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 1rem;
            font-weight: 600;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
            transform: translateY(-2px);
        }

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #7f8c8d;
            transform: translateY(-2px);
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
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

        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #3498db;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .contact-info {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .contact-icon {
            width: 20px;
            text-align: center;
        }

        .contact-link {
            color: #3498db;
            text-decoration: none;
        }

        .contact-link:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }

            .container {
                margin: 1rem auto;
            }

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

            .quick-stats {
                grid-template-columns: repeat(2, 1fr);
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
    <nav class="navbar">
        <h1>Customer Details</h1>
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
            <h2>Customer Profile</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="customer?action=list">Customers</a> &gt; 
                Customer Details
            </div>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <% if (customer != null) { %>
        
        <div class="quick-stats">
            <div class="stat-card">
                <div class="stat-number">0</div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">Rs. 0.00</div>
                <div class="stat-label">Total Spent</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">0</div>
                <div class="stat-label">Active Bills</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">New</div>
                <div class="stat-label">Customer Type</div>
            </div>
        </div>

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
                                <span class="status-badge status-active">Active</span>
                            </span>
                        </div>
                    </div>

                    <div class="info-section">
                        <h4>📞 Contact Information</h4>
                        <div class="contact-info">
                            <div class="contact-item">
                                <span class="contact-icon">📱</span>
                                <a href="tel:<%= customer.getPhone() %>" class="contact-link">
                                    <%= customer.getPhone() %>
                                </a>
                            </div>
                            <% if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) { %>
                            <div class="contact-item">
                                <span class="contact-icon">📧</span>
                                <a href="mailto:<%= customer.getEmail() %>" class="contact-link">
                                    <%= customer.getEmail() %>
                                </a>
                            </div>
                            <% } else { %>
                            <div class="contact-item">
                                <span class="contact-icon">📧</span>
                                <span class="info-value empty">No email provided</span>
                            </div>
                            <% } %>
                            <% if (customer.getAddress() != null && !customer.getAddress().trim().isEmpty()) { %>
                            <div class="contact-item">
                                <span class="contact-icon">📍</span>
                                <span><%= customer.getAddress() %></span>
                            </div>
                            <% } else { %>
                            <div class="contact-item">
                                <span class="contact-icon">📍</span>
                                <span class="info-value empty">No address provided</span>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="info-section">
                        <h4>📅 Account Details</h4>
                        <div class="info-row">
                            <span class="info-label">Created Date:</span>
                            <span class="info-value"><%= customer.getCreatedDate() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Last Updated:</span>
                            <span class="info-value">
                                <%= customer.getUpdatedDate() != null ? customer.getUpdatedDate() : "Never" %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Account Age:</span>
                            <span class="info-value" id="accountAge">Calculating...</span>
                        </div>
                    </div>
                </div>

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
                       onclick="return confirm('Are you sure you want to delete this customer? This action cannot be undone.')">
                        🗑️ Delete Customer
                    </a>
                </div>
            </div>
        </div>

        <% } else { %>
        <div class="customer-profile">
            <div class="profile-content" style="text-align: center; padding: 3rem;">
                <h3 style="color: #e74c3c; margin-bottom: 1rem;">Customer Not Found</h3>
                <p style="color: #7f8c8d; margin-bottom: 2rem;">
                    The requested customer could not be found or may have been deleted.
                </p>
                <a href="customer?action=list" class="btn btn-primary">Back to Customer List</a>
            </div>
        </div>
        <% } %>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Calculate account age
            <% if (customer != null) { %>
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
            <% } %>

            // Add loading state to action buttons
            const actionBtns = document.querySelectorAll('.btn');
            actionBtns.forEach(btn => {
                btn.addEventListener('click', function(e) {
                    if (!this.href || this.href.includes('delete') || this.href.includes('tel:') || this.href.includes('mailto:')) {
                        return; // Don't add loading to delete, tel, or mailto links
                    }
                    this.style.opacity = '0.7';
                    this.style.pointerEvents = 'none';
                    this.innerHTML = this.innerHTML.replace('✏️', '⏳').replace('💳', '⏳').replace('📋', '⏳');
                });
            });

            // Add confirmation for delete action
            const deleteBtn = document.querySelector('.btn-danger');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', function(e) {
                    const customerName = '<%= customer != null ? customer.getName() : "" %>';
                    if (!confirm(`Are you sure you want to delete customer "${customerName}"? This action cannot be undone and will remove all associated data.`)) {
                        e.preventDefault();
                    }
                });
            }

            // Add animation to stat cards
            const statCards = document.querySelectorAll('.stat-card');
            statCards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    card.style.transition = 'all 0.5s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 100);
            });

            // Add copy functionality for account number and phone
            const accountNumber = document.querySelector('.info-value:first-child');
            if (accountNumber) {
                accountNumber.style.cursor = 'pointer';
                accountNumber.title = 'Click to copy';
                accountNumber.addEventListener('click', function() {
                    copyToClipboard(this.textContent);
                    showCopyFeedback(this);
                });
            }

            function copyToClipboard(text) {
                navigator.clipboard.writeText(text).then(() => {
                    console.log('Copied to clipboard');
                }).catch(() => {
                    // Fallback for older browsers
                    const textArea = document.createElement('textarea');
                    textArea.value = text;
                    document.body.appendChild(textArea);
                    textArea.select();
                    document.execCommand('copy');
                    document.body.removeChild(textArea);
                });
            }

            function showCopyFeedback(element) {
                const originalText = element.textContent;
                element.textContent = 'Copied!';
                element.style.color = '#27ae60';
                
                setTimeout(() => {
                    element.textContent = originalText;
                    element.style.color = '';
                }, 1500);
            }

            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // E key for edit
                if (e.key === 'e' || e.key === 'E') {
                    const editBtn = document.querySelector('.btn-warning');
                    if (editBtn) editBtn.click();
                }
                
                // B key for back
                if (e.key === 'b' || e.key === 'B') {
                    const backBtn = document.querySelector('.btn-secondary');
                    if (backBtn) backBtn.click();
                }
                
                // N key for new bill
                if (e.key === 'n' || e.key === 'N') {
                    const billBtn = document.querySelector('.btn-success');
                    if (billBtn) billBtn.click();
                }
            });
        });
    </script>
</body>
</html>