// CustomerDAO.java - Updated to show newest customers first
package com.redupahana.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.redupahana.model.Customer;
import com.redupahana.util.DBConnectionFactory;

public class CustomerDAO {
    
    public void addCustomer(Customer customer) throws SQLException {
        String query = "INSERT INTO customers (account_number, name, address, phone, email) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, customer.getAccountNumber());
            statement.setString(2, customer.getName());
            statement.setString(3, customer.getAddress());
            statement.setString(4, customer.getPhone());
            statement.setString(5, customer.getEmail());
            statement.executeUpdate();
        }
    }
    
    // Updated method to show newest customers first
    public List<Customer> getAllCustomers() throws SQLException {
        List<Customer> customers = new ArrayList<>();
        // Changed ORDER BY to show newest customers first, then by name
        String query = "SELECT * FROM customers WHERE is_active = true ORDER BY created_date DESC, customer_id DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                customers.add(mapResultSetToCustomer(resultSet));
            }
        }
        return customers;
    }
    
    public Customer getCustomerById(int customerId) throws SQLException {
        String query = "SELECT * FROM customers WHERE customer_id = ? AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, customerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToCustomer(resultSet);
                }
            }
        }
        return null;
    }
    
    public Customer getCustomerByAccountNumber(String accountNumber) throws SQLException {
        String query = "SELECT * FROM customers WHERE account_number = ? AND is_active = true";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, accountNumber);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToCustomer(resultSet);
                }
            }
        }
        return null;
    }
    
    public void updateCustomer(Customer customer) throws SQLException {
        String query = "UPDATE customers SET name = ?, address = ?, phone = ?, email = ? WHERE customer_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setString(1, customer.getName());
            statement.setString(2, customer.getAddress());
            statement.setString(3, customer.getPhone());
            statement.setString(4, customer.getEmail());
            statement.setInt(5, customer.getCustomerId());
            statement.executeUpdate();
        }
    }
    
    public void deleteCustomer(int customerId) throws SQLException {
        String query = "UPDATE customers SET is_active = false WHERE customer_id = ?";
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, customerId);
            statement.executeUpdate();
        }
    }
    
    // Updated search method to also show newest first within search results
    public List<Customer> searchCustomers(String searchTerm) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String query = "SELECT * FROM customers WHERE is_active = true AND " +
                      "(name LIKE ? OR account_number LIKE ? OR phone LIKE ?) " +
                      "ORDER BY created_date DESC, customer_id DESC";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            String searchPattern = "%" + searchTerm + "%";
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    customers.add(mapResultSetToCustomer(resultSet));
                }
            }
        }
        return customers;
    }
    
    // Alternative method if you want alphabetical order for some specific cases
    public List<Customer> getAllCustomersAlphabetical() throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String query = "SELECT * FROM customers WHERE is_active = true ORDER BY name";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            
            while (resultSet.next()) {
                customers.add(mapResultSetToCustomer(resultSet));
            }
        }
        return customers;
    }
    
    // Method to get recently added customers (last 10)
    public List<Customer> getRecentCustomers(int limit) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String query = "SELECT * FROM customers WHERE is_active = true " +
                      "ORDER BY created_date DESC, customer_id DESC LIMIT ?";
        
        try (Connection connection = DBConnectionFactory.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            statement.setInt(1, limit);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    customers.add(mapResultSetToCustomer(resultSet));
                }
            }
        }
        return customers;
    }
    
    private Customer mapResultSetToCustomer(ResultSet resultSet) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerId(resultSet.getInt("customer_id"));
        customer.setAccountNumber(resultSet.getString("account_number"));
        customer.setName(resultSet.getString("name"));
        customer.setAddress(resultSet.getString("address"));
        customer.setPhone(resultSet.getString("phone"));
        customer.setEmail(resultSet.getString("email"));
        customer.setActive(resultSet.getBoolean("is_active"));
        customer.setCreatedDate(resultSet.getString("created_date"));
        customer.setUpdatedDate(resultSet.getString("updated_date"));
        return customer;
    }
}