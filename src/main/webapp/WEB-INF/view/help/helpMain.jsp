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
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "help");
    request.setAttribute("pageTitle", "Help & Support");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Support - Redupahana</title>
    
    <style>
        /* Help page specific styles */
        .help-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .help-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
            position: relative;
            overflow: hidden;
        }
        
        .help-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, #2F5249, #7fb069);
        }
        
        .help-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(47, 82, 73, 0.15);
        }
        
        .help-card-header {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            margin-bottom: 1rem;
        }
        
        .help-icon {
            font-size: 2rem;
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #2F5249, #7fb069);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .help-card h3 {
            color: #2c3e50;
            font-size: 1.2rem;
            font-weight: 600;
            margin: 0;
        }
        
        .help-description {
            color: #6c757d;
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 1.2rem;
        }
        
        .help-features {
            list-style: none;
            padding: 0;
            margin: 0 0 1.2rem 0;
        }
        
        .help-features li {
            padding: 0.3rem 0;
            color: #5a6c7d;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .help-features li::before {
            content: "✓";
            color: #2F5249;
            font-weight: bold;
            font-size: 1rem;
        }
        
        .help-button {
            background: linear-gradient(135deg, #2F5249, #7fb069);
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
            font-size: 0.9rem;
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
        
        .help-button:hover {
            background: linear-gradient(135deg, #3d6b5e, #8bb36e);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(47, 82, 73, 0.3);
            color: white;
            text-decoration: none;
        }
        
        .welcome-section {
            background: linear-gradient(135deg, #2F5249, #7fb069);
            color: white;
            padding: 2.5rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .welcome-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 50%);
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }
        
        .welcome-section h1 {
            margin: 0 0 0.8rem 0;
            font-size: 2.2rem;
            font-weight: 700;
            position: relative;
            z-index: 1;
        }
        
        .welcome-section p {
            margin: 0;
            font-size: 1.2rem;
            opacity: 0.95;
            position: relative;
            z-index: 1;
        }
        
        .quick-actions {
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            border: 1px solid #dee2e6;
        }
        
        .quick-actions h2 {
            color: #2c3e50;
            margin: 0 0 1.5rem 0;
            font-size: 1.4rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 600;
        }
        
        .quick-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        .quick-btn {
            background: white;
            color: #2F5249;
            padding: 0.8rem 1.5rem;
            border: 2px solid #2F5249;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .quick-btn:hover {
            background: #2F5249;
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(47, 82, 73, 0.2);
        }

        /* Contact Section */
        .contact-section {
            background: linear-gradient(135deg, #ffffff, #f8f9fa);
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            border: 1px solid #e9ecef;
            text-align: center;
        }

        .contact-section h2 {
            color: #2c3e50;
            margin: 0 0 1.5rem 0;
            font-size: 1.4rem;
            font-weight: 600;
        }

        .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .contact-item {
            background: white;
            padding: 1.2rem;
            border-radius: 12px;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .contact-item:hover {
            border-color: #2F5249;
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(47, 82, 73, 0.15);
        }

        .contact-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .contact-label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.3rem;
        }

        .contact-value {
            color: #2F5249;
            font-weight: 500;
        }

        .help-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        .user-guide-section {
            background: linear-gradient(135deg, #e8f5e8, #f0f8f0);
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            border: 1px solid #d4edda;
            text-align: center;
        }

        .user-guide-section h2 {
            color: #2c3e50;
            margin: 0 0 1rem 0;
            font-size: 1.4rem;
            font-weight: 600;
        }

        .user-guide-section p {
            color: #6c757d;
            font-size: 1rem;
            margin-bottom: 1.5rem;
        }

        .guide-button {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            padding: 1rem 2rem;
            border: none;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
        }

        .guide-button:hover {
            background: linear-gradient(135deg, #218838, #1ea085);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
            color: white;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <!-- Include complete sidebar component -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <main class="content-area">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <h1>🆘 Help & Support Center</h1>
                <p>Welcome <%= loggedUser.getFullName() %>! We're here to help you master the Redupahana POS System</p>
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

            <!-- User Guide Section -->
            <div class="user-guide-section">
                <h2>📖 Complete User Guide</h2>
                <p>Get step-by-step instructions on how to use every feature of the Redupahana POS System</p>
                <a href="help?action=userGuide" class="guide-button">
                    📚 Open User Guide →
                </a>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions">
                <h2>⚡ Quick Navigation</h2>
                <div class="quick-buttons">
                    <a href="dashboard" class="quick-btn">📊 Dashboard</a>
                    <a href="book?action=list" class="quick-btn">📚 Books</a>
                    <a href="customer?action=list" class="quick-btn">🏢 Customers</a>
                    <a href="bill?action=list" class="quick-btn">🧾 Bills</a>
                    <a href="book?action=add" class="quick-btn">➕ Add Book</a>
                    <a href="customer?action=add" class="quick-btn">➕ Add Customer</a>
                    <a href="bill?action=create" class="quick-btn">🛒 Create Bill</a>
                </div>
            </div>

            <!-- Help Categories -->
            <div class="help-grid">
                <!-- Book Management -->
                <div class="help-card">
                    <div class="help-card-header">
                        <div class="help-icon">📚</div>
                        <h3>Book Management</h3>
                    </div>
                    <p class="help-description">
                        Complete guide to managing your book inventory effectively.
                    </p>
                    <ul class="help-features">
                        <li>Add new books with auto-generated codes</li>
                        <li>Update pricing and stock quantities</li>
                        <li>Advanced search and filtering options</li>
                        <li>Track book performance and sales</li>
                    </ul>
                    <div class="help-actions">
                        <a href="book?action=list" class="help-button">📚 Manage Books</a>
                        <a href="book?action=add" class="help-button">➕ Add Book</a>
                    </div>
                </div>

                <!-- Customer Management -->
                <div class="help-card">
                    <div class="help-card-header">
                        <div class="help-icon">🏢</div>
                        <h3>Customer Management</h3>
                    </div>
                    <p class="help-description">
                        Build strong customer relationships with our comprehensive management tools.
                    </p>
                    <ul class="help-features">
                        <li>Register customers with unique account numbers</li>
                        <li>Maintain detailed contact information</li>
                        <li>Track customer purchase history</li>
                        <li>Quick customer search and updates</li>
                    </ul>
                    <div class="help-actions">
                        <a href="customer?action=list" class="help-button">🏢 Manage Customers</a>
                        <a href="customer?action=add" class="help-button">➕ Add Customer</a>
                    </div>
                </div>

                <!-- Bill Management -->
                <div class="help-card">
                    <div class="help-card-header">
                        <div class="help-icon">🧾</div>
                        <h3>Bill Management</h3>
                    </div>
                    <p class="help-description">
                        Streamline your billing process with powerful transaction management.
                    </p>
                    <ul class="help-features">
                        <li>Create professional bills instantly</li>
                        <li>Apply discounts and handle multiple items</li>
                        <li>Print and manage payment status</li>
                        <li>Complete transaction history tracking</li>
                    </ul>
                    <div class="help-actions">
                        <a href="bill?action=list" class="help-button">🧾 View Bills</a>
                        <a href="bill?action=create" class="help-button">🛒 Create Bill</a>
                    </div>
                </div>

                <!-- System Navigation -->
                <div class="help-card">
                    <div class="help-card-header">
                        <div class="help-icon">🧭</div>
                        <h3>System Navigation</h3>
                    </div>
                    <p class="help-description">
                        Master the system interface for maximum productivity.
                    </p>
                    <ul class="help-features">
                        <li>Use the sidebar menu for main navigation</li>
                        <li>Search functions in every module</li>
                        <li>Keyboard shortcuts for faster work</li>
                        <li>Always logout when session ends</li>
                    </ul>
                    <div class="help-actions">
                        <a href="dashboard" class="help-button">📊 Dashboard</a>
                        <a href="help?action=userGuide" class="help-button">📖 User Guide</a>
                    </div>
                </div>
            </div>

            <!-- Contact Support -->
            <div class="contact-section">
                <h2>📞 Need Personal Assistance?</h2>
                <div class="contact-grid">
                    <div class="contact-item" onclick="window.location.href='tel:+94771234567'">
                        <div class="contact-icon">📱</div>
                        <div class="contact-label">Call Us</div>
                        <div class="contact-value">+94 77 123 4567</div>
                    </div>
                    <div class="contact-item" onclick="window.location.href='mailto:support@redupahana.lk'">
                        <div class="contact-icon">📧</div>
                        <div class="contact-label">Email Support</div>
                        <div class="contact-value">support@redupahana.lk</div>
                    </div>
                    <div class="contact-item" onclick="window.location.href='https://wa.me/94771234567'">
                        <div class="contact-icon">💬</div>
                        <div class="contact-label">WhatsApp</div>
                        <div class="contact-value">+94 77 123 4567</div>
                    </div>
                </div>
                <p style="color: #6c757d; margin: 0; font-size: 0.9rem;">
                    Available 24/7 • Response within 2 hours • Free technical support
                </p>
            </div>

            <!-- System Info -->
            <div class="info-card">
                <h4>ℹ️ System Information</h4>
                <div class="info-row">
                    <span class="info-label">System Version:</span>
                    <span class="info-value">Redupahana POS v1.0</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Your Role:</span>
                    <span class="info-value">Cashier</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Login Status:</span>
                    <span class="info-value">Active Session</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Support Level:</span>
                    <span class="info-value">Full Access • 24/7 Support</span>
                </div>
            </div>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🆘 Help & Support Center loaded');
            
            // Animate help cards on load
            const helpCards = document.querySelectorAll('.help-card');
            helpCards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(30px)';
                
                setTimeout(() => {
                    card.style.transition = 'all 0.6s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 150);
            });
            
            // Animate other sections
            const sections = document.querySelectorAll('.quick-actions, .contact-section, .user-guide-section');
            sections.forEach((section, index) => {
                section.style.opacity = '0';
                section.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    section.style.transition = 'all 0.5s ease';
                    section.style.opacity = '1';
                    section.style.transform = 'translateY(0)';
                }, (index + 1) * 200);
            });
            
            // Contact item click handlers with better UX
            document.querySelectorAll('.contact-item').forEach(item => {
                item.addEventListener('click', function(e) {
                    this.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        this.style.transform = 'translateY(-3px)';
                    }, 150);
                });
            });
            
            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if (e.altKey && e.key === 'h') {
                    e.preventDefault();
                    window.location.href = 'help?action=list';
                }
                
                if (e.altKey && e.key === 'g') {
                    e.preventDefault();
                    window.location.href = 'help?action=userGuide';
                }
                
                if (e.altKey && e.key === 'c') {
                    e.preventDefault();
                    window.location.href = 'tel:+94771234567';
                }
            });
            
            console.log('💡 Shortcuts: Alt+H=Help, Alt+G=User Guide, Alt+C=Call Support');
        });
    </script>
</body>
</html>