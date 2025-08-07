// CustomerPortalController.java
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
import com.redupahana.model.Bill;
import com.redupahana.model.BillItem;
import com.redupahana.model.User;
import com.redupahana.service.BillService;
import com.redupahana.service.UserService;
import com.redupahana.service.BookService;

@WebServlet("/customerPortal")
public class CustomerPortalController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private BillService billService;
    private UserService userService;
    private BookService bookService;
    
    public void init() throws ServletException {
        billService = BillService.getInstance();
        userService = UserService.getInstance();
        bookService = BookService.getInstance();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if customer is logged in
        HttpSession session = request.getSession();
        Customer loggedCustomer = (Customer) session.getAttribute("loggedCustomer");
        String loginType = (String) session.getAttribute("loginType");
        
        if (loggedCustomer == null || !"customer".equals(loginType)) {
            response.sendRedirect("auth");
            return;
        }
        
        // Load all customer data at once
        loadAllCustomerData(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Customer portal is read-only, redirect to main portal
        response.sendRedirect("customerPortal");
    }
    
    private void loadAllCustomerData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Customer loggedCustomer = (Customer) session.getAttribute("loggedCustomer");
            
            // Get all customer bills
            List<Bill> allCustomerBills = billService.getBillsByCustomer(loggedCustomer.getCustomerId());
            
            // Get recent bills (last 5)
            List<Bill> recentBills = allCustomerBills;
            if (allCustomerBills.size() > 5) {
                recentBills = allCustomerBills.subList(0, 5);
            }
            
            // Calculate dashboard statistics
            int totalBills = allCustomerBills.size();
            double totalAmount = 0;
            double totalPaid = 0;
            int pendingBills = 0;
            int totalBooks = 0;
            
            for (Bill bill : allCustomerBills) {
                totalAmount += bill.getTotalAmount();
                if ("PAID".equals(bill.getPaymentStatus())) {
                    totalPaid += bill.getTotalAmount();
                } else if ("PENDING".equals(bill.getPaymentStatus())) {
                    pendingBills++;
                }
                
                // Count total books
                if (bill.getBillItems() != null) {
                    for (BillItem item : bill.getBillItems()) {
                        totalBooks += item.getQuantity();
                    }
                }
            }
            
            // Calculate average order value
            double averageOrderValue = 0;
            if (totalBills > 0) {
                averageOrderValue = totalAmount / totalBills;
            }
            
            // Find most recent bill
            Bill lastOrder = null;
            if (!allCustomerBills.isEmpty()) {
                lastOrder = allCustomerBills.get(0); // Bills are ordered by date DESC
            }
            
            // Get cashier details for all bills
            for (Bill bill : allCustomerBills) {
                try {
                    User cashier = userService.getUserById(bill.getCashierId());
                    if (cashier != null) {
                        bill.setCashierName(cashier.getFullName());
                    }
                } catch (Exception e) {
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                // Get book details for all bill items
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            com.redupahana.model.Book book = bookService.getBookById(billItem.getBookId());
                            if (book != null) {
                                billItem.setBookTitle(book.getTitle());
                                billItem.setAuthor(book.getAuthor());
                                billItem.setBookCode(book.getBookCode());
                                billItem.setIsbn(book.getIsbn());
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading book details for ID " + billItem.getBookId() + ": " + e.getMessage());
                        }
                    }
                }
            }
            
            // Set all data for the single portal page
            request.setAttribute("customer", loggedCustomer);
            
            // Dashboard data
            request.setAttribute("recentBills", recentBills);
            request.setAttribute("totalBills", totalBills);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("totalPaid", totalPaid);
            request.setAttribute("pendingBills", pendingBills);
            request.setAttribute("pendingAmount", totalAmount - totalPaid);
            
            // Profile data
            request.setAttribute("totalOrders", totalBills);
            request.setAttribute("totalSpent", totalAmount);
            request.setAttribute("averageOrderValue", averageOrderValue);
            request.setAttribute("totalBooks", totalBooks);
            request.setAttribute("lastOrder", lastOrder);
            
            // Bills data
            request.setAttribute("allBills", allCustomerBills);
            
            // Check for messages in session
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }
            
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage");
            }
            
            // Forward to single customer portal page
            request.getRequestDispatcher("WEB-INF/view/dashboard/customerPortal.jsp").forward(request, response);
            
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error loading customer data: " + e.getMessage());
            request.setAttribute("errorMessage", "Error loading customer data: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/dashboard/customerPortal.jsp").forward(request, response);
        }
    }
}