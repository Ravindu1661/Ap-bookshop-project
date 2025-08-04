<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Redupahana</title>
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
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .navbar h1 {
            font-size: 1.5rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .logout-btn {
            background-color: #e74c3c;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9rem;
        }

        .logout-btn:hover {
            background-color: #c0392b;
        }

        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .welcome-section {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .dashboard-card {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease;
        }

        .dashboard-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .dashboard-card i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #3498db;
        }

        .dashboard-card h3 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .dashboard-card p {
            color: #7f8c8d;
            margin-bottom: 1rem;
        }

        .card-link {
            display: inline-block;
            background-color: #3498db;
            color: white;
            padding: 0.7rem 1.5rem;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .card-link:hover {
            background-color: #2980b9;
        }

        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 1rem;
        }

        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .action-btn {
            background-color: #27ae60;
            color: white;
            padding: 0.8rem 1.5rem;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .action-btn:hover {
            background-color: #229954;
        }

        .action-btn.secondary {
            background-color: #f39c12;
        }

        .action-btn.secondary:hover {
            background-color: #e67e22;
        }

        @media (max-width: 768px) {
            .navbar {
                padding: 1rem;
                flex-direction: column;
                gap: 1rem;
            }

            .container {
                padding: 0 0.5rem;
            }

            .dashboard-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
            }
        }

        /* Icon styles */
        .icon-users::before { content: "👥"; }
        .icon-items::before { content: "📦"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Redupahana Admin Dashboard</h1>
        <div class="user-info">
            <span>Welcome, <%= loggedUser.getFullName() %></span>
            <a href="auth?action=logout" class="logout-btn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-section">
            <h2>Welcome to Admin Dashboard</h2>
            <p>Manage your business operations efficiently from this central hub.</p>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card">
                <div class="icon-users"></div>
                <h3>User Management</h3>
                <p>Manage system users and their roles</p>
                <a href="user?action=list" class="card-link">Manage Users</a>
            </div>

            <div class="dashboard-card">
                <div class="icon-items"></div>
                <h3>Item Management</h3>
                <p>Add, edit, and manage inventory items</p>
                <a href="item?action=list" class="card-link">Manage Items</a>
            </div>

            <div class="dashboard-card">
                <div class="icon-customers"></div>
                <h3>Customer Management</h3>
                <p>Manage customer information and accounts</p>
                <a href="customer?action=list" class="card-link">Manage Customers</a>
            </div>

            <div class="dashboard-card">
                <div class="icon-bills"></div>
                <h3>Bill Management</h3>
                <p>View and manage all transactions</p>
                <a href="bill?action=list" class="card-link">View Bills</a>
            </div>
        </div>

        <div class="quick-actions">
            <h2>Quick Actions</h2>
            <div class="action-buttons">
                <a href="customer?action=add" class="action-btn">Add New Customer</a>
                <a href="item?action=add" class="action-btn">Add New Item</a>
                <a href="bill?action=create" class="action-btn secondary">Create New Bill</a>
                <a href="user?action=add" class="action-btn secondary">Add New User</a>
            </div>
        </div>
    </div>

    <script>
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            // Add click effects to cards
            const cards = document.querySelectorAll('.dashboard-card');
            cards.forEach(card => {
                card.addEventListener('click', function(e) {
                    if (!e.target.classList.contains('card-link')) {
                        const link = this.querySelector('.card-link');
                        if (link) {
                            window.location.href = link.href;
                        }
                    }
                });
            });

            // Add loading effect for action buttons
            const actionBtns = document.querySelectorAll('.action-btn, .card-link');
            actionBtns.forEach(btn => {
                btn.addEventListener('click', function() {
                    this.style.opacity = '0.7';
                    this.innerHTML += '...';
                });
            });
        });
    </script>
</body>
</html>