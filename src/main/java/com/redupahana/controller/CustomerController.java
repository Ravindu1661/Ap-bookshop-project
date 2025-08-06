// CustomerController.java
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
import com.redupahana.model.Customer;
import com.redupahana.service.CustomerService;
import com.redupahana.util.Constants;

@WebServlet("/customer")
public class CustomerController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CustomerService customerService;
    
    public void init() throws ServletException {
        customerService = CustomerService.getInstance();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listCustomers(request, response);
        } else if (action.equals("add")) {
            showAddForm(request, response);
        } else if (action.equals("edit")) {
            showEditForm(request, response);
        } else if (action.equals("delete")) {
            deleteCustomer(request, response);
        } else if (action.equals("search")) {
            searchCustomers(request, response);
        } else if (action.equals("view")) {
            viewCustomer(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action.equals("add")) {
            addCustomer(request, response);
        } else if (action.equals("update")) {
            updateCustomer(request, response);
        }
    }
    
    private void listCustomers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Customer> customers = customerService.getAllCustomers();
            request.setAttribute("customers", customers);
            
            // Check for success message in session and display it
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage"); // Remove after displaying
            }
            
            request.getRequestDispatcher("WEB-INF/view/customer/listCustomers.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customers: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/view/customer/addCustomer.jsp").forward(request, response);
    }
    
    private void addCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            Customer customer = new Customer();
            
            // Get form data
            String accountNumber = request.getParameter("accountNumber");
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            
            // Set customer data
            customer.setAccountNumber(accountNumber != null && !accountNumber.trim().isEmpty() ? accountNumber.trim() : null);
            customer.setName(name != null ? name.trim() : "");
            customer.setAddress(address != null && !address.trim().isEmpty() ? address.trim() : null);
            customer.setPhone(phone != null ? phone.trim() : "");
            customer.setEmail(email != null && !email.trim().isEmpty() ? email.trim() : null);
            
            // Add customer through service
            customerService.addCustomer(customer);
            
            // Set success message in session
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Customer '" + customer.getName() + "' has been added successfully!");
            
            // Redirect to customer list
            response.sendRedirect("customer?action=list");
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/customer/addCustomer.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Validation Error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/customer/addCustomer.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Unexpected Error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/customer/addCustomer.jsp").forward(request, response);
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            Customer customer = customerService.getCustomerById(customerId);
            
            if (customer != null) {
                request.setAttribute("customer", customer);
                request.getRequestDispatcher("WEB-INF/view/customer/editCustomer.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customer: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            Customer customer = new Customer();
            
            // Get form data
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            
            // Set customer data
            customer.setCustomerId(customerId);
            customer.setName(name != null ? name.trim() : "");
            customer.setAddress(address != null && !address.trim().isEmpty() ? address.trim() : null);
            customer.setPhone(phone != null ? phone.trim() : "");
            customer.setEmail(email != null && !email.trim().isEmpty() ? email.trim() : null);
            
            customerService.updateCustomer(customer);
            
            // Set success message in session
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Customer '" + customer.getName() + "' has been updated successfully!");
            
            response.sendRedirect("customer?action=list");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            showEditForm(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
            showEditForm(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Validation Error: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Unexpected Error: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            
            // Get customer details before deletion for success message
            Customer customer = customerService.getCustomerById(customerId);
            String customerName = customer != null ? customer.getName() : "Customer";
            
            customerService.deleteCustomer(customerId);
            
            // Set success message in session
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Customer '" + customerName + "' has been deleted successfully!");
            
            response.sendRedirect("customer?action=list");
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid customer ID format");
            response.sendRedirect("customer?action=list");
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting customer: " + e.getMessage());
            response.sendRedirect("customer?action=list");
        }
    }
    
    private void searchCustomers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                // If no search term, show all customers
                listCustomers(request, response);
                return;
            }
            
            List<Customer> customers = customerService.searchCustomers(searchTerm.trim());
            request.setAttribute("customers", customers);
            request.setAttribute("searchTerm", searchTerm.trim());
            
            // Add search result message
            if (customers.isEmpty()) {
                request.setAttribute("infoMessage", "No customers found matching '" + searchTerm + "'");
            } else {
                request.setAttribute("infoMessage", "Found " + customers.size() + " customer(s) matching '" + searchTerm + "'");
            }
            
            request.getRequestDispatcher("WEB-INF/view/customer/listCustomers.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching customers: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Search Error: " + e.getMessage());
            listCustomers(request, response);
        }
    }
    
    private void viewCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            Customer customer = customerService.getCustomerById(customerId);
            
            if (customer != null) {
                request.setAttribute("customer", customer);
                request.getRequestDispatcher("WEB-INF/view/customer/viewCustomer.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customer: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}