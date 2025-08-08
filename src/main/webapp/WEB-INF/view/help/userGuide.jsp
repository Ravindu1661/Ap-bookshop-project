<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    // Only allow cashiers
    if (Constants.ROLE_ADMIN.equals(loggedUser.getRole())) {
        response.sendRedirect("dashboard");
        return;
    }
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "help");
    request.setAttribute("pageTitle", "User Guide");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Guide - Redupahana</title>
    
    <style>
        /* User Guide specific styles */
        .guide-container {
            max-width: 900px;
            margin: 0 auto;
        }
        
        .guide-header {
            background: linear-gradient(135deg, #2F5249, #7fb069);
            color: white;
            padding: 2.5rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .guide-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 50%);
            animation: float 8s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-15px) rotate(180deg); }
        }
        
        .guide-header h1 {
            margin: 0 0 0.5rem 0;
            font-size: 2.2rem;
            font-weight: 700;
            position: relative;
            z-index: 1;
        }
        
        .guide-header p {
            margin: 0;
            font-size: 1.1rem;
            opacity: 0.9;
            position: relative;
            z-index: 1;
        }
        
        .guide-nav {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border: 1px solid #e9ecef;
        }
        
        .guide-nav h3 {
            color: #2c3e50;
            margin: 0 0 1rem 0;
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .guide-nav-links {
            display: flex;
            flex-wrap: wrap;
            gap: 0.8rem;
        }
        
        .guide-nav-link {
            background: #f8f9fa;
            color: #2F5249;
            padding: 0.6rem 1.2rem;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }
        
        .guide-nav-link:hover {
            background: #2F5249;
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
        }
        
        .guide-section {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border: 1px solid #e9ecef;
            position: relative;
        }
        
        .guide-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(180deg, #2F5249, #7fb069);
            border-radius: 2px;
        }
        
        .guide-section h2 {
            color: #2c3e50;
            margin: 0 0 1rem 0;
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .guide-section h3 {
            color: #2F5249;
            margin: 1.5rem 0 0.8rem 0;
            font-size: 1.1rem;
            font-weight: 600;
        }
        
        .guide-section p {
            color: #6c757d;
            line-height: 1.7;
            margin-bottom: 1rem;
        }
        
        .guide-steps {
            list-style: none;
            padding: 0;
            margin: 1rem 0;
        }
        
        .guide-steps li {
            background: #f8f9fa;
            padding: 0.8rem 1rem;
            margin-bottom: 0.8rem;
            border-radius: 8px;
            border-left: 4px solid #2F5249;
            position: relative;
            padding-left: 3rem;
        }
        
        .guide-steps li::before {
            content: counter(step-counter);
            counter-increment: step-counter;
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: #2F5249;
            color: white;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 0.8rem;
        }
        
        .guide-steps {
            counter-reset: step-counter;
        }
        
        .guide-tips {
            background: linear-gradient(135deg, #e8f5e8, #f0f8f0);
            padding: 1.2rem;
            border-radius: 8px;
            border: 1px solid #d4edda;
            margin: 1rem 0;
        }
        
        .guide-tips h4 {
            color: #2F5249;
            margin: 0 0 0.8rem 0;
            font-size: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .guide-tips ul {
            margin: 0;
            padding-left: 1.2rem;
        }
        
        .guide-tips li {
            color: #5a6c7d;
            margin-bottom: 0.3rem;
        }
        
        .back-button {
            background: linear-gradient(135deg, #6c757d, #868e96);
            color: white;
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 500;
            transition: all 0.3s ease;
            margin-bottom: 2rem;
        }
        
        .back-button:hover {
            background: linear-gradient(135deg, #5a6268, #6f757b);
            transform: translateY(-2px);
            color: white;
            text-decoration: none;
        }
        
        .quick-links {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
        }
        
        .quick-links h3 {
            color: #2c3e50;
            margin: 0 0 1rem 0;
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .quick-link-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .quick-link {
            background: white;
            padding: 1rem;
            border-radius: 8px;
            text-decoration: none;
            color: #2F5249;
            font-weight: 500;
            transition: all 0.3s ease;
            border: 1px solid #dee2e6;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .quick-link:hover {
            background: #2F5249;
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <div class="guide-container">
                <!-- Back Button -->
                <a href="help?action=list" class="back-button">
                    ← Back to Help Center
                </a>

                <!-- Guide Header -->
                <div class="guide-header">
                    <h1>📖 Complete User Guide</h1>
                    <p>Master the Redupahana POS System - Step by step instructions for every feature</p>
                </div>

                <!-- Quick Navigation -->
                <div class="guide-nav">
                    <h3>📋 Quick Navigation</h3>
                    <div class="guide-nav-links">
                        <a href="#getting-started" class="guide-nav-link">🚀 Getting Started</a>
                        <a href="#book-management" class="guide-nav-link">📚 Book Management</a>
                        <a href="#customer-management" class="guide-nav-link">🏢 Customer Management</a>
                        <a href="#bill-management" class="guide-nav-link">🧾 Bill Management</a>
                        <a href="#shortcuts" class="guide-nav-link">⌨️ Shortcuts</a>
                    </div>
                </div>

                <!-- Quick Links -->
                <div class="quick-links">
                    <h3>🔗 Quick Actions</h3>
                    <div class="quick-link-grid">
                        <a href="dashboard" class="quick-link">📊 Go to Dashboard</a>
                        <a href="book?action=add" class="quick-link">➕ Add New Book</a>
                        <a href="customer?action=add" class="quick-link">👤 Add Customer</a>
                        <a href="bill?action=create" class="quick-link">🛒 Create Bill</a>
                    </div>
                </div>

                <!-- Getting Started -->
                <div id="getting-started" class="guide-section">
                    <h2>🚀 Getting Started</h2>
                    <p>Welcome to Redupahana POS System! This guide will help you understand the basic navigation and core features.</p>
                    
                    <h3>System Overview</h3>
                    <p>The Redupahana POS System is designed specifically for bookstores to manage inventory, customers, and sales efficiently.</p>
                    
                    <ol class="guide-steps">
                        <li>After logging in, you'll see the Dashboard with an overview of your system</li>
                        <li>Use the sidebar menu on the left to navigate between different modules</li>
                        <li>The top bar shows your current page and user information</li>
                        <li>Each page has search functionality to quickly find what you need</li>
                        <li>Always remember to logout when you're finished working</li>
                    </ol>

                    <div class="guide-tips">
                        <h4>💡 Pro Tips</h4>
                        <ul>
                            <li>The sidebar will collapse on smaller screens - use the menu button to open it</li>
                            <li>Look for keyboard shortcuts mentioned throughout the system</li>
                            <li>Green messages indicate successful actions, red messages indicate errors</li>
                            <li>Your role as Cashier gives you access to all day-to-day operations</li>
                        </ul>
                    </div>
                </div>

                <!-- Book Management -->
                <div id="book-management" class="guide-section">
                    <h2>📚 Book Management</h2>
                    <p>Learn how to effectively manage your book inventory, from adding new books to tracking stock levels.</p>
                    
                    <h3>Adding a New Book</h3>
                    <ol class="guide-steps">
                        <li>Click "Book Management" in the sidebar</li>
                        <li>Click the "➕ Add New Book" button</li>
                        <li>Fill in the required fields: Title, Author, Price, and Stock Quantity</li>
                        <li>Book Code will be auto-generated if left empty</li>
                        <li>Add optional details like ISBN, Publisher, Publication Year</li>
                        <li>Click "Add Book" to save</li>
                    </ol>

                    <h3>Managing Existing Books</h3>
                    <ol class="guide-steps">
                        <li>Use the search bar to find specific books by title, author, or ISBN</li>
                        <li>Click "👁️ View" to see complete book details</li>
                        <li>Click "✏️ Edit" to update book information or stock levels</li>
                        <li>Use "🗑️ Delete" carefully - this will remove the book permanently</li>
                    </ol>

                    <div class="guide-tips">
                        <h4>📚 Book Management Tips</h4>
                        <ul>
                            <li>Keep stock quantities updated to avoid overselling</li>
                            <li>Use descriptive titles and accurate author names for better searching</li>
                            <li>ISBN numbers help identify books uniquely</li>
                            <li>Regular price updates help maintain competitive pricing</li>
                        </ul>
                    </div>
                </div>

                <!-- Customer Management -->
                <div id="customer-management" class="guide-section">
                    <h2>🏢 Customer Management</h2>
                    <p>Build and maintain strong customer relationships with our comprehensive customer management system.</p>
                    
                    <h3>Registering a New Customer</h3>
                    <ol class="guide-steps">
                        <li>Navigate to "Customer Management" from the sidebar</li>
                        <li>Click "➕ Add New Customer" button</li>
                        <li>Enter the customer's name (required)</li>
                        <li>Add phone number for contact (recommended)</li>
                        <li>Include email address if available</li>
                        <li>Add physical address for delivery purposes</li>
                        <li>Account number will be generated automatically</li>
                        <li>Click "Add Customer" to save</li>
                    </ol>

                    <h3>Managing Customer Information</h3>
                    <ol class="guide-steps">
                        <li>Search for customers using name, account number, phone, or email</li>
                        <li>View complete customer details including purchase history</li>
                        <li>Update contact information as needed</li>
                        <li>Track customer transactions and preferences</li>
                    </ol>

                    <div class="guide-tips">
                        <h4>🏢 Customer Management Tips</h4>
                        <ul>
                            <li>Always ask for phone numbers - they're great for quick customer lookup</li>
                            <li>Keep customer information up-to-date for better service</li>
                            <li>Use the search function to quickly find returning customers</li>
                            <li>Email addresses enable digital receipt delivery</li>
                        </ul>
                    </div>
                </div>

                <!-- Bill Management -->
                <div id="bill-management" class="guide-section">
                    <h2>🧾 Bill Management</h2>
                    <p>Master the billing process from creating new bills to managing payments and printing receipts.</p>
                    
                    <h3>Creating a New Bill</h3>
                    <ol class="guide-steps">
                        <li>Go to "Bill Management" and click "🛒 Create Bill"</li>
                        <li>Select the customer from the dropdown list</li>
                        <li>Add books to the bill by selecting book, quantity, and unit price</li>
                        <li>You can add multiple books to a single bill</li>
                        <li>Apply discount if applicable</li>
                        <li>Set payment status (Paid/Pending)</li>
                        <li>Review the total amount and click "Create Bill"</li>
                    </ol>

                    <h3>Managing Bills</h3>
                    <ol class="guide-steps">
                        <li>View all bills in the Bill Management section</li>
                        <li>Search bills by bill number, customer name, or date</li>
                        <li>Click "👁️ View" to see complete bill details</li>
                        <li>Use "🖨️ Print" to generate customer receipts</li>
                        <li>Update payment status if payments are received later</li>
                    </ol>

                    <div class="guide-tips">
                        <h4>🧾 Billing Tips</h4>
                        <ul>
                            <li>Double-check quantities and prices before creating bills</li>
                            <li>Print receipts immediately for customer records</li>
                            <li>Keep track of pending payments for follow-up</li>
                            <li>Use the search function to quickly find specific bills</li>
                        </ul>
                    </div>
                </div>

                <!-- Keyboard Shortcuts -->
                <div id="shortcuts" class="guide-section">
                    <h2>⌨️ Keyboard Shortcuts</h2>
                    <p>Work faster with these handy keyboard shortcuts available throughout the system.</p>
                    
                    <h3>Global Shortcuts</h3>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin: 1rem 0;">
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Ctrl + D</strong><br>
                            <span style="color: #6c757d;">Go to Dashboard</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Ctrl + B</strong><br>
                            <span style="color: #6c757d;">Go to Bills</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Alt + N</strong><br>
                            <span style="color: #6c757d;">Add New Customer</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Alt + H</strong><br>
                            <span style="color: #6c757d;">Open Help Center</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Ctrl + F</strong><br>
                            <span style="color: #6c757d;">Focus Search Bar</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 0.8rem; border-radius: 6px; border-left: 4px solid #2F5249;">
                            <strong>Esc</strong><br>
                            <span style="color: #6c757d;">Close Sidebar (Mobile)</span>
                        </div>
                    </div>

                    <div class="guide-tips">
                        <h4>⌨️ Shortcut Tips</h4>
                        <ul>
                            <li>Shortcuts work on most pages throughout the system</li>
                            <li>Use Ctrl+F to quickly focus on search bars in any module</li>
                            <li>ESC key closes the sidebar on mobile devices</li>
                            <li>More shortcuts are displayed in tooltips throughout the system</li>
                        </ul>
                    </div>
                </div>

                <!-- Contact Support -->
                <div class="guide-section">
                    <h2>📞 Need More Help?</h2>
                    <p>If you can't find what you're looking for in this guide, don't hesitate to reach out for personal assistance.</p>
                    
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin: 1.5rem 0;">
                        <div style="background: #f8f9fa; padding: 1.2rem; border-radius: 8px; text-align: center; cursor: pointer;" onclick="window.location.href='tel:+94771234567'">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">📱</div>
                            <strong>Call Support</strong><br>
                            <span style="color: #2F5249;">+94 77 123 4567</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 1.2rem; border-radius: 8px; text-align: center; cursor: pointer;" onclick="window.location.href='mailto:support@redupahana.lk'">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">📧</div>
                            <strong>Email Us</strong><br>
                            <span style="color: #2F5249;">support@redupahana.lk</span>
                        </div>
                        <div style="background: #f8f9fa; padding: 1.2rem; border-radius: 8px; text-align: center; cursor: pointer;" onclick="window.location.href='https://wa.me/94771234567'">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">💬</div>
                            <strong>WhatsApp</strong><br>
                            <span style="color: #2F5249;">+94 77 123 4567</span>
                        </div>
                    </div>
                </div>

                <!-- Back to Help Center -->
                <div style="text-align: center; margin: 2rem 0;">
                    <a href="help?action=list" class="back-button">
                        ← Back to Help Center
                    </a>
                </div>
            </div>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('📖 User Guide loaded');
            
            // Smooth scrolling for navigation links
            document.querySelectorAll('.guide-nav-link').forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    const targetId = this.getAttribute('href').substring(1);
                    const targetElement = document.getElementById(targetId);
                    
                    if (targetElement) {
                        targetElement.scrollIntoView({
                            behavior: 'smooth',
                            block: 'start'
                        });
                        
                        // Highlight the section briefly
                        targetElement.style.backgroundColor = '#f8f9fa';
                        setTimeout(() => {
                            targetElement.style.backgroundColor = 'white';
                        }, 2000);
                    }
                });
            });
            
            // Animate sections on scroll
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            });
            
            document.querySelectorAll('.guide-section').forEach(section => {
                section.style.opacity = '0';
                section.style.transform = 'translateY(20px)';
                section.style.transition = 'all 0.6s ease';
                observer.observe(section);
            });
            
            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if (e.altKey && e.key === 'h') {
                    e.preventDefault();
                    window.location.href = 'help?action=list';
                }
            });
            
            console.log('💡 Guide loaded with smooth navigation and animations');
        });
    </script>
</body>
</html>