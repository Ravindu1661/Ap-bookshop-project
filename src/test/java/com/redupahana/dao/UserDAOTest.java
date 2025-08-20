package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.*;
import com.redupahana.model.User;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class UserDAOTest {

    private UserDAO userDAO;
    private User testUser;
    
    // Test data constants
    private static final String TEST_USERNAME = "daotest" + System.currentTimeMillis();
    private static final String TEST_EMAIL = "daotest@example.com";

    @BeforeAll
    void setUpAll() {
        userDAO = new UserDAO();
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUsername(TEST_USERNAME);
        testUser.setPassword("testpass123");
        testUser.setRole("ADMIN");
        testUser.setFullName("DAO Test User");
        testUser.setEmail(TEST_EMAIL);
        testUser.setPhone("0771234567");
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
    @DisplayName("Test User Authentication - Success")
    void testAuthenticate_Success() {
        try {
            // Add test user first
            userDAO.addUser(testUser);
            
            User authenticatedUser = userDAO.authenticate(TEST_USERNAME, "testpass123");
            assertNotNull(authenticatedUser, "Authentication should succeed");
            assertEquals(TEST_USERNAME, authenticatedUser.getUsername());
            assertEquals("DAO Test User", authenticatedUser.getFullName());
            
            System.out.println("✓ User authentication successful");
            
        } catch (SQLException e) {
            fail("Authentication test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test User Authentication - Failed")
    void testAuthenticate_Failed() {
        try {
            User authenticatedUser = userDAO.authenticate("wronguser", "wrongpass");
            assertNull(authenticatedUser, "Authentication should fail for invalid credentials");
            
            System.out.println("✓ Invalid authentication correctly rejected");
            
        } catch (SQLException e) {
            fail("Failed authentication test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Add User")
    void testAddUser() {
        try {
            assertDoesNotThrow(() -> userDAO.addUser(testUser));
            
            // Verify user was added
            User retrievedUser = userDAO.getUserByUsername(TEST_USERNAME);
            assertNotNull(retrievedUser, "User should exist in database");
            assertEquals(TEST_USERNAME, retrievedUser.getUsername());
            assertEquals("DAO Test User", retrievedUser.getFullName());
            
            System.out.println("✓ User added successfully");
            
        } catch (SQLException e) {
            fail("Add user test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get All Users")
    void testGetAllUsers() {
        try {
            // Add test user first
            userDAO.addUser(testUser);
            
            List<User> users = userDAO.getAllUsers();
            assertNotNull(users, "Users list should not be null");
            assertTrue(users.size() > 0, "Should have at least one user");
            
            // Find our test user
            boolean foundTestUser = users.stream()
                .anyMatch(user -> TEST_USERNAME.equals(user.getUsername()));
            assertTrue(foundTestUser, "Should find our test user");
            
            System.out.println("✓ Retrieved " + users.size() + " users from database");
            
        } catch (SQLException e) {
            fail("Get all users test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get User By ID")
    void testGetUserById() {
        try {
            // Add test user first
            userDAO.addUser(testUser);
            
            // Get user by username to get the ID
            User addedUser = userDAO.getUserByUsername(TEST_USERNAME);
            assertNotNull(addedUser, "User should exist");
            
            int userId = addedUser.getUserId();
            
            User retrievedUser = userDAO.getUserById(userId);
            assertNotNull(retrievedUser, "Should find user by valid ID");
            assertEquals(TEST_USERNAME, retrievedUser.getUsername());
            assertEquals(userId, retrievedUser.getUserId());
            
            System.out.println("✓ Found user by ID: " + userId);
            
        } catch (SQLException e) {
            fail("Get user by ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Get User By Username")
    void testGetUserByUsername() {
        try {
            // Add test user first
            userDAO.addUser(testUser);
            
            User retrievedUser = userDAO.getUserByUsername(TEST_USERNAME);
            assertNotNull(retrievedUser, "Should find user by username");
            assertEquals(TEST_USERNAME, retrievedUser.getUsername());
            assertEquals("DAO Test User", retrievedUser.getFullName());
            
            System.out.println("✓ Found user by username: " + TEST_USERNAME);
            
        } catch (SQLException e) {
            fail("Get user by username test failed: " + e.getMessage());
        }
    }

    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
            String deleteSQL = "DELETE FROM users WHERE username = ? OR email = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteSQL)) {
                stmt.setString(1, TEST_USERNAME);
                stmt.setString(2, TEST_EMAIL);
                int deleted = stmt.executeUpdate();
                if (deleted > 0) {
                    System.out.println("Cleaned up " + deleted + " user test record(s)");
                }
            }
        } catch (SQLException e) {
            System.err.println("User cleanup failed: " + e.getMessage());
        }
    }
}
