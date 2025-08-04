// BillItem.java
package com.redupahana.model;

public class BillItem {
    private int billItemId;
    private int billId;
    private int itemId;
    private int quantity;
    private double unitPrice;
    private double totalPrice;
    private Item item;

    // Constructors
    public BillItem() {}

    public BillItem(int billId, int itemId, int quantity, double unitPrice) {
        this.billId = billId;
        this.itemId = itemId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = quantity * unitPrice;
    }

    // Getters and Setters
    public int getBillItemId() { return billItemId; }
    public void setBillItemId(int billItemId) { this.billItemId = billItemId; }

    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { 
        this.quantity = quantity;
        this.totalPrice = quantity * unitPrice;
    }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { 
        this.unitPrice = unitPrice;
        this.totalPrice = quantity * unitPrice;
    }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public Item getItem() { return item; }
    public void setItem(Item item) { this.item = item; }
}