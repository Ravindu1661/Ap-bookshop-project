// BillService.java - Updated with Base64 Image Support
package com.redupahana.service;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.BillDAO;
import com.redupahana.dao.BillItemDAO;
import com.redupahana.dao.BookDAO;
import com.redupahana.model.Bill;
import com.redupahana.model.BillItem;
import com.redupahana.model.Book;
import com.redupahana.service.BookService;
import com.redupahana.util.BillNumberGenerator;
import com.redupahana.util.DBConnectionFactory;
import com.redupahana.util.ValidationUtil;

public class BillService {
    
    private static BillService instance;
    private BillDAO billDAO;
    private BillItemDAO billItemDAO;
    private BookDAO bookDAO; // Direct DAO access for transaction control
    
    private BillService() {
        this.billDAO = new BillDAO();
        this.billItemDAO = new BillItemDAO();
        this.bookDAO = new BookDAO();
    }
    
    public static BillService getInstance() {
        if (instance == null) {
            synchronized (BillService.class) {
                if (instance == null) {
                    instance = new BillService();
                }
            }
        }
        return instance;
    }
    
    public int createBill(Bill bill, List<BillItem> billItems) throws SQLException {
        validateBillForCreation(bill, billItems);
        
        Connection connection = null;
        boolean originalAutoCommit = true;
        
        try {
            // Get connection and start transaction
            connection = DBConnectionFactory.getConnection();
            originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            
            // Generate bill number if not provided
            if (bill.getBillNumber() == null || bill.getBillNumber().isEmpty()) {
                // Simple timestamp-based generation to avoid database conflicts
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
                String timestamp = sdf.format(new java.util.Date());
                bill.setBillNumber("BILL" + timestamp);
            }

            // Pre-validate all books and check stock
            double subTotal = 0;
            for (BillItem billItem : billItems) {
                Book book = getBookByIdWithConnection(connection, billItem.getBookId());
                if (book == null) {
                    throw new IllegalArgumentException("Book with ID " + billItem.getBookId() + " not found");
                }
                
                // Check stock availability
                if (book.getStockQuantity() < billItem.getQuantity()) {
                    throw new IllegalArgumentException("Insufficient stock for book: " + book.getTitle() + 
                        ". Available: " + book.getStockQuantity() + ", Required: " + billItem.getQuantity());
                }
                
                // Set unit price from book if not set
                if (billItem.getUnitPrice() <= 0) {
                    billItem.setUnitPrice(book.getPrice());
                }
                
                // Calculate total price
                billItem.calculateTotalPrice();
                subTotal += billItem.getTotalPrice();
                
                // CHANGED: Set comprehensive book details in bill item including Base64 image
                billItem.setBookTitle(book.getTitle());
                billItem.setBookCode(book.getBookCode());
                billItem.setAuthor(book.getAuthor());
                billItem.setIsbn(book.getIsbn());
                billItem.setPublisher(book.getPublisher());
                billItem.setImageBase64(book.getImageBase64());  // CHANGED: Set Base64 image
                billItem.setBookCategory(book.getBookCategory());
                billItem.setLanguage(book.getLanguage());
                billItem.setPages(book.getPages());
                billItem.setPublicationYear(book.getPublicationYear());
            }
            
            // Set bill totals
            bill.setSubTotal(subTotal);
            
            // Calculate tax (if applicable)
            double tax = 0; // You can implement tax calculation logic here
            bill.setTax(tax);
            
            // Calculate total amount
            double totalAmount = subTotal + tax - bill.getDiscount();
            bill.setTotalAmount(totalAmount);
            
            // Add bill to database using the same connection
            int billId = addBillWithConnection(connection, bill);
            bill.setBillId(billId);
            
            // Add bill items and update stock using the same connection
            for (BillItem billItem : billItems) {
                billItem.setBillId(billId);
                addBillItemWithConnection(connection, billItem);
                
                // Update book stock using the same connection
                updateBookStockWithConnection(connection, billItem.getItemId(), billItem.getQuantity());
            }
            
            // Commit transaction
            connection.commit();
            return billId;
            
        } catch (Exception e) {
            // Rollback transaction on error
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("Error during rollback: " + rollbackEx.getMessage());
                }
            }
            throw new SQLException("Error creating bill: " + e.getMessage(), e);
        } finally {
            // Restore original auto-commit and close connection
            if (connection != null) {
                try {
                    connection.setAutoCommit(originalAutoCommit);
                    connection.close();
                } catch (SQLException closeEx) {
                    System.err.println("Error closing connection: " + closeEx.getMessage());
                }
            }
        }
    }
    
    // Helper method to get book using specific connection with all fields including Base64 image
    private Book getBookByIdWithConnection(Connection connection, int bookId) throws SQLException {
        String query = "SELECT * FROM items WHERE item_id = ? AND category = 'Books' AND is_active = true";
        try (java.sql.PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, bookId);
            try (java.sql.ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBook(resultSet);
                }
            }
        }
        return null;
    }
    
    // Helper method to add bill using specific connection
    private int addBillWithConnection(Connection connection, Bill bill) throws SQLException {
        String query = "INSERT INTO bills (bill_number, customer_id, cashier_id, sub_total, discount, " +
                      "tax, total_amount, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (java.sql.PreparedStatement statement = connection.prepareStatement(query, 
                java.sql.Statement.RETURN_GENERATED_KEYS)) {
            
            statement.setString(1, bill.getBillNumber());
            statement.setInt(2, bill.getCustomerId());
            statement.setInt(3, bill.getCashierId());
            statement.setDouble(4, bill.getSubTotal());
            statement.setDouble(5, bill.getDiscount());
            statement.setDouble(6, bill.getTax());
            statement.setDouble(7, bill.getTotalAmount());
            statement.setString(8, bill.getPaymentStatus());
            
            statement.executeUpdate();
            
            try (java.sql.ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        }
        return 0;
    }
    
    // Helper method to add bill item using specific connection
    private void addBillItemWithConnection(Connection connection, BillItem billItem) throws SQLException {
        String query = "INSERT INTO bill_items (bill_id, item_id, quantity, unit_price, total_price) " +
                      "VALUES (?, ?, ?, ?, ?)";
        
        try (java.sql.PreparedStatement statement = connection.prepareStatement(query, 
                java.sql.Statement.RETURN_GENERATED_KEYS)) {
            
            statement.setInt(1, billItem.getBillId());
            statement.setInt(2, billItem.getBookId());
            statement.setInt(3, billItem.getQuantity());
            statement.setDouble(4, billItem.getUnitPrice());
            statement.setDouble(5, billItem.getTotalPrice());
            
            statement.executeUpdate();
            
            try (java.sql.ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    billItem.setBillItemId(generatedKeys.getInt(1));
                }
            }
        }
    }
    
    // Helper method to update book stock using specific connection
    private void updateBookStockWithConnection(Connection connection, int bookId, int quantity) throws SQLException {
        String query = "UPDATE items SET stock_quantity = stock_quantity - ? WHERE item_id = ? AND category = 'Books'";
        try (java.sql.PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, quantity);
            statement.setInt(2, bookId);
            int rowsAffected = statement.executeUpdate();
            
            if (rowsAffected == 0) {
                throw new SQLException("Failed to update stock for book ID: " + bookId);
            }
        }
    }
    
    // CHANGED: Helper method to map ResultSet to Book with Base64 image support
    private Book mapResultSetToBook(java.sql.ResultSet resultSet) throws SQLException {
        Book book = new Book();
        book.setBookId(resultSet.getInt("item_id"));
        book.setBookCode(resultSet.getString("item_code"));
        book.setTitle(resultSet.getString("name"));
        book.setDescription(resultSet.getString("description"));
        book.setPrice(resultSet.getDouble("price"));
        book.setStockQuantity(resultSet.getInt("stock_quantity"));
        book.setAuthor(resultSet.getString("author"));
        book.setIsbn(resultSet.getString("isbn"));
        book.setPublisher(resultSet.getString("publisher"));
        
        // Handle nullable integer fields
        int publicationYear = resultSet.getInt("publication_year");
        if (!resultSet.wasNull()) {
            book.setPublicationYear(publicationYear);
        }
        
        int pages = resultSet.getInt("pages");
        if (!resultSet.wasNull()) {
            book.setPages(pages);
        }
        
        book.setLanguage(resultSet.getString("language"));
        book.setActive(resultSet.getBoolean("is_active"));
        
        // CHANGED: Handle new fields for Base64 image and category
        book.setImageBase64(resultSet.getString("image_base64"));
        book.setBookCategory(resultSet.getString("book_category"));
        
        // Handle timestamps
        java.sql.Timestamp createdTimestamp = resultSet.getTimestamp("created_date");
        if (createdTimestamp != null) {
            book.setCreatedDate(createdTimestamp.toString());
        }
        
        java.sql.Timestamp updatedTimestamp = resultSet.getTimestamp("updated_date");
        if (updatedTimestamp != null) {
            book.setUpdatedDate(updatedTimestamp.toString());
        }
        
        return book;
    }
    
    // Existing methods with enhanced book loading for bill items
    public List<Bill> getAllBills() throws SQLException {
        List<Bill> bills = billDAO.getAllBills();
        
        // Load bill items for each bill with enhanced book details
        for (Bill bill : bills) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bills;
    }
    
    public Bill getBillById(int billId) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        
        Bill bill = billDAO.getBillById(billId);
        if (bill != null) {
            // Load bill items with enhanced book details
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bill;
    }
    
    public Bill getBillByNumber(String billNumber) throws SQLException {
        if (!ValidationUtil.isNotEmpty(billNumber)) {
            throw new IllegalArgumentException("Bill number is required");
        }
        
        Bill bill = billDAO.getBillByNumber(billNumber);
        if (bill != null) {
            // Load bill items with enhanced book details
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bill;
    }
    
    public List<Bill> getBillsByCustomer(int customerId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        
        List<Bill> bills = billDAO.getBillsByCustomer(customerId);
        
        // Load bill items for each bill with enhanced book details
        for (Bill bill : bills) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bills;
    }
    
    public List<Bill> getBillsByCashier(int cashierId) throws SQLException {
        if (cashierId <= 0) {
            throw new IllegalArgumentException("Invalid cashier ID");
        }
        
        List<Bill> bills = billDAO.getBillsByCashier(cashierId);
        
        // Load bill items for each bill with enhanced book details
        for (Bill bill : bills) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bills;
    }
    
    public List<Bill> searchBills(String searchTerm) throws SQLException {
        if (!ValidationUtil.isNotEmpty(searchTerm)) {
            throw new IllegalArgumentException("Search term is required");
        }
        
        List<Bill> bills = billDAO.searchBills(searchTerm);
        
        // Load bill items for each bill with enhanced book details
        for (Bill bill : bills) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return bills;
    }
    
    public List<Bill> getPendingPaymentBills() throws SQLException {
        List<Bill> allBills = billDAO.getAllBills();
        List<Bill> pendingBills = allBills.stream()
                .filter(bill -> "PENDING".equalsIgnoreCase(bill.getPaymentStatus()))
                .collect(java.util.stream.Collectors.toList());
        
        // Load bill items for each pending bill with enhanced book details
        for (Bill bill : pendingBills) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            
            // Load complete book details for each bill item
            for (BillItem billItem : billItems) {
                try {
                    Book book = bookDAO.getBookById(billItem.getBookId());
                    if (book != null) {
                        // CHANGED: Set all book details including Base64 image
                        billItem.setBookTitle(book.getTitle());
                        billItem.setBookCode(book.getBookCode());
                        billItem.setAuthor(book.getAuthor());
                        billItem.setIsbn(book.getIsbn());
                        billItem.setPublisher(book.getPublisher());
                        billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                        billItem.setBookCategory(book.getBookCategory());
                        billItem.setLanguage(book.getLanguage());
                        billItem.setPages(book.getPages());
                        billItem.setPublicationYear(book.getPublicationYear());
                    }
                } catch (SQLException e) {
                    System.err.println("Error loading book details for bill item: " + e.getMessage());
                }
            }
            
            bill.setBillItems(billItems);
        }
        
        return pendingBills;
    }
    
    public void updateBillPaymentStatus(int billId, String paymentStatus) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        if (!ValidationUtil.isNotEmpty(paymentStatus)) {
            throw new IllegalArgumentException("Payment status is required");
        }
        
        billDAO.updateBillPaymentStatus(billId, paymentStatus);
    }
    
    public void deleteBill(int billId) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        
        Connection connection = null;
        boolean originalAutoCommit = true;
        
        try {
            connection = DBConnectionFactory.getConnection();
            originalAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            
            // Get bill items to restore stock
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
            
            // Restore stock for each book
            for (BillItem billItem : billItems) {
                String restoreStockQuery = "UPDATE items SET stock_quantity = stock_quantity + ? WHERE item_id = ? AND category = 'Books'";
                try (java.sql.PreparedStatement statement = connection.prepareStatement(restoreStockQuery)) {
                    statement.setInt(1, billItem.getQuantity());
                    statement.setInt(2, billItem.getBookId());
                    statement.executeUpdate();
                }
            }
            
            // Delete bill (this will cascade delete bill items)
            String deleteBillQuery = "DELETE FROM bills WHERE bill_id = ?";
            try (java.sql.PreparedStatement statement = connection.prepareStatement(deleteBillQuery)) {
                statement.setInt(1, billId);
                statement.executeUpdate();
            }
            
            connection.commit();
            
        } catch (Exception e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("Error during rollback: " + rollbackEx.getMessage());
                }
            }
            throw new SQLException("Error deleting bill: " + e.getMessage(), e);
        } finally {
            if (connection != null) {
                try {
                    connection.setAutoCommit(originalAutoCommit);
                    connection.close();
                } catch (SQLException closeEx) {
                    System.err.println("Error closing connection: " + closeEx.getMessage());
                }
            }
        }
    }
    
    public boolean canDeleteBill(int billId) throws SQLException {
        // You can implement business logic here to determine if a bill can be deleted
        // For example, only allow deletion of bills created within last 24 hours, or only PENDING bills
        Bill bill = getBillById(billId);
        return bill != null; // For now, allow deletion of any existing bill
    }
    
    private void validateBillForCreation(Bill bill, List<BillItem> billItems) {
        if (bill == null) {
            throw new IllegalArgumentException("Bill is required");
        }
        
        if (bill.getCustomerId() <= 0) {
            throw new IllegalArgumentException("Valid customer is required");
        }
        
        if (bill.getCashierId() <= 0) {
            throw new IllegalArgumentException("Valid cashier is required");
        }
        
        if (billItems == null || billItems.isEmpty()) {
            throw new IllegalArgumentException("At least one book item is required");
        }
        
        if (bill.getDiscount() < 0) {
            throw new IllegalArgumentException("Discount cannot be negative");
        }
        
        // Validate each bill item
        for (BillItem billItem : billItems) {
            if (billItem.getBookId() <= 0) {
                throw new IllegalArgumentException("Valid book selection is required");
            }
            
            if (billItem.getQuantity() <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than 0");
            }
            
            if (billItem.getUnitPrice() < 0) {
                throw new IllegalArgumentException("Unit price cannot be negative");
            }
        }
    }
}