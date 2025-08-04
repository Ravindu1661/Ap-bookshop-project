// ValidationUtil.java
package com.redupahana.util;

import java.util.regex.Pattern;

public class ValidationUtil {
    
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$");
    
    private static final Pattern PHONE_PATTERN = 
        Pattern.compile("^\\d{10}$");
    
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone).matches();
    }
    
    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }
    
    public static boolean isValidPrice(double price) {
        return price > 0;
    }
    
    public static boolean isValidQuantity(int quantity) {
        return quantity > 0;
    }
}
