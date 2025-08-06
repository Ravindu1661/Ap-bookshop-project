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
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "book");
    request.setAttribute("pageTitle", "View Book");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Book - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            font-size: 14px;
            line-height: 1.5;
            color: #2c3e50;
            overflow-x: hidden;
        }

        /* Content Area */
        .content-area {
            padding: 1.5rem;
        }

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

        /* Alert Messages */
        .alert {
            padding: 0.8rem 1rem;
            border-radius: 6px;
            margin-bottom: 1.2rem;
            border-left: 4px solid;
            font-size: 0.9rem;
            animation: slideIn 0.3s ease;
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

        /* Book Profile Card */
        .book-profile {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }

        .profile-header {
            background: #007bff;
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 0.8rem;
            font-size: 2.5rem;
        }

        .profile-title {
            font-size: 1.6rem;
            font-weight: 600;
            margin-bottom: 0.4rem;
        }

        .profile-author {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 0.8rem;
        }

        .profile-code {
            font-size: 0.9rem;
            opacity: 0.8;
            display: inline-block;
            padding: 0.4rem 0.8rem;
            border-radius: 15px;
            background-color: rgba(255, 255, 255, 0.2);
        }

        .profile-content {
            padding: 1.5rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .info-section {
            background-color: #f8f9fa;
            padding: 1.2rem;
            border-radius: 8px;
            border-left: 4px solid #007bff;
        }

        .info-section h4 {
            color: #2c3e50;
            margin-bottom: 0.8rem;
            font-size: 1rem;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.8rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e9ecef;
        }

        .info-row:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .info-label {
            font-weight: 500;
            color: #6c757d;
            flex: 1;
            font-size: 0.85rem;
        }

        .info-value {
            color: #2c3e50;
            flex: 2;
            text-align: right;
            font-size: 0.9rem;
        }

        .info-value.empty {
            color: #adb5bd;
            font-style: italic;
        }

        /* Price Display */
        .price {
            font-weight: 600;
            color: #28a745;
            font-size: 1.1rem;
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
            gap: 0.8rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #dee2e6;
        }

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

        .btn-warning {
            background: #ffc107;
            color: #212529;
        }

        .btn-warning:hover {
            background: #e0a800;
        }

        /* Not Found State */
        .not-found {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center;
        }

        .not-found h3 {
            color: #dc3545;
            margin-bottom: 0.8rem;
            font-size: 1.2rem;
        }

        .not-found p {
            color: #6c757d;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
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
            font-size: 0.9rem;
        }

        .description-box.empty {
            color: #adb5bd;
            font-style: italic;
            text-align: center;
            padding: 1.5rem;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .content-area {
                padding: 1rem;
            }

            .page-header {
                padding: 1rem;
            }

            .profile-header {
                padding: 1.2rem;
            }

            .profile-title {
                font-size: 1.3rem;
            }

            .profile-content {
                padding: 1rem;
            }

            .info-grid {
                grid-template-columns: 1fr;
                gap: 0.8rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .info-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.25rem;
            }

            .info-value {
                text-align: left;
            }

            .btn {
                width: 100%;
                margin-bottom: 0.5rem;
            }
        }

        @media (max-width: 480px) {
            .profile-avatar {
                width: 60px;
                height: 60px;
                font-size: 2rem;
            }

            .profile-title {
                font-size: 1.1rem;
            }

            .profile-author {
                font-size: 0.9rem;
            }

            .btn {
                font-size: 0.85rem;
                padding: 0.6rem 1rem;
            }

            .info-section h4 {
                font-size: 0.9rem;
            }

            .info-label,
            .info-value {
                font-size: 0.8rem;
            }
        }

        /* Subtle animations */
        .book-profile,
        .not-found {
            animation: slideUp 0.3s ease-out;
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
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
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
            if (e.key === 'e' || e.key === 'E') {
                const editBtn = document.querySelector('.btn-warning');
                if (editBtn) editBtn.click();
            }
            
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