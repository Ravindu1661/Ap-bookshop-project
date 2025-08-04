// ItemController.java
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
import com.redupahana.model.Item;
import com.redupahana.model.User;
import com.redupahana.service.ItemService;
import com.redupahana.util.Constants;

@WebServlet("/item")
public class ItemController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ItemService itemService;
    
    public void init() throws ServletException {
        itemService = ItemService.getInstance();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listItems(request, response);
        } else if (action.equals("add")) {
            showAddForm(request, response);
        } else if (action.equals("edit")) {
            showEditForm(request, response);
        } else if (action.equals("delete")) {
            deleteItem(request, response);
        } else if (action.equals("search")) {
            searchItems(request, response);
        } else if (action.equals("view")) {
            viewItem(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("auth");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action.equals("add")) {
            addItem(request, response);
        } else if (action.equals("update")) {
            updateItem(request, response);
        }
    }
    
    private void listItems(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Item> items = itemService.getAllItems();
            request.setAttribute("items", items);
            
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
            
            request.getRequestDispatcher("WEB-INF/view/item/listItems.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading items: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
    }
    
    private void addItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get form parameters
            String itemCode = request.getParameter("itemCode");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String category = request.getParameter("category");
            
            // Basic validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Item name is required.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            if (priceStr == null || priceStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Price is required.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            if (stockStr == null || stockStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Stock quantity is required.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            if (category == null || category.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Category is required.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            double price;
            int stockQuantity;
            
            try {
                price = Double.parseDouble(priceStr);
                if (price <= 0) {
                    request.setAttribute("errorMessage", "Price must be greater than 0.");
                    request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid price format.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            try {
                stockQuantity = Integer.parseInt(stockStr);
                if (stockQuantity < 0) {
                    request.setAttribute("errorMessage", "Stock quantity cannot be negative.");
                    request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid stock quantity format.");
                request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
                return;
            }
            
            // Create item object
            Item item = new Item();
            
            // Handle item code (auto-generate if empty)
            if (itemCode != null && !itemCode.trim().isEmpty()) {
                item.setItemCode(itemCode.trim());
            }
            
            item.setName(name.trim());
            item.setPrice(price);
            item.setStockQuantity(stockQuantity);
            item.setCategory(category);
            
            // Handle optional description
            if (description != null && !description.trim().isEmpty()) {
                item.setDescription(description.trim());
            }
            
            // Add item to database
            itemService.addItem(item);
            
            // Set success message in session for redirect
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Item '" + name + "' has been successfully added to inventory.");
            
            // Redirect to item list
            response.sendRedirect("item?action=list");
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding item: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String itemIdParam = request.getParameter("id");
            if (itemIdParam == null || itemIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid item ID.");
                response.sendRedirect("item?action=list");
                return;
            }
            
            int itemId = Integer.parseInt(itemIdParam);
            Item item = itemService.getItemById(itemId);
            
            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("WEB-INF/view/item/editItem.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Item not found.");
                response.sendRedirect("item?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid item ID format.");
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error loading item: " + e.getMessage());
            response.sendRedirect("item?action=list");
        }
    }
    
    private void updateItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Get form parameters
            String itemIdParam = request.getParameter("itemId");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String category = request.getParameter("category");
            
            // Basic validation
            if (itemIdParam == null || itemIdParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Invalid item ID.");
                showEditForm(request, response);
                return;
            }
            
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Item name is required.");
                showEditForm(request, response);
                return;
            }
            
            if (priceStr == null || priceStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Price is required.");
                showEditForm(request, response);
                return;
            }
            
            if (stockStr == null || stockStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Stock quantity is required.");
                showEditForm(request, response);
                return;
            }
            
            if (category == null || category.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Category is required.");
                showEditForm(request, response);
                return;
            }
            
            int itemId = Integer.parseInt(itemIdParam);
            double price = Double.parseDouble(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);
            
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                showEditForm(request, response);
                return;
            }
            
            if (stockQuantity < 0) {
                request.setAttribute("errorMessage", "Stock quantity cannot be negative.");
                showEditForm(request, response);
                return;
            }
            
            // Get existing item data first
            Item existingItem = itemService.getItemById(itemId);
            if (existingItem == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Item not found.");
                response.sendRedirect("item?action=list");
                return;
            }
            
            // Create updated item object
            Item item = new Item();
            item.setItemId(itemId);
            item.setItemCode(existingItem.getItemCode()); // Keep original item code
            item.setName(name.trim());
            item.setPrice(price);
            item.setStockQuantity(stockQuantity);
            item.setCategory(category);
            item.setCreatedDate(existingItem.getCreatedDate()); // Keep original created date
            
            // Handle optional description
            if (description != null && !description.trim().isEmpty()) {
                item.setDescription(description.trim());
            } else {
                item.setDescription(null);
            }
            
            // Update item in database
            itemService.updateItem(item);
            
            // Set success message in session for redirect
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Item '" + name + "' has been successfully updated.");
            
            // Redirect to item list
            response.sendRedirect("item?action=list");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format in form data.");
            showEditForm(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating item: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String itemIdParam = request.getParameter("id");
            if (itemIdParam == null || itemIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid item ID.");
                response.sendRedirect("item?action=list");
                return;
            }
            
            int itemId = Integer.parseInt(itemIdParam);
            
            // Get item info before deletion for success message
            Item itemToDelete = itemService.getItemById(itemId);
            if (itemToDelete == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Item not found.");
                response.sendRedirect("item?action=list");
                return;
            }
            
            // Delete item
            itemService.deleteItem(itemId);
            
            // Set success message
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Item '" + itemToDelete.getName() + "' has been successfully deleted.");
            
            // Redirect to item list
            response.sendRedirect("item?action=list");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid item ID format.");
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting item: " + e.getMessage());
            response.sendRedirect("item?action=list");
        }
    }
    
    private void searchItems(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                // If search term is empty, redirect to list all items
                response.sendRedirect("item?action=list");
                return;
            }
            
            List<Item> items = itemService.searchItems(searchTerm.trim());
            request.setAttribute("items", items);
            request.setAttribute("searchTerm", searchTerm.trim());
            
            // Add search result message
            if (items.isEmpty()) {
                request.setAttribute("errorMessage", "No items found matching '" + searchTerm + "'.");
            } else {
                request.setAttribute("successMessage", "Found " + items.size() + " item(s) matching '" + searchTerm + "'.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/item/listItems.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching items: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void viewItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String itemIdParam = request.getParameter("id");
            if (itemIdParam == null || itemIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid item ID.");
                response.sendRedirect("item?action=list");
                return;
            }
            
            int itemId = Integer.parseInt(itemIdParam);
            Item item = itemService.getItemById(itemId);
            
            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("WEB-INF/view/item/viewItem.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Item not found.");
                response.sendRedirect("item?action=list");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid item ID format.");
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading item: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}