// BookController.java - Improved with better error handling for book code generation + Image Upload Support
package com.redupahana.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import com.redupahana.model.Book;
import com.redupahana.model.User;
import com.redupahana.service.BookService;
import com.redupahana.util.Constants;

@WebServlet("/book")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class BookController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private BookService bookService;
    private static final String UPLOAD_DIR = "uploads/books";
    
    public void init() throws ServletException {
        bookService = BookService.getInstance();
        
        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listBooks(request, response);
        } else if (action.equals("add")) {
            showAddForm(request, response);
        } else if (action.equals("edit")) {
            showEditForm(request, response);
        } else if (action.equals("delete")) {
            deleteBook(request, response);
        } else if (action.equals("search")) {
            searchBooks(request, response);
        } else if (action.equals("view")) {
            viewBook(request, response);
        } else if (action.equals("searchByAuthor")) {
            searchBooksByAuthor(request, response);
        } else if (action.equals("searchByLanguage")) {
            searchBooksByLanguage(request, response);
        } else if (action.equals("searchByCategory")) {
            searchBooksByCategory(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action.equals("add")) {
            addBook(request, response);
        } else if (action.equals("update")) {
            updateBook(request, response);
        }
    }
    
    private void listBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Book> books = bookService.getAllBooks();
            List<String> categories = bookService.getAllBookCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            
            // Check for success messages in session
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }
            
            // Check for error messages in session
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage");
            }
            
            request.getRequestDispatcher("WEB-INF/view/book/listBooks.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading books: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Get suggested book code for display
            String suggestedCode = bookService.getNextAvailableBookCode();
            request.setAttribute("suggestedBookCode", suggestedCode);
            
            // Get all categories for dropdown
            List<String> categories = bookService.getAllBookCategories();
            request.setAttribute("categories", categories);
            
        } catch (SQLException e) {
            // If we can't get suggested code, that's okay, just continue without it
            System.err.println("Could not generate suggested book code: " + e.getMessage());
        }
        
        request.getRequestDispatcher("WEB-INF/view/book/addBook.jsp").forward(request, response);
    }
    
    /**
     * Improved addBook method with better error handling and retry logic + Image Upload
     */
    private void addBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int maxRetries = 3;
        int retryCount = 0;
        
        while (retryCount < maxRetries) {
            try {
                // Get form parameters
                String bookCode = request.getParameter("bookCode");
                String title = request.getParameter("title");
                String author = request.getParameter("author");
                String description = request.getParameter("description");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stockQuantity");
                String isbn = request.getParameter("isbn");
                String publisher = request.getParameter("publisher");
                String publicationYearStr = request.getParameter("publicationYear");
                String pagesStr = request.getParameter("pages");
                String language = request.getParameter("language");
                String bookCategory = request.getParameter("bookCategory");
                
                // Handle image upload
                String imagePath = null;
                Part imagePart = request.getPart("bookImage");
                if (imagePart != null && imagePart.getSize() > 0) {
                    imagePath = handleImageUpload(imagePart);
                }
                
                // Basic validation
                if (title == null || title.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Book title is required.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                if (author == null || author.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Author name is required.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                if (priceStr == null || priceStr.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Price is required.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                if (stockStr == null || stockStr.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Stock quantity is required.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                double price;
                int stockQuantity;
                int publicationYear = 0;
                int pages = 0;
                
                try {
                    price = Double.parseDouble(priceStr);
                    if (price <= 0) {
                        request.setAttribute("errorMessage", "Price must be greater than 0.");
                        showAddFormWithError(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid price format.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                try {
                    stockQuantity = Integer.parseInt(stockStr);
                    if (stockQuantity < 0) {
                        request.setAttribute("errorMessage", "Stock quantity cannot be negative.");
                        showAddFormWithError(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid stock quantity format.");
                    showAddFormWithError(request, response);
                    return;
                }
                
                // Parse optional fields
                if (publicationYearStr != null && !publicationYearStr.trim().isEmpty()) {
                    try {
                        publicationYear = Integer.parseInt(publicationYearStr);
                        if (publicationYear < 1000 || publicationYear > java.time.Year.now().getValue()) {
                            request.setAttribute("errorMessage", "Invalid publication year.");
                            showAddFormWithError(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("errorMessage", "Invalid publication year format.");
                        showAddFormWithError(request, response);
                        return;
                    }
                }
                
                if (pagesStr != null && !pagesStr.trim().isEmpty()) {
                    try {
                        pages = Integer.parseInt(pagesStr);
                        if (pages < 0) {
                            request.setAttribute("errorMessage", "Number of pages cannot be negative.");
                            showAddFormWithError(request, response);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("errorMessage", "Invalid pages format.");
                        showAddFormWithError(request, response);
                        return;
                    }
                }
                
                // Create book object
                Book book = new Book();
                
                // Handle book code - Let service auto-generate if empty or invalid
                if (bookCode != null && !bookCode.trim().isEmpty()) {
                    // Only set if user provided a code, otherwise let service generate
                    book.setBookCode(bookCode.trim());
                }
                
                book.setTitle(title.trim());
                book.setAuthor(author.trim());
                book.setPrice(price);
                book.setStockQuantity(stockQuantity);
                book.setImagePath(imagePath);
                
                // Handle optional fields
                if (description != null && !description.trim().isEmpty()) {
                    book.setDescription(description.trim());
                }
                
                if (isbn != null && !isbn.trim().isEmpty()) {
                    book.setIsbn(isbn.trim());
                }
                
                if (publisher != null && !publisher.trim().isEmpty()) {
                    book.setPublisher(publisher.trim());
                }
                
                if (publicationYear > 0) {
                    book.setPublicationYear(publicationYear);
                }
                
                if (pages > 0) {
                    book.setPages(pages);
                }
                
                if (language != null && !language.trim().isEmpty()) {
                    book.setLanguage(language.trim());
                } else {
                    book.setLanguage("Sinhala"); // Default language
                }
                
                if (bookCategory != null && !bookCategory.trim().isEmpty()) {
                    book.setBookCategory(bookCategory.trim());
                }
                
                // Try to add book to database
                bookService.addBook(book);
                
                // If we reach here, book was added successfully
                HttpSession session = request.getSession();
                String finalBookCode = book.getBookCode(); // Get the assigned book code
                session.setAttribute("successMessage", 
                    "📚 Book '" + title + "' by " + author + " has been successfully added to the library with code: " + finalBookCode);
                
                // Redirect to book list
                response.sendRedirect("book?action=list");
                return; // Exit the retry loop
                
            } catch (SQLException e) {
                retryCount++;
                
                // Check if it's a duplicate key error
                if (e.getMessage().contains("already exists") || e.getMessage().contains("Duplicate entry")) {
                    if (retryCount < maxRetries) {
                        // Clear the book code to force auto-generation on retry
                        System.out.println("Retry attempt " + retryCount + " - Book code conflict, trying again...");
                        
                        // Add a small delay to avoid rapid retries
                        try {
                            Thread.sleep(10); // 10ms delay
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                        }
                        
                        continue; // Retry the operation
                    } else {
                        // Maximum retries reached
                        request.setAttribute("errorMessage", 
                            "❌ Unable to generate a unique book code after " + maxRetries + " attempts. Please try again in a moment.");
                        showAddFormWithError(request, response);
                        return;
                    }
                } else {
                    // Other SQL errors
                    request.setAttribute("errorMessage", "Database error: " + e.getMessage());
                    showAddFormWithError(request, response);
                    return;
                }
                
            } catch (IllegalArgumentException e) {
                // Validation errors from service layer
                if (e.getMessage().contains("already exists")) {
                    // Suggest alternative book code
                    try {
                        String originalCode = request.getParameter("bookCode");
                        if (originalCode != null && !originalCode.trim().isEmpty()) {
                            String suggestedCode = bookService.suggestAlternativeBookCode(originalCode.trim());
                            request.setAttribute("suggestedBookCode", suggestedCode);
                            request.setAttribute("errorMessage", 
                                "❌ Book code '" + originalCode.trim() + "' already exists. " +
                                "Suggested alternative: " + suggestedCode + " (or leave blank for auto-generation)");
                        } else {
                            request.setAttribute("errorMessage", e.getMessage());
                        }
                    } catch (SQLException sqlEx) {
                        request.setAttribute("errorMessage", e.getMessage());
                    }
                } else {
                    request.setAttribute("errorMessage", e.getMessage());
                }
                showAddFormWithError(request, response);
                return;
                
            } catch (Exception e) {
                // Other unexpected errors
                request.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
                showAddFormWithError(request, response);
                return;
            }
        }
    }
    
    /**
     * Handle image upload and return the path
     */
    private String handleImageUpload(Part imagePart) throws IOException {
        String fileName = getFileName(imagePart);
        if (fileName == null || fileName.trim().isEmpty()) {
            return null;
        }
        
        // Validate file type
        String contentType = imagePart.getContentType();
        if (!isValidImageType(contentType)) {
            throw new IllegalArgumentException("Invalid image format. Only JPG, PNG, and GIF are allowed.");
        }
        
        // Generate unique file name
        String fileExtension = getFileExtension(fileName);
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
        
        // Get upload path
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        
        // Save file
        Path filePath = Paths.get(uploadPath, uniqueFileName);
        Files.copy(imagePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        // Return relative path for database storage
        return UPLOAD_DIR + "/" + uniqueFileName;
    }
    
    /**
     * Get file name from Part
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
    
    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        int lastIndexOf = fileName.lastIndexOf(".");
        if (lastIndexOf == -1) {
            return "";
        }
        return fileName.substring(lastIndexOf);
    }
    
    /**
     * Validate image type
     */
    private boolean isValidImageType(String contentType) {
        return contentType != null && (
            contentType.equals("image/jpeg") ||
            contentType.equals("image/jpg") ||
            contentType.equals("image/png") ||
            contentType.equals("image/gif")
        );
    }
    
    /**
     * Delete image file
     */
    private void deleteImageFile(String imagePath) {
        if (imagePath != null && !imagePath.trim().isEmpty()) {
            try {
                String fullPath = getServletContext().getRealPath("") + File.separator + imagePath;
                File file = new File(fullPath);
                if (file.exists()) {
                    file.delete();
                }
            } catch (Exception e) {
                System.err.println("Error deleting image file: " + e.getMessage());
            }
        }
    }
    
    /**
     * Helper method to show add form with error and preserve form data
     */
    private void showAddFormWithError(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Preserve form data
        request.setAttribute("formData", request.getParameterMap());
        
        try {
            // Get suggested book code for display
            String suggestedCode = bookService.getNextAvailableBookCode();
            if (request.getAttribute("suggestedBookCode") == null) {
                request.setAttribute("suggestedBookCode", suggestedCode);
            }
            
            // Get all categories for dropdown
            List<String> categories = bookService.getAllBookCategories();
            request.setAttribute("categories", categories);
            
        } catch (SQLException e) {
            System.err.println("Could not generate suggested book code: " + e.getMessage());
        }
        
        request.getRequestDispatcher("WEB-INF/view/book/addBook.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String bookIdParam = request.getParameter("id");
            if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid book ID.");
                response.sendRedirect("book?action=list");
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            Book book = bookService.getBookById(bookId);
            
            if (book != null) {
                request.setAttribute("book", book);
                
                // Get all categories for dropdown
                List<String> categories = bookService.getAllBookCategories();
                request.setAttribute("categories", categories);
                
                request.getRequestDispatcher("WEB-INF/view/book/editBook.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Book not found.");
                response.sendRedirect("book?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid book ID format.");
            response.sendRedirect("book?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error loading book: " + e.getMessage());
            response.sendRedirect("book?action=list");
        }
    }
    
    private void updateBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get form parameters
            String bookIdParam = request.getParameter("bookId");
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String isbn = request.getParameter("isbn");
            String publisher = request.getParameter("publisher");
            String publicationYearStr = request.getParameter("publicationYear");
            String pagesStr = request.getParameter("pages");
            String language = request.getParameter("language");
            String bookCategory = request.getParameter("bookCategory");
            String removeImage = request.getParameter("removeImage");
            
            // Basic validation
            if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Invalid book ID.");
                showEditForm(request, response);
                return;
            }
            
            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Book title is required.");
                showEditForm(request, response);
                return;
            }
            
            if (author == null || author.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Author name is required.");
                showEditForm(request, response);
                return;
            }
            
            if (priceStr == null || priceStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Price is required.");
                showEditForm(request, response);
                return;
            }
            
            if (stockStr == null || stockStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Stock quantity is required.");
                showEditForm(request, response);
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            double price = Double.parseDouble(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);
            int publicationYear = 0;
            int pages = 0;
            
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                showEditForm(request, response);
                return;
            }
            
            if (stockQuantity < 0) {
                request.setAttribute("errorMessage", "Stock quantity cannot be negative.");
                showEditForm(request, response);
                return;
            }
            
            // Parse optional fields
            if (publicationYearStr != null && !publicationYearStr.trim().isEmpty()) {
                try {
                    publicationYear = Integer.parseInt(publicationYearStr);
                    if (publicationYear < 1000 || publicationYear > java.time.Year.now().getValue()) {
                        request.setAttribute("errorMessage", "Invalid publication year.");
                        showEditForm(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid publication year format.");
                    showEditForm(request, response);
                    return;
                }
            }
            
            if (pagesStr != null && !pagesStr.trim().isEmpty()) {
                try {
                    pages = Integer.parseInt(pagesStr);
                    if (pages < 0) {
                        request.setAttribute("errorMessage", "Number of pages cannot be negative.");
                        showEditForm(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid pages format.");
                    showEditForm(request, response);
                    return;
                }
            }
            
            // Get existing book data first
            Book existingBook = bookService.getBookById(bookId);
            if (existingBook == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Book not found.");
                response.sendRedirect("book?action=list");
                return;
            }
            
            // Handle image upload/removal
            String imagePath = existingBook.getImagePath();
            
            // Check if user wants to remove existing image
            if ("true".equals(removeImage)) {
                if (imagePath != null) {
                    deleteImageFile(imagePath);
                }
                imagePath = null;
            }
            
            // Handle new image upload
            Part imagePart = request.getPart("bookImage");
            if (imagePart != null && imagePart.getSize() > 0) {
                // Delete old image if exists
                if (imagePath != null) {
                    deleteImageFile(imagePath);
                }
                // Upload new image
                imagePath = handleImageUpload(imagePart);
            }
            
            // Create updated book object
            Book book = new Book();
            book.setBookId(bookId);
            book.setBookCode(existingBook.getBookCode()); // Keep original book code
            book.setTitle(title.trim());
            book.setAuthor(author.trim());
            book.setPrice(price);
            book.setStockQuantity(stockQuantity);
            book.setCreatedDate(existingBook.getCreatedDate()); // Keep original created date
            book.setImagePath(imagePath);
            
            // Handle optional fields
            if (description != null && !description.trim().isEmpty()) {
                book.setDescription(description.trim());
            } else {
                book.setDescription(null);
            }
            
            if (isbn != null && !isbn.trim().isEmpty()) {
                book.setIsbn(isbn.trim());
            } else {
                book.setIsbn(null);
            }
            
            if (publisher != null && !publisher.trim().isEmpty()) {
                book.setPublisher(publisher.trim());
            } else {
                book.setPublisher(null);
            }
            
            if (publicationYear > 0) {
                book.setPublicationYear(publicationYear);
            }
            
            if (pages > 0) {
                book.setPages(pages);
            }
            
            if (language != null && !language.trim().isEmpty()) {
                book.setLanguage(language.trim());
            } else {
                book.setLanguage("Sinhala");
            }
            
            if (bookCategory != null && !bookCategory.trim().isEmpty()) {
                book.setBookCategory(bookCategory.trim());
            } else {
                book.setBookCategory(null);
            }
            
            // Update book in database
            bookService.updateBook(book);
            
            // Set success message in session for redirect
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "📚 Book '" + title + "' has been successfully updated.");
            
            // Redirect to book list
            response.sendRedirect("book?action=list");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format in form data.");
            showEditForm(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating book: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String bookIdParam = request.getParameter("id");
            if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid book ID.");
                response.sendRedirect("book?action=list");
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            
            // Get book info before deletion for success message and image cleanup
            Book bookToDelete = bookService.getBookById(bookId);
            if (bookToDelete == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Book not found.");
                response.sendRedirect("book?action=list");
                return;
            }
            
            // Delete associated image file
            if (bookToDelete.getImagePath() != null) {
                deleteImageFile(bookToDelete.getImagePath());
            }
            
            // Delete book
            bookService.deleteBook(bookId);
            
            // Set success message
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", 
                "🗑️ Book '" + bookToDelete.getTitle() + "' by " + bookToDelete.getAuthor() + " has been successfully deleted.");
            
            // Redirect to book list
            response.sendRedirect("book?action=list");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid book ID format.");
            response.sendRedirect("book?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting book: " + e.getMessage());
            response.sendRedirect("book?action=list");
        }
    }
    
    private void searchBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                response.sendRedirect("book?action=list");
                return;
            }
            
            List<Book> books = bookService.searchBooks(searchTerm.trim());
            List<String> categories = bookService.getAllBookCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("searchTerm", searchTerm.trim());
            
            if (books.isEmpty()) {
                request.setAttribute("errorMessage", "No books found matching '" + searchTerm + "'.");
            } else {
                request.setAttribute("successMessage", "Found " + books.size() + " book(s) matching '" + searchTerm + "'.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/book/listBooks.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching books: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void searchBooksByAuthor(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String author = request.getParameter("author");
            if (author == null || author.trim().isEmpty()) {
                response.sendRedirect("book?action=list");
                return;
            }
            
            List<Book> books = bookService.getBooksByAuthor(author.trim());
            List<String> categories = bookService.getAllBookCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("searchTerm", "Author: " + author.trim());
            
            if (books.isEmpty()) {
                request.setAttribute("errorMessage", "No books found by author '" + author + "'.");
            } else {
                request.setAttribute("successMessage", "Found " + books.size() + " book(s) by author '" + author + "'.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/book/listBooks.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching books by author: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void searchBooksByLanguage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String language = request.getParameter("language");
            if (language == null || language.trim().isEmpty()) {
                response.sendRedirect("book?action=list");
                return;
            }
            
            List<Book> books = bookService.getBooksByLanguage(language.trim());
            List<String> categories = bookService.getAllBookCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("searchTerm", "Language: " + language.trim());
            
            if (books.isEmpty()) {
                request.setAttribute("errorMessage", "No books found in '" + language + "' language.");
            } else {
                request.setAttribute("successMessage", "Found " + books.size() + " book(s) in '" + language + "' language.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/book/listBooks.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching books by language: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void searchBooksByCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String category = request.getParameter("category");
            if (category == null || category.trim().isEmpty()) {
                response.sendRedirect("book?action=list");
                return;
            }
            
            List<Book> books = bookService.getBooksByCategory(category.trim());
            List<String> categories = bookService.getAllBookCategories();
            
            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("searchTerm", "Category: " + category.trim());
            
            if (books.isEmpty()) {
                request.setAttribute("errorMessage", "No books found in '" + category + "' category.");
            } else {
                request.setAttribute("successMessage", "Found " + books.size() + " book(s) in '" + category + "' category.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/book/listBooks.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching books by category: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void viewBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String bookIdParam = request.getParameter("id");
            if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid book ID.");
                response.sendRedirect("book?action=list");
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            Book book = bookService.getBookById(bookId);
            
            if (book != null) {
                request.setAttribute("book", book);
                request.getRequestDispatcher("WEB-INF/view/book/viewBook.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Book not found.");
                response.sendRedirect("book?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid book ID format.");
            response.sendRedirect("book?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading book: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}