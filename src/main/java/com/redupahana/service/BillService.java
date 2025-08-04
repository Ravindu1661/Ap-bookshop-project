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
        
        // Generate bill number
        bill.setBillNumber(BillNumberGenerator.generateBillNumber());
        
        // Calculate totals
        calculateBillTotals(bill, billItems);
        
        // Save bill
        int billId = billDAO.addBill(bill);
        
        // Save bill items and update stock
        for (BillItem billItem : billItems) {
            billItem.setBillId(billId);
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
    
    public List<Bill> getBillsByCustomer(int customerId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }
        return billDAO.getBillsByCustomer(customerId);
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
            if (billItem.getItemId() <= 0) {
                throw new IllegalArgumentException("Invalid item ID");
            }
            if (billItem.getQuantity() <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than 0");
            }
            if (billItem.getUnitPrice() <= 0) {
                throw new IllegalArgumentException("Unit price must be greater than 0");
            }
            
            // Check stock availability
            Item item = itemDAO.getItemById(billItem.getItemId());
            if (item == null) {
                throw new IllegalArgumentException("Item not found: " + billItem.getItemId());
            }
            if (item.getStockQuantity() < billItem.getQuantity()) {
                throw new IllegalArgumentException("Insufficient stock for item: " + item.getName());
            }
        }
    }
    
    private void calculateBillTotals(Bill bill, List<BillItem> billItems) {
        double subTotal = 0;
        
        for (BillItem billItem : billItems) {
            billItem.setTotalPrice(billItem.getQuantity() * billItem.getUnitPrice());
            subTotal += billItem.getTotalPrice();
        }
        
        bill.setSubTotal(subTotal);
        
        // Apply discount if not set
        if (bill.getDiscount() == 0) {
            bill.setDiscount(Constants.DEFAULT_DISCOUNT);
        }
        
        // Calculate tax
        double taxableAmount = subTotal - bill.getDiscount();
        bill.setTax(taxableAmount * Constants.DEFAULT_TAX_RATE);
        
        // Calculate total
        bill.setTotalAmount(taxableAmount + bill.getTax());
    }
}