<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    // Check if user is admin - if not, show access denied
    boolean isAdmin = Constants.ROLE_ADMIN.equals(loggedUser.getRole());
    
    Bill bill = (Bill) request.getAttribute("bill");
    Customer customer = (Customer) request.getAttribute("customer");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Payment Status - Redupahana</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            font-size: 14px;
            line-height: 1.5;
            color: #2c3e50;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: -280px;
            width: 280px;
            height: 100vh;
            background: #2c3e50;
            transition: left 0.3s ease;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }

        .sidebar.active {
            left: 0;
        }

        .sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }

        .sidebar-header h2 {
            color: #fff;
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
        }

        .sidebar-header p {
            color: #bdc3c7;
            font-size: 0.9rem;
        }

        .sidebar-menu {
            padding: 1rem 0;
        }

        .menu-item {
            display: block;
            padding: 1rem 1.5rem;
            color: #ecf0f1;
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .menu-item:hover,
        .menu-item.active {
            background-color: rgba(255,255,255,0.1);
            border-left-color: #95a5a6;
            color: #fff;
        }

        .menu-item i {
            margin-right: 0.8rem;
            font-size: 1.1rem;
            width: 20px;
            text-align: center;
        }

        .icon-dashboard::before { content: "📊"; }
        .icon-users::before { content: "👥"; }
        .icon-books::before { content: "📚"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
        .icon-logout::before { content: "🚪"; }

        /* Main Content */
        .main-content {
            margin-left: 0;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        /* Top Navigation */
        .topbar {
            background: #fff;
            padding: 0.8rem 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 999;
        }

        .menu-toggle {
            background: #2c3e50;
            color: white;
            border: none;
            padding: 0.6rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: background-color 0.3s ease;
        }

        .menu-toggle:hover {
            background: #34495e;
        }

        .page-title {
            font-size: 1.2rem;
            color: #2c3e50;
            font-weight: 600;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            color: #2c3e50;
            font-size: 0.9rem;
        }

        .user-avatar {
            width: 32px;
            height: 32px;
            background: #2c3e50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 0.8rem;
        }

        /* Overlay for mobile */
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .overlay.active {
            opacity: 1;
            visibility: visible;
        }

        /* Content Area */
        .content-area {
            padding: 1.5rem;
        }

        .page-header {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .page-header h1 {
            color: #2c3e50;
            font-size: 1.4rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .breadcrumb {
            color: #6c757d;
            font-size: 0.85rem;
        }

        .breadcrumb a {
            color: #495057;
            text-decoration: none;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* Alert Messages */
        .alert {
            padding: 0.8rem 1rem;
            border-radius: 6px;
            margin-bottom: 1.2rem;
            border-left: 4px solid;
            font-size: 0.9rem;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #dc3545;
            color: #721c24;
        }

        .alert-success {
            background-color: #d4edda;
            border-left-color: #28a745;
            color: #155724;
        }

        .alert-warning {
            background-color: #fff3cd;
            border-left-color: #ffc107;
            color: #856404;
        }

        /* Access Denied Styles */
        .access-denied {
            background: white;
            border-radius: 8px;
            padding: 3rem;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            margin-top: 2rem;
        }

        .access-denied-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.7;
        }

        .access-denied h2 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 1rem;
        }

        .access-denied p {
            color: #6c757d;
            font-size: 1.1rem;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .access-denied .btn {
            background: #dc3545;
            color: white;
            padding: 0.7rem 1.4rem;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.2s ease;
            display: inline-block;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }

        .access-denied .btn:hover {
            background: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        /* Form Container */
        .form-container {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .bill-info {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 1.2rem;
            margin-bottom: 1.5rem;
            border: 1px solid #e9ecef;
        }

        .bill-info h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1rem;
            font-weight: 600;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem;
            background: white;
            border-radius: 4px;
            font-size: 0.9rem;
        }

        .info-label {
            font-weight: 500;
            color: #6c757d;
        }

        .info-value {
            color: #2c3e50;
            font-weight: 500;
        }

        .current-status {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-paid {
            background-color: #d4edda;
            color: #155724;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }

        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }

        /* Form Styles */
        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.6rem;
            font-weight: 600;
            color: #2c3e50;
            font-size: 1rem;
        }

        .form-control {
            width: 100%;
            padding: 0.7rem;
            border: 1px solid #ced4da;
            border-radius: 5px;
            font-size: 0.9rem;
            transition: all 0.2s ease;
            background: white;
            color: #495057;
        }

        .form-control:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.1);
        }

        .form-control option {
            background: white;
            color: #495057;
        }

        /* Status Selection */
        .status-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .status-option {
            position: relative;
            cursor: pointer;
        }

        .status-option input[type="radio"] {
            display: none;
        }

        .status-option label {
            display: block;
            padding: 1rem;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            text-align: center;
            transition: all 0.2s ease;
            cursor: pointer;
            background: white;
            color: #495057;
        }

        .status-option input[type="radio"]:checked + label {
            border-color: #007bff;
            background: #f8f9fa;
        }

        .status-option:hover label {
            border-color: #007bff;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }

        /* Buttons */
        .btn {
            padding: 0.7rem 1.4rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.2s ease;
            margin-right: 0.8rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        .btn-primary {
            background: #28a745;
            color: white;
        }

        .btn-primary:hover {
            background: #1e7e34;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #545b62;
        }

        .form-actions {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #e9ecef;
            text-align: center;
        }

        /* Responsive Design */
        @media (min-width: 1024px) {
            .sidebar {
                left: 0;
            }
            
            .main-content {
                margin-left: 280px;
            }
            
            .menu-toggle {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .topbar {
                padding: 1rem;
            }
            
            .content-area {
                padding: 1rem;
            }
            
            .page-header {
                padding: 1.5rem;
            }
            
            .form-container {
                padding: 1.5rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .status-options {
                grid-template-columns: 1fr;
            }
            
            .btn {
                display: block;
                margin-bottom: 0.5rem;
                margin-right: 0;
                text-align: center;
            }
            
            .user-info span {
                display: none;
            }
        }

        /* Loading Animation */
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }

        .loading::after {
            content: " Processing...";
            animation: dots 1.5s steps(5, end) infinite;
        }

        @keyframes dots {
            0%, 20% { content: " Processing"; }
            40% { content: " Processing."; }
            60% { content: " Processing.."; }
            80%, 100% { content: " Processing..."; }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>Redupahana</h2>
            <p>Admin Panel</p>
        </div>
        <nav class="sidebar-menu">
            <a href="dashboard" class="menu-item">
                <i class="icon-dashboard"></i>
                Dashboard
            </a>
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list" class="menu-item">
                <i class="icon-users"></i>
                User Management
            </a>
            <% } %>
            <a href="book?action=list" class="menu-item">
                <i class="icon-books"></i>
                Book Management
            </a>
            <a href="customer?action=list" class="menu-item">
                <i class="icon-customers"></i>
                Customer Management
            </a>
            <a href="bill?action=list" class="menu-item active">
                <i class="icon-bills"></i>
                Bill Management
            </a>
            <a href="auth?action=logout" class="menu-item" style="margin-top: 2rem; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 1rem;">
                <i class="icon-logout"></i>
                Logout
            </a>
        </nav>
    </div>

    <!-- Overlay for mobile -->
    <div class="overlay" id="overlay"></div>

    <!-- Main Content -->
    <div class="main-content" id="mainContent">
        <!-- Top Navigation -->
        <header class="topbar">
            <div style="display: flex; align-items: center; gap: 1rem;">
                <button class="menu-toggle" id="menuToggle">☰</button>
                <h1 class="page-title">💳 Update Payment Status</h1>
            </div>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span><%= loggedUser.getFullName() %> (<%= loggedUser.getRole() %>)</span>
            </div>
        </header>

        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>💳 Update Payment Status</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="bill?action=list">Bills</a> &gt; 
                    Update Payment Status
                </div>
            </div>

            <% if (!isAdmin) { %>
                <!-- Access Denied for Cashiers -->
                <div class="access-denied">
                    <div class="access-denied-icon">🚫</div>
                    <h2>Access Denied</h2>
                    <p>
                        Sorry, you don't have permission to access this page.<br>
                        Only administrators can update payment status.<br>
                        Please contact your system administrator if you need access.
                    </p>
                    <a href="bill?action=list" class="btn">🔙 Back to Bills</a>
                </div>
            <% } else { %>
                <!-- Success Message -->
                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    ✅ <%= successMessage %>
                </div>
                <% } %>

                <!-- Error Message -->
                <% if (errorMessage != null) { %>
                <div class="alert alert-error">
                    ❌ <%= errorMessage %>
                </div>
                <% } %>

                <% if (bill == null) { %>
                    <div class="alert alert-error">
                        ❌ Bill not found. Please try again.
                    </div>
                    <div style="text-align: center; margin-top: 2rem;">
                        <a href="bill?action=list" class="btn btn-secondary">🔙 Back to Bills</a>
                    </div>
                <% } else { %>
                    <!-- Bill Information -->
                    <div class="bill-info">
                        <h3>📄 Bill Information</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Bill Number:</span>
                                <span class="info-value">#<%= bill.getBillNumber() %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Customer:</span>
                                <span class="info-value">
                                    <%= customer != null ? customer.getName() : bill.getCustomerName() != null ? bill.getCustomerName() : "N/A" %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Bill Date:</span>
                                <span class="info-value"><%= bill.getBillDate() != null ? bill.getBillDate() : "N/A" %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Total Amount:</span>
                                <span class="info-value">Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Current Status:</span>
                                <span class="info-value">
                                    <span class="current-status status-<%= bill.getPaymentStatus().toLowerCase() %>">
                                        <%= bill.getPaymentStatus() %>
                                    </span>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Cashier:</span>
                                <span class="info-value">
                                    <%= bill.getCashierName() != null ? bill.getCashierName() : "N/A" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Update Payment Status Form -->
                    <div class="form-container">
                        <form action="bill" method="post" id="updatePaymentForm">
                            <input type="hidden" name="action" value="updatePaymentStatus">
                            <input type="hidden" name="billId" value="<%= bill.getBillId() %>">
                            
                            <div class="form-group">
                                <label>💰 Select New Payment Status</label>
                                <div class="status-options">
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="PAID" id="statusPaid" 
                                               <%= "PAID".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusPaid">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">✅</div>
                                            <div>PAID</div>
                                            <small style="opacity: 0.8;">Payment completed</small>
                                        </label>
                                    </div>
                                    
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="PENDING" id="statusPending" 
                                               <%= "PENDING".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusPending">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">⏰</div>
                                            <div>PENDING</div>
                                            <small style="opacity: 0.8;">Awaiting payment</small>
                                        </label>
                                    </div>
                                    
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="CANCELLED" id="statusCancelled" 
                                               <%= "CANCELLED".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusCancelled">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">❌</div>
                                            <div>CANCELLED</div>
                                            <small style="opacity: 0.8;">Payment cancelled</small>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary" id="submitBtn">
                                    💾 Update Payment Status
                                </button>
                                <a href="bill?action=view&id=<%= bill.getBillId() %>" class="btn btn-secondary">
                                    👁️ View Bill
                                </a>
                                <a href="bill?action=list" class="btn btn-secondary">
                                    🔙 Back to Bills
                                </a>
                            </div>
                        </form>
                    </div>
                <% } %>
            <% } %>
        </main>
    </div>

    <script>
        // Sidebar Toggle
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        function toggleSidebar() {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        if (menuToggle) {
            menuToggle.addEventListener('click', toggleSidebar);
        }
        
        if (overlay) {
            overlay.addEventListener('click', toggleSidebar);
        }

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });

        // Form validation and submission
        const updatePaymentForm = document.getElementById('updatePaymentForm');
        if (updatePaymentForm) {
            updatePaymentForm.addEventListener('submit', function(e) {
                const selectedStatus = document.querySelector('input[name="paymentStatus"]:checked');
                const submitBtn = document.getElementById('submitBtn');
                
                if (!selectedStatus) {
                    e.preventDefault();
                    alert('Please select a payment status before updating.');
                    return false;
                }
                
                // Show confirmation dialog
                const statusValue = selectedStatus.value;
                const statusText = selectedStatus.nextElementSibling.querySelector('div').textContent;
                
                if (!confirm(`Are you sure you want to update the payment status to "${statusText}"?`)) {
                    e.preventDefault();
                    return false;
                }
                
                // Show loading state
                submitBtn.classList.add('loading');
                submitBtn.disabled = true;
                submitBtn.innerHTML = '⏳ Updating Status...';
            });
        }

        // Status option hover effects
        document.querySelectorAll('.status-option').forEach(option => {
            option.addEventListener('click', function() {
                const radio = this.querySelector('input[type="radio"]');
                if (radio) {
                    radio.checked = true;
                    
                    // Update visual selection
                    document.querySelectorAll('.status-option').forEach(opt => {
                        opt.classList.remove('selected');
                    });
                    this.classList.add('selected');
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key closes sidebar on mobile
            if (e.key === 'Escape' && sidebar.classList.contains('active')) {
                toggleSidebar();
            }
            
            // Ctrl+S to submit form (prevent default save)
            if (e.ctrlKey && e.key === 's' && updatePaymentForm) {
                e.preventDefault();
                updatePaymentForm.dispatchEvent(new Event('submit'));
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Update Payment Status page loaded');
            
            // Set initial selected status visual indicator
            const checkedRadio = document.querySelector('input[name="paymentStatus"]:checked');
            if (checkedRadio) {
                checkedRadio.closest('.status-option').classList.add('selected');
            }
            
            // Add visual feedback for status changes
            document.querySelectorAll('input[name="paymentStatus"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    document.querySelectorAll('.status-option').forEach(opt => {
                        opt.classList.remove('selected');
                    });
                    this.closest('.status-option').classList.add('selected');
                });
            });
            
            // Auto-focus on form if admin
            <% if (isAdmin && bill != null) { %>
            const firstStatusOption = document.querySelector('.status-option');
            if (firstStatusOption) {
                firstStatusOption.focus();
            }
            <% } %>
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                if (alert.classList.contains('alert-success')) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-20px)';
                    setTimeout(() => {
                        alert.style.display = 'none';
                    }, 300);
                }
            });
        }, 5000);

        // Add ripple effect to buttons
        document.querySelectorAll('.btn').forEach(button => {
            button.addEventListener('click', function(e) {
                const ripple = document.createElement('span');
                const rect = this.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                const x = e.clientX - rect.left - size / 2;
                const y = e.clientY - rect.top - size / 2;
                
                ripple.style.width = ripple.style.height = size + 'px';
                ripple.style.left = x + 'px';
                ripple.style.top = y + 'px';
                ripple.classList.add('ripple');
                
                this.appendChild(ripple);
                
                setTimeout(() => {
                    ripple.remove();
                }, 600);
            });
        });
    </script>

    <style>
        /* Additional styles for ripple effect */
        .btn {
            position: relative;
            overflow: hidden;
        }

        .ripple {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.3);
            animation: ripple-animation 0.6s linear;
        }

        @keyframes ripple-animation {
            to {
                transform: scale(2);
                opacity: 0;
            }
        }

        /* Selected status option styling */
        .status-option.selected label {
            border-color: white !important;
            background: rgba(255, 255, 255, 0.25) !important;
            transform: scale(1.05);
            box-shadow: 0 4px 20px rgba(255, 255, 255, 0.3);
        }

        /* Enhanced alert animations */
        .alert {
            animation: slideInFromTop 0.5s ease-out;
        }

        @keyframes slideInFromTop {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Enhanced access denied styling */
        .access-denied {
            animation: fadeInScale 0.6s ease-out;
        }

        @keyframes fadeInScale {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        /* Role-based styling */
        .user-info .user-avatar {
            position: relative;
        }

        .user-info .user-avatar::after {
            content: '<%= isAdmin ? "👑" : "👤" %>';
            position: absolute;
            bottom: -2px;
            right: -2px;
            font-size: 0.7rem;
            background: <%= isAdmin ? "#f39c12" : "#3498db" %>;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid rgba(255, 255, 255, 0.5);
        }

        /* Mobile optimizations */
        @media (max-width: 480px) {
            .access-denied {
                padding: 2rem 1rem;
            }
            
            .access-denied h2 {
                font-size: 1.5rem;
            }
            
            .access-denied p {
                font-size: 1rem;
            }
            
            .info-grid {
                gap: 0.5rem;
            }
            
            .info-item {
                flex-direction: column;
                text-align: left;
            }
            
            .info-label {
                margin-bottom: 0.25rem;
                font-size: 0.9rem;
            }
        }
          @media (max-width: 768px) {
            .topbar {
                padding: 0.7rem;
            }
            
            .content-area {
                padding: 1rem;
            }
            
            .page-header {
                padding: 1rem;
            }
            
            .form-container {
                padding: 1rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .status-options {
                grid-template-columns: 1fr;
            }
            
            .btn {
                display: block;
                margin-bottom: 0.5rem;
                margin-right: 0;
                text-align: center;
            }
            
            .user-info span {
                display: none;
            }
        }

        /* Mobile optimizations */
        @media (max-width: 480px) {
            .access-denied {
                padding: 1.5rem 1rem;
            }
            
            .access-denied h2 {
                font-size: 1.4rem;
            }
            
            .access-denied p {
                font-size: 0.95rem;
            }
            
            .info-grid {
                gap: 0.5rem;
            }
            
            .info-item {
                flex-direction: column;
                text-align: left;
                padding: 0.4rem;
            }
            
            .info-label {
                margin-bottom: 0.2rem;
                font-size: 0.8rem;
            }
            
            .info-value {
                font-size: 0.85rem;
            }
        }

        /* Loading Animation */
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }

        .loading::after {
            content: " Processing...";
            animation: dots 1.5s steps(5, end) infinite;
        }

        @keyframes dots {
            0%, 20% { content: " Processing"; }
            40% { content: " Processing."; }
            60% { content: " Processing.."; }
            80%, 100% { content: " Processing..."; }
        }

        /* Additional styles for ripple effect */
        .btn {
            position: relative;
            overflow: hidden;
        }

        .ripple {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.3);
            animation: ripple-animation 0.6s linear;
        }

        @keyframes ripple-animation {
            to {
                transform: scale(2);
                opacity: 0;
            }
        }

        /* Selected status option styling */
        .status-option.selected label {
            border-color: #007bff !important;
            background: #e3f2fd !important;
            color: #1976d2 !important;
            transform: scale(1.02);
            box-shadow: 0 2px 8px rgba(0, 123, 255, 0.2);
        }

        /* Enhanced alert animations */
        .alert {
            animation: slideInFromTop 0.5s ease-out;
        }

        @keyframes slideInFromTop {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Enhanced access denied styling */
        .access-denied {
            animation: fadeInScale 0.6s ease-out;
        }

        @keyframes fadeInScale {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        /* Role-based styling */
        .user-info .user-avatar {
            position: relative;
        }

        .user-info .user-avatar::after {
            content: '<%= isAdmin ? "👑" : "👤" %>';
            position: absolute;
            bottom: -2px;
            right: -2px;
            font-size: 0.6rem;
            background: <%= isAdmin ? "#ffc107" : "#007bff" %>;
            border-radius: 50%;
            width: 14px;
            height: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid white;
        }

        /* Subtle animations */
        .form-container {
            animation: slideUp 0.3s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</body>
</html>