<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String roleParam = request.getParameter("role");
    String selectedRole = (String) request.getAttribute("selectedRole");
    if (selectedRole == null) {
        selectedRole = roleParam;
    }
    boolean isAdminRole = "admin".equalsIgnoreCase(selectedRole);

    String error = (String) request.getAttribute("error");
    if (error == null && "true".equalsIgnoreCase(request.getParameter("error"))) {
        error = "Invalid credentials. Please verify your details and try again.";
    }
    String registered = request.getParameter("registered");
    String loggedOut = request.getParameter("loggedOut");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - E-Banking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .role-switch-container {
            display: flex;
            background: #f1f5f9;
            padding: 5px;
            border-radius: 12px;
            margin-bottom: 24px;
            gap: 6px;
            border: 1px solid var(--border);
        }
        .role-tab {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 11px 16px;
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-muted);
            background: transparent;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .role-tab:hover {
            color: var(--primary);
        }
        .role-tab.active-user {
            background: #ffffff;
            color: var(--primary);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        .role-tab.active-admin {
            background: #ffffff;
            color: #991b1b;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
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
        .demo-box {
            margin-top: 20px;
            padding: 12px 14px;
            background-color: #f8fafc;
            border: 1px dashed var(--border);
            border-radius: 8px;
            font-size: 0.85rem;
            color: var(--text-muted);
            text-align: center;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .demo-box:hover {
            background-color: #f1f5f9;
        }
    </style>
</head>
<body>

<div class="container-sm" id="loginApp" data-role="<%= isAdminRole ? "ADMIN" : "USER" %>">
    <div class="navbar-custom">
        <h2>E-Banking</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;" id="navRegisterLink">Register</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2 id="roleHeaderTitle"><%= isAdminRole ? "Administrator Sign In" : "Customer Sign In" %></h2>
            <p id="roleSubtitle"><%= isAdminRole ? "Access the Bank Administrator Operations Portal" : "Access your Personal Internet Banking Account" %></p>
        </div>

        <!-- Role Selector UI -->
        <div class="role-switch-container">
            <button type="button" class="role-tab <%= !isAdminRole ? "active-user" : "" %>" id="btnRoleUser" onclick="setRole('USER')">
                <span style="font-size: 1.15rem;">👤</span> Customer Login
            </button>
            <button type="button" class="role-tab <%= isAdminRole ? "active-admin" : "" %>" id="btnRoleAdmin" onclick="setRole('ADMIN')">
                <span style="font-size: 1.15rem;">🛡️</span> Bank Admin
            </button>
        </div>

        <!-- Feedback Alerts -->
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <% } %>

        <% if ("true".equals(registered)) { %>
            <div class="alert alert-success">
                Registration completed successfully! Please login with your credentials below.
            </div>
        <% } %>

        <% if ("true".equals(loggedOut)) { %>
            <div class="alert alert-success">
                You have been safely signed out.
            </div>
        <% } %>

        <!-- Customer Login Form -->
        <div id="customerSection" style="<%= isAdminRole ? "display: none;" : "display: block;" %>">
            <form action="${pageContext.request.contextPath}/user/login" method="post">
                <div class="form-group">
                    <label for="email">Customer Email Address</label>
                    <input type="email" id="email" name="email" placeholder="e.g. rahul@gmail.com" required <%= !isAdminRole ? "autofocus" : "" %>>
                </div>

                <div class="form-group">
                    <label for="password">Account Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>

                <button type="submit" class="btn btn-primary">Login as Customer</button>
            </form>

            <div class="demo-box" onclick="fillCustomerDemo()" title="Click to autofill credentials">
                <strong>Demo Customer (Click to autofill):</strong> <code>rahul@gmail.com</code> / <code>user123</code>
            </div>
        </div>

        <!-- Bank Admin Login Form -->
        <div id="adminSection" style="<%= isAdminRole ? "display: block;" : "display: none;" %>">
            <form action="${pageContext.request.contextPath}/admin/login" method="post">
                <div class="form-group">
                    <label for="adminUsername">Admin Email or Username</label>
                    <input type="text" id="adminUsername" name="username" placeholder="e.g. admin@gmail.com or admin" required <%= isAdminRole ? "autofocus" : "" %>>
                </div>

                <div class="form-group">
                    <label for="adminPassword">Admin Password</label>
                    <input type="password" id="adminPassword" name="password" placeholder="Enter admin password" required>
                </div>

                <button type="submit" class="btn btn-admin">Login as Administrator</button>
            </form>

            <div class="demo-box" onclick="fillAdminDemo()" title="Click to autofill credentials">
                <strong>Demo Admin (Click to autofill):</strong> <code>admin@gmail.com</code> / <code>admin123</code>
            </div>
        </div>

        <div class="auth-links">
            Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp<%= isAdminRole ? "?role=admin" : "" %>" id="registerLink">Register new account</a>
        </div>
    </div>
</div>

<script>
    function setRole(role) {
        var isAdm = (role === 'ADMIN');

        var btnUser = document.getElementById('btnRoleUser');
        var btnAdmin = document.getElementById('btnRoleAdmin');
        if (btnUser) btnUser.className = isAdm ? 'role-tab' : 'role-tab active-user';
        if (btnAdmin) btnAdmin.className = isAdm ? 'role-tab active-admin' : 'role-tab';

        var custSection = document.getElementById('customerSection');
        var admSection = document.getElementById('adminSection');
        if (custSection) custSection.style.display = isAdm ? 'none' : 'block';
        if (admSection) admSection.style.display = isAdm ? 'block' : 'none';

        var roleTitle = document.getElementById('roleHeaderTitle');
        if (roleTitle) {
            roleTitle.textContent = isAdm ? 'Administrator Sign In' : 'Customer Sign In';
        }

        var roleSub = document.getElementById('roleSubtitle');
        if (roleSub) {
            roleSub.textContent = isAdm 
                ? 'Access the Bank Administrator Operations Portal' 
                : 'Access your Personal Internet Banking Account';
        }

        var regLink = document.getElementById('registerLink');
        if (regLink) {
            regLink.setAttribute('href', '${pageContext.request.contextPath}/register.jsp?role=' + (isAdm ? 'admin' : 'user'));
        }

        var navRegLink = document.getElementById('navRegisterLink');
        if (navRegLink) {
            navRegLink.setAttribute('href', '${pageContext.request.contextPath}/register.jsp?role=' + (isAdm ? 'admin' : 'user'));
        }

        var adminInput = document.getElementById('adminUsername');
        var userInput = document.getElementById('email');
        if (isAdm && adminInput) {
            adminInput.focus();
        } else if (!isAdm && userInput) {
            userInput.focus();
        }
    }

    function fillCustomerDemo() {
        var email = document.getElementById('email');
        var pass = document.getElementById('password');
        if (email) email.value = 'rahul@gmail.com';
        if (pass) pass.value = 'user123';
    }

    function fillAdminDemo() {
        var user = document.getElementById('adminUsername');
        var pass = document.getElementById('adminPassword');
        if (user) user.value = 'admin@gmail.com';
        if (pass) pass.value = 'admin123';
    }

    window.addEventListener('DOMContentLoaded', function() {
        var app = document.getElementById('loginApp');
        var initialRole = (app && app.getAttribute('data-role')) ? app.getAttribute('data-role') : 'USER';
        if (initialRole === 'ADMIN') {
            setRole('ADMIN');
        } else {
            setRole('USER');
        }
    });
</script>

</body>
</html>
