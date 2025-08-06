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
    String successMessage = (String) request.getAttribute("successMessage");
    
    // 🔥 IMPORTANT: Set page attributes for sidebar
    request.setAttribute("currentPage", "customer");
    request.setAttribute("pageTitle", "Edit Customer");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Customer - Redupahana</title>
    
    <!-- 🎨 Page-specific styles (if needed) -->
    <style>
        /* Add any page-specific styles here */
        .customer-info {
            background: linear-gradient(135deg, #e8f4fd, #f8f9fa);
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border-left: 4px solid #3498db;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .customer-info h4 {
            color: #2c3e50;
            margin-bottom: 1.5rem;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
        }

        .info-item {
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            font-size: 0.85rem;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            color: #2c3e50;
            font-size: 1.1rem;
            font-weight: 500;
        }

        .status-active {
            color: #27ae60;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
        }

        .status-active::before {
            content: "✅";
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <!-- 🔥 INCLUDE COMPLETE SIDEBAR COMPONENT -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content Wrapper -->
    <div class="main-content" id="mainContent">
        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>✏️ Edit Customer</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="customer?action=list">Customer Management</a> &gt; 
                    Edit Customer
                </div>
            </div>

            <% if (customer != null) { %>
            <!-- Customer Info Card -->
            <div class="customer-info">
                <h4>📋 Current Customer Information</h4>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Account Number</div>
                        <div class="info-value">🏦 <%= customer.getAccountNumber() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Customer ID</div>
                        <div class="info-value">#<%= customer.getCustomerId() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Created Date</div>
                        <div class="info-value">📅 <%= customer.getCreatedDate() != null ? customer.getCreatedDate().toString().substring(0, 10) : "N/A" %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Status</div>
                        <div class="info-value">
                            <span class="status-active">Active</span>
                        </div>
                    </div>
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

            <!-- Form Container -->
            <div class="form-container">
                <form action="customer" method="post" id="editCustomerForm" novalidate>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="customerId" value="<%= customer.getCustomerId() %>">
                    
                    <div class="form-group full-width">
                        <label for="accountNumber">Account Number</label>
                        <div class="input-group">
                            <span class="input-icon">🏦</span>
                            <input type="text" class="form-control" id="accountNumber" name="accountNumber" 
                                   value="<%= customer.getAccountNumber() %>" disabled>
                        </div>
                        <div class="form-text">Account number cannot be changed for security reasons</div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="name">Customer Name <span class="required">*</span></label>
                            <div class="input-group">
                                <span class="input-icon">👤</span>
                                <input type="text" class="form-control" id="name" name="name" 
                                       value="<%= customer.getName() != null ? customer.getName() : "" %>" required 
                                       placeholder="Enter full name">
                            </div>
                            <div class="form-text">Customer's full legal name</div>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number <span class="required">*</span></label>
                            <div class="input-group">
                                <span class="input-icon">📞</span>
                                <input type="tel" class="form-control" id="phone" name="phone" 
                                       value="<%= customer.getPhone() != null ? customer.getPhone() : "" %>" required 
                                       placeholder="0771234567" pattern="[0-9]{10}">
                            </div>
                            <div class="form-text">Enter 10-digit mobile number</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <div class="input-group">
                            <span class="input-icon">📧</span>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="<%= customer.getEmail() != null ? customer.getEmail() : "" %>"
                                   placeholder="customer@example.com">
                        </div>
                        <div class="form-text">Optional email for communications</div>
                    </div>

                    <div class="form-group">
                        <label for="address">Address</label>
                        <div class="input-group">
                            <span class="input-icon">🏠</span>
                            <textarea class="form-control" id="address" name="address" rows="4" 
                                      placeholder="Enter complete address (optional)" style="padding-left: 3rem; resize: vertical;"><%= customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                        </div>
                        <div class="form-text">Customer's residential or business address</div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            ✏️ Update Customer
                        </button>
                        <a href="customer?action=view&id=<%= customer.getCustomerId() %>" class="btn btn-warning">
                            👁️ View Details
                        </a>
                        <a href="customer?action=list" class="btn btn-secondary">
                            ❌ Cancel
                        </a>
                        <div style="margin-left: auto; color: #7f8c8d; font-size: 0.9rem;">
                            <span class="required">*</span> Required fields
                        </div>
                    </div>
                </form>
            </div>
            <% } else { %>
            <!-- Customer Not Found -->
            <div class="form-container">
                <div style="text-align: center; padding: 3rem;">
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

    <!-- 🎯 Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🔧 Edit Customer page loaded');
            
            <% if (customer != null) { %>
            // Form validation and page-specific functionality
            const form = document.getElementById('editCustomerForm');
            const nameField = document.getElementById('name');
            const phoneField = document.getElementById('phone');
            const emailField = document.getElementById('email');

            // Phone number formatting
            phoneField.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 10) {
                    this.value = this.value.substr(0, 10);
                }
            });

            // Form submission
            form.addEventListener('submit', function(e) {
                let isValid = true;

                // Validate required fields
                if (!nameField.value.trim()) {
                    nameField.closest('.form-group').classList.add('has-error');
                    isValid = false;
                }

                if (!phoneField.value.trim() || !validatePhone(phoneField.value)) {
                    phoneField.closest('.form-group').classList.add('has-error');
                    isValid = false;
                }

                if (emailField.value.trim() && !validateEmail(emailField.value)) {
                    emailField.closest('.form-group').classList.add('has-error');
                    isValid = false;
                }

                if (!isValid) {
                    e.preventDefault();
                    showNotification('⚠️ Please fill in all required fields correctly.', 'error');
                    return false;
                }

                // Show success notification
                showNotification('⏳ Updating customer...', 'info');
            });

            // Focus on name field
            nameField.focus();
            nameField.select();

            // Page-specific keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Ctrl+S to save
                if (e.ctrlKey && e.key === 's') {
                    e.preventDefault();
                    form.submit();
                }
                
                // Alt+V to view customer
                if (e.altKey && e.key === 'v') {
                    e.preventDefault();
                    window.location.href = 'customer?action=view&id=<%= customer.getCustomerId() %>';
                }
            });

            console.log('💡 Page keyboard shortcuts:');
            console.log('   - Ctrl+S: Save changes');
            console.log('   - Alt+V: View customer details');
            <% } %>
        });
    </script>
</body>
</html>