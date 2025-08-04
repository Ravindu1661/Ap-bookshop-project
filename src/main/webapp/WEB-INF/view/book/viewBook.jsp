<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Book book = (Book) request.getAttribute("book");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Book - Redupahana</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: -280px;
            width: 280px;
            height: 100vh;
            background: #2c3e50;
            transition: left 0.3s ease;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }

        .sidebar.active { left: 0; }

        .sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }

        .sidebar-header h2 {
            color: #fff;
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
        }

        .sidebar-header p {
            color: #bdc3c7;
            font-size: 0.9rem;
        }

        .sidebar-menu { padding: 1rem 0; }

        .menu-item {
            display: block;
            padding: 1rem 1.5rem;
            color: #ecf0f1;
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .menu-item:hover,
        .menu-item.active {
            background-color: rgba(255,255,255,0.1);
            border-left-color: #95a5a6;
            color: #fff;
        }

        .menu-item i {
            margin-right: 0.8rem;
            font-size: 1.1rem;
            width: 20px;
            text-align: center;
        }

        .icon-dashboard::before { content: "📊"; }
        .icon-users::before { content: "👥"; }
        .icon-books::before { content: "📚"; }
        .icon-customers::before { content: "🏢"; }
        .icon-bills::before { content: "🧾"; }
        .icon-logout::before { content: "🚪"; }

        /* Main Content */
        .main-content {
            margin-left: 0;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        /* Top Navigation */
        .topbar {
            background: #fff;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 999;
        }

        .menu-toggle {
            background: #2c3e50;
            color: white;
            border: none;
            padding: 0.8rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s ease;
        }

        .menu-toggle:hover { background: #34495e; }

        .page-title {
            font-size: 1.5rem;
            color: #2c3e50;
            font-weight: 600;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #2c3e50;
        }

        .user-avatar {
            width: 35px;
            height: 35px;
            background: #2c3e50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 0.9rem;
        }

        /* Overlay */
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .overlay.active {
            opacity: 1;
            visibility: visible;
        }

        /* Content Area */
        .content-area { padding: 2rem; }

        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .page-header h1 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .breadcrumb a {
            color: #2c3e50;
            text-decoration: none;
        }

        .breadcrumb a:hover { text-decoration: underline; }

        /* Alert Messages */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #e74c3c;
            color: #721c24;
        }

        /* Book Profile Card */
        .book-profile {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .profile-header {
            background: #2c3e50;
            color: white;
            padding: 2.5rem;
            text-align: center;
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 3rem;
        }

        .profile-title {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .profile-author {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 1rem;
        }

        .profile-code {
            font-size: 1rem;
            opacity: 0.8;
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            background-color: rgba(255, 255, 255, 0.2);
        }

        .profile-content { padding: 2rem; }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .info-section {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid #2c3e50;
        }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e9ecef;
        }

        .info-row:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            flex: 1;
        }

        .info-value {
            color: #2c3e50;
            flex: 2;
            text-align: right;
        }

        .info-value.empty {
            color: #bdc3c7;
            font-style: italic;
        }

        /* Price Display */
        .price {
            font-weight: 600;
            color: #27ae60;
            font-size: 1.2rem;
        }

        /* Stock Badge */
        .stock-badge {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .stock-low {
            background-color: #f8d7da;
            color: #721c24;
        }

        .stock-medium {
            background-color: #fff3cd;
            color: #856404;
        }

        .stock-good {
            background-color: #d4edda;
            color: #155724;
        }

        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.8rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            background-color: #d4edda;
            color: #155724;
        }

        .language-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            background-color: #e8f4fd;
            color: #2c3e50;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 500;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 1rem;
            font-weight: 500;
        }

        .btn-primary {
            background-color: #2c3e50;
            color: white;
        }

        .btn-primary:hover {
            background-color: #34495e;
            transform: translateY(-2px);
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: #7f8c8d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #95a5a6;
            transform: translateY(-2px);
        }

        /* Not Found State */
        .not-found {
            background: white;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            text-align: center;
        }

        .not-found h3 {
            color: #e74c3c;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }

        .not-found p {
            color: #7f8c8d;
            margin-bottom: 2rem;
        }

        /* Description Box */
        .description-box {
            background-color: #fff;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 0.5rem;
            line-height: 1.6;
            color: #2c3e50;
        }

        .description-box.empty {
            color: #bdc3c7;
            font-style: italic;
            text-align: center;
            padding: 2rem;
        }

        /* Responsive Design */
        @media (min-width: 1024px) {
            .sidebar { left: 0; }
            .main-content { margin-left: 280px; }
            .menu-toggle { display: none; }
        }

        @media (max-width: 768px) {
            .topbar { padding: 1rem; }
            .content-area { padding: 1rem; }
            .page-header { padding: 1.5rem; }
            .profile-header { padding: 1.5rem; }
            .profile-title { font-size: 1.5rem; }
            .profile-content { padding: 1rem; }
            .info-grid { grid-template-columns: 1fr; gap: 1rem; }
            .action-buttons { flex-direction: column; }
            .info-row { flex-direction: column; align-items: flex-start; gap: 0.25rem; }
            .info-value { text-align: left; }
            .user-info span { display: none; }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>Redupahana</h2>
            <p>Admin Panel</p>
        </div>
        <nav class="sidebar-menu">
            <a href="dashboard" class="menu-item">
                <i class="icon-dashboard"></i>
                Dashboard
            </a>
            <% if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) { %>
            <a href="user?action=list" class="menu-item">
                <i class="icon-users"></i>
                User Management
            </a>
            <% } %>
            <a href="book?action=list" class="menu-item active">
                <i class="icon-books"></i>
                Book Management
            </a>
            <a href="customer?action=list" class="menu-item">
                <i class="icon-customers"></i>
                Customer Management
            </a>
            <a href="bill?action=list" class="menu-item">
                <i class="icon-bills"></i>
                Bill Management
            </a>
            <a href="auth?action=logout" class="menu-item" style="margin-top: 2rem; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 1rem;">
                <i class="icon-logout"></i>
                Logout
            </a>
        </nav>
    </div>

    <!-- Overlay for mobile -->
    <div class="overlay" id="overlay"></div>

    <!-- Main Content -->
    <div class="main-content" id="mainContent">
        <!-- Top Navigation -->
        <header class="topbar">
            <div style="display: flex; align-items: center; gap: 1rem;">
                <button class="menu-toggle" id="menuToggle">☰</button>
                <h1 class="page-title">Book Details</h1>
            </div>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <span><%= loggedUser.getFullName() %></span>
            </div>
        </header>

        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>📚 Book Details</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="book?action=list">Book Management</a> &gt; 
                    Book Details
                </div>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <% if (book != null) { %>
            <!-- Book Profile -->
            <div class="book-profile">
                <div class="profile-header">
                    <div class="profile-avatar">📖</div>
                    <div class="profile-title"><%= book.getTitle() %></div>
                    <div class="profile-author">by <%= book.getAuthor() %></div>
                    <div class="profile-code">Code: <%= book.getBookCode() %></div>
                </div>

                <div class="profile-content">
                    <div class="info-grid">
                        <div class="info-section">
                            <h4>📋 Basic Information</h4>
                            <div class="info-row">
                                <span class="info-label">Book ID:</span>
                                <span class="info-value">#<%= book.getBookId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Title:</span>
                                <span class="info-value"><%= book.getTitle() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Author:</span>
                                <span class="info-value"><%= book.getAuthor() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Language:</span>
                                <span class="info-value">
                                    <span class="language-badge"><%= book.getLanguage() != null ? book.getLanguage() : "Sinhala" %></span>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="status-badge">Available</span>
                                </span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>💰 Pricing & Stock</h4>
                            <div class="info-row">
                                <span class="info-label">Price:</span>
                                <span class="info-value price">Rs. <%= String.format("%.2f", book.getPrice()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Stock Quantity:</span>
                                <span class="info-value">
                                    <span class="stock-badge <%= 
                                        book.getStockQuantity() == 0 ? "stock-low" :
                                        book.getStockQuantity() <= 5 ? "stock-low" : 
                                        book.getStockQuantity() <= 20 ? "stock-medium" : "stock-good" 
                                    %>">
                                        <%= book.getStockQuantity() %> copies
                                    </span>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Total Value:</span>
                                <span class="info-value price">
                                    Rs. <%= String.format("%.2f", book.getPrice() * book.getStockQuantity()) %>
                                </span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📖 Publication Details</h4>
                            <div class="info-row">
                                <span class="info-label">ISBN:</span>
                                <span class="info-value <%= book.getIsbn() == null || book.getIsbn().trim().isEmpty() ? "empty" : "" %>">
                                    <%= book.getIsbn() != null && !book.getIsbn().trim().isEmpty() ? book.getIsbn() : "Not provided" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Publisher:</span>
                                <span class="info-value <%= book.getPublisher() == null || book.getPublisher().trim().isEmpty() ? "empty" : "" %>">
                                    <%= book.getPublisher() != null && !book.getPublisher().trim().isEmpty() ? book.getPublisher() : "Not provided" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Publication Year:</span>
                                <span class="info-value">
                                    <%= book.getPublicationYear() > 0 ? book.getPublicationYear() : "Not specified" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Pages:</span>
                                <span class="info-value">
                                    <%= book.getPages() > 0 ? book.getPages() + " pages" : "Not specified" %>
                                </span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h4>📅 Timeline</h4>
                            <div class="info-row">
                                <span class="info-label">Added to Library:</span>
                                <span class="info-value"><%= book.getCreatedDate() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Last Updated:</span>
                                <span class="info-value">
                                    <%= book.getUpdatedDate() != null ? book.getUpdatedDate() : "Never updated" %>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Days in Library:</span>
                                <span class="info-value" id="daysInLibrary">Calculating...</span>
                            </div>
                        </div>
                    </div>

                    <!-- Description Section -->
                    <div class="info-section" style="grid-column: 1 / -1;">
                        <h4>📝 Description</h4>
                        <% if (book.getDescription() != null && !book.getDescription().trim().isEmpty()) { %>
                        <div class="description-box">
                            <%= book.getDescription() %>
                        </div>
                        <% } else { %>
                        <div class="description-box empty">
                            No description provided for this book.
                        </div>
                        <% } %>
                    </div>

                    <div class="action-buttons">
                        <a href="book?action=edit&id=<%= book.getBookId() %>" class="btn btn-warning">
                            ✏️ Edit Book
                        </a>
                        <a href="book?action=list" class="btn btn-primary">
                            📚 Back to Library
                        </a>
                    </div>
                </div>
            </div>

            <% } else { %>
            <!-- Book Not Found -->
            <div class="not-found">
                <h3>Book Not Found</h3>
                <p>The requested book could not be found or may have been removed from the library.</p>
                <a href="book?action=list" class="btn btn-primary">Back to Book List</a>
            </div>
            <% } %>
        </main>
    </div>

    <script>
        // Sidebar Toggle
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        function toggleSidebar() {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        menuToggle.addEventListener('click', toggleSidebar);
        overlay.addEventListener('click', toggleSidebar);

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });

        // Calculate days in library
        <% if (book != null) { %>
        const createdDate = new Date('<%= book.getCreatedDate() %>');
        const now = new Date();
        const diffTime = Math.abs(now - createdDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        document.getElementById('daysInLibrary').textContent = diffDays + ' days';
        <% } %>

        // Add loading state to action buttons
        document.querySelectorAll('.btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                if (!this.classList.contains('btn-disabled')) {
                    this.style.opacity = '0.7';
                    this.innerHTML = this.innerHTML + '...';
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // E key for edit
            if (e.key === 'e' || e.key === 'E') {
                const editBtn = document.querySelector('.btn-warning');
                if (editBtn) editBtn.click();
            }
            
            // B key for back
            if (e.key === 'b' || e.key === 'B') {
                const backBtn = document.querySelector('.btn-primary');
                if (backBtn) backBtn.click();
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('View Book page loaded');
        });
    </script>
</body>
</html>