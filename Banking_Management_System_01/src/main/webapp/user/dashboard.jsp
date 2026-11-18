<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% Integer userId=(Integer) session.getAttribute("userId"); if (userId==null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp" ); return; } String firstName=(String)
        session.getAttribute("firstName"); String lastName=(String) session.getAttribute("lastName"); String
        userFullName=(firstName !=null ? firstName : "User" ) + (lastName !=null ? " " + lastName : "" ); %>
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
                        <span>Welcome, <strong>
                                <%= userFullName %>
                            </strong></span>
                        <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary"
                            style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
                        <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary"
                            style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
                    </div>
                </div>

                <div class="card" style="margin-bottom: 24px;">
                    <h3>Hello, <%= firstName !=null ? firstName : "Customer" %>!</h3>
                    <p style="color: var(--text-muted); margin-top: 4px;">
                        Welcome to your digital banking portal. Manage your profile and bank accounts below.
                    </p>
                </div>

                <h3 style="margin-bottom: 12px; color: var(--text-main);">Banking Services</h3>

                <div class="dashboard-grid">
                    <a href="${pageContext.request.contextPath}/user/profile" class="dashboard-card">
                        <div class="card-icon">👤</div>
                        <h3>My Profile</h3>
                        <p>View personal KYC details, phone number and update residential address</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/account/list" class="dashboard-card">
                        <div class="card-icon">🏦</div>
                        <h3>My Accounts</h3>
                        <p>View your active bank accounts, check available balance and IFSC codes</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/account/create" class="dashboard-card">
                        <div class="card-icon">➕</div>
                        <h3>Open Account</h3>
                        <p>Open a new Savings or Current account with instant account number generation</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/user/transactions" class="dashboard-card">
                        <div class="card-icon">💳</div>
                        <h3>Transactions & Transfers</h3>
                        <p>Deposit funds, withdraw cash, and transfer money between accounts with live passbook</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/user/cards" class="dashboard-card">
                        <div class="card-icon">🪪</div>
                        <h3>My Cards</h3>
                        <p>Manage virtual Debit & Credit cards, view masked numbers, and toggle security lock</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/user/loans" class="dashboard-card">
                        <div class="card-icon">💰</div>
                        <h3>Loans & EMI</h3>
                        <p>Explore interest rates, compute monthly EMI, and apply for instant personal or home loans</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/user/logout" class="dashboard-card"
                        style="border-color: #ffcdd2;">
                        <div class="card-icon">🚪</div>
                        <h3 style="color: var(--danger);">Logout</h3>
                        <p>Safely terminate your current internet banking session</p>
                    </a>
                </div>
            </div>

        </body>

        </html>