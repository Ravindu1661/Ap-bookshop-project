<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>R-edupahana - Online Billing System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .welcome-container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        .logo {
            font-size: 4rem;
            margin-bottom: 20px;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
        }
        p {
            color: #666;
            margin-bottom: 30px;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-weight: bold;
            transition: transform 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
    </style>
</head>
<body>
    <div class="welcome-container">
        <div class="logo">📚</div>
        <h1>Welcome to R-edupahana</h1>
        <p>Online Billing System</p>
        <a href="auth" class="btn" onclick="goToAuth(); return false;">Login to Continue</a>
    </div>

    <script>
        function goToAuth() {
            // Try different approaches
            var contextPath = '<%= request.getContextPath() %>';
            if (contextPath && contextPath !== '') {
                window.location.href = contextPath + '/auth';
            } else {
                window.location.href = 'auth';
            }
        }
    </script>
</body>
</html>