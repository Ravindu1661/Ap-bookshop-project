<!-- printBill.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="java.util.List"%>
<%
    Bill bill = (Bill) request.getAttribute("bill");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Print Bill - <%= bill != null ? bill.getBillNumber() : "Bill" %></title>
    <style>
        @media print {
            body { margin: 0; }
            .no-print { display: none; }
            .print-container { box-shadow: none; }
        }
        body { font-family: 'Courier New', monospace; margin: 20px; background-color: #f5f5f5; }
        .print-container { max-width: 400px; margin: 0 auto; background: white; padding: 20px; border: 1px solid #ddd; }
        .header { text-align: center; border-bottom: 2px dashed #333; padding-bottom: 10px; margin-bottom: 15px; }
        .company-name { font-size: 18px; font-weight: bold; }
        .company-details { font-size: 10px; margin-top: 5px; }
        .bill-info { margin-bottom: 15px; font-size: 12px; }
        .bill-info div { margin-bottom: 2px; }
        .items-table { width: 100%; font-size: 11px; margin-bottom: 15px; }
        .items-table th, .items-table td { padding: 3px 0; text-align: left; }
        .items-table th { border-bottom: 1px solid #333; }
        .totals { border-top: 1px dashed #333; padding-top: 10px; font-size: 12px; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 3px; }
        .final-total { font-weight: bold; border-top: 1px solid #333; padding-top: 5px; font-size: 14px; }
        .footer { text-align: center; font-size: 10px; margin-top: 15px; border-top: 1px dashed #333; padding-top: 10px; }
        .print-button { text-align: center; margin-bottom: 20px; }
        .btn { padding: 10px 20px; background-color: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 0 5px; text-decoration: none; display: inline-block; }
        .btn:hover { background-color: #2980b9; }
        .btn-secondary { background-color: #95a5a6; }
        .btn-secondary:hover { background-color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="no-print print-button">
        <button class="btn" onclick="window.print()">🖨️ Print</button>
        <a href="bill?action=view&id=<%= bill != null ? bill.getBillId() : "" %>" class="btn btn-secondary">👁️ View Bill</a>
        <a href="bill?action=list" class="btn btn-secondary">📋 Back to Bills</a>
    </div>

    <% if (bill != null) { %>
    <div class="print-container">
        <div class="header">
            <div class="company-name">REDUPAHANA</div>
            <div class="company-details">
                Business Management System<br>
                Tel: +94 11 234 5678<br>
                Email: info@redupahana.com
            </div>
        </div>

        <div class="bill-info">
            <div><strong>Bill No:</strong> <%= bill.getBillNumber() %></div>
            <div><strong>Date:</strong> <%= bill.getBillDate() %></div>
            <div><strong>Customer ID:</strong> #<%= bill.getCustomerId() %></div>
            <div><strong>Cashier ID:</strong> #<%= bill.getCashierId() %></div>
            <div><strong>Status:</strong> <%= bill.getPaymentStatus() %></div>
        </div>

        <% if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) { %>
        <table class="items-table">
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Qty</th>
                    <th>Price</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <% for (BillItem item : bill.getBillItems()) { %>
                <tr>
                    <td>Item #<%= item.getItemId() %></td>
                    <td><%= item.getQuantity() %></td>
                    <td><%= String.format("%.2f", item.getUnitPrice()) %></td>
                    <td><%= String.format("%.2f", item.getTotalPrice()) %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>

        <div class="totals">
            <div class="total-row">
                <span>Sub Total:</span>
                <span>Rs. <%= String.format("%.2f", bill.getSubTotal()) %></span>
            </div>
            <div class="total-row">
                <span>Discount:</span>
                <span>Rs. <%= String.format("%.2f", bill.getDiscount()) %></span>
            </div>
            <div class="total-row">
                <span>Tax (5%):</span>
                <span>Rs. <%= String.format("%.2f", bill.getTax()) %></span>
            </div>
            <div class="total-row final-total">
                <span>TOTAL:</span>
                <span>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
            </div>
        </div>

        <div class="footer">
            <div>Thank you for your business!</div>
            <div>Powered by Redupahana System</div>
            <div>Generated on: <%= new java.util.Date() %></div>
        </div>
    </div>
    <% } else { %>
    <div style="text-align: center; padding: 50px;">
        <h3>Bill Not Found</h3>
        <a href="bill?action=list" class="btn">Back to Bills</a>
    </div>
    <% } %>

    <script>
        // Auto-print when page loads (optional)
        // window.onload = function() { window.print(); }
        
        // Print function
        function printBill() {
            window.print();
        }
        
        // Close window after printing (optional)
        window.onafterprint = function() {
            // window.close();
        }
    </script>
</body>