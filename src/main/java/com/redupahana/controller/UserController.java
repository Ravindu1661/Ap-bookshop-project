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
            User user = new User();
            user.setUsername(request.getParameter("username"));
            user.setPassword(request.getParameter("password"));
            user.setRole(request.getParameter("role"));
            user.setFullName(request.getParameter("fullName"));
            user.setEmail(request.getParameter("email"));
            user.setPhone(request.getParameter("phone"));
            
            userService.addUser(user);
            request.setAttribute("successMessage", Constants.SUCCESS_ADD);
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding user: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/user/addUser.jsp").forward(request, response);
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User user = userService.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("WEB-INF/view/user/editUser.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            User user = new User();
            user.setUserId(Integer.parseInt(request.getParameter("userId")));
            user.setUsername(request.getParameter("username"));
            user.setRole(request.getParameter("role"));
            user.setFullName(request.getParameter("fullName"));
            user.setEmail(request.getParameter("email"));
            user.setPhone(request.getParameter("phone"));
            
            userService.updateUser(user);
            request.setAttribute("successMessage", Constants.SUCCESS_UPDATE);
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating user: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            
            // Check if trying to delete self
            HttpSession session = request.getSession();
            User loggedUser = (User) session.getAttribute("loggedUser");
            
            if (loggedUser.getUserId() == userId) {
                request.setAttribute("errorMessage", "You cannot delete your own account.");
                response.sendRedirect("user?action=list");
                return;
            }
            
            userService.deleteUser(userId);
            request.setAttribute("successMessage", Constants.SUCCESS_DELETE);
            response.sendRedirect("user?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error deleting user: " + e.getMessage());
            response.sendRedirect("user?action=list");
        }
    }
    
    private void viewUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User user = userService.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("WEB-INF/view/user/viewUser.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}