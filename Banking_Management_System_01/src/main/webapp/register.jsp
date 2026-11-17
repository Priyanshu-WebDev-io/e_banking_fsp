<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String roleParam = request.getParameter("role");
    String selectedRole = (String) request.getAttribute("selectedRole");
    if (selectedRole == null) {
        selectedRole = roleParam;
    }
    boolean isAdminRole = "admin".equalsIgnoreCase(selectedRole);

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - E-Banking</title>
    <link rel="stylesheet" href="css/style.css">
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
    </style>
</head>
<body>

<div class="container-sm">
    <div class="navbar-custom">
        <h2>E-Banking</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="login.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Login</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2 id="regHeaderTitle">Create Account</h2>
            <p id="regSubtitle">Select your role to get started</p>
        </div>

        <!-- Role Selector Switch -->
        <div class="role-switch-container">
            <button type="button" class="role-tab <%= !isAdminRole ? "active-user" : "" %>" id="btnRegUser" onclick="setRegRole('USER')">
                <span style="font-size: 1.15rem;">👤</span> Customer
            </button>
            <button type="button" class="role-tab <%= isAdminRole ? "active-admin" : "" %>" id="btnRegAdmin" onclick="setRegRole('ADMIN')">
                <span style="font-size: 1.15rem;">🛡️</span> Bank Admin
            </button>
        </div>

        <!-- Feedback Alert -->
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <% } %>

        <!-- 1. Customer Registration Form -->
        <div id="customerRegSection" style="<%= isAdminRole ? "display: none;" : "display: block;" %>">
            <form action="${pageContext.request.contextPath}/user/register" method="post" onsubmit="return validatePasswords('userPass', 'userConfirmPass')">
                <div class="form-group">
                    <label for="userName">Full Name *</label>
                    <input type="text" id="userName" name="name" placeholder="Enter your full name" required <%= !isAdminRole ? "autofocus" : "" %>>
                </div>

                <div class="form-group">
                    <label for="userEmail">Email Address *</label>
                    <input type="email" id="userEmail" name="email" placeholder="e.g. name@example.com" required>
                </div>

                <div class="form-group">
                    <label for="userPass">Password *</label>
                    <input type="password" id="userPass" name="password" placeholder="Create a password" required>
                </div>

                <div class="form-group">
                    <label for="userConfirmPass">Confirm Password *</label>
                    <input type="password" id="userConfirmPass" name="confirmPassword" placeholder="Re-enter your password" required>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: 8px;">Create Customer Account</button>
            </form>
        </div>

        <!-- 2. Admin Registration Form -->
        <div id="adminRegSection" style="<%= isAdminRole ? "display: block;" : "display: none;" %>">
            <form action="${pageContext.request.contextPath}/admin/register" method="post" onsubmit="return validatePasswords('adminPass', 'adminConfirmPass')">
                <div class="form-group">
                    <label for="adminName">Full Name *</label>
                    <input type="text" id="adminName" name="name" placeholder="Enter administrator full name" required <%= isAdminRole ? "autofocus" : "" %>>
                </div>

                <div class="form-group">
                    <label for="adminEmail">Email Address *</label>
                    <input type="email" id="adminEmail" name="email" placeholder="e.g. admin@ebanking.com" required>
                </div>

                <div class="form-group">
                    <label for="adminPass">Password *</label>
                    <input type="password" id="adminPass" name="password" placeholder="Create admin password" required>
                </div>

                <div class="form-group">
                    <label for="adminConfirmPass">Confirm Password *</label>
                    <input type="password" id="adminConfirmPass" name="confirmPassword" placeholder="Re-enter admin password" required>
                </div>

                <button type="submit" class="btn btn-admin" style="margin-top: 8px;">Create Admin Account</button>
            </form>
        </div>

        <div class="auth-links">
            Already have an account? <a href="login.jsp<%= isAdminRole ? "?role=admin" : "" %>" id="loginLink">Login here</a>
        </div>
    </div>
</div>

<script>
    function setRegRole(role) {
        const isAdm = (role === 'ADMIN');
        document.getElementById('btnRegUser').className = isAdm ? 'role-tab' : 'role-tab active-user';
        document.getElementById('btnRegAdmin').className = isAdm ? 'role-tab active-admin' : 'role-tab';

        document.getElementById('customerRegSection').style.display = isAdm ? 'none' : 'block';
        document.getElementById('adminRegSection').style.display = isAdm ? 'block' : 'none';

        document.getElementById('regSubtitle').innerText = isAdm 
            ? 'Fill in administrator details to register your staff account' 
            : 'Fill in your details below to register your customer account';

        document.getElementById('loginLink').href = isAdm 
            ? 'login.jsp?role=admin' 
            : 'login.jsp?role=user';

        if (isAdm) {
            document.getElementById('adminName').focus();
        } else {
            document.getElementById('userName').focus();
        }
    }

    function validatePasswords(p1Id, p2Id) {
        const p1 = document.getElementById(p1Id).value;
        const p2 = document.getElementById(p2Id).value;
        if (p1 !== p2) {
            alert('Password and Confirm Password do not match. Please verify and try again.');
            return false;
        }
        return true;
    }

    // Set initial role if passed
    window.addEventListener('DOMContentLoaded', function() {
        <% if (isAdminRole) { %>
            setRegRole('ADMIN');
        <% } %>
    });
</script>

</body>
</html>
