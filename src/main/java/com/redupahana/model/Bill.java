// Bill.java
package com.redupahana.model;

import java.util.List;

public class Bill {
    private int billId;
    private String billNumber;
    private int customerId;
    private int cashierId;
    private String billDate;
    private double subTotal;
    private double discount;
    private double tax;
    private double totalAmount;
    private String paymentStatus;
    private Customer customer;
    private User cashier;
    private List<BillItem> billItems;

    // Constructors
    public Bill() {}

    public Bill(String billNumber, int customerId, int cashierId, double subTotal, double totalAmount) {
        this.billNumber = billNumber;
        this.customerId = customerId;
        this.cashierId = cashierId;
        this.subTotal = subTotal;
        this.totalAmount = totalAmount;
        this.paymentStatus = "PAID";
    }

    // Getters and Setters
    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public String getBillNumber() { return billNumber; }
    public void setBillNumber(String billNumber) { this.billNumber = billNumber; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getCashierId() { return cashierId; }
    public void setCashierId(int cashierId) { this.cashierId = cashierId; }

    public String getBillDate() { return billDate; }
    public void setBillDate(String billDate) { this.billDate = billDate; }

    public double getSubTotal() { return subTotal; }
    public void setSubTotal(double subTotal) { this.subTotal = subTotal; }

    public double getDiscount() { return discount; }
    public void setDiscount(double discount) { this.discount = discount; }

    public double getTax() { return tax; }
    public void setTax(double tax) { this.tax = tax; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }

    public User getCashier() { return cashier; }
    public void setCashier(User cashier) { this.cashier = cashier; }

    public List<BillItem> getBillItems() { return billItems; }
    public void setBillItems(List<BillItem> billItems) { this.billItems = billItems; }
}
