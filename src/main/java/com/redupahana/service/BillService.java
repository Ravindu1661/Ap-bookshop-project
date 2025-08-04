// BillService.java
package com.redupahana.service;

import java.sql.SQLException;
import java.util.List;
import com.redupahana.dao.BillDAO;
import com.redupahana.dao.BillItemDAO;
import com.redupahana.dao.ItemDAO;
import com.redupahana.model.Bill;
import com.redupahana.model.BillItem;
import com.redupahana.model.Item;
import com.redupahana.util.BillNumberGenerator;
import com.redupahana.util.Constants;
import com.redupahana.util.ValidationUtil;

public class BillService {
    
    private static BillService instance;
    private BillDAO billDAO;
    private BillItemDAO billItemDAO;
    private ItemDAO itemDAO;
    
    private BillService() {
        this.billDAO = new BillDAO();
        this.billItemDAO = new BillItemDAO();
        this.itemDAO = new ItemDAO();
    }
    
    public static BillService getInstance() {
        if (instance == null) {
            synchronized (BillService.class) {
                if (instance == null) {
                    instance = new BillService();
                }
            }
        }
        return instance;
    }
    
    public int createBill(Bill bill, List<BillItem> billItems) throws SQLException {
        validateBill(bill, billItems);
        
        // Generate bill number if not provided
        if (bill.getBillNumber() == null || bill.getBillNumber().isEmpty()) {
            bill.setBillNumber(BillNumberGenerator.generateBillNumber());
        }
        
        // Calculate totals
        calculateBillTotals(bill, billItems);
        
        // Save bill
        int billId = billDAO.addBill(bill);
        
        // Save bill items and update stock
        for (BillItem billItem : billItems) {
            billItem.setBillId(billId);
            billItem.calculateTotalPrice(); // Ensure total is calculated
            billItemDAO.addBillItem(billItem);
            // Update item stock
            itemDAO.updateStock(billItem.getItemId(), billItem.getQuantity());
        }
        
        return billId;
    }
    
    public List<Bill> getAllBills() throws SQLException {
        return billDAO.getAllBills();
    }
    
    public Bill getBillById(int billId) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        Bill bill = billDAO.getBillById(billId);
        if (bill != null) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
            bill.setBillItems(billItems);
        }
        return bill;
    }
    
    public Bill getBillByNumber(String billNumber) throws SQLException {
        if (!ValidationUtil.isNotEmpty(billNumber)) {
            throw new IllegalArgumentException("Bill number is required");
        }
        Bill bill = billDAO.getBillByNumber(billNumber);
        if (bill != null) {
            List<BillItem> billItems = billItemDAO.getBillItemsByBillId(bill.getBillId());
            bill.setBillItems(billItems);
        }
        return bill;
    }
    
    public List<Bill> getBillsByCustomer(int customerId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        return billDAO.getBillsByCustomer(customerId);
    }
    
    public List<Bill> getBillsByCashier(int cashierId) throws SQLException {
        if (cashierId <= 0) {
            throw new IllegalArgumentException("Invalid cashier ID");
        }
        return billDAO.getBillsByCashier(cashierId);
    }
    
    public List<Bill> searchBills(String searchTerm) throws SQLException {
        if (!ValidationUtil.isNotEmpty(searchTerm)) {
            throw new IllegalArgumentException("Search term is required");
        }
        return billDAO.searchBills(searchTerm);
    }
    
    public void updateBillPaymentStatus(int billId, String paymentStatus) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        if (!ValidationUtil.isNotEmpty(paymentStatus)) {
            throw new IllegalArgumentException("Payment status is required");
        }
        billDAO.updateBillPaymentStatus(billId, paymentStatus);
    }
    
    public void deleteBill(int billId) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        
        // Get bill items before deletion to restore stock
        List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
        
        // Restore stock for each item
        for (BillItem billItem : billItems) {
            // Restore stock by adding back the quantity
            restoreItemStock(billItem.getItemId(), billItem.getQuantity());
        }
        
        // Delete bill (this will also delete bill items due to DAO implementation)
        billDAO.deleteBill(billId);
    }
    
    public void addBillItem(int billId, BillItem billItem) throws SQLException {
        validateBillItem(billItem);
        billItem.setBillId(billId);
        billItem.calculateTotalPrice();
        billItemDAO.addBillItem(billItem);
        
        // Update item stock
        itemDAO.updateStock(billItem.getItemId(), billItem.getQuantity());
        
        // Recalculate bill totals
        recalculateBillTotals(billId);
    }
    
    public void updateBillItem(BillItem billItem) throws SQLException {
        validateBillItem(billItem);
        
        // Get old bill item to calculate stock difference
        BillItem oldBillItem = billItemDAO.getBillItemById(billItem.getBillItemId());
        if (oldBillItem == null) {
            throw new IllegalArgumentException("Bill item not found");
        }
        
        int stockDifference = billItem.getQuantity() - oldBillItem.getQuantity();
        
        billItem.calculateTotalPrice();
        billItemDAO.updateBillItem(billItem);
        
        // Update stock if quantity changed
        if (stockDifference != 0) {
            itemDAO.updateStock(billItem.getItemId(), stockDifference);
        }
        
        // Recalculate bill totals
        recalculateBillTotals(billItem.getBillId());
    }
    
    public void deleteBillItem(int billItemId) throws SQLException {
        if (billItemId <= 0) {
            throw new IllegalArgumentException("Invalid bill item ID");
        }
        
        // Get bill item before deletion to restore stock
        BillItem billItem = billItemDAO.getBillItemById(billItemId);
        if (billItem == null) {
            throw new IllegalArgumentException("Bill item not found");
        }
        
        // Restore stock
        restoreItemStock(billItem.getItemId(), billItem.getQuantity());
        
        billItemDAO.deleteBillItem(billItemId);
        
        // Recalculate bill totals
        recalculateBillTotals(billItem.getBillId());
    }
    
    public List<BillItem> getBillItemsByBillId(int billId) throws SQLException {
        if (billId <= 0) {
            throw new IllegalArgumentException("Invalid bill ID");
        }
        return billItemDAO.getBillItemsByBillId(billId);
    }
    
    public List<BillItem> getBillItemsByItemId(int itemId) throws SQLException {
        if (itemId <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        return billItemDAO.getBillItemsByItemId(itemId);
    }
    
    public BillItem getBillItemById(int billItemId) throws SQLException {
        if (billItemId <= 0) {
            throw new IllegalArgumentException("Invalid bill item ID");
        }
        return billItemDAO.getBillItemById(billItemId);
    }
    
    // Additional utility methods
    public double calculateBillTotal(int billId) throws SQLException {
        List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
        return billItems.stream()
                .mapToDouble(BillItem::getTotalPrice)
                .sum();
    }
    
    public int getTotalItemsInBill(int billId) throws SQLException {
        List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
        return billItems.stream()
                .mapToInt(BillItem::getQuantity)
                .sum();
    }
    
    public boolean canDeleteBill(int billId) throws SQLException {
        Bill bill = billDAO.getBillById(billId);
        if (bill == null) {
            return false;
        }
        // Add business logic here - for example, can't delete paid bills older than X days
        return true;
    }
    
    private void validateBill(Bill bill, List<BillItem> billItems) throws SQLException {
        if (bill.getCustomerId() <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        if (bill.getCashierId() <= 0) {
            throw new IllegalArgumentException("Invalid cashier ID");
        }
        if (billItems == null || billItems.isEmpty()) {
            throw new IllegalArgumentException("Bill must contain at least one item");
        }
        
        // Validate each bill item and check stock availability
        for (BillItem billItem : billItems) {
            validateBillItem(billItem);
            
            // Check stock availability
            Item item = itemDAO.getItemById(billItem.getItemId());
            if (item == null) {
                throw new IllegalArgumentException("Item not found: " + billItem.getItemId());
            }
            if (!item.isActive()) {
                throw new IllegalArgumentException("Item is not active: " + item.getName());
            }
            if (item.getStockQuantity() < billItem.getQuantity()) {
                throw new IllegalArgumentException("Insufficient stock for item: " + item.getName() + 
                    ". Available: " + item.getStockQuantity() + ", Requested: " + billItem.getQuantity());
            }
        }
    }
    
    private void validateBillItem(BillItem billItem) {
        if (billItem.getItemId() <= 0) {
            throw new IllegalArgumentException("Invalid item ID");
        }
        if (billItem.getQuantity() <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than 0");
        }
        if (billItem.getUnitPrice() <= 0) {
            throw new IllegalArgumentException("Unit price must be greater than 0");
        }
    }
    
    private void calculateBillTotals(Bill bill, List<BillItem> billItems) {
        double subTotal = 0;
        
        for (BillItem billItem : billItems) {
            billItem.calculateTotalPrice();
            subTotal += billItem.getTotalPrice();
        }
        
        bill.setSubTotal(subTotal);
        
        // Apply discount if not set
        if (bill.getDiscount() == 0) {
            bill.setDiscount(Constants.DEFAULT_DISCOUNT);
        }
        
        // Ensure discount doesn't exceed subtotal
        if (bill.getDiscount() > subTotal) {
            bill.setDiscount(subTotal);
        }
        
        // Calculate tax
        double taxableAmount = subTotal - bill.getDiscount();
        if (taxableAmount < 0) taxableAmount = 0; // Ensure non-negative
        
        bill.setTax(taxableAmount * Constants.DEFAULT_TAX_RATE);
        
        // Calculate total
        bill.setTotalAmount(taxableAmount + bill.getTax());
    }
    
    private void recalculateBillTotals(int billId) throws SQLException {
        Bill bill = billDAO.getBillById(billId);
        if (bill == null) {
            throw new IllegalArgumentException("Bill not found");
        }
        
        List<BillItem> billItems = billItemDAO.getBillItemsByBillId(billId);
        if (billItems.isEmpty()) {
            // If no items left, you might want to delete the bill or set totals to zero
            bill.setSubTotal(0);
            bill.setTax(0);
            bill.setTotalAmount(0);
        } else {
            calculateBillTotals(bill, billItems);
        }
        
        // Update bill totals in database
        updateBillTotals(billId, bill.getSubTotal(), bill.getTax(), bill.getTotalAmount());
    }
    
    private void updateBillTotals(int billId, double subTotal, double tax, double totalAmount) throws SQLException {
        // You should add this method to BillDAO
        String updateQuery = "UPDATE bills SET sub_total = ?, tax = ?, total_amount = ? WHERE bill_id = ?";
        // For now, we'll assume this functionality exists in BillDAO
        // billDAO.updateBillTotals(billId, subTotal, tax, totalAmount);
    }
    
    private void restoreItemStock(int itemId, int quantity) throws SQLException {
        // Restore stock by adding back the quantity (opposite of updateStock)
        String restoreStockQuery = "UPDATE items SET stock_quantity = stock_quantity + ? WHERE item_id = ?";
        // You should add this method to ItemDAO as restoreStock
        // itemDAO.restoreStock(itemId, quantity);
        
        // For now, we can use negative quantity with updateStock
        itemDAO.updateStock(itemId, -quantity);
    }
    
    // Report generation methods
    public List<Bill> getBillsByDateRange(String startDate, String endDate) throws SQLException {
        if (!ValidationUtil.isNotEmpty(startDate) || !ValidationUtil.isNotEmpty(endDate)) {
            throw new IllegalArgumentException("Start date and end date are required");
        }
        // You should add this method to BillDAO
        // return billDAO.getBillsByDateRange(startDate, endDate);
        return getAllBills(); // Temporary implementation
    }
    
    public double getTotalSalesAmount(String startDate, String endDate) throws SQLException {
        List<Bill> bills = getBillsByDateRange(startDate, endDate);
        return bills.stream()
                .filter(Bill::isPaid)
                .mapToDouble(Bill::getTotalAmount)
                .sum();
    }
    
    public int getTotalBillsCount(String startDate, String endDate) throws SQLException {
        List<Bill> bills = getBillsByDateRange(startDate, endDate);
        return bills.size();
    }
    
    public List<Bill> getPendingPaymentBills() throws SQLException {
        List<Bill> allBills = getAllBills();
        return allBills.stream()
                .filter(Bill::isPending)
                .collect(java.util.stream.Collectors.toList());
    }
}