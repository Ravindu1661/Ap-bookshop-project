// BillItem.java - Enhanced with Base64 Image Support
package com.redupahana.model;

public class BillItem {
    private int billItemId;
    private int billId;
    private int bookId;  // Changed from itemId to bookId
    private int quantity;
    private double unitPrice;
    private double totalPrice;

    // Enhanced Book specific fields - including new Base64 image and category
    private String bookTitle;
    private String bookCode;
    private String author;
    private String isbn;
    private String publisher;
    private String language;
    private int pages;
    private int publicationYear;
    private String imageBase64;    // CHANGED: Base64 image data instead of path
    private String bookCategory;   // Book category
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

    // Basic Getters and Setters
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

    // Enhanced Book specific getters and setters
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookCode() { return bookCode; }
    public void setBookCode(String bookCode) { this.bookCode = bookCode; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public int getPages() { return pages; }
    public void setPages(int pages) { this.pages = pages; }

    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }

    // CHANGED: Base64 image getters and setters
    public String getImageBase64() { return imageBase64; }
    public void setImageBase64(String imageBase64) { this.imageBase64 = imageBase64; }

    public String getBookCategory() { return bookCategory; }
    public void setBookCategory(String bookCategory) { this.bookCategory = bookCategory; }

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
        StringBuilder desc = new StringBuilder();
        if (author != null && !author.trim().isEmpty()) {
            desc.append("by ").append(author);
        }
        if (bookCategory != null && !bookCategory.trim().isEmpty()) {
            if (desc.length() > 0) desc.append(" | ");
            desc.append("Category: ").append(bookCategory);
        }
        if (language != null && !language.trim().isEmpty()) {
            if (desc.length() > 0) desc.append(" | ");
            desc.append("Language: ").append(language);
        }
        return desc.length() > 0 ? desc.toString() : null; 
    }
    public void setItemDescription(String itemDescription) { /* Not used for books */ }

    // CHANGED: Helper methods for Base64 image display
    public boolean hasImage() {
        return imageBase64 != null && !imageBase64.trim().isEmpty();
    }

    public String getImageDataUrl() {
        return hasImage() ? imageBase64 : null;
    }

    public String getImageUrl() {
        return getImageDataUrl(); // Return Base64 data URL directly
    }

    // Backward compatibility for JSPs still using getImagePath()
    public String getImagePath() { 
        return hasImage() ? "base64_image" : null; 
    }
    public void setImagePath(String imagePath) { 
        // For compatibility only - do nothing since we use Base64
    }

    // Helper methods for category display
    public boolean hasCategory() {
        return bookCategory != null && !bookCategory.trim().isEmpty();
    }

    public String getCategoryDisplay() {
        return hasCategory() ? bookCategory : "Uncategorized";
    }

    // Enhanced book info display methods
    public String getBookInfo() {
        StringBuilder info = new StringBuilder();
        if (bookTitle != null) info.append(bookTitle);
        if (author != null && !author.trim().isEmpty()) {
            if (info.length() > 0) info.append(" by ");
            info.append(author);
        }
        return info.toString();
    }

    public String getBookDetails() {
        StringBuilder details = new StringBuilder();
        if (bookCode != null && !bookCode.trim().isEmpty()) {
            details.append("Code: ").append(bookCode);
        }
        if (isbn != null && !isbn.trim().isEmpty()) {
            if (details.length() > 0) details.append(" | ");
            details.append("ISBN: ").append(isbn);
        }
        if (publisher != null && !publisher.trim().isEmpty()) {
            if (details.length() > 0) details.append(" | ");
            details.append("Publisher: ").append(publisher);
        }
        if (publicationYear > 0) {
            if (details.length() > 0) details.append(" | ");
            details.append("Year: ").append(publicationYear);
        }
        if (pages > 0) {
            if (details.length() > 0) details.append(" | ");
            details.append("Pages: ").append(pages);
        }
        return details.toString();
    }

    // Utility methods
    public void calculateTotalPrice() {
        this.totalPrice = this.quantity * this.unitPrice;
    }

    public boolean isBook() {
        return true; // Always true now
    }

    public String getFormattedPrice() {
        return String.format("Rs. %.2f", unitPrice);
    }

    public String getFormattedTotalPrice() {
        return String.format("Rs. %.2f", totalPrice);
    }

    @Override
    public String toString() {
        return "BillItem{" +
                "bookTitle='" + bookTitle + '\'' +
                ", author='" + author + '\'' +
                ", category='" + bookCategory + '\'' +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                ", totalPrice=" + totalPrice +
                ", hasImage=" + hasImage() +
                '}';
    }
}