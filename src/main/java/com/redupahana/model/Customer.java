// Customer.java
package com.redupahana.model;

public class Customer {
    private int customerId;
    private String accountNumber;
    private String name;
    private String address;
    private String phone;
    private String email;
    private String createdDate;
    private String updatedDate;
    private boolean isActive;

    // Constructors
    public Customer() {}

    public Customer(String accountNumber, String name, String address, String phone, String email) {
        this.accountNumber = accountNumber;
        this.name = name;
        this.address = address;
        this.phone = phone;
        this.email = email;
        this.isActive = true;
    }

    // Getters and Setters
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getCreatedDate() { return createdDate; }
    public void setCreatedDate(String createdDate) { this.createdDate = createdDate; }

    public String getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(String updatedDate) { this.updatedDate = updatedDate; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}