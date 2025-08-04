<!-- printBill.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.BillItem"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
    Bill bill = (Bill) request.getAttribute("bill");
    Customer customer = (Customer) request.getAttribute("customer");
    User cashier = (User) request.getAttribute("cashier");
    
    // Format current date and time
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
    Date now = new Date();
    String currentDate = dateFormat.format(now);
    String currentTime = timeFormat.format(now);
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
            .no-print { display: none !important; }
            .print-container { box-shadow: none; margin: 0; }
            @page { margin: 0.5cm; }
        }
        
        body { 
            font-family: 'Courier New', monospace; 
            margin: 20px; 
            background-color: #f5f5f5; 
            font-size: 12px;
            line-height: 1.2;
        }
        
        .print-container { 
            max-width: 380px; 
            margin: 0 auto; 
            background: white; 
            padding: 15px; 
            border: 1px solid #ddd; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header { 
            text-align: center; 
            border-bottom: 2px dashed #333; 
            padding-bottom: 10px; 
            margin-bottom: 10px; 
        }
        
        .company-name { 
            font-size: 18px; 
            font-weight: bold; 
            letter-spacing: 2px;
            margin-bottom: 3px;
        }
        
        .company-details { 
            font-size: 9px; 
            margin-top: 3px; 
            line-height: 1.3;
        }
        
        .section-divider {
            border-bottom: 1px dashed #666;
            margin: 8px 0;
            padding-bottom: 5px;
        }
        
        .bill-info { 
            margin-bottom: 10px; 
            font-size: 10px; 
        }
        
        .bill-info div { 
            margin-bottom: 2px; 
            display: flex;
            justify-content: space-between;
        }
        
        .bill-info .label {
            font-weight: bold;
            min-width: 80px;
        }
        
        .customer-info {
            background-color: #f9f9f9;
            padding: 6px;
            margin-bottom: 10px;
            border: 1px solid #ddd;
            font-size: 10px;
        }
        
        .customer-info .section-title {
            font-weight: bold;
            text-align: center;
            margin-bottom: 5px;
            font-size: 11px;
            border-bottom: 1px solid #ccc;
            padding-bottom: 2px;
        }
        
        .cashier-info {
            font-size: 9px;
            margin-bottom: 10px;
            padding: 4px;
            background-color: #f5f5f5;
            border-left: 3px solid #333;
        }
        
        .items-table { 
            width: 100%; 
            font-size: 9px; 
            margin-bottom: 10px; 
            border-collapse: collapse;
        }
        
        .items-table th, .items-table td { 
            padding: 3px 2px; 
            text-align: left; 
            border-bottom: 1px dotted #999;
            vertical-align: top;
        }
        
        .items-table th { 
            border-bottom: 1px solid #333; 
            font-weight: bold;
            background-color: #f0f0f0;
            font-size: 9px;
        }
        
        .items-table .text-right {
            text-align: right;
        }
        
        .items-table .text-center {
            text-align: center;
        }
        
        .item-details {
            font-size: 8px;
            color: #666;
        }
        
        .item-name {
            font-weight: bold;
            font-size: 9px;
        }
        
        .totals { 
            border-top: 2px dashed #333; 
            padding-top: 8px; 
            font-size: 10px; 
        }
        
        .total-row { 
            display: flex; 
            justify-content: space-between; 
            margin-bottom: 3px; 
            padding: 1px 0;
        }
        
        .total-row.highlight {
            background-color: #f0f0f0;
            padding: 2px 3px;
            margin: 1px -3px;
        }
        
        .final-total { 
            font-weight: bold; 
            border-top: 2px solid #333; 
            padding-top: 6px; 
            font-size: 12px;
            margin-top: 6px;
            background-color: #f5f5f5;
            padding: 6px 3px;
            margin-left: -3px;
            margin-right: -3px;
        }
        
        .payment-info {
            margin-top: 10px;
            padding: 6px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            font-size: 10px;
        }
        
        .payment-status {
            text-align: center;
            font-weight: bold;
            padding: 4px;
            margin: 3px 0;
            border-radius: 3px;
            font-size: 10px;
        }
        
        .status-paid {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }
        
        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .footer { 
            text-align: center; 
            font-size: 8px; 
            margin-top: 15px; 
            border-top: 2px dashed #333; 
            padding-top: 10px; 
            line-height: 1.3;
        }
        
        .footer .thank-you {
            font-size: 10px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .print-button { 
            text-align: center; 
            margin-bottom: 15px; 
        }
        
        .btn { 
            padding: 8px 15px; 
            background-color: #3498db; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
            margin: 0 5px; 
            text-decoration: none; 
            display: inline-block; 
            font-size: 11px;
        }
        
        .btn:hover { 
            background-color: #2980b9; 
        }
        
        .btn-secondary { 
            background-color: #95a5a6; 
        }
        
        .btn-secondary:hover { 
            background-color: #7f8c8d; 
        }
        
        .summary-stats {
            display: flex;
            justify-content: space-between;
            font-size: 9px;
            margin-top: 8px;
            padding-top: 5px;
            border-top: 1px dotted #999;
        }
    </style>
</head>
<body>
    <div class="no-print print-button">
        <button class="btn" onclick="window.print()">🖨️ Print Bill</button>
        <a href="bill?action=view&id=<%= bill != null ? bill.getBillId() : "" %>" class="btn btn-secondary">👁️ View Bill</a>
        <a href="bill?action=list" class="btn btn-secondary">📋 Back to Bills</a>
    </div>

    <% if (bill != null) { %>
    <div class="print-container">
        <!-- Header Section -->
        <div class="header">
            <div class="company-name">REDUPAHANA</div>
            <div class="company-details">
                Business Management System<br>
                No. 123, Main Street, Colombo 01<br>
                Tel: +94 11 234 5678<br>
                Email: info@redupahana.com
            </div>
        </div>

        <!-- Bill Information Section -->
        <div class="bill-info section-divider">
            <div>
                <span class="label">Bill No:</span>
                <span><%= bill.getBillNumber() %></span>
            </div>
            <div>
                <span class="label">Date:</span>
                <span><%= bill.getBillDate() %></span>
            </div>
            <div>
                <span class="label">Time:</span>
                <span><%= currentTime %></span>
            </div>
            <div>
                <span class="label">Bill ID:</span>
                <span>#<%= bill.getBillId() %></span>
            </div>
        </div>

        <!-- Customer Information Section -->
        <% if (customer != null) { %>
        <div class="customer-info">
            <div class="section-title">CUSTOMER INFO</div>
            <div>
                <span class="label">ID:</span>
                <span>#<%= customer.getCustomerId() %></span>
            </div>
            <div>
                <span class="label">Name:</span>
                <span><%= customer.getName() %></span>
            </div>
            <% if (customer.getPhone() != null && !customer.getPhone().isEmpty()) { %>
            <div>
                <span class="label">Phone:</span>
                <span><%= customer.getPhone() %></span>
            </div>
            <% } %>
            <% if (customer.getEmail() != null && !customer.getEmail().isEmpty()) { %>
            <div>
                <span class="label">Email:</span>
                <span><%= customer.getEmail() %></span>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="customer-info">
            <div class="section-title">CUSTOMER INFO</div>
            <div>
                <span class="label">ID:</span>
                <span>#<%= bill.getCustomerId() %></span>
            </div>
            <div style="font-style: italic; text-align: center; color: #666;">
                Customer details not available
            </div>
        </div>
        <% } %>

        <!-- Cashier Information Section -->
        <div class="cashier-info">
            <strong>Served By:</strong> 
            <% if (cashier != null) { %>
                <%= cashier.getFullName() %> (ID: #<%= cashier.getUserId() %>)
            <% } else { %>
                Cashier ID: #<%= bill.getCashierId() %>
            <% } %>
        </div>

        <!-- Items Section -->
        <% if (bill.getBillItems() != null && !bill.getBillItems().isEmpty()) { %>
        <table class="items-table">
            <thead>
                <tr>
                    <th style="width: 40%;">Item Details</th>
                    <th class="text-center" style="width: 15%;">Qty</th>
                    <th class="text-right" style="width: 20%;">Price</th>
                    <th class="text-right" style="width: 25%;">Total</th>
                </tr>
            </thead>
            <tbody>
                <% 
                double itemCount = 0;
                double totalQty = 0;
                for (BillItem item : bill.getBillItems()) { 
                    itemCount++;
                    totalQty += item.getQuantity();
                %>
                <tr>
                    <td>
                        <div class="item-name">
                            <% if (item.getItemName() != null && !item.getItemName().isEmpty()) { %>
                                <%= item.getItemName() %>
                            <% } else { %>
                                Item #<%= item.getItemId() %>
                            <% } %>
                        </div>
                        <div class="item-details">
                            ID: #<%= item.getItemId() %> | Unit: Rs. <%= String.format("%.2f", item.getUnitPrice()) %>
                        </div>
                    </td>
                    <td class="text-center"><%= item.getQuantity() %></td>
                    <td class="text-right">Rs. <%= String.format("%.2f", item.getUnitPrice()) %></td>
                    <td class="text-right"><strong>Rs. <%= String.format("%.2f", item.getTotalPrice()) %></strong></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <!-- Summary Statistics -->
        <div class="summary-stats">
            <span>Items: <%= (int)itemCount %></span>
            <span>Total Qty: <%= (int)totalQty %></span>
        </div>
        <% } else { %>
        <div style="text-align: center; padding: 15px; color: #666; font-style: italic;">
            No items found
        </div>
        <% } %>

        <!-- Totals Section -->
        <div class="totals">
			<%
			double subTotal = 0;
			Double discountWrapper = bill.getDiscount();
			double discount = (discountWrapper != null) ? discountWrapper : 0;
			double tax = 0;
			
			// Calculate subtotal from bill items
			if (bill.getBillItems() != null) {
			    for (BillItem item : bill.getBillItems()) {
			        subTotal += item.getTotalPrice();
			    }
			}
			
			// Calculate tax (5% on amount after discount)
			tax = (subTotal - discount) * 0.05;
			%>
            
            <div class="total-row">
                <span>Sub Total:</span>
                <span>Rs. <%= String.format("%.2f", subTotal) %></span>
            </div>
            
            <% if (discount > 0) { %>
            <div class="total-row highlight">
                <span>Discount:</span>
                <span>- Rs. <%= String.format("%.2f", discount) %></span>
            </div>
            <% } %>
            
            <div class="total-row">
                <span>Tax (5%):</span>
                <span>Rs. <%= String.format("%.2f", tax) %></span>
            </div>
            
            <div class="total-row final-total">
                <span>TOTAL:</span>
                <span>Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
            </div>
        </div>

        <!-- Payment Information -->
        <div class="payment-info">
            <div style="text-align: center; font-weight: bold; margin-bottom: 5px; font-size: 10px;">
                PAYMENT STATUS
            </div>
            <div class="payment-status status-<%= bill.getPaymentStatus().toLowerCase() %>">
                <%= bill.getPaymentStatus() %>
                <% if ("PAID".equals(bill.getPaymentStatus())) { %>
                ✓
                <% } else if ("PENDING".equals(bill.getPaymentStatus())) { %>
                ⏳
                <% } else { %>
                ✗
                <% } %>
            </div>
        </div>

        <!-- Footer Section -->
        <div class="footer">
            <div class="thank-you">Thank You!</div>
            <div>
                Goods once sold cannot be returned without receipt.<br>
                Exchange within 7 days with valid receipt.
            </div>
            <div style="margin-top: 8px;">
                <strong>Redupahana System</strong><br>
                <%= new java.util.Date() %>
            </div>
            <div style="margin-top: 5px; font-size: 7px;">
                Computer generated bill - No signature required
            </div>
        </div>
    </div>
    <% } else { %>
    <div style="text-align: center; padding: 50px;">
        <h3>⚠️ Bill Not Found</h3>
        <p>The requested bill could not be found.</p>
        <a href="bill?action=list" class="btn">📋 Back to Bills</a>
    </div>
    <% } %>

    <script>
        // Print function
        function printBill() {
            window.print();
        }
        
        // Handle after print
        window.onafterprint = function() {
            console.log('Bill printed successfully');
        }
        
        // Keyboard shortcut for print
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                printBill();
            }
        });
        
        console.log('Print Bill page loaded successfully');
    </script>
</body>
</html>