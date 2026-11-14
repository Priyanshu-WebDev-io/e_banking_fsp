<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String userFullName = (firstName != null ? firstName : "User") + (lastName != null ? " " + lastName : "");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container-lg">
    <div class="navbar-custom">
        <h2>E-Banking Customer Portal</h2>
        <div class="user-info">
            <span>Welcome, <strong><%= userFullName %></strong></span>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <div class="card" style="margin-bottom: 24px;">
        <h3>Hello, <%= firstName != null ? firstName : "Customer" %>!</h3>
        <p style="color: var(--text-muted); margin-top: 4px;">
            Manage your personal profile, bank accounts, fund transfers, loans, and debit/credit cards all in one place.
        </p>
    </div>

    <h3 style="margin-bottom: 12px; color: var(--text-main);">Quick Services</h3>

    <div class="dashboard-grid">
        <a href="${pageContext.request.contextPath}/user/profile" class="dashboard-card">
            <div class="card-icon">👤</div>
            <h3>My Profile</h3>
            <p>View personal details, contact info and update address</p>
        </a>

        <a href="${pageContext.request.contextPath}/account/list" class="dashboard-card">
            <div class="card-icon">🏦</div>
            <h3>My Accounts</h3>
            <p>View savings, current accounts, balance and statements</p>
        </a>

        <a href="transactions.jsp" class="dashboard-card">
            <div class="card-icon">💳</div>
            <h3>Transactions</h3>
            <p>Transfer funds, deposit, withdraw and check transaction logs</p>
        </a>

        <a href="loans.jsp" class="dashboard-card">
            <div class="card-icon">📄</div>
            <h3>Loans</h3>
            <p>View personal, home, car loan applications and EMI status</p>
        </a>

        <a href="cards.jsp" class="dashboard-card">
            <div class="card-icon">💳</div>
            <h3>Cards</h3>
            <p>Manage your linked debit cards and credit cards</p>
        </a>

        <a href="${pageContext.request.contextPath}/user/logout" class="dashboard-card" style="border-color: #ffcdd2;">
            <div class="card-icon">🚪</div>
            <h3 style="color: var(--danger);">Logout</h3>
            <p>Safely terminate your current internet banking session</p>
        </a>
    </div>
</div>

</body>
</html>
