package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.sql.*;
import java.util.List;
import org.junit.jupiter.api.*;
import org.mockito.*;
import com.redupahana.model.User;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserDAOTest {

    @Mock
    private Connection mockConnection;
    
    @Mock
    private PreparedStatement mockStatement;
    
    @Mock
    private ResultSet mockResultSet;
    
    private UserDAO userDAO;
    private User testUser;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        userDAO = new UserDAO();
        
        testUser = new User();
        testUser.setUsername("testuser");
        testUser.setPassword("password123");
        testUser.setRole("ADMIN");
        testUser.setFullName("Test User");
        testUser.setEmail("test@example.com");
        testUser.setPhone("0771234567");
    }

    @Test
    @Order(1)
    @DisplayName("Test User Authentication - Success")
    void testAuthenticate_Success() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            setupMockResultSetForUser();

            // Act
            User authenticatedUser = userDAO.authenticate("testuser", "password123");

            // Assert
            assertNotNull(authenticatedUser);
            assertEquals("testuser", authenticatedUser.getUsername());
            assertEquals("Test User", authenticatedUser.getFullName());
            
            verify(mockStatement).setString(1, "testuser");
            verify(mockStatement).setString(2, "password123");
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test User Authentication - Failed")
    void testAuthenticate_Failed() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(false);

            // Act
            User authenticatedUser = userDAO.authenticate("wronguser", "wrongpassword");

            // Assert
            assertNull(authenticatedUser);
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Add User")
    void testAddUser() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);

            // Act & Assert
            assertDoesNotThrow(() -> userDAO.addUser(testUser));
            
            verify(mockStatement).setString(1, "testuser");
            verify(mockStatement).setString(3, "ADMIN");
            verify(mockStatement).setString(4, "Test User");
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get All Users")
    void testGetAllUsers() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            Statement mockCreateStatement = mock(Statement.class);
            when(mockConnection.createStatement()).thenReturn(mockCreateStatement);
            when(mockCreateStatement.executeQuery(anyString())).thenReturn(mockResultSet);
            
            when(mockResultSet.next()).thenReturn(true, false);
            setupMockResultSetForUser();

            // Act
            List<User> users = userDAO.getAllUsers();

            // Assert
            assertEquals(1, users.size());
            assertEquals("testuser", users.get(0).getUsername());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get User By ID")
    void testGetUserById() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            setupMockResultSetForUser();

            // Act
            User user = userDAO.getUserById(1);

            // Assert
            assertNotNull(user);
            assertEquals("testuser", user.getUsername());
            verify(mockStatement).setInt(1, 1);
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Get User By Username")
    void testGetUserByUsername() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            setupMockResultSetForUser();

            // Act
            User user = userDAO.getUserByUsername("testuser");

            // Assert
            assertNotNull(user);
            assertEquals("testuser", user.getUsername());
            verify(mockStatement).setString(1, "testuser");
        }
    }

    private void setupMockResultSetForUser() throws SQLException {
        when(mockResultSet.getInt("user_id")).thenReturn(1);
        when(mockResultSet.getString("username")).thenReturn("testuser");
        when(mockResultSet.getString("password")).thenReturn("password123");
        when(mockResultSet.getString("role")).thenReturn("ADMIN");
        when(mockResultSet.getString("full_name")).thenReturn("Test User");
        when(mockResultSet.getString("email")).thenReturn("test@example.com");
        when(mockResultSet.getString("phone")).thenReturn("0771234567");
        when(mockResultSet.getBoolean("is_active")).thenReturn(true);
        when(mockResultSet.getString("created_date")).thenReturn("2024-01-01 00:00:00");
    }
}