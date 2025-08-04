// BillNumberGenerator.java
package com.redupahana.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class BillNumberGenerator {
    
    private static int counter = 1;
    
    public static synchronized String generateBillNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String dateString = sdf.format(new Date());
        return "BILL" + dateString + String.format("%04d", counter++);
    }
    
    public static synchronized String generateAccountNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
        String dateString = sdf.format(new Date());
        return "ACC" + dateString + String.format("%03d", counter++);
    }
    
    public static synchronized String generateItemCode(String category) {
        String prefix = category.toUpperCase().substring(0, Math.min(3, category.length()));
        return prefix + String.format("%03d", counter++);
    }
}
