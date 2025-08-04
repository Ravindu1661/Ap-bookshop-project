// CustomerService.java
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.CustomerDAO;
import com.redupahana.model.Customer;
import com.redupahana.util.BillNumberGenerator;
import com.redupahana.util.ValidationUtil;

public class CustomerService {
    
    private static CustomerService instance;
    private CustomerDAO customerDAO;
    
    private CustomerService() {
        this.customerDAO = new CustomerDAO();
    }
    
    public static CustomerService getInstance() {
        if (instance == null) {
            synchronized (CustomerService.class) {
                if (instance == null) {
                    instance = new CustomerService();
                }
            }
        }
        return instance;
    }
    
    public void addCustomer(Customer customer) throws SQLException {
        validateCustomer(customer);
        // Generate account number if not provided
        if (customer.getAccountNumber() == null || customer.getAccountNumber().isEmpty()) {
            customer.setAccountNumber(BillNumberGenerator.generateAccountNumber());
        }
        customerDAO.addCustomer(customer);
    }
    
    public List<Customer> getAllCustomers() throws SQLException {
        return customerDAO.getAllCustomers();
    }
    
    public Customer getCustomerById(int customerId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        return customerDAO.getCustomerById(customerId);
    }
    
    public Customer getCustomerByAccountNumber(String accountNumber) throws SQLException {
        if (!ValidationUtil.isNotEmpty(accountNumber)) {
            throw new IllegalArgumentException("Account number is required");
        }
        return customerDAO.getCustomerByAccountNumber(accountNumber);
    }
    
    public void updateCustomer(Customer customer) throws SQLException {
        validateCustomerForUpdate(customer);
        customerDAO.updateCustomer(customer);
    }
    
    public void deleteCustomer(int customerId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        customerDAO.deleteCustomer(customerId);
    }
    
    public List<Customer> searchCustomers(String searchTerm) throws SQLException {
        if (!ValidationUtil.isNotEmpty(searchTerm)) {
            throw new IllegalArgumentException("Search term is required");
        }
        return customerDAO.searchCustomers(searchTerm);
    }
    
    private void validateCustomer(Customer customer) {
        if (!ValidationUtil.isNotEmpty(customer.getName())) {
            throw new IllegalArgumentException("Customer name is required");
        }
        if (!ValidationUtil.isNotEmpty(customer.getPhone())) {
            throw new IllegalArgumentException("Phone number is required");
        }
        if (!ValidationUtil.isValidPhone(customer.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }
        if (customer.getEmail() != null && !customer.getEmail().isEmpty() && !ValidationUtil.isValidEmail(customer.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }
    
    private void validateCustomerForUpdate(Customer customer) {
        if (customer.getCustomerId() <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        validateCustomer(customer);
    }
}