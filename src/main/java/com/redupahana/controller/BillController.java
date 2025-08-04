// BillController.java
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
    private UserService userService;
    public void init() throws ServletException {
        billService = BillService.getInstance();
        customerService = CustomerService.getInstance();
        itemService = ItemService.getInstance();
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
            List<Item> items = itemService.getAllItems();
            
            // Filter only active items with stock > 0
            items = items.stream()
                    .filter(item -> item.isActive() && item.getStockQuantity() > 0)
                    .collect(java.util.stream.Collectors.toList());
            
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
            String[] itemIds = request.getParameterValues("itemId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");
            
            List<BillItem> billItems = new ArrayList<>();
            if (itemIds != null && quantities != null && unitPrices != null) {
                for (int i = 0; i < itemIds.length; i++) {
                    if (i < quantities.length && i < unitPrices.length &&
                        !itemIds[i].trim().isEmpty() && 
                        !quantities[i].trim().isEmpty() && 
                        !unitPrices[i].trim().isEmpty()) {
                        
                        try {
                            int itemId = Integer.parseInt(itemIds[i]);
                            int quantity = Integer.parseInt(quantities[i]);
                            double unitPrice = Double.parseDouble(unitPrices[i]);
                            
                            if (itemId <= 0) {
                                request.setAttribute("errorMessage", "Invalid item selection.");
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
                            billItem.setItemId(itemId);
                            billItem.setQuantity(quantity);
                            billItem.setUnitPrice(unitPrice);
                            billItems.add(billItem);
                        } catch (NumberFormatException e) {
                            request.setAttribute("errorMessage", "Invalid number format in item data.");
                            showCreateForm(request, response);
                            return;
                        }
                    }
                }
            }
            
            if (billItems.isEmpty()) {
                request.setAttribute("errorMessage", "At least one item is required.");
                showCreateForm(request, response);
                return;
            }
            
            // Create bill
            int billId = billService.createBill(bill, billItems);
            
            // Get the created bill for success message
            Bill createdBill = billService.getBillById(billId);
            
            // Set success message
            session.setAttribute("successMessage", 
                "Bill #" + createdBill.getBillNumber() + " has been successfully created. " +
                "Total Amount: Rs. " + String.format("%.2f", createdBill.getTotalAmount()));
            
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
                
                // Get cashier details - you'll need to implement this
                User cashier = null;
                try {
                    // Uncomment and implement this when you have UserService
                     cashier = userService.getUserById(bill.getCashierId());
                } catch (Exception e) {
                    // Log error but continue - cashier details will show as "not available"
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                // Get item details for bill items (if you want to show item names)
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            Item item = itemService.getItemById(billItem.getItemId());
                            if (item != null) {
                                // You'll need to add setItemName method to BillItem class
                                billItem.setItemName(item.getName());
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading item details for ID " + billItem.getItemId() + ": " + e.getMessage());
                            // Continue without item name - will use item ID instead
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
                    // Uncomment this if you have UserService
                    // cashier = userService.getUserById(bill.getCashierId());
                } catch (Exception e) {
                    // Cashier details not found, but continue with bill printing
                    System.err.println("Error loading cashier details: " + e.getMessage());
                }
                
                // Get item details for bill items
                if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) {
                    for (BillItem billItem : bill.getBillItems()) {
                        try {
                            Item item = itemService.getItemById(billItem.getItemId());
                            if (item != null) {
                                billItem.setItemName(item.getName()); // Assuming you have setter for item name
                            }
                        } catch (SQLException e) {
                            System.err.println("Error loading item details for ID " + billItem.getItemId() + ": " + e.getMessage());
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
            
            // Set success message
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", 
                "Bill #" + billToDelete.getBillNumber() + " has been successfully deleted. " +
                "Stock has been restored for all items.");
            
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
                "Payment status for Bill #" + bill.getBillNumber() + " has been updated to " + paymentStatus + ".");
            
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
                request.setAttribute("successMessage", "Found " + bills.size() + " bill(s) for " + 
                    (customer != null ? customer.getName() : "this customer") + ".");
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
                request.setAttribute("successMessage", "Found " + bills.size() + " bill(s) created by " + cashierName + ".");
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
                request.setAttribute("successMessage", "No pending payments found. All bills are paid!");
            } else {
                request.setAttribute("errorMessage", bills.size() + " bill(s) have pending payments.");
            }
            
            request.getRequestDispatcher("WEB-INF/view/bill/listBills.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading pending payments: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/view/error.jsp").forward(request, response);
        }
    }
}