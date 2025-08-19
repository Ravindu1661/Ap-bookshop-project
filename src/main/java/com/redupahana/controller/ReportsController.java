// ReportsController.java - Simple Reports Controller
package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.User;
import com.redupahana.service.ReportsService;
import com.redupahana.util.Constants;

@WebServlet("/reports")
public class ReportsController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ReportsService reportsService;
    
    @Override
    public void init() throws ServletException {
        reportsService = ReportsService.getInstance();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has admin role
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        // Only allow admin access
        if (!Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
            session.setAttribute("errorMessage", "Access denied. Admin privileges required.");
            response.sendRedirect("dashboard");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("dashboard")) {
            showReportsDashboard(request, response);
        } else if (action.equals("sales")) {
            showSalesReport(request, response);
        } else if (action.equals("inventory")) {
            showInventoryReport(request, response);
        } else {
            showReportsDashboard(request, response);
        }
    }
    
    private void showReportsDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get basic statistics
            Map<String, Object> stats = reportsService.getBasicStats();
            
            request.setAttribute("stats", stats);
            request.setAttribute("currentPage", "reports");
            request.setAttribute("pageTitle", "Reports Dashboard");
            
            // Check for messages
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }
            
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage");
            }
            
            request.getRequestDispatcher("WEB-INF/view/reports/dashboard.jsp").forward(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading reports: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showSalesReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get sales data
            List<Map<String, Object>> salesData = reportsService.getSalesData();
            Map<String, Object> salesSummary = reportsService.getSalesSummary();
            
            request.setAttribute("salesData", salesData);
            request.setAttribute("salesSummary", salesSummary);
            request.setAttribute("currentPage", "reports");
            request.setAttribute("pageTitle", "Sales Report");
            
            request.getRequestDispatcher("WEB-INF/view/reports/sales.jsp").forward(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading sales report: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showInventoryReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get inventory data
            List<Map<String, Object>> inventoryData = reportsService.getInventoryData();
            Map<String, Object> inventorySummary = reportsService.getInventorySummary();
            
            request.setAttribute("inventoryData", inventoryData);
            request.setAttribute("inventorySummary", inventorySummary);
            request.setAttribute("currentPage", "reports");
            request.setAttribute("pageTitle", "Inventory Report");
            
            request.getRequestDispatcher("WEB-INF/view/reports/inventory.jsp").forward(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading inventory report: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}