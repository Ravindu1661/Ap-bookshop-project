<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Portal - R-edupahana</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #667eea;
            --secondary-color: #764ba2;
            --success-color: #10b981;
            --info-color: #3b82f6;
        }

        body {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .portal-header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
            padding: 20px 0;
        }

        .portal-content {
            margin-top: 30px;
            margin-bottom: 30px;
        }

        .welcome-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            margin-bottom: 30px;
        }

        .feature-card {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }

        .feature-icon {
            font-size: 3rem;
            margin-bottom: 20px;
            color: var(--primary-color);
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
            color: white;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="portal-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h2 class="mb-0">📚 R-edupahana Customer Portal</h2>
                </div>
                <div class="col-md-4 text-end">
                    <a href="auth?action=logout" class="btn btn-outline-danger">
                        <i class="fas fa-sign-out-alt me-2"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container portal-content">
        <!-- Welcome Card -->
        <div class="welcome-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-3">👋 Welcome, ${customer.name}!</h1>
                    <p class="lead mb-2">Account Number: <strong>${customer.accountNumber}</strong></p>
                    <c:if test="${not empty customer.email}">
                        <p class="mb-2"><i class="fas fa-envelope me-2"></i>${customer.email}</p>
                    </c:if>
                    <c:if test="${not empty customer.phone}">
                        <p class="mb-2"><i class="fas fa-phone me-2"></i>${customer.phone}</p>
                    </c:if>
                    <c:if test="${not empty customer.address}">
                        <p class="mb-0"><i class="fas fa-map-marker-alt me-2"></i>${customer.address}</p>
                    </c:if>
                </div>
                <div class="col-md-4 text-center">
                    <div style="font-size: 5rem; color: var(--success-color);">
                        <i class="fas fa-user-circle"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Features Grid -->
        <div class="row">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-receipt"></i>
                    </div>
                    <h4>Purchase History</h4>
                    <p>View all your past purchases and invoices in one place.</p>
                    <button class="btn btn-primary-custom" onclick="showComingSoon()">
                        <i class="fas fa-eye me-2"></i>View History
                    </button>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-download"></i>
                    </div>
                    <h4>Download Invoices</h4>
                    <p>Download and print your invoices for record keeping.</p>
                    <button class="btn btn-primary-custom" onclick="showComingSoon()">
                        <i class="fas fa-download me-2"></i>Download
                    </button>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <h4>Account Summary</h4>
                    <p>Get detailed insights about your account activity.</p>
                    <button class="btn btn-primary-custom" onclick="showComingSoon()">
                        <i class="fas fa-chart-bar me-2"></i>View Summary
                    </button>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-edit"></i>
                    </div>
                    <h4>Update Profile</h4>
                    <p>Keep your contact information up to date.</p>
                    <button class="btn btn-primary-custom" onclick="showComingSoon()">
                        <i class="fas fa-user-edit me-2"></i>Update Profile
                    </button>
                </div>
            </div>
            <div class="col-md-6">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <h4>Contact Support</h4>
                    <p>Get help with any questions or concerns.</p>
                    <button class="btn btn-primary-custom" onclick="showComingSoon()">
                        <i class="fas fa-phone-alt me-2"></i>Contact Us
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script>
        function showComingSoon() {
            alert('This feature is coming soon! Stay tuned for updates.');
        }
    </script>
</body>
</html>