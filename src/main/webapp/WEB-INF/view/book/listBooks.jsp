<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Book> books = (List<Book>) request.getAttribute("books");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Management - Redupahana</title>
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

        .sidebar.active {
            left: 0;
        }

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

        .sidebar-menu {
            padding: 1rem 0;
        }

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

        .menu-toggle:hover {
            background: #34495e;
        }

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

        /* Overlay for mobile */
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
        .content-area {
            padding: 2rem;
        }

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
            margin-bottom: 1rem;
        }

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .breadcrumb a {
            color: #2c3e50;
            text-decoration: none;
        }

        .breadcrumb a:hover {
            text-decoration: underline;
        }

        /* Search & Filter Section */
        .search-section {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .search-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr auto;
            gap: 1rem;
            align-items: end;
        }

        .search-group {
            display: flex;
            flex-direction: column;
        }

        .search-group label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .search-group input,
        .search-group select {
            padding: 0.7rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 0.9rem;
        }

        .search-group input:focus,
        .search-group select:focus {
            outline: none;
            border-color: #2c3e50;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            text-align: center;
            border-left: 4px solid #2c3e50;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        /* Alert Messages */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid;
            animation: slideIn 0.3s ease;
        }

        .alert-success {
            background-color: #d4edda;
            border-left-color: #27ae60;
            color: #155724;
        }

        .alert-error {
            background-color: #f8d7da;
            border-left-color: #e74c3c;
            color: #721c24;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Buttons */
        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 0.9rem;
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

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
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

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
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

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.8rem;
        }

        /* Table Styles */
        .table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
        }

        .table-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-header h2 {
            color: #2c3e50;
            font-size: 1.3rem;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th,
        .table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        /* Stock Status */
        .stock-status {
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

        .price {
            font-weight: 600;
            color: #27ae60;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state h3 {
            margin-bottom: 1rem;
            color: #2c3e50;
        }

        /* Language Badge */
        .language-badge {
            display: inline-block;
            padding: 0.2rem 0.6rem;
            background-color: #e8f4fd;
            color: #2c3e50;
            border-radius: 10px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        /* Responsive Design */
        @media (min-width: 1024px) {
            .sidebar {
                left: 0;
            }
            
            .main-content {
                margin-left: 280px;
            }
            
            .menu-toggle {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .topbar {
                padding: 1rem;
            }
            
            .content-area {
                padding: 1rem;
            }
            
            .page-header {
                padding: 1.5rem;
            }
            
            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-row {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .table-container {
                overflow-x: auto;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .user-info span {
                display: none;
            }
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
                <h1 class="page-title">Book Management</h1>
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
                <h1>📚 Book Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Book Management
                </div>
                <div class="header-actions">
                    <a href="book?action=add" class="btn btn-success">➕ Add New Book</a>
                </div>
            </div>

            <!-- Search & Filter Section -->
            <div class="search-section">
                <form action="book" method="get" id="searchForm">
                    <div class="search-row">
                        <div class="search-group">
                            <label for="searchTerm">Search Books</label>
                            <input type="text" name="searchTerm" id="searchTerm" 
                                   placeholder="Search by title, author, ISBN, or publisher..." 
                                   value="<%= searchTerm != null ? searchTerm : "" %>">
                        </div>
                        <div class="search-group">
                            <label for="searchAuthor">Filter by Author</label>
                            <input type="text" name="author" id="searchAuthor" 
                                   placeholder="Author name...">
                        </div>
                        <div class="search-group">
                            <label for="searchLanguage">Filter by Language</label>
                            <select name="language" id="searchLanguage">
                                <option value="">All Languages</option>
                                <option value="Sinhala">Sinhala</option>
                                <option value="English">English</option>
                                <option value="Tamil">Tamil</option>
                            </select>
                        </div>
                        <div class="search-group">
                            <button type="button" class="btn btn-primary" onclick="performSearch()">🔍 Search</button>
                            <% if (searchTerm != null) { %>
                            <a href="book?action=list" class="btn btn-secondary" style="margin-top: 0.5rem;">❌ Clear</a>
                            <% } %>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Stats Cards -->
            <%
                int totalBooks = 0;
                int lowStockBooks = 0;
                int outOfStockBooks = 0;
                
                if (books != null) {
                    totalBooks = books.size();
                    for (Book book : books) {
                        if (book.getStockQuantity() == 0) {
                            outOfStockBooks++;
                        } else if (book.getStockQuantity() <= 5) {
                            lowStockBooks++;
                        }
                    }
                }
            %>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= totalBooks %></h3>
                    <p>Total Books</p>
                </div>
                <div class="stat-card">
                    <h3><%= lowStockBooks %></h3>
                    <p>Low Stock Books</p>
                </div>
                <div class="stat-card">
                    <h3><%= outOfStockBooks %></h3>
                    <p>Out of Stock</p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success" id="successAlert">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="alert alert-error" id="errorAlert">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Books Table -->
            <div class="table-container">
                <div class="table-header">
                    <h2>Library Inventory</h2>
                    <% if (searchTerm != null) { %>
                    <span style="color: #7f8c8d; font-size: 0.9rem;">Search results for: "<%= searchTerm %>"</span>
                    <% } %>
                </div>

                <% if (books != null && !books.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Book Code</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Language</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Publisher</th>
                            <th>Year</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Book book : books) { %>
                        <tr>
                            <td><strong><%= book.getBookCode() %></strong></td>
                            <td>
                                <strong><%= book.getTitle() %></strong>
                                <% if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) { %>
                                <br><small style="color: #7f8c8d;">ISBN: <%= book.getIsbn() %></small>
                                <% } %>
                            </td>
                            <td><%= book.getAuthor() %></td>
                            <td>
                                <span class="language-badge"><%= book.getLanguage() != null ? book.getLanguage() : "Sinhala" %></span>
                            </td>
                            <td class="price">Rs. <%= String.format("%.2f", book.getPrice()) %></td>
                            <td>
                                <span class="stock-status <%= 
                                    book.getStockQuantity() == 0 ? "stock-low" :
                                    book.getStockQuantity() <= 5 ? "stock-low" : 
                                    book.getStockQuantity() <= 20 ? "stock-medium" : "stock-good" 
                                %>">
                                    <%= book.getStockQuantity() %> copies
                                </span>
                            </td>
                            <td><%= book.getPublisher() != null ? book.getPublisher() : "-" %></td>
                            <td><%= book.getPublicationYear() > 0 ? book.getPublicationYear() : "-" %></td>
                            <td>
                                <div class="action-buttons">
                                    <a href="book?action=view&id=<%= book.getBookId() %>" 
                                       class="btn btn-primary btn-sm">👁️ View</a>
                                    <a href="book?action=edit&id=<%= book.getBookId() %>" 
                                       class="btn btn-warning btn-sm">✏️ Edit</a>
                                    <a href="book?action=delete&id=<%= book.getBookId() %>" 
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirmDelete('<%= book.getTitle() %>', '<%= book.getAuthor() %>')">🗑️ Delete</a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <h3>No Books Found</h3>
                    <p>
                        <% if (searchTerm != null) { %>
                        No books match your search criteria for "<%= searchTerm %>".
                        <% } else { %>
                        Start by adding your first book to the library.
                        <% } %>
                    </p>
                    <a href="book?action=add" class="btn btn-success" style="margin-top: 1rem;">📚 Add Book</a>
                </div>
                <% } %>
            </div>
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

        // Search Functions
        function performSearch() {
            const form = document.getElementById('searchForm');
            const searchTerm = document.getElementById('searchTerm').value.trim();
            const author = document.getElementById('searchAuthor').value.trim();
            const language = document.getElementById('searchLanguage').value;

            if (searchTerm) {
                form.action = 'book?action=search';
                form.submit();
            } else if (author) {
                form.action = 'book?action=searchByAuthor';
                form.submit();
            } else if (language) {
                form.action = 'book?action=searchByLanguage';
                form.submit();
            } else {
                window.location.href = 'book?action=list';
            }
        }

        // Confirm delete function
        function confirmDelete(title, author) {
            return confirm('Are you sure you want to delete the book "' + title + '" by ' + author + '? This action cannot be undone.');
        }

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.opacity = '0';
                alert.style.transform = 'translateY(-10px)';
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 300);
            });
        }, 5000);

        // Add loading states to buttons
        document.querySelectorAll('.btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                if (!this.onclick && !this.href.includes('delete')) {
                    this.style.opacity = '0.7';
                    this.innerHTML = this.innerHTML + '...';
                }
            });
        });

        // Enter key search
        document.getElementById('searchTerm').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                performSearch();
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Book Management page loaded');
        });
    </script>
</body>
</html>