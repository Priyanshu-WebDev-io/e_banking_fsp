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
<nav class="navbar navbar-expand-lg navbar-dark sticky-top shadow-sm" style="background-color: #0d47a1 !important;">
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
                        <li><a class="dropdown-item" href="user/dashboard.jsp"><i class="bi bi-speedometer2 text-info me-2"></i> Dashboard</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/profile"><i class="bi bi-person-vcard text-secondary me-2"></i> My Profile</a></li>
                    </ul>
                </li>

                <!-- Bank Accounts Dropdown -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white fw-semibold" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-wallet2"></i> Bank Accounts
                    </a>
                    <ul class="dropdown-menu shadow">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/list"><i class="bi bi-list-ul text-primary me-2"></i> View All Accounts</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/account/create"><i class="bi bi-plus-circle text-success me-2"></i> Open New Account</a></li>
                    </ul>
                </li>

                <li class="nav-item">
                    <a class="nav-link text-white fw-semibold" href="#modules"><i class="bi bi-layers"></i> Modules</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-white fw-semibold" href="#directory"><i class="bi bi-compass"></i> All URLs</a>
                </li>
            </ul>

            <!-- Auth Quick Actions -->
            <div class="d-flex gap-2">
                <a href="user/login.jsp" class="btn btn-warning fw-bold px-3 shadow-sm">
                    <i class="bi bi-box-arrow-in-right"></i> Login
                </a>
                <a href="user/register.jsp" class="btn btn-light fw-bold px-3 shadow-sm text-primary">
                    <i class="bi bi-person-plus-fill"></i> Register
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="container py-4">

    <!-- Hero Banner -->
    <div class="hero-banner">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">
                    <i class="bi bi-check-circle-fill"></i> JSP &bull; Servlet &bull; JDBC &bull; MySQL
                </span>
                <h1>Internet Banking Portal</h1>
                <p class="mt-3">
                    A clean, modular e-banking system built with raw Java Servlets, JSP views, JDBC SQL statements, and MySQL storage.
                </p>
                <div class="d-flex flex-wrap gap-3 mt-4">
                    <a href="user/login.jsp" class="btn btn-warning btn-lg fw-bold px-4 shadow">
                        <i class="bi bi-box-arrow-in-right"></i> Customer Login
                    </a>
                    <a href="user/register.jsp" class="btn btn-light btn-lg fw-bold px-4 text-primary shadow">
                        <i class="bi bi-person-plus"></i> Open Account
                    </a>
                    <a href="${pageContext.request.contextPath}/account/list" class="btn btn-outline-light btn-lg fw-semibold px-4">
                        <i class="bi bi-wallet2"></i> My Accounts
                    </a>
                </div>
            </div>
            <div class="col-lg-4 text-center d-none d-lg-block">
                <i class="bi bi-shield-check" style="font-size: 8.5rem; opacity: 0.9;"></i>
            </div>
        </div>
    </div>

    <!-- Active Architecture Status -->
    <div class="card border-0 shadow-sm mb-5 bg-white p-4 rounded-3">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h5 class="mb-1 text-primary fw-bold"><i class="bi bi-cpu-fill"></i> Application Architecture</h5>
                <p class="text-muted mb-0">Pattern: <code>Browser &rarr; JSP &rarr; Servlet (JDBC) &rarr; MySQL Database</code></p>
            </div>
            <div class="d-flex gap-2">
                <span class="badge bg-success px-3 py-2 fs-6"><i class="bi bi-check-lg"></i> MySQL `ebanking`</span>
                <span class="badge bg-primary px-3 py-2 fs-6"><i class="bi bi-lock-fill"></i> Session Protected</span>
            </div>
        </div>
    </div>

    <!-- Active Modules -->
    <div id="modules" class="mb-5">
        <div class="mb-4">
            <h2 class="fw-bold text-primary mb-1">Active System Modules</h2>
            <p class="text-muted">Currently implemented and functional modules in the project</p>
        </div>

        <div class="row g-4">
            <!-- 1. User Authentication Module -->
            <div class="col-md-4">
                <a href="user/login.jsp" class="feature-card">
                    <div class="feature-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-person-lock"></i>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="fw-bold mb-0">User Authentication</h4>
                        <span class="badge bg-success">Active</span>
                    </div>
                    <p class="text-muted flex-grow-1">
                        Customer registration with input validation, secure session management, login authentication, and safe logout.
                    </p>
                    <div class="mt-3 text-primary fw-semibold d-flex align-items-center gap-1">
                        Go to Login <i class="bi bi-arrow-right"></i>
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
                        View registered customer details, phone number, address, city, state, and update contact information.
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
                        Create Savings and Current accounts, auto-generate 12-digit account numbers, branch IFSC, and real-time balance tracking.
                    </p>
                    <div class="mt-3 text-success fw-semibold d-flex align-items-center gap-1">
                        View Accounts <i class="bi bi-arrow-right"></i>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <!-- Complete Site Map / Direct URL Directory -->
    <div id="directory" class="card border-0 shadow-sm p-4 rounded-3 mb-5">
        <h3 class="fw-bold text-primary mb-2"><i class="bi bi-compass"></i> Application URL Directory</h3>
        <p class="text-muted mb-4">Direct links to all implemented JSP pages and Servlet endpoints:</p>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Feature</th>
                        <th>URL / Endpoint</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>Home Page</strong></td>
                        <td><code>index.jsp</code></td>
                        <td><span class="badge bg-info text-dark">JSP</span></td>
                        <td>Main application home landing page</td>
                        <td><a href="index.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Registration</strong></td>
                        <td><code>user/register.jsp</code></td>
                        <td><span class="badge bg-info text-dark">JSP</span></td>
                        <td>Form to create a new bank customer</td>
                        <td><a href="user/register.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Register Servlet</strong></td>
                        <td><code>/user/register</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Direct JDBC INSERT to <code>ebanking.users</code></td>
                        <td><a href="user/register.jsp" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Login</strong></td>
                        <td><code>user/login.jsp</code></td>
                        <td><span class="badge bg-info text-dark">JSP</span></td>
                        <td>Customer login screen</td>
                        <td><a href="user/login.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Login Servlet</strong></td>
                        <td><code>/user/login</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Verifies credentials & sets session</td>
                        <td><a href="user/login.jsp" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>Customer Dashboard</strong></td>
                        <td><code>user/dashboard.jsp</code></td>
                        <td><span class="badge bg-info text-dark">JSP</span></td>
                        <td>Session-protected user dashboard</td>
                        <td><a href="user/dashboard.jsp" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>View Profile</strong></td>
                        <td><code>/user/profile</code></td>
                        <td><span class="badge bg-primary">Servlet (GET)</span></td>
                        <td>Fetches user details via JDBC and displays profile.jsp</td>
                        <td><a href="${pageContext.request.contextPath}/user/profile" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Edit Profile Form</strong></td>
                        <td><code>user/edit-profile.jsp</code></td>
                        <td><span class="badge bg-info text-dark">JSP</span></td>
                        <td>Form to update customer contact details</td>
                        <td><a href="${pageContext.request.contextPath}/user/update-profile" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Update Profile Servlet</strong></td>
                        <td><code>/user/update-profile</code></td>
                        <td><span class="badge bg-primary">Servlet (POST)</span></td>
                        <td>Executes JDBC UPDATE and refreshes session</td>
                        <td><a href="${pageContext.request.contextPath}/user/update-profile" class="btn btn-sm btn-outline-secondary">Go to Form</a></td>
                    </tr>
                    <tr>
                        <td><strong>My Accounts</strong></td>
                        <td><code>/account/list</code></td>
                        <td><span class="badge bg-primary">Servlet (GET)</span></td>
                        <td>Lists all bank accounts and total balance for the user</td>
                        <td><a href="${pageContext.request.contextPath}/account/list" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>Open New Account</strong></td>
                        <td><code>/account/create</code></td>
                        <td><span class="badge bg-primary">Servlet (GET/POST)</span></td>
                        <td>Opens Savings/Current account with initial deposit</td>
                        <td><a href="${pageContext.request.contextPath}/account/create" class="btn btn-sm btn-outline-primary">Open</a></td>
                    </tr>
                    <tr>
                        <td><strong>User Logout</strong></td>
                        <td><code>/user/logout</code></td>
                        <td><span class="badge bg-danger">Servlet (GET)</span></td>
                        <td>Invalidates user session and redirects to login</td>
                        <td><a href="${pageContext.request.contextPath}/user/logout" class="btn btn-sm btn-outline-danger">Logout</a></td>
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
        <p class="text-white-50 mb-3">Academic College Project &bull; Raw JSP + Servlet + JDBC + MySQL Architecture</p>
        <div class="d-flex justify-content-center gap-3">
            <a href="index.jsp" class="text-white-50 text-decoration-none">Home</a>
            <span class="text-white-50">&bull;</span>
            <a href="user/login.jsp" class="text-white-50 text-decoration-none">Login</a>
            <span class="text-white-50">&bull;</span>
            <a href="user/register.jsp" class="text-white-50 text-decoration-none">Register</a>
            <span class="text-white-50">&bull;</span>
            <a href="${pageContext.request.contextPath}/account/list" class="text-white-50 text-decoration-none">Accounts</a>
            <span class="text-white-50">&bull;</span>
            <a href="user/dashboard.jsp" class="text-white-50 text-decoration-none">Dashboard</a>
        </div>
    </div>
</footer>

<!-- Bootstrap Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
