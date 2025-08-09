<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%@ page import="java.util.List"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String suggestedBookCode = (String) request.getAttribute("suggestedBookCode");
    List<String> categories = (List<String>) request.getAttribute("categories");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "book");
    request.setAttribute("pageTitle", "Add Book");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Book - Redupahana</title>
    
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

        /* Info Notice */
        .info-notice {
            background-color: #e8f4fd;
            border: 1px solid #bee5eb;
            padding: 1.2rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #007bff;
        }

        .info-notice h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-size: 1.1rem;
        }

        .info-notice p {
            color: #2c3e50;
            font-size: 0.9rem;
        }

        /* Form Styles */
        .form-container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.2rem;
        }

        .form-group {
            margin-bottom: 1.2rem;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #2c3e50;
            font-size: 0.9rem;
        }

        .required {
            color: #dc3545;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        .form-control.error {
            border-color: #dc3545;
            box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.25);
        }

        .form-text {
            font-size: 0.8rem;
            color: #6c757d;
            margin-top: 0.25rem;
        }

        /* Book Code Input */
        .book-code-group {
            position: relative;
        }

        .book-code-suggestion {
            background-color: #e8f4fd;
            border: 1px solid #bee5eb;
            padding: 0.5rem 0.8rem;
            border-radius: 4px;
            font-size: 0.8rem;
            margin-top: 0.25rem;
            color: #0c5460;
        }

        /* Price Input */
        .price-input-group {
            position: relative;
        }

        .price-input-group::before {
            content: "Rs.";
            position: absolute;
            left: 0.8rem;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
            font-weight: 500;
        }

        .price-input-group .form-control {
            padding-left: 3rem;
        }

        /* Stock Indicator */
        .stock-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }

        .stock-level {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
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

        /* Category Selection */
        .category-group {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
        }

        .category-select {
            flex: 1;
        }

        .category-input {
            flex: 1;
            display: none;
        }

        .category-input.show {
            display: block;
        }

        .btn-add-category {
            background: #28a745;
            color: white;
            border: none;
            padding: 0.8rem 1rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.85rem;
            white-space: nowrap;
            transition: background 0.3s ease;
        }

        .btn-add-category:hover {
            background: #218838;
        }

        /* Image Upload */
        .image-upload-container {
            border: 2px dashed #dee2e6;
            border-radius: 8px;
            padding: 2rem;
            text-align: center;
            background-color: #f8f9fa;
            transition: all 0.3s ease;
        }

        .image-upload-container:hover {
            border-color: #007bff;
            background-color: #e8f4fd;
        }

        .image-upload-container.dragover {
            border-color: #007bff;
            background-color: #e8f4fd;
        }

        .image-preview {
            margin-top: 1rem;
            display: none;
        }

        .image-preview img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .image-remove {
            margin-top: 0.5rem;
            background: #dc3545;
            color: white;
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
        }

        .image-remove:hover {
            background: #c82333;
        }

        /* Language Selection */
        .language-selection {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 0.8rem;
            margin-top: 0.5rem;
        }

        .language-option {
            border: 2px solid #dee2e6;
            border-radius: 6px;
            padding: 0.8rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .language-option:hover {
            border-color: #007bff;
            background-color: #f8f9fa;
        }

        .language-option.selected {
            border-color: #007bff;
            background-color: #e8f4fd;
        }

        .language-option input[type="radio"] {
            display: none;
        }

        .language-icon {
            font-size: 1.3rem;
            margin-bottom: 0.4rem;
        }

        .language-name {
            color: #2c3e50;
            font-weight: 500;
            font-size: 0.85rem;
        }

        /* Buttons */
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

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #545b62;
        }

        .btn:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            pointer-events: none;
        }

        .form-actions {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #dee2e6;
            text-align: center;
            display: flex;
            justify-content: center;
            gap: 0.8rem;
        }

        /* Form validation states */
        .form-group.has-error .form-control {
            border-color: #dc3545;
            box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.25);
        }

        .form-group.has-error .form-text {
            color: #dc3545;
        }

        .form-group.has-error .form-text::before {
            content: "⚠️";
        }

        .form-group.has-success .form-control {
            border-color: #28a745;
            box-shadow: 0 0 0 2px rgba(40, 167, 69, 0.25);
        }

        .form-group.has-success .form-text {
            color: #28a745;
        }

        .form-group.has-success .form-text::before {
            content: "✅";
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .content-area {
                padding: 1rem;
            }

            .page-header {
                padding: 1rem;
            }

            .form-container {
                padding: 1.2rem;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 0.8rem;
            }

            .language-selection {
                grid-template-columns: repeat(2, 1fr);
            }

            .btn {
                width: 100%;
                margin-bottom: 0.5rem;
            }

            .category-group {
                flex-direction: column;
                gap: 0.8rem;
            }
        }

        @media (max-width: 480px) {
            .language-selection {
                grid-template-columns: 1fr;
            }

            .form-container {
                padding: 1rem;
            }

            .btn {
                font-size: 0.85rem;
                padding: 0.6rem 1rem;
            }
        }

        /* Subtle animations */
        .form-container {
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
                <h1>📚 Add New Book</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="book?action=list">Book Management</a> &gt; 
                    Add Book
                </div>
            </div>

            <!-- Info Notice -->
            <div class="info-notice">
                <h4>📖 Add New Book to Library</h4>
                <p>Fill in the details below to add a new book to your library inventory. Required fields are marked with an asterisk (*). You can also upload a book cover image.</p>
            </div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Add Book Form -->
            <div class="form-container">
                <form action="book" method="post" id="addBookForm" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">
                    
                    <!-- Book Code -->
                    <div class="form-group">
                        <label for="bookCode">Book Code</label>
                        <div class="book-code-group">
                            <input type="text" class="form-control" id="bookCode" name="bookCode" 
                                   placeholder="Leave blank for auto-generation">
                            <% if (suggestedBookCode != null) { %>
                            <div class="book-code-suggestion">
                                💡 Suggested code: <%= suggestedBookCode %> (or leave blank for auto-generation)
                            </div>
                            <% } %>
                        </div>
                        <div class="form-text">Leave blank to auto-generate a unique book code</div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="title">Book Title <span class="required">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" required 
                                   placeholder="Enter book title">
                        </div>

                        <div class="form-group">
                            <label for="author">Author <span class="required">*</span></label>
                            <input type="text" class="form-control" id="author" name="author" required 
                                   placeholder="Enter author name">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="isbn">ISBN</label>
                            <input type="text" class="form-control" id="isbn" name="isbn" 
                                   placeholder="Enter ISBN (optional)">
                        </div>

                        <div class="form-group">
                            <label for="publisher">Publisher</label>
                            <input type="text" class="form-control" id="publisher" name="publisher" 
                                   placeholder="Enter publisher name (optional)">
                        </div>
                    </div>

                    <!-- Category Selection -->
                    <div class="form-group">
                        <label for="bookCategory">Book Category</label>
                        <div class="category-group">
                            <div class="category-select">
                                <select class="form-control" id="categorySelect" onchange="toggleCategoryInput()">
                                    <option value="">Select existing category</option>
                                    <% if (categories != null && !categories.isEmpty()) { %>
                                        <% for (String category : categories) { %>
                                            <option value="<%= category %>"><%= category %></option>
                                        <% } %>
                                    <% } %>
                                    <option value="__new__">➕ Add New Category</option>
                                </select>
                            </div>
                            <div class="category-input" id="categoryInput">
                                <input type="text" class="form-control" id="bookCategory" name="bookCategory" 
                                       placeholder="Enter new category name">
                            </div>
                            <button type="button" class="btn-add-category" onclick="addNewCategory()" style="display: none;" id="addCategoryBtn">
                                ➕ Add
                            </button>
                        </div>
                        <div class="form-text">Select an existing category or create a new one</div>
                    </div>

                    <div class="form-group full-width">
                        <label for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" 
                                  placeholder="Enter book description (optional)"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="price">Price <span class="required">*</span></label>
                            <div class="price-input-group">
                                <input type="number" class="form-control" id="price" name="price" required 
                                       min="0.01" step="0.01" placeholder="0.00">
                            </div>
                            <div class="form-text">Enter price in Sri Lankan Rupees</div>
                        </div>

                        <div class="form-group">
                            <label for="stockQuantity">Stock Quantity <span class="required">*</span></label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" required 
                                   min="0" placeholder="Enter number of copies">
                            <div class="stock-indicator">
                                <span>Stock Level:</span>
                                <span class="stock-level" id="stockLevel">-</span>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="publicationYear">Publication Year</label>
                            <input type="number" class="form-control" id="publicationYear" name="publicationYear" 
                                   min="1000" max="2025" placeholder="Enter year (optional)">
                        </div>

                        <div class="form-group">
                            <label for="pages">Number of Pages</label>
                            <input type="number" class="form-control" id="pages" name="pages" 
                                   min="1" placeholder="Enter page count (optional)">
                        </div>
                    </div>

                    <!-- Image Upload -->
                    <div class="form-group">
                        <label for="bookImage">Book Cover Image</label>
                        <div class="image-upload-container" id="imageUploadContainer">
                            <input type="file" id="bookImage" name="bookImage" accept="image/*" style="display: none;">
                            <div class="upload-text">
                                <h4>📷 Upload Book Cover</h4>
                                <p>Click here or drag and drop an image file (JPG, PNG, GIF)</p>
                                <p style="font-size: 0.8rem; color: #6c757d;">Maximum file size: 5MB</p>
                            </div>
                            <div class="image-preview" id="imagePreview">
                                <img id="previewImg" src="" alt="Book Cover Preview">
                                <br>
                                <button type="button" class="image-remove" onclick="removeImage()">🗑️ Remove Image</button>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Language</label>
                        <div class="language-selection">
                            <div class="language-option selected" onclick="selectLanguage('Sinhala')">
                                <input type="radio" name="language" value="Sinhala" id="languageSinhala" checked>
                                <div class="language-icon">🇱🇰</div>
                                <div class="language-name">Sinhala</div>
                            </div>
                            <div class="language-option" onclick="selectLanguage('English')">
                                <input type="radio" name="language" value="English" id="languageEnglish">
                                <div class="language-icon">🇬🇧</div>
                                <div class="language-name">English</div>
                            </div>
                            <div class="language-option" onclick="selectLanguage('Tamil')">
                                <input type="radio" name="language" value="Tamil" id="languageTamil">
                                <div class="language-icon">🇮🇳</div>
                                <div class="language-name">Tamil</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            ✅ Add Book to Library
                        </button>
                        <a href="book?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        // Category Management
        function toggleCategoryInput() {
            const select = document.getElementById('categorySelect');
            const input = document.getElementById('categoryInput');
            const addBtn = document.getElementById('addCategoryBtn');
            const hiddenInput = document.getElementById('bookCategory');
            
            if (select.value === '__new__') {
                input.classList.add('show');
                addBtn.style.display = 'block';
                hiddenInput.value = '';
            } else {
                input.classList.remove('show');
                addBtn.style.display = 'none';
                hiddenInput.value = select.value;
            }
        }

        function addNewCategory() {
            const input = document.getElementById('bookCategory');
            const categoryName = input.value.trim();
            
            if (categoryName) {
                const select = document.getElementById('categorySelect');
                const newOption = new Option(categoryName, categoryName, true, true);
                select.insertBefore(newOption, select.lastElementChild);
                
                document.getElementById('categoryInput').classList.remove('show');
                document.getElementById('addCategoryBtn').style.display = 'none';
                
                showNotification('✅ Category "' + categoryName + '" added successfully!', 'success');
            }
        }

        // Image Upload
        const imageUploadContainer = document.getElementById('imageUploadContainer');
        const imageInput = document.getElementById('bookImage');
        const imagePreview = document.getElementById('imagePreview');
        const previewImg = document.getElementById('previewImg');

        imageUploadContainer.addEventListener('click', function() {
            imageInput.click();
        });

        imageUploadContainer.addEventListener('dragover', function(e) {
            e.preventDefault();
            this.classList.add('dragover');
        });

        imageUploadContainer.addEventListener('dragleave', function(e) {
            e.preventDefault();
            this.classList.remove('dragover');
        });

        imageUploadContainer.addEventListener('drop', function(e) {
            e.preventDefault();
            this.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                handleImageFile(files[0]);
            }
        });

        imageInput.addEventListener('change', function(e) {
            if (e.target.files.length > 0) {
                handleImageFile(e.target.files[0]);
            }
        });

        function handleImageFile(file) {
            if (!file.type.match('image.*')) {
                showNotification('⚠️ Please select a valid image file.', 'error');
                return;
            }

            if (file.size > 5 * 1024 * 1024) { // 5MB
                showNotification('⚠️ File size must be less than 5MB.', 'error');
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                imagePreview.style.display = 'block';
                document.querySelector('.upload-text').style.display = 'none';
            };
            reader.readAsDataURL(file);
        }

        function removeImage() {
            imageInput.value = '';
            imagePreview.style.display = 'none';
            document.querySelector('.upload-text').style.display = 'block';
        }

        // Language Selection
        function selectLanguage(language) {
            document.querySelectorAll('.language-option').forEach(function(option) {
                option.classList.remove('selected');
            });
            event.currentTarget.classList.add('selected');
            document.getElementById('language' + language).checked = true;
        }

        // Stock Level Indicator
        const stockQuantityInput = document.getElementById('stockQuantity');
        const stockLevelSpan = document.getElementById('stockLevel');

        function validateField(field, validationFn) {
            const formGroup = field.closest('.form-group');
            const isValid = validationFn(field.value);
            
            formGroup.classList.remove('has-error', 'has-success');
            
            if (field.value.trim() === '') {
                return true;
            }
            
            if (isValid) {
                formGroup.classList.add('has-success');
                return true;
            } else {
                formGroup.classList.add('has-error');
                return false;
            }
        }

        // Validation functions
        function validateTitle(title) {
            return title.trim().length >= 2;
        }

        function validateAuthor(author) {
            return author.trim().length >= 2;
        }

        function validatePrice(price) {
            return !isNaN(price) && parseFloat(price) > 0;
        }

        function validateStock(stock) {
            return !isNaN(stock) && parseInt(stock) >= 0;
        }

        function validateYear(year) {
            if (!year.trim()) return true;
            const y = parseInt(year);
            const currentYear = new Date().getFullYear();
            return y >= 1000 && y <= currentYear;
        }

        function validatePages(pages) {
            if (!pages.trim()) return true;
            return parseInt(pages) > 0;
        }

        stockQuantityInput.addEventListener('input', function() {
            const quantity = parseInt(this.value) || 0;
            
            stockLevelSpan.className = 'stock-level';
            
            if (quantity === 0) {
                stockLevelSpan.textContent = 'Out of Stock';
                stockLevelSpan.classList.add('stock-low');
            } else if (quantity <= 5) {
                stockLevelSpan.textContent = 'Low Stock';
                stockLevelSpan.classList.add('stock-low');
            } else if (quantity <= 20) {
                stockLevelSpan.textContent = 'Medium Stock';
                stockLevelSpan.classList.add('stock-medium');
            } else {
                stockLevelSpan.textContent = 'Good Stock';
                stockLevelSpan.classList.add('stock-good');
            }
        });

        // Real-time validation
        document.getElementById('title').addEventListener('blur', function() {
            validateField(this, validateTitle);
        });

        document.getElementById('author').addEventListener('blur', function() {
            validateField(this, validateAuthor);
        });

        document.getElementById('price').addEventListener('blur', function() {
            validateField(this, validatePrice);
        });

        document.getElementById('stockQuantity').addEventListener('blur', function() {
            validateField(this, validateStock);
        });

        document.getElementById('publicationYear').addEventListener('blur', function() {
            validateField(this, validateYear);
        });

        document.getElementById('pages').addEventListener('blur', function() {
            validateField(this, validatePages);
        });

        // Form Validation
        document.getElementById('addBookForm').addEventListener('submit', function(e) {
            const title = document.getElementById('title');
            const author = document.getElementById('author');
            const price = document.getElementById('price');
            const stockQuantity = document.getElementById('stockQuantity');
            const publicationYear = document.getElementById('publicationYear');
            const pages = document.getElementById('pages');

            let isValid = true;

            isValid = validateField(title, validateTitle) && isValid;
            isValid = validateField(author, validateAuthor) && isValid;
            isValid = validateField(price, validatePrice) && isValid;
            isValid = validateField(stockQuantity, validateStock) && isValid;
            isValid = validateField(publicationYear, validateYear) && isValid;
            isValid = validateField(pages, validatePages) && isValid;

            if (!isValid) {
                e.preventDefault();
                showNotification('⚠️ Please fill in all required fields correctly.', 'error');
                return false;
            }

            const submitBtn = document.getElementById('submitBtn');
            submitBtn.style.opacity = '0.7';
            submitBtn.innerHTML = '⏳ Adding Book...';
            submitBtn.disabled = true;
        });

        // Notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type === 'success' ? 'success' : 'error'}`;
            notification.innerHTML = message;
            
            // Add success alert styles if not exist
            if (type === 'success' && !document.querySelector('.alert-success')) {
                const style = document.createElement('style');
                style.textContent = `
                    .alert-success {
                        background-color: #d4edda;
                        border-left-color: #28a745;
                        color: #155724;
                    }
                `;
                document.head.appendChild(style);
            }
            
            document.querySelector('.form-container').prepend(notification);
            setTimeout(() => {
                notification.style.opacity = '0';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Add Book page loaded');
            document.getElementById('title').focus();
            stockQuantityInput.dispatchEvent(new Event('input'));
            
            // Initialize category dropdown
            toggleCategoryInput();
        });
    </script>
</body>
</html>