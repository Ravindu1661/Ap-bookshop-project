<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    // Get logged user from session
    User sidebarUser = (User) session.getAttribute("loggedUser");
    String currentPage = request.getParameter("currentPage");
    if (currentPage == null) {
        currentPage = (String) request.getAttribute("currentPage");
    }
    if (currentPage == null) {
        currentPage = "";
    }
    
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Dashboard";
    }
    
    // Determine sidebar color scheme based on user role
    String sidebarColorClass = "sidebar-admin"; // default to admin colors
    if (sidebarUser != null && !Constants.ROLE_ADMIN.equals(sidebarUser.getRole())) {
        sidebarColorClass = "sidebar-cashier";
    }
    
    // Check for welcome notification
    String showWelcomeNotification = (String) session.getAttribute("showWelcomeNotification");
    if (showWelcomeNotification != null) {
        session.removeAttribute("showWelcomeNotification"); // Remove after reading
    }
%>

<style>

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f8f9fa;
    font-size: 14px;
    line-height: 1.5;
    color: #2c3e50;
    overflow-x: hidden;
}

/* Base Sidebar Styles */
.sidebar {
    position: fixed;
    top: 0;
    left: -280px;
    width: 280px;
    height: 100vh;
    transition: left 0.3s ease;
    z-index: 1000;
    box-shadow: 2px 0 10px rgba(0,0,0,0.1);
}

/* Admin Sidebar Colors (Default - Blue-Gray) */
.sidebar.sidebar-admin {
    background: #2c3e50;
}

.sidebar.sidebar-admin .sidebar-header h2 {
    color: #fff;
}

.sidebar.sidebar-admin .sidebar-header p {
    color: #bdc3c7;
}

.sidebar.sidebar-admin .menu-item {
    color: #ecf0f1;
}

.sidebar.sidebar-admin .menu-item:hover,
.sidebar.sidebar-admin .menu-item.active {
    background-color: rgba(255,255,255,0.1);
    border-left-color: #95a5a6;
    color: #fff;
}

/* Cashier Sidebar Colors (Green Theme) */
.sidebar.sidebar-cashier {
    background: #2F5249;
}

.sidebar.sidebar-cashier .sidebar-header h2 {
    color: #fff;
}

.sidebar.sidebar-cashier .sidebar-header p {
    color: #a8c5be;
}

.sidebar.sidebar-cashier .menu-item {
    color: #e8f4f1;
}

.sidebar.sidebar-cashier .menu-item:hover,
.sidebar.sidebar-cashier .menu-item.active {
    background-color: rgba(255,255,255,0.15);
    border-left-color: #7fb069;
    color: #fff;
}

.sidebar.active {
    left: 0;
}

.sidebar-header {
    padding: 1.5rem;
    border-bottom: 1px solid rgba(255,255,255,0.1);
    text-align: center;
}

.sidebar-header h2 {
    font-size: 1.3rem;
    margin-bottom: 0.5rem;
    font-weight: 600;
}

.sidebar-header p {
    font-size: 0.9rem;
}

.sidebar-menu {
    padding: 1rem 0;
}

.menu-item {
    display: block;
    padding: 1rem 1.5rem;
    text-decoration: none;
    transition: all 0.3s ease;
    border-left: 3px solid transparent;
    position: relative;
}

.menu-item i {
    margin-right: 0.8rem;
    font-size: 1.1rem;
    width: 20px;
    text-align: center;
}

/* Logout Menu Item Special Styling */
.menu-item.logout-item {
    margin-top: 2rem;
    border-top: 1px solid rgba(255,255,255,0.1);
    padding-top: 1rem;
    position: relative;
}

.menu-item.logout-item:hover {
    background-color: rgba(220, 53, 69, 0.2) !important;
    border-left-color: #dc3545 !important;
}

.menu-item.logout-item.logging-out {
    background-color: rgba(220, 53, 69, 0.3) !important;
    pointer-events: none;
    opacity: 0.8;
}

.menu-item.logout-item.logging-out::after {
    content: '';
    position: absolute;
    right: 1rem;
    top: 50%;
    transform: translateY(-50%);
    width: 16px;
    height: 16px;
    border: 2px solid rgba(255,255,255,0.3);
    border-top: 2px solid white;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

/* Icon classes using Unicode */
.icon-dashboard::before { content: "📊"; }
.icon-users::before { content: "👥"; }
.icon-books::before { content: "📚"; }
.icon-customers::before { content: "🏢"; }
.icon-bills::before { content: "🧾"; }
.icon-help::before { content: "❓"; }
.icon-logout::before { content: "🚪"; }

/* Main Content */
.main-content {
    margin-left: 0;
    min-height: 100vh;
    transition: margin-left 0.3s ease;
}

.main-content.shifted {
    margin-left: 280px;
}

/* Top Navigation - Role-based colors for menu toggle */
.topbar {
    background: #fff;
    padding: 0.8rem 1.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 999;
}

/* Admin Menu Toggle */
.menu-toggle.admin {
    background: #2c3e50;
    color: white;
    border: none;
    padding: 0.6rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.3s ease;
}

.menu-toggle.admin:hover {
    background: #34495e;
}

/* Cashier Menu Toggle */
.menu-toggle.cashier {
    background: #2F5249;
    color: white;
    border: none;
    padding: 0.6rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.3s ease;
}

.menu-toggle.cashier:hover {
    background: #3d6b5e;
}

/* Default menu toggle (fallback) */
.menu-toggle {
    background: #2c3e50;
    color: white;
    border: none;
    padding: 0.6rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.3s ease;
}

.menu-toggle:hover {
    background: #34495e;
}

.page-title {
    font-size: 1.2rem;
    color: #2c3e50;
    font-weight: 600;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 0.8rem;
    color: #2c3e50;
    font-size: 0.9rem;
}

/* Role-based User Avatar Colors */
.user-avatar.admin {
    width: 32px;
    height: 32px;
    background: #2c3e50;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: bold;
    font-size: 0.8rem;
}

.user-avatar.cashier {
    width: 32px;
    height: 32px;
    background: #2F5249;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: bold;
    font-size: 0.8rem;
}

/* Default user avatar */
.user-avatar {
    width: 32px;
    height: 32px;
    background: #2c3e50;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: bold;
    font-size: 0.8rem;
}

/* Welcome Notification Styles */
.welcome-notification {
    position: fixed;
    top: 20px;
    right: 20px;
    background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    color: white;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(40, 167, 69, 0.3);
    z-index: 10000;
    opacity: 0;
    transform: translateX(100%);
    transition: all 0.5s ease;
    max-width: 350px;
    font-size: 0.9rem;
    font-weight: 500;
}

.welcome-notification.show {
    opacity: 1;
    transform: translateX(0);
}

.welcome-notification .icon {
    display: inline-block;
    margin-right: 0.5rem;
    font-size: 1.2rem;
}

/* Overlay for mobile */
.overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 999;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
}

.overlay.active {
    opacity: 1;
    visibility: visible;
}

/* Content Area */
.content-area {
    padding: 1.5rem;
}

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

.breadcrumb {
    color: #6c757d;
    font-size: 0.85rem;
}

.breadcrumb a {
    color: #495057;
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

/* Alert Messages */
.alert {
    padding: 0.8rem 1rem;
    border-radius: 6px;
    margin-bottom: 1.2rem;
    border-left: 4px solid;
    font-size: 0.9rem;
    animation: slideIn 0.3s ease;
}

.alert-success {
    background-color: #d4edda;
    border-left-color: #28a745;
    color: #155724;
}

.alert-error {
    background-color: #f8d7da;
    border-left-color: #dc3545;
    color: #721c24;
}

.alert-info {
    background-color: #cce7ff;
    border-left-color: #3498db;
    color: #0c5aa6;
}

@keyframes slideIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Responsive Design */
@media (min-width: 1024px) {
    .sidebar {
        left: 0;
    }
    
    .main-content {
        margin-left: 280px;
    }
    
    .menu-toggle {
        display: none;
    }
}

@media (max-width: 768px) {
    .welcome-notification {
        top: 10px;
        right: 10px;
        left: 10px;
        max-width: none;
        font-size: 0.85rem;
    }
    
    .topbar {
        padding: 0.7rem;
    }
    
    .content-area {
        padding: 1rem;
    }
    
    .user-info span {
        display: none;
    }
}

/* Additional complete styles */

/* Common Button Styles */
.btn {
    padding: 0.7rem 1.4rem;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    font-size: 0.9rem;
    font-weight: 500;
    transition: all 0.2s ease;
    box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    text-align: center;
    white-space: nowrap;
}

.btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}

.btn-primary {
    background: #007bff;
    color: white;
}

.btn-primary:hover {
    background: #0056b3;
}

.btn-success {
    background: #28a745;
    color: white;
}

.btn-success:hover {
    background: #1e7e34;
}

.btn-warning {
    background: #ffc107;
    color: #212529;
}

.btn-warning:hover {
    background: #e0a800;
}

.btn-danger {
    background: #dc3545;
    color: white;
}

.btn-danger:hover {
    background: #c82333;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background: #545b62;
}

.btn-sm {
    padding: 0.4rem 0.8rem;
    font-size: 0.8rem;
}

/* Form Styles */
.form-container {
    background: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.form-group {
    margin-bottom: 1.2rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #2c3e50;
    font-size: 0.9rem;
}

.required {
    color: #dc3545;
}

.form-control {
    width: 100%;
    padding: 0.8rem;
    border: 1px solid #dee2e6;
    border-radius: 6px;
    font-size: 0.9rem;
    transition: all 0.3s ease;
    background-color: #fff;
}

.form-control:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
    background-color: #fff;
}

.form-control:disabled {
    background-color: #f8f9fa;
    color: #6c757d;
    cursor: not-allowed;
}

.form-control.error {
    border-color: #dc3545;
    box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.25);
}

.form-text {
    font-size: 0.8rem;
    color: #6c757d;
    margin-top: 0.3rem;
}

/* Form Grid */
.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.2rem;
}

.form-group.full-width {
    grid-column: 1 / -1;
}

.form-actions {
    margin-top: 1.5rem;
    padding-top: 1.5rem;
    border-top: 1px solid #e9ecef;
    display: flex;
    gap: 0.8rem;
    align-items: center;
}

/* Input Icons */
.input-group {
    position: relative;
}

.input-group .form-control {
    padding-left: 2.5rem;
}

.input-icon {
    position: absolute;
    left: 0.8rem;
    top: 50%;
    transform: translateY(-50%);
    color: #6c757d;
    font-size: 1rem;
}

/* Table Styles */
.table-container {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    overflow-x: auto;
    overflow-y: visible;
}

.table-header {
    padding: 1.2rem 1.5rem;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #f8f9fa;
    position: sticky;
    top: 0;
    z-index: 10;
}

.table-header h2 {
    color: #2c3e50;
    font-size: 1.1rem;
    font-weight: 600;
}

.table {
    width: 100%;
    border-collapse: collapse;
    min-width: 1000px;
    font-size: 0.9rem;
}

.table th,
.table td {
    padding: 0.8rem;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
    vertical-align: middle;
}

.table th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    white-space: nowrap;
}

.table tbody tr {
    transition: all 0.2s ease;
    background: white;
}

.table tbody tr:hover {
    background-color: #f8f9fa;
}

.table tbody tr:last-child td {
    border-bottom: none;
}

.action-buttons {
    display: flex;
    gap: 0.3rem;
    flex-wrap: nowrap;
    justify-content: flex-start;
    align-items: center;
    min-width: 200px;
}

.action-buttons .btn {
    flex-shrink: 0;
    min-width: 60px;
}

/* Actions Column Fixed Width */
.table th:last-child,
.table td:last-child {
    width: 220px;
    min-width: 220px;
    position: sticky;
    right: 0;
    background: white;
    box-shadow: -2px 0 4px rgba(0,0,0,0.05);
    z-index: 2;
}

.table th:last-child {
    z-index: 3;
    background: #f8f9fa;
}

.table tbody tr:hover td:last-child {
    background: #f8f9fa;
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
    border-left: 4px solid #007bff;
    position: relative;
    overflow: hidden;
}

.stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    width: 60px;
    height: 60px;
    background: linear-gradient(135deg, rgba(0, 123, 255, 0.1), transparent);
    border-radius: 0 0 0 60px;
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

/* Search Container */
.search-container {
    background: white;
    padding: 1.2rem;
    border-radius: 8px;
    margin-bottom: 1.2rem;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.search-form {
    display: flex;
    gap: 0.8rem;
    align-items: center;
}

.search-input {
    flex: 1;
    padding: 0.8rem;
    border: 1px solid #dee2e6;
    border-radius: 6px;
    font-size: 0.9rem;
    transition: all 0.3s ease;
}

.search-input:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 3rem 1.5rem;
    color: #6c757d;
}

.empty-state h3 {
    margin-bottom: 0.8rem;
    color: #495057;
    font-size: 1.2rem;
}

.empty-state p {
    margin-bottom: 1.5rem;
    font-size: 1rem;
}

.empty-state .icon {
    font-size: 3rem;
    margin-bottom: 1rem;
    opacity: 0.5;
}

/* Info Cards */
.info-card {
    background: #f8f9fa;
    padding: 1.2rem;
    border-radius: 6px;
    border-left: 4px solid #007bff;
    margin-bottom: 1rem;
}

.info-card h4 {
    color: #2c3e50;
    margin-bottom: 0.8rem;
    font-size: 1rem;
    font-weight: 600;
}

.info-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.4rem;
    padding: 0.2rem 0;
    font-size: 0.9rem;
}

.info-label {
    font-weight: 500;
    color: #6c757d;
}

.info-value {
    color: #2c3e50;
    font-weight: 500;
}

/* Status Badge */
.status-badge {
    padding: 0.3rem 0.8rem;
    border-radius: 15px;
    font-size: 0.8rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
}

.status-paid {
    background-color: #d4edda;
    color: #155724;
}

.status-pending {
    background-color: #fff3cd;
    color: #856404;
}

.status-cancelled {
    background-color: #f8d7da;
    color: #721c24;
}

/* Loading States */
.loading {
    opacity: 0.6;
    pointer-events: none;
}

.loading::after {
    content: " Processing...";
}

/* Subtle animations */
.form-container,
.table-container,
.stat-card {
    animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Additional responsive styles for smaller screens */
@media (max-width: 1200px) {
    .table {
        min-width: 900px;
    }

    .action-buttons {
        min-width: 180px;
    }

    .table th:last-child,
    .table td:last-child {
        width: 200px;
        min-width: 200px;
    }
}

@media (max-width: 480px) {
    .table {
        min-width: 700px;
        font-size: 0.75rem;
    }

    .table th,
    .table td {
        padding: 0.4rem;
    }

    .action-buttons .btn {
        font-size: 0.7rem;
        padding: 0.3rem 0.5rem;
    }

    .table th:last-child,
    .table td:last-child {
        width: 110px;
        min-width: 110px;
    }

    .stat-card h3 {
        font-size: 1.5rem;
    }

    .stats-grid {
        grid-template-columns: 1fr;
    }
}

</style>

<!-- Welcome Notification -->
<% if ("true".equals(showWelcomeNotification) && sidebarUser != null) { %>
<div class="welcome-notification" id="welcomeNotification">
    <span class="icon">👋</span>
    Welcome back, <%= sidebarUser.getFullName() %>! 
    <% if (Constants.ROLE_ADMIN.equals(sidebarUser.getRole())) { %>
        You're logged in as Administrator.
    <% } else { %>
        You're logged in as Cashier.
    <% } %>
</div>
<% } %>

<!-- Sidebar -->
<div class="sidebar <%= sidebarColorClass %>" id="sidebar">
    <div class="sidebar-header">
        <h2>Redupahana</h2>
        <% if (sidebarUser != null) { %>
            <% if (Constants.ROLE_ADMIN.equals(sidebarUser.getRole())) { %>
                <p>Administrator</p>
            <% } else { %>
                <p>Cashier</p>
            <% } %>
        <% } else { %>
            <p>POS System</p>
        <% } %>
    </div>
    <nav class="sidebar-menu">
        <a href="dashboard" class="menu-item <%= "dashboard".equals(currentPage) ? "active" : "" %>">
            <i class="icon-dashboard"></i>
            Dashboard
        </a>
        <% if (sidebarUser != null && Constants.ROLE_ADMIN.equals(sidebarUser.getRole())) { %>
        <a href="user?action=list" class="menu-item <%= "user".equals(currentPage) ? "active" : "" %>">
            <i class="icon-users"></i>
            User Management
        </a>
        <% } %>
        <a href="book?action=list" class="menu-item <%= "book".equals(currentPage) ? "active" : "" %>">
            <i class="icon-books"></i>
            Book Management
        </a>
        <a href="customer?action=list" class="menu-item <%= "customer".equals(currentPage) ? "active" : "" %>">
            <i class="icon-customers"></i>
            Customer Management
        </a>
        <a href="bill?action=list" class="menu-item <%= "bill".equals(currentPage) ? "active" : "" %>">
            <i class="icon-bills"></i>
            Bill Management
        </a>
        <!-- Help & Support - Only for Cashiers -->
        <% if (sidebarUser != null && !Constants.ROLE_ADMIN.equals(sidebarUser.getRole())) { %>
        <a href="help?action=list" class="menu-item <%= "help".equals(currentPage) ? "active" : "" %>">
            <i class="icon-help"></i>
            Help & Support
        </a>
        <% } %>
        <a href="#" onclick="handleLogout(event)" class="menu-item logout-item" id="logoutMenuItem">
            <i class="icon-logout"></i>
            Logout
        </a>
    </nav>
</div>

<!-- Overlay for mobile -->
<div class="overlay" id="overlay"></div>

<!-- Top Navigation -->
<header class="topbar">
    <div style="display: flex; align-items: center; gap: 1rem;">
        <button class="menu-toggle <%= sidebarUser != null && Constants.ROLE_ADMIN.equals(sidebarUser.getRole()) ? "admin" : "cashier" %>" id="menuToggle">☰</button>
        <h1 class="page-title"><%= pageTitle %></h1>
    </div>
    <div class="user-info">
        <% if (sidebarUser != null) { %>
        <div class="user-avatar <%= Constants.ROLE_ADMIN.equals(sidebarUser.getRole()) ? "admin" : "cashier" %>"><%= sidebarUser.getFullName().substring(0,1).toUpperCase() %></div>
        <span><%= sidebarUser.getFullName() %></span>
        <% } else { %>
        <div class="user-avatar">?</div>
        <span>Guest</span>
        <% } %>
    </div>
</header>

<script>
// Enhanced dashboard functionality with Role-based Sidebar Colors and Logout
document.addEventListener('DOMContentLoaded', function() {
    // Show welcome notification if needed
    const welcomeNotification = document.getElementById('welcomeNotification');
    if (welcomeNotification) {
        setTimeout(() => {
            welcomeNotification.classList.add('show');
            
            // Auto-hide after 4 seconds
            setTimeout(() => {
                welcomeNotification.classList.remove('show');
                setTimeout(() => {
                    welcomeNotification.remove();
                }, 500);
            }, 4000);
        }, 500);
    }

    // Sidebar Toggle Function
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('overlay');

    function toggleSidebar() {
        sidebar.classList.toggle('active');
        overlay.classList.toggle('active');
    }

    if (menuToggle && sidebar && overlay) {
        menuToggle.addEventListener('click', toggleSidebar);
        overlay.addEventListener('click', toggleSidebar);

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 1024) {
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });
    }

    // Auto-hide alerts after 5 seconds with animation
    setTimeout(function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-10px)';
            setTimeout(function() {
                if (alert.parentNode) {
                    alert.remove();
                }
            }, 300);
        });
    }, 5000);

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // ESC key closes sidebar on mobile
        if (e.key === 'Escape' && sidebar.classList.contains('active')) {
            toggleSidebar();
        }
        
        // Ctrl+D for dashboard
        if (e.ctrlKey && e.key === 'd') {
            e.preventDefault();
            window.location.href = 'dashboard';
        }
        
        // Ctrl+B for bills
        if (e.ctrlKey && e.key === 'b') {
            e.preventDefault();
            window.location.href = 'bill?action=list';
        }
    });
});

// Handle logout with animation and message
function handleLogout(event) {
    event.preventDefault();
    
    const logoutMenuItem = document.getElementById('logoutMenuItem');
    const logoutText = logoutMenuItem.querySelector('i').nextSibling;
    
    // Add logging out state
    logoutMenuItem.classList.add('logging-out');
    logoutText.textContent = ' Logging out...';
    
    // Show logout notification
    showLogoutNotification('Logging out...', 'info');
    
    // Redirect after 2 seconds
    setTimeout(() => {
        window.location.href = 'auth?action=logout';
    }, 2000);
}

// Show logout notification function
function showLogoutNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.innerHTML = `<span class="icon">🔄</span> ${message}`;
    notification.className = `welcome-notification ${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(23, 162, 184, 0.3);
        z-index: 10000;
        opacity: 0;
        transform: translateX(100%);
        transition: all 0.5s ease;
        max-width: 350px;
        font-size: 0.9rem;
        font-weight: 500;
    `;
    
    document.body.appendChild(notification);
    
    // Show notification
    setTimeout(() => {
        notification.style.opacity = '1';
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Auto-hide after 3 seconds
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (document.body.contains(notification)) {
                document.body.removeChild(notification);
            }
        }, 500);
    }, 1800);
}

// Enhanced confirm delete function with better styling
function confirmDelete(itemName, itemId) {
    const message = 'Are you sure you want to delete ' + itemName + ' (ID: ' + itemId + ')?\n\nThis action cannot be undone!';
    return confirm(message);
}

// Show notification function
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.textContent = message;
    notification.className = `alert alert-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        min-width: 300px;
        animation: slideInRight 0.3s ease;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            if (document.body.contains(notification)) {
                document.body.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Add slide animations for notifications
const slideStyle = document.createElement('style');
slideStyle.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(slideStyle);

// Make functions globally available
window.confirmDelete = confirmDelete;
window.showNotification = showNotification;
window.handleLogout = handleLogout;

console.log('Enhanced Dashboard with Role-based Sidebar Colors and Logout loaded successfully');
</script>
</body>
</html>