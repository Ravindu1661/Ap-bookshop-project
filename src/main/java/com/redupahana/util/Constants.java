// Constants.java
package com.redupahana.util;

public class Constants {

    // User Roles
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_CASHIER = "CASHIER";

    // Payment Status
    public static final String PAYMENT_PAID = "PAID";
    public static final String PAYMENT_PENDING = "PENDING";
    public static final String PAYMENT_CANCELLED = "CANCELLED";

    // Response Messages
    public static final String SUCCESS_ADD = "Record added successfully";
    public static final String SUCCESS_UPDATE = "Record updated successfully";
    public static final String SUCCESS_DELETE = "Record deleted successfully";
    public static final String ERROR_ADD = "Error adding record";
    public static final String ERROR_UPDATE = "Error updating record";
    public static final String ERROR_DELETE = "Error deleting record";
    public static final String ERROR_NOT_FOUND = "Record not found";

    // Customer Specific Messages
    public static final String SUCCESS_CUSTOMER_ADD = "Customer added successfully";
    public static final String SUCCESS_CUSTOMER_UPDATE = "Customer updated successfully";
    public static final String SUCCESS_CUSTOMER_DELETE = "Customer deleted successfully";
    public static final String ERROR_CUSTOMER_NOT_FOUND = "Customer not found";
    public static final String ERROR_CUSTOMER_DUPLICATE_ACCOUNT = "Account number already exists";
    public static final String ERROR_CUSTOMER_INVALID_DATA = "Invalid customer data provided";

    // Validation Messages
    public static final String ERROR_REQUIRED_FIELD = "This field is required";
    public static final String ERROR_INVALID_EMAIL = "Invalid email format";
    public static final String ERROR_INVALID_PHONE = "Invalid phone number format";
    public static final String ERROR_INVALID_ACCOUNT_NUMBER = "Invalid account number format";

    // Default Values
    public static final double DEFAULT_TAX_RATE = 0.10; // 10%
    public static final double DEFAULT_DISCOUNT = 0.0;
    
    // Account Number Settings
    public static final String ACCOUNT_PREFIX = "ACC";
    public static final int ACCOUNT_NUMBER_LENGTH = 12; // ACC + YYYYMM + 6 digits
    
    // Phone Number Settings
    public static final int PHONE_NUMBER_LENGTH = 10;
    public static final String PHONE_PATTERN = "^[0-9]{10}$";
    
    // Email Settings  
    public static final String EMAIL_PATTERN = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    
    // System Settings
    public static final int SESSION_TIMEOUT = 30; // minutes
    public static final int MAX_SEARCH_RESULTS = 100;
    public static final String DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
    public static final String DATE_FORMAT_SHORT = "yyyy-MM-dd";
}