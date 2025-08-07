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
    
    // Check if coming from view customer page
    String preSelectedCustomerId = request.getParameter("customerId");
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

        .add-customer-btn, .show-customers-btn {
            padding: 0.75rem 1.5rem;
            background: #10b981;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s;
            white-space: nowrap;
        }

        .add-customer-btn:hover, .show-customers-btn:hover {
            background: #059669;
        }

        .show-customers-btn {
            background: #3b82f6;
            margin-left: 0.5rem;
        }

        .show-customers-btn:hover {
            background: #2563eb;
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

        .bill-item-info h4 {
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
                    <div style="font-size: 0.8rem; color: rgba(255,255,255,0.8);"><%= loggedUser.getRole() %></div>
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
                        <div id="selectedCustomerInfo" style="margin-top: 0.5rem; font-size: 0.9rem; color: #059669; font-weight: 500;"></div>
                    </div>
                    <button type="button" class="show-customers-btn" onclick="openCustomerTableModal()">
                        📋 Show All
                    </button>
                    <button type="button" class="add-customer-btn" onclick="openAddCustomerModal()">
                        ➕ Add New
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
                                <button type="button" class="btn btn-sm" style="background: #059669; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
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

    <!-- Customer Table Modal -->
    <div class="modal" id="customerTableModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>📋 Select Customer</h3>
                <p>Choose a customer from the list below</p>
            </div>
            <div class="modal-body">
                <div class="customer-modal-search">
                    <input type="text" class="form-control" id="customerTableSearch" 
                           placeholder="🔍 Search customers..." 
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
                            <!-- Customer data will be populated here -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-clear" onclick="closeCustomerTableModal()">❌ Close</button>
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

    <!-- Hidden iframe for form submission -->
    <iframe name="customerFrame" style="display: none;" onload="handleCustomerFormResponse()"></iframe>
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

        // Validation functions
        function validateName(name) {
            return name && name.trim().length >= 2 && /^[a-zA-Z\s.]+$/.test(name.trim());
        }

        function validatePhone(phone) {
            return phone && /^[0-9]{10}$/.test(phone);
        }

        function validateEmail(email) {
            if (!email || email.trim() === '') return true; // Optional field
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

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
            closeCustomerTableModal();
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

        // Customer Table Modal Functions
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
                customer.phone.includes(query) ||
                customer.accountNumber.toLowerCase().includes(query.toLowerCase()) ||
                customer.email.toLowerCase().includes(query.toLowerCase())
            );

            populateCustomerTable(filteredCustomers);
        }

        // Add Customer Function (Fixed with Iframe approach)
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
            
            // Validate required fields
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
            
            // Validate formats
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

            // Check if customer already exists
            const existingCustomer = allCustomers.find(customer => customer.phone === phone);
            if (existingCustomer) {
                showAlert('❌ Customer with this phone number already exists', 'error');
                phoneField.focus();
                return;
            }
            
            // Show loading state
            addCustomerBtn.classList.add('loading');
            addCustomerBtn.innerHTML = '⏳ Adding Customer...';
            addCustomerBtn.disabled = true;
            
            // Store customer data for later use
            window.newCustomerData = { name, phone, email, address };
            
            // Create and submit hidden form
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'customer';
            form.target = 'customerFrame';
            form.style.display = 'none';
            
            // Add form fields
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
            
            // Add to page and submit
            document.body.appendChild(form);
            console.log('📤 Submitting customer form:', { name, phone, email, address });
            form.submit();
            
            // Remove form after submission
            setTimeout(() => {
                document.body.removeChild(form);
            }, 1000);
        }

        // Handle customer form response from iframe
        function handleCustomerFormResponse() {
            const iframe = document.getElementsByName('customerFrame')[0];
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            
            if (!window.newCustomerData) return; // No customer being added
            
            try {
                const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
                const responseBody = iframeDocument.body.innerHTML.toLowerCase();
                
                console.log('🔍 Customer form response received');
                
                // Check for success indicators
                const hasSuccess = responseBody.includes('success') || 
                                 responseBody.includes('added') ||
                                 responseBody.includes('customer') && responseBody.includes('successfully');
                
                // Check for error indicators
                const hasError = responseBody.includes('error') || 
                               responseBody.includes('duplicate') ||
                               responseBody.includes('exception') ||
                               responseBody.includes('validation') ||
                               responseBody.includes('failed');
                
                if (hasError && !hasSuccess) {
                    // Extract specific error message
                    let errorMessage = 'Failed to add customer';
                    if (responseBody.includes('duplicate')) {
                        errorMessage = 'Customer with this phone number already exists';
                    } else if (responseBody.includes('validation')) {
                        errorMessage = 'Please check the entered information';
                    }
                    
                    showAlert('❌ ' + errorMessage, 'error');
                    console.error('❌ Customer add failed:', errorMessage);
                } else {
                    // Success case
                    const customerData = window.newCustomerData;
                    console.log('✅ Customer added successfully:', customerData.name);
                    
                    // Clear form
                    document.getElementById('newCustomerName').value = '';
                    document.getElementById('newCustomerPhone').value = '';
                    document.getElementById('newCustomerEmail').value = '';
                    document.getElementById('newCustomerAddress').value = '';
                    
                    // Close modal
                    closeAddCustomerModal();
                    
                    // Show success message
                    showAlert('✅ Customer "' + customerData.name + '" added successfully!', 'success');
                    
                    // Refresh the page to get updated customer list and auto-select
                    setTimeout(() => {
                        const currentUrl = new URL(window.location);
                        currentUrl.searchParams.set('newCustomerPhone', customerData.phone);
                        window.location.href = currentUrl.toString();
                    }, 1000);
                }
                
            } catch (error) {
                console.log('⚠️ Could not read iframe response, assuming success');
                const customerData = window.newCustomerData;
                
                // Clear form
                document.getElementById('newCustomerName').value = '';
                document.getElementById('newCustomerPhone').value = '';
                document.getElementById('newCustomerEmail').value = '';
                document.getElementById('newCustomerAddress').value = '';
                
                // Close modal
                closeAddCustomerModal();
                
                // Show success message
                showAlert('✅ Customer "' + customerData.name + '" added successfully!', 'success');
                
                // Refresh with new customer phone
                setTimeout(() => {
                    const currentUrl = new URL(window.location);
                    currentUrl.searchParams.set('newCustomerPhone', customerData.phone);
                    window.location.href = currentUrl.toString();
                }, 1000);
            } finally {
                // Reset button state
                addCustomerBtn.classList.remove('loading');
                addCustomerBtn.innerHTML = '✅ Add Customer';
                addCustomerBtn.disabled = false;
                
                // Clear stored data
                delete window.newCustomerData;
            }
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
                        <button type="button" class="btn btn-sm" style="background: #059669; color: white; padding: 0.3rem 0.8rem; border: none; border-radius: 4px; font-size: 0.8rem;"
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
            // Clear form
            document.getElementById('newCustomerName').value = '';
            document.getElementById('newCustomerPhone').value = '';
            document.getElementById('newCustomerEmail').value = '';
            document.getElementById('newCustomerAddress').value = '';
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
            console.log('🚀 CreateBill page loaded');
            
            // Phone number input formatting
            const phoneField = document.getElementById('newCustomerPhone');
            phoneField.addEventListener('input', function() {
                // Remove non-digits and limit to 10 digits
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 10) {
                    this.value = this.value.substr(0, 10);
                }
            });
            
            // Initialize discount change listener
            document.getElementById('discount').addEventListener('input', calculateTotals);
            
            // Initialize calculations
            calculateTotals();
            
            // Display all products initially
            displayAllProducts();
            
            // Close modals when clicking outside
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
            
            // Auto-focus customer search
            setTimeout(() => {
                document.getElementById('customerSearch').focus();
            }, 500);

            // Handle pre-selected customer (from view customer page)
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

            // Handle newly added customer auto-selection
            const urlParams = new URLSearchParams(window.location.search);
            const newCustomerPhone = urlParams.get('newCustomerPhone');
            if (newCustomerPhone) {
                const newCustomer = allCustomers.find(c => c.phone === newCustomerPhone);
                if (newCustomer) {
                    selectCustomer(newCustomer.id, newCustomer.name, newCustomer.phone, newCustomer.accountNumber);
                    showAlert('✅ New customer "' + newCustomer.name + '" selected for billing', 'success');
                    
                    // Clean URL
                    const cleanUrl = window.location.pathname + window.location.search.replace(/[&?]newCustomerPhone=[^&]*/g, '');
                    window.history.replaceState({}, document.title, cleanUrl);
                }
            }
            
            console.log('💡 Shortcuts: Ctrl+Enter=Create Bill, Ctrl+N=Add Customer, Ctrl+L=Show Customers, Escape=Close Modals');
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key closes modals
            if (e.key === 'Escape') {
                closeAddCustomerModal();
                closeCustomerTableModal();
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

            // Ctrl+L to show customer list
            if (e.ctrlKey && e.key === 'l') {
                e.preventDefault();
                openCustomerTableModal();
            }
        });
    </script>
</body>
</html>