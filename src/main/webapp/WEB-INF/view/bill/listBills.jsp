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
            max-width: 1400px;
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
            margin-bottom: 1rem;
        }

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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

        .stat-card.revenue {
            border-left: 4px solid #27ae60;
        }

        .stat-card.today {
            border-left: 4px solid #3498db;
        }

        .stat-card.pending {
            border-left: 4px solid #f39c12;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
            font-size: 0.9rem;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
        }

        .btn-info {
            background-color: #17a2b8;
            color: white;
        }

        .btn-info:hover {
            background-color: #138496;
        }

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.8rem;
        }

        .alert {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .table-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
            border-bottom: 1px solid #ddd;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

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

        .amount {
            font-weight: 600;
            color: #27ae60;
        }

        .bill-number {
            font-family: monospace;
            font-weight: 600;
            color: #2c3e50;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state h3 {
            margin-bottom: 1rem;
        }

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }

            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .stats-cards {
                grid-template-columns: 1fr;
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
    <nav class="navbar">
        <h1>Bill Management</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="customer?action=list">Customers</a>
            <a href="item?action=list">Items</a>
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list">Users</a>
            <% } %>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Bill Management</h2>
            <div class="header-actions">
                <div>
                    <span style="color: #7f8c8d;">Welcome, <%= loggedUser.getFullName() %></span>
                </div>
                <a href="bill?action=create" class="btn btn-success">Create New Bill</a>
            </div>
        </div>

        <%
            // Calculate statistics
            int totalBills = 0;
            double totalRevenue = 0.0;
            int todayBills = 0;
            int pendingBills = 0;
            
            if (bills != null) {
                totalBills = bills.size();
                for (Bill bill : bills) {
                    totalRevenue += bill.getTotalAmount();
                    if (Constants.PAYMENT_PENDING.equals(bill.getPaymentStatus())) {
                        pendingBills++;
                    }
                    // Note: For today's bills, you might want to add date comparison logic
                    // For now, we'll show all bills as today's bills for demo
                    todayBills = totalBills;
                }
            }
        %>

        <div class="stats-cards">
            <div class="stat-card revenue">
                <h3>Rs. <%= String.format("%.2f", totalRevenue) %></h3>
                <p>Total Revenue</p>
            </div>
            <div class="stat-card today">
                <h3><%= totalBills %></h3>
                <p>Total Bills</p>
            </div>
            <div class="stat-card pending">
                <h3><%= pendingBills %></h3>
                <p>Pending Bills</p>
            </div>
        </div>

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
                        <td class="bill-number"><%= bill.getBillNumber() %></td>
                        <td>
                            <% 
                                // Note: You might want to fetch customer name from database
                                // For now showing customer ID
                            %>
                            Customer #<%= bill.getCustomerId() %>
                        </td>
                        <td>
                            <% 
                                // Note: You might want to fetch cashier name from database
                                // For now showing cashier ID
                            %>
                            Cashier #<%= bill.getCashierId() %>
                        </td>
                        <td><%= bill.getBillDate() %></td>
                        <td class="amount">Rs. <%= String.format("%.2f", bill.getSubTotal()) %></td>
                        <td>Rs. <%= String.format("%.2f", bill.getDiscount()) %></td>
                        <td>Rs. <%= String.format("%.2f", bill.getTax()) %></td>
                        <td class="amount"><strong>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></strong></td>
                        <td>
                            <span class="payment-status <%= 
                                Constants.PAYMENT_PAID.equals(bill.getPaymentStatus()) ? "status-paid" :
                                Constants.PAYMENT_PENDING.equals(bill.getPaymentStatus()) ? "status-pending" : "status-cancelled"
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
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state">
                <h3>No bills found</h3>
                <p>Start by creating your first bill.</p>
                <a href="bill?action=create" class="btn btn-success">Create Bill</a>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Add loading state to buttons
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(btn => {
                btn.addEventListener('click', function() {
                    if (!this.href || this.href.includes('print')) {
                        return; // Don't add loading to print buttons
                    }
                    this.style.opacity = '0.7';
                    this.style.pointerEvents = 'none';
                });
            });

            // Auto-refresh every 30 seconds for real-time updates
            // setInterval(function() {
            //     window.location.reload();
            // }, 30000);

            // Highlight recent bills (bills from today)
            const rows = document.querySelectorAll('tbody tr');
            const today = new Date().toISOString().split('T')[0];
            
            rows.forEach(row => {
                const dateCell = row.cells[3]; // Date column
                if (dateCell && dateCell.textContent.includes(today)) {
                    row.style.backgroundColor = '#f0f8ff';
                    row.style.borderLeft = '4px solid #3498db';
                }
            });

            // Add tooltip for bill numbers
            const billNumbers = document.querySelectorAll('.bill-number');
            billNumbers.forEach(element => {
                element.title = 'Click to view bill details';
                element.style.cursor = 'pointer';
                element.addEventListener('click', function() {
                    const row = this.closest('tr');
                    const viewButton = row.querySelector('.btn-primary');
                    if (viewButton) {
                        window.location.href = viewButton.href;
                    }
                });
            });

            // Format currency amounts
            const amountElements = document.querySelectorAll('.amount');
            amountElements.forEach(element => {
                const amount = parseFloat(element.textContent.replace('Rs. ', ''));
                if (amount > 10000) {
                    element.style.color = '#27ae60';
                    element.style.fontWeight = 'bold';
                } else if (amount > 5000) {
                    element.style.color = '#f39c12';
                }
            });
        });

        // Print functionality
        function printBill(billId) {
            const printWindow = window.open(`bill?action=print&id=${billId}`, '_blank');
            printWindow.focus();
        }

        // Quick stats update
        function updateStats() {
            // This could be enhanced to fetch real-time stats via AJAX
            console.log('Stats updated');
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl + N for new bill
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                window.location.href = 'bill?action=create';
            }
            
            // Ctrl + R for refresh
            if (e.ctrlKey && e.key === 'r') {
                e.preventDefault();
                window.location.reload();
            }
        });
    </script>
</body>
</html>