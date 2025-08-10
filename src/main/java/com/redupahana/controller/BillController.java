// BillController.java - Enhanced with Base64 Image Support
package com.redupahana.controller;

import com.redupahana.service.UserService;
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
import com.redupahana.model.Book;
import com.redupahana.model.User;
import com.redupahana.service.BillService;
import com.redupahana.service.CustomerService;
import com.redupahana.service.BookService;
import com.redupahana.util.Constants;

@WebServlet("/bill")
public class BillController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private BillService billService;
    private CustomerService customerService;
    private BookService bookService;
    private UserService userService;
    
    public void init() throws ServletException {
        billService = BillService.getInstance();
        customerService = CustomerService.getInstance();
        bookService = BookService.getInstance();
        userService = UserService.getInstance();
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
            listBills(request, response);
        } else if (action.equals("create")) {
            showCreateForm(request, response);
        } else if (action.equals("view")) {
            viewBill(request, response);
        } else if (action.equals("print")) {
            printBill(request, response);
        } else if (action.equals("search")) {
            searchBills(request, response);
        } else if (action.equals("delete")) {
            deleteBill(request, response);
        } else if (action.equals("updatePaymentStatus")) {
            showUpdatePaymentStatusForm(request, response);
        } else if (action.equals("customerBills")) {
            viewCustomerBills(request, response);
        } else if (action.equals("cashierBills")) {
            viewCashierBills(request, response);
        } else if (action.equals("pendingPayments")) {
            viewPendingPayments(request, response);
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
        
        if (action.equals("create")) {
            createBill(request, response);
        } else if (action.equals("updatePaymentStatus")) {
            updatePaymentStatus(request, response);
        }
    }
    
    private void listBills(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Bill> bills = billService.getAllBills();
            request.setAttribute("bills", bills);
            
            // Check for success messages in session
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }
            
            // Check for error messages in session
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage");
            }
            
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
            List<Book> books = bookService.getAllBooks();
            
            // Filter only active books with stock > 0
            books = books.stream()
                    .filter(book -> book.isActive() && book.getStockQuantity() > 0)
                    .collect(java.util.stream.Collectors.toList());
            
            // Get all book categories for filtering
            List<String> bookCategories = bookService.getAllBookCategories();
            
            request.setAttribute("customers", customers);
            request.setAttribute("books", books);
            request.setAttribute("bookCategories", bookCategories);
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
            
            // Get form parameters
            String customerIdParam = request.getParameter("customerId");
            String discountParam = request.getParameter("discount");
            String paymentStatus = request.getParameter("paymentStatus");
            
            // Basic validation
            if (customerIdParam == null || customerIdParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer is required.");
                showCreateForm(request, response);
                return;
            }
            
            int customerId;
            double discount = 0;
            
            try {
                customerId = Integer.parseInt(customerIdParam);
                if (customerId <= 0) {
                    request.setAttribute("errorMessage", "Invalid customer selection.");
                    showCreateForm(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid customer selection.");
                showCreateForm(request, response);
                return;
            }
            
            if (discountParam != null && !discountParam.trim().isEmpty()) {
                try {
                    discount = Double.parseDouble(discountParam);
                    if (discount < 0) {
                        request.setAttribute("errorMessage", "Discount cannot be negative.");
                        showCreateForm(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid discount format.");
                    showCreateForm(request, response);
                    return;
                }
            }
            
            // Create bill object
            Bill bill = new Bill();
            bill.setCustomerId(customerId);
            bill.setCashierId(loggedUser.getUserId());
            bill.setDiscount(discount);
            bill.setPaymentStatus(paymentStatus != null && !paymentStatus.trim().isEmpty() ? 
                                paymentStatus : Constants.PAYMENT_PAID);
            
            // Get bill items from request
            String[] bookIds = request.getParameterValues("bookId");  // Changed from itemId to bookId
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");
            
            List<BillItem> billItems = new ArrayList<>();
            if (bookIds != null && quantities != null && unitPrices != null) {
                for (int i = 0; i < bookIds.length; i++) {
                    if (i < quantities.length && i < unitPrices.length &&
                        !bookIds[i].trim().isEmpty() && 
                        !quantities[i].trim().isEmpty() && 
                        !unitPrices[i].trim().isEmpty()) {
                        
                        try {
                            int bookId = Integer.parseInt(bookIds[i]);
                            int quantity = Integer.parseInt(quantities[i]);
                            double unitPrice = Double.parseDouble(unitPrices[i]);
                            
                            if (bookId <= 0) {
                                request.setAttribute("errorMessage", "Invalid book selection.");
                                showCreateForm(request, response);
                                return;
                            }
                            
                            if (quantity <= 0) {
                                request.setAttribute("errorMessage", "Quantity must be greater than 0.");
                                showCreateForm(request, response);
                                return;
                            }
                            
                            if (unitPrice <= 0) {
                                request.setAttribute("errorMessage", "Unit price must be greater than 0.");
                                showCreateForm(request, response);
                                return;
                            }
                            
                            BillItem billItem = new BillItem();
                            billItem.setBookId(bookId);
                            billItem.setQuantity(quantity);
                            billItem.setUnitPrice(unitPrice);
                            billItems.add(billItem);
                        } catch (NumberFormatException e) {
                            request.setAttribute("errorMessage", "Invalid number format in book data.");
                            showCreateForm(request, response);
                            return;
                        }
                    }
                }
            }
            
            if (billItems.isEmpty()) {
                request.setAttribute("errorMessage", "At least one book is required.");
                showCreateForm(request, response);
                return;
            }
            
            // Create bill
            int billId = billService.createBill(bill, billItems);
            
            // Get the created bill for success message
            Bill createdBill = billService.getBillById(billId);
            
            // Set success message
            session.setAttribute("successMessage", 
                "📄 Bill #" + createdBill.getBillNumber() + " has been successfully created. " +
                "Total Amount: Rs. " + String.format("%.2f", createdBill.getTotalAmount()) + 
                " | Books: " + createdBill.getTotalBooksCount());
            
            response.sendRedirect("bill?action=view&id=" + billId);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error creating bill: " + e.getMessage());
            showCreateForm(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            showCreateForm(request, response);
        }
    }
    
    private void viewBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String billIdParam = request.getParameter("id");
            if (billIdParam == null || billIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            int billId;
            try {
                billId = Integer.parseInt(billIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            Bill bill = billService.getBillById(billId);
            
            if (bill != null) {
                // Get customer details
                Customer customer = null;
                try {
                    customer = customerService.getCustomerById(bill.getCustomerId());
                } catch (SQLException e) {
                    // Log error but continue - customer details will show as "not available"
                    System.err.println("Error loading customer details: " + e.getMessage());
                }
                
                // Get cashier details
                User cashier = null;
                try {
                    cashier = userService.getUserById(bill.getCashierId());
                } catch (Exception e) {
                    // Log error but continue - cashier details will show as "not available"
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            // Enhanced book details loading with Base64 image support
                            if (billItem.getBookTitle() == null || billItem.getBookTitle().trim().isEmpty()) {
                                Book book = bookService.getBookById(billItem.getBookId());
                                if (book != null) {
                                    // UPDATED: Set all book details including Base64 image
                                    billItem.setBookTitle(book.getTitle());
                                    billItem.setAuthor(book.getAuthor());
                                    billItem.setBookCode(book.getBookCode());
                                    billItem.setIsbn(book.getIsbn());
                                    billItem.setPublisher(book.getPublisher());
                                    billItem.setLanguage(book.getLanguage());
                                    billItem.setPages(book.getPages());
                                    billItem.setPublicationYear(book.getPublicationYear());
                                    billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64 support
                                    billItem.setBookCategory(book.getBookCategory());
                                }
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading book details for ID " + billItem.getBookId() + ": " + e.getMessage());
                            // Continue without book details - will use book ID instead
                        }
                    }
                }
                
                // Set attributes for JSP
                request.setAttribute("bill", bill);
                request.setAttribute("customer", customer);
                request.setAttribute("cashier", cashier);
                
                // Check for success messages in session
                HttpSession session = request.getSession();
                String successMessage = (String) session.getAttribute("successMessage");
                if (successMessage != null) {
                    request.setAttribute("successMessage", successMessage);
                    session.removeAttribute("successMessage");
                }
                
                // Check for error messages in session
                String errorMessage = (String) session.getAttribute("errorMessage");
                if (errorMessage != null) {
                    request.setAttribute("errorMessage", errorMessage);
                    session.removeAttribute("errorMessage");
                }
                
                request.getRequestDispatcher("WEB-INF/view/bill/viewBill.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("bill?action=list");
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bill: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void printBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String billIdParam = request.getParameter("id");
            if (billIdParam == null || billIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            int billId;
            try {
                billId = Integer.parseInt(billIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            Bill bill = billService.getBillById(billId);
            
            if (bill != null) {
                // Get customer details
                Customer customer = null;
                try {
                    customer = customerService.getCustomerById(bill.getCustomerId());
                } catch (SQLException e) {
                    // Customer details not found, but continue with bill printing
                    System.err.println("Error loading customer details: " + e.getMessage());
                }
                
                // Get cashier details
                User cashier = null;
                try {
                    cashier = userService.getUserById(bill.getCashierId());
                } catch (Exception e) {
                    // Cashier details not found, but continue with bill printing
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                // CHANGED: Enhanced book details loading for printing - already done in BillService
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            // Ensure all book details are available for printing
                            if (billItem.getBookTitle() == null || billItem.getBookTitle().trim().isEmpty()) {
                                Book book = bookService.getBookById(billItem.getBookId());
                                if (book != null) {
                                    // CHANGED: Set comprehensive book details for print view
                                    billItem.setBookTitle(book.getTitle());
                                    billItem.setAuthor(book.getAuthor());
                                    billItem.setBookCode(book.getBookCode());
                                    billItem.setIsbn(book.getIsbn());
                                    billItem.setPublisher(book.getPublisher());
                                    billItem.setLanguage(book.getLanguage());
                                    billItem.setPages(book.getPages());
                                    billItem.setPublicationYear(book.getPublicationYear());
                                    billItem.setImageBase64(book.getImageBase64());  // CHANGED: Base64
                                    billItem.setBookCategory(book.getBookCategory());
                                }
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading book details for ID " + billItem.getBookId() + ": " + e.getMessage());
                        }
                    }
                }
                
                request.setAttribute("bill", bill);
                request.setAttribute("customer", customer);
                request.setAttribute("cashier", cashier);
                request.getRequestDispatcher("WEB-INF/view/bill/printBill.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("bill?action=list");
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bill: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void searchBills(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String searchTerm = request.getParameter("searchTerm");
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                response.sendRedirect("bill?action=list");
                return;
            }
            
            List<Bill> bills = billService.searchBills(searchTerm.trim());
            request.setAttribute("bills", bills);
            request.setAttribute("searchTerm", searchTerm.trim());
            
            if (bills.isEmpty()) {
                request.setAttribute("errorMessage", "No bills found matching '" + searchTerm + "'.");
            } else {
                request.setAttribute("successMessage", "Found " + bills.size() + " bill(s) matching '" + searchTerm + "'.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error searching bills: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void deleteBill(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String billIdParam = request.getParameter("id");
            if (billIdParam == null || billIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            int billId;
            try {
                billId = Integer.parseInt(billIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            // Get bill info before deletion for success message
            Bill billToDelete = billService.getBillById(billId);
            if (billToDelete == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            // Check if bill can be deleted
            if (!billService.canDeleteBill(billId)) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "This bill cannot be deleted.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            // Delete bill
            billService.deleteBill(billId);
            
            // Set success message with enhanced details
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", 
                "🗑️ Bill #" + billToDelete.getBillNumber() + " has been successfully deleted. " +
                "Stock has been restored for " + billToDelete.getTotalBooksCount() + " book(s). " +
                "Amount: Rs. " + String.format("%.2f", billToDelete.getTotalAmount()));
            
            response.sendRedirect("bill?action=list");
            
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting bill: " + e.getMessage());
            response.sendRedirect("bill?action=list");
        }
    }
    
    private void showUpdatePaymentStatusForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String billIdParam = request.getParameter("id");
            if (billIdParam == null || billIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            int billId;
            try {
                billId = Integer.parseInt(billIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            Bill bill = billService.getBillById(billId);
            
            if (bill != null) {
                request.setAttribute("bill", bill);
                request.getRequestDispatcher("WEB-INF/view/bill/updatePaymentStatus.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("bill?action=list");
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading bill: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void updatePaymentStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String billIdParam = request.getParameter("billId");
            String paymentStatus = request.getParameter("paymentStatus");
            
            if (billIdParam == null || billIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Payment status is required.");
                showUpdatePaymentStatusForm(request, response);
                return;
            }
            
            int billId;
            try {
                billId = Integer.parseInt(billIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid bill ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            // Get bill info for success message
            Bill bill = billService.getBillById(billId);
            if (bill == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            billService.updateBillPaymentStatus(billId, paymentStatus);
            
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", 
                "💳 Payment status for Bill #" + bill.getBillNumber() + " has been updated to " + paymentStatus + ". " +
                "Amount: Rs. " + String.format("%.2f", bill.getTotalAmount()));
            
            response.sendRedirect("bill?action=view&id=" + billId);
            
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error updating payment status: " + e.getMessage());
            response.sendRedirect("bill?action=list");
        }
    }
    
    private void viewCustomerBills(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String customerIdParam = request.getParameter("customerId");
            if (customerIdParam == null || customerIdParam.trim().isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid customer ID.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            int customerId;
            try {
                customerId = Integer.parseInt(customerIdParam);
            } catch (NumberFormatException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid customer ID format.");
                response.sendRedirect("bill?action=list");
                return;
            }
            
            List<Bill> bills = billService.getBillsByCustomer(customerId);
            Customer customer = customerService.getCustomerById(customerId);
            
            request.setAttribute("bills", bills);
            request.setAttribute("customer", customer);
            request.setAttribute("viewType", "customer");
            
            if (bills.isEmpty()) {
                request.setAttribute("errorMessage", "No bills found for this customer.");
            } else {
                int totalBooks = bills.stream().mapToInt(Bill::getTotalBooksCount).sum();
                double totalAmount = bills.stream().mapToDouble(Bill::getTotalAmount).sum();
                request.setAttribute("successMessage", "Found " + bills.size() + " bill(s) for " + 
                    (customer != null ? customer.getName() : "this customer") + 
                    ". Total Books: " + totalBooks + ", Total Amount: Rs. " + String.format("%.2f", totalAmount));
            }
            
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading customer bills: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void viewCashierBills(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User loggedUser = (User) session.getAttribute("loggedUser");
            
            String cashierIdParam = request.getParameter("cashierId");
            int cashierId;
            
            if (cashierIdParam != null && !cashierIdParam.trim().isEmpty()) {
                try {
                    cashierId = Integer.parseInt(cashierIdParam);
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Invalid cashier ID format.");
                    response.sendRedirect("bill?action=list");
                    return;
                }
            } else {
                // Show current user's bills if no cashier ID specified
                cashierId = loggedUser.getUserId();
            }
            
            List<Bill> bills = billService.getBillsByCashier(cashierId);
            
            request.setAttribute("bills", bills);
            request.setAttribute("viewType", "cashier");
            request.setAttribute("cashierId", cashierId);
            
            String cashierName = (cashierId == loggedUser.getUserId()) ? "You" : "Cashier ID " + cashierId;
            
            if (bills.isEmpty()) {
                request.setAttribute("errorMessage", "No bills found for this cashier.");
            } else {
                int totalBooks = bills.stream().mapToInt(Bill::getTotalBooksCount).sum();
                double totalAmount = bills.stream().mapToDouble(Bill::getTotalAmount).sum();
                request.setAttribute("successMessage", "Found " + bills.size() + " bill(s) created by " + cashierName + 
                    ". Total Books Sold: " + totalBooks + ", Total Amount: Rs. " + String.format("%.2f", totalAmount));
            }
            
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading cashier bills: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
    
    private void viewPendingPayments(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Bill> bills = billService.getPendingPaymentBills();
            
            request.setAttribute("bills", bills);
            request.setAttribute("viewType", "pending");
            
            if (bills.isEmpty()) {
                request.setAttribute("successMessage", "✅ No pending payments found. All bills are paid!");
            } else {
                double totalPendingAmount = bills.stream().mapToDouble(Bill::getTotalAmount).sum();
                int totalPendingBooks = bills.stream().mapToInt(Bill::getTotalBooksCount).sum();
                request.setAttribute("errorMessage", "⏳ " + bills.size() + " bill(s) have pending payments. " +
                    "Total Pending: Rs. " + String.format("%.2f", totalPendingAmount) + 
                    " | Books: " + totalPendingBooks);
            }
            
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading pending payments: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}