<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Book"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Book> books = (List<Book>) request.getAttribute("books");
    List<String> categories = (List<String>) request.getAttribute("categories");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "book");
    request.setAttribute("pageTitle", "Book Management");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Management - Redupahana</title>
    <style>
        /* Page-specific styles */
        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        /* Search & Filter Section */
        .search-section {
            background: white;
            padding: 1.2rem;
            border-radius: 8px;
            margin-bottom: 1.2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .search-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr auto;
            gap: 0.8rem;
            align-items: end;
        }

        .search-group {
            display: flex;
            flex-direction: column;
        }

        .search-group label {
            font-weight: 500;
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .search-group input,
        .search-group select {
            padding: 0.8rem;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .search-group input:focus,
        .search-group select:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .stat-card {
            background: white;
            padding: 1.2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center;
            border-left: 4px solid #007bff;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, rgba(0, 123, 255, 0.1), transparent);
            border-radius: 0 0 0 60px;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 1.8rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .stat-card p {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 500;
        }

        /* Book Image */
        .book-image {
            width: 50px;
            height: 70px;
            object-fit: cover;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: transform 0.2s ease;
        }

        .book-image:hover {
            transform: scale(1.1);
        }

        .no-image {
            width: 50px;
            height: 70px;
            background-color: #f8f9fa;
            border: 2px dashed #dee2e6;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #6c757d;
        }

        /* Category Badge */
        .category-badge {
            display: inline-block;
            padding: 0.2rem 0.6rem;
            background-color: #e8f4fd;
            color: #2c3e50;
            border-radius: 10px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid #bee5eb;
        }

        /* Language Badge */
        .language-badge {
            display: inline-block;
            padding: 0.2rem 0.6rem;
            background-color: #fff3cd;
            color: #856404;
            border-radius: 10px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid #ffeaa7;
        }

        /* Stock Status */
        .stock-status {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .stock-low {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .stock-medium {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .stock-good {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .price {
            font-weight: 600;
            color: #28a745;
        }

        /* Table Updates */
        .table td {
            vertical-align: middle;
        }

        .book-info {
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .book-details h4 {
            margin: 0;
            font-size: 0.95rem;
            color: #2c3e50;
        }

        .book-details small {
            color: #6c757d;
            font-size: 0.8rem;
        }

        .book-meta {
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
        }

        /* Image Modal */
        .image-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.8);
            cursor: pointer;
        }

        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            max-width: 90%;
            max-height: 90%;
        }

        .modal-image {
            width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .modal-close {
            position: absolute;
            top: 10px;
            right: 10px;
            color: white;
            font-size: 2rem;
            cursor: pointer;
            background: rgba(0,0,0,0.5);
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        @media (max-width: 768px) {
            .search-row {
                grid-template-columns: 1fr;
            }
            
            .book-info {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>📚 Book Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Book Management
                </div>
                <div class="header-actions">
                    <a href="book?action=add" class="btn btn-success">➕ Add New Book</a>
                </div>
            </div>

            <!-- Search & Filter Section -->
            <div class="search-section">
                <form action="book" method="get" id="searchForm">
                    <input type="hidden" name="action" value="search">
                    <div class="search-row">
                        <div class="search-group">
                            <label for="searchTerm">Search Books</label>
                            <input type="text" name="searchTerm" id="searchTerm" 
                                   placeholder="Search by title, author, ISBN, publisher, or category..." 
                                   value="<%= searchTerm != null ? searchTerm.replaceAll("(Author|Language|Category): ", "") : "" %>">
                        </div>
                        <div class="search-group">
                            <label for="searchAuthor">Filter by Author</label>
                            <input type="text" name="author" id="searchAuthor" 
                                   placeholder="Author name...">
                        </div>
                        <div class="search-group">
                            <label for="searchLanguage">Filter by Language</label>
                            <select name="language" id="searchLanguage">
                                <option value="">All Languages</option>
                                <option value="Sinhala">Sinhala</option>
                                <option value="English">English</option>
                                <option value="Tamil">Tamil</option>
                            </select>
                        </div>
                        <div class="search-group">
                            <label for="searchCategory">Filter by Category</label>
                            <select name="category" id="searchCategory">
                                <option value="">All Categories</option>
                                <% if (categories != null && !categories.isEmpty()) { %>
                                    <% for (String category : categories) { %>
                                        <option value="<%= category %>"><%= category %></option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="search-group">
                            <button type="submit" class="btn btn-primary">🔍 Search</button>
                            <% if (searchTerm != null || request.getParameter("author") != null || 
                                   request.getParameter("language") != null || request.getParameter("category") != null) { %>
                            <a href="book?action=list" class="btn btn-secondary" style="margin-top: 0.5rem;">❌ Clear</a>
                            <% } %>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Stats Cards -->
            <%
                int totalBooks = 0;
                int lowStockBooks = 0;
                int outOfStockBooks = 0;
                
                if (books != null) {
                    totalBooks = books.size();
                    for (Book book : books) {
                        if (book.getStockQuantity() == 0) {
                            outOfStockBooks++;
                        } else if (book.getStockQuantity() <= 5) {
                            lowStockBooks++;
                        }
                    }
                }
            %>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= totalBooks %></h3>
                    <p>Total Books</p>
                </div>
                <div class="stat-card">
                    <h3><%= lowStockBooks %></h3>
                    <p>Low Stock Books</p>
                </div>
                <div class="stat-card">
                    <h3><%= outOfStockBooks %></h3>
                    <p>Out of Stock</p>
                </div>
                <div class="stat-card">
                    <h3><%= categories != null ? categories.size() : 0 %></h3>
                    <p>Categories</p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success" id="successAlert">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="alert alert-error" id="errorAlert">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <!-- Books Table -->
            <div class="table-container">
                <div class="table-header">
                    <h2>Library Inventory</h2>
                    <% if (searchTerm != null) { %>
                    <span style="color: #6c757d; font-size: 0.9rem;">Search results for: "<%= searchTerm %>"</span>
                    <% } %>
                </div>

                <% if (books != null && !books.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>author</th>
                            <th>Category</th>
                            <th>Language</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Publication</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Book book : books) { %>
                        <tr>
                            <td>
							    <div class="book-info">
							        <% if (book.getImageBase64() != null && !book.getImageBase64().trim().isEmpty()) { %>
							            <img src="<%= book.getImageBase64() %>" alt="<%= book.getTitle() %>" 
							                 class="book-image" onclick="showImageModal('<%= book.getImageBase64() %>', '<%= book.getTitle() %>')">
							        <% } else { %>
							            <div class="no-image">📚</div>
							        <% } %>
							        <div class="book-details">
							            <h4><%= book.getTitle() %></h4>
							            <small><strong>Code:</strong> <%= book.getBookCode() %></small>
							            <% if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) { %>
							            <br><small><strong>ISBN:</strong> <%= book.getIsbn() %></small>
							            <% } %>
							        </div>
							    </div>
							</td>
                            <td>
                                <div class="book-meta">
                                    <strong><%= book.getAuthor() %></strong>
                                    <% if (book.getPublisher() != null && !book.getPublisher().trim().isEmpty()) { %>
                                    <small style="color: #6c757d;"><%= book.getPublisher() %></small>
                                    <% } %>
                                    <% if (book.getPages() > 0) { %>
                                    <small style="color: #6c757d;"><%= book.getPages() %> pages</small>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <% if (book.getBookCategory() != null && !book.getBookCategory().trim().isEmpty()) { %>
                                    <span class="category-badge"><%= book.getBookCategory() %></span>
                                <% } else { %>
                                    <span style="color: #6c757d; font-style: italic;">No category</span>
                                <% } %>
                            </td>
                            <td>
                                <span class="language-badge"><%= book.getLanguage() != null ? book.getLanguage() : "Sinhala" %></span>
                            </td>
                            <td class="price">Rs. <%= String.format("%.2f", book.getPrice()) %></td>
                            <td>
                                <span class="stock-status <%= 
                                    book.getStockQuantity() == 0 ? "stock-low" :
                                    book.getStockQuantity() <= 5 ? "stock-low" : 
                                    book.getStockQuantity() <= 20 ? "stock-medium" : "stock-good" 
                                %>">
                                    <%= book.getStockQuantity() %> copies
                                </span>
                            </td>
                            <td>
                                <% if (book.getPublicationYear() > 0) { %>
                                    <%= book.getPublicationYear() %>
                                <% } else { %>
                                    <span style="color: #6c757d;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="book?action=view&id=<%= book.getBookId() %>" 
                                       class="btn btn-primary btn-sm">👁️ View</a>
                                    <a href="book?action=edit&id=<%= book.getBookId() %>" 
                                       class="btn btn-warning btn-sm">✏️ Edit</a>
                                    <a href="book?action=delete&id=<%= book.getBookId() %>" 
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirmDelete('<%= book.getTitle() %>', '<%= book.getBookId() %>')">🗑️ Delete</a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <h3>No Books Found</h3>
                    <p>
                        <% if (searchTerm != null) { %>
                        No books match your search criteria for "<%= searchTerm %>".
                        <% } else { %>
                        Start by adding your first book to the library.
                        <% } %>
                    </p>
                    <a href="book?action=add" class="btn btn-success" style="margin-top: 1rem;">📚 Add Book</a>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <!-- Image Modal -->
    <div id="imageModal" class="image-modal" onclick="closeImageModal()">
        <div class="modal-content">
            <span class="modal-close" onclick="closeImageModal()">&times;</span>
            <img id="modalImage" class="modal-image" src="" alt="">
        </div>
    </div>

    <script>
        // Image Modal Functions
       function showImageModal(imageData, title) {
		    const modal = document.getElementById('imageModal');
		    const modalImg = document.getElementById('modalImage');
		    modal.style.display = 'block';
		    modalImg.src = imageData; // Now handles Base64 data
		    modalImg.alt = title;
		}

        function closeImageModal() {
            document.getElementById('imageModal').style.display = 'none';
        }

        // Delete Confirmation
       function confirmDelete(bookTitle, bookId) {
		    return confirm('Are you sure you want to delete "' + bookTitle + '"?\n\nThis action cannot be undone.');
		}

        // Search Function
        function performSearch() {
            const form = document.getElementById('searchForm');
            const searchTerm = document.getElementById('searchTerm').value.trim();
            const author = document.getElementById('searchAuthor').value.trim();
            const language = document.getElementById('searchLanguage').value;
            const category = document.getElementById('searchCategory').value;

            if (!searchTerm && !author && !language && !category) {
                window.location.href = 'book?action=list';
                return;
            }

            // Prioritize searchTerm if multiple fields are filled
            if (searchTerm) {
                form.action = 'book?action=search';
            } else if (author) {
                form.action = 'book?action=searchByAuthor';
            } else if (language) {
                form.action = 'book?action=searchByLanguage';
            } else if (category) {
                form.action = 'book?action=searchByCategory';
            }

            // Show loading state
            const searchButton = form.querySelector('.btn-primary');
            searchButton.classList.add('loading');

            form.submit();
        }

        // Enter key search for all inputs
        document.querySelectorAll('#searchTerm, #searchAuthor').forEach(input => {
            input.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    performSearch();
                }
            });
        });

        // Change handlers for dropdowns
        document.getElementById('searchLanguage').addEventListener('change', function() {
            if (this.value) {
                document.getElementById('searchForm').action = 'book?action=searchByLanguage';
                document.getElementById('searchForm').submit();
            }
        });

        document.getElementById('searchCategory').addEventListener('change', function() {
            if (this.value) {
                document.getElementById('searchForm').action = 'book?action=searchByCategory';
                document.getElementById('searchForm').submit();
            }
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Book Management page loaded');

            // Restore previous filter values if any
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('author')) {
                document.getElementById('searchAuthor').value = urlParams.get('author');
            }
            if (urlParams.has('language')) {
                document.getElementById('searchLanguage').value = urlParams.get('language');
            }
            if (urlParams.has('category')) {
                document.getElementById('searchCategory').value = urlParams.get('category');
            }

            // Auto-hide alerts after 5 seconds
            setTimeout(() => {
                const successAlert = document.getElementById('successAlert');
                const errorAlert = document.getElementById('errorAlert');
                if (successAlert) {
                    successAlert.style.opacity = '0';
                    setTimeout(() => successAlert.remove(), 300);
                }
                if (errorAlert) {
                    errorAlert.style.opacity = '0';
                    setTimeout(() => errorAlert.remove(), 300);
                }
            }, 5000);
        });

        // Close modal on Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeImageModal();
            }
        });
    </script>
</body>
</html>