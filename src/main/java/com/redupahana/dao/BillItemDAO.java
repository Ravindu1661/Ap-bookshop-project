// BillItemDAO.java
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
            statement.setInt(2, billItem.getItemId());
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
        String query = "SELECT bi.*, i.name as item_name, i.item_code, i.category, " +
                      "i.description as item_description " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE bi.bill_id = ? ORDER BY bi.bill_item_id";
        
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
        String query = "SELECT bi.*, i.name as item_name, i.item_code, i.category, " +
                      "i.description as item_description " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE bi.bill_item_id = ?";
        
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
    
    public List<BillItem> getBillItemsByItemId(int itemId) throws SQLException {
        List<BillItem> billItems = new ArrayList<>();
        String query = "SELECT bi.*, i.name as item_name, i.item_code, i.category, " +
                      "i.description as item_description, " +
                      "b.bill_number, b.bill_date " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "LEFT JOIN bills b ON bi.bill_id = b.bill_id " +
                      "WHERE bi.item_id = ? ORDER BY b.bill_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, itemId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    billItems.add(mapResultSetToBillItem(resultSet));
                }
            }
        }
        return billItems;
    }
    
    private BillItem mapResultSetToBillItem(ResultSet resultSet) throws SQLException {
        BillItem billItem = new BillItem();
        billItem.setBillItemId(resultSet.getInt("bill_item_id"));
        billItem.setBillId(resultSet.getInt("bill_id"));
        billItem.setItemId(resultSet.getInt("item_id"));
        billItem.setQuantity(resultSet.getInt("quantity"));
        billItem.setUnitPrice(resultSet.getDouble("unit_price"));
        billItem.setTotalPrice(resultSet.getDouble("total_price"));
        
        // Set additional item info if available
        try {
            billItem.setItemName(resultSet.getString("item_name"));
            billItem.setItemCode(resultSet.getString("item_code"));
            billItem.setItemCategory(resultSet.getString("category"));
            billItem.setItemDescription(resultSet.getString("item_description"));
        } catch (SQLException e) {
            // Columns may not be available in all queries
        }
        
        return billItem;
    }
}