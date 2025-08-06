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
    
    // Set currentPage for sidebar
    request.setAttribute("currentPage", "bill");
    // Set pageTitle for sidebar
    request.setAttribute("pageTitle", "Bill Management");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill Management - Redupahana</title>
    <style>
        /* Page-specific styles */
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
            gap: 0.8rem;
            align-items: center;
        }

        .search-input {
            flex: 1;
            padding: 0.8rem;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            width: 300px;
        }

        .search-input:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .stat-card {
            background: white;
            padding: 1.2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 1.8rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .stat-card p {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .stat-card.revenue { border-left: 4px solid #28a745; }
        .stat-card.today { border-left: 4px solid #3498db; }
        .stat-card.pending { border-left: 4px solid #ffc107; }

        /* Bill-specific styles */
        .amount {
            font-weight: 600;
            color: #28a745;
        }

        .bill-number {
            font-family: monospace;
            font-weight: 600;
            color: #2c3e50;
            cursor: pointer;
        }

        .bill-number:hover {
            color: #007bff;
        }

        @media (max-width: 768px) {
            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-input {
                width: 100%;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 0.2rem;
            }
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content" id="mainContent">
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
                                <span class="status-badge <%= 
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
        // Bill-specific functions
        function viewBill(billId) {
            window.location.href = 'bill?action=view&id=' + billId;
        }

        function deleteBill(billId, billNumber) {
            if (confirmDelete(`bill ${billNumber}`, billId)) {
                window.location.href = 'bill?action=delete&id=' + billId;
            }
        }

        // Page-specific JavaScript
        document.addEventListener('DOMContentLoaded', function() {
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
        });
    </script>
</body>
</html>