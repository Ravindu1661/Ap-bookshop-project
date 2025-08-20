package com.redupahana.dao;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.sql.*;
import java.util.List;
import org.junit.jupiter.api.*;
import org.mockito.*;
import com.redupahana.model.Bill;
import com.redupahana.util.DBConnectionFactory;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class BillDAOTest {

    @Mock
    private Connection mockConnection;
    
    @Mock
    private PreparedStatement mockStatement;
    
    @Mock
    private ResultSet mockResultSet;
    
    private BillDAO billDAO;
    private Bill testBill;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        billDAO = new BillDAO();
        
        testBill = new Bill();
        testBill.setBillNumber("BILL001");
        testBill.setCustomerId(1);
        testBill.setCashierId(1);
        testBill.setSubTotal(100.0);
        testBill.setDiscount(10.0);
        testBill.setTax(9.0);
        testBill.setTotalAmount(99.0);
        testBill.setPaymentStatus("PENDING");
    }

    @Test
    @Order(1)
    @DisplayName("Test Add Bill")
    void testAddBill() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS)))
                .thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);
            when(mockStatement.getGeneratedKeys()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            when(mockResultSet.getInt(1)).thenReturn(1);

            // Act
            int billId = billDAO.addBill(testBill);

            // Assert
            assertEquals(1, billId);
            verify(mockStatement).setString(1, "BILL001");
            verify(mockStatement).setInt(2, 1);
            verify(mockStatement).setDouble(7, 99.0);
        }
    }

    @Test
    @Order(2)
    @DisplayName("Test Get All Bills")
    void testGetAllBills() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            Statement mockCreateStatement = mock(Statement.class);
            when(mockConnection.createStatement()).thenReturn(mockCreateStatement);
            when(mockCreateStatement.executeQuery(anyString())).thenReturn(mockResultSet);
            
            when(mockResultSet.next()).thenReturn(true, false);
            setupMockResultSetForBill();

            // Act
            List<Bill> bills = billDAO.getAllBills();

            // Assert
            assertEquals(1, bills.size());
            assertEquals("BILL001", bills.get(0).getBillNumber());
        }
    }

    @Test
    @Order(3)
    @DisplayName("Test Get Bill By ID")
    void testGetBillById() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true);
            setupMockResultSetForBill();

            // Act
            Bill bill = billDAO.getBillById(1);

            // Assert
            assertNotNull(bill);
            assertEquals("BILL001", bill.getBillNumber());
            assertEquals(99.0, bill.getTotalAmount());
        }
    }

    @Test
    @Order(4)
    @DisplayName("Test Get Bills By Customer")
    void testGetBillsByCustomer() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeQuery()).thenReturn(mockResultSet);
            when(mockResultSet.next()).thenReturn(true, false);
            setupMockResultSetForBill();

            // Act
            List<Bill> bills = billDAO.getBillsByCustomer(1);

            // Assert
            assertEquals(1, bills.size());
            verify(mockStatement).setInt(1, 1);
        }
    }

    @Test
    @Order(5)
    @DisplayName("Test Update Bill Payment Status")
    void testUpdateBillPaymentStatus() throws SQLException {
        // Arrange
        try (MockedStatic<DBConnectionFactory> mockedFactory = mockStatic(DBConnectionFactory.class)) {
            mockedFactory.when(DBConnectionFactory::getConnection).thenReturn(mockConnection);
            
            when(mockConnection.prepareStatement(anyString())).thenReturn(mockStatement);
            when(mockStatement.executeUpdate()).thenReturn(1);

            // Act & Assert
            assertDoesNotThrow(() -> billDAO.updateBillPaymentStatus(1, "PAID"));
            
            verify(mockStatement).setString(1, "PAID");
            verify(mockStatement).setInt(2, 1);
        }
    }

    private void setupMockResultSetForBill() throws SQLException {
        when(mockResultSet.getInt("bill_id")).thenReturn(1);
        when(mockResultSet.getString("bill_number")).thenReturn("BILL001");
        when(mockResultSet.getInt("customer_id")).thenReturn(1);
        when(mockResultSet.getInt("cashier_id")).thenReturn(1);
        when(mockResultSet.getString("bill_date")).thenReturn("2024-01-01 10:00:00");
        when(mockResultSet.getDouble("sub_total")).thenReturn(100.0);
        when(mockResultSet.getDouble("discount")).thenReturn(10.0);
        when(mockResultSet.getDouble("tax")).thenReturn(9.0);
        when(mockResultSet.getDouble("total_amount")).thenReturn(99.0);
        when(mockResultSet.getString("payment_status")).thenReturn("PENDING");
        when(mockResultSet.getString("customer_name")).thenReturn("Test Customer");
        when(mockResultSet.getString("cashier_name")).thenReturn("Test Cashier");
    }
}
