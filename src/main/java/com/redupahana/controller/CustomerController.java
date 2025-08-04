
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
            customer.setAccountNumber(request.getParameter("accountNumber"));
            customer.setName(request.getParameter("name"));
            customer.setAddress(request.getParameter("address"));
            customer.setPhone(request.getParameter("phone"));
            customer.setEmail(request.getParameter("email"));
            
            customerService.addCustomer(customer);
            request.setAttribute("successMessage", Constants.SUCCESS_ADD);
            response.sendRedirect("customer?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error adding customer: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/customer/addCustomer.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
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
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customer: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            Customer customer = new Customer();
            customer.setCustomerId(Integer.parseInt(request.getParameter("customerId")));
            customer.setName(request.getParameter("name"));
            customer.setAddress(request.getParameter("address"));
            customer.setPhone(request.getParameter("phone"));
            customer.setEmail(request.getParameter("email"));
            
            customerService.updateCustomer(customer);
            request.setAttribute("successMessage", Constants.SUCCESS_UPDATE);
            response.sendRedirect("customer?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating customer: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            showEditForm(request, response);
        }
    }
    
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            customerService.deleteCustomer(customerId);
            request.setAttribute("successMessage", Constants.SUCCESS_DELETE);
            response.sendRedirect("customer?action=list");
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error deleting customer: " + e.getMessage());
            response.sendRedirect("customer?action=list");
        }
    }
    
    private void searchCustomers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            List<Customer> customers = customerService.searchCustomers(searchTerm);
            request.setAttribute("customers", customers);
            request.setAttribute("searchTerm", searchTerm);
            request.getRequestDispatcher("WEB-INF/view/customer/listCustomers.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching customers: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
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
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customer: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}
