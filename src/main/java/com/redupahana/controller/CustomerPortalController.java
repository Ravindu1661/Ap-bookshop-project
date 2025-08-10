// CustomerPortalController.java - Enhanced with Base64 Image & Category Support
package com.redupahana.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
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
import com.redupahana.model.Book;
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
            Map<String, Integer> categoryStats = new HashMap<>();
            Map<String, Integer> authorStats = new HashMap<>();
            String favoriteCategory = "";
            String favoriteAuthor = "";
            
            for (Bill bill : allCustomerBills) {
                totalAmount += bill.getTotalAmount();
                if ("PAID".equals(bill.getPaymentStatus())) {
                    totalPaid += bill.getTotalAmount();
                } else if ("PENDING".equals(bill.getPaymentStatus())) {
                    pendingBills++;
                }
                
                // Count total books and analyze categories/authors
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
            
            // Enhanced data loading for bills with complete book information
            for (Bill bill : allCustomerBills) {
                try {
                    // Load cashier details
                    User cashier = userService.getUserById(bill.getCashierId());
                    if (cashier != null) {
                        bill.setCashierName(cashier.getFullName());
                    }
                } catch (Exception e) {
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                // Enhanced book details loading with Base64 image and category support
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            Book book = bookService.getBookById(billItem.getBookId());
                            if (book != null) {
                                // Set comprehensive book details
                                billItem.setBookTitle(book.getTitle());
                                billItem.setAuthor(book.getAuthor());
                                billItem.setBookCode(book.getBookCode());
                                billItem.setIsbn(book.getIsbn());
                                billItem.setPublisher(book.getPublisher());
                                billItem.setLanguage(book.getLanguage());
                                billItem.setPages(book.getPages());
                                billItem.setPublicationYear(book.getPublicationYear());
                                
                                // UPDATED: Set Base64 image instead of image path
                                billItem.setImageBase64(book.getImageBase64());
                                
                                // UPDATED: Set book category
                                billItem.setBookCategory(book.getBookCategory());
                                
                                // Track category statistics for customer preferences
                                String category = book.getBookCategory();
                                if (category != null && !category.trim().isEmpty()) {
                                    categoryStats.put(category, 
                                        categoryStats.getOrDefault(category, 0) + billItem.getQuantity());
                                }
                                
                                // Track author statistics
                                String author = book.getAuthor();
                                if (author != null && !author.trim().isEmpty()) {
                                    authorStats.put(author, 
                                        authorStats.getOrDefault(author, 0) + billItem.getQuantity());
                                }
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading book details for ID " + billItem.getBookId() + ": " + e.getMessage());
                        }
                    }
                }
            }
            
            // Find favorite category and author
            if (!categoryStats.isEmpty()) {
                favoriteCategory = categoryStats.entrySet().stream()
                    .max(Map.Entry.comparingByValue())
                    .get().getKey();
            }
            
            if (!authorStats.isEmpty()) {
                favoriteAuthor = authorStats.entrySet().stream()
                    .max(Map.Entry.comparingByValue())
                    .get().getKey();
            }
            
            // Calculate additional statistics
            int totalUniqueBooks = 0;
            for (Bill bill : allCustomerBills) {
                if (bill.getBillItems() != null) {
                    totalUniqueBooks += bill.getBillItems().size();
                }
            }
            
            // Calculate books by language
            Map<String, Integer> languageStats = new HashMap<>();
            for (Bill bill : allCustomerBills) {
                if (bill.getBillItems() != null) {
                    for (BillItem item : bill.getBillItems()) {
                        String language = item.getLanguage();
                        if (language != null && !language.trim().isEmpty()) {
                            languageStats.put(language, 
                                languageStats.getOrDefault(language, 0) + item.getQuantity());
                        }
                    }
                }
            }
            
            // Set all data for the single portal page
            request.setAttribute("customer", loggedCustomer);
            
            // Enhanced dashboard data
            request.setAttribute("recentBills", recentBills);
            request.setAttribute("totalBills", totalBills);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("totalPaid", totalPaid);
            request.setAttribute("pendingBills", pendingBills);
            request.setAttribute("pendingAmount", totalAmount - totalPaid);
            
            // Enhanced profile data with reading preferences
            request.setAttribute("totalOrders", totalBills);
            request.setAttribute("totalSpent", totalAmount);
            request.setAttribute("averageOrderValue", averageOrderValue);
            request.setAttribute("totalBooks", totalBooks);
            request.setAttribute("totalUniqueBooks", totalUniqueBooks);
            request.setAttribute("lastOrder", lastOrder);
            request.setAttribute("favoriteCategory", favoriteCategory);
            request.setAttribute("favoriteAuthor", favoriteAuthor);
            request.setAttribute("categoryStats", categoryStats);
            request.setAttribute("authorStats", authorStats);
            request.setAttribute("languageStats", languageStats);
            
            // Bills data with enhanced book information
            request.setAttribute("allBills", allCustomerBills);
            
            // Calculate and set additional insights
            if (totalBills > 0) {
                // Calculate average books per order
                double avgBooksPerOrder = (double) totalBooks / totalBills;
                request.setAttribute("avgBooksPerOrder", avgBooksPerOrder);
                
                // Calculate reading frequency (orders per month)
                // This is a simplified calculation - you might want to make it more sophisticated
                double ordersPerMonth = totalBills / 12.0; // Assuming data for 1 year
                request.setAttribute("ordersPerMonth", ordersPerMonth);
                
                // Find most expensive order
                Bill mostExpensiveOrder = allCustomerBills.stream()
                    .max((b1, b2) -> Double.compare(b1.getTotalAmount(), b2.getTotalAmount()))
                    .orElse(null);
                request.setAttribute("mostExpensiveOrder", mostExpensiveOrder);
                
                // Find order with most books
                Bill mostBooksOrder = allCustomerBills.stream()
                    .max((b1, b2) -> Integer.compare(b1.getTotalBooksCount(), b2.getTotalBooksCount()))
                    .orElse(null);
                request.setAttribute("mostBooksOrder", mostBooksOrder);
            }
            
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
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
            request.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/dashboard/customerPortal.jsp").forward(request, response);
        }
    }
}