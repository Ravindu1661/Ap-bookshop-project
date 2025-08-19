<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    @SuppressWarnings("unchecked")
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Redupahana</title>
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

        .stat-card.sales { border-left: 4px solid #28a745; }
        .stat-card.today { border-left: 4px solid #3498db; }
        .stat-card.customers { border-left: 4px solid #fd7e14; }
        .stat-card.books { border-left: 4px solid #6f42c1; }

        /* Dashboard Container */
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Welcome Section */
        .welcome-section {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            text-align: center;
        }

        .welcome-section h1 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .welcome-section p {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        /* Management Cards */
        .management-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .management-card {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-decoration: none;
            color: inherit;
            transition: transform 0.3s ease;
            border-left: 4px solid #007bff;
        }

        .management-card:hover {
            transform: translateY(-5px);
            text-decoration: none;
            color: inherit;
        }

        .management-card.users { border-left-color: #007bff; }
        .management-card.books { border-left-color: #6f42c1; }
        .management-card.customers { border-left-color: #fd7e14; }
        .management-card.bills { border-left-color: #28a745; }
        .management-card.reports { border-left-color: #dc3545; }

        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            display: block;
        }

        .card-title {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }

        .card-desc {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 1.5rem;
        }

        .card-link {
            background: #007bff;
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            display: inline-block;
            transition: background 0.3s ease;
        }

        .card-link:hover {
            background: #0056b3;
            color: white;
            text-decoration: none;
        }

        /* Quick Actions */
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }

        .quick-actions-title {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #2c3e50;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .action-btn {
            background: #007bff;
            color: white;
            padding: 1rem 1.5rem;
            text-decoration: none;
            border-radius: 5px;
            text-align: center;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .action-btn:hover {
            background: #0056b3;
            transform: translateY(-2px);
            color: white;
            text-decoration: none;
        }

        .action-btn.success {
            background: #28a745;
        }

        .action-btn.success:hover {
            background: #1e7e34;
        }

        .action-btn.warning {
            background: #ffc107;
            color: #212529;
        }

        .action-btn.warning:hover {
            background: #e0a800;
        }

        /* System Info */
        .system-info {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .system-info-title {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #2c3e50;
        }

        .info-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 0.8rem 0;
            border-bottom: 1px solid #e9ecef;
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #6c757d;
        }

        .info-value {
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

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .management-grid {
                grid-template-columns: 1fr;
            }
            
            .actions-grid {
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
                <h1>Admin Dashboard</h1>
                <div class="breadcrumb">
                    Dashboard &gt; Admin Overview
                </div>
            </div>

            <!-- Alert Messages -->
            <% String successMessage = (String) request.getAttribute("successMessage"); %>
            <% if (successMessage != null) { %>
                <div class="alert alert-success"><%= successMessage %></div>
            <% } %>
            
            <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
            <% if (errorMessage != null) { %>
                <div class="alert alert-error"><%= errorMessage %></div>
            <% } %>

            <div class="dashboard-container">


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
                        <p>Total Books (<%= stats.get("totalStock") %> in stock)</p>
                    </div>
                </div>
                <% } %>

                <!-- Management Cards -->
                <div class="management-grid">
                    <a href="user?action=list" class="management-card users">
                        <span class="card-icon">👥</span>
                        <div class="card-title">User Management</div>
                        <div class="card-desc">Manage system users, roles, and permissions</div>
                        <span class="card-link">Manage Users</span>
                    </a>
                    
                    <a href="book?action=list" class="management-card books">
                        <span class="card-icon">📚</span>
                        <div class="card-title">Book Management</div>
                        <div class="card-desc">Add, edit, and manage your book inventory</div>
                        <span class="card-link">Manage Books</span>
                    </a>
                    
                    
                    <a href="bill?action=list" class="management-card bills">
                        <span class="card-icon">🧾</span>
                        <div class="card-title">Bill Management</div>
                        <div class="card-desc">View, create, and manage all transactions</div>
                        <span class="card-link">View Bills</span>
                    </a>
                    
                    <a href="reports" class="management-card reports">
                        <span class="card-icon">📊</span>
                        <div class="card-title">Reports & Analytics</div>
                        <div class="card-desc">View business insights and analytics</div>
                        <span class="card-link">View Reports</span>
                    </a>
                </div>

                <!-- Quick Actions -->
                <div class="quick-actions">
                    <div class="quick-actions-title">Quick Actions</div>
                    <div class="actions-grid">
                        <a href="customer?action=add" class="action-btn success">Add New Customer</a>
                        <a href="book?action=add" class="action-btn success">Add New Book</a>
                        <a href="bill?action=create" class="action-btn warning">Create New Bill</a>
                        <a href="user?action=add" class="action-btn">Add New User</a>
                    </div>
                </div>

                <!-- System Information -->
                <div class="system-info">
                    <div class="system-info-title">System Information</div>
                    <ul class="info-list">
                        <li class="info-item">
                            <span class="info-label">Current User</span>
                            <span class="info-value"><%= loggedUser.getFullName() %></span>
                        </li>
                        <li class="info-item">
                            <span class="info-label">User Role</span>
                            <span class="info-value"><%= loggedUser.getRole() %></span>
                        </li>
                        <li class="info-item">
                            <span class="info-label">System Status</span>
                            <span class="info-value">Online</span>
                        </li>
                        <li class="info-item">
                            <span class="info-label">Last Login</span>
                            <span class="info-value"><%= new java.util.Date().toString().substring(0, 16) %></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Admin Dashboard loaded successfully');
            console.log('User: <%= loggedUser.getFullName() %>');
            
            // Add keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Alt+1 for User Management
                if (e.altKey && e.key === '1') {
                    e.preventDefault();
                    window.location.href = 'user?action=list';
                }
                
                // Alt+2 for Book Management
                if (e.altKey && e.key === '2') {
                    e.preventDefault();
                    window.location.href = 'book?action=list';
                }
                
                // Alt+3 for Customer Management
                if (e.altKey && e.key === '3') {
                    e.preventDefault();
                    window.location.href = 'customer?action=list';
                }
                
                // Alt+4 for Bill Management
                if (e.altKey && e.key === '4') {
                    e.preventDefault();
                    window.location.href = 'bill?action=list';
                }
                
                // Alt+5 for Reports
                if (e.altKey && e.key === '5') {
                    e.preventDefault();
                    window.location.href = 'reports';
                }
                
                // Ctrl+N for new bill
                if (e.ctrlKey && e.key === 'n') {
                    e.preventDefault();
                    window.location.href = 'bill?action=create';
                }
            });
            
            console.log('Shortcuts: Alt+1=Users, Alt+2=Books, Alt+3=Customers, Alt+4=Bills, Alt+5=Reports, Ctrl+N=New Bill');
        });
    </script>
</body>
</html>