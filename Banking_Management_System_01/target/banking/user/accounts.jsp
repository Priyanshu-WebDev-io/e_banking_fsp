<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Accounts - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card text-center" style="text-align: center;">
        <div class="brand-header">
            <h2>🏦 Bank Accounts Module</h2>
            <p>Account creation, savings & current account details, and balance inquiry</p>
        </div>

        <div style="padding: 30px; background: #f8fafc; border-radius: 8px; margin: 20px 0;">
            <p style="font-size: 1.1rem; color: var(--text-muted);">
                The <strong>Accounts Module</strong> will be linked to your User ID (<strong>#<%= userId %></strong>) next.
            </p>
            <p style="font-size: 0.95rem; color: var(--text-muted); margin-top: 8px;">
                Features coming up: Open New Account, View Account Balances, Account Statements.
            </p>
        </div>

        <div class="actions-bar" style="justify-content: center;">
            <a href="dashboard.jsp" class="btn btn-primary" style="max-width: 250px; margin: 0 auto;">Back to Dashboard</a>
        </div>
    </div>
</div>

</body>
</html>
