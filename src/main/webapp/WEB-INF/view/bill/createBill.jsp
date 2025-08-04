<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Item"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Item> items = (List<Item>) request.getAttribute("items");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Bill - Redupahana POS</title>
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
            position: relative;
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

        /* Icon classes using Unicode */
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

        .breadcrumb a:hover {
            text-decoration: underline;
        }

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

        .alert-success {
            background-color: #d4edda;
            border-left-color: #27ae60;
            color: #155724;
        }

        /* POS Interface Container */
        .pos-container {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 1.5rem;
            height: calc(100vh - 200px);
        }

        /* Left Panel - Item Selection & Bill Items */
        .left-panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            display: flex;
            flex-direction: column;
        }

        .panel-header {
            padding: 1.5rem;
            border-bottom: 1px solid #eee;
            background: #2c3e50;
            color: white;
            border-radius: 12px 12px 0 0;
        }

        .panel-header h3 {
            margin: 0;
            font-size: 1.2rem;
        }

        /* Customer Selection */
        .customer-section {
            padding: 1.5rem;
            border-bottom: 1px solid #eee;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #2c3e50;
        }

        .required {
            color: #e74c3c;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #2c3e50;
            box-shadow: 0 0 0 2px rgba(44, 62, 80, 0.1);
        }

        /* Items Grid */
        .items-grid {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
        }

        .items-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            max-height: 400px;
            overflow-y: auto;
        }

        .item-card {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            background: #f8f9fa;
        }

        .item-card:hover {
            border-color: #2c3e50;
            background: #e8f4fd;
            transform: translateY(-2px);
        }

        .item-card.selected {
            border-color: #27ae60;
            background: #d4edda;
        }

        .item-card h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }

        .item-price {
            color: #27ae60;
            font-weight: bold;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
        }

        .item-stock {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        /* Right Panel - Bill Summary */
        .right-panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
            display: flex;
            flex-direction: column;
        }

        /* Bill Items */
        .bill-items {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
        }

        .bill-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            border: 1px solid #eee;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            background: #f8f9fa;
        }

        .bill-item-info {
            flex: 1;
        }

        .bill-item-name {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.25rem;
        }

        .bill-item-details {
            font-size: 0.9rem;
            color: #7f8c8d;
        }

        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .qty-btn {
            width: 30px;
            height: 30px;
            border: none;
            border-radius: 50%;
            background: #2c3e50;
            color: white;
            cursor: pointer;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .qty-btn:hover {
            background: #34495e;
        }

        .qty-input {
            width: 60px;
            text-align: center;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 0.25rem;
        }

        .remove-btn {
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 0.5rem;
            cursor: pointer;
            font-size: 0.8rem;
        }

        .remove-btn:hover {
            background: #c0392b;
        }

        /* Bill Totals */
        .bill-totals {
            padding: 1.5rem;
            background: #f8f9fa;
            border-top: 1px solid #eee;
            border-radius: 0 0 12px 12px;
        }

        .discount-section {
            margin-bottom: 1rem;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }

        .total-row.final {
            font-size: 1.3rem;
            font-weight: bold;
            padding-top: 0.5rem;
            border-top: 2px solid #2c3e50;
            color: #27ae60;
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
            border-radius: 8px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }

        .btn-success {
            background: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background: #229954;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: #7f8c8d;
            color: white;
        }

        .btn-secondary:hover {
            background: #95a5a6;
            transform: translateY(-2px);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state h3 {
            margin-bottom: 1rem;
            color: #2c3e50;
        }

        /* Quick Actions */
        .quick-actions {
            padding: 1rem 1.5rem;
            border-top: 1px solid #eee;
            display: flex;
            gap: 0.5rem;
        }

        .quick-btn {
            padding: 0.5rem 1rem;
            border: 1px solid #2c3e50;
            background: white;
            color: #2c3e50;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .quick-btn:hover {
            background: #2c3e50;
            color: white;
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

        @media (max-width: 1200px) {
            .pos-container {
                grid-template-columns: 1fr;
                height: auto;
            }
            
            .right-panel {
                order: -1;
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
            
            .items-container {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
            
            .user-info span {
                display: none;
            }
        }

        /* Loading State */
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }

        .loading::after {
            content: " Processing...";
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
                <h1 class="page-title">🧾 Create New Bill</h1>
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
                <h1>🏪 Point of Sale System</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="bill?action=list">Bills</a> &gt; 
                    Create Bill
                </div>
            </div>

            <!-- Success Message -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- POS Interface -->
            <form action="bill" method="post" id="createBillForm">
                <input type="hidden" name="action" value="create">
                
                <div class="pos-container">
                    <!-- Left Panel - Items & Customer -->
                    <div class="left-panel">
                        <div class="panel-header">
                            <h3>📦 Select Items</h3>
                        </div>
                        
                        <!-- Customer Selection -->
                        <div class="customer-section">
                            <div class="form-group">
                                <label for="customerId">👤 Select Customer <span class="required">*</span></label>
                                <select class="form-control" id="customerId" name="customerId" required>
                                    <option value="">Choose a customer...</option>
                                    <% if (customers != null) {
                                        for (Customer customer : customers) { %>
                                    <option value="<%= customer.getCustomerId() %>">
                                        <%= customer.getName() %> - <%= customer.getAccountNumber() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>

                        <!-- Items Grid -->
                        <div class="items-grid">
                            <div class="items-container">
                                <% if (items != null && !items.isEmpty()) {
                                    for (Item item : items) { %>
                                <div class="item-card" onclick="addItemToBill(<%= item.getItemId() %>, '<%= item.getName() %>', <%= item.getPrice() %>, <%= item.getStockQuantity() %>)">
                                    <h4><%= item.getName() %></h4>
                                    <div class="item-price">Rs. <%= String.format("%.2f", item.getPrice()) %></div>
                                    <div class="item-stock">Stock: <%= item.getStockQuantity() %></div>
                                </div>
                                <% } } else { %>
                                <div class="empty-state">
                                    <h3>No Items Available</h3>
                                    <p>Please add items to inventory first</p>
                                </div>
                                <% } %>
                            </div>
                        </div>

                        <!-- Quick Actions -->
                        <div class="quick-actions">
                            <button type="button" class="quick-btn" onclick="clearBill()">🗑️ Clear All</button>
                            <button type="button" class="quick-btn" onclick="addDiscount()">💰 Add Discount</button>
                        </div>
                    </div>

                    <!-- Right Panel - Bill Summary -->
                    <div class="right-panel">
                        <div class="panel-header">
                            <h3>🧾 Bill Summary</h3>
                        </div>

                        <!-- Bill Items -->
                        <div class="bill-items" id="billItems">
                            <div class="empty-state">
                                <h3>No Items Selected</h3>
                                <p>Click on items to add them to the bill</p>
                            </div>
                        </div>

                        <!-- Discount Section -->
                        <div class="bill-totals">
                            <div class="discount-section">
                                <div class="form-group">
                                    <label for="discount">💰 Discount (Rs.)</label>
                                    <input type="number" class="form-control" id="discount" name="discount" 
                                           value="0" min="0" step="0.01" onchange="calculateTotals()">
                                </div>
                            </div>

                            <!-- Totals -->
                            <div class="total-row">
                                <span>Sub Total:</span>
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
                                <span>💰 TOTAL:</span>
                                <span id="totalAmount">Rs. 0.00</span>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="action-buttons">
                            <button type="submit" class="btn btn-success" id="submitBtn">
                                ✅ Create Bill
                            </button>
                            <a href="bill?action=list" class="btn btn-secondary">
                                ❌ Cancel
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Hidden input fields for form submission -->
                <div id="hiddenInputs"></div>
            </form>
        </main>
    </div>

    <script>
        // Global variables
        let billItems = [];
        let itemRowCount = 0;

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

        // Add item to bill
        function addItemToBill(itemId, itemName, price, stock) {
            // Check if item already exists in bill
            const existingItem = billItems.find(item => item.id === itemId);
            
            if (existingItem) {
                if (existingItem.quantity < stock) {
                    existingItem.quantity++;
                    updateBillDisplay();
                } else {
                    alert(`Cannot add more ${itemName}. Stock limit reached.`);
                }
            } else {
                billItems.push({
                    id: itemId,
                    name: itemName,
                    price: price,
                    quantity: 1,
                    stock: stock
                });
                updateBillDisplay();
            }
        }

        // Update bill display
        function updateBillDisplay() {
            const billItemsContainer = document.getElementById('billItems');
            
            if (billItems.length === 0) {
                billItemsContainer.innerHTML = `
                    <div class="empty-state">
                        <h3>No Items Selected</h3>
                        <p>Click on items to add them to the bill</p>
                    </div>
                `;
            } else {
                billItemsContainer.innerHTML = billItems.map((item, index) => `
                    <div class="bill-item">
                        <div class="bill-item-info">
                            <div class="bill-item-name">${item.name}</div>
                            <div class="bill-item-details">Rs. ${item.price.toFixed(2)} each</div>
                        </div>
                        <div class="quantity-controls">
                            <button type="button" class="qty-btn" onclick="decreaseQuantity(${index})">-</button>
                            <input type="number" class="qty-input" value="${item.quantity}" min="1" max="${item.stock}" 
                                   onchange="updateQuantity(${index}, this.value)">
                            <button type="button" class="qty-btn" onclick="increaseQuantity(${index})">+</button>
                            <button type="button" class="remove-btn" onclick="removeItem(${index})">🗑️</button>
                        </div>
                    </div>
                `).join('');
            }
            
            updateHiddenInputs();
            calculateTotals();
        }

        // Quantity management functions
        function increaseQuantity(index) {
            const item = billItems[index];
            if (item.quantity < item.stock) {
                item.quantity++;
                updateBillDisplay();
            } else {
                alert(`Cannot add more ${item.name}. Stock limit reached.`);
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
                alert(`Maximum quantity for ${item.name} is ${item.stock}`);
                updateBillDisplay(); // Reset to previous value
            } else {
                removeItem(index);
            }
        }

        function removeItem(index) {
            billItems.splice(index, 1);
            updateBillDisplay();
        }

        // Clear all items
        function clearBill() {
            if (billItems.length > 0 && confirm('Are you sure you want to clear all items?')) {
                billItems = [];
                updateBillDisplay();
            }
        }

        // Add discount functionality
        function addDiscount() {
            const currentDiscount = document.getElementById('discount').value;
            const newDiscount = prompt('Enter discount amount (Rs.):', currentDiscount);
            
            if (newDiscount !== null && !isNaN(newDiscount) && parseFloat(newDiscount) >= 0) {
                document.getElementById('discount').value = parseFloat(newDiscount);
                calculateTotals();
            }
        }

        // Calculate totals
        function calculateTotals() {
            let subTotal = 0;
            
            billItems.forEach(item => {
                subTotal += item.price * item.quantity;
            });
            
            const discount = parseFloat(document.getElementById('discount').value) || 0;
            const taxableAmount = subTotal - discount;
            const tax = taxableAmount * 0.05; // 5% tax
            const totalAmount = taxableAmount + tax;
            
            document.getElementById('subTotal').textContent = `Rs. ${subTotal.toFixed(2)}`;
            document.getElementById('discountAmount').textContent = `Rs. ${discount.toFixed(2)}`;
            document.getElementById('taxAmount').textContent = `Rs. ${tax.toFixed(2)}`;
            document.getElementById('totalAmount').textContent = `Rs. ${totalAmount.toFixed(2)}`;
        }

        // Update hidden inputs for form submission
        function updateHiddenInputs() {
            const hiddenInputsContainer = document.getElementById('hiddenInputs');
            hiddenInputsContainer.innerHTML = '';
            
            billItems.forEach((item, index) => {
                hiddenInputsContainer.innerHTML += `
                    <input type="hidden" name="itemId" value="${item.id}">
                    <input type="hidden" name="quantity" value="${item.quantity}">
                    <input type="hidden" name="unitPrice" value="${item.price}">
                `;
            });
        }

        // Form validation and submission
        document.getElementById('createBillForm').addEventListener('submit', function(e) {
            const customerId = document.getElementById('customerId').value;
            const submitBtn = document.getElementById('submitBtn');
            
            // Validate customer selection
            if (!customerId) {
                e.preventDefault();
                alert('Please select a customer before creating the bill.');
                return;
            }
            
            // Validate bill items
            if (billItems.length === 0) {
                e.preventDefault();
                alert('Please add at least one item to the bill.');
                return;
            }
            
            // Check total amount
            const totalAmount = parseFloat(document.getElementById('totalAmount').textContent.replace('Rs. ', ''));
            if (totalAmount <= 0) {
                e.preventDefault();
                alert('Bill total must be greater than 0.');
                return;
            }
            
            // Show loading state
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '⏳ Creating Bill...';
        });

        // Auto-select customer if only one exists
        document.addEventListener('DOMContentLoaded', function() {
            const customerSelect = document.getElementById('customerId');
            if (customerSelect.options.length === 2) { // Only "Choose customer" + 1 customer
                customerSelect.selectedIndex = 1;
            }
            
            // Initialize discount change listener
            document.getElementById('discount').addEventListener('input', calculateTotals);
            
            // Initialize calculations
            calculateTotals();
        });

        // Search functionality for items (optional enhancement)
        function searchItems(query) {
            const itemCards = document.querySelectorAll('.item-card');
            itemCards.forEach(card => {
                const itemName = card.querySelector('h4').textContent.toLowerCase();
                if (itemName.includes(query.toLowerCase())) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // ESC key closes sidebar on mobile
            if (e.key === 'Escape' && sidebar.classList.contains('active')) {
                toggleSidebar();
            }
            
            // Ctrl+S to submit form (prevent default save)
            if (e.ctrlKey && e.key === 's') {
                e.preventDefault();
                document.getElementById('createBillForm').dispatchEvent(new Event('submit'));
            }
            
            // Ctrl+D to add discount
            if (e.ctrlKey && e.key === 'd') {
                e.preventDefault();
                addDiscount();
            }
        });

        // Item card selection visual feedback
        function highlightSelectedItem(itemId) {
            // Remove previous highlights
            document.querySelectorAll('.item-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // Add highlight to current item
            const selectedCard = document.querySelector(`[onclick*="${itemId}"]`);
            if (selectedCard) {
                selectedCard.classList.add('selected');
                setTimeout(() => {
                    selectedCard.classList.remove('selected');
                }, 300);
            }
        }

        // Enhanced addItemToBill with visual feedback
        const originalAddItemToBill = addItemToBill;
        addItemToBill = function(itemId, itemName, price, stock) {
            highlightSelectedItem(itemId);
            originalAddItemToBill(itemId, itemName, price, stock);
        };
    </script>
</body>
</html>