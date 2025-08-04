package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.User;
import com.redupahana.service.UserService;
import com.redupahana.util.Constants;


//@WebServlet("/auth")
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserService userService;
    
    @Override
    public void init() throws ServletException {
        userService = UserService.getInstance();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            logout(request, response);
        } else {
            showLoginForm(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("login".equals(action)) {
            login(request, response);
        }
    }
    
    private void showLoginForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }
    
    private void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        try {
            User user = userService.authenticateUser(username, password);
            
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loggedUser", user);
                session.setAttribute("userRole", user.getRole());
                
                // Redirect based on role
                if (Constants.ROLE_ADMIN.equals(user.getRole())) {
                    response.sendRedirect("dashboard?action=admin");
                } else if (Constants.ROLE_CASHIER.equals(user.getRole())) {
                    response.sendRedirect("dashboard?action=cashier");
                } else {
                    response.sendRedirect("dashboard");
                }
            } else {
                request.setAttribute("errorMessage", "Invalid username or password");
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/error.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }
    
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("auth");
    }
}