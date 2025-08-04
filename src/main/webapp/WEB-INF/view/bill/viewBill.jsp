<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%@ page import="java.util.List"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Bill bill = (Bill) request.getAttribute("bill");
    Customer customer = (Customer) request.getAttribute("customer");
    User cashier = (User) request.getAttribute("cashier");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Bill - Redupahana</title>
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
            position: relative;
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

        /* Icon classes using Unicode */
        .icon-dashboard::before { content: "📊"; }
        .icon-users::before { content: "👥"; }
        .icon-items::before { content: "📦"; }
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

        /* Bill Container */
        .bill-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        /* Bill Header */
        .bill-header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 1.8rem;
            text-align: center;
        }

        .company-name {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 0.3rem;
        }

        .bill-title {
            font-size: 1rem;
            opacity: 0.9;
            font-weight: 400;
        }

        /* Bill Content */
        .bill-content {
            padding: 1.5rem;
        }

        /* Bill Info Cards */
        .bill-info-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .info-card {
            background: #f8f9fa;
            padding: 1.2rem;
            border-radius: 6px;
            border-left: 4px solid #007bff;
        }

        .info-card h4 {
            color: #2c3e50;
            margin-bottom: 0.8rem;
            font-size: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.4rem;
            padding: 0.2rem 0;
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

        /* Status Badge */
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
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

        /* Customer Info Card */
        .customer-card {
            background: #e3f2fd;
            border-left-color: #2196f3;
        }

        /* Cashier Info Card */
        .cashier-card {
            background: #f3e5f5;
            border-left-color: #9c27b0;
        }

        /* Items Section */
        .items-section {
            margin: 1.5rem 0;
        }

        .section-title {
            color: #2c3e50;
            font-size: 1.1rem;
            margin-bottom: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            font-size: 0.9rem;
        }

        .items-table th {
            background: #f8f9fa;
            color: #495057;
            padding: 0.8rem;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        .items-table td {
            padding: 0.8rem;
            border-bottom: 1px solid #e9ecef;
            background: white;
        }

        .items-table tbody tr:hover {
            background: #f8f9fa;
        }

        .items-table tbody tr:last-child td {
            border-bottom: none;
        }

        .item-name {
            font-weight: 600;
            color: #2c3e50;
        }

        .item-details {
            font-size: 0.8rem;
            color: #6c757d;
            margin-top: 0.2rem;
        }

        /* Calculation Section */
        .calculation-section {
            background: #f8f9fa;
            padding: 1.2rem;
            border-radius: 6px;
            margin: 1.5rem 0;
            border: 1px solid #e9ecef;
        }

        .calculation-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.6rem;
            font-size: 0.9rem;
            color: #495057;
        }

        .calculation-row.subtotal {
            padding-bottom: 0.6rem;
            border-bottom: 1px solid #dee2e6;
        }

        .calculation-row.discount {
            color: #dc3545;
            font-weight: 500;
        }

        .calculation-row.total {
            font-size: 1.1rem;
            font-weight: 700;
            color: #28a745;
            border-top: 2px solid #28a745;
            padding-top: 0.8rem;
            margin-top: 0.8rem;
        }

        /* Action Buttons */
        .action-buttons {
            padding: 1.5rem;
            background: #f8f9fa;
            display: flex;
            gap: 0.8rem;
            justify-content: center;
            flex-wrap: wrap;
            border-top: 1px solid #e9ecef;
        }

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
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        .btn-primary {
            background: #007bff;
            color: white;
        }

        .btn-primary:hover {
            background: #0056b3;
        }

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-success:hover {
            background: #1e7e34;
        }

        .btn-warning {
            background: #ffc107;
            color: #212529;
        }

        .btn-warning:hover {
            background: #e0a800;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #545b62;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem 1.5rem;
            color: #6c757d;
        }

        .empty-state h3 {
            color: #495057;
            margin-bottom: 0.8rem;
            font-size: 1.2rem;
        }

        .empty-state p {
            font-size: 1rem;
            margin-bottom: 1.5rem;
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
                padding: 0.7rem;
            }
            
            .content-area {
                padding: 1rem;
            }
            
            .page-header {
                padding: 1rem;
            }
            
            .bill-content {
                padding: 1rem;
            }
            
            .bill-info-cards {
                grid-template-columns: 1fr;
                gap: 0.8rem;
            }
            
            .items-table {
                font-size: 0.8rem;
            }
            
            .items-table th,
            .items-table td {
                padding: 0.5rem;
            }
            
            .action-buttons {
                padding: 1rem;
                flex-direction: column;
            }
            
            .btn {
                justify-content: center;
            }
            
            .user-info span {
                display: none;
            }
        }

        @media (max-width: 480px) {
            .bill-header {
                padding: 1.2rem;
            }
            
            .company-name {
                font-size: 1.4rem;
            }
            
            .items-table th,
            .items-table td {
                padding: 0.4rem;
                font-size: 0.75rem;
            }
        }

        /* Print Styles */
        @media print {
            .sidebar,
            .topbar,
            .page-header,
            .action-buttons,
            .overlay {
                display: none !important;
            }
            
            .main-content {
                margin-left: 0 !important;
            }
            
            .content-area {
                padding: 0 !important;
            }
            
            .bill-container {
                box-shadow: none !important;
                border: 1px solid #000;
            }
        }

        /* Loading States */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }

        .loading::after {
            content: " Processing...";
        }

        /* Subtle animations */
        .bill-container {
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
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>Redupahana</h2>
            <p>POS System</p>
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
            <a href="item?action=list" class="menu-item">
                <i class="icon-items"></i>
                Item Management
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
                <h1 class="page-title">Bill Details</h1>
            </div>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span><%= loggedUser.getFullName() %></span>
            </div>
        </header>

        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>📄 Bill Information</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="bill?action=list">Bills</a> &gt; 
                    Bill Details
                </div>
            </div>

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

            <!-- Bill Content -->
            <% if (bill != null) { %>
            <div class="bill-container">
                <!-- Bill Header -->
                <div class="bill-header">
                    <div class="company-name">REDUPAHANA</div>
                    <div class="bill-title">INVOICE / BILL</div>
                </div>

                <!-- Bill Content -->
                <div class="bill-content">
                    <!-- Bill Information Cards -->
                    <div class="bill-info-cards">
                        <!-- Bill Details Card -->
                        <div class="info-card">
                            <h4>🧾 Bill Details</h4>
                            <div class="info-row">
                                <span class="info-label">Bill Number:</span>
                                <span class="info-value">#<%= bill.getBillNumber() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Bill ID:</span>
                                <span class="info-value">#<%= bill.getBillId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Date:</span>
                                <span class="info-value"><%= bill.getBillDate() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="status-badge status-<%= bill.getPaymentStatus().toLowerCase() %>">
                                        <%= "PAID".equals(bill.getPaymentStatus()) ? "✅" : "PENDING".equals(bill.getPaymentStatus()) ? "⏳" : "❌" %> 
                                        <%= bill.getPaymentStatus() %>
                                    </span>
                                </span>
                            </div>
                        </div>
                        
                        <!-- Customer Details Card -->
                        <div class="info-card customer-card">
                            <h4>👤 Customer Information</h4>
                            <% if (customer != null) { %>
                            <div class="info-row">
                                <span class="info-label">Customer ID:</span>
                                <span class="info-value">#<%= customer.getCustomerId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Name:</span>
                                <span class="info-value"><%= customer.getName() %></span>
                            </div>
                            <% if (customer.getPhone() != null && !customer.getPhone().isEmpty()) { %>
                            <div class="info-row">
                                <span class="info-label">Phone:</span>
                                <span class="info-value"><%= customer.getPhone() %></span>
                            </div>
                            <% } %>
                            <% if (customer.getEmail() != null && !customer.getEmail().isEmpty()) { %>
                            <div class="info-row">
                                <span class="info-label">Email:</span>
                                <span class="info-value"><%= customer.getEmail() %></span>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="info-row">
                                <span class="info-label">Customer ID:</span>
                                <span class="info-value">#<%= bill.getCustomerId() %></span>
                            </div>
                            <div style="font-style: italic; color: #6c757d; font-size: 0.85rem;">
                                Customer details not available
                            </div>
                            <% } %>
                        </div>
                        
                        <!-- Cashier Details Card -->
                        <div class="info-card cashier-card">
                            <h4>💼 Cashier Information</h4>
                            <% if (cashier != null) { %>
                            <div class="info-row">
                                <span class="info-label">Cashier ID:</span>
                                <span class="info-value">#<%= cashier.getUserId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Name:</span>
                                <span class="info-value"><%= cashier.getFullName() %></span>
                            </div>
                            <% if (cashier.getRole() != null) { %>
                            <div class="info-row">
                                <span class="info-label">Role:</span>
                                <span class="info-value"><%= cashier.getRole() %></span>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="info-row">
                                <span class="info-label">Cashier ID:</span>
                                <span class="info-value">#<%= bill.getCashierId() %></span>
                            </div>
                            <div style="font-style: italic; color: #6c757d; font-size: 0.85rem;">
                                Cashier details not available
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Items Section -->
                    <% if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) { %>
                    <div class="items-section">
                        <h3 class="section-title">📦 Items Purchased</h3>
                        <table class="items-table">
                            <thead>
                                <tr>
                                    <th>Item Details</th>
                                    <th style="text-align: center;">Quantity</th>
                                    <th style="text-align: right;">Unit Price</th>
                                    <th style="text-align: right;">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                int itemCount = 0;
                                int totalQty = 0;
                                for (BillItem item : bill.getBillItems()) { 
                                    itemCount++;
                                    totalQty += item.getQuantity();
                                %>
                                <tr>
                                    <td>
                                        <div class="item-name">
                                            <% if (item.getItemName() != null && !item.getItemName().isEmpty()) { %>
                                                <%= item.getItemName() %>
                                            <% } else { %>
                                                Item #<%= item.getItemId() %>
                                            <% } %>
                                        </div>
                                        <div class="item-details">
                                            Item ID: #<%= item.getItemId() %>
                                        </div>
                                    </td>
                                    <td style="text-align: center;"><%= item.getQuantity() %></td>
                                    <td style="text-align: right;">Rs. <%= String.format("%.2f", item.getUnitPrice()) %></td>
                                    <td style="text-align: right;"><strong>Rs. <%= String.format("%.2f", item.getTotalPrice()) %></strong></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        
                        <!-- Summary Stats -->
                        <div style="margin-top: 0.8rem; padding-top: 0.8rem; border-top: 1px solid #e9ecef; display: flex; justify-content: space-between; font-size: 0.85rem; color: #6c757d;">
                            <span>Total Items: <%= itemCount %></span>
                            <span>Total Quantity: <%= totalQty %></span>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="items-section">
                        <h3 class="section-title">📦 Items Purchased</h3>
                        <div style="text-align: center; padding: 2rem; color: #6c757d; font-style: italic;">
                            No items found for this bill
                        </div>
                    </div>
                    <% } %>

                    <!-- Calculation Section -->
                    <div class="calculation-section">
                        <h4 style="color: #495057; margin-bottom: 1rem; font-size: 1rem;">💰 Bill Calculations</h4>
                        <%
                        double subTotal = 0;
                        Double discountWrapper = bill.getDiscount();
                        double discount = (discountWrapper != null) ? discountWrapper : 0;
                        double tax = 0;
                        
                        // Calculate subtotal from bill items
                        if (bill.getBillItems() != null) {
                            for (BillItem item : bill.getBillItems()) {
                                subTotal += item.getTotalPrice();
                            }
                        }
                        
                        // Calculate tax (5% on amount after discount)
                        tax = (subTotal - discount) * 0.05;
                        %>
                        
                        <div class="calculation-row subtotal">
                            <span>Sub Total:</span>
                            <span>Rs. <%= String.format("%.2f", subTotal) %></span>
                        </div>
                        
                        <% if (discount > 0) { %>
                        <div class="calculation-row discount">
                            <span>Discount Applied:</span>
                            <span>- Rs. <%= String.format("%.2f", discount) %></span>
                        </div>
                        <% } %>
                        
                        <div class="calculation-row">
                            <span>Tax (5%):</span>
                            <span>Rs. <%= String.format("%.2f", tax) %></span>
                        </div>
                        
                        <div class="calculation-row total">
                            <span>GRAND TOTAL:</span>
                            <span>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <a href="bill?action=print&id=<%= bill.getBillId() %>" class="btn btn-success" target="_blank">
                        🖨️ Print Bill
                    </a>
                    
                    <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole()) || 
                           "PENDING".equals(bill.getPaymentStatus())) { %>
                    <a href="bill?action=updatePaymentStatus&id=<%= bill.getBillId() %>" class="btn btn-warning">
                        💳 Update Payment
                    </a>
                    <% } %>
                    
                    <a href="bill?action=list" class="btn btn-secondary">
                        📋 Back to Bills
                    </a>
                    
                    <a href="bill?action=create" class="btn btn-primary">
                        ➕ Create New Bill
                    </a>
                </div>
            </div>
            <% } else { %>
            <!-- Bill Not Found -->
            <div class="bill-container">
                <div class="empty-state">
                    <h3>🚫 Bill Not Found</h3>
                    <p>The requested bill could not be found or you don't have permission to view it.</p>
                    <a href="bill?action=list" class="btn btn-primary">
                        📋 Back to Bills
                    </a>
                </div>
            </div>
            <% } %>
        </main>
    </div>

    <script>
        // Sidebar Toggle Functionality
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        function toggleSidebar() {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        menuToggle.addEventListener('click', toggleSidebar);
        overlay.addEventListener('click', toggleSidebar);

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });

        // Add loading effect to buttons
        document.addEventListener('DOMContentLoaded', function() {
            const actionButtons = document.querySelectorAll('.btn');
            actionButtons.forEach(btn => {
                btn.addEventListener('click', function(e) {
                    if (!this.classList.contains('loading') && !this.getAttribute('target')) {
                        this.classList.add('loading');
                        const originalText = this.innerHTML;
                        this.innerHTML = originalText.replace(/^[^A-Za-z]*/, '⏳ ');
                        
                        // Don't reset for navigation links
                        if (!this.href || this.href.includes('javascript:')) {
                            setTimeout(() => {
                                this.classList.remove('loading');
                                this.innerHTML = originalText;
                            }, 2000);
                        }
                    }
                });
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key closes sidebar on mobile
            if (e.key === 'Escape' && sidebar.classList.contains('active')) {
                toggleSidebar();
            }
            
            // Ctrl+P for print
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                const printBtn = document.querySelector('.btn-success[href*="print"]');
                if (printBtn) {
                    printBtn.click();
                }
            }
            
            // Ctrl+B to go back to bills list
            if (e.ctrlKey && e.key === 'b') {
                e.preventDefault();
                window.location.href = 'bill?action=list';
            }
        });

        // Auto-hide success/error messages after 5 seconds
        document.addEventListener('DOMContentLoaded', function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-10px)';
                    setTimeout(() => {
                        alert.remove();
                    }, 300);
                }, 5000);
            });
        });

        // Copy bill number to clipboard functionality
        function copyBillNumber() {
            <% if (bill != null) { %>
            const billNumber = '<%= bill.getBillNumber() %>';
            navigator.clipboard.writeText(billNumber).then(function() {
                // Show temporary notification
                const notification = document.createElement('div');
                notification.textContent = 'Bill number copied!';
                notification.style.cssText = `
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    background: #28a745;
                    color: white;
                    padding: 0.8rem 1.2rem;
                    border-radius: 6px;
                    z-index: 9999;
                    font-size: 0.9rem;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
                    animation: slideInRight 0.3s ease;
                `;
                
                document.body.appendChild(notification);
                
                setTimeout(() => {
                    notification.style.animation = 'slideOutRight 0.3s ease';
                    setTimeout(() => {
                        if (document.body.contains(notification)) {
                            document.body.removeChild(notification);
                        }
                    }, 300);
                }, 2000);
            });
            <% } %>
        }

        // Add click handler to bill number
        document.addEventListener('DOMContentLoaded', function() {
            const billNumberElements = document.querySelectorAll('.info-value');
            billNumberElements.forEach(element => {
                if (element.textContent.includes('#<%= bill != null ? bill.getBillNumber() : "" %>')) {
                    element.style.cursor = 'pointer';
                    element.title = 'Click to copy bill number';
                    element.addEventListener('click', copyBillNumber);
                }
            });
        });

        // Add slide animations for notifications
        const slideStyle = document.createElement('style');
        slideStyle.textContent = `
            @keyframes slideInRight {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            
            @keyframes slideOutRight {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
        document.head.appendChild(slideStyle);

        // Print functionality with loading state
        document.addEventListener('DOMContentLoaded', function() {
            const printBtn = document.querySelector('.btn-success[href*="print"]');
            if (printBtn) {
                printBtn.addEventListener('click', function(e) {
                    // Add loading effect
                    this.classList.add('loading');
                    const originalText = this.innerHTML;
                    this.innerHTML = '🖨️ Opening Print...';
                    
                    // Reset button after 3 seconds
                    setTimeout(() => {
                        this.classList.remove('loading');
                        this.innerHTML = originalText;
                    }, 3000);
                });
            }
        });

        // Enhanced hover effects for cards
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.info-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 12px rgba(0,0,0,0.1)';
                    this.style.transition = 'all 0.3s ease';
                });
                
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = '';
                });
            });
        });

        // Status badge pulse animation for pending payments
        document.addEventListener('DOMContentLoaded', function() {
            const pendingBadge = document.querySelector('.status-pending');
            if (pendingBadge) {
                pendingBadge.style.animation = 'pulse 2s infinite';
                
                const pulseStyle = document.createElement('style');
                pulseStyle.textContent = `
                    @keyframes pulse {
                        0%, 100% { opacity: 1; }
                        50% { opacity: 0.7; }
                    }
                `;
                document.head.appendChild(pulseStyle);
            }
        });

        console.log('View Bill page loaded successfully');
    </script>
</body>
</html>