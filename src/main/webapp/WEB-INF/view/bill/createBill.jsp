<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Book> books = (List<Book>) request.getAttribute("books");
    List<String> bookCategories = (List<String>) request.getAttribute("bookCategories");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    String preSelectedCustomerId = request.getParameter("customerId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS System - Create Bill | Redupahana</title>
</head>
<body>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            color: #2c3e50;
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1400px;
            margin: 0 auto;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .back-btn {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            background: rgba(255,255,255,0.2);
            border-radius: 6px;
            transition: background 0.3s;
        }

        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        .store-title {
            font-size: 1.5rem;
            font-weight: 700;
        }

        .subtitle {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        /* Main Container */
        .main-container {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 1.5rem;
            max-width: 1400px;
            margin: 1.5rem auto;
            padding: 0 1rem;
            min-height: calc(100vh - 100px);
        }

        /* Left Panel - Products */
        .left-panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
        }

        .panel-header {
            background: #f8f9fa;
            padding: 1.5rem;
            border-bottom: 1px solid #dee2e6;
        }

        .panel-header h2 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .panel-header p {
            color: #6c757d;
            font-size: 0.9rem;
        }

        /* Customer Section */
        .customer-section {
            padding: 1.5rem;
            background: #fff;
            border-bottom: 1px solid #dee2e6;
        }

        .customer-controls {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
        }

        .form-group {
            flex: 1;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #374151;
        }

        .required {
            color: #ef4444;
        }

        .customer-search {
            position: relative;
        }

        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #d1d5db;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 1px solid #d1d5db;
            border-top: none;
            border-radius: 0 0 8px 8px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
        }

        .search-result-item {
            padding: 0.75rem;
            border-bottom: 1px solid #f3f4f6;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .search-result-item:hover {
            background: #f8f9fa;
        }

        .search-result-item:last-child {
            border-bottom: none;
        }

        .add-customer-btn, .show-customers-btn, .unselect-customer-btn {
            padding: 0.75rem 1.5rem;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s;
            white-space: nowrap;
        }

        .add-customer-btn {
            background: #10b981;
        }

        .add-customer-btn:hover {
            background: #059669;
        }

        .show-customers-btn {
            background: #3b82f6;
            margin-left: 0.5rem;
        }

        .show-customers-btn:hover {
            background: #2563eb;
        }

        .unselect-customer-btn {
            background: #ef4444;
            margin-left: 0.5rem;
        }

        .unselect-customer-btn:hover:not(:disabled) {
            background: #dc2626;
        }

        .unselect-customer-btn:disabled {
            background: #f87171;
            cursor: not-allowed;
            opacity: 0.6;
        }

        /* Category Filter Section */
        .category-filter {
            padding: 1rem 1.5rem;
            background: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
        }

        .filter-controls {
            display: flex;
            gap: 1rem;
            align-items: center;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .filter-group label {
            font-weight: 600;
            color: #374151;
            font-size: 0.9rem;
        }

        .category-select {
            padding: 0.5rem;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 0.9rem;
            background: white;
        }

        .reset-filters-btn {
            padding: 0.5rem 1rem;
            background: #6b7280;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background 0.3s;
        }

        .reset-filters-btn:hover {
            background: #4b5563;
        }

        /* Product Search */
        .product-search {
            padding: 1rem 1.5rem;
        }

        .search-input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #d1d5db;
            border-radius: 8px;
            font-size: 0.95rem;
        }

        /* Products Table */
        .products-table-container {
            max-height: 500px;
            overflow-y: auto;
        }

        .products-table {
            width: 100%;
            border-collapse: collapse;
        }

        .products-table th {
            background: #f8f9fa;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #dee2e6;
            position: sticky;
            top: 0;
        }

        .products-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #f3f4f6;
        }

        .products-table tbody tr {
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .products-table tbody tr:hover {
            background: #f8f9fa;
        }

        .products-table tbody tr.selected {
            background: #dbeafe;
        }

        /* Book Image & Category Styles */
        .book-image {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #e5e7eb;
        }

        .book-image-placeholder {
            width: 40px;
            height: 40px;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: #9ca3af;
        }

        .book-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .book-details {
            flex: 1;
        }

        .book-title {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }

        .book-meta {
            font-size: 0.8rem;
            color: #6b7280;
        }

        .category-badge {
            display: inline-block;
            padding: 0.2rem 0.5rem;
            background: #e0e7ff;
            color: #3730a3;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
            margin-right: 0.5rem;
        }

        .price-cell {
            font-weight: 600;
            color: #059669;
        }

        .stock-badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .stock-badge.high {
            background: #dcfce7;
            color: #166534;
        }

        .stock-badge.medium {
            background: #fef3c7;
            color: #92400e;
        }

        .stock-badge.low {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Right Panel - Bill */
        .right-panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .bill-header {
            background: #f8f9fa;
            padding: 1.5rem;
            border-bottom: 1px solid #dee2e6;
        }

        .bill-header h2 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .bill-number {
            color: #6c757d;
            font-weight: 600;
        }

        .bill-items {
            flex: 1;
            padding: 1rem;
            min-height: 300px;
            overflow-y: auto;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #6c757d;
        }

        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .bill-item {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 0.75rem;
            border-left: 4px solid #3b82f6;
        }

        .bill-item-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.75rem;
        }

        .bill-item-info {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            flex: 1;
        }

        .bill-item-image {
            width: 35px;
            height: 35px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #e5e7eb;
            flex-shrink: 0;
        }

        .bill-item-image-placeholder {
            width: 35px;
            height: 35px;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            color: #9ca3af;
            flex-shrink: 0;
        }

        .bill-item-text h4 {
            color: #1f2937;
            margin-bottom: 0.25rem;
            font-size: 0.95rem;
        }

        .bill-item-details {
            color: #6b7280;
            font-size: 0.8rem;
        }

        .item-total {
            font-weight: 700;
            color: #059669;
            font-size: 1rem;
        }

        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .qty-btn {
            width: 30px;
            height: 30px;
            border: 1px solid #d1d5db;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            transition: background 0.2s;
        }

        .qty-btn:hover {
            background: #f3f4f6;
        }

        .qty-input {
            width: 50px;
            text-align: center;
            padding: 0.25rem;
            border: 1px solid #d1d5db;
            border-radius: 4px;
        }

        .remove-btn {
            background: #ef4444;
            color: white;
            border: none;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
        }

        .remove-btn:hover {
            background: #dc2626;
        }

        /* Bill Totals */
        .bill-totals {
            padding: 1rem;
            border-top: 1px solid #dee2e6;
            background: #f8f9fa;
        }

        .discount-section {
            margin-bottom: 1rem;
        }

        .discount-input {
            display: flex;
            gap: 0.5rem;
        }

        .discount-input .form-control {
            flex: 1;
        }

        .apply-discount-btn {
            padding: 0.5rem 1rem;
            background: #6366f1;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9rem;
        }

        .apply-discount-btn:hover {
            background: #5b21b6;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            padding: 0.25rem 0;
        }

        .total-row.final {
            border-top: 2px solid #dee2e6;
            padding-top: 0.75rem;
            margin-top: 0.75rem;
            font-size: 1.1rem;
            font-weight: 700;
            color: #059669;
        }

        /* Action Buttons */
        .action-buttons {
            padding: 1rem;
            border-top: 1px solid #dee2e6;
            display: flex;
            gap: 0.75rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s;
        }

        .btn-success {
            background: #059669;
            color: white;
            flex: 1;
        }

        .btn-success:hover {
            background: #047857;
            transform: translateY(-1px);
        }

        .btn-clear {
            background: #6b7280;
            color: white;
        }

        .btn-clear:hover {
            background: #4b5563;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow: hidden;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }

        .modal-header {
            background: #f8f9fa;
            padding: 1.5rem;
            border-bottom: 1px solid #dee2e6;
        }

        .modal-header h3 {
            color: #1f2937;
            margin-bottom: 0.5rem;
        }

        .modal-header p {
            color: #6b7280;
            font-size: 0.9rem;
        }

        .modal-body {
            padding: 1.5rem;
            max-height: 60vh;
            overflow-y: auto;
        }

        .modal-actions {
            padding: 1rem 1.5rem;
            border-top: 1px solid #dee2e6;
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        /* Customer Table Modal */
        .customers-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 1rem;
        }

        .customers-table th {
            background: #f8f9fa;
            padding: 0.75rem;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        .customers-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #f3f4f6;
        }

        .customers-table tbody tr {
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .customers-table tbody tr:hover {
            background: #f8f9fa;
        }

        .customer-modal-search {
            margin-bottom: 1rem;
        }

        /* Form Grid for Add Customer */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .input-group {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: #6b7280;
            font-size: 1rem;
            z-index: 10;
        }

        .input-group .form-control {
            padding-left: 3rem;
        }

        .input-group textarea.form-control {
            padding-left: 3rem;
            resize: vertical;
        }

        /* Alerts */
        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
            font-weight: 500;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }

        /* Loading States */
        .loading {
            opacity: 0.7;
            cursor: not-allowed;
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .main-container {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .right-panel {
                order: -1;
                min-height: auto;
            }
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 1rem;
            }

            .customer-controls {
                flex-direction: column;
                align-items: stretch;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .filter-controls {
                flex-direction: column;
                align-items: stretch;
            }

            .book-info {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
    <header class="header">
        <div class="header-content">
            <div class="header-left">
                <a href="bill?action=list" class="back-btn">
                    ← Back to Bills
                </a>
                <div>
                    <div class="store-title">🏪 Redupahana POS System</div>
                    <div class="subtitle">Create New Bill</div>
                </div>
            </div>
            <div class="user-info">
                <div class="user-avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <div>
                    <div style="font-weight: 600;"><%= loggedUser.getFullName() %></div>
                    <div style="font-size: 0.8rem; color: rgba(255,255,255,0.8);"><%= loggedUser.getRole() %></div>
                </div>
            </div>
        </div>
    </header>

    <% if (successMessage != null) { %>
    <div class="alert alert-success">
        ✅ <%= successMessage %>
    </div>
    <% } %>

    <% if (errorMessage != null) { %>
    <div class="alert alert-error">
        ❌ <%= errorMessage %>
    </div>
    <% } %>

    <div class="main-container">
        <div class="left-panel">
            <div class="panel-header">
                <h2>🛍️ Product Selection</h2>
                <p>Choose customer and products for billing</p>
            </div>

            <div class="customer-section">
                <div class="customer-controls">
                    <div class="form-group">
                        <label for="customerSearch">👤 Search & Select Customer <span class="required">*</span></label>
                        <div class="customer-search">
                            <input type="text" class="form-control" id="customerSearch" 
                                   placeholder="Type customer name or phone number..." 
                                   onkeyup="searchCustomers(this.value)" 
                                   onfocus="showCustomerSearch()" 
                                   onblur="hideCustomerSearch()">
                            <div class="search-results" id="customerSearchResults"></div>
                        </div>
                        <input type="hidden" id="selectedCustomerId" name="customerId">
                        <div id="selectedCustomerInfo" style="margin-top: 0.5rem; font-size: 0.9rem; color: #059669; font-weight: 500;"></div>
                    </div>
                    <button type="button" class="show-customers-btn" onclick="openCustomerTableModal()">
                        📋 Show All
                    </button>
                    <button type="button" class="add-customer-btn" onclick="openAddCustomerModal()">
                        ➕ Add New
                    </button>
                    <button type="button" class="unselect-customer-btn" id="unselectCustomerBtn" onclick="unselectCustomer()" disabled>
                        ❌ Unselect
                    </button>
                </div>
            </div>

            <div class="category-filter">
                <div class="filter-controls">
                    <div class="form-group">
                        <label for="categoryFilter">📚 Category:</label>
                        <select id="categoryFilter" class="category-select" onchange="filterByCategory(this.value)">
                            <option value="">All Categories</option>
                            <% if (bookCategories != null && !bookCategories.isEmpty()) {
                                for (String category : bookCategories) { %>
                            <option value="<%= category %>"><%= category %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="stockFilter">📦 Stock:</label>
                        <select id="stockFilter" class="category-select" onchange="filterByStock(this.value)">
                            <option value="">All Stock</option>
                            <option value="available">Available Only</option>
                            <option value="low">Low Stock (≤5)</option>
                            <option value="high">High Stock (>10)</option>
                        </select>
                    </div>
                    <button type="button" class="reset-filters-btn" onclick="resetFilters()">
                        🔄 Reset
                    </button>
                </div>
            </div>

            <div class="product-search">
                <input type="text" class="search-input" placeholder="🔍 Search products by title, author, or ISBN..." 
                       onkeyup="searchProducts(this.value)">
            </div>

            <div class="products-table-container">
                <table class="products-table" id="productsTable">
                    <thead>
                        <tr>
                            <th>Book Details</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="productsTableBody">
                        <% if (books != null && !books.isEmpty()) {
                            for (Book book : books) { %>
                        <tr onclick="selectProduct(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>', '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>', <%= book.getPrice() %>, <%= book.getStockQuantity() %>, '<%= book.getImagePath() != null ? book.getImagePath().replace("'", "\\'") : "" %>', '<%= book.getBookCategory() != null ? book.getBookCategory().replace("'", "\\'") : "" %>')">
                            <td>
                                <div class="book-info">
                                    <% if (book.getImagePath() != null && !book.getImagePath().trim().isEmpty()) { %>
                                    <img src="<%= request.getContextPath() %>/<%= book.getImagePath() %>" 
                                         alt="<%= book.getTitle() %>" class="book-image" 
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="book-image-placeholder" style="display: none;">📚</div>
                                    <% } else { %>
                                    <div class="book-image-placeholder">📚</div>
                                    <% } %>
                                    <div class="book-details">
                                        <div class="book-title"><%= book.getTitle() %></div>
                                        <div class="book-meta">
                                            <% if (book.getBookCategory() != null && !book.getBookCategory().trim().isEmpty()) { %>
                                            <span class="category-badge"><%= book.getBookCategory() %></span>
                                            <% } %>
                                            <% if (book.getAuthor() != null && !book.getAuthor().trim().isEmpty()) { %>
                                            by <%= book.getAuthor() %>
                                            <% } %>
                                            <% if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) { %>
                                            • ISBN: <%= book.getIsbn() %>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td class="price-cell">Rs. <%= String.format("%.2f", book.getPrice()) %></td>
                            <td>
                                <span class="stock-badge <%= book.getStockQuantity() > 10 ? "high" : (book.getStockQuantity() > 5 ? "medium" : "low") %>">
                                    <%= book.getStockQuantity() %>
                                </span>
                            </td>
                            <td>
                                <button type="button" class="btn btn-sm" style="background: #059669; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
                                        onclick="event.stopPropagation(); addProductToBill(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>', '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>', <%= book.getPrice() %>, <%= book.getStockQuantity() %>, '<%= book.getImagePath() != null ? book.getImagePath().replace("'", "\\'") : "" %>', '<%= book.getBookCategory() != null ? book.getBookCategory().replace("'", "\\'") : "" %>')">
                                    Add
                                </button>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="4" class="empty-state">
                                <div class="empty-state-icon">📚</div>
                                <h3>No Products Available</h3>
                                <p>Please add products to inventory first</p>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="right-panel">
            <div class="bill-header">
                <h2>🧾 Current Bill</h2>
                <div class="bill-number">Bill #<span id="billNumber"><%= System.currentTimeMillis() %></span></div>
            </div>

            <div class="bill-items" id="billItems">
                <div class="empty-state">
                    <div class="empty-state-icon">🛒</div>
                    <h3>No Items Added</h3>
                    <p>Select products to add them to the bill</p>
                </div>
            </div>

            <div class="bill-totals">
                <div class="discount-section">
                    <div class="form-group">
                        <label for="discount">💰 Discount (Rs.)</label>
                        <div class="discount-input">
                            <input type="number" class="form-control" id="discount" name="discount" 
                                   value="0" min="0" step="0.01" placeholder="0.00">
                            <button type="button" class="apply-discount-btn" onclick="calculateTotals()">Apply</button>
                        </div>
                    </div>
                </div>

                <div class="total-row">
                    <span>Subtotal:</span>
                    <span id="subTotal">Rs. 0.00</span>
                </div>
                <div class="total-row">
                    <span>Discount:</span>
                    <span id="discountAmount">Rs. 0.00</span>
                </div>
                <div class="total-row">
                    <span>Tax (5%):</span>
                    <span id="taxAmount">Rs. 0.00</span>
                </div>
                <div class="total-row final">
                    <span>💳 TOTAL:</span>
                    <span id="totalAmount">Rs. 0.00</span>
                </div>
            </div>

            <div class="action-buttons">
                <button type="button" class="btn btn-success" onclick="createBill()" id="createBillBtn">
                    ✅ Create Bill
                </button>
                <button type="button" class="btn btn-clear" onclick="clearBill()">
                    🗑️ Clear All
                </button>
            </div>
        </div>
    </div>

    <div class="modal" id="customerTableModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>📋 Select Customer</h3>
                <p>Choose a customer from the list below</p>
            </div>
            <div class="modal-body">
                <div class="customer-modal-search">
                    <input type="text" class="form-control" id="customerTableSearch" 
                           placeholder="🔍 Search by name or phone..." 
                           onkeyup="searchCustomerTable(this.value)">
                </div>
                <div style="max-height: 400px; overflow-y: auto;">
                    <table class="customers-table" id="customersTable">
                        <thead>
                            <tr>
                                <th>Account Number</th>
                                <th>Name</th>
                                <th>Phone</th>
                                <th>Email</th>
                            </tr>
                        </thead>
                        <tbody id="customersTableBody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-clear" onclick="closeCustomerTableModal()">❌ Close</button>
            </div>
        </div>
    </div>

    <div class="modal" id="addCustomerModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>➕ Add New Customer</h3>
                <p>Fill in customer details to add them to the system</p>
            </div>
            
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="newCustomerName">Customer Name <span class="required">*</span></label>
                        <div class="input-group">
                            <span class="input-icon">👤</span>
                            <input type="text" class="form-control" id="newCustomerName" name="name" required 
                                   placeholder="Enter customer full name">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newCustomerPhone">Phone Number <span class="required">*</span></label>
                        <div class="input-group">
                            <span class="input-icon">📞</span>
                            <input type="tel" class="form-control" id="newCustomerPhone" name="phone" required 
                                   placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newCustomerEmail">Email Address</label>
                        <div class="input-group">
                            <span class="input-icon">📧</span>
                            <input type="email" class="form-control" id="newCustomerEmail" name="email"
                                   placeholder="Enter email address (optional)">
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label for="newCustomerAddress">Address</label>
                        <div class="input-group">
                            <span class="input-icon">🏠</span>
                            <textarea class="form-control" id="newCustomerAddress" name="address" rows="3" 
                                      placeholder="Enter customer address (optional)"></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-success" id="addCustomerBtn" onclick="addNewCustomer()">✅ Add Customer</button>
                <button type="button" class="btn btn-clear" onclick="closeAddCustomerModal()">❌ Cancel</button>
            </div>
        </div>
    </div>

    <iframe name="customerFrame" style="display: none;" onload="handleCustomerFormResponse()"></iframe>
    <form action="bill" method="post" id="createBillForm" style="display: none;">
        <input type="hidden" name="action" value="create">
        <input type="hidden" name="customerId" id="hiddenCustomerId">
        <input type="hidden" name="discount" id="hiddenDiscount">
        <div id="hiddenInputs"></div>
    </form>

    <script>
        let billItems = [];
        let allProducts = [];
        let filteredProducts = [];
        let allCustomers = [];
        let customerSearchTimeout;

        <% if (books != null) { %>
        allProducts = [
            <% for (int i = 0; i < books.size(); i++) {
                Book book = books.get(i); %>
            {
                id: <%= book.getBookId() %>,
                title: '<%= book.getTitle().replace("'", "\\'") %>',
                author: '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>',
                price: <%= book.getPrice() %>,
                stock: <%= book.getStockQuantity() %>,
                isbn: '<%= book.getIsbn() != null ? book.getIsbn() : "" %>',
                imagePath: '<%= request.getContextPath() %>/<%= book.getImagePath() != null ? book.getImagePath().replace("'", "\\'") : "" %>',
                category: '<%= book.getBookCategory() != null ? book.getBookCategory().replace("'", "\\'") : "" %>',
                language: '<%= book.getLanguage() != null ? book.getLanguage() : "" %>',
                publisher: '<%= book.getPublisher() != null ? book.getPublisher().replace("'", "\\'") : "" %>'
            }<%= i < books.size() - 1 ? "," : "" %>
            <% } %>
        ];
        <% } %>

        <% if (customers != null) { %>
        allCustomers = [
            <% for (int i = 0; i < customers.size(); i++) {
                Customer customer = customers.get(i); %>
            {
                id: <%= customer.getCustomerId() %>,
                name: '<%= customer.getName().replace("'", "\\'") %>',
                phone: '<%= customer.getPhone() != null ? customer.getPhone() : "" %>',
                accountNumber: '<%= customer.getAccountNumber() != null ? customer.getAccountNumber() : "" %>',
                email: '<%= customer.getEmail() != null ? customer.getEmail() : "" %>'
            }<%= i < customers.size() - 1 ? "," : "" %>
            <% } %>
        ];
        <% } %>

        filteredProducts = [...allProducts];

        function validateName(name) {
            return name && name.trim().length >= 2 && /^[a-zA-Z\s.]+$/.test(name.trim());
        }

        function validatePhone(phone) {
            return phone && /^[0-9]{10}$/.test(phone);
        }

        function validateEmail(email) {
            if (!email || email.trim() === '') return true;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        function filterByCategory(category) {
            filteredProducts = allProducts.filter(product => {
                if (!category) return true;
                return product.category === category;
            });
            
            const searchQuery = document.querySelector('.search-input').value;
            if (searchQuery && searchQuery.length >= 2) {
                filteredProducts = filteredProducts.filter(product => 
                    product.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    product.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    product.isbn.toLowerCase().includes(searchQuery.toLowerCase())
                );
            }
            
            displayProductsInTable(filteredProducts);
        }

        function filterByStock(stockType) {
            let baseProducts = allProducts;
            
            const categoryFilter = document.getElementById('categoryFilter').value;
            if (categoryFilter) {
                baseProducts = baseProducts.filter(product => product.category === categoryFilter);
            }
            
            if (stockType === 'available') {
                filteredProducts = baseProducts.filter(product => product.stock > 0);
            } else if (stockType === 'low') {
                filteredProducts = baseProducts.filter(product => product.stock <= 5 && product.stock > 0);
            } else if (stockType === 'high') {
                filteredProducts = baseProducts.filter(product => product.stock > 10);
            } else {
                filteredProducts = baseProducts;
            }
            
            const searchQuery = document.querySelector('.search-input').value;
            if (searchQuery && searchQuery.length >= 2) {
                filteredProducts = filteredProducts.filter(product => 
                    product.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    product.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    product.isbn.toLowerCase().includes(searchQuery.toLowerCase())
                );
            }
            
            displayProductsInTable(filteredProducts);
        }

        function resetFilters() {
            document.getElementById('categoryFilter').value = '';
            document.getElementById('stockFilter').value = '';
            document.querySelector('.search-input').value = '';
            filteredProducts = [...allProducts];
            displayProductsInTable(filteredProducts);
        }

        function searchCustomers(query) {
            clearTimeout(customerSearchTimeout);
            customerSearchTimeout = setTimeout(() => {
                const searchResults = document.getElementById('customerSearchResults');
                const searchInput = document.getElementById('customerSearch');
                
                if (!query || query.length < 2) {
                    searchResults.style.display = 'none';
                    searchResults.innerHTML = '';
                    return;
                }

                // Check for exact phone number match
                const exactPhoneMatch = allCustomers.find(customer => 
                    customer.phone === query.trim()
                );

                if (exactPhoneMatch) {
                    // Auto-select customer if exact phone number match
                    selectCustomer(
                        exactPhoneMatch.id,
                        exactPhoneMatch.name,
                        exactPhoneMatch.phone,
                        exactPhoneMatch.accountNumber
                    );
                    showAlert(`✅ Customer "${exactPhoneMatch.name}" selected by phone number`, 'success');
                    searchResults.style.display = 'none';
                    searchResults.innerHTML = '';
                    return;
                }

                // Filter customers by name or partial phone number
                const filteredCustomers = allCustomers.filter(customer => 
                    customer.name.toLowerCase().includes(query.toLowerCase()) ||
                    customer.phone.includes(query)
                );

                displayCustomerResults(filteredCustomers);
            }, 300);
        }

        function displayCustomerResults(customers) {
            const searchResults = document.getElementById('customerSearchResults');
            
            if (customers.length === 0) {
                searchResults.innerHTML = '<div class="search-result-item">No customers found</div>';
                searchResults.style.display = 'block';
                return;
            }

            searchResults.innerHTML = customers.map(customer => `
                <div class="search-result-item" onclick="selectCustomer(${customer.id}, '${customer.name.replace(/'/g, "\\'")}', '${customer.phone}', '${customer.accountNumber}')">
                    <strong>${customer.name}</strong><br>
                    <small>${customer.phone} • ${customer.accountNumber}</small>
                </div>
            `).join('');
            
            searchResults.style.display = 'block';
        }

        function selectCustomer(id, name, phone, accountNumber) {
            document.getElementById('selectedCustomerId').value = id;
            document.getElementById('customerSearch').value = name;
            document.getElementById('selectedCustomerInfo').innerHTML = `✅ Selected: ${name} (${accountNumber})`;
            document.getElementById('customerSearchResults').style.display = 'none';
            document.getElementById('unselectCustomerBtn').disabled = false;
            closeCustomerTableModal();
        }

        function unselectCustomer() {
            const customerSearch = document.getElementById('customerSearch');
            const selectedCustomerId = document.getElementById('selectedCustomerId');
            const selectedCustomerInfo = document.getElementById('selectedCustomerInfo');
            const unselectButton = document.getElementById('unselectCustomerBtn');

            if (selectedCustomerId.value) {
                selectedCustomerId.value = '';
                customerSearch.value = '';
                selectedCustomerInfo.innerHTML = '';
                unselectButton.disabled = true;
                showAlert('✅ Customer selection cleared', 'success');
            }
        }

        function showCustomerSearch() {
            const query = document.getElementById('customerSearch').value;
            if (query.length >= 2) {
                searchCustomers(query);
            }
        }

        function hideCustomerSearch() {
            setTimeout(() => {
                document.getElementById('customerSearchResults').style.display = 'none';
            }, 200);
        }

        function openCustomerTableModal() {
            document.getElementById('customerTableModal').classList.add('active');
            populateCustomerTable(allCustomers);
            document.getElementById('customerTableSearch').focus();
        }

        function closeCustomerTableModal() {
            document.getElementById('customerTableModal').classList.remove('active');
            document.getElementById('customerTableSearch').value = '';
        }

        function populateCustomerTable(customers) {
            const tableBody = document.getElementById('customersTableBody');
            
            if (customers.length === 0) {
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 2rem; color: #6b7280;">
                            <div>👥 No customers found</div>
                            <small>Try adjusting your search terms</small>
                        </td>
                    </tr>
                `;
                return;
            }

            tableBody.innerHTML = customers.map(customer => `
                <tr onclick="selectCustomer(${customer.id}, '${customer.name.replace(/'/g, "\\'")}', '${customer.phone}', '${customer.accountNumber}')">
                    <td><strong>${customer.accountNumber}</strong></td>
                    <td>${customer.name}</td>
                    <td>${customer.phone}</td>
                    <td>${customer.email || 'Not provided'}</td>
                </tr>
            `).join('');
        }

        function searchCustomerTable(query) {
            if (!query || query.length < 2) {
                populateCustomerTable(allCustomers);
                return;
            }

            const filteredCustomers = allCustomers.filter(customer => 
                customer.name.toLowerCase().includes(query.toLowerCase()) ||
                customer.phone.includes(query)
            );

            populateCustomerTable(filteredCustomers);
        }

        function addNewCustomer() {
            const nameField = document.getElementById('newCustomerName');
            const phoneField = document.getElementById('newCustomerPhone');
            const emailField = document.getElementById('newCustomerEmail');
            const addressField = document.getElementById('newCustomerAddress');
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            
            const name = nameField.value.trim();
            const phone = phoneField.value.trim();
            const email = emailField.value.trim();
            const address = addressField.value.trim();
            
            if (!name) {
                showAlert('❌ Customer name is required', 'error');
                nameField.focus();
                return;
            }
            
            if (!phone) {
                showAlert('❌ Phone number is required', 'error');
                phoneField.focus();
                return;
            }
            
            if (!validateName(name)) {
                showAlert('❌ Please enter a valid customer name', 'error');
                nameField.focus();
                return;
            }
            
            if (!validatePhone(phone)) {
                showAlert('❌ Please enter a valid 10-digit phone number', 'error');
                phoneField.focus();
                return;
            }
            
            if (email && !validateEmail(email)) {
                showAlert('❌ Please enter a valid email address', 'error');
                emailField.focus();
                return;
            }

            const existingCustomer = allCustomers.find(customer => customer.phone === phone);
            if (existingCustomer) {
                showAlert('❌ Customer with this phone number already exists', 'error');
                phoneField.focus();
                return;
            }
            
            addCustomerBtn.classList.add('loading');
            addCustomerBtn.innerHTML = '⏳ Adding Customer...';
            addCustomerBtn.disabled = true;
            
            window.newCustomerData = { name, phone, email, address };
            
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'customer';
            form.target = 'customerFrame';
            form.style.display = 'none';
            
            const actionField = document.createElement('input');
            actionField.type = 'hidden';
            actionField.name = 'action';
            actionField.value = 'add';
            form.appendChild(actionField);
            
            const nameField2 = document.createElement('input');
            nameField2.type = 'hidden';
            nameField2.name = 'name';
            nameField2.value = name;
            form.appendChild(nameField2);
            
            const phoneField2 = document.createElement('input');
            phoneField2.type = 'hidden';
            phoneField2.name = 'phone';
            phoneField2.value = phone;
            form.appendChild(phoneField2);
            
            if (email) {
                const emailField2 = document.createElement('input');
                emailField2.type = 'hidden';
                emailField2.name = 'email';
                emailField2.value = email;
                form.appendChild(emailField2);
            }
            
            if (address) {
                const addressField2 = document.createElement('input');
                addressField2.type = 'hidden';
                addressField2.name = 'address';
                addressField2.value = address;
                form.appendChild(addressField2);
            }
            
            document.body.appendChild(form);
            console.log('📤 Submitting customer form:', { name, phone, email, address });
            form.submit();
            
            setTimeout(() => {
                document.body.removeChild(form);
            }, 1000);
        }

        function handleCustomerFormResponse() {
            const iframe = document.getElementsByName('customerFrame')[0];
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            
            if (!window.newCustomerData) return;
            
            try {
                const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
                const responseBody = iframeDocument.body.innerHTML.toLowerCase();
                
                console.log('🔍 Customer form response received');
                
                const hasSuccess = responseBody.includes('success') || 
                                 responseBody.includes('added') ||
                                 responseBody.includes('customer') && responseBody.includes('successfully');
                
                const hasError = responseBody.includes('error') || 
                               responseBody.includes('duplicate') ||
                               responseBody.includes('exception') ||
                               responseBody.includes('validation') ||
                               responseBody.includes('failed');
                
                if (hasError && !hasSuccess) {
                    let errorMessage = 'Failed to add customer';
                    if (responseBody.includes('duplicate')) {
                        errorMessage = 'Customer with this phone number already exists';
                    } else if (responseBody.includes('validation')) {
                        errorMessage = 'Please check the entered information';
                    }
                    showAlert('❌ ' + errorMessage, 'error');
                    console.error('❌ Customer add failed:', errorMessage);
                } else {
                    const customerData = window.newCustomerData;
                    console.log('✅ Customer added successfully:', customerData.name);
                    
                    document.getElementById('newCustomerName').value = '';
                    document.getElementById('newCustomerPhone').value = '';
                    document.getElementById('newCustomerEmail').value = '';
                    document.getElementById('newCustomerAddress').value = '';
                    
                    closeAddCustomerModal();
                    
                    showAlert('✅ Customer "' + customerData.name + '" added successfully!', 'success');
                    
                    setTimeout(() => {
                        const currentUrl = new URL(window.location);
                        currentUrl.searchParams.set('newCustomerPhone', customerData.phone);
                        window.location.href = currentUrl.toString();
                    }, 1000);
                }
                
            } catch (error) {
                console.log('⚠️ Could not read iframe response, assuming success');
                const customerData = window.newCustomerData;
                
                document.getElementById('newCustomerName').value = '';
                document.getElementById('newCustomerPhone').value = '';
                document.getElementById('newCustomerEmail').value = '';
                document.getElementById('newCustomerAddress').value = '';
                
                closeAddCustomerModal();
                
                showAlert('✅ Customer "' + customerData.name + '" added successfully!', 'success');
                
                setTimeout(() => {
                    const currentUrl = new URL(window.location);
                    currentUrl.searchParams.set('newCustomerPhone', customerData.phone);
                    window.location.href = currentUrl.toString();
                }, 1000);
            } finally {
                addCustomerBtn.classList.remove('loading');
                addCustomerBtn.innerHTML = '✅ Add Customer';
                addCustomerBtn.disabled = false;
                
                delete window.newCustomerData;
            }
        }

        function searchProducts(query) {
            const tableBody = document.getElementById('productsTableBody');
            
            if (!query || query.length < 2) {
                applyCurrentFilters();
                return;
            }

            let searchResults = filteredProducts.filter(product => 
                product.title.toLowerCase().includes(query.toLowerCase()) ||
                product.author.toLowerCase().includes(query.toLowerCase()) ||
                product.isbn.toLowerCase().includes(query.toLowerCase()) ||
                product.category.toLowerCase().includes(query.toLowerCase()) ||
                product.publisher.toLowerCase().includes(query.toLowerCase())
            );

            displayProductsInTable(searchResults);
        }

        function applyCurrentFilters() {
            const categoryFilter = document.getElementById('categoryFilter').value;
            const stockFilter = document.getElementById('stockFilter').value;
            
            let results = [...allProducts];
            
            if (categoryFilter) {
                results = results.filter(product => product.category === categoryFilter);
            }
            
            if (stockFilter === 'available') {
                results = results.filter(product => product.stock > 0);
            } else if (stockFilter === 'low') {
                results = results.filter(product => product.stock <= 5 && product.stock > 0);
            } else if (stockFilter === 'high') {
                results = results.filter(product => product.stock > 10);
            }
            
            filteredProducts = results;
            displayProductsInTable(filteredProducts);
        }

        function displayProductsInTable(products) {
            const tableBody = document.getElementById('productsTableBody');
            
            if (products.length === 0) {
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 2rem; color: #6b7280;">
                            <div>🔍 No products found</div>
                            <small>Try different search terms or reset filters</small>
                        </td>
                    </tr>
                `;
                return;
            }

            tableBody.innerHTML = products.map(product => {
                const imageHtml = product.imagePath && product.imagePath.trim() !== '<%= request.getContextPath() %>/' ? 
                    `<img src="${product.imagePath}" 
                         alt="${product.title}" class="book-image" 
                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                     <div class="book-image-placeholder" style="display: none;">📚</div>` :
                    `<div class="book-image-placeholder">📚</div>`;
                
                const categoryBadge = product.category ? 
                    `<span class="category-badge">${product.category}</span>` : '';
                
                return `
                    <tr onclick="selectProduct(${product.id}, '${product.title.replace(/'/g, "\\'")}', '${product.author.replace(/'/g, "\\'")}', ${product.price}, ${product.stock}, '${product.imagePath.replace(/'/g, "\\'")}', '${product.category.replace(/'/g, "\\'")}')">
                        <td>
                            <div class="book-info">
                                ${imageHtml}
                                <div class="book-details">
                                    <div class="book-title">${product.title}</div>
                                    <div class="book-meta">
                                        ${categoryBadge}
                                        ${product.author ? `by ${product.author}` : ''}
                                        ${product.isbn ? ` • ISBN: ${product.isbn}` : ''}
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td class="price-cell">Rs. ${product.price.toFixed(2)}</td>
                        <td>
                            <span class="stock-badge ${product.stock > 10 ? 'high' : (product.stock > 5 ? 'medium' : 'low')}">
                                ${product.stock}
                            </span>
                        </td>
                        <td>
                            <button type="button" class="btn btn-sm" style="background: #059669; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
                                    onclick="event.stopPropagation(); addProductToBill(${product.id}, '${product.title.replace(/'/g, "\\'")}', '${product.author.replace(/'/g, "\\'")}', ${product.price}, ${product.stock}, '${product.imagePath.replace(/'/g, "\\'")}', '${product.category.replace(/'/g, "\\'")}')">
                                Add
                            </button>
                        </td>
                    </tr>
                `;
            }).join('');
        }

        function selectProduct(productId, title, author, price, stock, imagePath, category) {
            document.querySelectorAll('.products-table tbody tr').forEach(row => {
                row.classList.remove('selected');
            });
            
            event.currentTarget.classList.add('selected');
            
            setTimeout(() => {
                addProductToBill(productId, title, author, price, stock, imagePath, category);
                event.currentTarget.classList.remove('selected');
            }, 200);
        }

        function addProductToBill(productId, title, author, price, stock, imagePath, category) {
            if (stock === 0) {
                showAlert('❌ Product out of stock!', 'error');
                return;
            }

            const existingProduct = billItems.find(item => item.id === productId);
            
            if (existingProduct) {
                if (existingProduct.quantity < stock) {
                    existingProduct.quantity++;
                    updateBillDisplay();
                    showAlert(`✅ Added one more "${title}"`, 'success');
                } else {
                    showAlert(`❌ Cannot add more "${title}". Stock limit reached.`, 'error');
                }
            } else {
                billItems.push({
                    id: productId,
                    title: title,
                    author: author,
                    price: price,
                    quantity: 1,
                    stock: stock,
                    imagePath: imagePath || '',
                    category: category || '',
                    publisher: '',
                    isbn: ''
                });
                updateBillDisplay();
                showAlert(`✅ Added "${title}" to bill`, 'success');
            }
        }

        function updateBillDisplay() {
            const billItemsContainer = document.getElementById('billItems');
            
            if (billItems.length === 0) {
                billItemsContainer.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">🛒</div>
                        <h3>No Items Added</h3>
                        <p>Select products to add them to the bill</p>
                    </div>
                `;
            } else {
                billItemsContainer.innerHTML = billItems.map((item, index) => {
                    const imageHtml = item.imagePath && item.imagePath.trim() && !item.imagePath.endsWith('/') ? 
                        `<img src="${item.imagePath}" 
                             alt="${item.title}" class="bill-item-image" 
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                         <div class="bill-item-image-placeholder" style="display: none;">📚</div>` :
                        `<div class="bill-item-image-placeholder">📚</div>`;
                    
                    const categoryBadge = item.category ? 
                        `<span class="category-badge">${item.category}</span> ` : '';
                    
                    return `
                        <div class="bill-item">
                            <div class="bill-item-header">
                                <div class="bill-item-info">
                                    ${imageHtml}
                                    <div class="bill-item-text">
                                        <h4>${item.title}</h4>
                                        <div class="bill-item-details">
                                            ${categoryBadge}${item.author ? `by ${item.author} • ` : ''}Rs. ${item.price.toFixed(2)} each
                                        </div>
                                    </div>
                                </div>
                                <div class="item-total">Rs. ${(item.price * item.quantity).toFixed(2)}</div>
                            </div>
                            <div class="quantity-controls">
                                <button type="button" class="qty-btn" onclick="decreaseQuantity(${index})">-</button>
                                <input type="number" class="qty-input" value="${item.quantity}" min="1" max="${item.stock}" 
                                       onchange="updateQuantity(${index}, this.value)">
                                <button type="button" class="qty-btn" onclick="increaseQuantity(${index})">+</button>
                                <button type="button" class="remove-btn" onclick="removeProduct(${index})">🗑️</button>
                            </div>
                        </div>
                    `;
                }).join('');
            }
            
            calculateTotals();
        }

        function increaseQuantity(index) {
            const item = billItems[index];
            if (item.quantity < item.stock) {
                item.quantity++;
                updateBillDisplay();
            } else {
                showAlert(`❌ Maximum quantity for "${item.title}" is ${item.stock}`, 'error');
            }
        }

        function decreaseQuantity(index) {
            const item = billItems[index];
            if (item.quantity > 1) {
                item.quantity--;
                updateBillDisplay();
            }
        }

        function updateQuantity(index, newQuantity) {
            const item = billItems[index];
            const qty = parseInt(newQuantity);
            
            if (qty > 0 && qty <= item.stock) {
                item.quantity = qty;
                updateBillDisplay();
            } else if (qty > item.stock) {
                showAlert(`❌ Maximum quantity for "${item.title}" is ${item.stock}`, 'error');
                updateBillDisplay();
            } else if (qty <= 0) {
                removeProduct(index);
            }
        }

        function removeProduct(index) {
            const item = billItems[index];
            if (confirm(`Remove "${item.title}" from bill?`)) {
                billItems.splice(index, 1);
                updateBillDisplay();
                showAlert(`✅ Removed "${item.title}" from bill`, 'success');
            }
        }

        function clearBill() {
            if (billItems.length > 0 && confirm('Are you sure you want to clear all items from the bill?')) {
                billItems = [];
                updateBillDisplay();
                showAlert('✅ Bill cleared successfully', 'success');
            }
        }

        function calculateTotals() {
            let subTotal = 0;
            
            billItems.forEach(item => {
                subTotal += item.price * item.quantity;
            });
            
            const discount = parseFloat(document.getElementById('discount').value) || 0;
            const taxableAmount = Math.max(0, subTotal - discount);
            const tax = taxableAmount * 0.05;
            const totalAmount = taxableAmount + tax;
            
            document.getElementById('subTotal').textContent = `Rs. ${subTotal.toFixed(2)}`;
            document.getElementById('discountAmount').textContent = `Rs. ${discount.toFixed(2)}`;
            document.getElementById('taxAmount').textContent = `Rs. ${tax.toFixed(2)}`;
            document.getElementById('totalAmount').textContent = `Rs. ${totalAmount.toFixed(2)}`;
        }

        function createBill() {
            const customerId = document.getElementById('selectedCustomerId').value;
            const createBillBtn = document.getElementById('createBillBtn');
            
            if (!customerId) {
                showAlert('❌ Please select a customer before creating the bill.', 'error');
                return;
            }
            
            if (billItems.length === 0) {
                showAlert('❌ Please add at least one product to the bill.', 'error');
                return;
            }
            
            const totalAmount = parseFloat(document.getElementById('totalAmount').textContent.replace('Rs. ', ''));
            if (totalAmount <= 0) {
                showAlert('❌ Bill total must be greater than 0.', 'error');
                return;
            }
            
            const customerName = document.getElementById('customerSearch').value;
            const itemCount = billItems.length;
            const totalQty = billItems.reduce((sum, item) => sum + item.quantity, 0);
            
            if (!confirm(`Create bill for ${customerName}?\n\nItems: ${itemCount} different books (${totalQty} total)\nTotal Amount: Rs. ${totalAmount.toFixed(2)}`)) {
                return;
            }
            
            createBillBtn.classList.add('loading');
            createBillBtn.innerHTML = '⏳ Creating Bill...';
            createBillBtn.disabled = true;
            
            document.getElementById('hiddenCustomerId').value = customerId;
            document.getElementById('hiddenDiscount').value = document.getElementById('discount').value;
            
            const hiddenInputsContainer = document.getElementById('hiddenInputs');
            hiddenInputsContainer.innerHTML = '';
            
            billItems.forEach((item) => {
                hiddenInputsContainer.innerHTML += `
                    <input type="hidden" name="bookId" value="${item.id}">
                    <input type="hidden" name="quantity" value="${item.quantity}">
                    <input type="hidden" name="unitPrice" value="${item.price}">
                `;
            });
            
            setTimeout(() => {
                document.getElementById('createBillForm').submit();
            }, 500);
        }

        function openAddCustomerModal() {
            document.getElementById('addCustomerModal').classList.add('active');
            document.getElementById('newCustomerName').focus();
        }

        function closeAddCustomerModal() {
            document.getElementById('addCustomerModal').classList.remove('active');
            document.getElementById('newCustomerName').value = '';
            document.getElementById('newCustomerPhone').value = '';
            document.getElementById('newCustomerEmail').value = '';
            document.getElementById('newCustomerAddress').value = '';
        }

        function showAlert(message, type) {
            const existingAlerts = document.querySelectorAll('.alert');
            existingAlerts.forEach(alert => alert.remove());
            
            const alert = document.createElement('div');
            alert.className = `alert alert-${type}`;
            alert.innerHTML = message;
            
            const header = document.querySelector('.header');
            header.insertAdjacentElement('afterend', alert);
            
            setTimeout(() => {
                if (alert.parentNode) {
                    alert.remove();
                }
            }, 4000);
        }

        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Enhanced CreateBill page loaded with image & category support');
            
            const phoneField = document.getElementById('newCustomerPhone');
            phoneField.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 10) {
                    this.value = this.value.substr(0, 10);
                }
            });
            
            document.getElementById('discount').addEventListener('input', calculateTotals);
            
            document.getElementById('categoryFilter').addEventListener('change', function() {
                filterByCategory(this.value);
            });
            
            document.getElementById('stockFilter').addEventListener('change', function() {
                filterByStock(this.value);
            });
            
            calculateTotals();
            
            displayAllProducts();
            
            document.getElementById('addCustomerModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeAddCustomerModal();
                }
            });

            document.getElementById('customerTableModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeCustomerTableModal();
                }
            });
            
            setTimeout(() => {
                document.getElementById('customerSearch').focus();
            }, 500);

            <% if (preSelectedCustomerId != null && !preSelectedCustomerId.trim().isEmpty()) { %>
            try {
                const customerId = <%= preSelectedCustomerId %>;
                const customer = allCustomers.find(c => c.id === customerId);
                if (customer) {
                    selectCustomer(customer.id, customer.name, customer.phone, customer.accountNumber);
                    showAlert('✅ Customer pre-selected from customer profile', 'success');
                }
            } catch (e) {
                console.error('Error pre-selecting customer:', e);
            }
            <% } %>

            const urlParams = new URLSearchParams(window.location.search);
            const newCustomerPhone = urlParams.get('newCustomerPhone');
            if (newCustomerPhone) {
                const newCustomer = allCustomers.find(c => c.phone === newCustomerPhone);
                if (newCustomer) {
                    selectCustomer(newCustomer.id, newCustomer.name, newCustomer.phone, newCustomer.accountNumber);
                    showAlert('✅ New customer "' + newCustomer.name + '" selected for billing', 'success');
                    
                    const cleanUrl = window.location.pathname + window.location.search.replace(/[&?]newCustomerPhone=[^&]*/g, '');
                    window.history.replaceState({}, document.title, cleanUrl);
                }
            }

            console.log('💡 Enhanced Features: Image Support, Category Filtering, Enhanced Bill Items, Unselect Customer');
            console.log('🎮 Shortcuts: Ctrl+Enter=Create Bill, Ctrl+N=Add Customer, Ctrl+L=Show Customers, Ctrl+R=Reset Filters, Ctrl+U=Unselect Customer, Escape=Close Modals');
        });

        function displayAllProducts() {
            displayProductsInTable(allProducts);
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeAddCustomerModal();
                closeCustomerTableModal();
            }
            
            if (e.ctrlKey && e.key === 'Enter') {
                e.preventDefault();
                createBill();
            }
            
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                openAddCustomerModal();
            }

            if (e.ctrlKey && e.key === 'l') {
                e.preventDefault();
                openCustomerTableModal();
            }
            
            if (e.ctrlKey && e.key === 'r') {
                e.preventDefault();
                resetFilters();
            }
            
            if (e.ctrlKey && e.key === 'f') {
                e.preventDefault();
                document.querySelector('.search-input').focus();
            }

            if (e.ctrlKey && e.key === 'u') {
                e.preventDefault();
                unselectCustomer();
            }
        });
    </script>
</body>
</html>