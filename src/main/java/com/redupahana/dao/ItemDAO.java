// ItemDAO.java
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.Item;
import com.redupahana.util.DBConnectionFactory;

public class ItemDAO {
    
    public void addItem(Item item) throws SQLException {
        String query = "INSERT INTO items (item_code, name, description, price, stock_quantity, category) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, item.getItemCode());
            statement.setString(2, item.getName());
            statement.setString(3, item.getDescription());
            statement.setDouble(4, item.getPrice());
            statement.setInt(5, item.getStockQuantity());
            statement.setString(6, item.getCategory());
            statement.executeUpdate();
        }
    }
    
    public List<Item> getAllItems() throws SQLException {
        List<Item> items = new ArrayList<>();
        String query = "SELECT * FROM items WHERE is_active = true ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                items.add(mapResultSetToItem(resultSet));
            }
        }
        return items;
    }
    
    public Item getItemById(int itemId) throws SQLException {
        String query = "SELECT * FROM items WHERE item_id = ? AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, itemId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToItem(resultSet);
                }
            }
        }
        return null;
    }
    
    public Item getItemByCode(String itemCode) throws SQLException {
        String query = "SELECT * FROM items WHERE item_code = ? AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, itemCode);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToItem(resultSet);
                }
            }
        }
        return null;
    }
    
    public void updateItem(Item item) throws SQLException {
        String query = "UPDATE items SET name = ?, description = ?, price = ?, stock_quantity = ?, category = ? WHERE item_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, item.getName());
            statement.setString(2, item.getDescription());
            statement.setDouble(3, item.getPrice());
            statement.setInt(4, item.getStockQuantity());
            statement.setString(5, item.getCategory());
            statement.setInt(6, item.getItemId());
            statement.executeUpdate();
        }
    }
    
    public void deleteItem(int itemId) throws SQLException {
        String query = "UPDATE items SET is_active = false WHERE item_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, itemId);
            statement.executeUpdate();
        }
    }
    
    public void updateStock(int itemId, int quantity) throws SQLException {
        String query = "UPDATE items SET stock_quantity = stock_quantity - ? WHERE item_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, quantity);
            statement.setInt(2, itemId);
            statement.executeUpdate();
        }
    }
    
    public List<Item> searchItems(String searchTerm) throws SQLException {
        List<Item> items = new ArrayList<>();
        String query = "SELECT * FROM items WHERE is_active = true AND " +
                      "(name LIKE ? OR item_code LIKE ? OR category LIKE ?) ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            String searchPattern = "%" + searchTerm + "%";
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    items.add(mapResultSetToItem(resultSet));
                }
            }
        }
        return items;
    }
    
    private Item mapResultSetToItem(ResultSet resultSet) throws SQLException {
        Item item = new Item();
        item.setItemId(resultSet.getInt("item_id"));
        item.setItemCode(resultSet.getString("item_code"));
        item.setName(resultSet.getString("name"));
        item.setDescription(resultSet.getString("description"));
        item.setPrice(resultSet.getDouble("price"));
        item.setStockQuantity(resultSet.getInt("stock_quantity"));
        item.setCategory(resultSet.getString("category"));
        item.setActive(resultSet.getBoolean("is_active"));
        item.setCreatedDate(resultSet.getString("created_date"));
        item.setUpdatedDate(resultSet.getString("updated_date"));
        return item;
    }
}