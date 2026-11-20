<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer bankAdminId = (session != null) ? (Integer) session.getAttribute("bankAdminId") : null;
    if (bankAdminId != null) {
        response.sendRedirect(request.getContextPath() + "/bank-admin/dashboard");
        return;
    }

    String error = (String) request.getAttribute("error");
    if (error == null && "true".equalsIgnoreCase(request.getParameter("error"))) {
        error = "Invalid administrator credentials. Please try again.";
    }
    String loggedOut = request.getParameter("loggedOut");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Admin Portal - E-Banking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            background-color: #f1f5f9;
        }
        .portal-header {
            text-align: center;
            margin-bottom: 24px;
        }
        .portal-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, #059669, #047857);
            color: #ffffff;
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 12px;
            box-shadow: 0 4px 12px rgba(5, 150, 105, 0.3);
        }
        .btn-bank-admin {
            background-color: #059669;
            color: #ffffff;
            width: 100%;
            padding: 12px;
            font-size: 1rem;
            font-weight: 700;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn-bank-admin:hover {
            background-color: #047857;
            color: #ffffff;
        }
        .portal-badge {
            background: #d1fae5;
            color: #065f46;
            font-weight: 700;
            font-size: 0.8rem;
            padding: 4px 12px;
            border-radius: 9999px;
            display: inline-block;
            margin-bottom: 8px;
        }
        .role-switcher-banner {
            margin-top: 20px;
            padding: 12px;
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 0.85rem;
            text-align: center;
            display: flex;
            justify-content: center;
            gap: 16px;
        }
        .role-switcher-banner a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .role-switcher-banner a:hover {
            text-decoration: underline;
        }
        .demo-box {
            margin-top: 18px;
            padding: 12px 14px;
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            font-size: 0.85rem;
            color: var(--text-muted);
            text-align: center;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .demo-box:hover {
            background-color: #e2e8f0;
        }
    </style>
</head>
<body>

<div class="container-sm">
    <div class="navbar-custom">
        <h2>E-Banking Operations</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Central Login</a>
        </div>
    </div>

    <div class="card" style="margin-top: 20px;">
        <div class="portal-header">
            <div class="portal-icon">🏦</div>
            <div>
                <span class="portal-badge">Institutional Bank Portal</span>
            </div>
            <h2 style="font-size: 1.6rem; color: #0f172a; margin-bottom: 6px;">Bank Administrator Login</h2>
            <p style="color: #64748b; font-size: 0.92rem; margin: 0;">
                Dedicated portal to review loan applications, manage customer bank accounts, and oversee cards.
            </p>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger" style="margin-bottom: 16px;">
                <%= error %>
            </div>
        <% } %>

        <% if ("true".equals(loggedOut)) { %>
            <div class="alert alert-success" style="margin-bottom: 16px;">
                You have been safely signed out from the Bank Admin Portal.
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/bank-admin/login" method="post">
            <div class="form-group">
                <label for="username">Bank Admin Username or Email</label>
                <input type="text" id="username" name="username" placeholder="e.g. bankadmin@gmail.com or sbi_admin" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Administrator Password</label>
                <input type="password" id="password" name="password" placeholder="Enter password" required>
            </div>

            <button type="submit" class="btn-bank-admin">Sign In to Bank Admin Console</button>
        </form>

        <div class="demo-box" onclick="fillBankAdminDemo()" title="Click to autofill lead bank admin credentials">
            <strong>Demo Lead Bank Admin:</strong> <code>bankadmin@gmail.com</code> / <code>admin123</code>
        </div>
        <div class="demo-box" onclick="fillSbiAdminDemo()" style="margin-top: 8px;" title="Click to autofill SBI bank admin credentials">
            <strong>Demo SBI Bank Admin:</strong> <code>sbi.admin@gmail.com</code> / <code>admin123</code>
        </div>

        <div class="role-switcher-banner">
            <span>Switch Portal:</span>
            <a href="${pageContext.request.contextPath}/login.jsp?role=user">👤 Customer Login</a>
            <span>&bull;</span>
            <a href="${pageContext.request.contextPath}/login.jsp?role=platform_admin">🛡️ Platform Admin</a>
        </div>
    </div>
</div>

<script>
    function fillBankAdminDemo() {
        document.getElementById('username').value = 'bankadmin@gmail.com';
        document.getElementById('password').value = 'admin123';
    }
    function fillSbiAdminDemo() {
        document.getElementById('username').value = 'sbi.admin@gmail.com';
        document.getElementById('password').value = 'admin123';
    }
</script>

</body>
</html>
