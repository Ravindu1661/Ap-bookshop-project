// BookService.java
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
        
        // Generate book code if not provided
        if (book.getBookCode() == null || book.getBookCode().isEmpty()) {
            book.setBookCode(BillNumberGenerator.generateItemCode("Books"));
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