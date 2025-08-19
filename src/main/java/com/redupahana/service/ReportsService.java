// ReportsService.java - Simple Reports Service
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import com.redupahana.dao.ReportsDAO;

public class ReportsService {
    private static ReportsService instance;
    private ReportsDAO reportsDAO;
    
    private ReportsService() {
        reportsDAO = ReportsDAO.getInstance();
    }
    
    public static synchronized ReportsService getInstance() {
        if (instance == null) {
            instance = new ReportsService();
        }
        return instance;
    }
    
    // Basic dashboard statistics
    public Map<String, Object> getBasicStats() throws SQLException {
        return reportsDAO.getBasicStats();
    }
    
    // Sales report data
    public List<Map<String, Object>> getSalesData() throws SQLException {
        return reportsDAO.getSalesData();
    }
    
    public Map<String, Object> getSalesSummary() throws SQLException {
        return reportsDAO.getSalesSummary();
    }
    
    // Inventory report data
    public List<Map<String, Object>> getInventoryData() throws SQLException {
        return reportsDAO.getInventoryData();
    }
    
    public Map<String, Object> getInventorySummary() throws SQLException {
        return reportsDAO.getInventorySummary();
    }
}