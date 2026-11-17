<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .admin-badge {
            display: inline-block;
            background-color: #fee2e2;
            color: #991b1b;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }
        .btn-admin {
            background-color: #991b1b;
            color: #ffffff;
            width: 100%;
        }
        .btn-admin:hover {
            background-color: #7f1d1d;
            color: #ffffff;
        }
    </style>
</head>
<body>

<div class="container-sm">
    <div class="navbar-custom">
        <h2>🛡️ E-Banking Admin</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/user/login.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">User Login</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <span class="admin-badge">Admin Access Only</span>
            <h2>Administrator Portal</h2>
            <p>Sign in to manage customers, accounts, and bank operations</p>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <%
            }

            String loggedOut = request.getParameter("loggedOut");
            if ("true".equals(loggedOut)) {
        %>
            <div class="alert alert-success">
                You have been securely logged out of the admin portal.
            </div>
        <%
            }
        %>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <div class="form-group">
                <label for="username">Admin Username</label>
                <input type="text" id="username" name="username" placeholder="Enter admin username" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Admin Password</label>
                <input type="password" id="password" name="password" placeholder="Enter admin password" required>
            </div>

            <div style="margin-top: 24px;">
                <button type="submit" class="btn btn-admin">Sign In as Admin</button>
            </div>
        </form>

        <div style="margin-top: 20px; padding: 12px; background-color: #f8fafc; border-radius: 6px; font-size: 0.82rem; color: var(--text-muted); text-align: center;">
            <strong>Demo Credentials:</strong> Username: <code>admin</code> | Password: <code>admin123</code>
        </div>

        <div class="auth-links">
            Are you a customer? <a href="${pageContext.request.contextPath}/user/login.jsp">Customer Login</a>
        </div>
    </div>
</div>

</body>
</html>
