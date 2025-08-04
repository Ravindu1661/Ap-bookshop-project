<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="java.util.List"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    Bill bill = (Bill) request.getAttribute("bill");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Bill - Redupahana</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; }
        .navbar { background-color: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
        .bill-container { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 2rem; }
        .bill-header { text-align: center; border-bottom: 2px solid #3498db; padding-bottom: 1rem; margin-bottom: 2rem; }
        .company-name { font-size: 2rem; font-weight: bold; color: #2c3e50; }
        .bill-title { font-size: 1.5rem; color: #3498db; margin-top: 0.5rem; }
        .bill-info { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 2rem; }
        .info-section h4 { color: #2c3e50; margin-bottom: 0.5rem; }
        .info-row { margin-bottom: 0.3rem; }
        .label { font-weight: 600; color: #7f8c8d; }
        .value { color: #2c3e50; }
        .items-table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
        .items-table th, .items-table td { padding: 0.8rem; text-align: left; border-bottom: 1px solid #ddd; }
        .items-table th { background-color: #f8f9fa; font-weight: 600; }
        .totals-section { border-top: 2px solid #3498db; padding-top: 1rem; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 0.5rem; }
        .total-row.final { font-size: 1.2rem; font-weight: bold; color: #2c3e50; border-top: 1px solid #ddd; padding-top: 0.5rem; }
        .action-buttons { margin-top: 2rem; text-align: center; }
        .btn { padding: 0.8rem 2rem; margin: 0 0.5rem; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; font-size: 1rem; }
        .btn-primary { background-color: #3498db; color: white; }
        .btn-success { background-color: #27ae60; color: white; }
        .btn-secondary { background-color: #95a5a6; color: white; }
        .status-badge { padding: 0.25rem 0.8rem; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
        .status-paid { background-color: #d4edda; color: #155724; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Bill Details</h1>
        <div class="nav-links">
            <a href="dashboard" style="color: white; text-decoration: none; padding: 0.5rem 1rem;">Dashboard</a>
            <a href="bill?action=list" style="color: white; text-decoration: none; padding: 0.5rem 1rem;">Bills</a>
            <a href="auth?action=logout" style="color: white; text-decoration: none; padding: 0.5rem 1rem;">Logout</a>
        </div>
    </nav>

    <div class="container">
        <% if (bill != null) { %>
        <div class="bill-container">
            <div class="bill-header">
                <div class="company-name">REDUPAHANA</div>
                <div class="bill-title">INVOICE</div>
            </div>

            <div class="bill-info">
                <div class="info-section">
                    <h4>Bill Information</h4>
                    <div class="info-row">
                        <span class="label">Bill Number:</span>
                        <span class="value"><%= bill.getBillNumber() %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Date:</span>
                        <span class="value"><%= bill.getBillDate() %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Status:</span>
                        <span class="status-badge status-paid"><%= bill.getPaymentStatus() %></span>
                    </div>
                </div>
                <div class="info-section">
                    <h4>Customer Information</h4>
                    <div class="info-row">
                        <span class="label">Customer ID:</span>
                        <span class="value">#<%= bill.getCustomerId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Cashier ID:</span>
                        <span class="value">#<%= bill.getCashierId() %></span>
                    </div>
                </div>
            </div>

            <% if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) { %>
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (BillItem item : bill.getBillItems()) { %>
                    <tr>
                        <td>Item #<%= item.getItemId() %></td>
                        <td><%= item.getQuantity() %></td>
                        <td>Rs. <%= String.format("%.2f", item.getUnitPrice()) %></td>
                        <td>Rs. <%= String.format("%.2f", item.getTotalPrice()) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>

            <div class="totals-section">
                <div class="total-row">
                    <span>Sub Total:</span>
                    <span>Rs. <%= String.format("%.2f", bill.getSubTotal()) %></span>
                </div>
                <div class="total-row">
                    <span>Discount:</span>
                    <span>Rs. <%= String.format("%.2f", bill.getDiscount()) %></span>
                </div>
                <div class="total-row">
                    <span>Tax:</span>
                    <span>Rs. <%= String.format("%.2f", bill.getTax()) %></span>
                </div>
                <div class="total-row final">
                    <span>Total Amount:</span>
                    <span>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="bill?action=print&id=<%= bill.getBillId() %>" class="btn btn-success" target="_blank">🖨️ Print Bill</a>
                <a href="bill?action=list" class="btn btn-secondary">📋 Back to Bills</a>
            </div>
        </div>
        <% } else { %>
        <div style="background: white; padding: 3rem; text-align: center; border-radius: 8px;">
            <h3 style="color: #e74c3c;">Bill Not Found</h3>
            <a href="bill?action=list" class="btn btn-primary">Back to Bills</a>
        </div>
        <% } %>
    </div>
</body>
</html>