// BillControllerTest.java - Real Integration Test
// File: src/test/java/com/redupahana/controller/BillControllerTest.java
package com.redupahana.controller;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.junit.jupiter.api.*;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import com.redupahana.dao.BookDAO;
import com.redupahana.dao.CustomerDAO;
import com.redupahana.dao.UserDAO;
import com.redupahana.model.Bill;
import com.redupahana.model.Book;
import com.redupahana.model.Customer;
import com.redupahana.model.User;
import com.redupahana.service.BillService;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class BillControllerTest {

    private BillController billController;
    private BillService billService;
    private BookDAO bookDAO;
    private CustomerDAO customerDAO;
    private UserDAO userDAO;
    
    @Mock
    private HttpServletRequest request;
    @Mock
    private HttpServletResponse response;
    @Mock
    private HttpSession session;
    @Mock
    private RequestDispatcher dispatcher;
    
    // Test data constants
    private static final String TEST_BOOK_CODE = "BILLCTRL" + (System.currentTimeMillis() % 100000);
    private static final String TEST_CUSTOMER_ACCOUNT = "BILLCUST" + (System.currentTimeMillis() % 100000);
    private static final String TEST_CASHIER_USERNAME = "billcash" + (System.currentTimeMillis() % 10000);
    
    private Book testBook;
    private Customer testCustomer;
    private User testCashier;
    private Bill testBill;

    @BeforeAll
    void setUpAll() {
        MockitoAnnotations.openMocks(this);
        billController = new BillController();
        billService = BillService.getInstance();
        bookDAO = new BookDAO();
        customerDAO = new CustomerDAO();
        userDAO = new UserDAO();
        
        try {
            billController.init();
        } catch (ServletException e) {
            fail("Controller initialization failed: " + e.getMessage());
        }
        
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        try {
            // Create test book
            testBook = new Book();
            testBook.setBookCode(TEST_BOOK_CODE);
            testBook.setTitle("Controller Test Book");
            testBook.setAuthor("Test Author");
            testBook.setPrice(29.99);
            testBook.setStockQuantity(15);
            testBook.setIsbn("978-1111111111");
            testBook.setPublisher("Test Publisher");
            testBook.setPublicationYear(2024);
            testBook.setPages(250);
            testBook.setLanguage("English");
            testBook.setBookCategory("Fiction");
            testBook.setDescription("Test book for controller testing");
            bookDAO.addBook(testBook);
            
            // Create test customer
            testCustomer = new Customer();
            testCustomer.setAccountNumber(TEST_CUSTOMER_ACCOUNT);
            testCustomer.setName("Controller Test Customer");
            testCustomer.setAddress("123 Controller Test Street");
            testCustomer.setPhone("0771234567");
            testCustomer.setEmail("controllercust@test.com");
            customerDAO.addCustomer(testCustomer);
            testCustomer = customerDAO.getCustomerByAccountNumber(TEST_CUSTOMER_ACCOUNT);
            
            // Create test cashier
            testCashier = new User();
            testCashier.setUsername(TEST_CASHIER_USERNAME);
            testCashier.setPassword("testpass123");
            testCashier.setRole("CASHIER");
            testCashier.setFullName("Controller Test Cashier");
            testCashier.setEmail("controllercash@test.com");
            testCashier.setPhone("0779876543");
            userDAO.addUser(testCashier);
            testCashier = userDAO.getUserByUsername(TEST_CASHIER_USERNAME);
            
        } catch (SQLException e) {
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
    @DisplayName("Test List Bills - Access Control")
    void testListBills_AccessControl() throws ServletException, IOException {
        // Test without login - should redirect to auth
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(null);
        
        billController.doGet(request, response);
        
        verify(response).sendRedirect("auth");
        
        System.out.println("✓ List bills access control test passed");
    }

    @Test
    @Order(2)
    @DisplayName("Test List Bills - Authorized User")
    void testListBills_AuthorizedUser() throws ServletException, IOException {
        // Mock authorized user session
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("list");
        when(request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp")).thenReturn(dispatcher);
        
        billController.doGet(request, response);
        
        // Verify bills attribute is set
        verify(request).setAttribute(eq("bills"), any(List.class));
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ List bills authorized user test passed");
    }

    @Test
    @Order(3)
    @DisplayName("Test Show Create Form")
    void testShowCreateForm() throws ServletException, IOException {
        // Mock authorized user session
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("create");
        when(request.getRequestDispatcher("WEB-INF/view/bill/createBill.jsp")).thenReturn(dispatcher);
        
        billController.doGet(request, response);
        
        // Verify required attributes are set
        verify(request).setAttribute(eq("customers"), any(List.class));
        verify(request).setAttribute(eq("books"), any(List.class));
        verify(request).setAttribute(eq("bookCategories"), any(List.class));
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Show create form test passed");
    }

    @Test
    @Order(4)
    @DisplayName("Test Create Bill - Valid Data")
    void testCreateBill_ValidData() throws ServletException, IOException {
        // Mock request parameters for bill creation
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameter("customerId")).thenReturn(String.valueOf(testCustomer.getCustomerId()));
        when(request.getParameter("discount")).thenReturn("0");
        when(request.getParameter("paymentStatus")).thenReturn("PAID");
        
        // Mock bill items
        when(request.getParameterValues("bookId")).thenReturn(new String[]{String.valueOf(testBook.getBookId())});
        when(request.getParameterValues("quantity")).thenReturn(new String[]{"2"});
        when(request.getParameterValues("unitPrice")).thenReturn(new String[]{"29.99"});
        
        billController.doPost(request, response);
        
        // Verify success message is set
        verify(session).setAttribute(eq("successMessage"), contains("successfully created"));
        verify(response).sendRedirect(contains("bill?action=view&id="));
        
        System.out.println("✓ Create bill valid data test passed");
    }

    @Test
    @Order(5)
    @DisplayName("Test Create Bill - Invalid Customer")
    void testCreateBill_InvalidCustomer() throws ServletException, IOException {
        // Mock request with invalid customer ID
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameter("customerId")).thenReturn("-1");
        when(request.getRequestDispatcher("WEB-INF/view/bill/createBill.jsp")).thenReturn(dispatcher);
        
        billController.doPost(request, response);
        
        // Verify error message
        verify(request).setAttribute("errorMessage", "Invalid customer selection.");
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Create bill invalid customer test passed");
    }

    @Test
    @Order(6)
    @DisplayName("Test View Bill - Valid ID")
    void testViewBill_ValidID() throws ServletException, IOException {
        try {
            // First create a bill to view
            Bill bill = new Bill();
            bill.setCustomerId(testCustomer.getCustomerId());
            bill.setCashierId(testCashier.getUserId());
            bill.setDiscount(0.0);
            bill.setPaymentStatus("PAID");
            
            java.util.List<com.redupahana.model.BillItem> billItems = new java.util.ArrayList<>();
            com.redupahana.model.BillItem billItem = new com.redupahana.model.BillItem();
            billItem.setBookId(testBook.getBookId());
            billItem.setQuantity(1);
            billItem.setUnitPrice(testBook.getPrice());
            billItems.add(billItem);
            
            int billId = billService.createBill(bill, billItems);
            
            // Mock request to view the bill
            when(request.getSession()).thenReturn(session);
            when(session.getAttribute("loggedUser")).thenReturn(testCashier);
            when(request.getParameter("action")).thenReturn("view");
            when(request.getParameter("id")).thenReturn(String.valueOf(billId));
            when(request.getRequestDispatcher("WEB-INF/view/bill/viewBill.jsp")).thenReturn(dispatcher);
            
            billController.doGet(request, response);
            
            // Verify bill attributes are set
            verify(request).setAttribute(eq("bill"), any(Bill.class));
            verify(request).setAttribute(eq("customer"), any(Customer.class));
            verify(request).setAttribute(eq("cashier"), any(User.class));
            verify(dispatcher).forward(request, response);
            
            System.out.println("✓ View bill valid ID test passed");
            
        } catch (SQLException e) {
            fail("Test failed due to SQL error: " + e.getMessage());
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test View Bill - Invalid ID")
    void testViewBill_InvalidID() throws ServletException, IOException {
        // Mock request with invalid bill ID
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("view");
        when(request.getParameter("id")).thenReturn("invalid");
        
        billController.doGet(request, response);
        
        // Verify redirect with error message
        verify(session).setAttribute("errorMessage", "Invalid bill ID format.");
        verify(response).sendRedirect("bill?action=list");
        
        System.out.println("✓ View bill invalid ID test passed");
    }

    @Test
    @Order(8)
    @DisplayName("Test Search Bills")
    void testSearchBills() throws ServletException, IOException {
        // Mock search request
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("search");
        when(request.getParameter("searchTerm")).thenReturn("BILL");
        when(request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp")).thenReturn(dispatcher);
        
        billController.doGet(request, response);
        
        // Verify search results
        verify(request).setAttribute(eq("bills"), any(List.class));
        verify(request).setAttribute("searchTerm", "BILL");
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ Search bills test passed");
    }

    @Test
    @Order(9)
    @DisplayName("Test Search Bills - Empty Term")
    void testSearchBills_EmptyTerm() throws ServletException, IOException {
        // Mock search with empty term
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("search");
        when(request.getParameter("searchTerm")).thenReturn("");
        
        billController.doGet(request, response);
        
        // Verify redirect to list
        verify(response).sendRedirect("bill?action=list");
        
        System.out.println("✓ Search bills empty term test passed");
    }

    @Test
    @Order(10)
    @DisplayName("Test View Pending Payments")
    void testViewPendingPayments() throws ServletException, IOException {
        // Mock pending payments request
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("loggedUser")).thenReturn(testCashier);
        when(request.getParameter("action")).thenReturn("pendingPayments");
        when(request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp")).thenReturn(dispatcher);
        
        billController.doGet(request, response);
        
        // Verify pending bills are loaded
        verify(request).setAttribute(eq("bills"), any(List.class));
        verify(request).setAttribute("viewType", "pending");
        verify(dispatcher).forward(request, response);
        
        System.out.println("✓ View pending payments test passed");
    }

    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
            // Delete bills
            String deleteBillsSQL = "DELETE FROM bills WHERE bill_number LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteBillsSQL)) {
                stmt.setString(1, "BILL%");
                stmt.executeUpdate();
            }
            
            // Delete books
            String deleteBooksSQL = "DELETE FROM items WHERE item_code LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteBooksSQL)) {
                stmt.setString(1, "BILLCTRL%");
                stmt.executeUpdate();
            }
            
            // Delete customers
            String deleteCustomersSQL = "DELETE FROM customers WHERE account_number LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteCustomersSQL)) {
                stmt.setString(1, "BILLCUST%");
                stmt.executeUpdate();
            }
            
            // Delete users
            String deleteUsersSQL = "DELETE FROM users WHERE username LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteUsersSQL)) {
                stmt.setString(1, "billcash%");
                stmt.executeUpdate();
            }
            
        } catch (SQLException e) {
            System.err.println("Cleanup failed: " + e.getMessage());
        }
    }
}