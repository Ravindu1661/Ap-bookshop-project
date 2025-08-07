<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    // Check if user is logged in
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check if user is cashier (only cashiers can access help section)
    if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("dashboard");
        return;
    }
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "help");
    request.setAttribute("pageTitle", "Help & Support");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Support - Redupahana POS</title>
    <link rel="icon" type="image/x-icon" href="assets/favicon.ico">
</head>

<!-- Include Sidebar -->
 <%@ include file="../../includes/sidebar.jsp" %>

<!-- Main Content -->
<main class="main-content">
    <div class="content-area">
        <!-- Page Header -->
        <div class="page-header">
            <h1>Help & Support</h1>
            <div class="breadcrumb">
                <a href="dashboard">Dashboard</a> > Help & Support
            </div>
        </div>

        <!-- Welcome Section -->
        <div class="form-container">
            <h2 style="color: #2F5249; margin-bottom: 1rem; display: flex; align-items: center; gap: 0.5rem;">
                <span style="font-size: 1.5rem;">🎯</span> Welcome to Help Center
            </h2>
            <p style="color: #6c757d; margin-bottom: 1.5rem;">
                Hello <strong><%= loggedUser.getFullName() %></strong>! Here you can find helpful guides and support information to use the Redupahana POS system effectively.
            </p>
        </div>

        <!-- Help Categories -->
        <div class="stats-grid" style="margin-bottom: 2rem;">
            <div class="stat-card" style="border-left-color: #2F5249; text-align: left; padding: 1.5rem;">
                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem;">
                    <span style="font-size: 2rem;">📚</span>
                    <h3 style="margin: 0; color: #2F5249;">Quick Start Guide</h3>
                </div>
                <p style="margin-bottom: 1rem; color: #495057;">Learn the basics of using the POS system</p>
                <ul style="color: #6c757d; line-height: 1.6;">
                    <li>How to log in and navigate</li>
                    <li>Understanding the dashboard</li>
                    <li>Basic system navigation</li>
                </ul>
            </div>

            <div class="stat-card" style="border-left-color: #28a745; text-align: left; padding: 1.5rem;">
                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem;">
                    <span style="font-size: 2rem;">🛒</span>
                    <h3 style="margin: 0; color: #28a745;">Sales Management</h3>
                </div>
                <p style="margin-bottom: 1rem; color: #495057;">Master the art of processing sales</p>
                <ul style="color: #6c757d; line-height: 1.6;">
                    <li>Creating new bills</li>
                    <li>Managing customer information</li>
                    <li>Processing payments</li>
                </ul>
            </div>

            <div class="stat-card" style="border-left-color: #ffc107; text-align: left; padding: 1.5rem;">
                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem;">
                    <span style="font-size: 2rem;">📖</span>
                    <h3 style="margin: 0; color: #e0a800;">Book Management</h3>
                </div>
                <p style="margin-bottom: 1rem; color: #495057;">Handle book inventory efficiently</p>
                <ul style="color: #6c757d; line-height: 1.6;">
                    <li>Search and find books</li>
                    <li>Check book availability</li>
                    <li>Update book information</li>
                </ul>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="form-container">
            <h2 style="color: #2c3e50; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
                <span style="font-size: 1.3rem;">❓</span> Frequently Asked Questions
            </h2>
            
            <div style="margin-bottom: 2rem;">
                <details style="margin-bottom: 1rem; border: 1px solid #e9ecef; border-radius: 6px; padding: 1rem;">
                    <summary style="cursor: pointer; font-weight: 600; color: #2c3e50; padding: 0.5rem;">
                        How do I create a new bill for a customer?
                    </summary>
                    <div style="padding-top: 1rem; color: #6c757d; line-height: 1.6;">
                        <p><strong>Step 1:</strong> Go to "Bill Management" from the sidebar menu</p>
                        <p><strong>Step 2:</strong> Click on "Create New Bill" button</p>
                        <p><strong>Step 3:</strong> Select or add customer information</p>
                        <p><strong>Step 4:</strong> Add books to the bill by searching and selecting</p>
                        <p><strong>Step 5:</strong> Review the total amount and complete the transaction</p>
                    </div>
                </details>

                <details style="margin-bottom: 1rem; border: 1px solid #e9ecef; border-radius: 6px; padding: 1rem;">
                    <summary style="cursor: pointer; font-weight: 600; color: #2c3e50; padding: 0.5rem;">
                        How do I search for books in the inventory?
                    </summary>
                    <div style="padding-top: 1rem; color: #6c757d; line-height: 1.6;">
                        <p><strong>Method 1:</strong> Use the search bar in Book Management</p>
                        <p><strong>Method 2:</strong> Filter by categories or publishers</p>
                        <p><strong>Method 3:</strong> Search by ISBN or title keywords</p>
                        <p><strong>Tip:</strong> Use partial keywords for better search results</p>
                    </div>
                </details>

                <details style="margin-bottom: 1rem; border: 1px solid #e9ecef; border-radius: 6px; padding: 1rem;">
                    <summary style="cursor: pointer; font-weight: 600; color: #2c3e50; padding: 0.5rem;">
                        What should I do if I encounter an error?
                    </summary>
                    <div style="padding-top: 1rem; color: #6c757d; line-height: 1.6;">
                        <p><strong>Step 1:</strong> Take note of the error message</p>
                        <p><strong>Step 2:</strong> Try refreshing the page (F5)</p>
                        <p><strong>Step 3:</strong> If error persists, contact your administrator</p>
                        <p><strong>Important:</strong> Don't close the browser tab until issue is resolved</p>
                    </div>
                </details>

                <details style="margin-bottom: 1rem; border: 1px solid #e9ecef; border-radius: 6px; padding: 1rem;">
                    <summary style="cursor: pointer; font-weight: 600; color: #2c3e50; padding: 0.5rem;">
                        How do I logout safely from the system?
                    </summary>
                    <div style="padding-top: 1rem; color: #6c757d; line-height: 1.6;">
                        <p><strong>Method 1:</strong> Click the "Logout" button in the sidebar menu</p>
                        <p><strong>Method 2:</strong> The system will automatically log you out after inactivity</p>
                        <p><strong>Important:</strong> Always logout properly before closing the browser</p>
                        <p><strong>Security:</strong> Never leave your session open on shared computers</p>
                    </div>
                </details>
            </div>
        </div>

        <!-- Contact Information -->
        <div class="form-container">
            <h2 style="color: #2c3e50; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
                <span style="font-size: 1.3rem;">📞</span> Need More Help?
            </h2>
            
            <div class="form-grid">
                <div class="info-card">
                    <h4 style="color: #2F5249;">📧 Email Support</h4>
                    <p style="color: #6c757d; margin-bottom: 0.5rem;">For technical issues and questions:</p>
                    <p style="color: #2c3e50; font-weight: 600;">support@redupahana.lk</p>
                </div>
                
                <div class="info-card">
                    <h4 style="color: #2F5249;">📱 Phone Support</h4>
                    <p style="color: #6c757d; margin-bottom: 0.5rem;">Call us during business hours:</p>
                    <p style="color: #2c3e50; font-weight: 600;">+94 37 222 5555</p>
                </div>
            </div>
            
            <div class="info-card" style="margin-top: 1rem; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);">
                <h4 style="color: #2c3e50;">⏰ Support Hours</h4>
                <div class="info-row">
                    <span class="info-label">Monday - Friday:</span>
                    <span class="info-value">8:00 AM - 6:00 PM</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Saturday:</span>
                    <span class="info-value">9:00 AM - 1:00 PM</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Sunday:</span>
                    <span class="info-value">Closed</span>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="form-container" style="text-align: center;">
            <h3 style="color: #2c3e50; margin-bottom: 1.5rem;">Quick Actions</h3>
            <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
                <a href="dashboard" class="btn btn-primary">
                    <span>📊</span> Go to Dashboard
                </a>
                <a href="bill?action=list" class="btn btn-success">
                    <span>🧾</span> Manage Bills
                </a>
                <a href="book?action=list" class="btn btn-secondary">
                    <span>📚</span> Browse Books
                </a>
            </div>
        </div>
    </div>
</main>

<style>
/* Additional styles for help section */
details summary {
    transition: all 0.3s ease;
}

details[open] summary {
    color: #2F5249 !important;
    font-weight: 700;
}

details summary:hover {
    background-color: #f8f9fa;
    border-radius: 4px;
}

.btn span {
    margin-right: 0.3rem;
}

@media (max-width: 768px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</html>