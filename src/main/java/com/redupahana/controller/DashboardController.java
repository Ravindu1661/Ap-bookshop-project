// DashboardController.java
package com.redupahana.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.User;
import com.redupahana.util.Constants;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
            request.getRequestDispatcher("WEB-INF/view/dashboard/adminDashboard.jsp").forward(request, response);
        } else if (Constants.ROLE_CASHIER.equals(loggedUser.getRole())) {
            request.getRequestDispatcher("WEB-INF/view/dashboard/cashierDashboard.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("WEB-INF/view/dashboard/dashboard.jsp").forward(request, response);
        }
    }
}