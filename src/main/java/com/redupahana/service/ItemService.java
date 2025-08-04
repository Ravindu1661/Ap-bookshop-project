// ItemService.java
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.ItemDAO;
import com.redupahana.model.Item;
import com.redupahana.util.BillNumberGenerator;
import com.redupahana.util.ValidationUtil;

public class ItemService {
    
    private static ItemService instance;
    private ItemDAO itemDAO;
    
    private ItemService() {
        this.itemDAO = new ItemDAO();
    }
    
    public static ItemService getInstance() {
        if (instance == null) {
            synchronized (ItemService.class) {
                if (instance == null) {
                    instance = new ItemService();
                }
            }
        }
        return instance;
    }
    
    public void addItem(Item item) throws SQLException {
        validateItem(item);
        // Generate item code if not provided
        if (item.getItemCode() == null || item.getItemCode().isEmpty()) {
            item.setItemCode(BillNumberGenerator.generateItemCode(item.getCategory()));
        }
        itemDAO.addItem(item);
    }
    
    public List<Item> getAllItems() throws SQLException {
        return itemDAO.getAllItems();
    }
    
    public Item getItemById(int itemId) throws SQLException {
        if (itemId <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        return itemDAO.getItemById(itemId);
    }
    
    public Item getItemByCode(String itemCode) throws SQLException {
        if (!ValidationUtil.isNotEmpty(itemCode)) {
            throw new IllegalArgumentException("Item code is required");
        }
        return itemDAO.getItemByCode(itemCode);
    }
    
    public void updateItem(Item item) throws SQLException {
        validateItemForUpdate(item);
        itemDAO.updateItem(item);
    }
    
    public void deleteItem(int itemId) throws SQLException {
        if (itemId <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        itemDAO.deleteItem(itemId);
    }
    
    public void updateStock(int itemId, int quantity) throws SQLException {
        if (itemId <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        if (!ValidationUtil.isValidQuantity(quantity)) {
            throw new IllegalArgumentException("Invalid quantity");
        }
        itemDAO.updateStock(itemId, quantity);
    }
    
    public List<Item> searchItems(String searchTerm) throws SQLException {
        if (!ValidationUtil.isNotEmpty(searchTerm)) {
            throw new IllegalArgumentException("Search term is required");
        }
        return itemDAO.searchItems(searchTerm);
    }
    
    private void validateItem(Item item) {
        if (!ValidationUtil.isNotEmpty(item.getName())) {
            throw new IllegalArgumentException("Item name is required");
        }
        if (!ValidationUtil.isValidPrice(item.getPrice())) {
            throw new IllegalArgumentException("Price must be greater than 0");
        }
        if (item.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }
        if (!ValidationUtil.isNotEmpty(item.getCategory())) {
            throw new IllegalArgumentException("Category is required");
        }
    }
    
    private void validateItemForUpdate(Item item) {
        if (item.getItemId() <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        validateItem(item);
    }
}
