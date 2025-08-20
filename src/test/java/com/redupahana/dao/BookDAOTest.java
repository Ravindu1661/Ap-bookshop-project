package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.*;
import com.redupahana.model.Book;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class BookDAOTest {

    private BookDAO bookDAO;
    private Book testBook;
    private String testBookCode;
    
    // Test data constants
    private static final String TEST_ISBN = "978-1111111111";
    private static final String TEST_TITLE = "DAO Test Book";
    private static final String TEST_AUTHOR = "DAO Test Author";

    @BeforeAll
    void setUpAll() {
        bookDAO = new BookDAO();
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        testBook = new Book();
        testBook.setBookCode("BOOK" + System.currentTimeMillis());
        testBook.setTitle(TEST_TITLE);
        testBook.setAuthor(TEST_AUTHOR);
        testBook.setPrice(25.99);
        testBook.setStockQuantity(10);
        testBook.setIsbn(TEST_ISBN);
        testBook.setPublisher("DAO Test Publisher");
        testBook.setPublicationYear(2024);
        testBook.setPages(200);
        testBook.setLanguage("English");
        testBook.setBookCategory("Fiction");
        testBook.setDescription("DAO Test Description");
        testBook.setImageBase64("data:image/jpeg;base64,test");
    }

    @AfterEach
    void tearDown() {
        cleanupTestData();
    }

    @AfterAll
    void tearDownAll() {
        cleanupTestData();
    }

    @Test
    @Order(1)
    @DisplayName("Test Add Book - Success")
    void testAddBook_Success() {
        try {
            assertDoesNotThrow(() -> bookDAO.addBook(testBook));
            assertTrue(testBook.getBookId() > 0, "Book ID should be generated");
            testBookCode = testBook.getBookCode();
            
            // Verify book exists in database
            Book retrievedBook = bookDAO.getBookByCode(testBook.getBookCode());
            assertNotNull(retrievedBook, "Book should exist in database");
            assertEquals(TEST_TITLE, retrievedBook.getTitle());
            assertEquals(TEST_AUTHOR, retrievedBook.getAuthor());
            
            System.out.println("✓ Book added successfully: " + testBook.getBookCode());
            
        } catch (SQLException e) {
            fail("Add book test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Add Book - Duplicate Code")
    void testAddBook_DuplicateCode() {
        try {
            // Add first book
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Try to add duplicate
            Book duplicateBook = new Book();
            duplicateBook.setBookCode(testBook.getBookCode()); // Same code
            duplicateBook.setTitle("Different Title");
            duplicateBook.setAuthor("Different Author");
            duplicateBook.setPrice(19.99);
            duplicateBook.setStockQuantity(5);
            duplicateBook.setIsbn("978-2222222222"); // Different ISBN
            duplicateBook.setBookCategory("Fiction");
            
            SQLException exception = assertThrows(SQLException.class, 
                () -> bookDAO.addBook(duplicateBook));
            
            assertTrue(exception.getMessage().contains("already exists") || 
                      exception.getMessage().contains("Duplicate"));
            
            System.out.println("✓ Duplicate code validation passed");
            
        } catch (SQLException e) {
            fail("Duplicate code test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Get All Books")
    void testGetAllBooks() {
        try {
            // Add test book first
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            List<Book> books = bookDAO.getAllBooks();
            assertNotNull(books, "Books list should not be null");
            assertTrue(books.size() > 0, "Should have at least one book");
            
            // Find our test book
            boolean foundTestBook = books.stream()
                .anyMatch(book -> TEST_TITLE.equals(book.getTitle()));
            assertTrue(foundTestBook, "Should find our test book");
            
            System.out.println("✓ Retrieved " + books.size() + " books from database");
            
        } catch (SQLException e) {
            fail("Get all books test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get Book By ID - Found")
    void testGetBookById_Found() {
        try {
            // Add test book first
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            int bookId = testBook.getBookId();
            
            Book retrievedBook = bookDAO.getBookById(bookId);
            assertNotNull(retrievedBook, "Should find book by valid ID");
            assertEquals(TEST_TITLE, retrievedBook.getTitle());
            assertEquals(bookId, retrievedBook.getBookId());
            
            System.out.println("✓ Found book by ID: " + bookId);
            
        } catch (SQLException e) {
            fail("Get book by ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get Book By ID - Not Found")
    void testGetBookById_NotFound() {
        try {
            Book retrievedBook = bookDAO.getBookById(999999);
            assertNull(retrievedBook, "Should return null for invalid ID");
            
            System.out.println("✓ Correctly returned null for invalid ID");
            
        } catch (SQLException e) {
            fail("Get book by invalid ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Update Book - Success")
    void testUpdateBook_Success() {
        try {
            // Add test book first
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Update the book
            testBook.setTitle("Updated DAO Test Title");
            testBook.setPrice(35.99);
            testBook.setStockQuantity(15);
            
            assertDoesNotThrow(() -> bookDAO.updateBook(testBook));
            
            // Verify update
            Book updatedBook = bookDAO.getBookById(testBook.getBookId());
            assertNotNull(updatedBook, "Updated book should exist");
            assertEquals("Updated DAO Test Title", updatedBook.getTitle());
            assertEquals(35.99, updatedBook.getPrice(), 0.01);
            assertEquals(15, updatedBook.getStockQuantity());
            
            System.out.println("✓ Book updated successfully");
            
        } catch (SQLException e) {
            fail("Update book test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test Delete Book")
    void testDeleteBook() {
        try {
            // Add test book first
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            int bookId = testBook.getBookId();
            
            assertDoesNotThrow(() -> bookDAO.deleteBook(bookId));
            
            // Verify deletion (should return null for inactive book)
            Book deletedBook = bookDAO.getBookById(bookId);
            assertNull(deletedBook, "Deleted book should not be found");
            
            System.out.println("✓ Book deleted successfully");
            
        } catch (SQLException e) {
            fail("Delete book test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(8)
    @DisplayName("Test Search Books")
    void testSearchBooks() {
        try {
            // Add test book first
            bookDAO.addBook(testBook);
            testBookCode = testBook.getBookCode();
            
            // Search by title
            List<Book> searchResults = bookDAO.searchBooks("DAO Test");
            assertNotNull(searchResults, "Search results should not be null");
            assertTrue(searchResults.size() > 0, "Should find at least one book");
            
            // Verify our book is in results
            boolean foundTestBook = searchResults.stream()
                .anyMatch(book -> TEST_TITLE.equals(book.getTitle()));
            assertTrue(foundTestBook, "Should find our test book in search results");
            
            System.out.println("✓ Search found " + searchResults.size() + " books");
            
        } catch (SQLException e) {
            fail("Search books test failed: " + e.getMessage());
        }
    }

    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
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
        } catch (SQLException e) {
            System.err.println("Cleanup failed: " + e.getMessage());
        }
    }
}