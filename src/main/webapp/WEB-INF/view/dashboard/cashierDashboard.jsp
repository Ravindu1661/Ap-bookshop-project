<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "dashboard");
    request.setAttribute("pageTitle", "Cashier Dashboard");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Dashboard - R-edupahana</title>
    
    <style>
        /* Professional Cashier Dashboard Styles */
        .cashier-welcome {
            background: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .cashier-welcome h1 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .cashier-welcome .subtitle {
            opacity: 0.9;
            font-size: 1rem;
            margin-bottom: 1rem;
        }

        .user-info-box {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            margin-top: 1rem;
        }

        .user-avatar-large {
            width: 50px;
            height: 50px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: bold;
        }

        .user-details h3 {
            margin: 0;
            font-size: 1.1rem;
        }

        .user-details p {
            margin: 0;
            opacity: 0.8;
            font-size: 0.9rem;
        }

        /* Simple Stats Cards */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-box {
            background: white;
            padding: 1.8rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            border-top: 4px solid #3498db;
        }

        .stat-box.sales {
            border-top-color: #27ae60;
        }

        .stat-box.bills {
            border-top-color: #e74c3c;
        }

        .stat-box.customers {
            border-top-color: #f39c12;
        }

        .stat-box:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .stat-title {
            color: #7f8c8d;
            font-size: 0.9rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            background: #ecf0f1;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
        }

        .stat-change {
            font-size: 0.8rem;
            color: #27ae60;
            margin-top: 0.5rem;
        }

        /* Action Cards Grid */
        .actions-section {
            margin-bottom: 2rem;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            color: #2c3e50;
            font-size: 1.2rem;
            font-weight: 600;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .action-item {
            background: white;
            padding: 1.8rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .action-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: #3498db;
        }

        .action-item.primary::before {
            background: #27ae60;
        }

        .action-item.secondary::before {
            background: #f39c12;
        }

        .action-item.danger::before {
            background: #e74c3c;
        }

        .action-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        }

        .action-symbol {
            width: 60px;
            height: 60px;
            background: #ecf0f1;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin: 0 auto 1rem;
        }

        .action-item.primary .action-symbol {
            background: #d5f4e6;
            color: #27ae60;
        }

        .action-item.secondary .action-symbol {
            background: #fef9e7;
            color: #f39c12;
        }

        .action-item.danger .action-symbol {
            background: #fadbd8;
            color: #e74c3c;
        }

        .action-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.8rem;
        }

        .action-desc {
            color: #7f8c8d;
            font-size: 0.9rem;
            line-height: 1.5;
            margin-bottom: 1.5rem;
        }

        .action-button {
            background: #3498db;
            color: white;
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            display: inline-block;
            cursor: pointer;
        }

        .action-button:hover {
            background: #2980b9;
            transform: translateY(-1px);
            color: white;
        }

        .action-item.primary .action-button {
            background: #27ae60;
        }

        .action-item.primary .action-button:hover {
            background: #229954;
        }

        .action-item.secondary .action-button {
            background: #f39c12;
        }

        .action-item.secondary .action-button:hover {
            background: #e67e22;
        }

        .action-item.danger .action-button {
            background: #e74c3c;
        }

        .action-item.danger .action-button:hover {
            background: #c0392b;
        }

        /* Recent Activity */
        .activity-section {
            background: white;
            padding: 1.8rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .activity-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .activity-entry {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem 0;
            border-bottom: 1px solid #ecf0f1;
        }

        .activity-entry:last-child {
            border-bottom: none;
        }

        .activity-symbol {
            width: 35px;
            height: 35px;
            background: #ecf0f1;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }

        .activity-content {
            flex: 1;
        }

        .activity-title {
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.95rem;
            margin-bottom: 0.2rem;
        }

        .activity-time {
            color: #95a5a6;
            font-size: 0.85rem;
        }

        /* Time Display */
        .time-display {
            text-align: right;
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .cashier-welcome {
                padding: 1.5rem;
            }

            .cashier-welcome h1 {
                font-size: 1.5rem;
            }

            .user-info-box {
                flex-direction: column;
                text-align: center;
            }

            .stats-overview {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .actions-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .stat-box,
            .action-item,
            .activity-section {
                padding: 1.2rem;
            }
        }

        /* Smooth animations */
        .stat-box,
        .action-item,
        .activity-section {
            animation: slideUp 0.4s ease-out;
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
    <!-- Include sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <!-- Welcome Section -->
            <div class="cashier-welcome">
                <h1>Cashier Dashboard</h1>
                <p class="subtitle">Manage daily transactions and customer services</p>
                
                <div class="user-info-box">
                    <div class="user-avatar-large">
                        <%= loggedUser.getFullName().substring(0,1).toUpperCase() %>
                    </div>
                    <div class="user-details">
                        <h3><%= loggedUser.getFullName() %></h3>
                        <p>Cashier • <%= loggedUser.getUsername() %></p>
                    </div>
                    <div class="time-display" id="currentTime"></div>
                </div>
            </div>

            <!-- Statistics Overview -->
            <div class="stats-overview">
                <div class="stat-box sales">
                    <div class="stat-header">
                        <span class="stat-title">Today's Sales</span>
                        <div class="stat-icon">💰</div>
                    </div>
                    <div class="stat-value" id="todaySales">Rs. 0.00</div>
                    <div class="stat-change">+12% from yesterday</div>
                </div>

                <div class="stat-box bills">
                    <div class="stat-header">
                        <span class="stat-title">Bills Processed</span>
                        <div class="stat-icon">📋</div>
                    </div>
                    <div class="stat-value" id="todayBills">0</div>
                    <div class="stat-change">+3 new today</div>
                </div>

                <div class="stat-box customers">
                    <div class="stat-header">
                        <span class="stat-title">Customers Served</span>
                        <div class="stat-icon">👥</div>
                    </div>
                    <div class="stat-value" id="customersServed">0</div>
                    <div class="stat-change">Active customers</div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="actions-section">
                <h2 class="section-header">
                    <span>⚡</span>
                    Quick Actions
                </h2>
                
                <div class="actions-grid">
                    <div class="action-item primary">
                        <div class="action-symbol">💳</div>
                        <h3 class="action-title">Create New Bill</h3>
                        <p class="action-desc">Start a new transaction and process customer purchases</p>
                        <a href="bill?action=create" class="action-button">Create Bill</a>
                    </div>

                    <div class="action-item">
                        <div class="action-symbol">👤</div>
                        <h3 class="action-title">Customer Management</h3>
                        <p class="action-desc">View, add, or update customer information</p>
                        <a href="customer?action=list" class="action-button">Manage Customers</a>
                    </div>

                    <div class="action-item secondary">
                        <div class="action-symbol">📚</div>
                        <h3 class="action-title">View Books</h3>
                        <p class="action-desc">Browse book inventory and check availability</p>
                        <a href="book?action=list" class="action-button">View Books</a>
                    </div>

                    <div class="action-item danger">
                        <div class="action-symbol">📊</div>
                        <h3 class="action-title">Bill History</h3>
                        <p class="action-desc">View transaction history and previous bills</p>
                        <a href="bill?action=list" class="action-button">View Bills</a>
                    </div>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="activity-section">
                <h2 class="section-header">
                    <span>📈</span>
                    Recent Activity
                </h2>
                
                <ul class="activity-list" id="activityList">
                    <li class="activity-entry">
                        <div class="activity-symbol">✅</div>
                        <div class="activity-content">
                            <div class="activity-title">System Ready</div>
                            <div class="activity-time">Ready to process transactions</div>
                        </div>
                    </li>
                    <li class="activity-entry">
                        <div class="activity-symbol">👤</div>
                        <div class="activity-content">
                            <div class="activity-title">Cashier Login</div>
                            <div class="activity-time">Successfully logged into the system</div>
                        </div>
                    </li>
                </ul>
            </div>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize dashboard
            initializeCashierDashboard();
            
            // Update time display
            updateTimeDisplay();
            setInterval(updateTimeDisplay, 1000);
            
            // Load statistics
            loadDashboardStats();
            
            console.log('Cashier Dashboard loaded successfully');
        });

        function initializeCashierDashboard() {
            // Add welcome activity
            setTimeout(() => {
                const hour = new Date().getHours();
                let greeting = 'Good morning';
                if (hour >= 12) greeting = 'Good afternoon';
                if (hour >= 18) greeting = 'Good evening';
                
                addActivityEntry('👋', `${greeting}, <%= loggedUser.getFullName() %>!`, 'Welcome to your dashboard');
            }, 1500);

            // Animate statistics
            animateNumbers();
        }

        function updateTimeDisplay() {
            const now = new Date();
            const timeString = now.toLocaleString('en-US', {
                weekday: 'short',
                month: 'short', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            
            const timeElement = document.getElementById('currentTime');
            if (timeElement) {
                timeElement.textContent = timeString;
            }
        }

        function loadDashboardStats() {
            // Simulate loading statistics
            setTimeout(() => {
                document.getElementById('todaySales').textContent = 'Rs. 45,250.00';
                document.getElementById('todayBills').textContent = '12';
                document.getElementById('customersServed').textContent = '8';
                animateNumbers();
            }, 800);
        }

        function animateNumbers() {
            const numbers = document.querySelectorAll('.stat-value');
            numbers.forEach(element => {
                const finalValue = element.textContent;
                const isRupees = finalValue.includes('Rs.');
                const numValue = parseInt(finalValue.replace(/[^\d]/g, '')) || 0;
                
                if (numValue > 0) {
                    let current = 0;
                    const increment = numValue / 30;
                    
                    const timer = setInterval(() => {
                        current += increment;
                        if (current >= numValue) {
                            current = numValue;
                            clearInterval(timer);
                        }
                        
                        if (isRupees) {
                            element.textContent = 'Rs. ' + Math.floor(current).toLocaleString() + '.00';
                        } else {
                            element.textContent = Math.floor(current).toString();
                        }
                    }, 50);
                }
            });
        }

        function addActivityEntry(icon, title, description) {
            const activityList = document.getElementById('activityList');
            const newEntry = document.createElement('li');
            newEntry.className = 'activity-entry';
            newEntry.innerHTML = `
                <div class="activity-symbol">${icon}</div>
                <div class="activity-content">
                    <div class="activity-title">${title}</div>
                    <div class="activity-time">${description}</div>
                </div>
            `;
            
            activityList.insertBefore(newEntry, activityList.firstChild);
            
            // Keep only latest 4 activities
            while (activityList.children.length > 4) {
                activityList.removeChild(activityList.lastChild);
            }
        }
    </script>
</body>
</html>