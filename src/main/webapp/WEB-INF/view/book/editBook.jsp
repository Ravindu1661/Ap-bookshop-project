<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%@ page import="java.util.List"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Book book = (Book) request.getAttribute("book");
    List<String> categories = (List<String>) request.getAttribute("categories");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "book");
    request.setAttribute("pageTitle", "Edit Book");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Book - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            font-size: 14px;
            line-height: 1.5;
            color: #2c3e50;
            overflow-x: hidden;
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
            font-weight: 600;
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
            font-size: 0.9rem;
            animation: slideIn 0.3s ease;
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

        /* Book Info Card */
        .book-info-card {
            background: #e8f4fd;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border-left: 4px solid #2c3e50;
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 1.5rem;
            align-items: center;
        }

        .current-image {
            width: 100px;
            height: 140px;
            object-fit: cover;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .no-current-image {
            width: 100px;
            height: 140px;
            background-color: #f8f9fa;
            border: 2px dashed #dee2e6;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: #6c757d;
        }

        .book-info-details h4 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 0.25rem;
        }

        .info-value {
            color: #2c3e50;
            font-size: 1rem;
        }

        /* Form Styles */
        .form-container {
            background: white;
            padding: 2.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.07);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.95rem;
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

        .form-control:disabled {
            background-color: #f8f9fa;
            cursor: not-allowed;
        }

        .form-text {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.25rem;
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
            cursor: pointer;
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

        .current-image-section {
            margin-bottom: 1rem;
            padding: 1rem;
            background-color: #f8f9fa;
            border-radius: 8px;
        }

        .current-image-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }

        .btn-remove-current {
            background: #dc3545;
            color: white;
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
        }

        /* Language Selection */
        .language-selection {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .language-option {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

        .language-option:hover {
            border-color: #2c3e50;
            background-color: #f8f9fa;
        }

        .language-option.selected {
            border-color: #2c3e50;
            background-color: #e8f4fd;
        }

        .language-option input[type="radio"] {
            display: none;
        }

        .language-icon {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }

        .language-name {
            color: #2c3e50;
            font-weight: 600;
            font-size: 0.9rem;
        }

        /* Buttons */
        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 1rem;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        .btn-primary {
            background-color: #2c3e50;
            color: white;
        }

        .btn-primary:hover {
            background-color: #34495e;
        }

        .btn-secondary {
            background-color: #7f8c8d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #95a5a6;
        }

        .form-actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
            text-align: center;
            display: flex;
            justify-content: center;
            gap: 1rem;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .content-area {
                padding: 1rem;
            }

            .page-header {
                padding: 1.5rem;
            }

            .form-container {
                padding: 1.5rem;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .language-selection {
                grid-template-columns: repeat(2, 1fr);
            }

            .btn {
                width: 100%;
                margin-bottom: 0.5rem;
                margin-right: 0;
                text-align: center;
            }

            .book-info-card {
                grid-template-columns: 1fr;
                text-align: center;
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
                font-size: 0.9rem;
                padding: 0.7rem 1.5rem;
            }
        }

        /* Subtle animations */
        .form-container,
        .book-info-card {
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
                <h1>📚 Edit Book</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="book?action=list">Book Management</a> &gt; 
                    Edit Book
                </div>
            </div>

            <% if (book != null) { %>
            <!-- Current Book Info -->
            <div class="book-info-card">
			    <div class="current-book-image">
			        <% if (book.getImageBase64() != null && !book.getImageBase64().trim().isEmpty()) { %>
			            <img src="<%= book.getImageBase64() %>" alt="<%= book.getTitle() %>" class="current-image">
			        <% } else { %>
			            <div class="no-current-image">📚</div>
			        <% } %>
			    </div>
			    <div class="book-info-details">
			        <h4>📖 Current Book Information</h4>
			        <div class="info-grid">
			            <div class="info-item">
			                <span class="info-label">Book Code</span>
			                <span class="info-value"><%= book.getBookCode() %></span>
			            </div>
			            <div class="info-item">
			                <span class="info-label">Current Title</span>
			                <span class="info-value"><%= book.getTitle() %></span>
			            </div>
			            <div class="info-item">
			                <span class="info-label">Current Author</span>
			                <span class="info-value"><%= book.getAuthor() %></span>
			            </div>
			            <div class="info-item">
			                <span class="info-label">Current Price</span>
			                <span class="info-value">Rs. <%= String.format("%.2f", book.getPrice()) %></span>
			            </div>
			            <div class="info-item">
			                <span class="info-label">Current Category</span>
			                <span class="info-value">
			                    <%= book.getBookCategory() != null && !book.getBookCategory().trim().isEmpty() 
			                        ? book.getBookCategory() : "No category" %>
			                </span>
			            </div>
			            <div class="info-item">
			                <span class="info-label">Created Date</span>
			                <span class="info-value"><%= book.getCreatedDate() %></span>
			            </div>
			        </div>
			    </div>
			</div>

            <!-- Error Message -->
            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Edit Book Form -->
            <div class="form-container">
                <form action="book" method="post" id="editBookForm" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                    <input type="hidden" name="removeImage" id="removeImageFlag" value="false">
                    
                    <div class="form-group">
                        <label for="bookCode">Book Code</label>
                        <input type="text" class="form-control" value="<%= book.getBookCode() %>" disabled>
                        <div class="form-text">Book code cannot be changed</div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="title">Book Title <span class="required">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" 
                                   value="<%= book.getTitle() %>" required placeholder="Enter book title">
                        </div>

                        <div class="form-group">
                            <label for="author">Author <span class="required">*</span></label>
                            <input type="text" class="form-control" id="author" name="author" 
                                   value="<%= book.getAuthor() %>" required placeholder="Enter author name">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="isbn">ISBN</label>
                            <input type="text" class="form-control" id="isbn" name="isbn" 
                                   value="<%= book.getIsbn() != null ? book.getIsbn() : "" %>"
                                   placeholder="Enter ISBN (optional)">
                        </div>

                        <div class="form-group">
                            <label for="publisher">Publisher</label>
                            <input type="text" class="form-control" id="publisher" name="publisher" 
                                   value="<%= book.getPublisher() != null ? book.getPublisher() : "" %>"
                                   placeholder="Enter publisher name (optional)">
                        </div>
                    </div>

                    <!-- Category Selection -->
                    <div class="form-group">
					    <label for="bookCategory">Book Category <span class="required">*</span></label>
					    <div class="category-group">
					        <div class="category-select">
					            <select class="form-control" id="categorySelect" onchange="toggleCategoryInput()" required>
					                <option value="">Select a category (required)</option>
					                <% if (categories != null && !categories.isEmpty()) { %>
					                    <% for (String category : categories) { %>
					                        <option value="<%= category %>" 
					                            <%= category.equals(book.getBookCategory()) ? "selected" : "" %>>
					                            <%= category %>
					                        </option>
					                    <% } %>
					                <% } %>
					                <option value="__new__">➕ Add New Category</option>
					            </select>
					        </div>
					        <div class="category-input" id="categoryInput">
					            <input type="text" class="form-control" id="bookCategory" name="bookCategory" 
					                   value="<%= book.getBookCategory() != null ? book.getBookCategory() : "" %>"
					                   placeholder="Enter new category name" required>
					        </div>
					        <button type="button" class="btn-add-category" onclick="addNewCategory()" style="display: none;" id="addCategoryBtn">
					            ➕ Add
					        </button>
					    </div>
					    <div class="form-text">Book category is required. You can change to an existing category or create a new one.</div>
					 </div>
					</div>
                    <div class="form-group full-width">
                        <label for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" 
                                  placeholder="Enter book description (optional)"><%= book.getDescription() != null ? book.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="price">Price (Rs.) <span class="required">*</span></label>
                            <input type="number" class="form-control" id="price" name="price" 
                                   value="<%= book.getPrice() %>" required min="0.01" step="0.01">
                        </div>

                        <div class="form-group">
                            <label for="stockQuantity">Stock Quantity <span class="required">*</span></label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" 
                                   value="<%= book.getStockQuantity() %>" required min="0">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="publicationYear">Publication Year</label>
                            <input type="number" class="form-control" id="publicationYear" name="publicationYear" 
                                   value="<%= book.getPublicationYear() > 0 ? book.getPublicationYear() : "" %>"
                                   min="1000" max="2025" placeholder="Enter year (optional)">
                        </div>

                        <div class="form-group">
                            <label for="pages">Number of Pages</label>
                            <input type="number" class="form-control" id="pages" name="pages" 
                                   value="<%= book.getPages() > 0 ? book.getPages() : "" %>"
                                   min="1" placeholder="Enter page count (optional)">
                        </div>
                    </div>

                    <!-- Image Management -->
                    <div class="form-group">
                        <label for="bookImage">Book Cover Image</label>
                        
                        <% if (book.getImagePath() != null && !book.getImagePath().trim().isEmpty()) { %>
                        <div class="current-image-section" id="currentImageSection">
                            <h5>Current Image:</h5>
                            <img src="<%= book.getImagePath() %>" alt="Current book cover" style="max-width: 150px; border-radius: 8px;">
                            <div class="current-image-actions">
                                <button type="button" class="btn-remove-current" onclick="removeCurrentImage()">
                                    🗑️ Remove Current Image
                                </button>
                            </div>
                        </div>
                        <% } %>

                        <div class="image-upload-container" id="imageUploadContainer">
                            <input type="file" id="bookImage" name="bookImage" accept="image/*" style="display: none;">
                            <div class="upload-text">
                                <h4>📷 Upload New Book Cover</h4>
                                <p>Click here or drag and drop an image file (JPG, PNG, GIF)</p>
                                <p style="font-size: 0.8rem; color: #6c757d;">Maximum file size: 5MB</p>
                            </div>
                            <div class="image-preview" id="imagePreview">
                                <img id="previewImg" src="" alt="Book Cover Preview">
                                <br>
                                <button type="button" class="image-remove" onclick="removeNewImage()">🗑️ Remove New Image</button>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Language</label>
                        <div class="language-selection">
                            <div class="language-option <%= "Sinhala".equals(book.getLanguage()) ? "selected" : "" %>" onclick="selectLanguage('Sinhala')">
                                <input type="radio" name="language" value="Sinhala" id="languageSinhala" 
                                       <%= "Sinhala".equals(book.getLanguage()) ? "checked" : "" %>>
                                <div class="language-icon">🇱🇰</div>
                                <div class="language-name">Sinhala</div>
                            </div>
                            <div class="language-option <%= "English".equals(book.getLanguage()) ? "selected" : "" %>" onclick="selectLanguage('English')">
                                <input type="radio" name="language" value="English" id="languageEnglish" 
                                       <%= "English".equals(book.getLanguage()) ? "checked" : "" %>>
                                <div class="language-icon">🇬🇧</div>
                                <div class="language-name">English</div>
                            </div>
                            <div class="language-option <%= "Tamil".equals(book.getLanguage()) ? "selected" : "" %>" onclick="selectLanguage('Tamil')">
                                <input type="radio" name="language" value="Tamil" id="languageTamil" 
                                       <%= "Tamil".equals(book.getLanguage()) ? "checked" : "" %>>
                                <div class="language-icon">🇮🇳</div>
                                <div class="language-name">Tamil</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">💾 Update Book</button>
                        <a href="book?action=view&id=<%= book.getBookId() %>" class="btn btn-secondary">👁️ View Details</a>
                        <a href="book?action=list" class="btn btn-secondary">❌ Cancel</a>
                    </div>
                </form>
            </div>

            <% } else { %>
            <!-- Book Not Found -->
            <div class="alert alert-error">
                ❌ Book not found or invalid book ID.
            </div>
            <div style="text-align: center; margin-top: 2rem;">
                <a href="book?action=list" class="btn btn-primary">Back to Book List</a>
            </div>
            <% } %>
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
            hiddenInput.required = true;
            select.required = false;
        } else {
            input.classList.remove('show');
            addBtn.style.display = 'none';
            hiddenInput.value = select.value;
            hiddenInput.required = false;
            select.required = true;
        }
    }

    function addNewCategory() {
        const input = document.getElementById('bookCategory');
        const categoryName = input.value.trim();
        
        if (!categoryName) {
            alert('⚠️ Please enter a category name');
            input.focus();
            return;
        }
        
        if (categoryName.length < 2) {
            alert('⚠️ Category name must be at least 2 characters long');
            input.focus();
            return;
        }
        
        const select = document.getElementById('categorySelect');
        
        // Check if category already exists
        const existingOptions = Array.from(select.options);
        const categoryExists = existingOptions.some(option => 
            option.value.toLowerCase() === categoryName.toLowerCase() && option.value !== '__new__'
        );
        
        if (categoryExists) {
            alert('⚠️ Category "' + categoryName + '" already exists');
            input.focus();
            return;
        }
        
        // Add new category option
        const newOption = new Option(categoryName, categoryName, true, true);
        select.insertBefore(newOption, select.lastElementChild);
        
        // Hide input and show select
        document.getElementById('categoryInput').classList.remove('show');
        document.getElementById('addCategoryBtn').style.display = 'none';
        select.required = true;
        input.required = false;
        
        alert('✅ Category "' + categoryName + '" added successfully!');
    }

    // Image Management
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
            alert('⚠️ Please select a valid image file.');
            return;
        }

        if (file.size > 5 * 1024 * 1024) { // 5MB
            alert('⚠️ File size must be less than 5MB.');
            return;
        }

        const reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            imagePreview.style.display = 'block';
            document.querySelector('.upload-text').style.display = 'none';
        };
        
        reader.onerror = function() {
            alert('⚠️ Error reading the image file.');
        };
        
        reader.readAsDataURL(file);
    }

    function removeNewImage() {
        imageInput.value = '';
        imagePreview.style.display = 'none';
        document.querySelector('.upload-text').style.display = 'block';
    }

    function removeCurrentImage() {
        if (confirm('Are you sure you want to remove the current image?')) {
            document.getElementById('removeImageFlag').value = 'true';
            document.getElementById('currentImageSection').style.display = 'none';
        }
    }

    // Language Selection
    function selectLanguage(language) {
        document.querySelectorAll('.language-option').forEach(function(option) {
            option.classList.remove('selected');
        });
        
        event.currentTarget.classList.add('selected');
        document.getElementById('language' + language).checked = true;
    }

    // Basic Form Validation
    function validateCategory() {
        const select = document.getElementById('categorySelect');
        const input = document.getElementById('bookCategory');
        
        if (select.required && (!select.value || select.value === '')) {
            return false;
        }
        
        if (input.required && input.classList.contains('show') && (!input.value || input.value.trim().length < 2)) {
            return false;
        }
        
        return true;
    }

    // Form Submit Validation
    document.getElementById('editBookForm').addEventListener('submit', function(e) {
        const title = document.getElementById('title').value.trim();
        const author = document.getElementById('author').value.trim();
        const price = parseFloat(document.getElementById('price').value);
        const stockQuantity = parseInt(document.getElementById('stockQuantity').value);

        let errorMessages = [];

        // Basic validation
        if (!title) {
            errorMessages.push('Book title is required');
        }

        if (!author) {
            errorMessages.push('Author name is required');
        }

        if (!price || price <= 0) {
            errorMessages.push('Valid price is required');
        }

        if (isNaN(stockQuantity) || stockQuantity < 0) {
            errorMessages.push('Valid stock quantity is required');
        }

        if (!validateCategory()) {
            errorMessages.push('Book category is required');
        }

        if (errorMessages.length > 0) {
            e.preventDefault();
            alert('Please fix the following errors:\n• ' + errorMessages.join('\n• '));
            return false;
        }

        // Add loading state
        const submitBtn = this.querySelector('button[type="submit"]');
        submitBtn.style.opacity = '0.7';
        submitBtn.innerHTML = '⏳ Updating Book...';
        submitBtn.disabled = true;
    });

    // Initialize
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Edit Book page loaded');
        
        // Focus on book title field
        document.getElementById('title').focus();
        
        // Initialize category dropdown
        toggleCategoryInput();
        
        // Add category validation listeners
        const categorySelect = document.getElementById('categorySelect');
        const categoryInput = document.getElementById('bookCategory');
        
        categorySelect.addEventListener('change', function() {
            if (this.value && this.value !== '__new__') {
                this.style.borderColor = '#28a745';
            }
        });
        
        categoryInput.addEventListener('blur', function() {
            if (this.classList.contains('show') && this.value && this.value.trim().length >= 2) {
                this.style.borderColor = '#28a745';
            }
        });
    });
</script>
</body>
</html>