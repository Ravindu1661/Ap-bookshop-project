// BookDAO.java
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.Book;
import com.redupahana.util.DBConnectionFactory;

public class BookDAO {
    
    public void addBook(Book book) throws SQLException {
        String query = "INSERT INTO items (item_code, name, description, price, stock_quantity, category, " +
                      "author, isbn, publisher, publication_year, pages, language) " +
                      "VALUES (?, ?, ?, ?, ?, 'Books', ?, ?, ?, ?, ?, ?)";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, book.getBookCode());
            statement.setString(2, book.getTitle());
            statement.setString(3, book.getDescription());
            statement.setDouble(4, book.getPrice());
            statement.setInt(5, book.getStockQuantity());
            statement.setString(6, book.getAuthor());
            statement.setString(7, book.getIsbn());
            statement.setString(8, book.getPublisher());
            statement.setInt(9, book.getPublicationYear());
            statement.setInt(10, book.getPages());
            statement.setString(11, book.getLanguage());
            
            statement.executeUpdate();
        }
    }
    
    public List<Book> getAllBooks() throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                books.add(mapResultSetToBook(resultSet));
            }
        }
        return books;
    }
    
    public Book getBookById(int bookId) throws SQLException {
        String query = "SELECT * FROM items WHERE item_id = ? AND category = 'Books' AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, bookId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBook(resultSet);
                }
            }
        }
        return null;
    }
    
    public Book getBookByCode(String bookCode) throws SQLException {
        String query = "SELECT * FROM items WHERE item_code = ? AND category = 'Books' AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, bookCode);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBook(resultSet);
                }
            }
        }
        return null;
    }
    
    public Book getBookByIsbn(String isbn) throws SQLException {
        String query = "SELECT * FROM items WHERE isbn = ? AND category = 'Books' AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, isbn);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToBook(resultSet);
                }
            }
        }
        return null;
    }
    
    public void updateBook(Book book) throws SQLException {
        String query = "UPDATE items SET name = ?, description = ?, price = ?, stock_quantity = ?, " +
                      "author = ?, isbn = ?, publisher = ?, publication_year = ?, pages = ?, language = ? " +
                      "WHERE item_id = ? AND category = 'Books'";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, book.getTitle());
            statement.setString(2, book.getDescription());
            statement.setDouble(3, book.getPrice());
            statement.setInt(4, book.getStockQuantity());
            statement.setString(5, book.getAuthor());
            statement.setString(6, book.getIsbn());
            statement.setString(7, book.getPublisher());
            statement.setInt(8, book.getPublicationYear());
            statement.setInt(9, book.getPages());
            statement.setString(10, book.getLanguage());
            statement.setInt(11, book.getBookId());
            
            statement.executeUpdate();
        }
    }
    
    public void deleteBook(int bookId) throws SQLException {
        String query = "UPDATE items SET is_active = false WHERE item_id = ? AND category = 'Books'";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, bookId);
            statement.executeUpdate();
        }
    }
    
    public void updateStock(int bookId, int quantity) throws SQLException {
        String query = "UPDATE items SET stock_quantity = stock_quantity - ? WHERE item_id = ? AND category = 'Books'";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, quantity);
            statement.setInt(2, bookId);
            statement.executeUpdate();
        }
    }
    
    public List<Book> searchBooks(String searchTerm) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND " +
                      "(name LIKE ? OR item_code LIKE ? OR author LIKE ? OR isbn LIKE ? OR publisher LIKE ?) " +
                      "ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            String searchPattern = "%" + searchTerm + "%";
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            statement.setString(4, searchPattern);
            statement.setString(5, searchPattern);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    books.add(mapResultSetToBook(resultSet));
                }
            }
        }
        return books;
    }
    
    public List<Book> getBooksByAuthor(String author) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND author LIKE ? ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, "%" + author + "%");
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    books.add(mapResultSetToBook(resultSet));
                }
            }
        }
        return books;
    }
    
    public List<Book> getBooksByLanguage(String language) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND language = ? ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, language);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    books.add(mapResultSetToBook(resultSet));
                }
            }
        }
        return books;
    }
    
    private Book mapResultSetToBook(ResultSet resultSet) throws SQLException {
        Book book = new Book();
        book.setBookId(resultSet.getInt("item_id"));
        book.setBookCode(resultSet.getString("item_code"));
        book.setTitle(resultSet.getString("name"));
        book.setDescription(resultSet.getString("description"));
        book.setPrice(resultSet.getDouble("price"));
        book.setStockQuantity(resultSet.getInt("stock_quantity"));
        book.setAuthor(resultSet.getString("author"));
        book.setIsbn(resultSet.getString("isbn"));
        book.setPublisher(resultSet.getString("publisher"));
        book.setPublicationYear(resultSet.getInt("publication_year"));
        book.setPages(resultSet.getInt("pages"));
        book.setLanguage(resultSet.getString("language"));
        book.setActive(resultSet.getBoolean("is_active"));
        book.setCreatedDate(resultSet.getString("created_date"));
        book.setUpdatedDate(resultSet.getString("updated_date"));
        return book;
    }
}