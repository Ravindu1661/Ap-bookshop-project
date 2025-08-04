// Item.java
package com.redupahana.model;

public class Item {
    private int itemId;
    private String itemCode;
    private String name;
    private String description;
    private double price;
    private int stockQuantity;
    private String category;
    private boolean isActive;
    private String createdDate;
    private String updatedDate;

    // Constructors
    public Item() {}

    public Item(String itemCode, String name, String description, double price, int stockQuantity, String category) {
        this.itemCode = itemCode;
        this.name = name;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.category = category;
        this.isActive = true;
    }

    // Getters and Setters
    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getItemCode() { return itemCode; }
    public void setItemCode(String itemCode) { this.itemCode = itemCode; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getCreatedDate() { return createdDate; }
    public void setCreatedDate(String createdDate) { this.createdDate = createdDate; }

    public String getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(String updatedDate) { this.updatedDate = updatedDate; }
}
