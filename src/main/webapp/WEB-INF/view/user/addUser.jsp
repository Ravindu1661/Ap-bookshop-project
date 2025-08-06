<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "user");
    request.setAttribute("pageTitle", "Add New User");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add User - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        /* Info Notice */
        .info-notice {
            background-color: #e8f4fd;
            border: 1px solid #bee5eb;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            border-left: 4px solid #007bff;
        }

        .info-notice h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .info-notice p {
            color: #2c3e50;
            font-size: 0.9rem;
            margin: 0;
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

        /* Password Strength */
        .password-strength {
            margin-top: 0.5rem;
        }

        .strength-bar {
            height: 4px;
            background-color: #e0e0e0;
            border-radius: 2px;
            overflow: hidden;
            margin-bottom: 0.5rem;
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
        }

        .strength-weak { background-color: #dc3545; }
        .strength-medium { background-color: #ffc107; }
        .strength-strong { background-color: #28a745; }

        .strength-text {
            font-size: 0.8rem;
            margin-top: 0.25rem;
            color: #6c757d;
            font-weight: 500;
        }

        /* Enhanced form validation styles */
        .form-control.error {
            border-color: #dc3545;
            box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.25);
        }

        .form-control.success {
            border-color: #28a745;
            box-shadow: 0 0 0 2px rgba(40, 167, 69, 0.25);
        }

        /* Loading button state */
        .btn.loading {
            opacity: 0.7;
            pointer-events: none;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .role-selection {
                grid-template-columns: 1fr;
            }
            
            .info-notice {
                padding: 1rem;
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
                <h1>➕ Add New User</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="user?action=list">User Management</a> &gt; 
                    Add User
                </div>
            </div>

            <!-- Info Notice -->
            <div class="info-notice">
                <h4>👤 Create New User Account</h4>
                <p>You are creating a new user account. Please ensure all information is accurate and assign appropriate permissions.</p>
            </div>

            <!-- Alert Messages -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Add User Form -->
            <div class="form-container">
                <form action="user" method="post" id="addUserForm">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="username">👤 Username <span class="required">*</span></label>
                            <input type="text" class="form-control" id="username" name="username" required 
                                   placeholder="Enter unique username" autocomplete="username">
                            <div class="form-text">Username must be unique and cannot be changed later</div>
                        </div>

                        <div class="form-group">
                            <label for="fullName">📝 Full Name <span class="required">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" required 
                                   placeholder="Enter full name" autocomplete="name">
                        </div>

                        <div class="form-group">
                            <label for="email">📧 Email Address</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="Enter email address (optional)" autocomplete="email">
                        </div>

                        <div class="form-group">
                            <label for="phone">📞 Phone Number</label>
                            <input type="tel" class="form-control" id="phone" name="phone" 
                                   placeholder="Enter 10-digit phone number" pattern="[0-9]{10}" autocomplete="tel">
                            <div class="form-text">Enter a valid 10-digit phone number</div>
                        </div>

                        <div class="form-group full-width">
                            <label for="password">🔐 Password <span class="required">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" required 
                                   placeholder="Enter secure password" autocomplete="new-password">
                            <div class="password-strength">
                                <div class="strength-bar">
                                    <div class="strength-fill" id="strengthFill"></div>
                                </div>
                                <div class="strength-text" id="strengthText">Password strength will be shown here</div>
                            </div>
                            <div class="form-text">Password should be at least 8 characters with letters and numbers</div>
                        </div>

                        <div class="form-group full-width">
                            <label>🔑 User Role <span class="required">*</span></label>
                            <div class="role-selection">
                                <div class="role-option" onclick="selectRole('ADMIN')">
                                    <input type="radio" name="role" value="ADMIN" id="roleAdmin" required>
                                    <div class="role-icon">👑</div>
                                    <h4>Administrator</h4>
                                    <p>Full system access including user management, reports, and all features</p>
                                </div>
                                <div class="role-option" onclick="selectRole('CASHIER')">
                                    <input type="radio" name="role" value="CASHIER" id="roleCashier" required>
                                    <div class="role-icon">💼</div>
                                    <h4>Cashier</h4>
                                    <p>Access to billing, customer management, and inventory operations</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-success">✅ Create User</button>
                        <a href="user?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('➕ Add User page loaded');
            
            // Focus on username field
            document.getElementById('username').focus();
            
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
                    document.getElementById('addUserForm').submit();
                }
            });
            
            console.log('💡 Shortcuts: Escape=Cancel, Ctrl+S=Save');
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

        // Password Strength Checker
        const passwordInput = document.getElementById('password');
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');

        passwordInput.addEventListener('input', function() {
            const password = this.value;
            const strength = checkPasswordStrength(password);
            
            strengthFill.style.width = strength.percentage + '%';
            strengthFill.className = 'strength-fill strength-' + strength.level;
            strengthText.textContent = strength.text;
            strengthText.style.color = strength.color;
        });

        function checkPasswordStrength(password) {
            let score = 0;
            let feedback = [];

            if (password.length >= 8) score += 2;
            else feedback.push('at least 8 characters');

            if (password.match(/[a-z]/)) score += 1;
            else feedback.push('lowercase letter');

            if (password.match(/[A-Z]/)) score += 1;
            else feedback.push('uppercase letter');

            if (password.match(/[0-9]/)) score += 1;
            else feedback.push('number');

            if (password.match(/[^a-zA-Z0-9]/)) score += 1;

            if (score < 3) {
                return {
                    level: 'weak',
                    percentage: 25,
                    text: 'Weak - Add ' + feedback.slice(0, 2).join(', '),
                    color: '#dc3545'
                };
            } else if (score < 5) {
                return {
                    level: 'medium',
                    percentage: 60,
                    text: 'Medium - ' + (feedback.length > 0 ? 'Add ' + feedback[0] : 'Good progress'),
                    color: '#ffc107'
                };
            } else {
                return {
                    level: 'strong',
                    percentage: 100,
                    text: 'Strong - Good password!',
                    color: '#28a745'
                };
            }
        }

        // Form Validation
        document.getElementById('addUserForm').addEventListener('submit', function(e) {
            const username = document.getElementById('username').value.trim();
            const fullName = document.getElementById('fullName').value.trim();
            const password = document.getElementById('password').value;
            const role = document.querySelector('input[name="role"]:checked');

            let isValid = true;

            if (!username) {
                isValid = false;
            }

            if (!fullName) {
                isValid = false;
            }

            if (!password || password.length < 6) {
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
            submitBtn.innerHTML = '⏳ Creating User...';
            submitBtn.disabled = true;
        });

        // Phone number formatting
        document.getElementById('phone').addEventListener('input', function() {
            this.value = this.value.replace(/\D/g, '').substring(0, 10);
        });
    </script>
</body>
</html>