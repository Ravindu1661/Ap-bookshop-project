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
    
    // Default Values
    public static final double DEFAULT_TAX_RATE = 0.05; // 5%
    public static final double DEFAULT_DISCOUNT = 0.0;
}