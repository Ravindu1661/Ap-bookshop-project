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
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS System - Create Bill | Redupahana</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            color: #333;
            line-height: 1.6;
        }

        /* Header */
        .header {
            background: #fff;
            border-bottom: 2px solid #e9ecef;
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .back-btn {
            background: #6c757d;
            border: none;
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 500;
        }

        .back-btn:hover {
            background: #5a6268;
            transform: translateY(-1px);
        }

        .store-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2c3e50;
        }

        .subtitle {
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 0.2rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            background: #f8f9fa;
            padding: 0.8rem 1.2rem;
            border-radius: 8px;
            border: 1px solid #dee2e6;
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
            font-size: 1rem;
        }

        /* Alert Messages */
        .alert {
            max-width: 1400px;
            margin: 1rem auto;
            padding: 1rem 2rem;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 500;
            animation: slideIn 0.5s ease;
        }

        .alert-success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .alert-error {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
        }

        /* Left Panel - Products & Customer */
        .left-panel {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: 1px solid #dee2e6;
        }

        .panel-header {
            background: #2c3e50;
            color: white;
            padding: 1.5rem 2rem;
            border-radius: 8px 8px 0 0;
        }

        .panel-header h2 {
            font-size: 1.3rem;
            margin-bottom: 0.3rem;
        }

        .panel-header p {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        /* Customer Section */
        .customer-section {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #dee2e6;
            background: #f8f9fa;
        }

        .customer-controls {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 1rem;
            align-items: end;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #495057;
            font-size: 0.95rem;
        }

        .required {
            color: #dc3545;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

        .form-control:focus {
            outline: none;
            border-color: #2c3e50;
            box-shadow: 0 0 0 2px rgba(44, 62, 80, 0.1);
        }

        .add-customer-btn {
            background: #28a745;
            color: white;
            border: none;
            padding: 0.8rem 1.2rem;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            white-space: nowrap;
            font-size: 0.9rem;
        }

        .add-customer-btn:hover {
            background: #218838;
        }

        /* Customer Search Results */
        .customer-search {
            position: relative;
        }

        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 1px solid #ced4da;
            border-top: none;
            border-radius: 0 0 6px 6px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 50;
            display: none;
        }

        .search-result-item {
            padding: 0.8rem;
            cursor: pointer;
            border-bottom: 1px solid #f8f9fa;
            transition: background-color 0.3s ease;
        }

        .search-result-item:hover {
            background: #f8f9fa;
        }

        .search-result-item:last-child {
            border-bottom: none;
        }

        /* Product Search */
        .product-search {
            padding: 1.5rem 2rem;
            background: white;
            border-bottom: 1px solid #dee2e6;
        }

        .search-input {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: #2c3e50;
            box-shadow: 0 0 0 2px rgba(44, 62, 80, 0.1);
        }

        /* Products Table */
        .products-table-container {
            padding: 1.5rem 2rem;
            max-height: 400px;
            overflow-y: auto;
        }

        .products-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        .products-table th,
        .products-table td {
            padding: 0.8rem;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }

        .products-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #495057;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .products-table tbody tr {
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .products-table tbody tr:hover {
            background: #f8f9fa;
        }

        .products-table tbody tr.selected {
            background: #d4edda;
        }

        .stock-badge {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .stock-badge.high {
            background: #d4edda;
            color: #155724;
        }

        .stock-badge.medium {
            background: #fff3cd;
            color: #856404;
        }

        .stock-badge.low {
            background: #f8d7da;
            color: #721c24;
        }

        .price-cell {
            font-weight: 600;
            color: #28a745;
        }

        /* Right Panel - Bill */
        .right-panel {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: 1px solid #dee2e6;
            display: flex;
            flex-direction: column;
            max-height: calc(100vh - 200px);
        }

        .bill-header {
            background: #28a745;
            color: white;
            padding: 1.5rem;
            text-align: center;
            border-radius: 8px 8px 0 0;
        }

        .bill-header h2 {
            font-size: 1.3rem;
            margin-bottom: 0.3rem;
        }

        .bill-number {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        /* Bill Items */
        .bill-items {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
            min-height: 250px;
        }

        .bill-item {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 1rem;
            margin-bottom: 0.8rem;
            border: 1px solid #dee2e6;
            transition: all 0.3s ease;
        }

        .bill-item:hover {
            background: #e9ecef;
        }

        .bill-item-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.8rem;
        }

        .bill-item-info h4 {
            color: #495057;
            font-size: 0.95rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .bill-item-details {
            font-size: 0.85rem;
            color: #6c757d;
        }

        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: white;
            padding: 0.4rem;
            border-radius: 6px;
            border: 1px solid #dee2e6;
        }

        .qty-btn {
            width: 28px;
            height: 28px;
            border: none;
            border-radius: 4px;
            background: #2c3e50;
            color: white;
            cursor: pointer;
            font-size: 1rem;
            font-weight: bold;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .qty-btn:hover {
            background: #495057;
        }

        .qty-input {
            width: 50px;
            text-align: center;
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 0.3rem;
            font-weight: 500;
        }

        .remove-btn {
            background: #dc3545;
            color: white;
            border: none;
            padding: 0.3rem 0.6rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
            transition: all 0.3s ease;
        }

        .remove-btn:hover {
            background: #c82333;
        }

        .item-total {
            font-weight: 600;
            color: #28a745;
            font-size: 1rem;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 2rem 1rem;
            color: #6c757d;
        }

        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .empty-state h3 {
            color: #495057;
            margin-bottom: 0.5rem;
        }

        /* Bill Totals */
        .bill-totals {
            padding: 1.5rem;
            background: #f8f9fa;
            border-top: 1px solid #dee2e6;
        }

        .discount-section {
            margin-bottom: 1rem;
        }

        .discount-input {
            display: flex;
            gap: 0.5rem;
            align-items: end;
        }

        .discount-input input {
            flex: 1;
        }

        .apply-discount-btn {
            background: #17a2b8;
            color: white;
            border: none;
            padding: 0.8rem 1rem;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .apply-discount-btn:hover {
            background: #138496;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.4rem 0;
            font-size: 0.95rem;
            color: #495057;
        }

        .total-row.final {
            font-size: 1.2rem;
            font-weight: 700;
            color: #28a745;
            border-top: 2px solid #28a745;
            padding-top: 0.8rem;
            margin-top: 0.8rem;
        }

        /* Action Buttons */
        .action-buttons {
            padding: 1.5rem;
            display: flex;
            gap: 1rem;
        }

        .btn {
            flex: 1;
            padding: 1rem;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-success:hover {
            background: #218838;
            transform: translateY(-1px);
        }

        .btn-clear {
            background: #6c757d;
            color: white;
        }

        .btn-clear:hover {
            background: #5a6268;
            transform: translateY(-1px);
        }

        /* Add Customer Modal */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            max-width: 500px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            animation: modalSlideIn 0.3s ease;
            border: 1px solid #dee2e6;
        }

        @keyframes modalSlideIn {
            from { opacity: 0; transform: translateY(-50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .modal-header {
            text-align: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #dee2e6;
        }

        .modal-header h3 {
            color: #495057;
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
        }

        .modal-actions {
            display: flex;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        /* Loading State */
        .loading {
            position: relative;
            pointer-events: none;
            opacity: 0.7;
        }

        .loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 16px;
            height: 16px;
            margin: -8px 0 0 -8px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #2c3e50;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .main-container {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .right-panel {
                order: -1;
                max-height: 400px;
            }
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            
            .main-container {
                padding: 0 1rem;
                margin: 1rem auto;
            }
            
            .customer-controls {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .products-table {
                font-size: 0.9rem;
            }
            
            .products-table th,
            .products-table td {
                padding: 0.6rem 0.4rem;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
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
                    <div style="font-size: 0.8rem; color: #6c757d;"><%= loggedUser.getRole() %></div>
                </div>
            </div>
        </div>
    </header>

    <!-- Alert Messages -->
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

    <!-- Main Container -->
    <div class="main-container">
        <!-- Left Panel - Products & Customer -->
        <div class="left-panel">
            <div class="panel-header">
                <h2>🛍️ Product Selection</h2>
                <p>Choose customer and products for billing</p>
            </div>

            <!-- Customer Section -->
            <div class="customer-section">
                <div class="customer-controls">
                    <div class="form-group">
                        <label for="customerSearch">👤 Search & Select Customer <span class="required">*</span></label>
                        <div class="customer-search">
                            <input type="text" class="form-control" id="customerSearch" 
                                   placeholder="Type customer name, phone, or account number..." 
                                   onkeyup="searchCustomers(this.value)" 
                                   onfocus="showCustomerSearch()" 
                                   onblur="hideCustomerSearch()">
                            <div class="search-results" id="customerSearchResults"></div>
                        </div>
                        <input type="hidden" id="selectedCustomerId" name="customerId">
                        <div id="selectedCustomerInfo" style="margin-top: 0.5rem; font-size: 0.9rem; color: #28a745; font-weight: 500;"></div>
                    </div>
                    <button type="button" class="add-customer-btn" onclick="openAddCustomerModal()">
                        ➕ Add New Customer
                    </button>
                </div>
            </div>

            <!-- Product Search -->
            <div class="product-search">
                <input type="text" class="search-input" placeholder="🔍 Search products by title, author, or ISBN..." 
                       onkeyup="searchProducts(this.value)">
            </div>

            <!-- Products Table -->
            <div class="products-table-container">
                <table class="products-table" id="productsTable">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="productsTableBody">
                        <% if (books != null && !books.isEmpty()) {
                            for (Book book : books) { %>
                        <tr onclick="selectProduct(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>', '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>', <%= book.getPrice() %>, <%= book.getStockQuantity() %>)">
                            <td><strong><%= book.getTitle() %></strong></td>
                            <td><%= book.getAuthor() != null ? book.getAuthor() : "N/A" %></td>
                            <td class="price-cell">Rs. <%= String.format("%.2f", book.getPrice()) %></td>
                            <td>
                                <span class="stock-badge <%= book.getStockQuantity() > 10 ? "high" : (book.getStockQuantity() > 5 ? "medium" : "low") %>">
                                    <%= book.getStockQuantity() %>
                                </span>
                            </td>
                            <td>
                                <button type="button" class="btn btn-sm" style="background: #28a745; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
                                        onclick="event.stopPropagation(); addProductToBill(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>', '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>', <%= book.getPrice() %>, <%= book.getStockQuantity() %>)">
                                    Add
                                </button>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr>
                            <td colspan="5" class="empty-state">
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

        <!-- Right Panel - Bill -->
        <div class="right-panel">
            <div class="bill-header">
                <h2>🧾 Current Bill</h2>
                <div class="bill-number">Bill #<span id="billNumber"><%= System.currentTimeMillis() %></span></div>
            </div>

            <!-- Bill Items -->
            <div class="bill-items" id="billItems">
                <div class="empty-state">
                    <div class="empty-state-icon">🛒</div>
                    <h3>No Items Added</h3>
                    <p>Select products to add them to the bill</p>
                </div>
            </div>

            <!-- Bill Totals -->
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

            <!-- Action Buttons -->
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

    <!-- Add Customer Modal -->
    <div class="modal" id="addCustomerModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>➕ Add New Customer</h3>
                <p>Fill in customer details to add them to the system</p>
            </div>
            
            <form id="addCustomerForm" onsubmit="handleAddCustomerSubmit(event)">
                <div class="form-group">
                    <label for="newCustomerName">Customer Name <span class="required">*</span></label>
                    <input type="text" class="form-control" id="newCustomerName" name="name" required 
                           placeholder="Enter customer full name">
                </div>

                <div class="form-group">
                    <label for="newCustomerPhone">Phone Number <span class="required">*</span></label>
                    <input type="tel" class="form-control" id="newCustomerPhone" name="phone" required 
                           placeholder="Enter 10-digit phone number" pattern="[0-9]{10}">
                </div>

                <div class="form-group">
                    <label for="newCustomerEmail">Email Address</label>
                    <input type="email" class="form-control" id="newCustomerEmail" name="email"
                           placeholder="Enter email address (optional)">
                </div>

                <div class="form-group">
                    <label for="newCustomerAddress">Address</label>
                    <textarea class="form-control" id="newCustomerAddress" name="address" rows="3" 
                              placeholder="Enter customer address (optional)"></textarea>
                </div>

                <div class="modal-actions">
                    <button type="submit" class="btn btn-success" id="addCustomerBtn">✅ Add Customer</button>
                    <button type="button" class="btn btn-clear" onclick="closeAddCustomerModal()">❌ Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden Form for Bill Submission -->
    <form action="bill" method="post" id="createBillForm" style="display: none;">
        <input type="hidden" name="action" value="create">
        <input type="hidden" name="customerId" id="hiddenCustomerId">
        <input type="hidden" name="discount" id="hiddenDiscount">
        <div id="hiddenInputs"></div>
    </form>

    <script>
        // Global variables
        let billItems = [];
        let allProducts = [];
        let allCustomers = [];
        let customerSearchTimeout;

        // Store data for search functionality
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
                isbn: '<%= book.getIsbn() != null ? book.getIsbn() : "" %>'
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

        // Customer search functions
        function searchCustomers(query) {
            clearTimeout(customerSearchTimeout);
            customerSearchTimeout = setTimeout(() => {
                const searchResults = document.getElementById('customerSearchResults');
                
                if (!query || query.length < 2) {
                    searchResults.style.display = 'none';
                    return;
                }

                const filteredCustomers = allCustomers.filter(customer => 
                    customer.name.toLowerCase().includes(query.toLowerCase()) ||
                    customer.phone.includes(query) ||
                    customer.accountNumber.toLowerCase().includes(query.toLowerCase()) ||
                    customer.email.toLowerCase().includes(query.toLowerCase())
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

        // Product search functions
        function searchProducts(query) {
            const tableBody = document.getElementById('productsTableBody');
            
            if (!query || query.length < 2) {
                displayAllProducts();
                return;
            }

            const filteredProducts = allProducts.filter(product => 
                product.title.toLowerCase().includes(query.toLowerCase()) ||
                product.author.toLowerCase().includes(query.toLowerCase()) ||
                product.isbn.toLowerCase().includes(query.toLowerCase())
            );

            displayProductsInTable(filteredProducts);
        }

        function displayProductsInTable(products) {
            const tableBody = document.getElementById('productsTableBody');
            
            if (products.length === 0) {
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="5" style="text-align: center; padding: 2rem; color: #6c757d;">
                            <div>🔍 No products found</div>
                            <small>Try different search terms</small>
                        </td>
                    </tr>
                `;
                return;
            }

            tableBody.innerHTML = products.map(product => `
                <tr onclick="selectProduct(${product.id}, '${product.title.replace(/'/g, "\\'")}', '${product.author.replace(/'/g, "\\'")}', ${product.price}, ${product.stock})">
                    <td><strong>${product.title}</strong></td>
                    <td>${product.author || 'N/A'}</td>
                    <td class="price-cell">Rs. ${product.price.toFixed(2)}</td>
                    <td>
                        <span class="stock-badge ${product.stock > 10 ? 'high' : (product.stock > 5 ? 'medium' : 'low')}">
                            ${product.stock}
                        </span>
                    </td>
                    <td>
                        <button type="button" class="btn btn-sm" style="background: #28a745; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
                                onclick="event.stopPropagation(); addProductToBill(${product.id}, '${product.title.replace(/'/g, "\\'")}', '${product.author.replace(/'/g, "\\'")}', ${product.price}, ${product.stock})">
                            Add
                        </button>
                    </td>
                </tr>
            `).join('');
        }

        function displayAllProducts() {
            displayProductsInTable(allProducts);
        }

        function selectProduct(productId, title, author, price, stock) {
            // Remove previous selection
            document.querySelectorAll('.products-table tbody tr').forEach(row => {
                row.classList.remove('selected');
            });
            
            // Add selection to current row
            event.currentTarget.classList.add('selected');
            
            // Auto add to bill after short delay
            setTimeout(() => {
                addProductToBill(productId, title, author, price, stock);
                event.currentTarget.classList.remove('selected');
            }, 200);
        }

        // Add product to bill
        function addProductToBill(productId, title, author, price, stock) {
            if (stock === 0) {
                showAlert('❌ Product out of stock!', 'error');
                return;
            }

            // Check if product already exists in bill
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
                    stock: stock
                });
                updateBillDisplay();
                showAlert(`✅ Added "${title}" to bill`, 'success');
            }
        }

        // Update bill display
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
                billItemsContainer.innerHTML = billItems.map((item, index) => `
                    <div class="bill-item">
                        <div class="bill-item-header">
                            <div class="bill-item-info">
                                <h4>${item.title}</h4>
                                <div class="bill-item-details">
                                    ${item.author ? `by ${item.author} • ` : ''}Rs. ${item.price.toFixed(2)} each
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
                `).join('');
            }
            
            calculateTotals();
        }

        // Quantity management functions
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
                updateBillDisplay(); // Reset to previous value
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

        // Clear all products
        function clearBill() {
            if (billItems.length > 0 && confirm('Are you sure you want to clear all items from the bill?')) {
                billItems = [];
                updateBillDisplay();
                showAlert('✅ Bill cleared successfully', 'success');
            }
        }

        // Calculate totals
        function calculateTotals() {
            let subTotal = 0;
            
            billItems.forEach(item => {
                subTotal += item.price * item.quantity;
            });
            
            const discount = parseFloat(document.getElementById('discount').value) || 0;
            const taxableAmount = Math.max(0, subTotal - discount);
            const tax = taxableAmount * 0.05; // 5% tax
            const totalAmount = taxableAmount + tax;
            
            document.getElementById('subTotal').textContent = `Rs. ${subTotal.toFixed(2)}`;
            document.getElementById('discountAmount').textContent = `Rs. ${discount.toFixed(2)}`;
            document.getElementById('taxAmount').textContent = `Rs. ${tax.toFixed(2)}`;
            document.getElementById('totalAmount').textContent = `Rs. ${totalAmount.toFixed(2)}`;
        }

        // Create bill function
        function createBill() {
            const customerId = document.getElementById('selectedCustomerId').value;
            const createBillBtn = document.getElementById('createBillBtn');
            
            // Validate customer selection
            if (!customerId) {
                showAlert('❌ Please select a customer before creating the bill.', 'error');
                return;
            }
            
            // Validate bill items
            if (billItems.length === 0) {
                showAlert('❌ Please add at least one product to the bill.', 'error');
                return;
            }
            
            // Check total amount
            const totalAmount = parseFloat(document.getElementById('totalAmount').textContent.replace('Rs. ', ''));
            if (totalAmount <= 0) {
                showAlert('❌ Bill total must be greater than 0.', 'error');
                return;
            }
            
            // Confirm bill creation
            const customerName = document.getElementById('customerSearch').value;
            if (!confirm(`Create bill for ${customerName}?\nTotal Amount: Rs. ${totalAmount.toFixed(2)}`)) {
                return;
            }
            
            // Show loading state
            createBillBtn.classList.add('loading');
            createBillBtn.innerHTML = '⏳ Creating Bill...';
            createBillBtn.disabled = true;
            
            // Prepare form data
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
            
            // Submit form
            setTimeout(() => {
                document.getElementById('createBillForm').submit();
            }, 500);
        }

        // Add Customer Modal Functions
        function openAddCustomerModal() {
            document.getElementById('addCustomerModal').classList.add('active');
            document.getElementById('newCustomerName').focus();
        }

        function closeAddCustomerModal() {
            document.getElementById('addCustomerModal').classList.remove('active');
            document.getElementById('addCustomerForm').reset();
        }

        // Handle Add Customer Form Submission with AJAX
        function handleAddCustomerSubmit(event) {
            event.preventDefault();
            
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            const form = document.getElementById('addCustomerForm');
            const formData = new FormData(form);
            formData.append('action', 'add');
            
            const name = document.getElementById('newCustomerName').value.trim();
            const phone = document.getElementById('newCustomerPhone').value.trim();
            
            // Validate required fields
            if (!name || !phone) {
                showAlert('❌ Please fill in all required fields.', 'error');
                return;
            }
            
            // Validate phone number
            if (!/^[0-9]{10}$/.test(phone)) {
                showAlert('❌ Please enter a valid 10-digit phone number.', 'error');
                return;
            }
            
            // Show loading
            addCustomerBtn.classList.add('loading');
            addCustomerBtn.innerHTML = '⏳ Adding Customer...';
            addCustomerBtn.disabled = true;
            
            // Send AJAX request
            fetch('customer', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(data => {
                // Check if the response contains error (simple check)
                if (data.includes('Error adding customer') || data.includes('Duplicate entry')) {
                    throw new Error('Customer with this phone number or account already exists');
                }
                
                // If successful, refresh customer data and close modal
                refreshCustomerData()
                    .then(() => {
                        closeAddCustomerModal();
                        showAlert('✅ Customer added successfully!', 'success');
                        
                        // Auto-select the newly added customer
                        const newCustomerName = name;
                        setTimeout(() => {
                            document.getElementById('customerSearch').value = newCustomerName;
                            searchCustomers(newCustomerName);
                            setTimeout(() => {
                                const searchResults = document.getElementById('customerSearchResults');
                                const firstResult = searchResults.querySelector('.search-result-item');
                                if (firstResult) {
                                    firstResult.click();
                                }
                            }, 300);
                        }, 500);
                    });
            })
            .catch(error => {
                console.error('Error:', error);
                showAlert('❌ Error adding customer: ' + error.message, 'error');
            })
            .finally(() => {
                // Reset button state
                addCustomerBtn.classList.remove('loading');
                addCustomerBtn.innerHTML = '✅ Add Customer';
                addCustomerBtn.disabled = false;
            });
        }

        // Refresh customer data from server
        function refreshCustomerData() {
            return fetch('customer?action=list')
                .then(response => response.text())
                .then(data => {
                    // Extract customer data from response (this is a simple approach)
                    // In a real application, you might want to return JSON instead
                    
                    // For now, we'll make another request to get fresh data
                    return fetch('bill?action=create')
                        .then(response => response.text())
                        .then(html => {
                            // Parse the HTML to extract customer data
                            const parser = new DOMParser();
                            const doc = parser.parseFromString(html, 'text/html');
                            const scripts = doc.querySelectorAll('script');
                            
                            // Find the script that contains allCustomers array
                            for (let script of scripts) {
                                const content = script.textContent;
                                if (content.includes('allCustomers = [')) {
                                    const start = content.indexOf('allCustomers = [');
                                    const end = content.indexOf('];', start) + 2;
                                    const customerArrayCode = content.substring(start, end);
                                    
                                    // Execute the code to update allCustomers
                                    try {
                                        eval(customerArrayCode);
                                        console.log('Customer data refreshed successfully');
                                    } catch (e) {
                                        console.error('Error parsing customer data:', e);
                                    }
                                    break;
                                }
                            }
                        });
                })
                .catch(error => {
                    console.error('Error refreshing customer data:', error);
                });
        }

        // Show alert function
        function showAlert(message, type) {
            // Remove existing alerts
            const existingAlerts = document.querySelectorAll('.alert');
            existingAlerts.forEach(alert => alert.remove());
            
            // Create new alert
            const alert = document.createElement('div');
            alert.className = `alert alert-${type}`;
            alert.innerHTML = message;
            
            // Insert after header
            const header = document.querySelector('.header');
            header.insertAdjacentElement('afterend', alert);
            
            // Auto remove after 4 seconds
            setTimeout(() => {
                if (alert.parentNode) {
                    alert.remove();
                }
            }, 4000);
        }

        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize discount change listener
            document.getElementById('discount').addEventListener('input', calculateTotals);
            
            // Initialize calculations
            calculateTotals();
            
            // Display all products initially
            displayAllProducts();
            
            // Close modal when clicking outside
            document.getElementById('addCustomerModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeAddCustomerModal();
                }
            });
            
            // Auto-focus customer search
            setTimeout(() => {
                document.getElementById('customerSearch').focus();
            }, 500);
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key closes modal
            if (e.key === 'Escape') {
                closeAddCustomerModal();
            }
            
            // Ctrl+Enter to create bill
            if (e.ctrlKey && e.key === 'Enter') {
                e.preventDefault();
                createBill();
            }
            
            // Ctrl+N to add new customer
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                openAddCustomerModal();
            }
        });
    </script>
</body>
</html>