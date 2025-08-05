<!-- ================================================================ -->
<!-- quickBilling.jsp - Quick Book Billing Interface -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null || !Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
        response.sendRedirect("auth");
        return;
    }
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Book> books = (List<Book>) request.getAttribute("books");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quick Book Billing - Redupahana</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .navbar { 
            background: rgba(255, 255, 255, 0.1); 
            backdrop-filter: blur(10px);
            color: white; 
            padding: 1rem 2rem; 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .navbar h1 {
            font-size: 1.5rem;
            font-weight: 600;
        }
        
        .nav-links {
            display: flex;
            gap: 1rem;
        }
        
        .nav-link {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            background: rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .nav-link:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-1px);
        }
        
        .container { 
            max-width: 1400px; 
            margin: 1rem auto; 
            padding: 0 1rem; 
        }
        
        .billing-layout { 
            display: grid; 
            grid-template-columns: 1fr 420px; 
            gap: 1.5rem; 
            height: calc(100vh - 120px); 
        }
        
        .main-panel { 
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px; 
            padding: 1.5rem; 
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .sidebar { 
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px; 
            padding: 1.5rem; 
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .search-section {
            margin-bottom: 1.5rem;
        }
        
        .search-section h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .customer-search, .book-search { 
            margin-bottom: 1rem; 
        }
        
        .search-input { 
            width: 100%; 
            padding: 1rem; 
            border: 2px solid #e1e8ed;
            border-radius: 12px; 
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.9);
        }
        
        .search-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            background: white;
        }
        
        .customer-results {
            max-height: 200px;
            overflow-y: auto;
            margin-top: 0.5rem;
        }
        
        .customer-result-item {
            padding: 0.75rem;
            border: 1px solid #e1e8ed;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            cursor: pointer;
            background: white;
            transition: all 0.3s ease;
        }
        
        .customer-result-item:hover {
            border-color: #667eea;
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .customer-name {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.25rem;
        }
        
        .customer-details {
            font-size: 0.9rem;
            color: #7f8c8d;
        }
        
        .books-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); 
            gap: 1rem; 
            max-height: 500px; 
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #667eea #f1f3f4;
        }
        
        .books-grid::-webkit-scrollbar {
            width: 6px;
        }
        
        .books-grid::-webkit-scrollbar-track {
            background: #f1f3f4;
            border-radius: 3px;
        }
        
        .books-grid::-webkit-scrollbar-thumb {
            background: #667eea;
            border-radius: 3px;
        }
        
        .book-card { 
            border: 2px solid #e1e8ed;
            border-radius: 12px; 
            padding: 1rem; 
            cursor: pointer; 
            transition: all 0.3s ease; 
            text-align: center; 
            background: white;
            position: relative;
            overflow: hidden;
        }
        
        .book-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
            transition: left 0.5s ease;
        }
        
        .book-card:hover::before {
            left: 100%;
        }
        
        .book-card:hover { 
            border-color: #667eea; 
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
        }
        
        .book-card.selected {
            border-color: #27ae60;
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            transform: scale(1.02);
        }
        
        .book-title { 
            font-weight: 600; 
            margin-bottom: 0.5rem;
            color: #2c3e50;
            font-size: 0.95rem;
            height: 2.5rem;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        
        .book-author {
            color: #7f8c8d;
            font-size: 0.85rem;
            margin-bottom: 0.5rem;
            font-style: italic;
        }
        
        .book-price { 
            color: #27ae60; 
            font-weight: 700;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
        }
        
        .book-stock { 
            font-size: 0.8rem; 
            color: #7f8c8d;
            background: #f8f9fa;
            padding: 0.25rem 0.5rem;
            border-radius: 12px;
            display: inline-block;
        }
        
        .book-isbn {
            font-size: 0.75rem;
            color: #95a5a6;
            margin-top: 0.5rem;
        }
        
        .bill-summary h3 { 
            margin-bottom: 1rem; 
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .selected-customer {
            padding: 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            text-align: center;
        }
        
        .bill-items { 
            margin-bottom: 1rem; 
            max-height: 320px; 
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #667eea #f1f3f4;
        }
        
        .bill-items::-webkit-scrollbar {
            width: 6px;
        }
        
        .bill-items::-webkit-scrollbar-track {
            background: #f1f3f4;
            border-radius: 3px;
        }
        
        .bill-items::-webkit-scrollbar-thumb {
            background: #667eea;
            border-radius: 3px;
        }
        
        .bill-item { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            padding: 1rem;
            border: 1px solid #e1e8ed;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            background: white;
            transition: all 0.3s ease;
        }
        
        .bill-item:hover {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .bill-item-info {
            flex: 1;
        }
        
        .bill-item-title {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.25rem;
        }
        
        .bill-item-details {
            font-size: 0.9rem;
            color: #7f8c8d;
        }
        
        .bill-totals { 
            border-top: 2px solid #667eea; 
            padding-top: 1rem;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            padding: 1rem;
            margin-top: 1rem;
        }
        
        .total-row { 
            display: flex; 
            justify-content: space-between; 
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }
        
        .total-row.final { 
            font-weight: bold; 
            font-size: 1.3rem; 
            color: #27ae60;
            padding-top: 0.5rem;
            border-top: 1px solid #dee2e6;
        }
        
        .btn { 
            padding: 1rem 1.5rem; 
            border: none; 
            border-radius: 12px; 
            cursor: pointer; 
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-success { 
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
            color: white; 
            width: 100%; 
            margin-top: 1rem;
            box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
        }
        
        .btn-success:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(39, 174, 96, 0.4);
        }
        
        .btn-danger { 
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            color: white; 
            padding: 0.4rem 0.8rem; 
            font-size: 0.8rem;
            border-radius: 6px;
        }
        
        .quantity-controls { 
            display: flex; 
            align-items: center; 
            gap: 0.5rem; 
        }
        
        .quantity-btn { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            border: none; 
            border-radius: 6px; 
            width: 30px; 
            height: 30px; 
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .quantity-btn:hover {
            transform: scale(1.1);
        }
        
        .quantity-display {
            background: #f8f9fa;
            padding: 0.5rem;
            border-radius: 6px;
            min-width: 40px;
            text-align: center;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .empty-state {
            text-align: center;
            color: #7f8c8d;
            padding: 3rem 1rem;
        }
        
        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }
        
        .keyboard-shortcuts {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            padding: 0.75rem;
            margin-top: 1rem;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.8);
        }
        
        .shortcut {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.2rem 0.4rem;
            border-radius: 4px;
            margin: 0.2rem;
            font-family: monospace;
        }
        
        @media (max-width: 1200px) {
            .billing-layout { 
                grid-template-columns: 1fr; 
                height: auto; 
            }
            .sidebar { 
                order: -1; 
            }
        }
        
        @media (max-width: 768px) {
            .navbar {
                padding: 1rem;
                flex-direction: column;
                gap: 1rem;
            }
            
            .nav-links {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .books-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
        }
        
        /* Loading Animation */
        .loading {
            opacity: 0.7;
            pointer-events: none;
        }
        
        .loading::after {
            content: " Processing...";
            animation: dots 1.5s steps(5, end) infinite;
        }
        
        @keyframes dots {
            0%, 20% { content: " Processing"; }
            40% { content: " Processing."; }
            60% { content: " Processing.."; }
            80%, 100% { content: " Processing..."; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>📚 Quick Book Billing</h1>
        <div class="nav-links">
            <a href="dashboard" class="nav-link">📊 Dashboard</a>
            <a href="book?action=list" class="nav-link">📚 Books</a>
            <a href="bill?action=list" class="nav-link">🧾 Bills</a>
            <a href="auth?action=logout" class="nav-link">🚪 Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="billing-layout">
            <div class="main-panel">
                <div class="search-section">
                    <h3>👤 Customer Search</h3>
                    <div class="customer-search">
                        <input type="text" id="customerSearch" class="search-input" 
                               placeholder="🔍 Search customer by name, phone, or account number..." 
                               onkeyup="searchCustomers()" autocomplete="off">
                        <div id="customerResults" class="customer-results"></div>
                    </div>
                </div>

                <div class="search-section">
                    <h3>📚 Book Search</h3>
                    <div class="book-search">
                        <input type="text" id="bookSearch" class="search-input" 
                               placeholder="🔍 Search books by title, author, or ISBN..." 
                               onkeyup="searchBooks()" autocomplete="off">
                    </div>
                </div>

                <div class="books-grid" id="booksGrid">
                    <!-- Books will be loaded here -->
                </div>
            </div>

            <div class="sidebar">
                <div class="bill-summary">
                    <h3>🧾 Current Bill</h3>
                    <div id="selectedCustomer" class="selected-customer">
                        <div class="empty-state-icon">👤</div>
                        No customer selected
                    </div>
                    
                    <div class="bill-items" id="billItems">
                        <div class="empty-state">
                            <div class="empty-state-icon">📚</div>
                            <div>No books added</div>
                            <small>Click on books to add them</small>
                        </div>
                    </div>

                    <div class="bill-totals">
                        <div class="total-row">
                            <span>📊 Subtotal:</span>
                            <span id="subtotal">Rs. 0.00</span>
                        </div>
                        <div class="total-row">
                            <span>💰 Tax (5%):</span>
                            <span id="tax">Rs. 0.00</span>
                        </div>
                        <div class="total-row final">
                            <span>🏆 Total:</span>
                            <span id="total">Rs. 0.00</span>
                        </div>
                    </div>

                    <button class="btn btn-success" onclick="completeBill()" id="completeBillBtn">
                        💳 Complete Purchase
                    </button>
                </div>
                
                <div class="keyboard-shortcuts">
                    <strong>Keyboard Shortcuts:</strong><br>
                    <span class="shortcut">F2</span> Customer Search
                    <span class="shortcut">F3</span> Book Search
                    <span class="shortcut">F12</span> Complete Bill
                    <span class="shortcut">Esc</span> Clear Search
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedCustomer = null;
        let billItems = [];
        let allBooks = [];
        let allCustomers = [];

        document.addEventListener('DOMContentLoaded', function() {
            loadBooks();
            loadCustomers();
            
        document.addEventListener('DOMContentLoaded', function() {
            loadBooks();
            loadCustomers();
            
            // Focus on customer search initially
            document.getElementById('customerSearch').focus();
        });

        function loadBooks() {
            // Load books from JSP data
            allBooks = [
                <% if (books != null) {
                    for (int i = 0; i < books.size(); i++) {
                        Book book = books.get(i); %>
                {
                    id: <%= book.getBookId() %>,
                    title: '<%= book.getTitle().replace("'", "\\'") %>',
                    author: '<%= book.getAuthor() != null ? book.getAuthor().replace("'", "\\'") : "" %>',
                    price: <%= book.getPrice() %>,
                    stock: <%= book.getStockQuantity() %>,
                    isbn: '<%= book.getIsbn() != null ? book.getIsbn() : "" %>',
                    publisher: '<%= book.getPublisher() != null ? book.getPublisher().replace("'", "\\'") : "" %>'
                }<%= i < books.size() - 1 ? "," : "" %>
                <% } } %>
            ];
            displayBooks(allBooks);
        }

        function loadCustomers() {
            // Load customers from JSP data
            allCustomers = [
                <% if (customers != null) {
                    for (int i = 0; i < customers.size(); i++) {
                        Customer customer = customers.get(i); %>
                {
                    id: <%= customer.getCustomerId() %>,
                    name: '<%= customer.getName().replace("'", "\\'") %>',
                    phone: '<%= customer.getPhone() != null ? customer.getPhone() : "" %>',
                    accountNumber: '<%= customer.getAccountNumber() %>',
                    email: '<%= customer.getEmail() != null ? customer.getEmail() : "" %>'
                }<%= i < customers.size() - 1 ? "," : "" %>
                <% } } %>
            ];
        }

        function displayBooks(books) {
            const booksGrid = document.getElementById('booksGrid');
            if (books.length === 0) {
                booksGrid.innerHTML = `
                    <div class="empty-state" style="grid-column: 1 / -1;">
                        <div class="empty-state-icon">📚</div>
                        <div>No books found</div>
                        <small>Try different search terms</small>
                    </div>
                `;
                return;
            }

            booksGrid.innerHTML = books.map(book => `
                <div class="book-card" onclick="addBookToBill(${book.id})" data-book-id="${book.id}">
                    <div class="book-title">${book.title}</div>
                    ${book.author ? `<div class="book-author">by ${book.author}</div>` : ''}
                    <div class="book-price">Rs. ${book.price.toLocaleString()}</div>
                    <div class="book-stock">Stock: ${book.stock}</div>
                    ${book.isbn ? `<div class="book-isbn">ISBN: ${book.isbn}</div>` : ''}
                </div>
            `).join('');
        }

        function searchBooks() {
            const searchTerm = document.getElementById('bookSearch').value.toLowerCase().trim();
            if (searchTerm === '') {
                displayBooks(allBooks);
                return;
            }

            const filteredBooks = allBooks.filter(book => 
                book.title.toLowerCase().includes(searchTerm) ||
                book.author.toLowerCase().includes(searchTerm) ||
                book.isbn.toLowerCase().includes(searchTerm) ||
                book.publisher.toLowerCase().includes(searchTerm)
            );
            displayBooks(filteredBooks);
        }

        function searchCustomers() {
            const searchTerm = document.getElementById('customerSearch').value.toLowerCase().trim();
            const customerResults = document.getElementById('customerResults');
            
            if (searchTerm.length < 2) {
                customerResults.innerHTML = '';
                return;
            }

            const filteredCustomers = allCustomers.filter(customer => 
                customer.name.toLowerCase().includes(searchTerm) ||
                customer.phone.includes(searchTerm) ||
                customer.accountNumber.toLowerCase().includes(searchTerm) ||
                customer.email.toLowerCase().includes(searchTerm)
            );

            if (filteredCustomers.length === 0) {
                customerResults.innerHTML = `
                    <div class="customer-result-item" style="text-align: center; color: #7f8c8d;">
                        No customers found
                    </div>
                `;
                return;
            }

            customerResults.innerHTML = filteredCustomers.map(customer => `
                <div class="customer-result-item" onclick="selectCustomer(${customer.id})">
                    <div class="customer-name">${customer.name}</div>
                    <div class="customer-details">
                        ${customer.phone ? `📞 ${customer.phone}` : ''} 
                        ${customer.phone && customer.accountNumber ? ' | ' : ''}
                        ${customer.accountNumber ? `🆔 ${customer.accountNumber}` : ''}
                    </div>
                </div>
            `).join('');
        }

        function selectCustomer(customerId) {
            selectedCustomer = allCustomers.find(c => c.id === customerId);
            document.getElementById('selectedCustomer').innerHTML = `
                <div>👤 <strong>${selectedCustomer.name}</strong></div>
                <div style="font-size: 0.85rem; margin-top: 0.25rem;">
                    ${selectedCustomer.phone ? `📞 ${selectedCustomer.phone}` : ''}
                    ${selectedCustomer.phone && selectedCustomer.accountNumber ? '<br>' : ''}
                    ${selectedCustomer.accountNumber ? `🆔 ${selectedCustomer.accountNumber}` : ''}
                </div>
            `;
            document.getElementById('customerResults').innerHTML = '';
            document.getElementById('customerSearch').value = selectedCustomer.name;
            
            // Focus on book search after customer selection
            document.getElementById('bookSearch').focus();
        }

        function addBookToBill(bookId) {
            const book = allBooks.find(b => b.id === bookId);
            if (!book) return;

            const existingItem = billItems.find(bi => bi.id === bookId);

            if (existingItem) {
                if (existingItem.quantity < book.stock) {
                    existingItem.quantity += 1;
                } else {
                    alert(`Cannot add more "${book.title}". Stock limit reached (${book.stock}).`);
                    return;
                }
            } else {
                if (book.stock <= 0) {
                    alert(`"${book.title}" is out of stock.`);
                    return;
                }
                billItems.push({...book, quantity: 1});
            }

            // Visual feedback
            highlightBookCard(bookId);
            updateBillDisplay();
        }

        function highlightBookCard(bookId) {
            // Remove previous highlights
            document.querySelectorAll('.book-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // Add highlight to selected book
            const bookCard = document.querySelector(`[data-book-id="${bookId}"]`);
            if (bookCard) {
                bookCard.classList.add('selected');
                setTimeout(() => {
                    bookCard.classList.remove('selected');
                }, 500);
            }
        }

        function removeBookFromBill(bookId) {
            if (confirm('Remove this book from the bill?')) {
                billItems = billItems.filter(item => item.id !== bookId);
                updateBillDisplay();
            }
        }

        function updateQuantity(bookId, change) {
            const item = billItems.find(bi => bi.id === bookId);
            const book = allBooks.find(b => b.id === bookId);
            
            if (item && book) {
                const newQuantity = item.quantity + change;
                
                if (newQuantity <= 0) {
                    removeBookFromBill(bookId);
                } else if (newQuantity > book.stock) {
                    alert(`Maximum quantity for "${book.title}" is ${book.stock}`);
                } else {
                    item.quantity = newQuantity;
                    updateBillDisplay();
                }
            }
        }

        function updateBillDisplay() {
            const billItemsContainer = document.getElementById('billItems');
            
            if (billItems.length === 0) {
                billItemsContainer.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📚</div>
                        <div>No books added</div>
                        <small>Click on books to add them</small>
                    </div>
                `;
            } else {
                billItemsContainer.innerHTML = billItems.map(item => `
                    <div class="bill-item">
                        <div class="bill-item-info">
                            <div class="bill-item-title">${item.title}</div>
                            <div class="bill-item-details">
                                ${item.author ? `by ${item.author} • ` : ''}Rs. ${item.price.toLocaleString()} each
                            </div>
                        </div>
                        <div class="quantity-controls">
                            <button class="quantity-btn" onclick="updateQuantity(${item.id}, -1)">−</button>
                            <div class="quantity-display">${item.quantity}</div>
                            <button class="quantity-btn" onclick="updateQuantity(${item.id}, 1)">+</button>
                            <button class="btn-danger" onclick="removeBookFromBill(${item.id})" style="margin-left: 0.5rem;">×</button>
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
                document.getElementById('customerSearch').focus();
                return;
            }

            if (billItems.length === 0) {
                alert('Please add books to the bill.');
                document.getElementById('bookSearch').focus();
                return;
            }

            const total = billItems.reduce((sum, item) => sum + (item.price * item.quantity), 0) * 1.05;
            const bookCount = billItems.reduce((sum, item) => sum + item.quantity, 0);
            
            const confirmMessage = `Complete purchase for ${selectedCustomer.name}?\n\n` +
                                 `Books: ${bookCount} item(s)\n` +
                                 `Total: Rs. ${total.toFixed(2)}`;
            
            if (confirm(confirmMessage)) {
                const completeBillBtn = document.getElementById('completeBillBtn');
                completeBillBtn.classList.add('loading');
                completeBillBtn.disabled = true;
                completeBillBtn.innerHTML = '⏳ Processing';
                
                // Simulate API call
                setTimeout(() => {
                    // Here you would normally submit to the server
                    // For now, we'll just show success and reset
                    alert(`Bill completed successfully!\nTotal: Rs. ${total.toFixed(2)}\nThank you for your purchase!`);
                    
                    // Reset the form
                    resetBill();
                    
                    // Reset button
                    completeBillBtn.classList.remove('loading');
                    completeBillBtn.disabled = false;
                    completeBillBtn.innerHTML = '💳 Complete Purchase';
                }, 1500);
            }
        }

        function resetBill() {
            selectedCustomer = null;
            billItems = [];
            document.getElementById('selectedCustomer').innerHTML = `
                <div class="empty-state-icon">👤</div>
                No customer selected
            `;
            document.getElementById('customerSearch').value = '';
            document.getElementById('bookSearch').value = '';
            document.getElementById('customerResults').innerHTML = '';
            updateBillDisplay();
            displayBooks(allBooks);
            
            // Focus back to customer search
            document.getElementById('customerSearch').focus();
        }

        function clearSearch() {
            document.getElementById('customerSearch').value = '';
            document.getElementById('bookSearch').value = '';
            document.getElementById('customerResults').innerHTML = '';
            displayBooks(allBooks);
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            switch(e.key) {
                case 'F2':
                    e.preventDefault();
                    document.getElementById('customerSearch').focus();
                    break;
                case 'F3':
                    e.preventDefault();
                    document.getElementById('bookSearch').focus();
                    break;
                case 'F12':
                    e.preventDefault();
                    completeBill();
                    break;
                case 'Escape':
                    e.preventDefault();
                    clearSearch();
                    break;
                case 'Enter':
                    // If focus is on customer search and there's exactly one result, select it
                    if (e.target.id === 'customerSearch') {
                        const results = document.querySelectorAll('.customer-result-item');
                        if (results.length === 1) {
                            results[0].click();
                        }
                    }
                    break;
            }
        });

        // Auto-search as user types (debounced)
        let searchTimeout;
        document.getElementById('customerSearch').addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                searchCustomers();
            }, 300);
        });

        document.getElementById('bookSearch').addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                searchBooks();
            }, 300);
        });

        // Initialize display
        document.addEventListener('DOMContentLoaded', function() {
            updateBillDisplay();
        });
    </script>
</body>
</html>