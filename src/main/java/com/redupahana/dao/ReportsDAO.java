// ReportsDAO.java - Simple Reports Data Access
package com.redupahana.dao;

import java.sql.*;
import java.util.*;
import com.redupahana.util.DBConnectionFactory;

public class ReportsDAO {
    private static ReportsDAO instance;
    
    private ReportsDAO() {}
    
    public static synchronized ReportsDAO getInstance() {
        if (instance == null) {
            instance = new ReportsDAO();
        }
        return instance;
    }
    
    // Basic dashboard statistics
    public Map<String, Object> getBasicStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection conn = DBConnectionFactory.getConnection()) {
            // Total sales today
            String todaySQL = "SELECT COALESCE(SUM(total_amount), 0) as today_sales, COUNT(*) as today_bills " +
                              "FROM bills WHERE DATE(bill_date) = CURDATE() AND is_active = 1";
            try (PreparedStatement stmt = conn.prepareStatement(todaySQL);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("todaySales", rs.getDouble("today_sales"));
                    stats.put("todayBills", rs.getInt("today_bills"));
                }
            }
            
            // Monthly sales
            String monthlySQL = "SELECT COALESCE(SUM(total_amount), 0) as monthly_sales, COUNT(*) as monthly_bills " +
                               "FROM bills WHERE MONTH(bill_date) = MONTH(CURDATE()) AND YEAR(bill_date) = YEAR(CURDATE()) AND is_active = 1";
            try (PreparedStatement stmt = conn.prepareStatement(monthlySQL);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("monthlySales", rs.getDouble("monthly_sales"));
                    stats.put("monthlyBills", rs.getInt("monthly_bills"));
                }
            }
            
            // Total customers
            String customerSQL = "SELECT COUNT(*) as total_customers FROM customers WHERE is_active = 1";
            try (PreparedStatement stmt = conn.prepareStatement(customerSQL);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalCustomers", rs.getInt("total_customers"));
                }
            }
            
            // Total books
            String booksSQL = "SELECT COUNT(*) as total_books, SUM(stock_quantity) as total_stock FROM items WHERE is_active = 1";
            try (PreparedStatement stmt = conn.prepareStatement(booksSQL);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalBooks", rs.getInt("total_books"));
                    stats.put("totalStock", rs.getInt("total_stock"));
                }
            }
        }
        
        return stats;
    }
    
    // Sales report data
    public List<Map<String, Object>> getSalesData() throws SQLException {
        List<Map<String, Object>> salesData = new ArrayList<>();
        String sql = "SELECT b.bill_number, b.bill_date, b.total_amount, b.payment_status, " +
                     "c.name as customer_name, u.full_name as cashier_name " +
                     "FROM bills b " +
                     "LEFT JOIN customers c ON b.customer_id = c.customer_id " +
                     "LEFT JOIN users u ON b.cashier_id = u.user_id " +
                     "WHERE b.is_active = 1 " +
                     "ORDER BY b.bill_date DESC LIMIT 100";
        
        try (Connection conn = DBConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("billNumber", rs.getString("bill_number"));
                row.put("billDate", rs.getTimestamp("bill_date"));
                row.put("totalAmount", rs.getDouble("total_amount"));
                row.put("paymentStatus", rs.getString("payment_status"));
                row.put("customerName", rs.getString("customer_name"));
                row.put("cashierName", rs.getString("cashier_name"));
                salesData.add(row);
            }
        }
        
        return salesData;
    }
    
    public Map<String, Object> getSalesSummary() throws SQLException {
        Map<String, Object> summary = new HashMap<>();
        
        try (Connection conn = DBConnectionFactory.getConnection()) {
            String sql = "SELECT COUNT(*) as total_bills, SUM(total_amount) as total_sales, " +
                        "AVG(total_amount) as avg_sale, " +
                        "SUM(CASE WHEN payment_status = 'PAID' THEN total_amount ELSE 0 END) as paid_amount, " +
                        "SUM(CASE WHEN payment_status = 'PENDING' THEN total_amount ELSE 0 END) as pending_amount " +
                        "FROM bills WHERE is_active = 1";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalBills", rs.getInt("total_bills"));
                    summary.put("totalSales", rs.getDouble("total_sales"));
                    summary.put("avgSale", rs.getDouble("avg_sale"));
                    summary.put("paidAmount", rs.getDouble("paid_amount"));
                    summary.put("pendingAmount", rs.getDouble("pending_amount"));
                }
            }
        }
        
        return summary;
    }
    
    // Inventory report data
    public List<Map<String, Object>> getInventoryData() throws SQLException {
        List<Map<String, Object>> inventoryData = new ArrayList<>();
        String sql = "SELECT item_code, name as book_title, author, price, stock_quantity, " +
                     "book_category, language, " +
                     "CASE WHEN stock_quantity = 0 THEN 'Out of Stock' " +
                     "     WHEN stock_quantity <= 5 THEN 'Low Stock' " +
                     "     ELSE 'In Stock' END as stock_status " +
                     "FROM items WHERE is_active = 1 ORDER BY stock_quantity ASC";
        
        try (Connection conn = DBConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("itemCode", rs.getString("item_code"));
                row.put("bookTitle", rs.getString("book_title"));
                row.put("author", rs.getString("author"));
                row.put("price", rs.getDouble("price"));
                row.put("stockQuantity", rs.getInt("stock_quantity"));
                row.put("bookCategory", rs.getString("book_category"));
                row.put("language", rs.getString("language"));
                row.put("stockStatus", rs.getString("stock_status"));
                inventoryData.add(row);
            }
        }
        
        return inventoryData;
    }
    
    public Map<String, Object> getInventorySummary() throws SQLException {
        Map<String, Object> summary = new HashMap<>();
        
        try (Connection conn = DBConnectionFactory.getConnection()) {
            String sql = "SELECT COUNT(*) as total_items, SUM(stock_quantity) as total_stock, " +
                        "COUNT(CASE WHEN stock_quantity = 0 THEN 1 END) as out_of_stock, " +
                        "COUNT(CASE WHEN stock_quantity <= 5 AND stock_quantity > 0 THEN 1 END) as low_stock, " +
                        "SUM(price * stock_quantity) as total_value " +
                        "FROM items WHERE is_active = 1";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalItems", rs.getInt("total_items"));
                    summary.put("totalStock", rs.getInt("total_stock"));
                    summary.put("outOfStock", rs.getInt("out_of_stock"));
                    summary.put("lowStock", rs.getInt("low_stock"));
                    summary.put("totalValue", rs.getDouble("total_value"));
                }
            }
        }
        
        return summary;
    }
}