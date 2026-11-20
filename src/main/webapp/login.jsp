<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect already logged-in users to their respective dashboard
    String loggedOut = request.getParameter("loggedOut");
    if (loggedOut == null && session != null) {
        if (session.getAttribute("userId") != null) {
            response.sendRedirect(request.getContextPath() + "/user/dashboard");
            return;
        } else if (session.getAttribute("bankAdminId") != null) {
            response.sendRedirect(request.getContextPath() + "/bank-admin/dashboard");
            return;
        } else if (session.getAttribute("adminId") != null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
    }

    String roleParam = request.getParameter("role");
    String selectedRole = (String) request.getAttribute("selectedRole");
    if (selectedRole == null) {
        selectedRole = roleParam;
    }
    if (selectedRole == null || selectedRole.trim().isEmpty()) {
        selectedRole = "USER";
    }
    selectedRole = selectedRole.toUpperCase();

    if ("ADMIN".equals(selectedRole) || "PLATFORM".equals(selectedRole) || "PLATFORM_ADMIN".equals(selectedRole)) {
        selectedRole = "PLATFORM_ADMIN";
    } else if ("BANK".equals(selectedRole) || "BANK_ADMIN".equals(selectedRole) || "BANKADMIN".equals(selectedRole)) {
        selectedRole = "BANK_ADMIN";
    } else {
        selectedRole = "USER";
    }

    boolean isCustomer = "USER".equals(selectedRole);
    boolean isBankAdmin = "BANK_ADMIN".equals(selectedRole);
    boolean isPlatformAdmin = "PLATFORM_ADMIN".equals(selectedRole);

    String error = (String) request.getAttribute("error");
    if (error == null && "true".equalsIgnoreCase(request.getParameter("error"))) {
        error = "Invalid credentials. Please verify your details and try again.";
    }
    String registered = request.getParameter("registered");

    String headerTitle = isCustomer 
        ? "Customer Sign In" 
        : (isBankAdmin ? "Bank Administrator Operations" : "Platform Commission Governance");
    String headerSubtitle = isCustomer 
        ? "Access your personal accounts, execute transfers, manage cards, and apply for loans." 
        : (isBankAdmin 
            ? "Institutional bank console: Underwrite loans, activate customer accounts, and oversee cards." 
            : "Platform revenue authority: Regulate partner bank fee rates, monitor platform revenue, and audit ledgers.");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - E-Banking Multi-Role Portal</title>
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
            padding: 11px 12px;
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
            background: rgba(255, 255, 255, 0.5);
        }
        .role-tab.active-user {
            background: #ffffff;
            color: #2563eb;
            box-shadow: 0 2px 8px rgba(37, 99, 235, 0.15);
            border: 1px solid #dbeafe;
        }
        .role-tab.active-bank {
            background: #ffffff;
            color: #059669;
            box-shadow: 0 2px 8px rgba(5, 150, 105, 0.15);
            border: 1px solid #d1fae5;
        }
        .role-tab.active-platform {
            background: #ffffff;
            color: #991b1b;
            box-shadow: 0 2px 8px rgba(153, 27, 27, 0.15);
            border: 1px solid #fee2e2;
        }
        .role-banner-tag {
            display: inline-block;
            font-size: 0.78rem;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 9999px;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .tag-user {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }
        .tag-bank {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }
        .tag-platform {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
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
            transition: background-color 0.2s;
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
            transition: background-color 0.2s;
        }
        .btn-platform-admin:hover {
            background-color: #7f1d1d;
            color: #ffffff;
        }
        .demo-chip-group {
            margin-top: 18px;
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 12px;
        }
        .demo-chip-title {
            font-size: 0.78rem;
            text-transform: uppercase;
            font-weight: 700;
            color: #64748b;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .demo-chips {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .demo-chip {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 7px 10px;
            font-size: 0.82rem;
            color: var(--text-main);
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .demo-chip:hover {
            background: #f1f5f9;
            border-color: #94a3b8;
            transform: translateX(2px);
        }
        .demo-chip code {
            background: #f1f5f9;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.8rem;
            color: #0f172a;
        }
        .portal-direct-links {
            display: flex;
            justify-content: center;
            gap: 14px;
            margin-top: 22px;
            padding-top: 16px;
            border-top: 1px solid var(--border);
            font-size: 0.84rem;
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
        <div class="brand-header" style="text-align: center;">
            <div id="roleTagContainer">
                <span class="role-banner-tag <%= isCustomer ? "tag-user" : (isBankAdmin ? "tag-bank" : "tag-platform") %>" id="roleTag">
                    <%= isCustomer ? "Personal Banking" : (isBankAdmin ? "Institutional Bank Desk" : "Platform Governance") %>
                </span>
            </div>
            <h2 id="roleHeaderTitle" style="margin-bottom: 6px;"><%= headerTitle %></h2>
            <p id="roleSubtitle" style="font-size: 0.9rem; color: #64748b; margin: 0 auto; max-width: 440px;"><%= headerSubtitle %></p>
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
                ✅ Registration completed successfully! Please login with your credentials below.
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

            <div class="demo-chip-group">
                <div class="demo-chip-title">
                    <span>⚡ Quick Autofill Demo Customers</span>
                    <span style="font-weight: normal; font-size: 0.72rem;">Click to load</span>
                </div>
                <div class="demo-chips">
                    <div class="demo-chip" onclick="fillCustomerDemo('rahul@gmail.com', 'user123')">
                        <span>👤 <strong>Rahul Sharma</strong> (SBI / Mumbai)</span>
                        <code>rahul@gmail.com / user123</code>
                    </div>
                    <div class="demo-chip" onclick="fillCustomerDemo('ananya@gmail.com', 'user123')">
                        <span>👤 <strong>Ananya Patel</strong> (ICICI / Delhi)</span>
                        <code>ananya@gmail.com / user123</code>
                    </div>
                </div>
            </div>

            <div class="auth-links" style="margin-top: 16px; text-align: center; font-size: 0.88rem;">
                New customer? <a href="${pageContext.request.contextPath}/register.jsp?role=user">Open a Bank Account</a>
            </div>
        </div>

        <!-- 2. Bank Admin Login Form (Accounts, Loans, Cards) -->
        <div id="bankAdminSection" class="<%= !isBankAdmin ? "hidden" : "" %>">
            <form action="${pageContext.request.contextPath}/bank-admin/login" method="post">
                <input type="hidden" name="from" value="central">
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

            <div class="demo-chip-group">
                <div class="demo-chip-title">
                    <span>⚡ Quick Autofill Institutional Admins</span>
                    <span style="font-weight: normal; font-size: 0.72rem;">Click to load</span>
                </div>
                <div class="demo-chips">
                    <div class="demo-chip" onclick="fillBankAdminDemo('bankadmin@gmail.com', 'admin123')">
                        <span>🏦 <strong>Lead Bank Admin</strong> (All Partner Banks)</span>
                        <code>bankadmin@gmail.com / admin123</code>
                    </div>
                    <div class="demo-chip" onclick="fillBankAdminDemo('sbi.admin@gmail.com', 'admin123')">
                        <span>🏛️ <strong>SBI Administrator</strong> (State Bank of India)</span>
                        <code>sbi.admin@gmail.com / admin123</code>
                    </div>
                    <div class="demo-chip" onclick="fillBankAdminDemo('hdfc.admin@gmail.com', 'admin123')">
                        <span>🏛️ <strong>HDFC Administrator</strong> (HDFC Bank)</span>
                        <code>hdfc.admin@gmail.com / admin123</code>
                    </div>
                    <div class="demo-chip" onclick="fillBankAdminDemo('icici.admin@gmail.com', 'admin123')">
                        <span>🏛️ <strong>ICICI Administrator</strong> (ICICI Bank)</span>
                        <code>icici.admin@gmail.com / admin123</code>
                    </div>
                </div>
            </div>

            <p style="font-size: 0.8rem; color: #64748b; margin-top: 14px; text-align: center;">
                Bank administrators underwrite loan applications, regulate customer accounts, and oversee payment cards.
            </p>
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

            <div class="demo-chip-group">
                <div class="demo-chip-title">
                    <span>⚡ Quick Autofill Platform Admins</span>
                    <span style="font-weight: normal; font-size: 0.72rem;">Click to load</span>
                </div>
                <div class="demo-chips">
                    <div class="demo-chip" onclick="fillPlatformAdminDemo('admin@gmail.com', 'admin123')">
                        <span>🛡️ <strong>Platform Admin</strong> (Commission Authority)</span>
                        <code>admin@gmail.com / admin123</code>
                    </div>
                    <div class="demo-chip" onclick="fillPlatformAdminDemo('priyanshu.admin@gmail.com', 'admin123')">
                        <span>🛡️ <strong>Priyanshu (Platform Admin)</strong></span>
                        <code>priyanshu.admin@gmail.com / admin123</code>
                    </div>
                </div>
            </div>

            <p style="font-size: 0.8rem; color: #64748b; margin-top: 14px; text-align: center;">
                Platform governance strictly controls partner bank transaction fee rates, commission yields, and audit ledgers.
            </p>
        </div>

        <div class="portal-direct-links">
            <a href="${pageContext.request.contextPath}/index.jsp">🏠 Platform Home</a>
            <span>&bull;</span>
            <a href="${pageContext.request.contextPath}/bank-admin/login.jsp">🏦 Standalone Bank Portal</a>
            <span>&bull;</span>
            <a href="${pageContext.request.contextPath}/register.jsp?role=user">👤 Customer Registration</a>
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

        var tag = document.getElementById('roleTag');
        var title = document.getElementById('roleHeaderTitle');
        var subtitle = document.getElementById('roleSubtitle');

        if (tag && title && subtitle) {
            if (isCust) {
                tag.className = 'role-banner-tag tag-user';
                tag.textContent = 'Personal Banking';
                title.textContent = 'Customer Sign In';
                subtitle.textContent = 'Access your personal accounts, execute transfers, manage cards, and apply for loans.';
            } else if (isBank) {
                tag.className = 'role-banner-tag tag-bank';
                tag.textContent = 'Institutional Bank Desk';
                title.textContent = 'Bank Administrator Operations';
                subtitle.textContent = 'Institutional bank console: Underwrite loans, activate customer accounts, and oversee cards.';
            } else {
                tag.className = 'role-banner-tag tag-platform';
                tag.textContent = 'Platform Governance';
                title.textContent = 'Platform Commission Governance';
                subtitle.textContent = 'Platform revenue authority: Regulate partner bank fee rates, monitor platform revenue, and audit ledgers.';
            }
        }

        var navReg = document.getElementById('navRegisterLink');
        if (navReg) {
            navReg.style.display = isCust ? 'inline-block' : 'none';
        }

        // Update URL query string without reloading page
        if (window.history && window.history.replaceState) {
            var newUrl = window.location.pathname + '?role=' + (isCust ? 'user' : (isBank ? 'bank_admin' : 'platform_admin'));
            window.history.replaceState({ role: role }, '', newUrl);
        }
    }

    function fillCustomerDemo(email, password) {
        setPortalRole('USER');
        document.getElementById('email').value = email;
        document.getElementById('password').value = password;
        document.getElementById('email').focus();
    }

    function fillBankAdminDemo(username, password) {
        setPortalRole('BANK_ADMIN');
        document.getElementById('bankAdminUsername').value = username;
        document.getElementById('bankAdminPassword').value = password;
        document.getElementById('bankAdminUsername').focus();
    }

    function fillPlatformAdminDemo(username, password) {
        setPortalRole('PLATFORM_ADMIN');
        document.getElementById('platformUsername').value = username;
        document.getElementById('platformPassword').value = password;
        document.getElementById('platformUsername').focus();
    }

    window.addEventListener('DOMContentLoaded', function() {
        var app = document.getElementById('loginApp');
        var initialRole = (app && app.getAttribute('data-role')) ? app.getAttribute('data-role') : 'USER';
        setPortalRole(initialRole);
    });
</script>

</body>
</html>
