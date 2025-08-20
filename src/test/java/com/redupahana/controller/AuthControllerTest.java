// AuthControllerTest.java - Real Integration Test
// File: src/test/java/com/redupahana/controller/AuthControllerTest.java
package com.redupahana.controller;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.junit.jupiter.api.*;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import com.redupahana.dao.UserDAO;
import com.redupahana.dao.CustomerDAO;
import com.redupahana.model.User;
import com.redupahana.model.Customer;
import com.redupahana.util.DBConnectionFactory;
import com.redupahana.util.SecurityUtil;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class AuthControllerTest {

    private AuthController authController;
    private UserDAO userDAO;
    private CustomerDAO customerDAO;
    
    @Mock
    private HttpServletRequest request;
    @Mock
    private HttpServletResponse response;
    @Mock
    private HttpSession session;
    @Mock
    private RequestDispatcher dispatcher;
    
    // Test data constants
    private static final String TEST_USERNAME = "authtest" + (System.currentTimeMillis() % 10000);
    private static final String TEST_CUSTOMER_ACCOUNT = "AUTHCUST" + (System.currentTimeMillis() % 100000);
    private static final String TEST_PASSWORD = "testpass123";
    
    private User testUser;
    private Customer testCustomer;

    @BeforeAll
    void setUpAll() {
        MockitoAnnotations.openMocks(this);
        authController = new AuthController();
        userDAO = new UserDAO();
        customerDAO = new CustomerDAO();
        
        try {
            authController.init();
        } catch (ServletException e) {
            fail("Controller initialization failed: " + e.getMessage());
        }
        
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        try {
            // Create test user with hashed password
            testUser = new User();
            testUser.setUsername(TEST_USERNAME);
            testUser.setPassword(SecurityUtil.hashPassword(TEST_PASSWORD));
            testUser.setRole("ADMIN");
            testUser.setFullName("Test Admin User");
            testUser.setEmail("testadmin@test.com");
            testUser.setPhone("0771234567");
            userDAO.addUser(testUser);
            testUser = userDAO.getUserByUsername(TEST_USERNAME); // Get with ID
            
            // Create test customer
            testCustomer = new Customer();
            testCustomer.setAccountNumber(TEST_CUSTOMER_ACCOUNT);
            testCustomer.setName("Test Customer Auth");
            testCustomer.setAddress("123 Auth Test Street");
            testCustomer.setPhone("0779876543");
            testCustomer.setEmail("testcustauth@test.com");
            customerDAO.addCustomer(testCustomer);
            testCustomer = customerDAO.getCustomerByAccountNumber(TEST_CUSTOMER_ACCOUNT); // Get with ID
            
        } catch (Exception e) {
            fail("Test setup failed: " + e.getMessage());
        }
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
    @DisplayName("Test Staff Login - Success")
    void testStaffLogin_Success() throws ServletException, IOException {
        // Mock request parameters
        when(request.getParameter("action")).thenReturn("login");
        when(request.getParameter("username")).thenReturn(TEST_USERNAME);
        when(request.getParameter("password")).thenReturn(TEST_PASSWORD);
        when(request.getSession()).thenReturn(session);
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doPost(request, response);
        
        // Verify session attributes with ArgumentMatchers instead of exact object comparison
        verify(session).setAttribute(eq("loggedUser"), any(User.class));
        verify(session).setAttribute("userRole", "ADMIN");
        verify(session).setAttribute("loginType", "staff");
        verify(session).setAttribute("showWelcomeNotification", "true");
        
        // Verify request attributes
        verify(request).setAttribute(eq("successMessage"), contains("Welcome back, Test Admin User!"));
        verify(request).setAttribute(eq("redirectUrl"), eq("dashboard?action=admin"));
        verify(request).setAttribute("showSuccess", "true");
        
        // Verify forward to login page
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Staff login success test passed");
    }
    @Test
    @Order(2)
    @DisplayName("Test Staff Login - Invalid Credentials")
    void testStaffLogin_InvalidCredentials() throws ServletException, IOException {
        // Mock request parameters with wrong password
        when(request.getParameter("action")).thenReturn("login");
        when(request.getParameter("username")).thenReturn(TEST_USERNAME);
        when(request.getParameter("password")).thenReturn("wrongpassword");
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doPost(request, response);
        
        // Verify error message
        verify(request).setAttribute("errorMessage", "Invalid username or password");
        verify(dispatcher).forward(request, response);
        
        // Verify session not set
        verify(session, never()).setAttribute(eq("loggedUser"), any());
        
        System.out.println("✓ Staff login invalid credentials test passed");
    }

    @Test
    @Order(3)
    @DisplayName("Test Customer Login - Success")
    void testCustomerLogin_Success() throws ServletException, IOException {
        // Mock request parameters
        when(request.getParameter("action")).thenReturn("customerLogin");
        when(request.getParameter("accountNumber")).thenReturn(TEST_CUSTOMER_ACCOUNT);
        when(request.getSession()).thenReturn(session);
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doPost(request, response);
        
        // Verify session attributes - just check if any Customer object is set
        verify(session).setAttribute(eq("loggedCustomer"), any(Customer.class));
        verify(session).setAttribute("loginType", "customer");
        verify(session).setAttribute("showWelcomeNotification", "true");
        
        // Verify request attributes
        verify(request).setAttribute(eq("successMessage"), argThat(msg -> 
            msg.toString().contains("Welcome, Test Customer Auth!")));
        verify(request).setAttribute("redirectUrl", "customerPortal");
        verify(request).setAttribute("showSuccess", "true");
        
        // Verify forward to login page
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Customer login success test passed");
    }

    @Test
    @Order(4)
    @DisplayName("Test Customer Login - Invalid Account")
    void testCustomerLogin_InvalidAccount() throws ServletException, IOException {
        // Mock request parameters with invalid account number
        when(request.getParameter("action")).thenReturn("customerLogin");
        when(request.getParameter("accountNumber")).thenReturn("INVALID123");
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doPost(request, response);
        
        // Verify error message
        verify(request).setAttribute("errorMessage", "Invalid account number or account is inactive");
        verify(dispatcher).forward(request, response);
        
        // Verify session not set
        verify(session, never()).setAttribute(eq("loggedCustomer"), any());
        
        System.out.println("✓ Customer login invalid account test passed");
    }

    @Test
    @Order(5)
    @DisplayName("Test Logout - Staff User")
    void testLogout_StaffUser() throws ServletException, IOException {
        // Mock request and session for logout
        when(request.getParameter("action")).thenReturn("logout");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testUser);
        when(session.getAttribute("loginType")).thenReturn("staff");
        
        // Execute
        authController.doGet(request, response);
        
        // Verify session invalidation
        verify(session).invalidate();
        
        // Verify logout message setting
        verify(session).setAttribute(eq("logoutMessage"), contains("Goodbye, Test Admin User!"));
        verify(session).setAttribute("logoutUserType", "Administrator");
        verify(session).setAttribute("showLogout", "true");
        
        // Verify redirect to auth page for staff
        verify(response).sendRedirect("auth");
        
        System.out.println("✓ Staff logout test passed");
    }

    @Test
    @Order(6)
    @DisplayName("Test Logout - Customer")
    void testLogout_Customer() throws ServletException, IOException {
        // Mock request and session for customer logout
        when(request.getParameter("action")).thenReturn("logout");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("loggedCustomer")).thenReturn(testCustomer);
        when(session.getAttribute("loginType")).thenReturn("customer");
        
        // Execute
        authController.doGet(request, response);
        
        // Verify session invalidation
        verify(session).invalidate();
        
        // Verify logout message setting
        verify(session).setAttribute(eq("logoutMessage"), contains("Goodbye, Test Customer Auth!"));
        verify(session).setAttribute("logoutUserType", "Customer");
        verify(session).setAttribute("showLogout", "true");
        
        // Verify redirect to customer portal for customers
        verify(response).sendRedirect("customerPortal?showLogout=true");
        
        System.out.println("✓ Customer logout test passed");
    }

    @Test
    @Order(7)
    @DisplayName("Test Show Login Form")
    void testShowLoginForm() throws ServletException, IOException {
        // Mock request for showing login form
        when(request.getParameter("action")).thenReturn(null);
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doGet(request, response);
        
        // Verify forward to login form
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Show login form test passed");
    }

    @Test
    @Order(8)
    @DisplayName("Test Empty Account Number Validation")
    void testEmptyAccountNumberValidation() throws ServletException, IOException {
        // Mock request with empty account number
        when(request.getParameter("action")).thenReturn("customerLogin");
        when(request.getParameter("accountNumber")).thenReturn("");
        when(request.getRequestDispatcher("/WEB-INF/view/login.jsp")).thenReturn(dispatcher);
        
        // Execute
        authController.doPost(request, response);
        
        // Verify error message
        verify(request).setAttribute("errorMessage", "Account number is required");
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Empty account number validation test passed");
    }

    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
            // Delete test users
            String deleteUsersSQL = "DELETE FROM users WHERE username LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteUsersSQL)) {
                stmt.setString(1, "authtest%");
                stmt.executeUpdate();
            }
            
            // Delete test customers
            String deleteCustomersSQL = "DELETE FROM customers WHERE account_number LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteCustomersSQL)) {
                stmt.setString(1, "AUTHCUST%");
                stmt.executeUpdate();
            }
            
        } catch (SQLException e) {
            System.err.println("Cleanup failed: " + e.getMessage());
        }
    }
}