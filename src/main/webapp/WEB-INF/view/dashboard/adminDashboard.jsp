<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "dashboard");
    request.setAttribute("pageTitle", "Dashboard");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Redupahana</title>
    
    <!-- Dashboard-specific styles -->
    <style>
        /* Dashboard Welcome Section */
        .welcome-section {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 2.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            text-align: center;
            box-shadow: 0 4px 15px rgba(44, 62, 80, 0.2);
        }

        .welcome-section h1 {
            font-size: 2.2rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .welcome-section p {
            opacity: 0.9;
            font-size: 1.1rem;
            margin-bottom: 0;
        }

        /* Enhanced Dashboard Stats Cards */
        .dashboard-stat-card {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            cursor: pointer;
            border-left: 4px solid #007bff;
            position: relative;
            overflow: hidden;
        }

        .dashboard-stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, rgba(0, 123, 255, 0.1), transparent);
            border-radius: 0 0 0 80px;
        }

        .dashboard-stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            border-left-color: #0056b3;
        }

        .stat-card-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin-bottom: 1rem;
            background: #f8f9fa;
            color: #2c3e50;
        }

        .dashboard-stat-card h3 {
            color: #2c3e50;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .dashboard-stat-card p {
            color: #6c757d;
            margin-bottom: 1.5rem;
            line-height: 1.5;
            font-size: 0.9rem;
        }

        .card-link {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: #007bff;
            color: white;
            padding: 0.8rem 1.8rem;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            box-shadow: 0 2px 6px rgba(0, 123, 255, 0.3);
        }

        .card-link:hover {
            background: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.4);
        }

        /* Quick Actions Section */
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-top: 1.5rem;
        }

        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 1.5rem;
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1rem;
        }

        .action-btn {
            background: #007bff;
            color: white;
            padding: 1rem 1.5rem;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            box-shadow: 0 2px 6px rgba(0, 123, 255, 0.3);
        }

        .action-btn:hover {
            background: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.4);
        }

        .action-btn.secondary {
            background: #6c757d;
            box-shadow: 0 2px 6px rgba(108, 117, 125, 0.3);
        }

        .action-btn.secondary:hover {
            background: #545b62;
            box-shadow: 0 4px 12px rgba(108, 117, 125, 0.4);
        }

        .action-btn.success {
            background: #28a745;
            box-shadow: 0 2px 6px rgba(40, 167, 69, 0.3);
        }

        .action-btn.success:hover {
            background: #1e7e34;
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
        }

        .action-btn.warning {
            background: #ffc107;
            color: #212529;
            box-shadow: 0 2px 6px rgba(255, 193, 7, 0.3);
        }

        .action-btn.warning:hover {
            background: #e0a800;
            box-shadow: 0 4px 12px rgba(255, 193, 7, 0.4);
        }

        /* System Status Info */
        .system-info {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-top: 1.5rem;
        }

        .system-info h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .info-item {
            padding: 0.8rem;
            background: #f8f9fa;
            border-radius: 6px;
            border-left: 3px solid #007bff;
        }

        .info-label {
            font-size: 0.8rem;
            color: #6c757d;
            margin-bottom: 0.3rem;
        }

        .info-value {
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.9rem;
        }

        /* Loading Animation for Cards */
        .dashboard-stat-card.loading {
            opacity: 0;
            transform: translateY(20px);
            animation: slideInUp 0.6s ease forwards;
        }

        @keyframes slideInUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .welcome-section {
                padding: 1.5rem;
            }
            
            .welcome-section h1 {
                font-size: 1.8rem;
            }
            
            .quick-actions,
            .system-info {
                padding: 1.5rem;
            }
            
            .action-buttons {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <h1>🎯 Welcome Back, <%= loggedUser.getFullName() %></h1>
                <p>Manage your business operations efficiently from this central hub</p>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="dashboard-stat-card" onclick="navigateTo('user?action=list')">
                    <div class="stat-card-icon">👥</div>
                    <h3>User Management</h3>
                    <p>Manage system users, roles, and permissions. Add new users and control access levels.</p>
                    <a href="user?action=list" class="card-link">👥 Manage Users</a>
                </div>

                <div class="dashboard-stat-card" onclick="navigateTo('book?action=list')">
                    <div class="stat-card-icon">📚</div>
                    <h3>Book Management</h3>
                    <p>Add, edit, and manage your book inventory. Track stock levels and book information.</p>
                    <a href="book?action=list" class="card-link">📚 Manage Books</a>
                </div>

                <div class="dashboard-stat-card" onclick="navigateTo('customer?action=list')">
                    <div class="stat-card-icon">🏢</div>
                    <h3>Customer Management</h3>
                    <p>Manage customer information, accounts, and maintain client relationships effectively.</p>
                    <a href="customer?action=list" class="card-link">🏢 Manage Customers</a>
                </div>

                <div class="dashboard-stat-card" onclick="navigateTo('bill?action=list')">
                    <div class="stat-card-icon">🧾</div>
                    <h3>Bill Management</h3>
                    <p>View, create, and manage all transactions. Generate reports and track payments.</p>
                    <a href="bill?action=list" class="card-link">🧾 View Bills</a>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions">
                <h2>⚡ Quick Actions</h2>
                <div class="action-buttons">
                    <a href="customer?action=add" class="action-btn success">➕ Add New Customer</a>
                    <a href="book?action=add" class="action-btn success">📚 Add New Book</a>
                    <a href="bill?action=create" class="action-btn warning">🧾 Create New Bill</a>
                    <a href="user?action=add" class="action-btn secondary">👤 Add New User</a>
                </div>
            </div>

            <!-- System Information -->
            <div class="system-info">
                <h3>📊 System Information</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Current User</div>
                        <div class="info-value">👤 <%= loggedUser.getFullName() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">User Role</div>
                        <div class="info-value">👑 <%= loggedUser.getRole() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">System Status</div>
                        <div class="info-value">✅ Online</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Last Login</div>
                        <div class="info-value">🕐 <%= new java.util.Date().toString().substring(0, 16) %></div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Dashboard-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🎯 Admin Dashboard Loaded Successfully');
            console.log('Current user: <%= loggedUser.getFullName() %>');
            console.log('User role: <%= loggedUser.getRole() %>');
            
            // Card navigation function
            window.navigateTo = function(url) {
                window.location.href = url;
            };
            
            // Add loading effect to cards on page load
            const cards = document.querySelectorAll('.dashboard-stat-card');
            cards.forEach((card, index) => {
                card.classList.add('loading');
                // Remove loading class and add animation delay
                setTimeout(() => {
                    card.classList.remove('loading');
                    card.style.animationDelay = (index * 100) + 'ms';
                }, 100);
            });
            
            // Add keyboard navigation shortcuts
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
                
                // Ctrl+N for new bill
                if (e.ctrlKey && e.key === 'n') {
                    e.preventDefault();
                    window.location.href = 'bill?action=create';
                }
            });
            
            console.log('💡 Shortcuts: Alt+1=Users, Alt+2=Books, Alt+3=Customers, Alt+4=Bills, Ctrl+N=New Bill');
        });
    </script>
</body>
</html>