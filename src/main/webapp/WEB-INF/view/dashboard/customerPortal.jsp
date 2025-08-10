<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%
    Customer customer = (Customer) request.getAttribute("customer");

    // Success and logout messages
    String showWelcomeNotification = (String) session.getAttribute("showWelcomeNotification");
    String showLogout = (String) session.getAttribute("showLogout");
    String logoutMessage = (String) session.getAttribute("logoutMessage");
    String logoutUserType = (String) session.getAttribute("logoutUserType");
    
    // Clear the session attributes after retrieving them
    if (showWelcomeNotification != null) {
        session.removeAttribute("showWelcomeNotification");
    }
    if (showLogout != null) {
        session.removeAttribute("showLogout");
        session.removeAttribute("logoutMessage");
        session.removeAttribute("logoutUserType");
    }
    
    // Dashboard data
    @SuppressWarnings("unchecked")
    List<Bill> recentBills = (List<Bill>) request.getAttribute("recentBills");
    Integer totalBills = (Integer) request.getAttribute("totalBills");
    Double totalAmount = (Double) request.getAttribute("totalAmount");
    Double totalPaid = (Double) request.getAttribute("totalPaid");
    Integer pendingBills = (Integer) request.getAttribute("pendingBills");
    Double pendingAmount = (Double) request.getAttribute("pendingAmount");
    
    // Profile data with enhanced statistics
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Double totalSpent = (Double) request.getAttribute("totalSpent");
    Double averageOrderValue = (Double) request.getAttribute("averageOrderValue");
    Integer totalBooks = (Integer) request.getAttribute("totalBooks");
    Integer totalUniqueBooks = (Integer) request.getAttribute("totalUniqueBooks");
    Bill lastOrder = (Bill) request.getAttribute("lastOrder");
    String favoriteCategory = (String) request.getAttribute("favoriteCategory");
    String favoriteAuthor = (String) request.getAttribute("favoriteAuthor");
    Double avgBooksPerOrder = (Double) request.getAttribute("avgBooksPerOrder");
    Double ordersPerMonth = (Double) request.getAttribute("ordersPerMonth");
    Bill mostExpensiveOrder = (Bill) request.getAttribute("mostExpensiveOrder");
    Bill mostBooksOrder = (Bill) request.getAttribute("mostBooksOrder");
    
    // Enhanced statistics
    @SuppressWarnings("unchecked")
    Map<String, Integer> categoryStats = (Map<String, Integer>) request.getAttribute("categoryStats");
    @SuppressWarnings("unchecked")
    Map<String, Integer> authorStats = (Map<String, Integer>) request.getAttribute("authorStats");
    @SuppressWarnings("unchecked")
    Map<String, Integer> languageStats = (Map<String, Integer>) request.getAttribute("languageStats");
    
    // All bills data
    @SuppressWarnings("unchecked")
    List<Bill> allBills = (List<Bill>) request.getAttribute("allBills");
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Portal - Redupahana</title>
    <style>
        :root {
            --primary-blue: #2b6cb0;
            --secondary-blue: #3182ce;
            --darker-blue: #2c5282;
            --success-color: #10b981;
            --info-color: #3b82f6;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --light-bg: #f8fafc;
            --card-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            --border-radius: 12px;
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, var(--light-bg) 0%, #e2e8f0 100%);
            color: #374151;
            line-height: 1.6;
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            color: white;
            padding: 30px;
            border-radius: var(--border-radius);
            margin-bottom: 30px;
            text-align: center;
            position: relative;
            overflow: hidden;
            box-shadow: var(--card-shadow);
        }

        .header::before {
            content: '';
            position: absolute;
            width: 300px;
            height: 300px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            top: -150px;
            right: -150px;
        }

        .header-content {
            position: relative;
            z-index: 2;
        }

        .welcome-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .welcome-subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 20px;
        }

        .logout-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            padding: 10px 25px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-size: 1rem;
        }

        .logout-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
        }

        /* Navigation */
        .nav-tabs {
            display: flex;
            background: white;
            border-radius: var(--border-radius);
            padding: 5px;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
            gap: 5px;
        }

        .nav-tab {
            flex: 1;
            background: transparent;
            border: none;
            padding: 15px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            color: #6b7280;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .nav-tab.active {
            background: var(--primary-blue);
            color: white;
            box-shadow: 0 4px 15px rgba(43, 108, 176, 0.3);
        }

        .nav-tab:hover:not(.active) {
            background: #f3f4f6;
            color: var(--primary-blue);
        }

        /* Tab Content */
        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
            animation: fadeIn 0.4s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            font-weight: 500;
            border-left: 4px solid;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            color: #dc2626;
            border-left-color: #dc2626;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            border-left-color: #059669;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            text-align: center;
            position: relative;
            overflow: hidden;
            transition: var(--transition);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
        }

        .stat-card:nth-child(1)::before { background: var(--info-color); }
        .stat-card:nth-child(2)::before { background: var(--success-color); }
        .stat-card:nth-child(3)::before { background: var(--warning-color); }
        .stat-card:nth-child(4)::before { background: var(--danger-color); }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            font-size: 1.5rem;
            color: white;
        }

        .stat-card:nth-child(1) .stat-icon { background: linear-gradient(135deg, var(--info-color) 0%, #1d4ed8 100%); }
        .stat-card:nth-child(2) .stat-icon { background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%); }
        .stat-card:nth-child(3) .stat-icon { background: linear-gradient(135deg, var(--warning-color) 0%, #d97706 100%); }
        .stat-card:nth-child(4) .stat-icon { background: linear-gradient(135deg, var(--danger-color) 0%, #dc2626 100%); }

        .stat-value {
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--darker-blue);
            margin-bottom: 8px;
        }

        .stat-label {
            color: #6b7280;
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Cards */
        .card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .card-header {
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            padding: 20px 25px;
            border-bottom: 1px solid #e5e7eb;
        }

        .card-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--darker-blue);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-body {
            padding: 25px;
        }

        /* Bills Table */
        .bills-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        .bills-table th {
            background: #f8fafc;
            color: #495057;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        .bills-table td {
            padding: 12px;
            border-bottom: 1px solid #e9ecef;
            background: white;
        }

        .bills-table tbody tr:hover {
            background: #f8fafc;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .status-paid {
            background: #d4edda;
            color: #155724;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .view-bill-btn {
            background: var(--primary-blue);
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.8rem;
            transition: var(--transition);
        }

        .view-bill-btn:hover {
            background: var(--secondary-blue);
        }

        /* Bill Details Modal */
        .bill-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            padding: 20px;
            overflow-y: auto;
        }

        .bill-modal.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            border-radius: var(--border-radius);
            max-width: 900px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            position: relative;
        }

        .modal-header {
            background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-blue) 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .close-modal {
            background: none;
            border: none;
            color: white;
            font-size: 1.5rem;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .close-modal:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .modal-body {
            padding: 25px;
        }

        .bill-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .info-card {
            background: #f8fafc;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid var(--primary-blue);
        }

        .info-card h4 {
            color: var(--darker-blue);
            margin-bottom: 10px;
            font-size: 1rem;
            font-weight: 600;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }

        .info-label {
            color: #6b7280;
            font-weight: 500;
        }

        .info-value {
            color: var(--darker-blue);
            font-weight: 600;
        }

        .items-section {
            margin: 20px 0;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }

        .items-table th {
            background: #f8fafc;
            color: #495057;
            padding: 10px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        .items-table td {
            padding: 10px;
            border-bottom: 1px solid #e9ecef;
        }

        .book-image {
            width: 50px;
            height: 70px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #e5e7eb;
        }

        .book-details {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .book-info {
            flex: 1;
        }

        .book-title {
            font-weight: 600;
            color: var(--darker-blue);
            margin-bottom: 2px;
        }

        .book-author {
            color: #6b7280;
            font-size: 0.8rem;
            margin-bottom: 2px;
        }

        .book-meta {
            color: #9ca3af;
            font-size: 0.75rem;
        }

        .category-badge {
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 0.7rem;
            font-weight: 500;
            background: #e0f2fe;
            color: #0284c7;
        }

        .bill-total {
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }

        .total-row.grand-total {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--success-color);
            border-top: 2px solid var(--success-color);
            padding-top: 10px;
            margin-top: 10px;
        }

        /* Enhanced Profile Section */
        .profile-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .reading-insights {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }

        .insight-card {
            background: #f8fafc;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid var(--info-color);
        }

        .insight-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--darker-blue);
            margin-bottom: 5px;
        }

        .insight-label {
            color: #6b7280;
            font-size: 0.8rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }

            .welcome-title {
                font-size: 2rem;
            }

            .nav-tab {
                padding: 12px 15px;
                font-size: 0.9rem;
            }

            .stats-grid {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            }

            .stat-value {
                font-size: 1.8rem;
            }

            .bills-table {
                font-size: 0.8rem;
            }

            .bills-table th,
            .bills-table td {
                padding: 8px;
            }

            .modal-content {
                margin: 10px;
                max-height: 95vh;
            }

            .bill-info-grid {
                grid-template-columns: 1fr;
            }

            .book-details {
                flex-direction: column;
                text-align: center;
            }
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #6b7280;
        }

        .empty-icon {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }

        .empty-title {
            font-size: 1.5rem;
            color: #374151;
            margin-bottom: 10px;
        }

        .empty-message {
            font-size: 1rem;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="header-content">
                <h1 class="welcome-title">Welcome, <%= customer != null ? customer.getName() : "Customer" %>!</h1>
                <p class="welcome-subtitle">Account: <%= customer != null ? customer.getAccountNumber() : "N/A" %></p>
                
                <!-- Simple Logout Link -->
                <a href="auth?action=logout" class="logout-btn">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M6 12.5a.5.5 0 0 0 .5.5h8a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-8a.5.5 0 0 0-.5.5v2a.5.5 0 0 1-1 0v-2A1.5 1.5 0 0 1 6.5 2h8A1.5 1.5 0 0 1 16 3.5v9a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 5 12.5v-2a.5.5 0 0 1 1 0v2z"/>
                        <path fill-rule="evenodd" d="M.146 8.354a.5.5 0 0 1 0-.708l3-3a.5.5 0 1 1 .708.708L1.707 7.5H10.5a.5.5 0 0 1 0 1H1.707l2.147 2.146a.5.5 0 0 1-.708.708l-3-3z"/>
                    </svg>
                    Logout
                </a>
            </div>
        </div>

        <!-- Error/Success Messages -->
        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
            <%= errorMessage %>
        </div>
        <% } %>

        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.061L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
            </svg>
            <%= successMessage %>
        </div>
        <% } %>

        <!-- Navigation Tabs -->
        <div class="nav-tabs">
            <button class="nav-tab active" onclick="showTab('dashboard')">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                </svg>
                Dashboard
            </button>
            <button class="nav-tab" onclick="showTab('bills')">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .485.621l-1.5 6A.5.5 0 0 1 13 10H4a.5.5 0 0 1-.485-.379L1.61 3H.5a.5.5 0 0 1-.5-.5z"/>
                </svg>
                My Bills
            </button>
            <button class="nav-tab" onclick="showTab('profile')">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4z"/>
                </svg>
                Profile
            </button>
        </div>

        <!-- Dashboard Tab -->
        <div id="dashboard" class="tab-content active">
            <!-- Statistics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .485.621l-1.5 6A.5.5 0 0 1 13 10H4a.5.5 0 0 1-.485-.379L1.61 3H.5a.5.5 0 0 1-.5-.5z"/>
                        </svg>
                    </div>
                    <div class="stat-value"><%= totalBills != null ? totalBills : 0 %></div>
                    <div class="stat-label">Total Orders</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M4 10.781c.148 1.667 1.513 2.85 3.591 3.003V15h1.043v-1.216c2.27-.179 3.678-1.438 3.678-3.3 0-1.59-.947-2.51-2.956-3.028l-.722-.187V3.467c1.122.11 1.879.714 2.07 1.616h1.47c-.166-1.6-1.54-2.748-3.54-2.875V1H7.591v1.233c-1.939.23-3.27 1.472-3.27 3.156 0 1.454.966 2.483 2.661 2.917l.61.162v4.031c-1.149-.17-1.94-.8-2.131-1.718H4z"/>
                        </svg>
                    </div>
                    <div class="stat-value">Rs. <%= totalAmount != null ? String.format("%.0f", totalAmount) : "0" %></div>
                    <div class="stat-label">Total Spent</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M1 3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1v7.5a2.5 2.5 0 0 1-2.5 2.5h-9A2.5 2.5 0 0 1 1 13.5V6a1 1 0 0 1-1-1V3z"/>
                        </svg>
                    </div>
                    <div class="stat-value">Rs. <%= averageOrderValue != null ? String.format("%.0f", averageOrderValue) : "0" %></div>
                    <div class="stat-label">Average Order</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M1 2.828c.885-.37 2.154-.769 3.388-.893 1.33-.134 2.458.063 3.112.752v9.746c-.935-.53-2.12-.603-3.213-.493-1.18.12-2.37.461-3.287.811V2.828z"/>
                            <path d="M7.5 2.687c.654-.689 1.782-.886 3.112-.752 1.234.124 2.503.523 3.388.893v9.923c-.918-.35-2.107-.692-3.287-.81-1.094-.111-2.278-.039-3.213.492V2.687z"/>
                        </svg>
                    </div>
                    <div class="stat-value"><%= totalBooks != null ? totalBooks : 0 %></div>
                    <div class="stat-label">Books Purchased</div>
                </div>
            </div>

            <!-- Recent Bills -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">
                        <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M14 1a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H4.414A2 2 0 0 0 3 11.586l-2 2V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12.793a.5.5 0 0 0 .854.353l2.853-2.853A1 1 0 0 1 4.414 12H14a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
                        </svg>
                        Recent Orders
                    </h3>
                </div>
                <div class="card-body">
                    <% if (recentBills != null && !recentBills.isEmpty()) { %>
                    <table class="bills-table">
                        <thead>
                            <tr>
                                <th>Bill Number</th>
                                <th>Date</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Bill bill : recentBills) { %>
                            <tr>
                                <td><strong>#<%= bill.getBillNumber() %></strong></td>
                                <td><%= bill.getBillDate() %></td>
                                <td><strong>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></strong></td>
                                <td>
                                    <span class="status-badge status-<%= bill.getPaymentStatus().toLowerCase() %>">
                                        <%= bill.getPaymentStatus() %>
                                    </span>
                                </td>
                                <td>
                                    <button class="view-bill-btn" onclick="viewBill(<%= bill.getBillId() %>)">
                                        View Details
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div class="empty-state">
                        <div class="empty-icon">
                            <svg width="64" height="64" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .485.621l-1.5 6A.5.5 0 0 1 13 10H4a.5.5 0 0 1-.485-.379L1.61 3H.5a.5.5 0 0 1-.5-.5z"/>
                            </svg>
                        </div>
                        <h3 class="empty-title">No Orders Yet</h3>
                        <p class="empty-message">You haven't made any orders yet. Visit our store to start shopping!</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Bills Tab -->
        <div id="bills" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">
                        <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M1 2.828c.885-.37 2.154-.769 3.388-.893 1.33-.134 2.458.063 3.112.752v9.746c-.935-.53-2.12-.603-3.213-.493-1.18.12-2.37.461-3.287.811V2.828z"/>
                        </svg>
                        All My Bills
                    </h3>
                </div>
                <div class="card-body">
                    <% if (allBills != null && !allBills.isEmpty()) { %>
                    <table class="bills-table">
                        <thead>
                            <tr>
                                <th>Bill Number</th>
                                <th>Date</th>
                                <th>Items</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Cashier</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Bill bill : allBills) { %>
                            <tr>
                                <td><strong>#<%= bill.getBillNumber() %></strong></td>
                                <td><%= bill.getBillDate() %></td>
                                <td><%= bill.getBillItems() != null ? bill.getBillItems().size() : 0 %> items</td>
                                <td><strong>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></strong></td>
                                <td>
                                    <span class="status-badge status-<%= bill.getPaymentStatus().toLowerCase() %>">
                                        <%= bill.getPaymentStatus() %>
                                    </span>
                                </td>
                                <td><%= bill.getCashierName() != null ? bill.getCashierName() : "N/A" %></td>
                                <td>
                                    <button class="view-bill-btn" onclick="viewBill(<%= bill.getBillId() %>)">
                                        View Details
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div class="empty-state">
                        <div class="empty-icon">
                            <svg width="64" height="64" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .485.621l-1.5 6A.5.5 0 0 1 13 10H4a.5.5 0 0 1-.485-.379L1.61 3H.5a.5.5 0 0 1-.5-.5z"/>
                            </svg>
                        </div>
                        <h3 class="empty-title">No Bills Found</h3>
                        <p class="empty-message">You don't have any bills yet.</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Profile Tab -->
        <div id="profile" class="tab-content">
            <div class="profile-grid">
                <!-- Personal Information -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4z"/>
                            </svg>
                            Personal Information
                        </h3>
                    </div>
                    <div class="card-body">
                        <% if (customer != null) { %>
                        <div class="info-row">
                            <span class="info-label">Customer ID</span>
                            <span class="info-value">#<%= customer.getCustomerId() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Account Number</span>
                            <span class="info-value"><%= customer.getAccountNumber() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Full Name</span>
                            <span class="info-value"><%= customer.getName() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Phone</span>
                            <span class="info-value">
                                <% if (customer.getPhone() != null && !customer.getPhone().trim().isEmpty()) { %>
                                    <%= customer.getPhone() %>
                                <% } else { %>
                                    <span style="color: #9ca3af; font-style: italic;">Not provided</span>
                                <% } %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Email</span>
                            <span class="info-value">
                                <% if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) { %>
                                    <%= customer.getEmail() %>
                                <% } else { %>
                                    <span style="color: #9ca3af; font-style: italic;">Not provided</span>
                                <% } %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Address</span>
                            <span class="info-value">
                                <% if (customer.getAddress() != null && !customer.getAddress().trim().isEmpty()) { %>
                                    <%= customer.getAddress() %>
                                <% } else { %>
                                    <span style="color: #9ca3af; font-style: italic;">Not provided</span>
                                <% } %>
                            </span>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Account Summary -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M1 3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1v7.5a2.5 2.5 0 0 1-2.5 2.5h-9A2.5 2.5 0 0 1 1 13.5V6a1 1 0 0 1-1-1V3z"/>
                            </svg>
                            Account Summary
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="info-row">
                            <span class="info-label">Member Since</span>
                            <span class="info-value">
                                <%= customer != null && customer.getCreatedDate() != null ? customer.getCreatedDate().toString().substring(0, 10) : "Unknown" %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Account Status</span>
                            <span class="info-value" style="color: var(--success-color); font-weight: 700;">Active</span>
                        </div>
                        
                        <% if (lastOrder != null) { %>
                        <hr style="margin: 15px 0; border: none; border-top: 1px solid #e5e7eb;">
                        <h4 style="color: var(--darker-blue); margin-bottom: 10px; font-size: 1rem;">Last Order</h4>
                        <div class="info-row">
                            <span class="info-label">Bill Number</span>
                            <span class="info-value">#<%= lastOrder.getBillNumber() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Date</span>
                            <span class="info-value"><%= lastOrder.getBillDate() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Amount</span>
                            <span class="info-value">Rs. <%= String.format("%.2f", lastOrder.getTotalAmount()) %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Status</span>
                            <span class="info-value">
                                <span class="status-badge status-<%= lastOrder.getPaymentStatus().toLowerCase() %>">
                                    <%= lastOrder.getPaymentStatus() %>
                                </span>
                            </span>
                        </div>
                        <% } else { %>
                        <div style="text-align: center; color: #9ca3af; font-style: italic; margin-top: 15px;">
                            No orders found
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Reading Insights -->
            <% if (totalBooks != null && totalBooks > 0) { %>
            <div class="card" style="margin-top: 20px;">
                <div class="card-header">
                    <h3 class="card-title">
                        <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M1 2.828c.885-.37 2.154-.769 3.388-.893 1.33-.134 2.458.063 3.112.752v9.746c-.935-.53-2.12-.603-3.213-.493-1.18.12-2.37.461-3.287.811V2.828z"/>
                            <path d="M7.5 2.687c.654-.689 1.782-.886 3.112-.752 1.234.124 2.503.523 3.388.893v9.923c-.918-.35-2.107-.692-3.287-.81-1.094-.111-2.278-.039-3.213.492V2.687z"/>
                        </svg>
                        Reading Insights
                    </h3>
                </div>
                <div class="card-body">
                    <div class="reading-insights">
                        <div class="insight-card">
                            <div class="insight-value"><%= totalUniqueBooks != null ? totalUniqueBooks : 0 %></div>
                            <div class="insight-label">Unique Books</div>
                        </div>
                        
                        <% if (avgBooksPerOrder != null) { %>
                        <div class="insight-card">
                            <div class="insight-value"><%= String.format("%.1f", avgBooksPerOrder) %></div>
                            <div class="insight-label">Books Per Order</div>
                        </div>
                        <% } %>
                        
                        <% if (ordersPerMonth != null) { %>
                        <div class="insight-card">
                            <div class="insight-value"><%= String.format("%.1f", ordersPerMonth) %></div>
                            <div class="insight-label">Orders Per Month</div>
                        </div>
                        <% } %>
                        
                        <% if (favoriteCategory != null && !favoriteCategory.trim().isEmpty()) { %>
                        <div class="insight-card" style="border-left-color: var(--success-color);">
                            <div class="insight-value" style="font-size: 1rem; text-align: center;">
                                <span class="category-badge"><%= favoriteCategory %></span>
                            </div>
                            <div class="insight-label">Favorite Category</div>
                        </div>
                        <% } %>
                        
                        <% if (favoriteAuthor != null && !favoriteAuthor.trim().isEmpty()) { %>
                        <div class="insight-card" style="border-left-color: var(--warning-color);">
                            <div class="insight-value" style="font-size: 0.9rem; text-align: center;">
                                <%= favoriteAuthor.length() > 15 ? favoriteAuthor.substring(0, 15) + "..." : favoriteAuthor %>
                            </div>
                            <div class="insight-label">Favorite Author</div>
                        </div>
                        <% } %>
                        
                        <% if (mostExpensiveOrder != null) { %>
                        <div class="insight-card" style="border-left-color: var(--danger-color);">
                            <div class="insight-value">Rs. <%= String.format("%.0f", mostExpensiveOrder.getTotalAmount()) %></div>
                            <div class="insight-label">Highest Order</div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Bill Details Modal -->
    <div id="billModal" class="bill-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalTitle">Bill Details</h3>
                <button class="close-modal" onclick="closeBillModal()">×</button>
            </div>
            <div class="modal-body">
                <div id="modalContent">
                    <!-- Bill details will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <script>
        // Tab functionality
        function showTab(tabName) {
            // Hide all tab contents
            const tabContents = document.querySelectorAll('.tab-content');
            tabContents.forEach(content => {
                content.classList.remove('active');
            });

            // Remove active class from all tabs
            const tabs = document.querySelectorAll('.nav-tab');
            tabs.forEach(tab => {
                tab.classList.remove('active');
            });

            // Show selected tab content
            document.getElementById(tabName).classList.add('active');
            
            // Add active class to clicked tab
            event.target.classList.add('active');
        }

        // Bill details functionality
        const billsData = {
            <% if (allBills != null && !allBills.isEmpty()) { %>
            <% for (int i = 0; i < allBills.size(); i++) { 
                Bill bill = allBills.get(i);
                
                // Safe null handling for numeric values
                Double billSubTotal = bill.getSubTotal();
                Double billDiscount = bill.getDiscount();
                Double billTax = bill.getTax();
                Double billTotalAmount = bill.getTotalAmount();
                
                double subTotalValue = (billSubTotal != null) ? billSubTotal.doubleValue() : 0.0;
                double discountValue = (billDiscount != null) ? billDiscount.doubleValue() : 0.0;
                double taxValue = (billTax != null) ? billTax.doubleValue() : 0.0;
                double totalValue = (billTotalAmount != null) ? billTotalAmount.doubleValue() : 0.0;
            %>
            <%= bill.getBillId() %>: {
                id: <%= bill.getBillId() %>,
                number: '<%= bill.getBillNumber() != null ? bill.getBillNumber() : "N/A" %>',
                date: '<%= bill.getBillDate() != null ? bill.getBillDate() : "Unknown" %>',
                total: <%= totalValue %>,
                status: '<%= bill.getPaymentStatus() != null ? bill.getPaymentStatus() : "UNKNOWN" %>',
                cashier: '<%= bill.getCashierName() != null ? bill.getCashierName().replace("'", "\\'") : "N/A" %>',
                subtotal: <%= subTotalValue %>,
                discount: <%= discountValue %>,
                tax: <%= taxValue %>,
                items: [
                    <% if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) { %>
                    <% for (int j = 0; j < bill.getBillItems().size(); j++) { 
                        BillItem item = bill.getBillItems().get(j);
                        
                        // Safe null handling for item values
                        Integer itemQuantity = item.getQuantity();
                        Double itemUnitPrice = item.getUnitPrice();
                        Double itemTotalPrice = item.getTotalPrice();
                        
                        int quantityValue = (itemQuantity != null) ? itemQuantity.intValue() : 0;
                        double unitPriceValue = (itemUnitPrice != null) ? itemUnitPrice.doubleValue() : 0.0;
                        double itemTotalValue = (itemTotalPrice != null) ? itemTotalPrice.doubleValue() : 0.0;
                    %>
                    {
                        title: '<%= item.getBookTitle() != null ? item.getBookTitle().replace("'", "\\'") : ("Book #" + item.getBookId()) %>',
                        author: '<%= item.getAuthor() != null ? item.getAuthor().replace("'", "\\'") : "Unknown" %>',
                        code: '<%= item.getBookCode() != null ? item.getBookCode().replace("'", "\\'") : "N/A" %>',
                        category: '<%= item.getBookCategory() != null ? item.getBookCategory().replace("'", "\\'") : "" %>',
                        isbn: '<%= item.getIsbn() != null ? item.getIsbn().replace("'", "\\'") : "" %>',
                        publisher: '<%= item.getPublisher() != null ? item.getPublisher().replace("'", "\\'") : "" %>',
                        language: '<%= item.getLanguage() != null ? item.getLanguage().replace("'", "\\'") : "" %>',
                        pages: <%= item.getPages() %>,
                        year: <%= item.getPublicationYear() %>,
                        imageBase64: '<%= item.getImageBase64() != null ? item.getImageBase64() : "" %>',
                        quantity: <%= quantityValue %>,
                        unitPrice: <%= unitPriceValue %>,
                        totalPrice: <%= itemTotalValue %>
                    }<%= j < bill.getBillItems().size() - 1 ? "," : "" %>
                    <% } %>
                    <% } %>
                ]
            }<%= i < allBills.size() - 1 ? "," : "" %>
            <% } %>
            <% } %>
        };

        function viewBill(billId) {
            const bill = billsData[billId];
            if (!bill) {
                alert('Bill details not found');
                return;
            }

            document.getElementById('modalTitle').textContent = `Bill #${bill.number}`;
            
            let itemsHtml = '';
            if (bill.items && bill.items.length > 0) {
                itemsHtml = `
                    <div class="items-section">
                        <h4 style="color: var(--darker-blue); margin-bottom: 15px;">Items Purchased</h4>
                        <table class="items-table">
                            <thead>
                                <tr>
                                    <th>Book Details</th>
                                    <th style="text-align: center;">Qty</th>
                                    <th style="text-align: right;">Unit Price</th>
                                    <th style="text-align: right;">Total</th>
                                </tr>
                            </thead>
                            <tbody>`;
                
                bill.items.forEach(item => {
                    let bookImage = '';
                    if (item.imageBase64 && item.imageBase64.trim() !== '') {
                        bookImage = `<img src="data:image/jpeg;base64,${item.imageBase64}" alt="${item.title}" class="book-image" onerror="this.style.display='none'">`;
                    } else {
                        bookImage = `<div class="book-image" style="background: #f3f4f6; display: flex; align-items: center; justify-content: center; color: #9ca3af; font-size: 0.7rem;">No Image</div>`;
                    }
                    
                    itemsHtml += `
                        <tr>
                            <td>
                                <div class="book-details">
                                    ${bookImage}
                                    <div class="book-info">
                                        <div class="book-title">${item.title}</div>
                                        <div class="book-author">by ${item.author}</div>
                                        <div class="book-meta">
                                            Code: ${item.code}${item.category ? ` | ${item.category}` : ''}${item.isbn ? ` | ISBN: ${item.isbn}` : ''}
                                        </div>
                                        ${item.publisher || item.language || item.pages || item.year ? `
                                        <div class="book-meta">
                                            ${item.publisher ? `${item.publisher}` : ''}${item.language ? ` | ${item.language}` : ''}${item.pages ? ` | ${item.pages} pages` : ''}${item.year ? ` | ${item.year}` : ''}
                                        </div>` : ''}
                                    </div>
                                </div>
                            </td>
                            <td style="text-align: center;">${item.quantity}</td>
                            <td style="text-align: right;">Rs. ${item.unitPrice.toFixed(2)}</td>
                            <td style="text-align: right;"><strong>Rs. ${item.totalPrice.toFixed(2)}</strong></td>
                        </tr>`;
                });
                
                itemsHtml += `
                            </tbody>
                        </table>
                    </div>`;
            } else {
                itemsHtml = '<p style="text-align: center; color: #6b7280; font-style: italic;">No items found</p>';
            }

            const modalContent = `
                <div class="bill-info-grid">
                    <div class="info-card">
                        <h4>Bill Information</h4>
                        <div class="info-row">
                            <span class="info-label">Bill Number:</span>
                            <span class="info-value">#${bill.number}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Date:</span>
                            <span class="info-value">${bill.date}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Status:</span>
                            <span class="info-value">
                                <span class="status-badge status-${bill.status.toLowerCase()}">${bill.status}</span>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Cashier:</span>
                            <span class="info-value">${bill.cashier}</span>
                        </div>
                    </div>
                </div>
                
                ${itemsHtml}
                
                <div class="bill-total">
                    <h4 style="color: var(--darker-blue); margin-bottom: 15px;">Bill Summary</h4>
                    <div class="total-row">
                        <span>Subtotal:</span>
                        <span>Rs. ${bill.subtotal.toFixed(2)}</span>
                    </div>
                    ${bill.discount > 0 ? `
                    <div class="total-row" style="color: var(--danger-color);">
                        <span>Discount:</span>
                        <span>- Rs. ${bill.discount.toFixed(2)}</span>
                    </div>` : ''}
                    <div class="total-row">
                        <span>Tax:</span>
                        <span>Rs. ${bill.tax.toFixed(2)}</span>
                    </div>
                    <div class="total-row grand-total">
                        <span>GRAND TOTAL:</span>
                        <span>Rs. ${bill.total.toFixed(2)}</span>
                    </div>
                </div>`;

            document.getElementById('modalContent').innerHTML = modalContent;
            document.getElementById('billModal').classList.add('active');
        }

        function closeBillModal() {
            document.getElementById('billModal').classList.remove('active');
        }

        // Close modal when clicking outside
        document.addEventListener('click', function(e) {
            const billModal = document.getElementById('billModal');
            if (billModal && e.target === billModal) {
                closeBillModal();
            }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key - Close modal
            if (e.key === 'Escape') {
                const billModal = document.getElementById('billModal');
                if (billModal && billModal.classList.contains('active')) {
                    closeBillModal();
                }
            }
            
            // Number keys to switch tabs
            if (e.key === '1') {
                document.querySelectorAll('.nav-tab')[0].click();
            }
            if (e.key === '2') {
                document.querySelectorAll('.nav-tab')[1].click();
            }
            if (e.key === '3') {
                document.querySelectorAll('.nav-tab')[2].click();
            }
        });

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function() {
            // Auto-hide existing alerts after 5 seconds
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-10px)';
                    setTimeout(() => {
                        if (alert.parentNode) {
                            alert.parentNode.removeChild(alert);
                        }
                    }, 300);
                }, 5000);
            });

            console.log('Customer Portal loaded successfully');
        });
    </script>
</body>
</html>