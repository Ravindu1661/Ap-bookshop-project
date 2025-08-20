// BillServiceTest.java - Real Database Integration Test
// File: src/test/java/com/redupahana/service/BillServiceTest.java
package com.redupahana.service;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import org.junit.jupiter.api.*;
import com.redupahana.dao.BookDAO;
import com.redupahana.dao.CustomerDAO;
import com.redupahana.dao.UserDAO;
import com.redupahana.model.Bill;
import com.redupahana.model.BillItem;
import com.redupahana.model.Book;
import com.redupahana.model.Customer;
import com.redupahana.model.User;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class BillServiceTest {

    private BillService billService;
    private BookDAO bookDAO;
    private CustomerDAO customerDAO;
    private UserDAO userDAO;
    
    private Bill testBill;
    private List<BillItem> testBillItems;
    private Book testBook;
    private Customer testCustomer;
    private User testCashier;
    
    // Test data constants
    private static final String TEST_BILL_NUMBER = "BILL" + System.currentTimeMillis();
    private static final String TEST_BOOK_CODE = "BOO" + (System.currentTimeMillis() % 100000);
    private static final String TEST_CUSTOMER_ACCOUNT = "CUST" + (System.currentTimeMillis() % 100000);
    private static final String TEST_CASHIER_USERNAME = "cash" + (System.currentTimeMillis() % 10000);

    @BeforeAll
    void setUpAll() {
        billService = BillService.getInstance();
        bookDAO = new BookDAO();
        customerDAO = new CustomerDAO();
        userDAO = new UserDAO();
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        try {
            // Create test book
            testBook = new Book();
            testBook.setBookCode(TEST_BOOK_CODE);
            testBook.setTitle("Test Book for Bill");
            testBook.setAuthor("Test Author");
            testBook.setPrice(25.99);
            testBook.setStockQuantity(10);
            testBook.setIsbn("978-1234567890");
            testBook.setPublisher("Test Publisher");
            testBook.setPublicationYear(2024);
            testBook.setPages(200);
            testBook.setLanguage("English");
            testBook.setBookCategory("Fiction");
            testBook.setDescription("Test book description");
            bookDAO.addBook(testBook);
            
            // Create test customer
            testCustomer = new Customer();
            testCustomer.setAccountNumber(TEST_CUSTOMER_ACCOUNT);
            testCustomer.setName("Test Customer");
            testCustomer.setAddress("123 Test Street");
            testCustomer.setPhone("0771234567");
            testCustomer.setEmail("testcustomer@test.com");
            customerDAO.addCustomer(testCustomer);
            
            // Get the customer back to get the generated ID
            testCustomer = customerDAO.getCustomerByAccountNumber(TEST_CUSTOMER_ACCOUNT);
            
            // Create test cashier
            testCashier = new User();
            testCashier.setUsername(TEST_CASHIER_USERNAME);
            testCashier.setPassword("testpass123");
            testCashier.setRole("CASHIER");
            testCashier.setFullName("Test Cashier");
            testCashier.setEmail("testcashier@test.com");
            testCashier.setPhone("0779876543");
            userDAO.addUser(testCashier);
            
            // Get the user back to get the generated ID
            testCashier = userDAO.getUserByUsername(TEST_CASHIER_USERNAME);
            
            // Create test bill
            testBill = new Bill();
            testBill.setBillNumber(TEST_BILL_NUMBER);
            testBill.setCustomerId(testCustomer.getCustomerId());
            testBill.setCashierId(testCashier.getUserId());
            testBill.setDiscount(0.0);
            testBill.setPaymentStatus("PENDING");
            
            // Create test bill items
            testBillItems = new ArrayList<>();
            BillItem billItem = new BillItem();
            billItem.setBookId(testBook.getBookId());
            billItem.setQuantity(2);
            billItem.setUnitPrice(testBook.getPrice());
            testBillItems.add(billItem);
            
        } catch (SQLException e) {
            fail("Setup failed: " + e.getMessage());
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
    @DisplayName("Test Create Bill - Success")
    void testCreateBill_Success() {
        try {
            int billId = billService.createBill(testBill, testBillItems);
            
            assertTrue(billId > 0, "Bill ID should be generated");
            assertEquals(billId, testBill.getBillId(), "Bill ID should be set");
            
            // Verify bill was created
            Bill createdBill = billService.getBillById(billId);
            assertNotNull(createdBill, "Bill should exist in database");
            assertEquals(TEST_BILL_NUMBER, createdBill.getBillNumber());
            assertEquals(testCustomer.getCustomerId(), createdBill.getCustomerId());
            assertEquals(testCashier.getUserId(), createdBill.getCashierId());
            
            // Verify bill items
            assertNotNull(createdBill.getBillItems(), "Bill items should exist");
            assertEquals(1, createdBill.getBillItems().size(), "Should have one bill item");
            
            BillItem createdBillItem = createdBill.getBillItems().get(0);
            assertEquals(testBook.getBookId(), createdBillItem.getBookId());
            assertEquals(2, createdBillItem.getQuantity());
            assertEquals(testBook.getPrice(), createdBillItem.getUnitPrice());
            
            // Verify stock was updated
            Book updatedBook = bookDAO.getBookById(testBook.getBookId());
            assertEquals(8, updatedBook.getStockQuantity(), "Stock should be reduced by 2");
            
            System.out.println("✓ Bill created successfully: " + billId);
            
        } catch (Exception e) {
            fail("Create bill test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Create Bill - Invalid Data")
    void testCreateBill_InvalidData() {
        // Test null bill
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> billService.createBill(null, testBillItems),
            "Should throw exception for null bill"
        );
        assertEquals("Bill is required", exception.getMessage());
        
        // Test invalid customer ID
        testBill.setCustomerId(-1);
        exception = assertThrows(
            IllegalArgumentException.class,
            () -> billService.createBill(testBill, testBillItems),
            "Should throw exception for invalid customer ID"
        );
        assertEquals("Valid customer is required", exception.getMessage());
        
        // Test empty bill items
        testBill.setCustomerId(testCustomer.getCustomerId()); // Fix customer ID
        exception = assertThrows(
            IllegalArgumentException.class,
            () -> billService.createBill(testBill, new ArrayList<>()),
            "Should throw exception for empty bill items"
        );
        assertEquals("At least one book item is required", exception.getMessage());
        
        System.out.println("✓ Invalid data validation passed");
    }

    @Test
    @Order(3)
    @DisplayName("Test Create Bill - Insufficient Stock")
    void testCreateBill_InsufficientStock() {
        // Set quantity higher than available stock
        testBillItems.get(0).setQuantity(15); // Book has only 10 in stock
        
        SQLException exception = assertThrows(
            SQLException.class,
            () -> billService.createBill(testBill, testBillItems),
            "Should throw SQLException for insufficient stock"
        );
        
        assertTrue(exception.getMessage().contains("Insufficient stock"));
        
        System.out.println("✓ Insufficient stock validation passed");
    }

    @Test
    @Order(4)
    @DisplayName("Test Get All Bills")
    void testGetAllBills() {
        try {
            // Create a test bill first
            int billId = billService.createBill(testBill, testBillItems);
            
            List<Bill> bills = billService.getAllBills();
            assertNotNull(bills, "Bills list should not be null");
            assertTrue(bills.size() > 0, "Should have at least one bill");
            
            // Find our test bill
            boolean foundTestBill = bills.stream()
                .anyMatch(bill -> TEST_BILL_NUMBER.equals(bill.getBillNumber()));
            assertTrue(foundTestBill, "Should find our test bill");
            
            System.out.println("✓ Retrieved " + bills.size() + " bills from database");
            
        } catch (Exception e) {
            fail("Get all bills test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get Bill By ID")
    void testGetBillById() {
        try {
            // Create a test bill first
            int billId = billService.createBill(testBill, testBillItems);
            
            // Test valid ID
            Bill retrievedBill = billService.getBillById(billId);
            assertNotNull(retrievedBill, "Should retrieve bill by valid ID");
            assertEquals(TEST_BILL_NUMBER, retrievedBill.getBillNumber());
            
            // Test invalid ID
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> billService.getBillById(-1),
                "Should throw exception for invalid ID"
            );
            assertEquals("Invalid bill ID", exception.getMessage());
            
            System.out.println("✓ Get bill by ID test passed");
            
        } catch (Exception e) {
            fail("Get bill by ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Get Bill By Number")
    void testGetBillByNumber() {
        try {
            // Create a test bill first
            billService.createBill(testBill, testBillItems);
            
            Bill retrievedBill = billService.getBillByNumber(TEST_BILL_NUMBER);
            assertNotNull(retrievedBill, "Should find bill by number");
            assertEquals(TEST_BILL_NUMBER, retrievedBill.getBillNumber());
            
            // Test empty bill number
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> billService.getBillByNumber(""),
                "Should throw exception for empty bill number"
            );
            assertEquals("Bill number is required", exception.getMessage());
            
            System.out.println("✓ Get bill by number test passed");
            
        } catch (Exception e) {
            fail("Get bill by number test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test Get Bills By Customer")
    void testGetBillsByCustomer() {
        try {
            // Create a test bill first
            billService.createBill(testBill, testBillItems);
            
            List<Bill> customerBills = billService.getBillsByCustomer(testCustomer.getCustomerId());
            assertNotNull(customerBills, "Customer bills list should not be null");
            assertTrue(customerBills.size() > 0, "Should have at least one bill for customer");
            
            // Verify all bills belong to the customer
            for (Bill bill : customerBills) {
                assertEquals(testCustomer.getCustomerId(), bill.getCustomerId());
            }
            
            System.out.println("✓ Found " + customerBills.size() + " bills for customer");
            
        } catch (Exception e) {
            fail("Get bills by customer test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(8)
    @DisplayName("Test Search Bills")
    void testSearchBills() {
        try {
            // Create a test bill first
            billService.createBill(testBill, testBillItems);
            
            // Search by bill number
            List<Bill> searchResults = billService.searchBills("BILL");
            assertNotNull(searchResults, "Search results should not be null");
            assertTrue(searchResults.size() > 0, "Should find at least one bill");
            
            // Test empty search term
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> billService.searchBills(""),
                "Should throw exception for empty search term"
            );
            assertEquals("Search term is required", exception.getMessage());
            
            System.out.println("✓ Search bills test passed");
            
        } catch (Exception e) {
            fail("Search bills test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(9)
    @DisplayName("Test Update Payment Status")
    void testUpdatePaymentStatus() {
        try {
            // Create a test bill first
            int billId = billService.createBill(testBill, testBillItems);
            
            // Update payment status
            assertDoesNotThrow(() -> billService.updateBillPaymentStatus(billId, "PAID"));
            
            // Verify update
            Bill updatedBill = billService.getBillById(billId);
            assertEquals("PAID", updatedBill.getPaymentStatus());
            
            // Test invalid bill ID
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> billService.updateBillPaymentStatus(-1, "PAID"),
                "Should throw exception for invalid bill ID"
            );
            assertEquals("Invalid bill ID", exception.getMessage());
            
            System.out.println("✓ Payment status update test passed");
            
        } catch (Exception e) {
            fail("Update payment status test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(10)
    @DisplayName("Test Delete Bill")
    void testDeleteBill() {
        try {
            // Create a test bill first
            int billId = billService.createBill(testBill, testBillItems);
            
            // Get original stock
            Book bookBeforeDelete = bookDAO.getBookById(testBook.getBookId());
            int stockBeforeDelete = bookBeforeDelete.getStockQuantity();
            
            // Delete bill
            assertDoesNotThrow(() -> billService.deleteBill(billId));
            
            // Verify bill is deleted
            Bill deletedBill = billService.getBillById(billId);
            assertNull(deletedBill, "Bill should be deleted");
            
            // Verify stock is restored
            Book bookAfterDelete = bookDAO.getBookById(testBook.getBookId());
            assertEquals(stockBeforeDelete + 2, bookAfterDelete.getStockQuantity(), 
                "Stock should be restored");
            
            System.out.println("✓ Bill deletion test passed");
            
        } catch (Exception e) {
            fail("Delete bill test failed: " + e.getMessage());
        }
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
            String deleteBooksSQL = "DELETE FROM items WHERE item_code LIKE ? OR name = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteBooksSQL)) {
                stmt.setString(1, "BOO%");
                stmt.setString(2, "Test Book for Bill");
                stmt.executeUpdate();
            }
            
            // Delete customers
            String deleteCustomersSQL = "DELETE FROM customers WHERE account_number LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteCustomersSQL)) {
                stmt.setString(1, "CUST%");
                stmt.executeUpdate();
            }
            
            // Delete users
            String deleteUsersSQL = "DELETE FROM users WHERE username LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteUsersSQL)) {
                stmt.setString(1, "cash%");
                stmt.executeUpdate();
            }
            
        } catch (SQLException e) {
            System.err.println("Cleanup failed: " + e.getMessage());
        }
    }
}