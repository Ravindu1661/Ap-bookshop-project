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
import com.redupahana.model.Item;
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
            Item item = new Item();
            item.setItemCode(request.getParameter("itemCode"));
            item.setName(request.getParameter("name"));
            item.setDescription(request.getParameter("description"));
            item.setPrice(Double.parseDouble(request.getParameter("price")));
            item.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity")));
            item.setCategory(request.getParameter("category"));
            
            itemService.addItem(item);
            request.setAttribute("successMessage", Constants.SUCCESS_ADD);
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding item: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/item/addItem.jsp").forward(request, response);
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("id"));
            Item item = itemService.getItemById(itemId);
            
            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("WEB-INF/view/item/editItem.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading item: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void updateItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            Item item = new Item();
            item.setItemId(Integer.parseInt(request.getParameter("itemId")));
            item.setName(request.getParameter("name"));
            item.setDescription(request.getParameter("description"));
            item.setPrice(Double.parseDouble(request.getParameter("price")));
            item.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity")));
            item.setCategory(request.getParameter("category"));
            
            itemService.updateItem(item);
            request.setAttribute("successMessage", Constants.SUCCESS_UPDATE);
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating item: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("id"));
            itemService.deleteItem(itemId);
            request.setAttribute("successMessage", Constants.SUCCESS_DELETE);
            response.sendRedirect("item?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error deleting item: " + e.getMessage());
            response.sendRedirect("item?action=list");
        }
    }
    
    private void searchItems(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            List<Item> items = itemService.searchItems(searchTerm);
            request.setAttribute("items", items);
            request.setAttribute("searchTerm", searchTerm);
            request.getRequestDispatcher("WEB-INF/view/item/listItems.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching items: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void viewItem(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("id"));
            Item item = itemService.getItemById(itemId);
            
            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("WEB-INF/view/item/viewItem.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading item: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}