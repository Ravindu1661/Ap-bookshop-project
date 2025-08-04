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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Bill - Redupahana</title>
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
        }

        .navbar h1 {
            font-size: 1.5rem;
        }

        .nav-links {
            display: flex;
            gap: 1rem;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .nav-links a:hover {
            background-color: #34495e;
        }

        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .page-header h2 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .breadcrumb {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .breadcrumb a {
            color: #3498db;
            text-decoration: none;
        }

        .form-container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
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
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }

        .items-section {
            border: 2px solid #3498db;
            border-radius: 8px;
            padding: 1.5rem;
            margin: 2rem 0;
        }

        .items-section h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.5rem;
        }

        .item-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr 100px;
            gap: 1rem;
            align-items: end;
            margin-bottom: 1rem;
            padding: 1rem;
            background-color: #f8f9fa;
            border-radius: 4px;
        }

        .item-row:first-child {
            background-color: #e3f2fd;
            font-weight: 600;
        }

        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
            font-size: 1rem;
            text-align: center;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #229954;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
        }

        .btn-danger:hover {
            background-color: #c0392b;
        }

        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #7f8c8d;
        }

        .btn-sm {
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
        }

        .totals-section {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            margin: 2rem 0;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            padding: 0.5rem 0;
        }

        .total-row.final {
            border-top: 2px solid #2c3e50;
            font-weight: bold;
            font-size: 1.2rem;
            color: #2c3e50;
        }

        .alert {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .form-actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .item-row {
                grid-template-columns: 1fr;
                gap: 0.5rem;
            }

            .form-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Create Bill</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="bill?action=list">Bills</a>
            <a href="customer?action=list">Customers</a>
            <a href="item?action=list">Items</a>
            <a href="auth?action=logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2>Create New Bill</h2>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> &gt; 
                <a href="bill?action=list">Bills</a> &gt; 
                Create Bill
            </div>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="form-container">
            <form action="bill" method="post" id="createBillForm">
                <input type="hidden" name="action" value="create">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="customerId">Customer <span class="required">*</span></label>
                        <select class="form-control" id="customerId" name="customerId" required>
                            <option value="">Select Customer</option>
                            <% if (customers != null) {
                                for (Customer customer : customers) { %>
                            <option value="<%= customer.getCustomerId() %>">
                                <%= customer.getName() %> (<%= customer.getAccountNumber() %>)
                            </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="discount">Discount (Rs.)</label>
                        <input type="number" class="form-control" id="discount" name="discount" 
                               value="0" min="0" step="0.01">
                    </div>
                </div>

                <div class="items-section">
                    <h3>Bill Items</h3>
                    <div id="itemsContainer">
                        <div class="item-row">
                            <div>Item</div>
                            <div>Quantity</div>
                            <div>Unit Price (Rs.)</div>
                            <div>Total (Rs.)</div>
                            <div>Action</div>
                        </div>
                        <div class="item-row" data-row="0">
                            <div>
                                <select class="form-control item-select" name="itemId" required onchange="updateItemPrice(this)">
                                    <option value="">Select Item</option>
                                    <% if (items != null) {
                                        for (Item item : items) { %>
                                    <option value="<%= item.getItemId() %>" 
                                            data-price="<%= item.getPrice() %>"
                                            data-stock="<%= item.getStockQuantity() %>">
                                        <%= item.getName() %> (<%= item.getItemCode() %>) - Stock: <%= item.getStockQuantity() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                            <div>
                                <input type="number" class="form-control quantity-input" name="quantity" 
                                       min="1" required onchange="calculateRowTotal(this)">
                            </div>
                            <div>
                                <input type="number" class="form-control price-input" name="unitPrice" 
                                       step="0.01" min="0.01" required readonly>
                            </div>
                            <div>
                                <span class="row-total">0.00</span>
                            </div>
                            <div>
                                <button type="button" class="btn btn-danger btn-sm" onclick="removeItemRow(this)">Remove</button>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn btn-secondary btn-sm" onclick="addItemRow()">Add Another Item</button>
                </div>

                <div class="totals-section">
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
                        <span>Total Amount:</span>
                        <span id="totalAmount">Rs. 0.00</span>
                    </div>
                </div>

                <div class="form-actions">
                    <a href="bill?action=list" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-success">Create Bill</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        let itemRowCount = 1;

        document.addEventListener('DOMContentLoaded', function() {
            const discountInput = document.getElementById('discount');
            discountInput.addEventListener('input', calculateTotals);
            
            // Initialize first row
            const firstRow = document.querySelector('[data-row="0"]');
            if (firstRow) {
                const itemSelect = firstRow.querySelector('.item-select');
                const quantityInput = firstRow.querySelector('.quantity-input');
                const priceInput = firstRow.querySelector('.price-input');
                
                if (itemSelect) itemSelect.addEventListener('change', function() { updateItemPrice(this); });
                if (quantityInput) quantityInput.addEventListener('input', function() { calculateRowTotal(this); });
            }
        });

        function updateItemPrice(selectElement) {
            const selectedOption = selectElement.options[selectElement.selectedIndex];
            const row = selectElement.closest('.item-row');
            const priceInput = row.querySelector('.price-input');
            const quantityInput = row.querySelector('.quantity-input');
            
            if (selectedOption.value) {
                const price = selectedOption.getAttribute('data-price');
                const stock = selectedOption.getAttribute('data-stock');
                
                priceInput.value = parseFloat(price).toFixed(2);
                quantityInput.max = stock;
                quantityInput.title = `Available stock: ${stock}`;
                
                calculateRowTotal(quantityInput);
            } else {
                priceInput.value = '';
                quantityInput.max = '';
                quantityInput.title = '';
                calculateRowTotal(quantityInput);
            }
        }

        function calculateRowTotal(input) {
            const row = input.closest('.item-row');
            const quantity = parseFloat(row.querySelector('.quantity-input').value) || 0;
            const price = parseFloat(row.querySelector('.price-input').value) || 0;
            const totalSpan = row.querySelector('.row-total');
            
            const rowTotal = quantity * price;
            totalSpan.textContent = rowTotal.toFixed(2);
            
            calculateTotals();
        }

        function calculateTotals() {
            let subTotal = 0;
            const rowTotals = document.querySelectorAll('.row-total');
            
            rowTotals.forEach(total => {
                const value = parseFloat(total.textContent) || 0;
                subTotal += value;
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

        function addItemRow() {
            itemRowCount++;
            const container = document.getElementById('itemsContainer');
            const newRow = document.createElement('div');
            newRow.className = 'item-row';
            newRow.setAttribute('data-row', itemRowCount);
            
            newRow.innerHTML = `
                <div>
                    <select class="form-control item-select" name="itemId" required onchange="updateItemPrice(this)">
                        <option value="">Select Item</option>
                        <% if (items != null) {
                            for (Item item : items) { %>
                        <option value="<%= item.getItemId() %>" 
                                data-price="<%= item.getPrice() %>"
                                data-stock="<%= item.getStockQuantity() %>">
                            <%= item.getName() %> (<%= item.getItemCode() %>) - Stock: <%= item.getStockQuantity() %>
                        </option>
                        <% } } %>
                    </select>
                </div>
                <div>
                    <input type="number" class="form-control quantity-input" name="quantity" 
                           min="1" required onchange="calculateRowTotal(this)">
                </div>
                <div>
                    <input type="number" class="form-control price-input" name="unitPrice" 
                           step="0.01" min="0.01" required readonly>
                </div>
                <div>
                    <span class="row-total">0.00</span>
                </div>
                <div>
                    <button type="button" class="btn btn-danger btn-sm" onclick="removeItemRow(this)">Remove</button>
                </div>
            `;
            
            container.appendChild(newRow);
        }

        function removeItemRow(button) {
            const row = button.closest('.item-row');
            const container = document.getElementById('itemsContainer');
            const itemRows = container.querySelectorAll('.item-row[data-row]');
            
            if (itemRows.length > 1) {
                row.remove();
                calculateTotals();
            } else {
                alert('At least one item is required.');
            }
        }

        // Form validation
        document.getElementById('createBillForm').addEventListener('submit', function(e) {
            const itemRows = document.querySelectorAll('.item-row[data-row]');
            let hasValidItems = false;
            let errors = [];
            
            // Check if customer is selected
            const customerId = document.getElementById('customerId').value;
            if (!customerId) {
                errors.push('Please select a customer.');
            }
            
            // Validate items
            itemRows.forEach((row, index) => {
                const itemSelect = row.querySelector('.item-select');
                const quantityInput = row.querySelector('.quantity-input');
                const priceInput = row.querySelector('.price-input');
                
                if (itemSelect.value && quantityInput.value && priceInput.value) {
                    hasValidItems = true;
                    
                    // Check stock availability
                    const selectedOption = itemSelect.options[itemSelect.selectedIndex];
                    const stock = parseInt(selectedOption.getAttribute('data-stock'));
                    const quantity = parseInt(quantityInput.value);
                    
                    if (quantity > stock) {
                        errors.push(`Row ${index + 1}: Quantity (${quantity}) exceeds available stock (${stock}).`);
                    }
                }
            });
            
            if (!hasValidItems) {
                errors.push('Please add at least one valid item.');
            }
            
            // Check if total amount is greater than 0
            const totalAmount = parseFloat(document.getElementById('totalAmount').textContent.replace('Rs. ', ''));
            if (totalAmount <= 0) {
                errors.push('Bill total must be greater than 0.');
            }
            
            if (errors.length > 0) {
                e.preventDefault();
                alert('Please fix the following errors:\n\n' + errors.join('\n'));
                return false;
            }
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.textContent = 'Creating Bill...';
            submitBtn.disabled = true;
        });

        // Auto-select customer if only one exists
        document.addEventListener('DOMContentLoaded', function() {
            const customerSelect = document.getElementById('customerId');
            if (customerSelect.options.length === 2) { // Only "Select Customer" + 1 customer
                customerSelect.selectedIndex = 1;
            }
        });
    </script>
</body>
</html>