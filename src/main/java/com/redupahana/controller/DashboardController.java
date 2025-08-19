// DashboardController.java - Enhanced Dashboard Controller
package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
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

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ReportsService reportsService;
    
    @Override
    public void init() throws ServletException {
        reportsService = ReportsService.getInstance();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        try {
            if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
                showAdminDashboard(request, response);
            } else if (Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
                showCashierDashboard(request, response);
            } else {
                showBasicDashboard(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showAdminDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        // Get dashboard statistics using existing reports service
        Map<String, Object> stats = reportsService.getBasicStats();
        
        // Set attributes
        request.setAttribute("stats", stats);
        request.setAttribute("currentPage", "dashboard");
        request.setAttribute("pageTitle", "Admin Dashboard");
        
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
        
        request.getRequestDispatcher("WEB-INF/view/dashboard/adminDashboard.jsp").forward(request, response);
    }
    
    private void showCashierDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        // Get basic statistics for cashier
        Map<String, Object> stats = reportsService.getBasicStats();
        
        request.setAttribute("stats", stats);
        request.setAttribute("currentPage", "dashboard");
        request.setAttribute("pageTitle", "Cashier Dashboard");
        
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
        
        request.getRequestDispatcher("WEB-INF/view/dashboard/cashierDashboard.jsp").forward(request, response);
    }
    
    private void showBasicDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("currentPage", "dashboard");
        request.setAttribute("pageTitle", "Dashboard");
        
        request.getRequestDispatcher("WEB-INF/view/dashboard/dashboard.jsp").forward(request, response);
    }
}