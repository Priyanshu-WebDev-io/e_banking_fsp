<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String roleParam = request.getParameter("role");
    String selectedRole = (String) request.getAttribute("selectedRole");
    if (selectedRole == null) {
        selectedRole = roleParam;
    }
    if (selectedRole == null || selectedRole.trim().isEmpty()) {
        selectedRole = "USER";
    }
    selectedRole = selectedRole.toUpperCase();
    if ("ADMIN".equals(selectedRole)) {
        selectedRole = "PLATFORM_ADMIN";
    }

    boolean isCustomer = "USER".equals(selectedRole) || "CUSTOMER".equals(selectedRole);
    boolean isBankAdmin = "BANK_ADMIN".equals(selectedRole) || "BANKADMIN".equals(selectedRole);
    boolean isPlatformAdmin = "PLATFORM_ADMIN".equals(selectedRole) || "PLATFORM".equals(selectedRole);

    String error = (String) request.getAttribute("error");
    if (error == null && "true".equalsIgnoreCase(request.getParameter("error"))) {
        error = "Invalid credentials. Please verify your details and try again.";
    }
    String registered = request.getParameter("registered");
    String loggedOut = request.getParameter("loggedOut");

    String headerTitle = isCustomer ? "Customer Sign In" : (isBankAdmin ? "Bank Administrator Sign In" : "Platform Administrator Sign In");
    String headerSubtitle = isCustomer 
        ? "Access your Personal Internet Banking Account" 
        : (isBankAdmin ? "Bank Operations: Underwrite Loans, Regulate Accounts & Manage Cards" : "Platform Governance: Regulate Commissions & Partner Bank Rates");
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
        .hidden {
            display: none !important;
        }
        .role-tab {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 10px 12px;
            font-size: 0.88rem;
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
            color: #2563eb;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        .role-tab.active-bank {
            background: #ffffff;
            color: #059669;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        .role-tab.active-platform {
            background: #ffffff;
            color: #991b1b;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
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
        }
        .btn-bank-admin:hover {
            background-color: #047857;
            color: #ffffff;
        }
        .btn-platform-admin {
            background-color: #991b1b;
            color: #ffffff;
            width: 100%;
            padding: 12px;
            font-size: 1rem;
            font-weight: 700;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }
        .btn-platform-admin:hover {
            background-color: #7f1d1d;
            color: #ffffff;
        }
        .demo-box {
            margin-top: 16px;
            padding: 10px 14px;
            background-color: #f8fafc;
            border: 1px dashed var(--border);
            border-radius: 8px;
            font-size: 0.84rem;
            color: var(--text-muted);
            text-align: center;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .demo-box:hover {
            background-color: #f1f5f9;
        }
        .portal-direct-links {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid var(--border);
            font-size: 0.85rem;
            flex-wrap: wrap;
        }
        .portal-direct-links a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .portal-direct-links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container-sm" id="loginApp" data-role="<%= selectedRole %>">
    <div class="navbar-custom">
        <h2>E-Banking System</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;" id="navRegisterLink">Register</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2 id="roleHeaderTitle"><%= headerTitle %></h2>
            <p id="roleSubtitle" style="font-size: 0.9rem; color: #64748b;"><%= headerSubtitle %></p>
        </div>

        <!-- 3-Role Selector Switcher -->
        <div class="role-switch-container">
            <button type="button" class="role-tab <%= isCustomer ? "active-user" : "" %>" id="btnRoleUser" onclick="setPortalRole('USER')">
                <span style="font-size: 1.1rem;">👤</span> Customer
            </button>
            <button type="button" class="role-tab <%= isBankAdmin ? "active-bank" : "" %>" id="btnRoleBank" onclick="setPortalRole('BANK_ADMIN')">
                <span style="font-size: 1.1rem;">🏦</span> Bank Admin
            </button>
            <button type="button" class="role-tab <%= isPlatformAdmin ? "active-platform" : "" %>" id="btnRolePlatform" onclick="setPortalRole('PLATFORM_ADMIN')">
                <span style="font-size: 1.1rem;">🛡️</span> Platform Admin
            </button>
        </div>

        <!-- Feedback Alerts -->
        <% if (error != null) { %>
            <div class="alert alert-danger" style="margin-bottom: 16px;">
                <%= error %>
            </div>
        <% } %>

        <% if ("true".equals(registered)) { %>
            <div class="alert alert-success" style="margin-bottom: 16px;">
                Registration completed successfully! Please login with your credentials below.
            </div>
        <% } %>

        <% if ("true".equals(loggedOut)) { %>
            <div class="alert alert-success" style="margin-bottom: 16px;">
                You have been safely signed out.
            </div>
        <% } %>

        <!-- 1. Customer Login Form -->
        <div id="customerSection" class="<%= !isCustomer ? "hidden" : "" %>">
            <form action="${pageContext.request.contextPath}/user/login" method="post">
                <div class="form-group">
                    <label for="email">Customer Email Address</label>
                    <input type="email" id="email" name="email" placeholder="e.g. rahul@gmail.com" required>
                </div>

                <div class="form-group">
                    <label for="password">Account Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-weight: 700;">Login as Customer</button>
            </form>

            <div class="demo-box" onclick="fillCustomerDemo()" title="Click to autofill credentials">
                <strong>Demo Customer:</strong> <code>rahul@gmail.com</code> / <code>user123</code>
            </div>

            <div class="auth-links" style="margin-top: 16px; text-align: center; font-size: 0.88rem;">
                New customer? <a href="${pageContext.request.contextPath}/register.jsp?role=user">Open Bank Account</a>
            </div>
        </div>

        <!-- 2. Bank Admin Login Form (Accounts, Loans, Cards) -->
        <div id="bankAdminSection" class="<%= !isBankAdmin ? "hidden" : "" %>">
            <form action="${pageContext.request.contextPath}/bank-admin/login" method="post">
                <div class="form-group">
                    <label for="bankAdminUsername">Bank Admin Username or Email</label>
                    <input type="text" id="bankAdminUsername" name="username" placeholder="e.g. bankadmin@gmail.com or sbi_admin" required>
                </div>

                <div class="form-group">
                    <label for="bankAdminPassword">Administrator Password</label>
                    <input type="password" id="bankAdminPassword" name="password" placeholder="Enter bank admin password" required>
                </div>

                <button type="submit" class="btn-bank-admin">Sign In as Bank Administrator</button>
            </form>

            <div class="demo-box" onclick="fillBankAdminDemo()" title="Click to autofill Lead Bank Admin">
                <strong>Demo Lead Bank Admin:</strong> <code>bankadmin@gmail.com</code> / <code>admin123</code>
            </div>
            <div class="demo-box" onclick="fillSbiAdminDemo()" style="margin-top: 6px;" title="Click to autofill SBI Bank Admin">
                <strong>Demo SBI Bank Admin:</strong> <code>sbi.admin@gmail.com</code> / <code>admin123</code>
            </div>
        </div>

        <!-- 3. Platform Admin Login Form (Commissions Only) -->
        <div id="platformAdminSection" class="<%= !isPlatformAdmin ? "hidden" : "" %>">
            <form action="${pageContext.request.contextPath}/admin/login" method="post">
                <div class="form-group">
                    <label for="platformUsername">Platform Admin Email or Username</label>
                    <input type="text" id="platformUsername" name="username" placeholder="e.g. admin@gmail.com or admin" required>
                </div>

                <div class="form-group">
                    <label for="platformPassword">Platform Admin Password</label>
                    <input type="password" id="platformPassword" name="password" placeholder="Enter platform admin password" required>
                </div>

                <button type="submit" class="btn-platform-admin">Sign In as Platform Administrator</button>
            </form>

            <div class="demo-box" onclick="fillPlatformAdminDemo()" title="Click to autofill Platform Admin">
                <strong>Demo Platform Admin:</strong> <code>admin@gmail.com</code> / <code>admin123</code>
            </div>
        </div>

        <div class="portal-direct-links">
            <a href="${pageContext.request.contextPath}/bank-admin/login.jsp">🏦 Dedicated Bank Admin Portal</a>
            <span>&bull;</span>
            <a href="${pageContext.request.contextPath}/admin/login">🛡️ Platform Commission Console</a>
        </div>
    </div>
</div>

<script>
    function setPortalRole(role) {
        var isCust = (role === 'USER');
        var isBank = (role === 'BANK_ADMIN');
        var isPlat = (role === 'PLATFORM_ADMIN');

        var btnUser = document.getElementById('btnRoleUser');
        var btnBank = document.getElementById('btnRoleBank');
        var btnPlat = document.getElementById('btnRolePlatform');

        if (btnUser) btnUser.className = isCust ? 'role-tab active-user' : 'role-tab';
        if (btnBank) btnBank.className = isBank ? 'role-tab active-bank' : 'role-tab';
        if (btnPlat) btnPlat.className = isPlat ? 'role-tab active-platform' : 'role-tab';

        var custSec = document.getElementById('customerSection');
        var bankSec = document.getElementById('bankAdminSection');
        var platSec = document.getElementById('platformAdminSection');

        if (custSec) {
            custSec.classList.toggle('hidden', !isCust);
            custSec.style.display = isCust ? 'block' : 'none';
        }
        if (bankSec) {
            bankSec.classList.toggle('hidden', !isBank);
            bankSec.style.display = isBank ? 'block' : 'none';
        }
        if (platSec) {
            platSec.classList.toggle('hidden', !isPlat);
            platSec.style.display = isPlat ? 'block' : 'none';
        }

        var title = document.getElementById('roleHeaderTitle');
        var subtitle = document.getElementById('roleSubtitle');
        if (title && subtitle) {
            if (isCust) {
                title.textContent = 'Customer Sign In';
                subtitle.textContent = 'Access your Personal Internet Banking Account';
            } else if (isBank) {
                title.textContent = 'Bank Administrator Sign In';
                subtitle.textContent = 'Bank Operations: Underwrite Loans, Regulate Accounts & Manage Cards';
            } else {
                title.textContent = 'Platform Administrator Sign In';
                subtitle.textContent = 'Platform Governance: Regulate Commissions & Partner Bank Rates';
            }
        }

        var navReg = document.getElementById('navRegisterLink');
        if (navReg) {
            navReg.style.display = isCust ? 'inline-block' : 'none';
        }
    }

    function fillCustomerDemo() {
        document.getElementById('email').value = 'rahul@gmail.com';
        document.getElementById('password').value = 'user123';
    }

    function fillBankAdminDemo() {
        document.getElementById('bankAdminUsername').value = 'bankadmin@gmail.com';
        document.getElementById('bankAdminPassword').value = 'admin123';
    }

    function fillSbiAdminDemo() {
        document.getElementById('bankAdminUsername').value = 'sbi.admin@gmail.com';
        document.getElementById('bankAdminPassword').value = 'admin123';
    }

    function fillPlatformAdminDemo() {
        document.getElementById('platformUsername').value = 'admin@gmail.com';
        document.getElementById('platformPassword').value = 'admin123';
    }

    window.addEventListener('DOMContentLoaded', function() {
        var app = document.getElementById('loginApp');
        var initialRole = (app && app.getAttribute('data-role')) ? app.getAttribute('data-role') : 'USER';
        setPortalRole(initialRole);
    });
</script>

</body>
</html>
