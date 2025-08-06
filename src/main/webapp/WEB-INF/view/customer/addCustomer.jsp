<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "customer");
    request.setAttribute("pageTitle", "Add Customer");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Customer - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        .form-header {
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #f1f2f6;
        }

        .form-header h2 {
            color: #2c3e50;
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-header p {
            color: #7f8c8d;
            font-size: 0.95rem;
        }

        /* Form validation states */
        .form-group.has-error .form-control {
            border-color: #e74c3c;
            box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1);
        }

        .form-group.has-error .form-text {
            color: #e74c3c;
        }

        .form-group.has-error .form-text::before {
            content: "⚠️";
        }

        .form-group.has-success .form-control {
            border-color: #27ae60;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.1);
        }

        .form-group.has-success .form-text {
            color: #27ae60;
        }

        .form-group.has-success .form-text::before {
            content: "✅";
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
                <h1>➕ Add New Customer</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="customer?action=list">Customer Management</a> &gt; 
                    Add Customer
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
                <div class="form-header">
                    <h2>📝 Customer Information</h2>
                    <p>Fill in the details below to add a new customer to the system</p>
                </div>

                <form action="customer" method="post" id="addCustomerForm" novalidate>
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="name">Customer Name <span class="required">*</span></label>
                            <div class="input-group">
                                <span class="input-icon">👤</span>
                                <input type="text" class="form-control" id="name" name="name" required 
                                       placeholder="Enter full name">
                            </div>
                            <div class="form-text">Customer's full legal name</div>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number <span class="required">*</span></label>
                            <div class="input-group">
                                <span class="input-icon">📞</span>
                                <input type="tel" class="form-control" id="phone" name="phone" required 
                                       placeholder="0771234567" pattern="[0-9]{10}">
                            </div>
                            <div class="form-text">Enter 10-digit mobile number</div>
                        </div>

                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <div class="input-group">
                                <span class="input-icon">📧</span>
                                <input type="email" class="form-control" id="email" name="email" 
                                       placeholder="customer@example.com">
                            </div>
                            <div class="form-text">Optional email for communications</div>
                        </div>

                        <div class="form-group full-width">
                            <label for="address">Address</label>
                            <div class="input-group">
                                <span class="input-icon">🏠</span>
                                <textarea class="form-control" id="address" name="address" rows="4" 
                                          placeholder="Enter complete address (optional)" style="padding-left: 3rem; resize: vertical;"></textarea>
                            </div>
                            <div class="form-text">Customer's residential or business address</div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            ➕ Add Customer
                        </button>
                        <a href="customer?action=list" class="btn btn-secondary">
                            ❌ Cancel
                        </a>
                        <div style="margin-left: auto; color: #7f8c8d; font-size: 0.9rem;">
                            <span class="required">*</span> Required fields
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('➕ Add Customer page loaded');
            
            // Form elements
            const form = document.getElementById('addCustomerForm');
            const submitBtn = document.getElementById('submitBtn');
            const nameField = document.getElementById('name');
            const phoneField = document.getElementById('phone');
            const emailField = document.getElementById('email');

            function validateField(field, validationFn) {
                const formGroup = field.closest('.form-group');
                const isValid = validationFn(field.value);
                
                formGroup.classList.remove('has-error', 'has-success');
                
                if (field.value.trim() === '') {
                    return true; // Empty fields handled by required attribute
                }
                
                if (isValid) {
                    formGroup.classList.add('has-success');
                    return true;
                } else {
                    formGroup.classList.add('has-error');
                    return false;
                }
            }

            // Add event listeners for real-time validation
            nameField.addEventListener('blur', function() {
                validateField(this, validateName);
            });

            phoneField.addEventListener('blur', function() {
                validateField(this, validatePhone);
            });

            phoneField.addEventListener('input', function() {
                // Remove non-digits and limit to 10 digits
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 10) {
                    this.value = this.value.substr(0, 10);
                }
            });

            emailField.addEventListener('blur', function() {
                validateField(this, validateEmail);
            });

            // Form submission
            form.addEventListener('submit', function(e) {
                let isValid = true;

                // Check required fields
                if (!nameField.value.trim()) {
                    nameField.closest('.form-group').classList.add('has-error');
                    isValid = false;
                }

                if (!phoneField.value.trim()) {
                    phoneField.closest('.form-group').classList.add('has-error');
                    isValid = false;
                }

                // Validate formats
                if (nameField.value.trim() && !validateName(nameField.value)) {
                    isValid = false;
                }

                if (phoneField.value.trim() && !validatePhone(phoneField.value)) {
                    isValid = false;
                }

                if (emailField.value.trim() && !validateEmail(emailField.value)) {
                    isValid = false;
                }

                if (!isValid) {
                    e.preventDefault();
                    showNotification('⚠️ Please fill in all required fields correctly.', 'error');
                    return false;
                }

                // Show loading state
                submitBtn.disabled = true;
                submitBtn.innerHTML = '⏳ Adding Customer...';
                
                // Show success notification
                showNotification('✅ Adding customer to system...', 'success');
            });

            // Focus on first input
            nameField.focus();

            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Ctrl+S to save
                if (e.ctrlKey && e.key === 's') {
                    e.preventDefault();
                    form.submit();
                }
                
                // Escape to cancel
                if (e.key === 'Escape') {
                    if (confirm('Are you sure you want to cancel? Any unsaved changes will be lost.')) {
                        window.location.href = 'customer?action=list';
                    }
                }
            });

            console.log('💡 Shortcuts: Ctrl+S=Save, Escape=Cancel');
        });
    </script>
</body>
</html>