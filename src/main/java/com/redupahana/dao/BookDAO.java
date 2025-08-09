// BookDAO.java - Updated with Base64 Image Support
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.Book;
import com.redupahana.util.DBConnectionFactory;

public class BookDAO {
    
    /**
     * Add a new book with Base64 image support
     */
    public void addBook(Book book) throws SQLException {
        String query = "INSERT INTO items (item_code, name, description, price, stock_quantity, category, " +
                      "author, isbn, publisher, publication_year, pages, language, image_base64, book_category) " +
                      "VALUES (?, ?, ?, ?, ?, 'Books', ?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            connection = DBConnectionFactory.getConnection();
            // Disable auto-commit for transaction control
            connection.setAutoCommit(false);
            
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            
            statement.setString(1, book.getBookCode());
            statement.setString(2, book.getTitle());
            statement.setString(3, book.getDescription());
            statement.setDouble(4, book.getPrice());
            statement.setInt(5, book.getStockQuantity());
            statement.setString(6, book.getAuthor());
            statement.setString(7, book.getIsbn());
            statement.setString(8, book.getPublisher());
            
            // Handle null values for integer fields
            if (book.getPublicationYear() > 0) {
                statement.setInt(9, book.getPublicationYear());
            } else {
                statement.setNull(9, Types.INTEGER);
            }
            
            if (book.getPages() > 0) {
                statement.setInt(10, book.getPages());
            } else {
                statement.setNull(10, Types.INTEGER);
            }
            
            statement.setString(11, book.getLanguage());
            statement.setString(12, book.getImageBase64()); // Base64 image data
            statement.setString(13, book.getBookCategory());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating book failed, no rows affected.");
            }
            
            // Get the generated ID
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    book.setBookId(generatedKeys.getInt(1));
                }
            }
            
            // Commit the transaction
            connection.commit();
            
        } catch (SQLException e) {
            // Rollback on error
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    // Log rollback exception
                    System.err.println("Error during rollback: " + rollbackEx.getMessage());
                }
            }
            
            // Check if it's a duplicate key error and provide specific message
            if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("item_code")) {
                throw new SQLException("Book code '" + book.getBookCode() + "' already exists. Please try again.");
            }
            
            throw e;
        } finally {
            // Restore auto-commit and close resources
            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                } catch (SQLException e) {
                    System.err.println("Error restoring auto-commit: " + e.getMessage());
                }
            }
            
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    System.err.println("Error closing statement: " + e.getMessage());
                }
            }
            
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }
    }
    
    /**
     * Get all books ordered by created date (newest first)
     */
    public List<Book> getAllBooks() throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true " +
                      "ORDER BY created_date DESC, item_id DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                books.add(mapResultSetToBook(resultSet));
            }
        }
        return books;
    }
    
    /**
     * Get all books ordered by name (for specific use cases)
     */
    public List<Book> getAllBooksByName() throws SQLException {
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
    
    /**
     * Get book by ID with improved error handling
     */
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
    
    /**
     * Get book by code with case-insensitive search
     */
    public Book getBookByCode(String bookCode) throws SQLException {
        String query = "SELECT * FROM items WHERE UPPER(item_code) = UPPER(?) AND category = 'Books' AND is_active = true";
        
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
    
    /**
     * Get book by ISBN
     */
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
    
    /**
     * Update book with Base64 image support
     */
    public void updateBook(Book book) throws SQLException {
        String query = "UPDATE items SET name = ?, description = ?, price = ?, stock_quantity = ?, " +
                      "author = ?, isbn = ?, publisher = ?, publication_year = ?, pages = ?, language = ?, " +
                      "image_base64 = ?, book_category = ? " +
                      "WHERE item_id = ? AND category = 'Books'";
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            connection = DBConnectionFactory.getConnection();
            connection.setAutoCommit(false);
            
            statement = connection.prepareStatement(query);
            
            statement.setString(1, book.getTitle());
            statement.setString(2, book.getDescription());
            statement.setDouble(3, book.getPrice());
            statement.setInt(4, book.getStockQuantity());
            statement.setString(5, book.getAuthor());
            statement.setString(6, book.getIsbn());
            statement.setString(7, book.getPublisher());
            
            // Handle null values for integer fields
            if (book.getPublicationYear() > 0) {
                statement.setInt(8, book.getPublicationYear());
            } else {
                statement.setNull(8, Types.INTEGER);
            }
            
            if (book.getPages() > 0) {
                statement.setInt(9, book.getPages());
            } else {
                statement.setNull(9, Types.INTEGER);
            }
            
            statement.setString(10, book.getLanguage());
            statement.setString(11, book.getImageBase64()); // Base64 image data
            statement.setString(12, book.getBookCategory());
            statement.setInt(13, book.getBookId());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Updating book failed, no rows affected. Book may not exist.");
            }
            
            connection.commit();
            
        } catch (SQLException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("Error during rollback: " + rollbackEx.getMessage());
                }
            }
            throw e;
        } finally {
            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                } catch (SQLException e) {
                    System.err.println("Error restoring auto-commit: " + e.getMessage());
                }
            }
            
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    System.err.println("Error closing statement: " + e.getMessage());
                }
            }
            
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }
    }
    
    /**
     * Soft delete book (mark as inactive)
     */
    public void deleteBook(int bookId) throws SQLException {
        String query = "UPDATE items SET is_active = false, image_base64 = NULL " +
                      "WHERE item_id = ? AND category = 'Books'";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, bookId);
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Deleting book failed, no rows affected. Book may not exist.");
            }
        }
    }
    
    /**
     * Update stock quantity
     */
    public void updateStock(int bookId, int quantity) throws SQLException {
        String query = "UPDATE items SET stock_quantity = stock_quantity - ? WHERE item_id = ? AND category = 'Books'";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, quantity);
            statement.setInt(2, bookId);
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Updating stock failed, no rows affected. Book may not exist.");
            }
        }
    }
    
    /**
     * Search books with improved search functionality including category
     */
    public List<Book> searchBooks(String searchTerm) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND " +
                      "(UPPER(name) LIKE UPPER(?) OR UPPER(item_code) LIKE UPPER(?) OR UPPER(author) LIKE UPPER(?) " +
                      "OR UPPER(isbn) LIKE UPPER(?) OR UPPER(publisher) LIKE UPPER(?) OR UPPER(description) LIKE UPPER(?) " +
                      "OR UPPER(book_category) LIKE UPPER(?)) " +
                      "ORDER BY " +
                      "CASE " +
                      "  WHEN UPPER(name) LIKE UPPER(?) THEN 1 " +
                      "  WHEN UPPER(author) LIKE UPPER(?) THEN 2 " +
                      "  WHEN UPPER(item_code) LIKE UPPER(?) THEN 3 " +
                      "  ELSE 4 " +
                      "END, created_date DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            String searchPattern = "%" + searchTerm + "%";
            // Set parameters for WHERE clause
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            statement.setString(4, searchPattern);
            statement.setString(5, searchPattern);
            statement.setString(6, searchPattern);
            statement.setString(7, searchPattern);
            // Set parameters for ORDER BY clause
            statement.setString(8, searchPattern);
            statement.setString(9, searchPattern);
            statement.setString(10, searchPattern);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    books.add(mapResultSetToBook(resultSet));
                }
            }
        }
        return books;
    }
    
    /**
     * Get books by author
     */
    public List<Book> getBooksByAuthor(String author) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND UPPER(author) LIKE UPPER(?) " +
                      "ORDER BY created_date DESC, name";
        
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
    
    /**
     * Get books by language
     */
    public List<Book> getBooksByLanguage(String language) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND language = ? " +
                      "ORDER BY created_date DESC, name";
        
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
    
    /**
     * Get books by category
     */
    public List<Book> getBooksByCategory(String category) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM items WHERE category = 'Books' AND is_active = true AND book_category = ? " +
                      "ORDER BY created_date DESC, name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, category);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    books.add(mapResultSetToBook(resultSet));
                }
            }
        }
        return books;
    }
    
    /**
     * Get all unique book categories
     */
    public List<String> getAllBookCategories() throws SQLException {
        List<String> categories = new ArrayList<>();
        String query = "SELECT DISTINCT book_category FROM items WHERE category = 'Books' AND is_active = true " +
                      "AND book_category IS NOT NULL AND book_category != '' ORDER BY book_category";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                categories.add(resultSet.getString("book_category"));
            }
        }
        return categories;
    }
    
    /**
     * Check if book code exists (case-insensitive)
     */
    public boolean bookCodeExists(String bookCode) throws SQLException {
        String query = "SELECT COUNT(*) FROM items WHERE UPPER(item_code) = UPPER(?) AND category = 'Books' AND is_active = true";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, bookCode);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    /**
     * Get maximum book ID for code generation
     */
    public int getMaxBookId() throws SQLException {
        String query = "SELECT COALESCE(MAX(item_id), 0) FROM items WHERE category = 'Books'";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        }
        return 0;
    }
    
    /**
     * Map ResultSet to Book object with Base64 image support
     */
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
        
        // Handle nullable integer fields
        int publicationYear = resultSet.getInt("publication_year");
        if (!resultSet.wasNull()) {
            book.setPublicationYear(publicationYear);
        }
        
        int pages = resultSet.getInt("pages");
        if (!resultSet.wasNull()) {
            book.setPages(pages);
        }
        
        book.setLanguage(resultSet.getString("language"));
        book.setActive(resultSet.getBoolean("is_active"));
        
        // Handle Base64 image and category
        book.setImageBase64(resultSet.getString("image_base64"));
        book.setBookCategory(resultSet.getString("book_category"));
        
        // Handle timestamps
        Timestamp createdTimestamp = resultSet.getTimestamp("created_date");
        if (createdTimestamp != null) {
            book.setCreatedDate(createdTimestamp.toString());
        }
        
        Timestamp updatedTimestamp = resultSet.getTimestamp("updated_date");
        if (updatedTimestamp != null) {
            book.setUpdatedDate(updatedTimestamp.toString());
        }
        
        return book;
    }
}