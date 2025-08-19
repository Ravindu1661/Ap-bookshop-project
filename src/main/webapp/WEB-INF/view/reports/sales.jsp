<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> salesData = (List<Map<String, Object>>) request.getAttribute("salesData");
    @SuppressWarnings("unchecked")
    Map<String, Object> salesSummary = (Map<String, Object>) request.getAttribute("salesSummary");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Report - Redupahana</title>
    <style>
        /* Page-specific styles */
        .page-header {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .page-header h1 {
            color: #2c3e50;
            font-size: 1.4rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 1rem;
            flex-wrap: wrap;
            gap: 1rem;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .stat-card {
            background: white;
            padding: 1.2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 1.8rem;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .stat-card p {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .stat-card.revenue { border-left: 4px solid #28a745; }
        .stat-card.today { border-left: 4px solid #3498db; }
        .stat-card.pending { border-left: 4px solid #ffc107; }

        /* Sales specific styles */
        .amount {
            font-weight: 600;
            color: #28a745;
        }

        .sales-container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .report-header {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .back-link {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 5px;
            text-decoration: none;
        }
        
        .back-link:hover {
            background: rgba(255,255,255,0.3);
            color: white;
            text-decoration: none;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .summary-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #28a745;
        }
        
        .summary-card.revenue { border-left-color: #28a745; }
        .summary-card.bills { border-left-color: #007bff; }
        .summary-card.average { border-left-color: #6f42c1; }
        .summary-card.paid { border-left-color: #20c997; }
        .summary-card.pending { border-left-color: #dc3545; }
        
        .summary-number {
            font-size: 1.8rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        
        .summary-label {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .table-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .table-header {
            background: #f8f9fa;
            padding: 1.5rem;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .export-btn {
            background: #007bff;
            color: white;
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .export-btn:hover {
            background: #0056b3;
            color: white;
            text-decoration: none;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .data-table th,
        .data-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }
        
        .data-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #495057;
        }
        
        .data-table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .status-paid {
            background: #d4edda;
            color: #155724;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .no-data {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }
        
        @media (max-width: 768px) {
            .header-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .report-header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .data-table {
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <div class="main-content">
        <div class="content-area">
            <div class="sales-container">
                <!-- Header -->
                <div class="report-header">
                    <div>
                        <h1>📈Sales Report</h1>
                        <p>Complete sales analysis and billing data</p>
                    </div>
                    <a href="reports" class="back-link">← Back to Reports</a>
                </div>

                <!-- Summary Cards -->
                <% if (salesSummary != null) { %>
                <div class="summary-grid">
                    <div class="summary-card revenue">
                        <div class="summary-number">Rs. <%= String.format("%.2f", (Double) salesSummary.get("totalSales")) %></div>
                        <div class="summary-label">Total Sales</div>
                    </div>
                    
                    <div class="summary-card bills">
                        <div class="summary-number"><%= salesSummary.get("totalBills") %></div>
                        <div class="summary-label">Total Bills</div>
                    </div>
                    
                    <div class="summary-card average">
                        <div class="summary-number">Rs. <%= String.format("%.2f", (Double) salesSummary.get("avgSale")) %></div>
                        <div class="summary-label">Average Sale</div>
                    </div>
                    
                    <div class="summary-card paid">
                        <div class="summary-number">Rs. <%= String.format("%.2f", (Double) salesSummary.get("paidAmount")) %></div>
                        <div class="summary-label">Paid Amount</div>
                    </div>
                    
                    <% if ((Double) salesSummary.get("pendingAmount") > 0) { %>
                    <div class="summary-card pending">
                        <div class="summary-number">Rs. <%= String.format("%.2f", (Double) salesSummary.get("pendingAmount")) %></div>
                        <div class="summary-label">Pending Amount</div>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <!-- Sales Data Table -->
                <div class="table-section">
                    <div class="table-header">
                        <h2>Sales Data (Last 100 Records)</h2>
                        <button onclick="exportToExcel()" class="export-btn">📥 Export Excel</button>
                    </div>
                    
                    <% if (salesData != null && !salesData.isEmpty()) { %>
                    <table class="data-table" id="salesTable">
                        <thead>
                            <tr>
                                <th>Bill Number</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Cashier</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> sale : salesData) { %>
                            <tr>
                                <td><%= sale.get("billNumber") %></td>
                                <td><%= sdf.format((java.util.Date) sale.get("billDate")) %></td>
                                <td><%= sale.get("customerName") != null ? sale.get("customerName") : "Walk-in" %></td>
                                <td><%= sale.get("cashierName") %></td>
                                <td>Rs. <%= String.format("%.2f", (Double) sale.get("totalAmount")) %></td>
                                <td>
                                    <span class="status-badge status-<%= ((String) sale.get("paymentStatus")).toLowerCase() %>">
                                        <%= sale.get("paymentStatus") %>
                                    </span>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div class="no-data">
                        <h3>No Sales Data</h3>
                        <p>No sales records found in the system.</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script>
        function exportToExcel() {
            const table = document.getElementById('salesTable');
            if (!table) {
                alert('No data to export');
                return;
            }
            
            // Create workbook and worksheet
            const wb = XLSX.utils.book_new();
            
            // Convert table to worksheet
            const ws = XLSX.utils.table_to_sheet(table);
            
            // Add worksheet to workbook
            XLSX.utils.book_append_sheet(wb, ws, 'Sales Report');
            
            // Generate filename with current date
            const date = new Date().toISOString().split('T')[0];
            const filename = `sales_report_${date}.xlsx`;
            
            // Save file
            XLSX.writeFile(wb, filename);
        }
    </script>
</body>
</html>