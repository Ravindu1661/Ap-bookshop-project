package com.redupahana.model;

public class BillItem {
    private int billItemId;
    private int billId;
    private int bookId;  // Changed from itemId to bookId
    private int quantity;
    private double unitPrice;
    private double totalPrice;

    // Additional fields for display - Book specific
    private String bookTitle;
    private String bookCode;
    private String author;
    private String isbn;
    private Book book;

    // Constructors
    public BillItem() {}

    public BillItem(int billId, int bookId, int quantity, double unitPrice) {
        this.billId = billId;
        this.bookId = bookId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = quantity * unitPrice;
    }

    // Getters and Setters
    public int getBillItemId() { return billItemId; }
    public void setBillItemId(int billItemId) { this.billItemId = billItemId; }

    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public int getBookId() { return bookId; }  // Changed from getItemId
    public void setBookId(int bookId) { this.bookId = bookId; }

    // Backward compatibility methods
    public int getItemId() { return bookId; }  // For compatibility
    public void setItemId(int itemId) { this.bookId = itemId; }

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

    // Book specific getters and setters
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookCode() { return bookCode; }
    public void setBookCode(String bookCode) { this.bookCode = bookCode; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public Book getBook() { return book; }
    public void setBook(Book book) { this.book = book; }

    // Backward compatibility methods for display
    public String getItemName() { return bookTitle; }
    public void setItemName(String itemName) { this.bookTitle = itemName; }

    public String getItemCode() { return bookCode; }
    public void setItemCode(String itemCode) { this.bookCode = itemCode; }

    public String getItemCategory() { return "Books"; }
    public void setItemCategory(String itemCategory) { /* Always Books */ }

    public String getItemDescription() { 
        return author != null ? "by " + author : null; 
    }
    public void setItemDescription(String itemDescription) { /* Not used for books */ }

    // Utility methods
    public void calculateTotalPrice() {
        this.totalPrice = this.quantity * this.unitPrice;
    }

    public boolean isBook() {
        return true; // Always true now
    }

    @Override
    public String toString() {
        return "BillItem{" +
                "bookTitle='" + bookTitle + '\'' +
                ", author='" + author + '\'' +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                ", totalPrice=" + totalPrice +
                '}';
    }
}