// UserService.java
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.UserDAO;
import com.redupahana.model.User;
import com.redupahana.util.SecurityUtil;
import com.redupahana.util.ValidationUtil;

public class UserService {
    
    private static UserService instance;
    private UserDAO userDAO;
    
    private UserService() {
        this.userDAO = new UserDAO();
    }
    
    public static UserService getInstance() {
        if (instance == null) {
            synchronized (UserService.class) {
                if (instance == null) {
                    instance = new UserService();
                }
            }
        }
        return instance;
    }
    
    public User authenticateUser(String username, String password) throws SQLException {
        if (!ValidationUtil.isNotEmpty(username) || !ValidationUtil.isNotEmpty(password)) {
            throw new IllegalArgumentException("Username and password are required");
        }
        return userDAO.authenticate(username, password);
    }
    
    public void addUser(User user) throws SQLException {
        validateUser(user);
        // Hash password before storing
        user.setPassword(SecurityUtil.hashPassword(user.getPassword()));
        userDAO.addUser(user);
    }
    
    public List<User> getAllUsers() throws SQLException {
        return userDAO.getAllUsers();
    }
    
    public User getUserById(int userId) throws SQLException {
        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid user ID");
        }
        return userDAO.getUserById(userId);
    }
    
    public User getUserByUsername(String username) throws SQLException {
        if (!ValidationUtil.isNotEmpty(username)) {
            throw new IllegalArgumentException("Username is required");
        }
        return userDAO.getUserByUsername(username);
    }
    
    public void updateUser(User user) throws SQLException {
        validateUserForUpdate(user);
        userDAO.updateUser(user);
    }
    
    public void deleteUser(int userId) throws SQLException {
        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid user ID");
        }
        userDAO.deleteUser(userId);
    }
    
    private void validateUser(User user) {
        if (!ValidationUtil.isNotEmpty(user.getUsername())) {
            throw new IllegalArgumentException("Username is required");
        }
        if (!ValidationUtil.isNotEmpty(user.getPassword())) {
            throw new IllegalArgumentException("Password is required");
        }
        if (!ValidationUtil.isNotEmpty(user.getRole())) {
            throw new IllegalArgumentException("Role is required");
        }
        if (!ValidationUtil.isNotEmpty(user.getFullName())) {
            throw new IllegalArgumentException("Full name is required");
        }
        if (user.getEmail() != null && !ValidationUtil.isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }
        if (user.getPhone() != null && !ValidationUtil.isValidPhone(user.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }
    }
    
    private void validateUserForUpdate(User user) {
        if (user.getUserId() <= 0) {
            throw new IllegalArgumentException("Invalid user ID");
        }
        if (!ValidationUtil.isNotEmpty(user.getUsername())) {
            throw new IllegalArgumentException("Username is required");
        }
        if (!ValidationUtil.isNotEmpty(user.getRole())) {
            throw new IllegalArgumentException("Role is required");
        }
        if (!ValidationUtil.isNotEmpty(user.getFullName())) {
            throw new IllegalArgumentException("Full name is required");
        }
        if (user.getEmail() != null && !ValidationUtil.isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }
        if (user.getPhone() != null && !ValidationUtil.isValidPhone(user.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }
    }
}