// BookService.java - Fixed Version
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.BookDAO;
import com.redupahana.model.Book;
import com.redupahana.util.BillNumberGenerator;
import com.redupahana.util.ValidationUtil;

public class BookService {
    
    private static BookService instance;
    private BookDAO bookDAO;
    
    private BookService() {
        this.bookDAO = new BookDAO();
    }
    
    public static BookService getInstance() {
        if (instance == null) {
            synchronized (BookService.class) {
                if (instance == null) {
                    instance = new BookService();
                }
            }
        }
        return instance;
    }
    
    public void addBook(Book book) throws SQLException {
        validateBook(book);
        
        // Generate unique book code if not provided
        if (book.getBookCode() == null || book.getBookCode().isEmpty()) {
            book.setBookCode(generateUniqueBookCode());
        } else {
            // Check if provided code already exists
            Book existingBook = bookDAO.getBookByCode(book.getBookCode());
            if (existingBook != null) {
                throw new IllegalArgumentException("Book code '" + book.getBookCode() + "' already exists. Please use a different code.");
            }
        }
        
        // Check for duplicate ISBN
        if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) {
            Book existingBook = bookDAO.getBookByIsbn(book.getIsbn());
            if (existingBook != null) {
                throw new IllegalArgumentException("A book with ISBN " + book.getIsbn() + " already exists.");
            }
        }
        
        bookDAO.addBook(book);
    }
    
    /**
     * Generate a unique book code by checking existing codes in database
     */
    private String generateUniqueBookCode() throws SQLException {
        String baseCode = "BOO";
        int counter = 1;
        String bookCode;
        
        do {
            bookCode = baseCode + String.format("%03d", counter);
            Book existingBook = bookDAO.getBookByCode(bookCode);
            if (existingBook == null) {
                return bookCode; // Found unique code
            }
            counter++;
        } while (counter <= 9999); // Prevent infinite loop
        
        // If we reach here, generate timestamp-based code
        return baseCode + System.currentTimeMillis() % 100000;
    }
    
    /**
     * Alternative method: Get next available book code number
     */
    private String generateSequentialBookCode() throws SQLException {
        List<Book> allBooks = bookDAO.getAllBooks();
        int maxNumber = 0;
        
        for (Book book : allBooks) {
            String code = book.getBookCode();
            if (code != null && code.startsWith("BOO") && code.length() >= 6) {
                try {
                    String numberPart = code.substring(3);
                    int number = Integer.parseInt(numberPart);
                    maxNumber = Math.max(maxNumber, number);
                } catch (NumberFormatException e) {
                    // Skip non-numeric codes
                }
            }
        }
        
        return "BOO" + String.format("%03d", maxNumber + 1);
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
    
    /**
     * Check if a book code is available
     */
    public boolean isBookCodeAvailable(String bookCode) throws SQLException {
        if (bookCode == null || bookCode.trim().isEmpty()) {
            return false;
        }
        Book existingBook = bookDAO.getBookByCode(bookCode);
        return existingBook == null;
    }
    
    /**
     * Suggest available book codes if provided code exists
     */
    public String suggestAlternativeBookCode(String requestedCode) throws SQLException {
        if (isBookCodeAvailable(requestedCode)) {
            return requestedCode;
        }
        
        // Extract base and try with incremental numbers
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
        
        // Fallback to timestamp
        return base + System.currentTimeMillis() % 1000;
    }
    
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
    
    private void validateBookForUpdate(Book book) {
        if (book.getBookId() <= 0) {
            throw new IllegalArgumentException("Invalid book ID");
        }
        validateBook(book);
    }
}