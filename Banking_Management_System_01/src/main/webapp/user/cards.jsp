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
    <title>Cards - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="navbar-custom">
        <h2>Cards Module</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <div class="card text-center" style="text-align: center;">
        <div class="brand-header">
            <h2>💳 Debit & Credit Cards Module</h2>
            <p>Manage linked debit and credit cards, view limits and statuses</p>
        </div>

        <div style="padding: 30px; background: #f8fafc; border-radius: 8px; margin: 20px 0;">
            <p style="font-size: 1.1rem; color: var(--text-muted);">
                Cards overview for User ID: <strong>#<%= userId %></strong>.
            </p>
        </div>

        <div class="actions-bar" style="justify-content: center;">
            <a href="dashboard.jsp" class="btn btn-primary" style="max-width: 250px; margin: 0 auto;">Back to Dashboard</a>
        </div>
    </div>
</div>

</body>
</html>
