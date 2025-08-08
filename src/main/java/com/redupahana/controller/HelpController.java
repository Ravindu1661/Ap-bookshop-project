// HelpController.java
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

@WebServlet("/help")
public class HelpController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        // Only allow cashiers to access help section
        if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
            session.setAttribute("errorMessage", "Access denied. Help & Support is only available for Cashiers.");
            response.sendRedirect("dashboard");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            displayHelpMain(request, response);
        } else if (action.equals("userGuide")) {
            showUserGuide(request, response);
        } else {
            displayHelpMain(request, response);
        }
    }
    
    private void displayHelpMain(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set page attributes for sidebar
        request.setAttribute("currentPage", "help");
        request.setAttribute("pageTitle", "Help & Support");
        
        // Check for messages in session
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
        
        request.getRequestDispatcher("WEB-INF/view/help/helpMain.jsp").forward(request, response);
    }
    
    private void showUserGuide(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setAttribute("currentPage", "help");
        request.setAttribute("pageTitle", "User Guide");
        
        request.getRequestDispatcher("WEB-INF/view/help/userGuide.jsp").forward(request, response);
    }
    
    @SuppressWarnings("unused")
	private void showHelpMain(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set page attributes for sidebar
        request.setAttribute("currentPage", "help");
        request.setAttribute("pageTitle", "Help & Support");
        
        // Check for messages in session
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
        
        request.getRequestDispatcher("WEB-INF/view/help/helpMain.jsp").forward(request, response);
    }
}