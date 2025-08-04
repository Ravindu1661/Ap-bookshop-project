<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Dashboard - Redupahana</title>
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
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .navbar h1 {
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .cashier-icon {
            font-size: 2rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-welcome {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
        }

        .user-name {
            font-weight: 600;
            font-size: 1.1rem;
        }

        .user-role {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .logout-btn {
            background-color: rgba(255,255,255,0.2);
            color: white;
            border: none;
            padding: 0.6rem 1.2rem;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9rem;
            transition: background-color 0.3s;
        }

        .logout-btn:hover {
            background-color: rgba(255,255,255,0.3);
        }

        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .welcome-section {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }

        .welcome-section h2 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 2rem;
        }

        .welcome-section p {
            color: #7f8c8d;
            font-size: 1.1rem;
        }

        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.15);
        }

        .stat-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .stat-card.sales {
            border-left: 5px solid #3498db;
        }

        .stat-card.bills {
            border-left: 5px solid #27ae60;
        }

        .stat-card.customers {
            border-left: 5px solid #f39c12;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 1rem;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .action-card {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.15);
        }

        .action-icon {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            display: block;
        }

        .action-card h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.3rem;
        }

        .action-card p {
            color: #7f8c8d;
            margin-bottom: 1.5rem;
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .action-btn {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            color: white;
            padding: 0.8rem 2rem;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
        }

        .action-btn.create-bill {
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
        }

        .action-btn.create-bill:hover {
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.4);
        }

        .action-btn.secondary {
            background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
        }

        .action-btn.secondary:hover {
            box-shadow: 0 5px 15px rgba(243, 156, 18, 0.4);
        }

        .recent-activities {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .recent-activities h3 {
            color: #2c3e50;
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .activity-list {
            list-style: none;
        }

        .activity-item {
            padding: 1rem;
            border-bottom: 1px solid #ecf0f1;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            background-color: #3498db;
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .activity-content {
            flex: 1;
        }

        .activity-title {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.25rem;
        }

        .activity-time {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .keyboard-shortcuts {
            background: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 12px;
            margin-top: 2rem;
        }

        .keyboard-shortcuts h4 {
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .shortcuts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .shortcut-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem;
            background-color: rgba(255,255,255,0.1);
            border-radius: 6px;
        }

        .shortcut-key {
            background-color: rgba(255,255,255,0.2);
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-family: monospace;
            font-size: 0.8rem;
        }

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
                padding: 1rem;
            }

            .navbar h1 {
                font-size: 1.5rem;
            }

            .user-welcome {
                align-items: center;
            }

            .container {
                padding: 0 0.5rem;
                margin: 1rem auto;
            }

            .quick-stats {
                grid-template-columns: 1fr;
            }

            .dashboard-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .shortcuts-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Animation for page load */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .stat-card, .action-card, .recent-activities {
            animation: fadeInUp 0.6s ease-out;
        }

        .stat-card:nth-child(1) { animation-delay: 0.1s; }
        .stat-card:nth-child(2) { animation-delay: 0.2s; }
        .stat-card:nth-child(3) { animation-delay: 0.3s; }
        .action-card:nth-child(1) { animation-delay: 0.4s; }
        .action-card:nth-child(2) { animation-delay: 0.5s; }
        .action-card:nth-child(3) { animation-delay: 0.6s; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>
            <span class="cashier-icon">💼</span>
            Cashier Dashboard
        </h1>
        <div class="user-info">
            <div class="user-welcome">
                <div class="user-name">Welcome, <%= loggedUser.getFullName() %></div>
                <div class="user-role">Cashier</div>
            </div>
            <a href="auth?action=logout" class="logout-btn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-section">
            <h2>Ready for Business! ⚡</h2>
            <p>Start processing sales and managing customer transactions</p>
        </div>

        <div class="quick-stats">
            <div class="stat-card sales">
                <div class="stat-icon">💰</div>
                <div class="stat-number" id="todaySales">Rs. 0.00</div>
                <div class="stat-label">Today's Sales</div>
            </div>
            <div class="stat-card bills">
                <div class="stat-icon">🧾</div>
                <div class="stat-number" id="todayBills">0</div>
                <div class="stat-label">Bills Processed</div>
            </div>
            <div class="stat-card customers">
                <div class="stat-icon">👥</div>
                <div class="stat-number" id="totalCustomers">0</div>
                <div class="stat-label">Total Customers</div>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="action-card">
                <span class="action-icon">💳</span>
                <h3>Create New Bill</h3>
                <p>Process customer purchases and generate invoices quickly and efficiently</p>
                <a href="bill?action=create" class="action-btn create-bill">Start Billing</a>
            </div>

            <div class="action-card">
                <span class="action-icon">👥</span>
                <h3>Manage Customers</h3>
                <p>Add new customers, update information, and view customer history</p>
                <a href="customer?action=list" class="action-btn">View Customers</a>
            </div>

            <div class="action-card">
                <span class="action-icon">📦</span>
                <h3>View Inventory</h3>
                <p>Check product availability, prices, and stock levels</p>
                <a href="item?action=list" class="action-btn secondary">Browse Items</a>
            </div>

            <div class="action-card">
                <span class="action-icon">📊</span>
                <h3>View Bills</h3>
                <p>Access transaction history, print receipts, and track payments</p>
                <a href="bill?action=list" class="action-btn secondary">View Bills</a>
            </div>

            <div class="action-card">
                <span class="action-icon">🔍</span>
                <h3>Search & Reports</h3>
                <p>Find customers, items, or bills quickly with powerful search tools</p>
                <a href="javascript:void(0)" onclick="showSearchModal()" class="action-btn">Quick Search</a>
            </div>

            <div class="action-card">
                <span class="action-icon">⚙️</span>
                <h3>Cashier Tools</h3>
                <p>Access cashier-specific tools and utilities for daily operations</p>
                <a href="javascript:void(0)" onclick="showToolsModal()" class="action-btn secondary">Open Tools</a>
            </div>
        </div>

        <div class="recent-activities">
            <h3>
                <span>📈</span>
                Recent Activities
            </h3>
            <ul class="activity-list" id="activityList">
                <li class="activity-item">
                    <div class="activity-icon">💳</div>
                    <div class="activity-content">
                        <div class="activity-title">System Ready</div>
                        <div class="activity-time">Ready to process transactions</div>
                    </div>
                </li>
                <li class="activity-item">
                    <div class="activity-icon">👤</div>
                    <div class="activity-content">
                        <div class="activity-title">Cashier Login</div>
                        <div class="activity-time">Logged in successfully</div>
                    </div>
                </li>
            </ul>
        </div>

        <div class="keyboard-shortcuts">
            <h4>
                <span>⌨️</span>
                Keyboard Shortcuts
            </h4>
            <div class="shortcuts-grid">
                <div class="shortcut-item">
                    <span>New Bill</span>
                    <span class="shortcut-key">Ctrl + N</span>
                </div>
                <div class="shortcut-item">
                    <span>Find Customer</span>
                    <span class="shortcut-key">Ctrl + F</span>
                </div>
                <div class="shortcut-item">
                    <span>View Items</span>
                    <span class="shortcut-key">Ctrl + I</span>
                </div>
                <div class="shortcut-item">
                    <span>Quick Search</span>
                    <span class="shortcut-key">Ctrl + /</span>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize dashboard
            initializeDashboard();
            
            // Setup keyboard shortcuts
            setupKeyboardShortcuts();
            
            // Load statistics (mock data for now)
            loadStatistics();
            
            console.log('Cashier Dashboard initialized successfully');
        });

        function initializeDashboard() {
            // Add current time display
            updateCurrentTime();
            setInterval(updateCurrentTime, 1000);
            
            // Animate numbers
            animateCounters();
        }

        function updateCurrentTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString();
            const dateString = now.toLocaleDateString();
            
            // You can add a time display element if needed
            document.title = `Cashier Dashboard - ${timeString}`;
        }

        function animateCounters() {
            const counters = document.querySelectorAll('.stat-number');
            counters.forEach(counter => {
                const target = parseInt(counter.textContent.replace(/[^\d]/g, '')) || 0;
                const increment = target / 100;
                let current = 0;
                
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        current = target;
                        clearInterval(timer);
                    }
                    
                    if (counter.textContent.includes('Rs.')) {
                        counter.textContent = 'Rs. ' + Math.floor(current).toLocaleString() + '.00';
                    } else {
                        counter.textContent = Math.floor(current).toLocaleString();
                    }
                }, 20);
            });
        }

        function loadStatistics() {
            // Mock data - replace with actual API calls
            setTimeout(() => {
                document.getElementById('todaySales').textContent = 'Rs. 45,250.00';
                document.getElementById('todayBills').textContent = '12';
                document.getElementById('totalCustomers').textContent = '248';
                animateCounters();
            }, 1000);
        }

        function setupKeyboardShortcuts() {
            document.addEventListener('keydown', function(e) {
                if (e.ctrlKey) {
                    switch(e.key) {
                        case 'n':
                            e.preventDefault();
                            window.location.href = 'bill?action=create';
                            break;
                        case 'f':
                            e.preventDefault();
                            window.location.href = 'customer?action=list';
                            break;
                        case 'i':
                            e.preventDefault();
                            window.location.href = 'item?action=list';
                            break;
                        case '/':
                            e.preventDefault();
                            showSearchModal();
                            break;
                    }
                }
            });
        }

        function showSearchModal() {
            const searchTerm = prompt('Quick Search - Enter customer name, item name, or bill number:');
            if (searchTerm && searchTerm.trim()) {
                // Determine search type and redirect
                if (searchTerm.toUpperCase().startsWith('BILL')) {
                    window.location.href = 'bill?action=list&search=' + encodeURIComponent(searchTerm);
                } else if (searchTerm.includes('@') || /^\d+$/.test(searchTerm)) {
                    window.location.href = 'customer?action=search&searchTerm=' + encodeURIComponent(searchTerm);
                } else {
                    window.location.href = 'item?action=search&searchTerm=' + encodeURIComponent(searchTerm);
                }
            }
        }

        function showToolsModal() {
            const tools = [
                'Calculator',
                'Date/Time',
                'Currency Converter',
                'Quick Notes',
                'Print Test'
            ];
            
            const selectedTool = prompt('Select a tool:\n' + tools.map((tool, index) => `${index + 1}. ${tool}`).join('\n'));
            
            if (selectedTool) {
                const toolIndex = parseInt(selectedTool) - 1;
                if (toolIndex >= 0 && toolIndex < tools.length) {
                    switch(toolIndex) {
                        case 0:
                            openCalculator();
                            break;
                        case 1:
                            alert('Current Date/Time: ' + new Date().toLocaleString());
                            break;
                        case 2:
                            openCurrencyConverter();
                            break;
                        case 3:
                            openQuickNotes();
                            break;
                        case 4:
                            window.print();
                            break;
                    }
                }
            }
        }

        function openCalculator() {
            const calculation = prompt('Enter calculation (e.g., 123 + 456):');
            if (calculation) {
                try {
                    const result = eval(calculation.replace(/[^0-9+\-*/.() ]/g, ''));
                    alert(`Result: ${calculation} = ${result}`);
                } catch (e) {
                    alert('Invalid calculation');
                }
            }
        }

        function openCurrencyConverter() {
            const amount = prompt('Enter amount in LKR:');
            if (amount && !isNaN(amount)) {
                // Mock conversion rates
                const usd = (parseFloat(amount) / 320).toFixed(2);
                const eur = (parseFloat(amount) / 350).toFixed(2);
                alert(`LKR ${amount}\n≈ USD ${usd}\n≈ EUR ${eur}`);
            }
        }

        function openQuickNotes() {
            const note = prompt('Quick Note:');
            if (note) {
                const notes = JSON.parse(localStorage.getItem('cashierNotes') || '[]');
                notes.push({
                    text: note,
                    timestamp: new Date().toLocaleString()
                });
                localStorage.setItem('cashierNotes', JSON.stringify(notes));
                alert('Note saved!');
            }
        }

        // Add activity to recent activities
        function addActivity(icon, title, time) {
            const activityList = document.getElementById('activityList');
            const newActivity = document.createElement('li');
            newActivity.className = 'activity-item';
            newActivity.innerHTML = `
                <div class="activity-icon">${icon}</div>
                <div class="activity-content">
                    <div class="activity-title">${title}</div>
                    <div class="activity-time">${time}</div>
                </div>
            `;
            
            activityList.insertBefore(newActivity, activityList.firstChild);
            
            // Keep only latest 5 activities
            while (activityList.children.length > 5) {
                activityList.removeChild(activityList.lastChild);
            }
        }

        // Welcome message
        setTimeout(() => {
            const hour = new Date().getHours();
            let greeting = 'Good morning';
            if (hour >= 12) greeting = 'Good afternoon';
            if (hour >= 18) greeting = 'Good evening';
            
            addActivity('👋', `${greeting}, <%= loggedUser.getFullName() %>!`, 'Just now');
        }, 2000);
    </script>
</body>
</html>