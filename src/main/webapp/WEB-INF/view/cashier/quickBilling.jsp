<!-- ================================================================ -->
<!-- quickBilling.jsp - Quick Billing Interface -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Item"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Item> items = (List<Item>) request.getAttribute("items");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quick Billing - Redupahana</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; }
        .navbar { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .container { max-width: 1400px; margin: 1rem auto; padding: 0 1rem; }
        .billing-layout { display: grid; grid-template-columns: 1fr 400px; gap: 1rem; height: calc(100vh - 120px); }
        .main-panel { background: white; border-radius: 8px; padding: 1.5rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .sidebar { background: white; border-radius: 8px; padding: 1.5rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .customer-search { margin-bottom: 1rem; }
        .customer-search input { width: 100%; padding: 0.8rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; }
        .item-search { margin-bottom: 1rem; }
        .item-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 1rem; max-height: 400px; overflow-y: auto; }
        .item-card { border: 1px solid #ddd; border-radius: 6px; padding: 1rem; cursor: pointer; transition: all 0.3s; text-align: center; }
        .item-card:hover { border-color: #27ae60; background-color: #f8f9fa; }
        .item-name { font-weight: 600; margin-bottom: 0.5rem; }
        .item-price { color: #27ae60; font-weight: 600; }
        .item-stock { font-size: 0.8rem; color: #7f8c8d; }
        .bill-summary h3 { margin-bottom: 1rem; color: #2c3e50; }
        .bill-items { margin-bottom: 1rem; max-height: 300px; overflow-y: auto; }
        .bill-item { display: flex; justify-content: space-between; align-items: center; padding: 0.5rem; border-bottom: 1px solid #ecf0f1; }
        .bill-totals { border-top: 2px solid #27ae60; padding-top: 1rem; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 0.5rem; }
        .total-row.final { font-weight: bold; font-size: 1.2rem; color: #2c3e50; }
        .btn { padding: 0.8rem 1.5rem; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; transition: all 0.3s; }
        .btn-success { background-color: #27ae60; color: white; width: 100%; margin-top: 1rem; }
        .btn-success:hover { background-color: #229954; }
        .btn-danger { background-color: #e74c3c; color: white; padding: 0.3rem 0.6rem; font-size: 0.8rem; }
        .quantity-controls { display: flex; align-items: center; gap: 0.5rem; }
        .quantity-btn { background-color: #3498db; color: white; border: none; border-radius: 3px; width: 25px; height: 25px; cursor: pointer; }
        @media (max-width: 1200px) {
            .billing-layout { grid-template-columns: 1fr; height: auto; }
            .sidebar { order: -1; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>💳 Quick Billing</h1>
        <div style="display: flex; gap: 1rem;">
            <a href="dashboard" style="color: white; text-decoration: none; padding: 0.5rem 1rem; border-radius: 4px; background-color: rgba(255,255,255,0.2);">Dashboard</a>
            <a href="auth?action=logout" style="color: white; text-decoration: none; padding: 0.5rem 1rem; border-radius: 4px; background-color: rgba(255,255,255,0.2);">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="billing-layout">
            <div class="main-panel">
                <div class="customer-search">
                    <input type="text" id="customerSearch" placeholder="🔍 Search customer by name or phone..." onkeyup="searchCustomers()">
                    <div id="customerResults" style="margin-top: 0.5rem;"></div>
                </div>

                <div class="item-search">
                    <input type="text" id="itemSearch" placeholder="🔍 Search items..." onkeyup="searchItems()">
                </div>

                <div class="item-grid" id="itemGrid">
                    <!-- Items will be loaded here -->
                </div>
            </div>

            <div class="sidebar">
                <div class="bill-summary">
                    <h3>📋 Current Bill</h3>
                    <div id="selectedCustomer" style="padding: 0.5rem; background-color: #f8f9fa; border-radius: 4px; margin-bottom: 1rem; font-size: 0.9rem;">
                        No customer selected
                    </div>
                    
                    <div class="bill-items" id="billItems">
                        <div style="text-align: center; color: #7f8c8d; padding: 2rem;">
                            No items added
                        </div>
                    </div>

                    <div class="bill-totals">
                        <div class="total-row">
                            <span>Subtotal:</span>
                            <span id="subtotal">Rs. 0.00</span>
                        </div>
                        <div class="total-row">
                            <span>Tax (5%):</span>
                            <span id="tax">Rs. 0.00</span>
                        </div>
                        <div class="total-row final">
                            <span>Total:</span>
                            <span id="total">Rs. 0.00</span>
                        </div>
                    </div>

                    <button class="btn btn-success" onclick="completeBill()">
                        💳 Complete Purchase
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedCustomer = null;
        let billItems = [];
        let allItems = [];
        let allCustomers = [];

        document.addEventListener('DOMContentLoaded', function() {
            loadItems();
            loadCustomers();
        });

        function loadItems() {
            // Mock data - replace with actual API call
            allItems = [
                {id: 1, name: 'Smartphone', price: 25000, stock: 50, category: 'Electronics'},
                {id: 2, name: 'T-Shirt', price: 1500, stock: 100, category: 'Clothing'},
                {id: 3, name: 'Novel Book', price: 800, stock: 25, category: 'Books'},
                {id: 4, name: 'Coffee Mug', price: 500, stock: 200, category: 'Home'}
            ];
            displayItems(allItems);
        }

        function loadCustomers() {
            // Mock data - replace with actual API call
            allCustomers = [
                {id: 1, name: 'John Doe', phone: '0771234567', accountNumber: 'ACC001'},
                {id: 2, name: 'Jane Smith', phone: '0779876543', accountNumber: 'ACC002'},
                {id: 3, name: 'Bob Johnson', phone: '0775555555', accountNumber: 'ACC003'}
            ];
        }

        function displayItems(items) {
            const itemGrid = document.getElementById('itemGrid');
            itemGrid.innerHTML = items.map(item => `
                <div class="item-card" onclick="addItemToBill(${item.id})">
                    <div class="item-name">${item.name}</div>
                    <div class="item-price">Rs. ${item.price.toLocaleString()}</div>
                    <div class="item-stock">Stock: ${item.stock}</div>
                </div>
            `).join('');
        }

        function searchItems() {
            const searchTerm = document.getElementById('itemSearch').value.toLowerCase();
            const filteredItems = allItems.filter(item => 
                item.name.toLowerCase().includes(searchTerm) ||
                item.category.toLowerCase().includes(searchTerm)
            );
            displayItems(filteredItems);
        }

        function searchCustomers() {
            const searchTerm = document.getElementById('customerSearch').value.toLowerCase();
            const customerResults = document.getElementById('customerResults');
            
            if (searchTerm.length < 2) {
                customerResults.innerHTML = '';
                return;
            }

            const filteredCustomers = allCustomers.filter(customer => 
                customer.name.toLowerCase().includes(searchTerm) ||
                customer.phone.includes(searchTerm) ||
                customer.accountNumber.toLowerCase().includes(searchTerm)
            );

            customerResults.innerHTML = filteredCustomers.map(customer => `
                <div style="padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px; margin-bottom: 0.25rem; cursor: pointer; background-color: white;" 
                     onclick="selectCustomer(${customer.id})">
                    <strong>${customer.name}</strong><br>
                    <small>${customer.phone} | ${customer.accountNumber}</small>
                </div>
            `).join('');
        }

        function selectCustomer(customerId) {
            selectedCustomer = allCustomers.find(c => c.id === customerId);
            document.getElementById('selectedCustomer').innerHTML = `
                👤 ${selectedCustomer.name}<br>
                <small>${selectedCustomer.phone}</small>
            `;
            document.getElementById('customerResults').innerHTML = '';
            document.getElementById('customerSearch').value = selectedCustomer.name;
        }

        function addItemToBill(itemId) {
            const item = allItems.find(i => i.id === itemId);
            const existingItem = billItems.find(bi => bi.id === itemId);

            if (existingItem) {
                existingItem.quantity += 1;
            } else {
                billItems.push({...item, quantity: 1});
            }

            updateBillDisplay();
        }

        function removeItemFromBill(itemId) {
            billItems = billItems.filter(item => item.id !== itemId);
            updateBillDisplay();
        }

        function updateQuantity(itemId, change) {
            const item = billItems.find(bi => bi.id === itemId);
            if (item) {
                item.quantity += change;
                if (item.quantity <= 0) {
                    removeItemFromBill(itemId);
                } else {
                    updateBillDisplay();
                }
            }
        }

        function updateBillDisplay() {
            const billItemsContainer = document.getElementById('billItems');
            
            if (billItems.length === 0) {
                billItemsContainer.innerHTML = '<div style="text-align: center; color: #7f8c8d; padding: 2rem;">No items added</div>';
            } else {
                billItemsContainer.innerHTML = billItems.map(item => `
                    <div class="bill-item">
                        <div>
                            <div style="font-weight: 600;">${item.name}</div>
                            <div style="font-size: 0.9rem; color: #7f8c8d;">Rs. ${item.price.toLocaleString()} each</div>
                        </div>
                        <div class="quantity-controls">
                            <button class="quantity-btn" onclick="updateQuantity(${item.id}, -1)">-</button>
                            <span style="margin: 0 0.5rem; font-weight: 600;">${item.quantity}</span>
                            <button class="quantity-btn" onclick="updateQuantity(${item.id}, 1)">+</button>
                            <button class="btn-danger" onclick="removeItemFromBill(${item.id})" style="margin-left: 0.5rem;">×</button>
                        </div>
                    </div>
                `).join('');
            }

            // Calculate totals
            const subtotal = billItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            const tax = subtotal * 0.05;
            const total = subtotal + tax;

            document.getElementById('subtotal').textContent = 'Rs. ' + subtotal.toLocaleString() + '.00';
            document.getElementById('tax').textContent = 'Rs. ' + tax.toFixed(2);
            document.getElementById('total').textContent = 'Rs. ' + total.toFixed(2);
        }

        function completeBill() {
            if (!selectedCustomer) {
                alert('Please select a customer first.');
                return;
            }

            if (billItems.length === 0) {
                alert('Please add items to the bill.');
                return;
            }

            const total = billItems.reduce((sum, item) => sum + (item.price * item.quantity), 0) * 1.05;
            
            if (confirm(`Complete purchase for ${selectedCustomer.name}?\nTotal: Rs. ${total.toFixed(2)}`)) {
                // Here you would normally submit to the server
                alert('Bill completed successfully!');
                
                // Reset the form
                selectedCustomer = null;
                billItems = [];
                document.getElementById('selectedCustomer').innerHTML = 'No customer selected';
                document.getElementById('customerSearch').value = '';
                updateBillDisplay();
            }
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.key === 'F2') {
                e.preventDefault();
                document.getElementById('customerSearch').focus();
            } else if (e.key === 'F3') {
                e.preventDefault();
                document.getElementById('itemSearch').focus();
            } else if (e.key === 'F12') {
                e.preventDefault();
                completeBill();
            }
        });
    </script>
</body>
</html>