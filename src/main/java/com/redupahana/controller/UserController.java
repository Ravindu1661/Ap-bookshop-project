// UserController.java
package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.User;
import com.redupahana.service.UserService;
import com.redupahana.util.Constants;

@WebServlet("/user")
public class UserController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserService userService;
    
    public void init() throws ServletException {
        userService = UserService.getInstance();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        if (!Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
            request.setAttribute("errorMessage", "Access denied. Admin privileges required.");
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listUsers(request, response);
        } else if (action.equals("add")) {
            showAddForm(request, response);
        } else if (action.equals("edit")) {
            showEditForm(request, response);
        } else if (action.equals("delete")) {
            deleteUser(request, response);
        } else if (action.equals("view")) {
            viewUser(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        if (!Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
            request.setAttribute("errorMessage", "Access denied. Admin privileges required.");
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action.equals("add")) {
            addUser(request, response);
        } else if (action.equals("update")) {
            updateUser(request, response);
        }
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<User> users = userService.getAllUsers();
            request.setAttribute("users", users);
            
            // Check for success messages in session
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage"); // Remove after displaying
            }
            
            // Check for error messages in session
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage"); // Remove after displaying
            }
            
            request.getRequestDispatcher("WEB-INF/view/user/listUsers.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading users: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
    }
    
    private void addUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get form parameters
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            
            // Basic validation
            if (username == null || username.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Username is required.");
                request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
                return;
            }
            
            if (password == null || password.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Password is required.");
                request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
                return;
            }
            
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Full name is required.");
                request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
                return;
            }
            
            if (role == null || role.trim().isEmpty()) {
                request.setAttribute("errorMessage", "User role is required.");
                request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
                return;
            }
            
            // Create user object
            User user = new User();
            user.setUsername(username.trim());
            user.setPassword(password);
            user.setRole(role);
            user.setFullName(fullName.trim());
            
            // Handle optional fields
            if (email != null && !email.trim().isEmpty()) {
                user.setEmail(email.trim());
            }
            
            if (phone != null && !phone.trim().isEmpty()) {
                user.setPhone(phone.trim());
            }
            
            // Add user to database
            userService.addUser(user);
            
            // Set success message in session for redirect
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "User '" + username + "' has been successfully created.");
            
            // Redirect to user list
            response.sendRedirect("user?action=list");
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding user: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("id");
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid user ID.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            int userId = Integer.parseInt(userIdParam);
            User user = userService.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("WEB-INF/view/user/editUser.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "User not found.");
                response.sendRedirect("user?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID format.");
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            response.sendRedirect("user?action=list");
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get form parameters
            String userIdParam = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            
            // Basic validation
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Invalid user ID.");
                showEditForm(request, response);
                return;
            }
            
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Full name is required.");
                showEditForm(request, response);
                return;
            }
            
            if (role == null || role.trim().isEmpty()) {
                request.setAttribute("errorMessage", "User role is required.");
                showEditForm(request, response);
                return;
            }
            
            int userId = Integer.parseInt(userIdParam);
            
            // Get existing user data first
            User existingUser = userService.getUserById(userId);
            if (existingUser == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "User not found.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            // Create updated user object
            User user = new User();
            user.setUserId(userId);
            user.setUsername(existingUser.getUsername()); // Keep original username
            user.setPassword(existingUser.getPassword()); // Keep original password
            user.setRole(role);
            user.setFullName(fullName.trim());
            user.setCreatedDate(existingUser.getCreatedDate()); // Keep original created date
            
            // Handle optional fields
            if (email != null && !email.trim().isEmpty()) {
                user.setEmail(email.trim());
            } else {
                user.setEmail(null);
            }
            
            if (phone != null && !phone.trim().isEmpty()) {
                user.setPhone(phone.trim());
            } else {
                user.setPhone(null);
            }
            
            // Update user in database
            userService.updateUser(user);
            
            // Set success message in session for redirect
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "User '" + existingUser.getUsername() + "' has been successfully updated.");
            
            // Redirect to user list
            response.sendRedirect("user?action=list");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid user ID format.");
            showEditForm(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating user: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("id");
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid user ID.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            int userId = Integer.parseInt(userIdParam);
            
            // Check if trying to delete self
            HttpSession session = request.getSession();
            User loggedUser = (User) session.getAttribute("loggedUser");
            
            if (loggedUser.getUserId() == userId) {
                session.setAttribute("errorMessage", "You cannot delete your own account.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            // Get user info before deletion for success message
            User userToDelete = userService.getUserById(userId);
            if (userToDelete == null) {
                session.setAttribute("errorMessage", "User not found.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            // Delete user
            userService.deleteUser(userId);
            
            // Set success message
            session.setAttribute("successMessage", "User '" + userToDelete.getUsername() + "' has been successfully deleted.");
            
            // Redirect to user list
            response.sendRedirect("user?action=list");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID format.");
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting user: " + e.getMessage());
            response.sendRedirect("user?action=list");
        }
    }
    
    private void viewUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("id");
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid user ID.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            int userId = Integer.parseInt(userIdParam);
            User user = userService.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("WEB-INF/view/user/viewUser.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "User not found.");
                response.sendRedirect("user?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID format.");
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}