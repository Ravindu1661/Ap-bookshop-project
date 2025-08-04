
// BillController.java
package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.redupahana.model.Bill;
import com.redupahana.model.BillItem;
import com.redupahana.model.Customer;
import com.redupahana.model.Item;
import com.redupahana.model.User;
import com.redupahana.service.BillService;
import com.redupahana.service.CustomerService;
import com.redupahana.service.ItemService;
import com.redupahana.util.Constants;

@WebServlet("/bill")
public class BillController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private BillService billService;
    private CustomerService customerService;
    private ItemService itemService;
    
    public void init() throws ServletException {
        billService = BillService.getInstance();
        customerService = CustomerService.getInstance();
        itemService = ItemService.getInstance();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listBills(request, response);
        } else if (action.equals("create")) {
            showCreateForm(request, response);
        } else if (action.equals("view")) {
            viewBill(request, response);
        } else if (action.equals("print")) {
            printBill(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action.equals("create")) {
            createBill(request, response);
        }
    }
    
    private void listBills(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Bill> bills = billService.getAllBills();
            request.setAttribute("bills", bills);
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bills: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Customer> customers = customerService.getAllCustomers();
            List<Item> items = itemService.getAllItems();
            
            request.setAttribute("customers", customers);
            request.setAttribute("items", items);
            request.getRequestDispatcher("WEB-INF/view/bill/createBill.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void createBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User loggedUser = (User) session.getAttribute("loggedUser");
            
            Bill bill = new Bill();
            bill.setCustomerId(Integer.parseInt(request.getParameter("customerId")));
            bill.setCashierId(loggedUser.getUserId());
            bill.setDiscount(Double.parseDouble(request.getParameter("discount")));
            bill.setPaymentStatus(Constants.PAYMENT_PAID);
            
            // Get bill items from request
            String[] itemIds = request.getParameterValues("itemId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");
            
            List<BillItem> billItems = new ArrayList<>();
            if (itemIds != null) {
                for (int i = 0; i < itemIds.length; i++) {
                    if (!itemIds[i].isEmpty() && !quantities[i].isEmpty()) {
                        BillItem billItem = new BillItem();
                        billItem.setItemId(Integer.parseInt(itemIds[i]));
                        billItem.setQuantity(Integer.parseInt(quantities[i]));
                        billItem.setUnitPrice(Double.parseDouble(unitPrices[i]));
                        billItems.add(billItem);
                    }
                }
            }
            
            int billId = billService.createBill(bill, billItems);
            request.setAttribute("successMessage", "Bill created successfully");
            response.sendRedirect("bill?action=view&id=" + billId);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error creating bill: " + e.getMessage());
            showCreateForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            showCreateForm(request, response);
        }
    }
    
    private void viewBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int billId = Integer.parseInt(request.getParameter("id"));
            Bill bill = billService.getBillById(billId);
            
            if (bill != null) {
                request.setAttribute("bill", bill);
                request.getRequestDispatcher("WEB-INF/view/bill/viewBill.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bill: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void printBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int billId = Integer.parseInt(request.getParameter("id"));
            Bill bill = billService.getBillById(billId);
            
            if (bill != null) {
                request.setAttribute("bill", bill);
                request.getRequestDispatcher("WEB-INF/view/bill/printBill.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", Constants.ERROR_NOT_FOUND);
                request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bill: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}