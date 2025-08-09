// BookService.java - Fixed Version with Thread-safe Book Code Generation + Image and Category Support
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;
import com.redupahana.dao.BookDAO;
import com.redupahana.model.Book;
import com.redupahana.util.ValidationUtil;

public class BookService {
    
    private static BookService instance;
    private static final ReentrantLock instanceLock = new ReentrantLock();
    private static final ReentrantLock codeGenerationLock = new ReentrantLock();
    private BookDAO bookDAO;
    
    private BookService() {
        this.bookDAO = new BookDAO();
    }
    
    public static BookService getInstance() {
        if (instance == null) {
            instanceLock.lock();
            try {
                if (instance == null) {
                    instance = new BookService();
                }
            } finally {
                instanceLock.unlock();
            }
        }
        return instance;
    }
    
    public void addBook(Book book) throws SQLException {
        validateBook(book);
        
        // Thread-safe book code generation
        codeGenerationLock.lock();
        try {
            // Generate unique book code if not provided
            if (book.getBookCode() == null || book.getBookCode().trim().isEmpty()) {
                String uniqueCode = generateUniqueBookCodeSafe();
                book.setBookCode(uniqueCode);
            } else {
                // Check if provided code already exists
                if (!isBookCodeAvailable(book.getBookCode().trim())) {
                    throw new IllegalArgumentException("Book code '" + book.getBookCode() + "' already exists. Please use a different code.");
                }
                book.setBookCode(book.getBookCode().trim());
            }
            
            // Check for duplicate ISBN
            if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) {
                Book existingBook = bookDAO.getBookByIsbn(book.getIsbn().trim());
                if (existingBook != null) {
                    throw new IllegalArgumentException("A book with ISBN " + book.getIsbn() + " already exists.");
                }
            }
            
            // Add book to database
            bookDAO.addBook(book);
            
        } finally {
            codeGenerationLock.unlock();
        }
    }
    
    /**
     * Thread-safe method to generate unique book code with database verification
     */
    private String generateUniqueBookCodeSafe() throws SQLException {
        int attempts = 0;
        int maxAttempts = 100;
        
        while (attempts < maxAttempts) {
            attempts++;
            
            // Method 1: Try sequential numbering first
            String sequentialCode = generateSequentialBookCode();
            if (isBookCodeAvailable(sequentialCode)) {
                return sequentialCode;
            }
            
            // Method 2: If sequential fails, try timestamp-based
            String timestampCode = generateTimestampBookCode();
            if (isBookCodeAvailable(timestampCode)) {
                return timestampCode;
            }
            
            // Method 3: Random number based (fallback)
            String randomCode = generateRandomBookCode();
            if (isBookCodeAvailable(randomCode)) {
                return randomCode;
            }
            
            // Small delay to avoid tight loop
            try {
                Thread.sleep(1);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
        
        throw new SQLException("Unable to generate unique book code after " + maxAttempts + " attempts");
    }
    
    /**
     * Generate sequential book code (BOO001, BOO002, etc.)
     */
    private String generateSequentialBookCode() throws SQLException {
        List<Book> allBooks = bookDAO.getAllBooks();
        int maxNumber = 0;
        
        // Find the highest existing number in BOO### format
        for (Book book : allBooks) {
            String code = book.getBookCode();
            if (code != null && code.startsWith("BOO") && code.length() == 6) {
                try {
                    String numberPart = code.substring(3);
                    int number = Integer.parseInt(numberPart);
                    maxNumber = Math.max(maxNumber, number);
                } catch (NumberFormatException e) {
                    // Skip non-numeric codes
                }
            }
        }
        
        // Generate next available code
        int nextNumber = maxNumber + 1;
        return "BOO" + String.format("%03d", nextNumber);
    }
    
    /**
     * Generate timestamp-based book code
     */
    private String generateTimestampBookCode() {
        long timestamp = System.currentTimeMillis();
        String timestampStr = String.valueOf(timestamp);
        String last5Digits = timestampStr.substring(Math.max(0, timestampStr.length() - 5));
        return "BOO" + last5Digits;
    }
    
    /**
     * Generate random number based book code
     */
    private String generateRandomBookCode() {
        int randomNum = (int) (Math.random() * 99999) + 1;
        return "BOO" + String.format("%05d", randomNum);
    }
    
    /**
     * Alternative method using database auto-increment simulation
     */
    private String generateDatabaseBasedCode() throws SQLException {
        // This method tries to use a more database-centric approach
        try {
            // Get current max item_id and use it as base
            List<Book> books = bookDAO.getAllBooks();
            int maxId = 0;
            for (Book book : books) {
                maxId = Math.max(maxId, book.getBookId());
            }
            
            // Generate code based on next expected ID
            int nextId = maxId + 1;
            return "BOO" + String.format("%03d", nextId);
        } catch (Exception e) {
            // Fallback to timestamp if this fails
            return generateTimestampBookCode();
        }
    }
    
    public List<Book> getAllBooks() throws SQLException {
        return bookDAO.getAllBooks();
    }
    
    public Book getBookById(int bookId) throws SQLException {
        if (bookId <= 0) {
            throw new IllegalArgumentException("Invalid book ID");
        }
        return bookDAO.getBookById(bookId);
    }
    
    public Book getBookByCode(String bookCode) throws SQLException {
        if (!ValidationUtil.isNotEmpty(bookCode)) {
            throw new IllegalArgumentException("Book code is required");
        }
        return bookDAO.getBookByCode(bookCode);
    }
    
    public Book getBookByIsbn(String isbn) throws SQLException {
        if (!ValidationUtil.isNotEmpty(isbn)) {
            throw new IllegalArgumentException("ISBN is required");
        }
        return bookDAO.getBookByIsbn(isbn);
    }
    
    public void updateBook(Book book) throws SQLException {
        validateBookForUpdate(book);
        
        // Check for duplicate ISBN (exclude current book)
        if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) {
            Book existingBook = bookDAO.getBookByIsbn(book.getIsbn());
            if (existingBook != null && existingBook.getBookId() != book.getBookId()) {
                throw new IllegalArgumentException("Another book with ISBN " + book.getIsbn() + " already exists.");
            }
        }
        
        bookDAO.updateBook(book);
    }
    
    public void deleteBook(int bookId) throws SQLException {
        if (bookId <= 0) {
            throw new IllegalArgumentException("Invalid book ID");
        }
        bookDAO.deleteBook(bookId);
    }
    
    public void updateStock(int bookId, int quantity) throws SQLException {
        if (bookId <= 0) {
            throw new IllegalArgumentException("Invalid book ID");
        }
        if (!ValidationUtil.isValidQuantity(quantity)) {
            throw new IllegalArgumentException("Invalid quantity");
        }
        bookDAO.updateStock(bookId, quantity);
    }
    
    public List<Book> searchBooks(String searchTerm) throws SQLException {
        if (!ValidationUtil.isNotEmpty(searchTerm)) {
            throw new IllegalArgumentException("Search term is required");
        }
        return bookDAO.searchBooks(searchTerm);
    }
    
    public List<Book> getBooksByAuthor(String author) throws SQLException {
        if (!ValidationUtil.isNotEmpty(author)) {
            throw new IllegalArgumentException("Author name is required");
        }
        return bookDAO.getBooksByAuthor(author);
    }
    
    public List<Book> getBooksByLanguage(String language) throws SQLException {
        if (!ValidationUtil.isNotEmpty(language)) {
            throw new IllegalArgumentException("Language is required");
        }
        return bookDAO.getBooksByLanguage(language);
    }
    
    // New method for getting books by category
    public List<Book> getBooksByCategory(String category) throws SQLException {
        if (!ValidationUtil.isNotEmpty(category)) {
            throw new IllegalArgumentException("Category is required");
        }
        return bookDAO.getBooksByCategory(category);
    }
    
    // New method for getting all book categories
    public List<String> getAllBookCategories() throws SQLException {
        return bookDAO.getAllBookCategories();
    }
    
    /**
     * Thread-safe method to check if a book code is available
     */
    public boolean isBookCodeAvailable(String bookCode) throws SQLException {
        if (bookCode == null || bookCode.trim().isEmpty()) {
            return false;
        }
        
        // Double-check with database to ensure accuracy
        Book existingBook = bookDAO.getBookByCode(bookCode.trim());
        return existingBook == null;
    }
    
    /**
     * Suggest available book codes if provided code exists
     */
    public String suggestAlternativeBookCode(String requestedCode) throws SQLException {
        if (isBookCodeAvailable(requestedCode)) {
            return requestedCode;
        }
        
        // Try variations of the requested code
        String base = requestedCode.replaceAll("\\d+$", "");
        if (base.equals(requestedCode)) {
            base = requestedCode + "_";
        }
        
        for (int i = 1; i <= 99; i++) {
            String alternative = base + String.format("%02d", i);
            if (isBookCodeAvailable(alternative)) {
                return alternative;
            }
        }
        
        // If all variations fail, generate a new unique code
        return generateUniqueBookCodeSafe();
    }
    
    /**
     * Get the next available book code for display purposes
     */
    public String getNextAvailableBookCode() throws SQLException {
        codeGenerationLock.lock();
        try {
            return generateUniqueBookCodeSafe();
        } finally {
            codeGenerationLock.unlock();
        }
    }
    
    /**
     * Validate book data
     */
    private void validateBook(Book book) {
        if (!ValidationUtil.isNotEmpty(book.getTitle())) {
            throw new IllegalArgumentException("Book title is required");
        }
        if (!ValidationUtil.isNotEmpty(book.getAuthor())) {
            throw new IllegalArgumentException("Author name is required");
        }
        if (!ValidationUtil.isValidPrice(book.getPrice())) {
            throw new IllegalArgumentException("Price must be greater than 0");
        }
        if (book.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }
        if (book.getPublicationYear() > 0 && book.getPublicationYear() > java.time.Year.now().getValue()) {
            throw new IllegalArgumentException("Publication year cannot be in the future");
        }
        if (book.getPages() < 0) {
            throw new IllegalArgumentException("Number of pages cannot be negative");
        }
    }
    
    /**
     * Validate book data for update operations
     */
    private void validateBookForUpdate(Book book) {
        if (book.getBookId() <= 0) {
            throw new IllegalArgumentException("Invalid book ID");
        }
        validateBook(book);
    }
    
    /**
     * Get book statistics
     */
    public BookStatistics getBookStatistics() throws SQLException {
        List<Book> allBooks = getAllBooks();
        return new BookStatistics(allBooks);
    }
    
    /**
     * Inner class for book statistics
     */
    public static class BookStatistics {
        private final int totalBooks;
        private final int booksInStock;
        private final int booksOutOfStock;
        private final double totalInventoryValue;
        
        public BookStatistics(List<Book> books) {
            this.totalBooks = books.size();
            this.booksInStock = (int) books.stream().filter(b -> b.getStockQuantity() > 0).count();
            this.booksOutOfStock = totalBooks - booksInStock;
            this.totalInventoryValue = books.stream()
                .mapToDouble(b -> b.getPrice() * b.getStockQuantity())
                .sum();
        }
        
        // Getters
        public int getTotalBooks() { return totalBooks; }
        public int getBooksInStock() { return booksInStock; }
        public int getBooksOutOfStock() { return booksOutOfStock; }
        public double getTotalInventoryValue() { return totalInventoryValue; }
    }
}