<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="java.util.List"%>
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
    
    // Profile data
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Double totalSpent = (Double) request.getAttribute("totalSpent");
    Double averageOrderValue = (Double) request.getAttribute("averageOrderValue");
    Integer totalBooks = (Integer) request.getAttribute("totalBooks");
    Bill lastOrder = (Bill) request.getAttribute("lastOrder");
    
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
    /* Success/Logout Notification Styles */
.notification {
    position: fixed;
    top: 20px;
    right: -400px;
    width: 350px;
    padding: 20px;
    background: white;
    border-radius: var(--border-radius);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
    border-left: 5px solid var(--success-color);
    z-index: 2000;
    transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.notification.show {
    right: 20px;
}

.notification.logout {
    border-left-color: var(--info-color);
}

.notification-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 8px;
}

.notification-icon {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 12px;
    font-weight: bold;
    flex-shrink: 0;
}

.notification-icon.success {
    background: var(--success-color);
}

.notification-icon.info {
    background: var(--info-color);
}

.notification-title {
    font-weight: 600;
    color: var(--darker-blue);
    font-size: 1rem;
    margin: 0;
}

.notification-message {
    color: #6b7280;
    font-size: 0.9rem;
    line-height: 1.4;
    margin: 0;
}

.notification-close {
    position: absolute;
    top: 12px;
    right: 12px;
    background: none;
    border: none;
    color: #9ca3af;
    cursor: pointer;
    font-size: 18px;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: var(--transition);
}

.notification-close:hover {
    background: #f3f4f6;
    color: #374151;
}

/* Countdown Progress Bar */
.countdown-progress {
    margin-top: 10px;
    height: 4px;
    background: #e5e7eb;
    border-radius: 2px;
    overflow: hidden;
}

.countdown-bar {
    height: 100%;
    background: linear-gradient(90deg, var(--info-color), #1d4ed8);
    width: 100%;
    transition: width linear;
}

/* Animation for notification */
@keyframes slideInBounce {
    0% {
        right: -400px;
        opacity: 0;
    }
    60% {
        right: 30px;
        opacity: 1;
    }
    80% {
        right: 10px;
    }
    100% {
        right: 20px;
        opacity: 1;
    }
}

.notification.animate {
    animation: slideInBounce 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

/* Mobile responsiveness for notifications */
@media (max-width: 768px) {
    .notification {
        width: calc(100vw - 40px);
        right: -100vw;
        left: 20px;
    }
    
    .notification.show {
        right: 20px;
    }
    
    @keyframes slideInBounce {
        0% {
            right: -100vw;
            opacity: 0;
        }
        60% {
            right: 30px;
            opacity: 1;
        }
        80% {
            right: 10px;
        }
        100% {
            right: 20px;
            opacity: 1;
        }
    }
}

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

        .logout-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            pointer-events: none;
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
            max-width: 800px;
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

        /* Profile Section */
        .profile-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
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

        /* Loading */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid var(--primary-blue);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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
                
                <!-- Logout Button with onclick handler -->
                <button onclick="showLogoutConfirmation()" class="logout-btn" id="logoutBtn">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M6 12.5a.5.5 0 0 0 .5.5h8a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-8a.5.5 0 0 0-.5.5v2a.5.5 0 0 1-1 0v-2A1.5 1.5 0 0 1 6.5 2h8A1.5 1.5 0 0 1 16 3.5v9a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 5 12.5v-2a.5.5 0 0 1 1 0v2z"/>
                        <path fill-rule="evenodd" d="M.146 8.354a.5.5 0 0 1 0-.708l3-3a.5.5 0 1 1 .708.708L1.707 7.5H10.5a.5.5 0 0 1 0 1H1.707l2.147 2.146a.5.5 0 0 1-.708.708l-3-3z"/>
                    </svg>
                    <span id="logoutText">Logout</span>
                </button>
            </div>
        </div>

        <!-- Success/Logout Notifications -->
        <% if ("true".equals(showWelcomeNotification) && customer != null) { %>
        <div id="welcomeNotification" class="notification">
            <button class="notification-close" onclick="closeNotification('welcomeNotification')">&times;</button>
            <div class="notification-header">
                <div class="notification-icon success">✓</div>
                <h4 class="notification-title">Welcome Back!</h4>
            </div>
            <p class="notification-message">
                Hello <%= customer.getName() %>! You have successfully logged into your customer portal.
            </p>
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
                    <path d="M5 13a1 1 0 1 0 0 2 1 1 0 0 0 0-2zm-2 1a2 2 0 1 1 4 0 2 2 0 0 1-4 0zm9-1a1 1 0 1 0 0 2 1 1 0 0 0 0-2zm-2 1a2 2 0 1 1 4 0 2 2 0 0 1-4 0z"/>
                </svg>
                My Bills
            </button>
            <button class="nav-tab" onclick="showTab('profile')">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
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
                                    <a href="tel:<%= customer.getPhone() %>" style="color: var(--primary-blue);"><%= customer.getPhone() %></a>
                                <% } else { %>
                                    <span style="color: #9ca3af; font-style: italic;">Not provided</span>
                                <% } %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Email</span>
                            <span class="info-value">
                                <% if (customer.getEmail() != null && !customer.getEmail().trim().isEmpty()) { %>
                                    <a href="mailto:<%= customer.getEmail() %>" style="color: var(--primary-blue);"><%= customer.getEmail() %></a>
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

            <!-- Contact Information -->
            <div class="card" style="margin-top: 20px;">
                <div class="card-header">
                    <h3 class="card-title">
                        <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4Zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1H2Zm13 2.383-4.708 2.825L15 11.105V5.383Zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741ZM1 11.105l4.708-2.897L1 5.383v5.722Z"/>
                        </svg>
                        Need Help? Contact Us
                    </h3>
                </div>
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
                        <div style="text-align: center; padding: 20px; background: #f8fafc; border-radius: 8px;">
                            <div style="width: 50px; height: 50px; background: var(--primary-blue); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; color: white;">
                                <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                    <path d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4Z"/>
                                </svg>
                            </div>
                            <h4 style="color: var(--darker-blue); margin-bottom: 5px;">Email Support</h4>
                            <a href="mailto:support@redupahana.lk?subject=Customer Portal Support - Account <%= customer != null ? customer.getAccountNumber() : "N/A" %>&body=Hello Redupahana Support Team,%0D%0A%0D%0AI am <%= customer != null ? customer.getName() : "Customer" %> (Account: <%= customer != null ? customer.getAccountNumber() : "N/A" %>) and I need assistance with:%0D%0A%0D%0A[Please describe your inquiry here]" 
                               style="color: var(--primary-blue); text-decoration: none; font-weight: 600;">support@redupahana.lk</a>
                        </div>
                        
                        <div style="text-align: center; padding: 20px; background: #f8fafc; border-radius: 8px;">
                            <div style="width: 50px; height: 50px; background: var(--success-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; color: white;">
                                <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                    <path fill-rule="evenodd" d="M1.885.511a1.745 1.745 0 0 1 2.61.163L6.29 2.98c.329.423.445.974.315 1.494l-.547 2.19a.678.678 0 0 0 .178.643l2.457 2.457a.678.678 0 0 0 .644.178l2.189-.547a1.745 1.745 0 0 1 1.494.315l2.306 1.794c.829.645.905 1.87.163 2.611l-1.034 1.034c-.74.74-1.846 1.065-2.877.702a18.634 18.634 0 0 1-7.01-4.42 18.634 18.634 0 0 1-4.42-7.009c-.362-1.03-.037-2.137.703-2.877L1.885.511z"/>
                                </svg>
                            </div>
                            <h4 style="color: var(--darker-blue); margin-bottom: 5px;">Phone Support</h4>
                            <a href="tel:+94112345678" style="color: var(--success-color); text-decoration: none; font-weight: 600;">+94 11 234 5678</a>
                        </div>
                        
                        <div style="text-align: center; padding: 20px; background: #f8fafc; border-radius: 8px;">
                            <div style="width: 50px; height: 50px; background: var(--warning-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; color: white;">
                                <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                    <path d="M12.166 8.94c-.524 1.062-1.234 2.12-1.96 3.07A31.493 31.493 0 0 1 8 14.58a31.481 31.481 0 0 1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 7.867 3 6.862 3 6a5 5 0 0 1 10 0c0 .862-.305 1.867-.834 2.94zM8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10z"/>
                                    <path d="M8 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 1a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>
                                </svg>
                            </div>
                            <h4 style="color: var(--darker-blue); margin-bottom: 5px;">Visit Store</h4>
                            <p style="color: #6b7280; font-size: 0.9rem; margin: 0;">123 Main Street<br>Colombo 01</p>
                        </div>
                    </div>
                </div>
            </div>
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
    // Global variables
    const customerName = '<%= customer != null ? customer.getName() : "Customer" %>';
    let logoutTimer = null;
    let logoutCancelled = false;

    // Logout functionality with countdown and delay
    function showLogoutConfirmation() {
        const logoutBtn = document.getElementById('logoutBtn');
        const logoutText = document.getElementById('logoutText');
        
        // Disable button to prevent multiple clicks
        logoutBtn.disabled = true;
        logoutBtn.style.opacity = '0.7';
        logoutText.innerHTML = 'Processing...';
        
        // Reset cancellation flag
        logoutCancelled = false;
        
        // Create logout notification
        const notification = document.createElement('div');
        notification.id = 'logoutCountdownNotification';
        notification.className = 'notification logout';
        notification.innerHTML = `
            <button class="notification-close" onclick="cancelLogout()">&times;</button>
            <div class="notification-header">
                <div class="notification-icon info">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                        <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                        <path d="m10.97 4.97-.02.022-3.473 4.425-2.093-2.094a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-1.071-1.05z"/>
                    </svg>
                </div>
                <h4 class="notification-title">Logging Out...</h4>
            </div>
            <p class="notification-message" id="logoutCountdownMessage">
                Goodbye, ${customerName}! Logging out in <span id="countdown">3</span> seconds...
            </p>
            <div class="countdown-progress">
                <div class="countdown-bar" id="countdownBar" style="transition: width 3s linear; width: 100%;"></div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8rem; color: #6b7280; text-align: center;">
                Press ESC to cancel
            </div>
        `;
        
        document.body.appendChild(notification);
        
        // Show notification with animation
        setTimeout(() => {
            notification.classList.add('show', 'animate');
            // Start countdown bar animation
            const countdownBar = document.getElementById('countdownBar');
            if (countdownBar) {
                countdownBar.style.width = '0%';
            }
        }, 100);
        
        // Start countdown
        startLogoutCountdown();
        
        // Add ESC key listener
        document.addEventListener('keydown', handleLogoutEscape);
    }

    function startLogoutCountdown() {
        let count = 3;
        const countdownElement = document.getElementById('countdown');
        
        logoutTimer = setInterval(() => {
            if (logoutCancelled) {
                clearInterval(logoutTimer);
                return;
            }
            
            count--;
            if (countdownElement) {
                countdownElement.textContent = count;
            }
            
            if (count <= 0) {
                clearInterval(logoutTimer);
                
                if (!logoutCancelled) {
                    // Final message before redirect
                    const messageElement = document.getElementById('logoutCountdownMessage');
                    if (messageElement) {
                        messageElement.innerHTML = `Redirecting to login page...`;
                    }
                    
                    // Redirect after short delay
                    setTimeout(() => {
                        window.location.href = 'auth?action=logout';
                    }, 1000);
                }
            }
        }, 1000);
    }

    function cancelLogout() {
        logoutCancelled = true;
        
        if (logoutTimer) {
            clearInterval(logoutTimer);
        }
        
        // Remove notification
        const notification = document.getElementById('logoutCountdownNotification');
        if (notification) {
            notification.classList.remove('show');
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 400);
        }
        
        // Restore logout button
        const logoutBtn = document.getElementById('logoutBtn');
        const logoutText = document.getElementById('logoutText');
        logoutBtn.disabled = false;
        logoutBtn.style.opacity = '1';
        logoutText.innerHTML = 'Logout';
        
        // Remove ESC listener
        document.removeEventListener('keydown', handleLogoutEscape);
        
        // Show cancellation message
        showCancellationMessage();
    }

    function handleLogoutEscape(e) {
        if (e.key === 'Escape') {
            cancelLogout();
        }
    }

    function showCancellationMessage() {
        const cancelMessage = document.createElement('div');
        cancelMessage.className = 'notification';
        cancelMessage.style.borderLeftColor = 'var(--success-color)';
        cancelMessage.innerHTML = `
            <div class="notification-header">
                <div class="notification-icon success">✓</div>
                <h4 class="notification-title">Logout Cancelled</h4>
            </div>
            <p class="notification-message">
                Logout has been cancelled. You remain logged in.
            </p>
        `;
        
        document.body.appendChild(cancelMessage);
        
        setTimeout(() => {
            cancelMessage.classList.add('show', 'animate');
        }, 100);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            cancelMessage.classList.remove('show');
            setTimeout(() => {
                if (cancelMessage.parentNode) {
                    cancelMessage.parentNode.removeChild(cancelMessage);
                }
            }, 400);
        }, 3000);
    }

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

    // Notification functionality
    function showNotification(notificationId) {
        const notification = document.getElementById(notificationId);
        if (notification) {
            // Show notification with animation
            setTimeout(() => {
                notification.classList.add('show', 'animate');
            }, 300);

            // Auto-hide after 5 seconds
            setTimeout(() => {
                closeNotification(notificationId);
            }, 5000);
        }
    }

    function closeNotification(notificationId) {
        const notification = document.getElementById(notificationId);
        if (notification) {
            notification.classList.remove('show');
            // Remove element after animation completes
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 400);
        }
    }

    // Bill details functionality
    const billsData = {
        <% if (allBills != null && !allBills.isEmpty()) { %>
        <% for (int i = 0; i < allBills.size(); i++) { 
            Bill bill = allBills.get(i);
            
            // Safe null handling for numeric values with unique variable names
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
                    
                    // Safe null handling for item values with unique names
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
                itemsHtml += `
                    <tr>
                        <td>
                            <strong>${item.title}</strong><br>
                            <small style="color: #6b7280;">by ${item.author} | Code: ${item.code}</small>
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
                    <span>Tax (5%):</span>
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

    function showTabByIndex(index) {
        const tabs = ['dashboard', 'bills', 'profile'];
        if (tabs[index]) {
            const tabButtons = document.querySelectorAll('.nav-tab');
            tabButtons[index].click();
        }
    }

    // Event Listeners - Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        // Show welcome notification if present
        const welcomeNotification = document.getElementById('welcomeNotification');
        if (welcomeNotification) {
            showNotification('welcomeNotification');
        }

        // Show logout notification if present
        const logoutNotification = document.getElementById('logoutNotification');
        if (logoutNotification) {
            showNotification('logoutNotification');
        }

        // Auto-hide existing alerts
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
        console.log('Features: Welcome notifications, Logout with countdown, Bill details modal');
        console.log('Keyboard shortcuts: 1=Dashboard, 2=Bills, 3=Profile, ESC=Close modal/Cancel logout');
    });

    // Close modal when clicking outside
    document.addEventListener('click', function(e) {
        const billModal = document.getElementById('billModal');
        if (billModal && e.target === billModal) {
            closeBillModal();
        }
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // ESC key - Close modal and notifications (but not during logout countdown - that's handled separately)
        if (e.key === 'Escape') {
            const billModal = document.getElementById('billModal');
            if (billModal && billModal.classList.contains('active')) {
                closeBillModal();
                return; // Don't close other notifications if modal is open
            }
            
            // Close other notifications (but not logout countdown - that's handled in handleLogoutEscape)
            document.querySelectorAll('.notification.show').forEach(notification => {
                if (notification.id !== 'logoutCountdownNotification') {
                    closeNotification(notification.id);
                }
            });
        }
        
        // Number keys to switch tabs
        if (e.key === '1') showTabByIndex(0);
        if (e.key === '2') showTabByIndex(1);
        if (e.key === '3') showTabByIndex(2);
    });

    // Smooth scrolling for better UX
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth' });
                }
            });
        });

        // Add loading states to buttons
        document.querySelectorAll('.view-bill-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const originalText = this.innerHTML;
                this.innerHTML = '<div class="loading"></div> Loading...';
                this.disabled = true;
                
                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.disabled = false;
                }, 1000);
            });
        });

        // Welcome animation
        setTimeout(() => {
            const header = document.querySelector('.header');
            if (header) {
                header.style.animation = 'none';
            }
        }, 1000);
    });
</script>
</body></html>