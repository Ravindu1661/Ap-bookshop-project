<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String infoMessage = (String) request.getAttribute("infoMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "customer");
    request.setAttribute("pageTitle", "Customer Management");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Management - Redupahana</title>
    
    <!-- Page-specific styles -->
    <style>
        /* Additional styles for customer list specific features */
        .account-number {
            font-family: 'Courier New', monospace;
            font-weight: bold;
            background: #e9ecef;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            font-size: 0.85rem;
        }

        .customer-name {
            font-weight: 600;
            color: #2c3e50;
        }

        .contact-info {
            display: flex;
            align-items: center;
            gap: 0.3rem;
            color: #7f8c8d;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>🏢 Customer Management</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; Customer Management
                </div>
            </div>

            <!-- Stats Cards -->
            <%
                int totalCustomers = customers != null ? customers.size() : 0;
                int activeCustomers = totalCustomers; // Assuming all are active for now
                int searchResults = searchTerm != null ? totalCustomers : 0;
            %>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3><%= totalCustomers %></h3>
                    <p>📊 Total Customers</p>
                </div>
                <div class="stat-card">
                    <h3><%= activeCustomers %></h3>
                    <p>✅ Active Customers</p>
                </div>
                <div class="stat-card">
                    <h3><%= searchTerm != null ? searchResults : totalCustomers %></h3>
                    <p><%= searchTerm != null ? "🔍 Search Results" : "👁️ Displaying" %></p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ✅ <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
            <% } %>

            <% if (infoMessage != null) { %>
            <div class="alert alert-info">
                ℹ️ <%= infoMessage %>
            </div>
            <% } %>

            <!-- Search Container -->
            <div class="search-container">
                <form class="search-form" action="customer" method="get">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="searchTerm" class="search-input" 
                           placeholder="🔍 Search by name, account number, phone, or email..." 
                           value="<%= searchTerm != null ? searchTerm : "" %>">
                    <button type="submit" class="btn btn-primary">🔍 Search</button>
                    <% if (searchTerm != null) { %>
                    <a href="customer?action=list" class="btn btn-warning">❌ Clear</a>
                    <% } %>
                </form>
            </div>

            <!-- Customers Table -->
            <div class="table-container">
                <div class="table-header">
                    <h2>
                        <% if (searchTerm != null) { %>
                        🔍 Search Results (<%= totalCustomers %> found)
                        <% } else { %>
                        🏢 All Customers (<%= totalCustomers %>)
                        <% } %>
                    </h2>
                    <a href="customer?action=add" class="btn btn-success">➕ Add New Customer</a>
                </div>

                <% if (customers != null && !customers.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>🏦 Account Number</th>
                            <th>👤 Name</th>
                            <th>📞 Phone</th>
                            <th>📧 Email</th>
                            <th>🏠 Address</th>
                            <th>📅 Created Date</th>
                            <th>⚡ Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Customer customer : customers) { %>
                        <tr>
                            <td>
                                <span class="account-number"><%= customer.getAccountNumber() %></span>
                            </td>
                            <td>
                                <span class="customer-name"><%= customer.getName() %></span>
                            </td>
                            <td>
                                <% if (customer.getPhone() != null && !customer.getPhone().isEmpty()) { %>
                                    <span class="contact-info">📞 <%= customer.getPhone() %></span>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (customer.getEmail() != null && !customer.getEmail().isEmpty()) { %>
                                    <span class="contact-info">📧 <%= customer.getEmail() %></span>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (customer.getAddress() != null && !customer.getAddress().isEmpty()) { %>
                                    <% 
                                        String address = customer.getAddress();
                                        if (address.length() > 30) {
                                            address = address.substring(0, 30) + "...";
                                        }
                                    %>
                                    <span class="contact-info" title="<%= customer.getAddress() %>">🏠 <%= address %></span>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (customer.getCreatedDate() != null) { %>
                                    <%= customer.getCreatedDate().toString().substring(0, 10) %>
                                <% } else { %>
                                    <span style="color: #bdc3c7;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="customer?action=view&id=<%= customer.getCustomerId() %>" 
                                       class="btn btn-primary btn-sm" title="View Customer Details">
                                       👁️ View
                                    </a>
                                    <a href="customer?action=edit&id=<%= customer.getCustomerId() %>" 
                                       class="btn btn-warning btn-sm" title="Edit Customer">
                                       ✏️ Edit
                                    </a>
                                    <a href="customer?action=delete&id=<%= customer.getCustomerId() %>" 
                                       class="btn btn-danger btn-sm" title="Delete Customer"
                                       onclick="return confirmDelete('<%= customer.getName() %>', '<%= customer.getAccountNumber() %>')">
                                       🗑️ Delete
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <% if (searchTerm != null) { %>
                        <div class="icon">🔍</div>
                        <h3>No Search Results</h3>
                        <p>No customers found matching "<%= searchTerm %>"</p>
                        <p>Try searching with different keywords or <a href="customer?action=list">view all customers</a></p>
                    <% } else { %>
                        <div class="icon">🏢</div>
                        <h3>No Customers Found</h3>
                        <p>Start by adding your first customer to the system.</p>
                        <a href="customer?action=add" class="btn btn-success">➕ Add Customer</a>
                    <% } %>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <!-- Page-specific JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🏢 Customer List page loaded');
            console.log('Total customers: <%= totalCustomers %>');
            
            // Simple keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                // Alt+N for new customer
                if (e.altKey && e.key === 'n') {
                    e.preventDefault();
                    window.location.href = 'customer?action=add';
                }
                
                // Alt+S for search
                if (e.altKey && e.key === 's') {
                    e.preventDefault();
                    const searchInput = document.querySelector('.search-input');
                    if (searchInput) searchInput.focus();
                }
                
                // Ctrl+F for search
                if (e.ctrlKey && e.key === 'f') {
                    e.preventDefault();
                    const searchInput = document.querySelector('.search-input');
                    if (searchInput) searchInput.focus();
                }
            });
            
            console.log('💡 Shortcuts: Alt+N=New Customer, Alt+S=Search, Ctrl+F=Search');
        });
    </script>
</body>
</html>