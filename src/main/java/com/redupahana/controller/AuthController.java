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
import com.redupahana.model.Customer;
import com.redupahana.service.UserService;
import com.redupahana.service.CustomerService;
import com.redupahana.util.Constants;
import com.redupahana.util.SecurityUtil;

//@WebServlet("/auth")
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserService userService;
    private CustomerService customerService;
    
    @Override
    public void init() throws ServletException {
        userService = UserService.getInstance();
        customerService = CustomerService.getInstance();
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
            staffLogin(request, response);
        } else if ("customerLogin".equals(action)) {
            customerLogin(request, response);
        }
    }
    
    private void showLoginForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }
    
 // AuthController.java - Complete modifications

    private void staffLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        try {
            // Get user by username first
            User user = userService.getUserByUsername(username);
            
            if (user != null) {
                // Use SecurityUtil.verifyPassword to check password
                if (SecurityUtil.verifyPassword(password, user.getPassword())) {
                    HttpSession session = request.getSession();
                    session.setAttribute("loggedUser", user);
                    session.setAttribute("userRole", user.getRole());
                    session.setAttribute("loginType", "staff");
                    
                    // Set welcome notification flag for first login
                    session.setAttribute("showWelcomeNotification", "true");
                    
                    // Set success message and redirect URL
                    String redirectUrl;
                    String welcomeMessage = "Welcome back, " + user.getFullName() + "!";
                    
                    if (Constants.ROLE_ADMIN.equals(user.getRole())) {
                        redirectUrl = "dashboard?action=admin";
                        welcomeMessage += " Admin Dashboard loading...";
                    } else if (Constants.ROLE_CASHIER.equals(user.getRole())) {
                        redirectUrl = "dashboard?action=cashier";
                        welcomeMessage += " Cashier Dashboard loading...";
                    } else {
                        redirectUrl = "dashboard";
                        welcomeMessage += " Dashboard loading...";
                    }
                    
                    // Set success message and redirect URL in request
                    request.setAttribute("successMessage", welcomeMessage);
                    request.setAttribute("redirectUrl", redirectUrl);
                    request.setAttribute("showSuccess", "true");
                    
                    // Forward to login page with success message (will auto-redirect)
                    request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
                    
                } else {
                    request.setAttribute("errorMessage", "Invalid username or password");
                    request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
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

    private void customerLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accountNumber = request.getParameter("accountNumber");
        
        try {
            // Validate account number input
            if (accountNumber == null || accountNumber.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Account number is required");
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
                return;
            }
            
            // Get customer by account number
            Customer customer = customerService.getCustomerByAccountNumber(accountNumber.trim());
            
            if (customer != null && customer.isActive()) {
                HttpSession session = request.getSession();
                session.setAttribute("loggedCustomer", customer);
                session.setAttribute("loginType", "customer");
                
                // Set welcome notification flag for customer login
                session.setAttribute("showWelcomeNotification", "true");
                
                // Set success message and redirect URL
                String welcomeMessage = "Welcome, " + customer.getName() + "! Customer Portal loading...";
                String redirectUrl = "customerPortal";
                
                // Set success message and redirect URL in request
                request.setAttribute("successMessage", welcomeMessage);
                request.setAttribute("redirectUrl", redirectUrl);
                request.setAttribute("showSuccess", "true");
                
                // Forward to login page with success message (will auto-redirect)
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
                
            } else {
                request.setAttribute("errorMessage", "Invalid account number or account is inactive");
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/error.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String userName = null;
        String userType = "User";
        
        if (session != null) {
            // Get user info before invalidating session
            User loggedUser = (User) session.getAttribute("loggedUser");
            Customer loggedCustomer = (Customer) session.getAttribute("loggedCustomer");
            String loginType = (String) session.getAttribute("loginType");
            
            if (loggedUser != null) {
                userName = loggedUser.getFullName();
                userType = Constants.ROLE_ADMIN.equals(loggedUser.getRole()) ? "Administrator" : "Cashier";
            } else if (loggedCustomer != null) {
                userName = loggedCustomer.getName();
                userType = "Customer";
            }
            
            // Invalidate session
            session.invalidate();
        }
        
        // Create new session for logout message
        HttpSession newSession = request.getSession(true);
        
        // Set logout success message
        String logoutMessage = userName != null ? 
            "Goodbye, " + userName + "! You have been successfully logged out." :
            "You have been successfully logged out.";
        
        newSession.setAttribute("logoutMessage", logoutMessage);
        newSession.setAttribute("logoutUserType", userType);
        newSession.setAttribute("showLogout", "true");
        
        // Redirect to auth (login page will show logout message)
        response.sendRedirect("auth");
    }
    
}