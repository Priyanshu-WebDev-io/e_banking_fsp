<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Integer loggedInUserId = (session != null) ? (Integer) session.getAttribute("userId") : null;
    String loggedInFirstName = (session != null) ? (String) session.getAttribute("firstName") : null;
    Integer loggedInAdminId = (session != null) ? (Integer) session.getAttribute("adminId") : null;
    String loggedInAdminName = (session != null) ? (String) session.getAttribute("adminName") : null;
    if (loggedInAdminName == null && session != null) {
        loggedInAdminName = (String) session.getAttribute("adminUsername");
    }

    boolean isUser = (loggedInUserId != null);
    boolean isAdmin = (loggedInAdminId != null);
    boolean isLoggedIn = isUser || isAdmin;
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>E-Banking Management System</title>

    <!-- Bootstrap 5 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">

    <style>
        .hero-banner {
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 60%, #1976d2 100%);
            color: #ffffff;
            padding: 70px 24px;
            border-radius: 16px;
            margin-bottom: 36px;
            box-shadow: 0 10px 30px rgba(13, 71, 161, 0.2);
        }

        .hero-banner h1 {
            font-size: 2.8rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .hero-banner p {
            font-size: 1.15rem;
            opacity: 0.92;
            max-width: 650px;
        }

        .feature-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 28px;
            height: 100%;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 14px 28px rgba(0, 0, 0, 0.08);
            border-color: #0d47a1;
        }

        .feature-icon {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin-bottom: 18px;
        }
    </style>
</head>

<body style="background-color: #f8fafc;">

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top shadow-sm"
        style="background-color: #0d47a1 !important;">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold fs-4 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/index.jsp">
                <i class="bi bi-bank2 fs-3 text-warning"></i> E-Banking System
            </a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="mainNavbar">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                    <li class="nav-item">
                        <a class="nav-link active fw-semibold" href="${pageContext.request.contextPath}/index.jsp">
                            <i class="bi bi-house-door"></i> Home
                        </a>
                    </li>

                    <% if (isUser) { %>
                        <!-- Navigation for Logged-in Customer -->
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/user/dashboard.jsp">
                                <i class="bi bi-speedometer2"></i> Dashboard
                            </a>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle text-white fw-semibold" href="#" role="button" data-bs-toggle="dropdown">
                                <i class="bi bi-wallet2"></i> Bank Accounts
                            </a>
                            <ul class="dropdown-menu shadow">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/list"><i class="bi bi-list-ul text-primary me-2"></i> My Accounts</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/create"><i class="bi bi-plus-circle text-success me-2"></i> Open New Account</a></li>
                            </ul>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/user/profile">
                                <i class="bi bi-person-vcard"></i> My Profile
                            </a>
                        </li>
                    <% } else if (isAdmin) { %>
                        <!-- Navigation for Logged-in Administrator -->
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-speedometer2"></i> Admin Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/dashboard#customers">
                                <i class="bi bi-people"></i> Customers
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/dashboard#accounts">
                                <i class="bi bi-wallet2"></i> Accounts
                            </a>
                        </li>
                    <% } else { %>
                        <!-- Navigation for Guest / Visitor -->
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="#modules">
                                <i class="bi bi-layers"></i> Banking Services
                            </a>
                        </li>
                    <% } %>
                </ul>

                <!-- Navbar Action Controls -->
                <% if (isUser) { %>
                    <!-- Logged-in Customer Controls -->
                    <div class="d-flex align-items-center gap-2">
                        <span class="text-white fw-semibold me-2 d-none d-md-inline">
                            <i class="bi bi-person-circle text-warning fs-5 align-middle me-1"></i>
                            Welcome, <%= loggedInFirstName != null ? loggedInFirstName : "Customer" %>
                        </span>
                        <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-outline-light btn-sm fw-semibold">
                            <i class="bi bi-grid"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-warning btn-sm fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                <% } else if (isAdmin) { %>
                    <!-- Logged-in Admin Controls -->
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-danger text-white py-2 px-3 fw-bold me-2">
                            <i class="bi bi-shield-lock-fill me-1"></i> Admin: <%= loggedInAdminName != null ? loggedInAdminName : "admin" %>
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-light btn-sm fw-semibold">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-warning btn-sm fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                <% } else { %>
                    <!-- Guest Controls: Simple Login / Register Buttons -->
                    <div class="d-flex align-items-center gap-2">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-warning fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-in-right"></i> Login
                        </a>
                        <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-light fw-bold px-3 shadow-sm text-primary">
                            <i class="bi bi-person-plus-fill"></i> Register
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </nav>

    <div class="container py-4">

        <!-- Hero Banner -->
        <div class="hero-banner">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">
                        <i class="bi bi-shield-lock-fill"></i> Secure Digital Banking
                    </span>
                    <h1>Internet Banking Portal</h1>
                    <p class="mt-3">
                        Experience seamless, secure, and smart internet banking. Access your accounts, view
                        real-time balances, and manage your banking profile with ease.
                    </p>

                    <!-- Contextual Hero Actions -->
                    <div class="d-flex flex-wrap gap-3 mt-4">
                        <% if (isUser) { %>
                            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-speedometer2"></i> Go to Dashboard
                            </a>
                            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                                <i class="bi bi-wallet2"></i> My Accounts
                            </a>
                            <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-outline-light btn-lg fw-semibold px-4">
                                <i class="bi bi-person-vcard"></i> My Profile
                            </a>
                        <% } else if (isAdmin) { %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-speedometer2"></i> Admin Dashboard
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/dashboard#customers" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                                <i class="bi bi-people"></i> View Customers
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/dashboard#accounts" class="btn btn-outline-light btn-lg fw-semibold px-4">
                                <i class="bi bi-wallet2"></i> View Accounts
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-box-arrow-in-right"></i> Sign In / Login
                            </a>
                            <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                                <i class="bi bi-person-plus"></i> Open Account / Register
                            </a>
                        <% } %>
                    </div>
                </div>
                <div class="col-lg-4 text-center d-none d-lg-block">
                    <i class="bi bi-shield-check" style="font-size: 8.5rem; opacity: 0.9;"></i>
                </div>
            </div>
        </div>

        <!-- Active Modules -->
        <div id="modules" class="mb-5">
            <div class="mb-4">
                <h2 class="fw-bold text-primary mb-1">Banking Services</h2>
                <p class="text-muted">Explore our digital banking features</p>
            </div>

            <div class="row g-4">
                <!-- 1. User Authentication Module -->
                <div class="col-md-4">
                    <a href="<%= isUser ? "user/dashboard.jsp" : "login.jsp" %>" class="feature-card">
                        <div class="feature-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-person-lock"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">User Authentication</h4>
                            <span class="badge bg-success">Active</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            Customer registration with input validation, secure session management, login
                            authentication, and safe logout.
                        </p>
                        <div class="mt-3 text-primary fw-semibold d-flex align-items-center gap-1">
                            <%= isUser ? "Go to Dashboard" : "Go to Login" %> <i class="bi bi-arrow-right"></i>
                        </div>
                    </a>
                </div>

                <!-- 2. Customer Profile Module -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/user/profile" class="feature-card">
                        <div class="feature-icon bg-info bg-opacity-10 text-info">
                            <i class="bi bi-person-vcard"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">Profile & Settings</h4>
                            <span class="badge bg-success">Active</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            View registered customer details, phone number, address, city, state, and update contact
                            information.
                        </p>
                        <div class="mt-3 text-info fw-semibold d-flex align-items-center gap-1">
                            View Profile <i class="bi bi-arrow-right"></i>
                        </div>
                    </a>
                </div>

                <!-- 3. Accounts Module -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/account/list" class="feature-card">
                        <div class="feature-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-wallet2"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">Bank Accounts</h4>
                            <span class="badge bg-success">Active</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            Create Savings and Current accounts, auto-generate 12-digit account numbers, branch
                            IFSC, and real-time balance tracking.
                        </p>
                        <div class="mt-3 text-success fw-semibold d-flex align-items-center gap-1">
                            View Accounts <i class="bi bi-arrow-right"></i>
                        </div>
                    </a>
                </div>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center">
            <h5 class="fw-bold mb-2">E-Banking Management System</h5>
            <p class="text-white-50 mb-3">Safe &bull; Secure &bull; Reliable Digital Banking</p>
            <div class="d-flex justify-content-center gap-3 flex-wrap">
                <a href="${pageContext.request.contextPath}/index.jsp" class="text-white-50 text-decoration-none">Home</a>
                <span class="text-white-50">&bull;</span>
                <% if (isUser) { %>
                    <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="text-white-50 text-decoration-none">Dashboard</a>
                    <span class="text-white-50">&bull;</span>
                    <a href="${pageContext.request.contextPath}/account/list" class="text-white-50 text-decoration-none">Accounts</a>
                    <span class="text-white-50">&bull;</span>
                    <a href="${pageContext.request.contextPath}/user/profile" class="text-white-50 text-decoration-none">Profile</a>
                    <span class="text-white-50">&bull;</span>
                    <a href="${pageContext.request.contextPath}/user/logout" class="text-white-50 text-decoration-none">Logout</a>
                <% } else if (isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="text-white-50 text-decoration-none">Admin Dashboard</a>
                    <span class="text-white-50">&bull;</span>
                    <a href="${pageContext.request.contextPath}/admin/logout" class="text-white-50 text-decoration-none">Admin Logout</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="text-white-50 text-decoration-none">Login</a>
                    <span class="text-white-50">&bull;</span>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="text-white-50 text-decoration-none">Register</a>
                <% } %>
            </div>
        </div>
    </footer>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>
