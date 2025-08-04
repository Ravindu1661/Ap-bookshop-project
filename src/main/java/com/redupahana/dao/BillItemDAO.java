// BillItemDAO.java
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.BillItem;
import com.redupahana.util.DBConnectionFactory;

public class BillItemDAO {
    
    public void addBillItem(BillItem billItem) throws SQLException {
        String query = "INSERT INTO bill_items (bill_id, item_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, billItem.getBillId());
            statement.setInt(2, billItem.getItemId());
            statement.setInt(3, billItem.getQuantity());
            statement.setDouble(4, billItem.getUnitPrice());
            statement.setDouble(5, billItem.getTotalPrice());
            statement.executeUpdate();
        }
    }
    
    public List<BillItem> getBillItemsByBillId(int billId) throws SQLException {
        List<BillItem> billItems = new ArrayList<>();
        String query = "SELECT bi.*, i.name as item_name, i.item_code " +
                      "FROM bill_items bi " +
                      "LEFT JOIN items i ON bi.item_id = i.item_id " +
                      "WHERE bi.bill_id = ?";
        
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
    
    private BillItem mapResultSetToBillItem(ResultSet resultSet) throws SQLException {
        BillItem billItem = new BillItem();
        billItem.setBillItemId(resultSet.getInt("bill_item_id"));
        billItem.setBillId(resultSet.getInt("bill_id"));
        billItem.setItemId(resultSet.getInt("item_id"));
        billItem.setQuantity(resultSet.getInt("quantity"));
        billItem.setUnitPrice(resultSet.getDouble("unit_price"));
        billItem.setTotalPrice(resultSet.getDouble("total_price"));
        return billItem;
    }
}