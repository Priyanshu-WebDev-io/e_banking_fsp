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
        .security-badge {
            display: inline-block;
            background-color: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 6px 12px;
            font-size: 0.85rem;
            margin-bottom: 16px;
            width: 100%;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="container">
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
            <p id="regSubtitle">Select your account role to complete registration</p>
        </div>

        <!-- Role Selector UI -->
        <div class="role-switch-container">
            <button type="button" class="role-tab <%= !isAdminRole ? "active-user" : "" %>" id="btnRegUser" onclick="setRegRole('USER')">
                <span style="font-size: 1.15rem;">👤</span> Customer Registration
            </button>
            <button type="button" class="role-tab <%= isAdminRole ? "active-admin" : "" %>" id="btnRegAdmin" onclick="setRegRole('ADMIN')">
                <span style="font-size: 1.15rem;">🛡️</span> Bank Admin Registration
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
            <form action="${pageContext.request.contextPath}/user/register" method="post">
                <div class="form-row">
                    <div class="form-group">
                        <label for="firstName">First Name *</label>
                        <input type="text" id="firstName" name="firstName" placeholder="Enter first name" required>
                    </div>

                    <div class="form-group">
                        <label for="lastName">Last Name *</label>
                        <input type="text" id="lastName" name="lastName" placeholder="Enter last name" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email Address *</label>
                        <input type="email" id="email" name="email" placeholder="e.g. yourname@example.com" required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="text" id="phone" name="phone" placeholder="10-digit mobile number" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Account Password *</label>
                        <input type="password" id="password" name="password" placeholder="Choose a strong password" required>
                    </div>

                    <div class="form-group">
                        <label for="dateOfBirth">Date of Birth</label>
                        <input type="date" id="dateOfBirth" name="dateOfBirth">
                    </div>
                </div>

                <div class="form-group">
                    <label for="address">Residential Address</label>
                    <textarea id="address" name="address" rows="2" placeholder="Street address or apartment"></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="city">City</label>
                        <input type="text" id="city" name="city" placeholder="City">
                    </div>

                    <div class="form-group">
                        <label for="state">State</label>
                        <input type="text" id="state" name="state" placeholder="State">
                    </div>

                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" placeholder="Postal code">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: 10px;">Register Customer Account</button>
            </form>
        </div>

        <!-- 2. Admin Registration Form -->
        <div id="adminRegSection" style="<%= isAdminRole ? "display: block;" : "display: none;" %>">
            <div class="security-badge">
                🔒 <strong>Restricted:</strong> Bank staff registration requires the system administrator security key.
            </div>

            <form action="${pageContext.request.contextPath}/admin/register" method="post">
                <div class="form-row">
                    <div class="form-group">
                        <label for="adminFullName">Administrator Full Name *</label>
                        <input type="text" id="adminFullName" name="fullName" placeholder="e.g. Sarah Jenkins" required>
                    </div>

                    <div class="form-group">
                        <label for="adminUsernameInput">Admin Username *</label>
                        <input type="text" id="adminUsernameInput" name="username" placeholder="e.g. sjenkins" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="adminEmailInput">Admin Official Email</label>
                        <input type="email" id="adminEmailInput" name="email" placeholder="e.g. sjenkins@ebanking.com">
                    </div>

                    <div class="form-group">
                        <label for="adminPasswordInput">Admin Password *</label>
                        <input type="password" id="adminPasswordInput" name="password" placeholder="Set admin password" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="adminKey">Admin Security Key *</label>
                    <input type="text" id="adminKey" name="adminKey" placeholder="Enter System Key (Use: ADMIN2026)" required>
                    <small style="color: var(--text-muted); display: block; margin-top: 4px;">System demo authorization key: <code>ADMIN2026</code></small>
                </div>

                <button type="submit" class="btn btn-admin" style="margin-top: 10px;">Register Administrator Account</button>
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
            ? 'Fill in administrator credentials and security key to create your staff account' 
            : 'Fill in your personal details below to register your customer banking account';

        document.getElementById('loginLink').href = isAdm 
            ? 'login.jsp?role=admin' 
            : 'login.jsp?role=user';
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
