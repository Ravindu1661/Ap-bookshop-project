<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> inventoryData = (List<Map<String, Object>>) request.getAttribute("inventoryData");
    @SuppressWarnings("unchecked")
    Map<String, Object> inventorySummary = (Map<String, Object>) request.getAttribute("inventorySummary");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Report - Redupahana</title>
    <style>
        .inventory-container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .report-header {
            background: linear-gradient(135deg, #ffc107 0%, #ff8f00 100%);
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
            border-left: 4px solid #ffc107;
        }
        
        .summary-card.total { border-left-color: #007bff; }
        .summary-card.stock { border-left-color: #28a745; }
        .summary-card.low { border-left-color: #ffc107; }
        .summary-card.out { border-left-color: #dc3545; }
        .summary-card.value { border-left-color: #6f42c1; }
        
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
        
        .filter-section {
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 1.5rem;
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        
        .filter-select {
            padding: 0.5rem;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            background: white;
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
        
        .stock-status {
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .stock-status.in-stock {
            background: #d4edda;
            color: #155724;
        }
        
        .stock-status.low-stock {
            background: #fff3cd;
            color: #856404;
        }
        
        .stock-status.out-of-stock {
            background: #f8d7da;
            color: #721c24;
        }
        
        .no-data {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }
        
        @media (max-width: 768px) {
            .report-header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .filter-section {
                flex-direction: column;
                align-items: stretch;
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
            <div class="inventory-container">
                <!-- Header -->
                <div class="report-header">
                    <div>
                        <h1>📦Inventory Report</h1>
                        <p>Stock levels and inventory management</p>
                    </div>
                    <a href="reports" class="back-link">← Back to Reports</a>
                </div>

                <!-- Summary Cards -->
                <% if (inventorySummary != null) { %>
                <div class="summary-grid">
                    <div class="summary-card total">
                        <div class="summary-number"><%= inventorySummary.get("totalItems") %></div>
                        <div class="summary-label">Total Items</div>
                    </div>
                    
                    <div class="summary-card stock">
                        <div class="summary-number"><%= inventorySummary.get("totalStock") %></div>
                        <div class="summary-label">Total Stock</div>
                    </div>
                    
                    <div class="summary-card low">
                        <div class="summary-number"><%= inventorySummary.get("lowStock") %></div>
                        <div class="summary-label">Low Stock</div>
                    </div>
                    
                    <div class="summary-card out">
                        <div class="summary-number"><%= inventorySummary.get("outOfStock") %></div>
                        <div class="summary-label">Out of Stock</div>
                    </div>
                    
                    <div class="summary-card value">
                        <div class="summary-number">Rs. <%= String.format("%.0f", (Double) inventorySummary.get("totalValue")) %></div>
                        <div class="summary-label">Total Value</div>
                    </div>
                </div>
                <% } %>

                <!-- Filter Section -->
                <div class="filter-section">
                    <label>Filter by Stock Status:</label>
                    <select id="statusFilter" class="filter-select" onchange="filterInventory()">
                        <option value="all">All Items</option>
                        <option value="in-stock">In Stock</option>
                        <option value="low-stock">Low Stock</option>
                        <option value="out-of-stock">Out of Stock</option>
                    </select>
                </div>

                <!-- Inventory Data Table -->
                <div class="table-section">
                    <div class="table-header">
                        <h2>Inventory Data</h2>
                        <button onclick="exportToExcel()" class="export-btn">📥 Export Excel</button>
                    </div>
                    
                    <% if (inventoryData != null && !inventoryData.isEmpty()) { %>
                    <table class="data-table" id="inventoryTable">
                        <thead>
                            <tr>
                                <th>Item Code</th>
                                <th>Book Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Language</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> item : inventoryData) { %>
                            <tr data-status="<%= ((String) item.get("stockStatus")).toLowerCase().replace(" ", "-") %>">
                                <td><%= item.get("itemCode") %></td>
                                <td><%= item.get("bookTitle") %></td>
                                <td><%= item.get("author") != null ? item.get("author") : "Unknown" %></td>
                                <td><%= item.get("bookCategory") != null ? item.get("bookCategory") : "Uncategorized" %></td>
                                <td><%= item.get("language") != null ? item.get("language") : "Sinhala" %></td>
                                <td>Rs. <%= String.format("%.2f", (Double) item.get("price")) %></td>
                                <td><%= item.get("stockQuantity") %></td>
                                <td>
                                    <span class="stock-status <%= ((String) item.get("stockStatus")).toLowerCase().replace(" ", "-") %>">
                                        <%= item.get("stockStatus") %>
                                    </span>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div class="no-data">
                        <h3>No Inventory Data</h3>
                        <p>No inventory records found in the system.</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script>
        function filterInventory() {
            const filter = document.getElementById('statusFilter').value;
            const table = document.getElementById('inventoryTable');
            if (!table) return;
            
            const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const status = row.getAttribute('data-status');
                
                if (filter === 'all' || status === filter) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        }
        
        function exportToExcel() {
            const table = document.getElementById('inventoryTable');
            if (!table) {
                alert('No data to export');
                return;
            }
            
            // Get current filter to include in filename
            const filter = document.getElementById('statusFilter').value;
            let filterText = filter === 'all' ? 'all_items' : filter.replace('-', '_');
            
            // Create workbook and worksheet
            const wb = XLSX.utils.book_new();
            
            // Get visible rows only (respecting filter)
            const visibleRows = [];
            const allRows = table.querySelectorAll('tr');
            
            // Add header row
            const headerRow = allRows[0];
            if (headerRow) {
                visibleRows.push(headerRow);
            }
            
            // Add visible data rows
            for (let i = 1; i < allRows.length; i++) {
                const row = allRows[i];
                if (row.style.display !== 'none') {
                    visibleRows.push(row);
                }
            }
            
            // Create temporary table with visible rows only
            const tempTable = document.createElement('table');
            visibleRows.forEach(row => {
                tempTable.appendChild(row.cloneNode(true));
            });
            
            // Convert table to worksheet
            const ws = XLSX.utils.table_to_sheet(tempTable);
            
            // Add worksheet to workbook
            XLSX.utils.book_append_sheet(wb, ws, 'Inventory Report');
            
            // Generate filename with current date and filter
            const date = new Date().toISOString().split('T')[0];
            const filename = `inventory_report_${filterText}_${date}.xlsx`;
            
            // Save file
            XLSX.writeFile(wb, filename);
        }
    </script>
</body>
</html>