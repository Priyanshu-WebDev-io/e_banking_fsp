<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Login - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container-sm">
    <div class="navbar-custom">
        <h2>E-Banking</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="register.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Register</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2>User Login</h2>
            <p>Access your Internet Banking portal</p>
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

            String registered = request.getParameter("registered");
            if ("true".equals(registered)) {
        %>
            <div class="alert alert-success">
                Registration successful! Please login with your credentials.
            </div>
        <%
            }
        %>

        <form action="${pageContext.request.contextPath}/user/login" method="post">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn btn-primary">Login</button>
        </form>

        <div class="auth-links">
            Don't have an account? <a href="register.jsp">Create new account</a>
        </div>
    </div>
</div>

</body>
</html>
