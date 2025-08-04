package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.Bill;
import com.redupahana.util.DBConnectionFactory;

public class BillDAO {
    
    public int addBill(Bill bill) throws SQLException {
        String query = "INSERT INTO bills (bill_number, customer_id, cashier_id, sub_total, discount, " +
                      "tax, total_amount, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            statement.setString(1, bill.getBillNumber());
            statement.setInt(2, bill.getCustomerId());
            statement.setInt(3, bill.getCashierId());
            statement.setDouble(4, bill.getSubTotal());
            statement.setDouble(5, bill.getDiscount());
            statement.setDouble(6, bill.getTax());
            statement.setDouble(7, bill.getTotalAmount());
            statement.setString(8, bill.getPaymentStatus());
            
            statement.executeUpdate();
            
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        }
        return 0;
    }
    
    public List<Bill> getAllBills() throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String query = "SELECT b.*, c.name as customer_name, u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                bills.add(mapResultSetToBill(resultSet));
            }
        }
        return bills;
    }
    
    public Bill getBillById(int billId) throws SQLException {
        String query = "SELECT b.*, c.name as customer_name, c.phone, c.email, " +
                      "u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "WHERE b.bill_id = ?";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBill(resultSet);
                }
            }
        }
        return null;
    }
    
    public Bill getBillByNumber(String billNumber) throws SQLException {
        String query = "SELECT b.*, c.name as customer_name, c.phone, c.email, " +
                      "u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "WHERE b.bill_number = ?";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, billNumber);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBill(resultSet);
                }
            }
        }
        return null;
    }
    
    public List<Bill> getBillsByCustomer(int customerId) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String query = "SELECT b.*, c.name as customer_name, u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "WHERE b.customer_id = ? ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, customerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    bills.add(mapResultSetToBill(resultSet));
                }
            }
        }
        return bills;
    }
    
    public List<Bill> getBillsByCashier(int cashierId) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String query = "SELECT b.*, c.name as customer_name, u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "WHERE b.cashier_id = ? ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, cashierId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    bills.add(mapResultSetToBill(resultSet));
                }
            }
        }
        return bills;
    }
    
    public List<Bill> searchBills(String searchTerm) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String query = "SELECT b.*, c.name as customer_name, u.full_name as cashier_name " +
                      "FROM bills b " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                      "WHERE (b.bill_number LIKE ? OR c.name LIKE ? OR u.full_name LIKE ?) " +
                      "ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            String searchPattern = "%" + searchTerm + "%";
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    bills.add(mapResultSetToBill(resultSet));
                }
            }
        }
        return bills;
    }
    
    public void updateBillPaymentStatus(int billId, String paymentStatus) throws SQLException {
        String query = "UPDATE bills SET payment_status = ? WHERE bill_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, paymentStatus);
            statement.setInt(2, billId);
            statement.executeUpdate();
        }
    }
    
    public void deleteBill(int billId) throws SQLException {
        // First delete bill items
        String deleteBillItemsQuery = "DELETE FROM bill_items WHERE bill_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(deleteBillItemsQuery)) {
            
            statement.setInt(1, billId);
            statement.executeUpdate();
        }
        
        // Then delete bill
        String deleteBillQuery = "DELETE FROM bills WHERE bill_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(deleteBillQuery)) {
            
            statement.setInt(1, billId);
            statement.executeUpdate();
        }
    }
    
    private Bill mapResultSetToBill(ResultSet resultSet) throws SQLException {
        Bill bill = new Bill();
        bill.setBillId(resultSet.getInt("bill_id"));
        bill.setBillNumber(resultSet.getString("bill_number"));
        bill.setCustomerId(resultSet.getInt("customer_id"));
        bill.setCashierId(resultSet.getInt("cashier_id"));
        bill.setBillDate(resultSet.getString("bill_date"));
        bill.setSubTotal(resultSet.getDouble("sub_total"));
        bill.setDiscount(resultSet.getDouble("discount"));
        bill.setTax(resultSet.getDouble("tax"));
        bill.setTotalAmount(resultSet.getDouble("total_amount"));
        bill.setPaymentStatus(resultSet.getString("payment_status"));
        
        // Set additional info if available
        try {
            bill.setCustomerName(resultSet.getString("customer_name"));
            bill.setCashierName(resultSet.getString("cashier_name"));
        } catch (SQLException e) {
            // Columns may not be available in all queries
        }
        
        return bill;
    }
}
