package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.sql.*;
import java.util.List;
import org.junit.jupiter.api.*;
import org.mockito.*;
import com.redupahana.model.Book;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class BookDAOTest {

    @Mock
    private Connection mockConnection;
    
    @Mock
    private PreparedStatement mockStatement;
    
    @Mock
    private ResultSet mockResultSet;
    
    private BookDAO bookDAO;
    private Book testBook;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        bookDAO = new BookDAO();
        
        // Test data setup
        testBook = new Book();
        testBook.setBookCode("BOO001");
        testBook.setTitle("Test Book Title");
        testBook.setAuthor("Test Author");
        testBook.setPrice(25.99);
        testBook.setStockQuantity(10);
        testBook.setIsbn("978-0123456789");
        testBook.setPublisher("Test Publisher");
        testBook.setPublicationYear(2023);
        testBook.setPages(200);
        testBook.setLanguage("English");
        testBook.setBookCategory("Fiction");
        testBook.setImageBase64("data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=");
    }

    @Test
    @Order(1)
    @DisplayName("Test Add Book - Success Case")
    void testAddBook_Success() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS)))
                .thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);
            when(mockStatement.getGeneratedKeys()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            when(mockResultSet.getInt(1)).thenReturn(1);

            // Act & Assert
            assertDoesNotThrow(() -> bookDAO.addBook(testBook));
            
            verify(mockStatement).setString(1, "BOO001");
            verify(mockStatement).setString(2, "Test Book Title");
            verify(mockStatement).setDouble(4, 25.99);
            verify(mockConnection).commit();
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Add Book - Duplicate Book Code")
    void testAddBook_DuplicateCode() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS)))
                .thenReturn(mockStatement);
            
            SQLException duplicateException = new SQLException("Duplicate entry 'BOO001' for key 'item_code'");
            when(mockStatement.executeUpdate()).thenThrow(duplicateException);

            // Act & Assert
            SQLException exception = assertThrows(SQLException.class, () -> bookDAO.addBook(testBook));
            assertTrue(exception.getMessage().contains("already exists"));
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Get All Books")
    void testGetAllBooks() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            Statement mockStatement = mock(Statement.class);
            when(mockConnection.createStatement()).thenReturn(mockStatement);
            when(mockStatement.executeQuery(anyString())).thenReturn(mockResultSet);
            
            when(mockResultSet.next()).thenReturn(true, false);
            setupMockResultSetForBook();

            // Act
            List<Book> books = bookDAO.getAllBooks();

            // Assert
            assertEquals(1, books.size());
            assertEquals("BOO001", books.get(0).getBookCode());
            assertEquals("Test Book Title", books.get(0).getTitle());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get Book By ID - Found")
    void testGetBookById_Found() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            setupMockResultSetForBook();

            // Act
            Book book = bookDAO.getBookById(1);

            // Assert
            assertNotNull(book);
            assertEquals("BOO001", book.getBookCode());
            verify(mockStatement).setInt(1, 1);
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get Book By ID - Not Found")
    void testGetBookById_NotFound() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(false);

            // Act
            Book book = bookDAO.getBookById(999);

            // Assert
            assertNull(book);
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Update Book - Success")
    void testUpdateBook_Success() throws SQLException {
        // Arrange
        testBook.setBookId(1);
        
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);

            // Act & Assert
            assertDoesNotThrow(() -> bookDAO.updateBook(testBook));
            
            verify(mockStatement).setString(1, "Test Book Title");
            verify(mockStatement).setInt(13, 1);
            verify(mockConnection).commit();
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test Delete Book")
    void testDeleteBook() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);

            // Act & Assert
            assertDoesNotThrow(() -> bookDAO.deleteBook(1));
            
            verify(mockStatement).setInt(1, 1);
        }
    }

    @Test
    @Order(8)
    @DisplayName("Test Search Books")
    void testSearchBooks() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true, false);
            setupMockResultSetForBook();

            // Act
            List<Book> books = bookDAO.searchBooks("Test");

            // Assert
            assertEquals(1, books.size());
            assertEquals("Test Book Title", books.get(0).getTitle());
            
            // Verify search pattern is set correctly
            verify(mockStatement, times(10)).setString(anyInt(), eq("%Test%"));
        }
    }

    private void setupMockResultSetForBook() throws SQLException {
        when(mockResultSet.getInt("item_id")).thenReturn(1);
        when(mockResultSet.getString("item_code")).thenReturn("BOO001");
        when(mockResultSet.getString("name")).thenReturn("Test Book Title");
        when(mockResultSet.getString("author")).thenReturn("Test Author");
        when(mockResultSet.getDouble("price")).thenReturn(25.99);
        when(mockResultSet.getInt("stock_quantity")).thenReturn(10);
        when(mockResultSet.getString("isbn")).thenReturn("978-0123456789");
        when(mockResultSet.getString("publisher")).thenReturn("Test Publisher");
        when(mockResultSet.getInt("publication_year")).thenReturn(2023);
        when(mockResultSet.getInt("pages")).thenReturn(200);
        when(mockResultSet.getString("language")).thenReturn("English");
        when(mockResultSet.getBoolean("is_active")).thenReturn(true);
        when(mockResultSet.getString("image_base64")).thenReturn("data:image/jpeg;base64,test");
        when(mockResultSet.getString("book_category")).thenReturn("Fiction");
        when(mockResultSet.getString("description")).thenReturn("Test Description");
    }
}