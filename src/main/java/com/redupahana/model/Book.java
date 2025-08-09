// Book.java
package com.redupahana.model;

public class Book {
    private int bookId;
    private String bookCode;
    private String title;
    private String description;
    private double price;
    private int stockQuantity;
    private String author;
    private String isbn;
    private String publisher;
    private int publicationYear;
    private int pages;
    private String language;
    private boolean isActive;
    private String createdDate;
    private String updatedDate;
    
    // New fields for image and category
    private String imagePath;
    private String bookCategory;

    // Constructors
    public Book() {
        this.isActive = true;
        this.language = "Sinhala";
    }

    public Book(String title, String author, double price, int stockQuantity) {
        this();
        this.title = title;
        this.author = author;
        this.price = price;
        this.stockQuantity = stockQuantity;
    }

    // Getters and Setters
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getBookCode() { return bookCode; }
    public void setBookCode(String bookCode) { this.bookCode = bookCode; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }

    public int getPages() { return pages; }
    public void setPages(int pages) { this.pages = pages; }

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getCreatedDate() { return createdDate; }
    public void setCreatedDate(String createdDate) { this.createdDate = createdDate; }

    public String getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(String updatedDate) { this.updatedDate = updatedDate; }

    // New getters and setters for image and category
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getBookCategory() { return bookCategory; }
    public void setBookCategory(String bookCategory) { this.bookCategory = bookCategory; }

    // Helper methods for backward compatibility with Item
    public int getItemId() { return bookId; }
    public void setItemId(int itemId) { this.bookId = itemId; }

    public String getItemCode() { return bookCode; }
    public void setItemCode(String itemCode) { this.bookCode = itemCode; }

    public String getName() { return title; }
    public void setName(String name) { this.title = name; }

    public String getCategory() { return "Books"; }
    public void setCategory(String category) { /* Always Books */ }

    @Override
    public String toString() {
        return "Book{" +
                "title='" + title + '\'' +
                ", author='" + author + '\'' +
                ", price=" + price +
                ", stock=" + stockQuantity +
                ", category='" + bookCategory + '\'' +
                '}';
    }
}