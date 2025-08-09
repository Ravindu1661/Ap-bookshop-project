// BillItemDAO.java - Enhanced with Base64 Image Support
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.BillItem;
import com.redupahana.util.DBConnectionFactory;

public class BillItemDAO {
    
    public void addBillItem(BillItem billItem) throws SQLException {
        String query = "INSERT INTO bill_items (bill_id, item_id, quantity, unit_price, total_price) " +
                      "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            statement.setInt(1, billItem.getBillId());
            statement.setInt(2, billItem.getBookId());  // Changed from getItemId to getBookId
            statement.setInt(3, billItem.getQuantity());
            statement.setDouble(4, billItem.getUnitPrice());
            statement.setDouble(5, billItem.getTotalPrice());
            
            statement.executeUpdate();
            
            // Get generated key
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    billItem.setBillItemId(generatedKeys.getInt(1));
                }
            }
        }
    }
    
    public List<BillItem> getBillItemsByBillId(int billId) throws SQLException {
        List<BillItem> billItems = new ArrayList<>();
        // CHANGED: Updated query to get Base64 image data
        String query = "SELECT bi.*, i.name as book_title, i.item_code as book_code, " +
                      "i.author, i.isbn, i.publisher, i.language, i.pages, i.publication_year, " +
                      "i.description, i.image_base64, i.book_category " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE bi.bill_id = ? AND i.category = 'Books' " +
                      "ORDER BY bi.bill_item_id";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    billItems.add(mapResultSetToBillItem(resultSet));
                }
            }
        }
        return billItems;
    }
    
    public BillItem getBillItemById(int billItemId) throws SQLException {
        // CHANGED: Updated query to get Base64 image data
        String query = "SELECT bi.*, i.name as book_title, i.item_code as book_code, " +
                      "i.author, i.isbn, i.publisher, i.language, i.pages, i.publication_year, " +
                      "i.description, i.image_base64, i.book_category " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE bi.bill_item_id = ? AND i.category = 'Books'";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billItemId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBillItem(resultSet);
                }
            }
        }
        return null;
    }
    
    public void updateBillItem(BillItem billItem) throws SQLException {
        String query = "UPDATE bill_items SET quantity = ?, unit_price = ?, total_price = ? " +
                      "WHERE bill_item_id = ?";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billItem.getQuantity());
            statement.setDouble(2, billItem.getUnitPrice());
            statement.setDouble(3, billItem.getTotalPrice());
            statement.setInt(4, billItem.getBillItemId());
            
            statement.executeUpdate();
        }
    }
    
    public void deleteBillItem(int billItemId) throws SQLException {
        String query = "DELETE FROM bill_items WHERE bill_item_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billItemId);
            statement.executeUpdate();
        }
    }
    
    public void deleteBillItemsByBillId(int billId) throws SQLException {
        String query = "DELETE FROM bill_items WHERE bill_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billId);
            statement.executeUpdate();
        }
    }
    
    public List<BillItem> getBillItemsByBookId(int bookId) throws SQLException {
        List<BillItem> billItems = new ArrayList<>();
        // CHANGED: Updated query to get Base64 image data
        String query = "SELECT bi.*, i.name as book_title, i.item_code as book_code, " +
                      "i.author, i.isbn, i.publisher, i.language, i.pages, i.publication_year, " +
                      "i.description, i.image_base64, i.book_category, " +
                      "b.bill_number, b.bill_date " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "LEFT JOIN bills b ON bi.bill_id = b.bill_id " +
                      "WHERE bi.item_id = ? AND i.category = 'Books' " +
                      "ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, bookId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    billItems.add(mapResultSetToBillItem(resultSet));
                }
            }
        }
        return billItems;
    }
    
    /**
     * Get bill items with sales statistics for a specific book
     */
    public List<BillItem> getBillItemsWithStats(int bookId) throws SQLException {
        List<BillItem> billItems = new ArrayList<>();
        // CHANGED: Updated query to get Base64 image data
        String query = "SELECT bi.*, i.name as book_title, i.item_code as book_code, " +
                      "i.author, i.isbn, i.publisher, i.language, i.pages, i.publication_year, " +
                      "i.description, i.image_base64, i.book_category, " +
                      "b.bill_number, b.bill_date, b.payment_status, c.name as customer_name " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "LEFT JOIN bills b ON bi.bill_id = b.bill_id " +
                      "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                      "WHERE bi.item_id = ? AND i.category = 'Books' " +
                      "ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, bookId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    billItems.add(mapResultSetToBillItem(resultSet));
                }
            }
        }
        return billItems;
    }
    
    /**
     * CHANGED: Enhanced mapping method with Base64 image support
     */
    private BillItem mapResultSetToBillItem(ResultSet resultSet) throws SQLException {
        BillItem billItem = new BillItem();
        billItem.setBillItemId(resultSet.getInt("bill_item_id"));
        billItem.setBillId(resultSet.getInt("bill_id"));
        billItem.setBookId(resultSet.getInt("item_id"));  // Map item_id to bookId
        billItem.setQuantity(resultSet.getInt("quantity"));
        billItem.setUnitPrice(resultSet.getDouble("unit_price"));
        billItem.setTotalPrice(resultSet.getDouble("total_price"));
        
        // Set enhanced book info if available including new fields
        try {
            billItem.setBookTitle(resultSet.getString("book_title"));
            billItem.setBookCode(resultSet.getString("book_code"));
            billItem.setAuthor(resultSet.getString("author"));
            billItem.setIsbn(resultSet.getString("isbn"));
            billItem.setPublisher(resultSet.getString("publisher"));
            billItem.setLanguage(resultSet.getString("language"));
            
            // Handle nullable integer fields
            int pages = resultSet.getInt("pages");
            if (!resultSet.wasNull()) {
                billItem.setPages(pages);
            }
            
            int publicationYear = resultSet.getInt("publication_year");
            if (!resultSet.wasNull()) {
                billItem.setPublicationYear(publicationYear);
            }
            
            // CHANGED: Set Base64 image and book category
            billItem.setImageBase64(resultSet.getString("image_base64"));
            billItem.setBookCategory(resultSet.getString("book_category"));
            
        } catch (SQLException e) {
            // Columns may not be available in all queries - continue without these details
            System.err.println("Some book details not available: " + e.getMessage());
        }
        
        return billItem;
    }
    
    /**
     * Get sales summary by category
     */
    public List<Object[]> getSalesByCategory() throws SQLException {
        List<Object[]> categoryStats = new ArrayList<>();
        String query = "SELECT i.book_category, " +
                      "COUNT(DISTINCT bi.item_id) as unique_books, " +
                      "SUM(bi.quantity) as total_quantity, " +
                      "SUM(bi.total_price) as total_revenue " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE i.category = 'Books' AND i.is_active = true " +
                      "AND i.book_category IS NOT NULL AND i.book_category != '' " +
                      "GROUP BY i.book_category " +
                      "ORDER BY total_revenue DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                Object[] stats = new Object[4];
                stats[0] = resultSet.getString("book_category");
                stats[1] = resultSet.getInt("unique_books");
                stats[2] = resultSet.getInt("total_quantity");
                stats[3] = resultSet.getDouble("total_revenue");
                categoryStats.add(stats);
            }
        }
        return categoryStats;
    }
}