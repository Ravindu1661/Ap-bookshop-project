<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.NumberFormat"%>
<%
    @SuppressWarnings("unchecked")
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports Dashboard - Redupahana</title>
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
        .stat-card.books { border-left: 4px solid #6f42c1; }
        .stat-card.customers { border-left: 4px solid #fd7e14; }
        .stat-card.sales { border-left: 4px solid #28a745; }
        
        .reports-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .reports-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .reports-header h1 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .reports-menu {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .report-card {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-decoration: none;
            color: inherit;
            transition: transform 0.3s ease;
            border-left: 4px solid #007bff;
        }
        
        .report-card:hover {
            transform: translateY(-5px);
            text-decoration: none;
            color: inherit;
        }
        
        .report-card.sales { border-left-color: #28a745; }
        .report-card.inventory { border-left-color: #ffc107; }
        
        .report-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            display: block;
        }
        
        .report-title {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        .report-desc {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .summary-section {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .summary-title {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #2c3e50;
        }
        
        .summary-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 0.8rem 0;
            border-bottom: 1px solid #e9ecef;
        }
        
        .summary-item:last-child {
            border-bottom: none;
        }
        
        .summary-label {
            color: #6c757d;
        }
        
        .summary-value {
            font-weight: bold;
            color: #2c3e50;
        }

        /* Alert Messages */
        .alert {
            padding: 0.8rem 1rem;
            border-radius: 6px;
            margin-bottom: 1.2rem;
            border-left: 4px solid;
            font-size: 0.9rem;
            animation: slideIn 0.3s ease;
        }

        .alert-success {
            background-color: #d4edda;
            border-left-color: #28a745;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #dc3545;
            color: #721c24;
        }

        .alert-info {
            background-color: #cce7ff;
            border-left-color: #3498db;
            color: #0c5aa6;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem 1.5rem;
            color: #6c757d;
        }

        .empty-state h3 {
            margin-bottom: 0.8rem;
            color: #495057;
            font-size: 1.2rem;
        }

        .empty-state p {
            margin-bottom: 1.5rem;
            font-size: 1rem;
        }

        .empty-state .icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        /* Button Styles */
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
            text-align: center;
            white-space: nowrap;
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

        .btn-danger {
            background: #dc3545;
            color: white;
        }

        .btn-danger:hover {
            background: #c82333;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .reports-menu {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <div class="main-content">
        <div class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>Reports & Analytics</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Reports & Analytics
                </div>
            </div>

            <!-- Alert Messages -->
            <% String successMessage = (String) request.getAttribute("successMessage"); %>
            <% if (successMessage != null) { %>
                <div class="alert alert-success">✅ <%= successMessage %></div>
            <% } %>
            
            <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
            <% if (errorMessage != null) { %>
                <div class="alert alert-error">❌ <%= errorMessage %></div>
            <% } %>

            <div class="reports-container">
                <!-- Header -->
                <div class="reports-header">
                    <h1>Reports Dashboard</h1>
                    <p>Business insights and analytics</p>
                </div>

                <!-- Statistics -->
                <% if (stats != null) { %>
                <div class="stats-grid">
                    <div class="stat-card sales">
                        <h3>Rs. <%= String.format("%.2f", (Double) stats.get("todaySales")) %></h3>
                        <p>Today's Sales (<%= stats.get("todayBills") %> bills)</p>
                    </div>
                    
                    <div class="stat-card today">
                        <h3>Rs. <%= String.format("%.2f", (Double) stats.get("monthlySales")) %></h3>
                        <p>Monthly Sales (<%= stats.get("monthlyBills") %> bills)</p>
                    </div>
                    
                    <div class="stat-card customers">
                        <h3><%= stats.get("totalCustomers") %></h3>
                        <p>Total Customers</p>
                    </div>
                    
                    <div class="stat-card books">
                        <h3><%= stats.get("totalBooks") %></h3>
                        <p>📚 Total Books (<%= stats.get("totalStock") %> in stock)</p>
                    </div>
                </div>
                <% } %>

                <!-- Reports Menu -->
                <div class="reports-menu">
                    <a href="reports?action=sales" class="report-card sales">
                        <span class="report-icon"></span>
                        <div class="report-title">Sales Report</div>
                        <div class="report-desc">View sales data and billing information</div>
                    </a>
                    
                    <a href="reports?action=inventory" class="report-card inventory">
                        <span class="report-icon"></span>
                        <div class="report-title">Inventory Report</div>
                        <div class="report-desc">Monitor stock levels and book inventory</div>
                    </a>
                </div>

                <!-- Summary Section -->
                <div class="summary-section">
                    <div class="summary-title">Quick Summary</div>
                    <ul class="summary-list">
                        <li class="summary-item">
                            <span class="summary-label">System Status</span>
                            <span class="summary-value">Active</span>
                        </li>
                        <li class="summary-item">
                            <span class="summary-label">Last Updated</span>
                            <span class="summary-value">Real-time</span>
                        </li>
                        <li class="summary-item">
                            <span class="summary-label">Data Range</span>
                            <span class="summary-value">All Time</span>
                        </li>
                        <li class="summary-item">
                            <span class="summary-label">Report Types</span>
                            <span class="summary-value">2 Available</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</body>
</html>