<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Integer loggedInUserId = (session != null) ? (Integer) session.getAttribute("userId") : null;
    String loggedInFirstName = (session != null) ? (String) session.getAttribute("firstName") : null;

    Integer loggedInBankAdminId = (session != null) ? (Integer) session.getAttribute("bankAdminId") : null;
    String loggedInBankAdminName = (session != null) ? (String) session.getAttribute("bankAdminName") : null;
    String loggedInBankAdminBankName = (session != null) ? (String) session.getAttribute("bankAdminBankName") : null;

    Integer loggedInAdminId = (session != null) ? (Integer) session.getAttribute("adminId") : null;
    String loggedInAdminName = (session != null) ? (String) session.getAttribute("adminName") : null;
    if (loggedInAdminName == null && session != null) {
        loggedInAdminName = (String) session.getAttribute("adminUsername");
    }

    boolean isUser = (loggedInUserId != null);
    boolean isBankAdmin = (loggedInBankAdminId != null);
    boolean isPlatformAdmin = (loggedInAdminId != null);
    boolean isLoggedIn = isUser || isBankAdmin || isPlatformAdmin;
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
            padding: 60px 24px;
            border-radius: 16px;
            margin-bottom: 36px;
            box-shadow: 0 10px 30px rgba(13, 71, 161, 0.2);
        }

        .hero-banner h1 {
            font-size: 2.7rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .hero-banner p {
            font-size: 1.15rem;
            opacity: 0.92;
            max-width: 680px;
        }

        .feature-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 26px;
            height: 100%;
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
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
                                <i class="bi bi-wallet2"></i> Accounts
                            </a>
                            <ul class="dropdown-menu shadow">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/list"><i class="bi bi-list-ul text-primary me-2"></i> My Accounts</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/create"><i class="bi bi-plus-circle text-success me-2"></i> Open New Account</a></li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/user/loans">
                                <i class="bi bi-cash-stack"></i> Loans
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/user/cards">
                                <i class="bi bi-credit-card"></i> Cards
                            </a>
                        </li>
                    <% } else if (isBankAdmin) { %>
                        <!-- Navigation for Logged-in Bank Admin -->
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/bank-admin/dashboard">
                                <i class="bi bi-speedometer2"></i> Operations Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/bank-admin/accounts">
                                <i class="bi bi-wallet2"></i> Bank Accounts
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/bank-admin/loans">
                                <i class="bi bi-file-earmark-check"></i> Loans Desk
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/bank-admin/cards">
                                <i class="bi bi-credit-card-2-front"></i> Cards Desk
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/bank-admin/customers">
                                <i class="bi bi-people"></i> Customers
                            </a>
                        </li>
                    <% } else if (isPlatformAdmin) { %>
                        <!-- Navigation for Logged-in Platform Admin -->
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-graph-up-arrow"></i> Commission Overview
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/banks">
                                <i class="bi bi-building"></i> Partner Banks & Rates
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/transactions">
                                <i class="bi bi-cash-coin"></i> Commission Ledger
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="${pageContext.request.contextPath}/admin/reports">
                                <i class="bi bi-journal-text"></i> Reports & Audit
                            </a>
                        </li>
                    <% } else { %>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-semibold" href="#portals">
                                <i class="bi bi-grid-3x3-gap"></i> Access Portals
                            </a>
                        </li>
                    <% } %>
                </ul>

                <!-- Navbar Action Controls -->
                <% if (isUser) { %>
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
                <% } else if (isBankAdmin) { %>
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-success text-white py-2 px-3 fw-bold me-2">
                            <i class="bi bi-bank me-1"></i> Bank Admin: <%= loggedInBankAdminName != null ? loggedInBankAdminName : "Admin" %>
                        </span>
                        <a href="${pageContext.request.contextPath}/bank-admin/dashboard" class="btn btn-outline-light btn-sm fw-semibold">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/bank-admin/logout" class="btn btn-warning btn-sm fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                <% } else if (isPlatformAdmin) { %>
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-danger text-white py-2 px-3 fw-bold me-2">
                            <i class="bi bi-shield-lock-fill me-1"></i> Platform Admin: <%= loggedInAdminName != null ? loggedInAdminName : "admin" %>
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-light btn-sm fw-semibold">
                            <i class="bi bi-graph-up-arrow"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-warning btn-sm fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                <% } else { %>
                    <div class="d-flex align-items-center gap-2">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-warning fw-bold px-3 shadow-sm">
                            <i class="bi bi-box-arrow-in-right"></i> Sign In / Login
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
                        <i class="bi bi-shield-lock-fill"></i> Enterprise E-Banking Platform
                    </span>
                    <h1>Digital Banking & Governance</h1>
                    <p class="mt-3">
                        Integrated financial banking portal with isolated administrative controls: Bank Operations manage accounts, loans underwriting, and payment cards, while Platform Admin governs commission yields.
                    </p>

                    <!-- Contextual Hero Actions -->
                    <div class="d-flex flex-wrap gap-3 mt-4">
                        <% if (isUser) { %>
                            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-speedometer2"></i> Customer Dashboard
                            </a>
                            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                                <i class="bi bi-wallet2"></i> My Accounts
                            </a>
                        <% } else if (isBankAdmin) { %>
                            <a href="${pageContext.request.contextPath}/bank-admin/dashboard" class="btn btn-success btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-bank"></i> Bank Operations Console
                            </a>
                            <a href="${pageContext.request.contextPath}/bank-admin/loans" class="btn btn-light btn-lg fw-bold px-4 text-success shadow">
                                <i class="bi bi-file-earmark-check"></i> Review Loans Desk
                            </a>
                        <% } else if (isPlatformAdmin) { %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-graph-up-arrow"></i> Commission Command
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/banks" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                                <i class="bi bi-building"></i> Partner Banks & Rates
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/login.jsp?role=user" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-person"></i> Customer Login
                            </a>
                            <a href="${pageContext.request.contextPath}/bank-admin/login.jsp" class="btn btn-success btn-lg fw-bold px-4 shadow">
                                <i class="bi bi-bank"></i> Bank Admin Portal
                            </a>
                            <a href="${pageContext.request.contextPath}/login.jsp?role=platform_admin" class="btn btn-outline-light btn-lg fw-bold px-4">
                                <i class="bi bi-shield-lock"></i> Platform Admin
                            </a>
                        <% } %>
                    </div>
                </div>
                <div class="col-lg-4 text-center d-none d-lg-block">
                    <i class="bi bi-shield-check" style="font-size: 8.5rem; opacity: 0.9;"></i>
                </div>
            </div>
        </div>

        <!-- Portals Grid -->
        <div id="portals" class="mb-5">
            <div class="mb-4">
                <h2 class="fw-bold text-primary mb-1">Dedicated System Portals</h2>
                <p class="text-muted">Role-segregated portals with specialized workflows</p>
            </div>

            <div class="row g-4">
                <!-- 1. Customer Banking Portal -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/<%= isUser ? "user/dashboard.jsp" : "login.jsp?role=user" %>" class="feature-card">
                        <div class="feature-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-person-circle"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">Customer Portal</h4>
                            <span class="badge bg-primary">Online Banking</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            Customer internet banking to open Savings/Current accounts, transfer money, apply for loans, and manage debit/credit cards.
                        </p>
                        <div class="mt-3 text-primary fw-semibold d-flex align-items-center gap-1">
                            Enter Customer Portal <i class="bi bi-arrow-right"></i>
                        </div>
                    </a>
                </div>

                <!-- 2. Bank Admin Portal -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/<%= isBankAdmin ? "bank-admin/dashboard" : "bank-admin/login.jsp" %>" class="feature-card">
                        <div class="feature-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-bank2"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">Bank Admin Portal</h4>
                            <span class="badge bg-success">Operations</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            Dedicated institutional portal to review and disburse loan applications, regulate bank account statuses, and oversee payment cards.
                        </p>
                        <div class="mt-3 text-success fw-semibold d-flex align-items-center gap-1">
                            Enter Bank Admin Portal <i class="bi bi-arrow-right"></i>
                        </div>
                    </a>
                </div>

                <!-- 3. Platform Admin Portal -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/<%= isPlatformAdmin ? "admin/dashboard" : "login.jsp?role=platform_admin" %>" class="feature-card">
                        <div class="feature-icon bg-danger bg-opacity-10 text-danger">
                            <i class="bi bi-cash-coin"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="fw-bold mb-0">Platform Admin Portal</h4>
                            <span class="badge bg-danger">Commissions</span>
                        </div>
                        <p class="text-muted flex-grow-1">
                            Central platform governance strictly focused on tracking and collecting transaction commissions, managing partner bank fee rates, and audit reports.
                        </p>
                        <div class="mt-3 text-danger fw-semibold d-flex align-items-center gap-1">
                            Enter Platform Console <i class="bi bi-arrow-right"></i>
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
            <p class="text-white-50 mb-3">Multi-Tier Digital Banking &bull; Institutional Operations &bull; Platform Commission Governance</p>
            <div class="d-flex justify-content-center gap-3 flex-wrap">
                <a href="${pageContext.request.contextPath}/index.jsp" class="text-white-50 text-decoration-none">Home</a>
                <span class="text-white-50">&bull;</span>
                <a href="${pageContext.request.contextPath}/login.jsp?role=user" class="text-white-50 text-decoration-none">Customer Login</a>
                <span class="text-white-50">&bull;</span>
                <a href="${pageContext.request.contextPath}/bank-admin/login.jsp" class="text-white-50 text-decoration-none">Bank Admin Portal</a>
                <span class="text-white-50">&bull;</span>
                <a href="${pageContext.request.contextPath}/login.jsp?role=platform_admin" class="text-white-50 text-decoration-none">Platform Admin</a>
            </div>
        </div>
    </footer>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>
