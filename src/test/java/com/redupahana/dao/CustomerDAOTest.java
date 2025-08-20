// CustomerDAOTest.java - Real Database Integration Test
// File: src/test/java/com/redupahana/dao/CustomerDAOTest.java
package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.*;
import com.redupahana.model.Customer;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class CustomerDAOTest {

    private CustomerDAO customerDAO;
    private Customer testCustomer;
    private String testAccountNumber;
    
    // Test data constants
    private static final String TEST_EMAIL = "daotest@customer.com";
    private static final String TEST_NAME = "DAO Test Customer";
    private static final String TEST_PHONE = "0771234567";

    @BeforeAll
    void setUpAll() {
        customerDAO = new CustomerDAO();
        cleanupTestData();
    }

    @BeforeEach
    void setUp() {
        testAccountNumber = "DAOCUST" + System.currentTimeMillis();
        
        testCustomer = new Customer();
        testCustomer.setAccountNumber(testAccountNumber);
        testCustomer.setName(TEST_NAME);
        testCustomer.setAddress("123 DAO Test Street, Test City");
        testCustomer.setPhone(TEST_PHONE);
        testCustomer.setEmail(TEST_EMAIL);
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
    @DisplayName("Test Add Customer - Success")
    void testAddCustomer_Success() {
        try {
            assertDoesNotThrow(() -> customerDAO.addCustomer(testCustomer));
            
            // Verify customer exists in database
            Customer retrievedCustomer = customerDAO.getCustomerByAccountNumber(testAccountNumber);
            assertNotNull(retrievedCustomer, "Customer should exist in database");
            assertEquals(TEST_NAME, retrievedCustomer.getName());
            assertEquals(TEST_EMAIL, retrievedCustomer.getEmail());
            assertEquals(TEST_PHONE, retrievedCustomer.getPhone());
            
            System.out.println("✓ Customer added successfully: " + testAccountNumber);
            
        } catch (SQLException e) {
            fail("Add customer test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Add Customer - Duplicate Account Number")
    void testAddCustomer_DuplicateAccount() {
        try {
            // Add first customer
            customerDAO.addCustomer(testCustomer);
            
            // Try to add duplicate
            Customer duplicateCustomer = new Customer();
            duplicateCustomer.setAccountNumber(testAccountNumber); // Same account number
            duplicateCustomer.setName("Different Customer");
            duplicateCustomer.setAddress("Different Address");
            duplicateCustomer.setPhone("0779876543");
            duplicateCustomer.setEmail("different@email.com");
            
            SQLException exception = assertThrows(SQLException.class, 
                () -> customerDAO.addCustomer(duplicateCustomer));
            
            assertTrue(exception.getMessage().contains("Duplicate") || 
                      exception.getMessage().contains("unique") ||
                      exception.getMessage().contains("account_number"));
            
            System.out.println("✓ Duplicate account number validation passed");
            
        } catch (SQLException e) {
            fail("Duplicate account number test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Get All Customers")
    void testGetAllCustomers() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            List<Customer> customers = customerDAO.getAllCustomers();
            assertNotNull(customers, "Customers list should not be null");
            assertTrue(customers.size() > 0, "Should have at least one customer");
            
            // Find our test customer
            boolean foundTestCustomer = customers.stream()
                .anyMatch(customer -> TEST_NAME.equals(customer.getName()));
            assertTrue(foundTestCustomer, "Should find our test customer");
            
            // Verify newest first ordering
            if (customers.size() > 1) {
                // The first customer should be our newly added one (newest)
                Customer firstCustomer = customers.get(0);
                assertEquals(TEST_NAME, firstCustomer.getName(), 
                    "Newest customer should be first");
            }
            
            System.out.println("✓ Retrieved " + customers.size() + " customers from database (newest first)");
            
        } catch (SQLException e) {
            fail("Get all customers test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get Customer By ID - Found")
    void testGetCustomerById_Found() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            // Get customer by account number to get the ID
            Customer addedCustomer = customerDAO.getCustomerByAccountNumber(testAccountNumber);
            assertNotNull(addedCustomer, "Customer should exist");
            
            int customerId = addedCustomer.getCustomerId();
            
            Customer retrievedCustomer = customerDAO.getCustomerById(customerId);
            assertNotNull(retrievedCustomer, "Should find customer by valid ID");
            assertEquals(TEST_NAME, retrievedCustomer.getName());
            assertEquals(customerId, retrievedCustomer.getCustomerId());
            
            System.out.println("✓ Found customer by ID: " + customerId);
            
        } catch (SQLException e) {
            fail("Get customer by ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Get Customer By ID - Not Found")
    void testGetCustomerById_NotFound() {
        try {
            Customer retrievedCustomer = customerDAO.getCustomerById(999999);
            assertNull(retrievedCustomer, "Should return null for invalid ID");
            
            System.out.println("✓ Correctly returned null for invalid ID");
            
        } catch (SQLException e) {
            fail("Get customer by invalid ID test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(6)
    @DisplayName("Test Get Customer By Account Number")
    void testGetCustomerByAccountNumber() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            Customer retrievedCustomer = customerDAO.getCustomerByAccountNumber(testAccountNumber);
            assertNotNull(retrievedCustomer, "Should find customer by account number");
            assertEquals(TEST_NAME, retrievedCustomer.getName());
            assertEquals(testAccountNumber, retrievedCustomer.getAccountNumber());
            
            System.out.println("✓ Found customer by account number: " + testAccountNumber);
            
        } catch (SQLException e) {
            fail("Get customer by account number test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(7)
    @DisplayName("Test Update Customer - Success")
    void testUpdateCustomer_Success() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            // Get the customer to get the ID
            Customer addedCustomer = customerDAO.getCustomerByAccountNumber(testAccountNumber);
            assertNotNull(addedCustomer, "Customer should exist");
            
            // Update the customer
            addedCustomer.setName("Updated DAO Test Customer");
            addedCustomer.setEmail("updated@customer.com");
            addedCustomer.setPhone("0779876543");
            addedCustomer.setAddress("456 Updated Street, Updated City");
            
            assertDoesNotThrow(() -> customerDAO.updateCustomer(addedCustomer));
            
            // Verify update
            Customer updatedCustomer = customerDAO.getCustomerById(addedCustomer.getCustomerId());
            assertNotNull(updatedCustomer, "Updated customer should exist");
            assertEquals("Updated DAO Test Customer", updatedCustomer.getName());
            assertEquals("updated@customer.com", updatedCustomer.getEmail());
            assertEquals("0779876543", updatedCustomer.getPhone());
            
            System.out.println("✓ Customer updated successfully");
            
        } catch (SQLException e) {
            fail("Update customer test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(8)
    @DisplayName("Test Delete Customer")
    void testDeleteCustomer() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            // Get the customer to get the ID
            Customer addedCustomer = customerDAO.getCustomerByAccountNumber(testAccountNumber);
            assertNotNull(addedCustomer, "Customer should exist");
            
            int customerId = addedCustomer.getCustomerId();
            
            assertDoesNotThrow(() -> customerDAO.deleteCustomer(customerId));
            
            // Verify deletion (should return null for inactive customer)
            Customer deletedCustomer = customerDAO.getCustomerById(customerId);
            assertNull(deletedCustomer, "Deleted customer should not be found");
            
            System.out.println("✓ Customer deleted successfully");
            
        } catch (SQLException e) {
            fail("Delete customer test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(9)
    @DisplayName("Test Search Customers")
    void testSearchCustomers() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            // Search by name
            List<Customer> searchResults = customerDAO.searchCustomers("DAO Test");
            assertNotNull(searchResults, "Search results should not be null");
            assertTrue(searchResults.size() > 0, "Should find at least one customer");
            
            // Verify our customer is in results
            boolean foundTestCustomer = searchResults.stream()
                .anyMatch(customer -> TEST_NAME.equals(customer.getName()));
            assertTrue(foundTestCustomer, "Should find our test customer in search results");
            
            // Search by account number
            searchResults = customerDAO.searchCustomers(testAccountNumber.substring(0, 7));
            assertTrue(searchResults.size() > 0, "Should find customers by account number");
            
            // Search by phone
            searchResults = customerDAO.searchCustomers("077");
            assertTrue(searchResults.size() > 0, "Should find customers by phone");
            
            System.out.println("✓ Search found customers successfully");
            
        } catch (SQLException e) {
            fail("Search customers test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(10)
    @DisplayName("Test Get All Customers Alphabetical")
    void testGetAllCustomersAlphabetical() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            List<Customer> customers = customerDAO.getAllCustomersAlphabetical();
            assertNotNull(customers, "Customers list should not be null");
            assertTrue(customers.size() > 0, "Should have at least one customer");
            
            // Verify alphabetical ordering
            if (customers.size() > 1) {
                for (int i = 1; i < customers.size(); i++) {
                    String currentName = customers.get(i).getName();
                    String previousName = customers.get(i - 1).getName();
                    assertTrue(currentName.compareToIgnoreCase(previousName) >= 0, 
                        "Customers should be in alphabetical order");
                }
            }
            
            System.out.println("✓ Retrieved customers in alphabetical order");
            
        } catch (SQLException e) {
            fail("Get customers alphabetical test failed: " + e.getMessage());
        }
    }

    @Test
    @Order(11)
    @DisplayName("Test Get Recent Customers")
    void testGetRecentCustomers() {
        try {
            // Add test customer first
            customerDAO.addCustomer(testCustomer);
            
            List<Customer> recentCustomers = customerDAO.getRecentCustomers(5);
            assertNotNull(recentCustomers, "Recent customers list should not be null");
            assertTrue(recentCustomers.size() > 0, "Should have at least one recent customer");
            assertTrue(recentCustomers.size() <= 5, "Should not exceed limit of 5");
            
            // Find our test customer (should be first as most recent)
            Customer firstCustomer = recentCustomers.get(0);
            assertEquals(TEST_NAME, firstCustomer.getName(), 
                "Most recent customer should be our test customer");
            
            System.out.println("✓ Retrieved " + recentCustomers.size() + " recent customers");
            
        } catch (SQLException e) {
            fail("Get recent customers test failed: " + e.getMessage());
        }
    }

    private void cleanupTestData() {
        try (Connection connection = DBConnectionFactory.getConnection()) {
            String deleteSQL = "DELETE FROM customers WHERE email = ? OR name = ? OR account_number LIKE ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteSQL)) {
                stmt.setString(1, TEST_EMAIL);
                stmt.setString(2, TEST_NAME);
                stmt.setString(3, "DAOCUST%");
                int deleted = stmt.executeUpdate();
                if (deleted > 0) {
                    System.out.println("Cleaned up " + deleted + " customer test record(s)");
                }
            }
        } catch (SQLException e) {
            System.err.println("Customer cleanup failed: " + e.getMessage());
        }
    }
}