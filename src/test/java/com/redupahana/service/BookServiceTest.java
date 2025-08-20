// BookServiceTest.java - Real Database Integration Test
// File: src/test/java/com/redupahana/service/BookServiceTest.java
package com.redupahana.service;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.*;
import com.redupahana.dao.BookDAO;
import com.redupahana.model.Book;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class BookServiceTest {

    private BookService bookService;
    private BookDAO bookDAO;
    private Book testBook;
    private String testBookCode;
    
    // Test data 
    private static final String TEST_ISBN = "978-9999999999"; 
    private static final String TEST_TITLE = "Test Book Integration";
    private static final String TEST_AUTHOR = "Test Author Integration";

    @BeforeAll
    void setUpAll() {
        // Initialize service and DAO
        bookService = BookService.getInstance();
        bookDAO = new BookDAO();
        
        // Clean up any existing test data
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        // Create fresh test book for each test
        testBook = new Book();
        testBook.setTitle(TEST_TITLE);
        testBook.setAuthor(TEST_AUTHOR);
        testBook.setPrice(29.99);
        testBook.setStockQuantity(5);
        testBook.setIsbn(TEST_ISBN);
        testBook.setPublisher("Test Publisher");
        testBook.setPublicationYear(2024);
        testBook.setPages(200);
        testBook.setLanguage("English");
        testBook.setBookCategory("Fiction");
        testBook.setDescription("Test book description");
        
        // Set a sample Base64 image (small test image)
        testBook.setImageBase64("data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=");
    }

    @AfterEach
    void tearDown() {
        // Clean up test data after each test
        cleanupTestData();
    }

    @AfterAll
    void tearDownAll() {
        // Final cleanup
        cleanupTestData();
    }

    @Test
    @Order(1)
    @DisplayName("Test Add Book - Valid Data (Real Database)")
    void testAddBook_ValidData() {
        try {
            // Act
            assertDoesNotThrow(() -> bookService.addBook(testBook));
            
            // Assert - verify book was added
            assertNotNull(testBook.getBookCode(), "Book code should be generated");
            assertTrue(testBook.getBookCode().startsWith("BOO"), "Book code should start with BOO");
            
            testBookCode = testBook.getBookCode(); // Store for cleanup
            
            // Verify book exists in database
            Book retrievedBook = bookDAO.getBookByCode(testBook.getBookCode());
            assertNotNull(retrievedBook, "Book should exist in database");
            assertEquals(TEST_TITLE, retrievedBook.getTitle(), "Title should match");
            assertEquals(TEST_AUTHOR, retrievedBook.getAuthor(), "Author should match");
            assertEquals(29.99, retrievedBook.getPrice(), 0.01, "Price should match");
            assertEquals(5, retrievedBook.getStockQuantity(), "Stock should match");
            assertEquals(TEST_ISBN, retrievedBook.getIsbn(), "ISBN should match");
            
            System.out.println("✓ Book added successfully: " + retrievedBook.getBookCode());
            
        } catch (Exception e) {
            fail("Add book test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Add Book - Invalid Data Validation")
    void testAddBook_InvalidData() {
        // Test empty title
        testBook.setTitle("");
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> bookService.addBook(testBook),
            "Should throw exception for empty title"
        );
        assertEquals("Book title is required", exception.getMessage());
        
        // Test empty author
        testBook.setTitle(TEST_TITLE); // Fix title
        testBook.setAuthor("");
        exception = assertThrows(
            IllegalArgumentException.class, 
            () -> bookService.addBook(testBook),
            "Should throw exception for empty author"
        );
        assertEquals("Author name is required", exception.getMessage());
        
        // Test negative price
        testBook.setAuthor(TEST_AUTHOR); // Fix author
        testBook.setPrice(-1.0);
        exception = assertThrows(
            IllegalArgumentException.class, 
            () -> bookService.addBook(testBook),
            "Should throw exception for negative price"
        );
        assertEquals("Price must be greater than 0", exception.getMessage());
        
        // Test negative stock
        testBook.setPrice(29.99); // Fix price
        testBook.setStockQuantity(-1);
        exception = assertThrows(
            IllegalArgumentException.class, 
            () -> bookService.addBook(testBook),
            "Should throw exception for negative stock"
        );
        assertEquals("Stock quantity cannot be negative", exception.getMessage());
        
        System.out.println("✓ Validation tests passed");
    }

    @Test
    @Order(3)
    @DisplayName("Test Add Book - Duplicate ISBN")
    void testAddBook_DuplicateISBN() {
        try {
            // First, add a book
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Try to add another book with same ISBN
            Book duplicateBook = new Book();
            duplicateBook.setTitle("Different Title");
            duplicateBook.setAuthor("Different Author");
            duplicateBook.setPrice(19.99);
            duplicateBook.setStockQuantity(3);
            duplicateBook.setIsbn(TEST_ISBN); // Same ISBN
            duplicateBook.setBookCategory("Fiction");
            
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class, 
                () -> bookService.addBook(duplicateBook),
                "Should throw exception for duplicate ISBN"
            );
            
            assertTrue(exception.getMessage().contains("ISBN"), 
                "Error message should mention ISBN");
            assertTrue(exception.getMessage().contains("already exists"), 
                "Error message should mention already exists");
            
            System.out.println("✓ Duplicate ISBN validation passed");
            
        } catch (Exception e) {
            fail("Duplicate ISBN test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get All Books (Real Database)")
    void testGetAllBooks() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Get all books
            List<Book> books = bookService.getAllBooks();
            
            // Assert
            assertNotNull(books, "Books list should not be null");
            assertTrue(books.size() > 0, "Should have at least one book");
            
            // Find our test book
            boolean foundTestBook = books.stream()
                .anyMatch(book -> TEST_TITLE.equals(book.getTitle()) && 
                                TEST_AUTHOR.equals(book.getAuthor()));
            
            assertTrue(foundTestBook, "Should find our test book in the list");
            
            System.out.println("✓ Retrieved " + books.size() + " books from database");
            
        } catch (Exception e) {
            fail("Get all books test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get Book By ID (Real Database)")
    void testGetBookById() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Get the book ID from database
            Book addedBook = bookDAO.getBookByCode(testBook.getBookCode());
            assertNotNull(addedBook, "Book should exist");
            
            int bookId = addedBook.getBookId();
            
            // Test valid ID
            Book retrievedBook = bookService.getBookById(bookId);
            assertNotNull(retrievedBook, "Should retrieve book by valid ID");
            assertEquals(TEST_TITLE, retrievedBook.getTitle(), "Title should match");
            assertEquals(TEST_AUTHOR, retrievedBook.getAuthor(), "Author should match");
            
            // Test invalid ID
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> bookService.getBookById(-1),
                "Should throw exception for invalid ID"
            );
            assertEquals("Invalid book ID", exception.getMessage());
            
            System.out.println("✓ Get book by ID test passed");
            
        } catch (Exception e) {
            fail("Get book by ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Update Book (Real Database)")
    void testUpdateBook() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Get the book from database
            Book bookToUpdate = bookDAO.getBookByCode(testBook.getBookCode());
            assertNotNull(bookToUpdate, "Book should exist");
            
            // Update the book
            bookToUpdate.setTitle("Updated Test Title");
            bookToUpdate.setPrice(39.99);
            bookToUpdate.setStockQuantity(15);
            
            // Update in database
            assertDoesNotThrow(() -> bookService.updateBook(bookToUpdate));
            
            // Verify update
            Book updatedBook = bookDAO.getBookById(bookToUpdate.getBookId());
            assertNotNull(updatedBook, "Updated book should exist");
            assertEquals("Updated Test Title", updatedBook.getTitle(), "Title should be updated");
            assertEquals(39.99, updatedBook.getPrice(), 0.01, "Price should be updated");
            assertEquals(15, updatedBook.getStockQuantity(), "Stock should be updated");
            
            System.out.println("✓ Book update test passed");
            
        } catch (Exception e) {
            fail("Update book test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test Search Books (Real Database)")
    void testSearchBooks() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Test search by title
            List<Book> searchResults = bookService.searchBooks("Test Book");
            assertNotNull(searchResults, "Search results should not be null");
            assertTrue(searchResults.size() > 0, "Should find at least one book");
            
            // Verify our book is in results
            boolean foundTestBook = searchResults.stream()
                .anyMatch(book -> TEST_TITLE.equals(book.getTitle()));
            assertTrue(foundTestBook, "Should find our test book in search results");
            
            // Test search by author
            searchResults = bookService.searchBooks("Test Author");
            assertTrue(searchResults.size() > 0, "Should find books by author");
            
            // Test empty search term
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> bookService.searchBooks(""),
                "Should throw exception for empty search term"
            );
            assertEquals("Search term is required", exception.getMessage());
            
            System.out.println("✓ Search books test passed");
            
        } catch (Exception e) {
            fail("Search books test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(8)
    @DisplayName("Test Update Stock (Real Database)")
    void testUpdateStock() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Get the book from database
            Book addedBook = bookDAO.getBookByCode(testBook.getBookCode());
            int bookId = addedBook.getBookId();
            int originalStock = addedBook.getStockQuantity();
            
            // Update stock
            int newStock = 20;
            assertDoesNotThrow(() -> bookService.updateStock(bookId, newStock));
            
            // Verify stock update
            Book updatedBook = bookDAO.getBookById(bookId);
            assertEquals(newStock, updatedBook.getStockQuantity(), "Stock should be updated");
            
            System.out.println("✓ Stock update test passed: " + originalStock + " → " + newStock);
            
        } catch (Exception e) {
            fail("Update stock test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(9)
    @DisplayName("Test Book Code Availability (Real Database)")
    void testIsBookCodeAvailable() {
        try {
            // Add a test book first
            bookService.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Test existing code
            assertFalse(bookService.isBookCodeAvailable(testBook.getBookCode()), 
                "Existing book code should not be available");
            
            // Test new code
            assertTrue(bookService.isBookCodeAvailable("BOO99999"), 
                "New book code should be available");
            
            System.out.println("✓ Book code availability test passed");
            
        } catch (Exception e) {
            fail("Book code availability test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(10)
    @DisplayName("Test Database Connection")
    void testDatabaseConnection() {
        try {
            Connection connection = DBConnectionFactory.getConnection();
            assertNotNull(connection, "Database connection should not be null");
            assertFalse(connection.isClosed(), "Database connection should be open");
            
            System.out.println("✓ Database connection test passed");
            
        } catch (SQLException e) {
            fail("Database connection test failed: " + e.getMessage());
        }
    }

    // Helper method to clean up test data
    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
            // Delete test books by ISBN and title
            String deleteSQL = "DELETE FROM items WHERE isbn = ? OR name = ? OR item_code = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteSQL)) {
                stmt.setString(1, TEST_ISBN);
                stmt.setString(2, TEST_TITLE);
                stmt.setString(3, testBookCode != null ? testBookCode : "");
                int deleted = stmt.executeUpdate();
                if (deleted > 0) {
                    System.out.println("Cleaned up " + deleted + " test record(s)");
                }
            }
            
            // Also clean by book code if we have it
            if (testBookCode != null) {
                String deleteByCodeSQL = "DELETE FROM items WHERE item_code = ?";
                try (PreparedStatement stmt = connection.prepareStatement(deleteByCodeSQL)) {
                    stmt.setString(1, testBookCode);
                    stmt.executeUpdate();
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Cleanup failed: " + e.getMessage());
            // Don't fail the test because of cleanup issues
        }
    }

    // Test helper method to verify database state
    private void verifyDatabaseState() {
        try {
            List<Book> allBooks = bookDAO.getAllBooks();
            System.out.println("Current database has " + allBooks.size() + " books");
            
            // Check if test data exists
            boolean hasTestData = allBooks.stream()
                .anyMatch(book -> TEST_ISBN.equals(book.getIsbn()) || 
                               TEST_TITLE.equals(book.getTitle()));
            
            if (hasTestData) {
                System.out.println("⚠️  Test data found in database");
            }
            
        } catch (Exception e) {
            System.err.println("Database state verification failed: " + e.getMessage());
        }
    }
}