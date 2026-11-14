<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
            padding: 80px 20px;
            border-radius: 16px;
            margin-bottom: 40px;
            box-shadow: 0 10px 30px rgba(13, 71, 161, 0.2);
        }
        .hero-banner h1 {
            font-size: 3rem;
            font-weight: 800;
            letter-spacing: -1px;
        }
        .hero-banner p {
            font-size: 1.25rem;
            opacity: 0.9;
            max-width: 700px;
        }
        .feature-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 28px;
            height: 100%;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
        }
        .feature-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 16px 32px rgba(0, 0, 0, 0.08);
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
        .nav-pill-custom {
            padding: 8px 18px;
            border-radius: 20px;
            font-weight: 600;
        }
        .table-custom th {
            background-color: #0d47a1;
            color: white;
        }
    </style>
</head>
<body style="background-color: #f8fafc;">

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top shadow-sm" style="background-color: #0d47a1 !important;">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold fs-4 d-flex align-items-center gap-2" href="index.jsp">
            <i class="bi bi-bank2 fs-3 text-warning"></i> E-Banking System
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link active fw-semibold" href="index.jsp"><i class="bi bi-house-door"></i> Home</a>
                </li>

                <!-- User Portal Dropdown -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white fw-semibold" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-person-circle"></i> User Portal
                    </a>
                    <ul class="dropdown-menu shadow">
                        <li><a class="dropdown-item" href="user/login.jsp"><i class="bi bi-box-arrow-in-right text-primary me-2"></i> User Login</a></li>
                        <li><a class="dropdown-item" href="user/register.jsp"><i class="bi bi-person-plus text-success me-2"></i> Register New User</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="user/dashboard.jsp"><i class="bi bi-speedometer2 text-info me-2"></i> User Dashboard</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/profile"><i class="bi bi-person-vcard text-secondary me-2"></i> View Profile</a></li>
                    </ul>
                </li>

                <!-- Banking Services -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white fw-semibold" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-grid-fill"></i> Banking Services
                    </a>
                    <ul class="dropdown-menu shadow">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/list"><i class="bi bi-wallet2 text-primary me-2"></i> My Accounts</a></li>
                        <li><a class="dropdown-item" href="user/transactions.jsp"><i class="bi bi-arrow-left-right text-success me-2"></i> Transactions & Transfers</a></li>
                        <li><a class="dropdown-item" href="user/loans.jsp"><i class="bi bi-file-earmark-text text-warning me-2"></i> Loan Applications</a></li>
                        <li><a class="dropdown-item" href="user/cards.jsp"><i class="bi bi-credit-card text-danger me-2"></i> Debit & Credit Cards</a></li>
                    </ul>
                </li>

                <li class="nav-item">
                    <a class="nav-link text-white fw-semibold" href="#modules"><i class="bi bi-layers"></i> Modules</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-white fw-semibold" href="#sitemap"><i class="bi bi-compass"></i> Site Map</a>
                </li>
            </ul>

            <!-- Auth Buttons -->
            <div class="d-flex gap-2">
                <a href="user/login.jsp" class="btn btn-warning fw-bold px-3 shadow-sm">
                    <i class="bi bi-box-arrow-in-right"></i> Login
                </a>
                <a href="user/register.jsp" class="btn btn-light fw-bold px-3 shadow-sm">
                    <i class="bi bi-person-plus-fill text-primary"></i> Register
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="container py-4">

    <!-- Hero Section -->
    <div class="hero-banner">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">
                    <i class="bi bi-check-circle-fill"></i> College Project • JSP + Servlet + JDBC + MySQL
                </span>
                <h1>Enterprise Banking Portal</h1>
                <p class="mt-3">
                    A complete, lightweight, modular banking management system built with raw Java Servlets, JSP views, JDBC database queries, and MySQL storage.
                </p>
                <div class="d-flex flex-wrap gap-3 mt-4">
                    <a href="user/login.jsp" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                        <i class="bi bi-box-arrow-in-right"></i> Customer Login
                    </a>
                    <a href="user/register.jsp" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                        <i class="bi bi-person-plus"></i> Create Account
                    </a>
                    <a href="user/dashboard.jsp" class="btn btn-outline-light btn-lg fw-semibold px-4">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                </div>
            </div>
            <div class="col-lg-4 text-center d-none d-lg-block">
                <i class="bi bi-shield-check" style="font-size: 9rem; opacity: 0.85;"></i>
            </div>
        </div>
    </div>

    <!-- Quick Status Alert -->
    <div class="card border-0 shadow-sm mb-5 bg-white p-4 rounded-3">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h5 class="mb-1 text-primary fw-bold"><i class="bi bi-database-check"></i> System Architecture Status</h5>
                <p class="text-muted mb-0">Active Pattern: <code>JSP &rarr; Servlet &rarr; JDBC &rarr; MySQL</code> (No Hibernate / No Spring dependency)</p>
            </div>
            <div class="d-flex gap-2">
                <span class="badge bg-success px-3 py-2 fs-6"><i class="bi bi-check2"></i> MySQL Connected</span>
                <span class="badge bg-primary px-3 py-2 fs-6"><i class="bi bi-lock-fill"></i> Session Protected</span>
            </div>
        </div>
    </div>

    <!-- Banking Modules Section -->
    <div id="modules" class="mb-5">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Banking System Modules</h2>
                <p class="text-muted">Browse and test all available functional modules</p>
            </div>
        </div>

        <div class="row g-4">
            <!-- 1. User Module -->
            <div class="col-md-6 col-lg-4">
                <a href="user/dashboard.jsp" class="feature-card">
                    <div class="feature-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-person-circle"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">User Module</h4>
                        <span class="badge bg-success">Active</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Registration, Login authentication, Session management, Dashboard, and Profile view & update.
                    </p>
                    <div class="mt-3 text-primary fw-semibold d-flex align-items-center gap-1">
                        Access User Portal <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>

            <!-- 2. Profile Module -->
            <div class="col-md-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/user/profile" class="feature-card">
                    <div class="feature-icon bg-info bg-opacity-10 text-info">
                        <i class="bi bi-person-vcard"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">Profile & Settings</h4>
                        <span class="badge bg-success">Active</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        View customer KYC details, update phone number, address, city, state, and pincode.
                    </p>
                    <div class="mt-3 text-info fw-semibold d-flex align-items-center gap-1">
                        View Profile <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>

            <!-- 3. Accounts Module -->
            <div class="col-md-6 col-lg-4">
                <a href="${pageContext.request.contextPath}/account/list" class="feature-card">
                    <div class="feature-icon bg-success bg-opacity-10 text-success">
                        <i class="bi bi-wallet2"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">Bank Accounts</h4>
                        <span class="badge bg-success">Active</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Savings and Current account creation, view balances, account numbers, and statements linked by User ID.
                    </p>
                    <div class="mt-3 text-success fw-semibold d-flex align-items-center gap-1">
                        Manage Accounts <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>

            <!-- 4. Transactions Module -->
            <div class="col-md-6 col-lg-4">
                <a href="user/transactions.jsp" class="feature-card">
                    <div class="feature-icon bg-warning bg-opacity-10 text-warning">
                        <i class="bi bi-arrow-left-right"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">Transactions</h4>
                        <span class="badge bg-secondary">Next Step</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Fund transfers between accounts, deposits, withdrawals, and full transaction history statements.
                    </p>
                    <div class="mt-3 text-warning fw-semibold d-flex align-items-center gap-1">
                        View Transactions <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>

            <!-- 5. Loans Module -->
            <div class="col-md-6 col-lg-4">
                <a href="user/loans.jsp" class="feature-card">
                    <div class="feature-icon bg-secondary bg-opacity-10 text-secondary">
                        <i class="bi bi-file-earmark-text"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">Loans & EMI</h4>
                        <span class="badge bg-secondary">Next Step</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Personal, education, and home loan applications, approval workflow, and monthly EMI tracker.
                    </p>
                    <div class="mt-3 text-secondary fw-semibold d-flex align-items-center gap-1">
                        View Loans <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>

            <!-- 6. Cards Module -->
            <div class="col-md-6 col-lg-4">
                <a href="user/cards.jsp" class="feature-card">
                    <div class="feature-icon bg-danger bg-opacity-10 text-danger">
                        <i class="bi bi-credit-card"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">Debit & Credit Cards</h4>
                        <span class="badge bg-secondary">Next Step</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Debit/credit card requests, PIN setup, transaction limits, and card block/unblock toggles.
                    </p>
                    <div class="mt-3 text-danger fw-semibold d-flex align-items-center gap-1">
                        Manage Cards <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <!-- Complete Site Map & URL Matrix -->
    <div id="sitemap" class="card border-0 shadow-sm p-4 rounded-3 mb-5">
        <h3 class="fw-bold text-primary mb-3"><i class="bi bi-compass"></i> Complete Application Navigation Directory</h3>
        <p class="text-muted mb-4">Click any link below to test the corresponding page or Servlet endpoint directly:</p>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Page / Endpoint</th>
                        <th>Path / URL</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Direct Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>Home Landing Page</strong></td>
                        <td><code>index.jsp</code></td>
                        <td><span class="badge bg-info">JSP View</span></td>
                        <td>Main portal entry point with full navigation</td>
                        <td><a href="index.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Registration Form</strong></td>
                        <td><code>user/register.jsp</code></td>
                        <td><span class="badge bg-info">JSP View</span></td>
                        <td>Form to create a new customer account</td>
                        <td><a href="user/register.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Registration Servlet</strong></td>
                        <td><code>/user/register</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Direct JDBC INSERT to <code>ebanking.users</code></td>
                        <td><a href="user/register.jsp" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Login Form</strong></td>
                        <td><code>user/login.jsp</code></td>
                        <td><span class="badge bg-info">JSP View</span></td>
                        <td>Customer login screen with error feedback</td>
                        <td><a href="user/login.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Login Servlet</strong></td>
                        <td><code>/user/login</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Direct JDBC authentication and session creation</td>
                        <td><a href="user/login.jsp" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Dashboard</strong></td>
                        <td><code>user/dashboard.jsp</code></td>
                        <td><span class="badge bg-info">JSP View</span></td>
                        <td>Authenticated user landing page with module quick-links</td>
                        <td><a href="user/dashboard.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Profile Servlet</strong></td>
                        <td><code>/user/profile</code></td>
                        <td><span class="badge bg-primary">Servlet (GET)</span></td>
                        <td>Fetches latest user data via JDBC & forwards to profile.jsp</td>
                        <td><a href="${pageContext.request.contextPath}/user/profile" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Edit Profile Form</strong></td>
                        <td><code>user/edit-profile.jsp</code></td>
                        <td><span class="badge bg-info">JSP View</span></td>
                        <td>Pre-filled form to update phone, address, and city</td>
                        <td><a href="${pageContext.request.contextPath}/user/update-profile" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Update Profile Servlet</strong></td>
                        <td><code>/user/update-profile</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Direct JDBC UPDATE statement and session refresh</td>
                        <td><a href="${pageContext.request.contextPath}/user/update-profile" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Logout Servlet</strong></td>
                        <td><code>/user/logout</code></td>
                        <td><span class="badge bg-danger">Servlet (GET)</span></td>
                        <td>Destroys active session and redirects to login</td>
                        <td><a href="${pageContext.request.contextPath}/user/logout" class="btn btn-sm btn-outline-danger">Logout</a></td>
                    </tr>
                    <tr>
                        <td><strong>View Accounts List</strong></td>
                        <td><code>/account/list</code></td>
                        <td><span class="badge bg-primary">Servlet (GET)</span></td>
                        <td>Displays all bank accounts & balance for logged-in user</td>
                        <td><a href="${pageContext.request.contextPath}/account/list" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Open New Account</strong></td>
                        <td><code>/account/create</code></td>
                        <td><span class="badge bg-primary">Servlet (GET/POST)</span></td>
                        <td>Opens Savings, Current, or Salary account via direct JDBC</td>
                        <td><a href="${pageContext.request.contextPath}/account/create" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Transactions Module</strong></td>
                        <td><code>user/transactions.jsp</code></td>
                        <td><span class="badge bg-secondary">Placeholder</span></td>
                        <td>Next module: Transfer, deposit, and statement view</td>
                        <td><a href="user/transactions.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Loans Module</strong></td>
                        <td><code>user/loans.jsp</code></td>
                        <td><span class="badge bg-secondary">Placeholder</span></td>
                        <td>Next module: Loan applications view</td>
                        <td><a href="user/loans.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Cards Module</strong></td>
                        <td><code>user/cards.jsp</code></td>
                        <td><span class="badge bg-secondary">Placeholder</span></td>
                        <td>Next module: Debit & Credit cards overview</td>
                        <td><a href="user/cards.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- Footer -->
<footer class="bg-dark text-white py-4 mt-5">
    <div class="container text-center">
        <h5 class="fw-bold mb-2">E-Banking Management System</h5>
        <p class="text-white-50 mb-3">Academic College Project • JSP + Servlet + JDBC + MySQL Architecture</p>
        <div class="d-flex justify-content-center gap-3">
            <a href="index.jsp" class="text-white-50 text-decoration-none">Home</a>
            <span class="text-white-50">•</span>
            <a href="user/login.jsp" class="text-white-50 text-decoration-none">Login</a>
            <span class="text-white-50">•</span>
            <a href="user/register.jsp" class="text-white-50 text-decoration-none">Register</a>
            <span class="text-white-50">•</span>
            <a href="user/dashboard.jsp" class="text-white-50 text-decoration-none">Dashboard</a>
        </div>
    </div>
</footer>

<!-- Bootstrap Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
