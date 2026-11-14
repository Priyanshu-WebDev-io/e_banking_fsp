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
    <title>Open New Account - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container-sm">
    <div class="navbar-custom">
        <h2>Bank Accounts</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Accounts</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2>Open New Bank Account</h2>
            <p>Select your account type and make your initial deposit</p>
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
        %>

        <form action="${pageContext.request.contextPath}/account/create" method="post">
            <div class="form-group">
                <label for="accountType">Account Type *</label>
                <select id="accountType" name="accountType" required>
                    <option value="SAVINGS" selected>Savings Account (Interest earning, Min. ₹500)</option>
                    <option value="CURRENT">Current Account (For commercial use, Min. ₹2,000)</option>
                    <option value="SALARY">Salary Account (Corporate zero-balance)</option>
                    <option value="FIXED_DEPOSIT">Fixed Deposit Account (High interest term deposit)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="branchName">Select Bank Branch *</label>
                <select id="branchName" name="branchName" required>
                    <option value="Main Branch - Mumbai">Main Branch - Mumbai (IFSC: EBANK000101)</option>
                    <option value="Connaught Place - New Delhi">Connaught Place - New Delhi (IFSC: EBANK000201)</option>
                    <option value="Indiranagar - Bengaluru">Indiranagar - Bengaluru (IFSC: EBANK000301)</option>
                    <option value="Salt Lake - Kolkata">Salt Lake - Kolkata (IFSC: EBANK000401)</option>
                    <option value="Banjara Hills - Hyderabad">Banjara Hills - Hyderabad (IFSC: EBANK000501)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="initialDeposit">Initial Deposit Amount (₹) *</label>
                <input type="number" id="initialDeposit" name="initialDeposit" value="5000" min="500" step="100" required>
                <small style="color: var(--text-muted); font-size: 0.8rem; display: block; margin-top: 4px;">
                    Minimum initial opening deposit is ₹500.
                </small>
            </div>

            <div class="actions-bar" style="margin-top: 24px;">
                <button type="submit" class="btn btn-primary" style="flex: 1;">Open Account</button>
                <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="flex: 1;">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
