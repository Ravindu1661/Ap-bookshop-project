<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - R-edupahana</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .error-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 500px;
            margin: 20px;
            text-align: center;
        }

        .error-icon {
            font-size: 4rem;
            margin-bottom: 20px;
        }

        .error-title {
            font-size: 2rem;
            color: #e53e3e;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .error-message {
            color: #666;
            font-size: 1.1rem;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .error-details {
            background: #fed7d7;
            border: 1px solid #feb2b2;
            color: #9b2c2c;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: left;
            font-family: monospace;
            font-size: 14px;
            word-break: break-all;
        }

        .error-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a6fd8;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: #718096;
            color: white;
        }

        .btn-secondary:hover {
            background: #4a5568;
            transform: translateY(-2px);
        }

        .btn-home {
            background: #48bb78;
            color: white;
        }

        .btn-home:hover {
            background: #38a169;
            transform: translateY(-2px);
        }

        .error-footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
            color: #666;
            font-size: 12px;
        }

        @media (max-width: 480px) {
            .error-container {
                padding: 30px 20px;
            }
            
            .error-title {
                font-size: 1.5rem;
            }
            
            .error-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">⚠️</div>
        
        <h1 class="error-title">Oops! Something went wrong</h1>
        
        <div class="error-message">
            <c:choose>
                <c:when test="${not empty errorMessage}">
                    ${errorMessage}
                </c:when>
                <c:otherwise>
                    An unexpected error has occurred. Please try again later.
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Error Details (only show in development) -->
        <c:if test="${not empty errorDetails}">
            <div class="error-details">
                <strong>Error Details:</strong><br>
                ${errorDetails}
            </div>
        </c:if>

        <!-- Action Buttons -->
        <div class="error-actions">
            <button onclick="history.back()" class="btn btn-secondary">
                ← Go Back
            </button>
            
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                🏠 Dashboard
            </a>
            
            <a href="${pageContext.request.contextPath}/auth" class="btn btn-home">
                🔑 Login
            </a>
        </div>

        <!-- Footer -->
        <div class="error-footer">
            If this problem persists, please contact the system administrator.<br>
            Error occurred at: <script>document.write(new Date().toLocaleString());</script>
        </div>
    </div>

    <script>
        // Automatically redirect to login if session expired
        if (window.location.href.includes('session') || window.location.href.includes('timeout')) {
            setTimeout(() => {
                window.location.href = '${pageContext.request.contextPath}/auth';
            }, 3000);
        }

        // Log error details for debugging (in development only)
        console.log('Error Page Details:', {
            timestamp: new Date().toISOString(),
            url: window.location.href,
            referrer: document.referrer,
            userAgent: navigator.userAgent
        });
    </script>
</body>
</html>