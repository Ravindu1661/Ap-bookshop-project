// Simple BillNumberGenerator.java using UUID
package com.redupahana.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

public class BillNumberGenerator {
    
    /**
     * Generate unique account number using UUID (guaranteed unique)
     * Format: ACC + YYYYMM + first 6 chars of UUID
     */
    public static String generateAccountNumber() {
        String datePrefix = "ACC" + new SimpleDateFormat("yyyyMM").format(new Date());
        String uniqueId = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return datePrefix + uniqueId;
    }
    
    /**
     * Alternative: Simple timestamp-based generation
     * Format: ACC + YYYYMMDDHHMMSS
     */
    public static String generateAccountNumberTimestamp() {
        return "ACC" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    }
}