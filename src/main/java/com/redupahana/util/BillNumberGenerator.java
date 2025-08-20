// Simple BillNumberGenerator.java using UUID
package com.redupahana.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

public class BillNumberGenerator {
    
   
    public static String generateAccountNumber() {
        String datePrefix = "ACC" + new SimpleDateFormat("yyyyMM").format(new Date());
        String uniqueId = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return datePrefix + uniqueId;
    }
    
    
    public static String generateAccountNumberTimestamp() {
        return "ACC" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    }
}