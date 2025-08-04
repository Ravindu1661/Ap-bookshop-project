<!-- listBills.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Bill> bills = (List<Bill>) request.getAttribute("bills");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String viewType = (String) request.getAttribute("viewType");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill Management - Redupahana</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            overflow-x: hidden;
        }

        /* Sidebar Styles - Same as Admin Dashboard */
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
        .icon-books::before { content: "📚"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
        .icon-logout::before { content: "🚪"; }

        /* Main Content Styles */
        .main-content {
            margin-left: 0;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        .main-content.shifted {
            margin-left: 280px;
        }

        /* Top Navigation */
        .topbar {
            background: #fff;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
            padding: 0.8rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s ease;
        }

        .menu-toggle:hover {
            background: #34495e;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #2c3e50;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: #2c3e50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }

        /* Content Area */
        .content-area {
            padding: 2rem;
        }

        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .page-header h1 {
            color: #2c3e50;
            font-size: 1.8rem;
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

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 1rem;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .search-form {
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        .search-input {
            padding: 0.6rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            width: 300px;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
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

        .stat-card.revenue { border-left: 4px solid #27ae60; }
        .stat-card.today { border-left: 4px solid #3498db; }
        .stat-card.pending { border-left: 4px solid #f39c12; }

        /* Table Styles */
        .table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
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
            border-bottom: 1px solid #eee;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* Button Styles */
        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
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

        .btn-info {
            background-color: #17a2b8;
            color: white;
        }

        .btn-info:hover {
            background-color: #138496;
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

        /* Alert Styles */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border: 1px solid transparent;
        }

        .alert-success {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }

        /* Status Badges */
        .payment-status {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
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

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        .amount {
            font-weight: 600;
            color: #27ae60;
        }

        .bill-number {
            font-family: monospace;
            font-weight: 600;
            color: #2c3e50;
            cursor: pointer;
        }

        .bill-number:hover {
            color: #3498db;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state h3 {
            margin-bottom: 1rem;
            color: #2c3e50;
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
            .content-area {
                padding: 1rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-input {
                width: 100%;
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
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>Redupahana</h2>
            <p>Management System</p>
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
            <button class="menu-toggle" id="menuToggle">☰</button>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span>Welcome, <%= loggedUser.getFullName() %></span>
            </div>
        </header>

        <!-- Content Area -->
        <div class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>Bill Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Bill Management
                    <% if (searchTerm != null) { %>
                    &gt; Search Results for "<%= searchTerm %>"
                    <% } else if ("customer".equals(viewType)) { %>
                    &gt; Customer Bills
                    <% } else if ("cashier".equals(viewType)) { %>
                    &gt; Cashier Bills  
                    <% } else if ("pending".equals(viewType)) { %>
                    &gt; Pending Payments
                    <% } %>
                </div>
                
                <div class="header-actions">
                    <form class="search-form" action="bill" method="get">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="searchTerm" class="search-input" 
                               placeholder="Search by bill number, customer, or cashier..." 
                               value="<%= searchTerm != null ? searchTerm : "" %>">
                        <button type="submit" class="btn btn-primary">Search</button>
                        <% if (searchTerm != null) { %>
                        <a href="bill?action=list" class="btn btn-secondary">Clear</a>
                        <% } %>
                    </form>
                    <div>
                        <a href="bill?action=pendingPayments" class="btn btn-warning btn-sm">Pending Payments</a>
                        <a href="bill?action=cashierBills" class="btn btn-info btn-sm">My Bills</a>
                        <a href="bill?action=create" class="btn btn-success">+ Create New Bill</a>
                    </div>
                </div>
            </div>

            <!-- Statistics -->
            <%
                int totalBills = 0;
                double totalRevenue = 0.0;
                int pendingBills = 0;
                
                if (bills != null) {
                    totalBills = bills.size();
                    for (Bill bill : bills) {
                        if (bill.isPaid()) {
                            totalRevenue += bill.getTotalAmount();
                        }
                        if (bill.isPending()) {
                            pendingBills++;
                        }
                    }
                }
            %>

            <div class="stats-grid">
                <div class="stat-card revenue">
                    <h3>Rs. <%= String.format("%.2f", totalRevenue) %></h3>
                    <p>Total Revenue (Paid Bills)</p>
                </div>
                <div class="stat-card today">
                    <h3><%= totalBills %></h3>
                    <p>Total Bills</p>
                </div>
                <div class="stat-card pending">
                    <h3><%= pendingBills %></h3>
                    <p>Pending Payments</p>
                </div>
            </div>

            <!-- Alerts -->
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

            <!-- Bills Table -->
            <div class="table-container">
                <% if (bills != null && !bills.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Bill Number</th>
                            <th>Customer</th>
                            <th>Cashier</th>
                            <th>Date</th>
                            <th>Sub Total</th>
                            <th>Discount</th>
                            <th>Tax</th>
                            <th>Total Amount</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Bill bill : bills) { %>
                        <tr>
                            <td>
                                <span class="bill-number" onclick="viewBill(<%= bill.getBillId() %>)">
                                    <%= bill.getBillNumber() %>
                                </span>
                            </td>
                            <td>
                                <%= bill.getCustomerName() != null ? bill.getCustomerName() : "Customer #" + bill.getCustomerId() %>
                            </td>
                            <td>
                                <%= bill.getCashierName() != null ? bill.getCashierName() : "Cashier #" + bill.getCashierId() %>
                            </td>
                            <td><%= bill.getBillDate() %></td>
                            <td class="amount">Rs. <%= String.format("%.2f", bill.getSubTotal()) %></td>
                            <td>Rs. <%= String.format("%.2f", bill.getDiscount()) %></td>
                            <td>Rs. <%= String.format("%.2f", bill.getTax()) %></td>
                            <td class="amount"><strong>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></strong></td>
                            <td>
                                <span class="payment-status <%= 
                                    bill.isPaid() ? "status-paid" :
                                    bill.isPending() ? "status-pending" : "status-cancelled"
                                %>">
                                    <%= bill.getPaymentStatus() %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="bill?action=view&id=<%= bill.getBillId() %>" 
                                       class="btn btn-primary btn-sm">View</a>
                                    <a href="bill?action=print&id=<%= bill.getBillId() %>" 
                                       class="btn btn-info btn-sm" target="_blank">Print</a>
                                    <% if (bill.isPending()) { %>
                                    <a href="bill?action=updatePaymentStatus&id=<%= bill.getBillId() %>" 
                                       class="btn btn-warning btn-sm">Update Status</a>
                                    <% } %>
                                    <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
                                    <button onclick="deleteBill(<%= bill.getBillId() %>, '<%= bill.getBillNumber() %>')" 
                                            class="btn btn-danger btn-sm">Delete</button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <h3>No bills found</h3>
                    <% if (searchTerm != null) { %>
                    <p>No bills match your search criteria.</p>
                    <a href="bill?action=list" class="btn btn-primary">View All Bills</a>
                    <% } else { %>
                    <p>Start by creating your first bill.</p>
                    <a href="bill?action=create" class="btn btn-success">Create Bill</a>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Sidebar Toggle Functionality
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');
        const mainContent = document.getElementById('mainContent');

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

        // Bill functions
        function viewBill(billId) {
            window.location.href = 'bill?action=view&id=' + billId;
        }

        function deleteBill(billId, billNumber) {
            if (confirm(`Are you sure you want to delete bill ${billNumber}? This action cannot be undone and will restore stock for all items.`)) {
                window.location.href = 'bill?action=delete&id=' + billId;
            }
        }

        // Add loading states
        document.addEventListener('DOMContentLoaded', function() {
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(btn => {
                btn.addEventListener('click', function() {
                    if (!this.href || this.href.includes('print') || this.onclick) {
                        return;
                    }
                    this.style.opacity = '0.7';
                    this.style.pointerEvents = 'none';
                });
            });

            // Highlight recent bills
            const today = new Date().toISOString().split('T')[0];
            const rows = document.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                const dateCell = row.cells[3];
                if (dateCell && dateCell.textContent.includes(today)) {
                    row.style.backgroundColor = '#f0f8ff';
                    row.style.borderLeft = '4px solid #3498db';
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                window.location.href = 'bill?action=create';
            }
            
            if (e.key === 'Escape' && sidebar.classList.contains('active')) {
                toggleSidebar();
            }
        });
    </script>
</body>
</html>