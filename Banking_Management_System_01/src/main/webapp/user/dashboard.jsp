<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale, com.ebanking.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
        return;
    }

    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String userFullName = (firstName != null ? firstName : "Customer") + (lastName != null ? " " + lastName : "");

    BigDecimal totalBalance = (BigDecimal) request.getAttribute("totalBalance");
    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    Integer totalCards = (Integer) request.getAttribute("totalCards");
    Integer totalLoans = (Integer) request.getAttribute("totalLoans");
    BigDecimal disbursedLoansAmount = (BigDecimal) request.getAttribute("disbursedLoansAmount");

    // Fallback if accessed directly via /user/dashboard.jsp
    if (totalBalance == null || totalAccounts == null) {
        totalBalance = BigDecimal.ZERO;
        totalAccounts = 0;
        totalCards = 0;
        totalLoans = 0;
        disbursedLoansAmount = BigDecimal.ZERO;
        try (Connection con = DBConnection.getConnection()) {
            String accSql = "SELECT COUNT(*), COALESCE(SUM(balance), 0) FROM accounts WHERE user_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalAccounts = rs.getInt(1);
                        totalBalance = rs.getBigDecimal(2);
                    }
                }
            }
            String cardSql = "SELECT COUNT(*) FROM cards WHERE user_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(cardSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                    }
                }
            }
            String loanSql = "SELECT COUNT(*), COALESCE(SUM(principal_amount), 0) FROM loan_applications WHERE user_id = ? AND status = 'DISBURSED'";
            try (PreparedStatement ps = con.prepareStatement(loanSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        disbursedLoansAmount = rs.getBigDecimal(2);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.7rem;
        }
        .stat-info h4 {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.55rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .user-nav-bar {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 24px;
            background: #ffffff;
            padding: 10px 16px;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
        }
        .user-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .user-nav-bar .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
        }
        .user-nav-bar .nav-link.active {
            background: var(--primary);
            color: #ffffff;
        }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(290px, 1fr));
            gap: 20px;
            margin-bottom: 36px;
        }
        .service-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .service-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }
        .service-icon {
            font-size: 2.2rem;
            margin-bottom: 12px;
        }
        .service-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 6px;
        }
        .service-desc {
            color: var(--text-muted);
            font-size: 0.88rem;
            line-height: 1.5;
            margin-bottom: 18px;
        }
        .service-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 14px;
            border-top: 1px solid var(--border);
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>E-Banking Customer Portal</h2>
        <div class="user-info">
            <span>Welcome, <strong><%= userFullName %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="user-nav-bar">
        <a href="${pageContext.request.contextPath}/user/dashboard" class="nav-link active">🏠 Overview</a>
        <a href="${pageContext.request.contextPath}/account/list" class="nav-link">🏦 My Accounts</a>
        <a href="${pageContext.request.contextPath}/account/create" class="nav-link">➕ Open Account</a>
        <a href="${pageContext.request.contextPath}/user/transactions" class="nav-link">💳 Transactions</a>
        <a href="${pageContext.request.contextPath}/user/cards" class="nav-link">🪪 My Cards</a>
        <a href="${pageContext.request.contextPath}/user/loans" class="nav-link">💰 Loans & EMI</a>
        <a href="${pageContext.request.contextPath}/user/profile" class="nav-link">👤 Profile</a>
    </div>

    <!-- Welcome Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h3 style="font-size: 1.35rem; color: var(--text-main); margin-bottom: 4px;">
                    Hello, <%= firstName != null ? firstName : "Customer" %>! 👋
                </h3>
                <p style="color: var(--text-muted); font-size: 0.92rem;">
                    Welcome to your personal banking dashboard. Select a banking service below to manage your accounts, execute transfers, or apply for credit.
                </p>
            </div>
            <div>
                <span class="badge" style="background: #f0fdf4; color: #15803d; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #bbf7d0; font-size: 0.85rem;">
                    ✓ KYC Verified Customer
                </span>
            </div>
        </div>
    </div>

    <!-- User KPI Financial Summary Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">💰</div>
            <div class="stat-info">
                <h4>Total Combined Balance</h4>
                <div class="stat-value" style="color: var(--success);"><%= currencyFormat.format(totalBalance) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">🏦</div>
            <div class="stat-info">
                <h4>Active Bank Accounts</h4>
                <div class="stat-value"><%= totalAccounts %> Accounts</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f5f3ff; color: #7c3aed;">🪪</div>
            <div class="stat-info">
                <h4>Virtual Cards</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= totalCards %> Active Cards</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fff7ed; color: #ea580c;">📜</div>
            <div class="stat-info">
                <h4>Active Loans</h4>
                <div class="stat-value" style="color: #ea580c;"><%= totalLoans %> Disbursed</div>
            </div>
        </div>
    </div>

    <!-- Choice of Banking Services Grid -->
    <h3 style="margin-bottom: 16px; color: var(--text-main); font-weight: 700;">Select a Banking Service</h3>

    <div class="services-grid">
        <!-- 1. My Accounts -->
        <div class="service-card">
            <div>
                <div class="service-icon">🏦</div>
                <div class="service-title">My Bank Accounts</div>
                <div class="service-desc">
                    View your active accounts across partner banks (SBI, HDFC, ICICI), check available liquid balances, and inspect IFSC routing details.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #eff6ff; color: #1d4ed8; font-weight: 600;"><%= totalAccounts %> Accounts</span>
                <a href="${pageContext.request.contextPath}/account/list" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    View Accounts &rarr;
                </a>
            </div>
        </div>

        <!-- 2. Open Account -->
        <div class="service-card">
            <div>
                <div class="service-icon">➕</div>
                <div class="service-title">Open New Account</div>
                <div class="service-desc">
                    Open a new Savings or Current account with instant 12-digit account number generation and partner bank institutional selection.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f0fdf4; color: #15803d; font-weight: 600;">Instant Activation</span>
                <a href="${pageContext.request.contextPath}/account/create" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Account &rarr;
                </a>
            </div>
        </div>

        <!-- 3. Transactions & Transfers -->
        <div class="service-card">
            <div>
                <div class="service-icon">💳</div>
                <div class="service-title">Transactions & Transfers</div>
                <div class="service-desc">
                    Deposit funds, withdraw cash, and transfer money between accounts with automated platform commission calculation and live passbook.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #eff6ff; color: #1e40af; font-weight: 600;">Live Passbook</span>
                <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Transfers & Ledger &rarr;
                </a>
            </div>
        </div>

        <!-- 4. Virtual Cards -->
        <div class="service-card">
            <div>
                <div class="service-icon">🪪</div>
                <div class="service-title">Virtual Cards Desk</div>
                <div class="service-desc">
                    Manage virtual Debit & Credit cards with metallic gradient UI, view masked numbers, and toggle immediate fraud lock protection.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f5f3ff; color: #7c3aed; font-weight: 600;"><%= totalCards %> Cards</span>
                <a href="${pageContext.request.contextPath}/user/cards" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Manage Cards &rarr;
                </a>
            </div>
        </div>

        <!-- 5. Loans & EMI -->
        <div class="service-card">
            <div>
                <div class="service-icon">💰</div>
                <div class="service-title">Loans & EMI Calculator</div>
                <div class="service-desc">
                    Explore interest rates for Personal, Home, and Vehicle loans, calculate exact monthly EMI with live sliders, and apply for direct disbursal.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #fefce8; color: #a16207; font-weight: 600;">Direct Disbursal</span>
                <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Loans & EMI &rarr;
                </a>
            </div>
        </div>

        <!-- 6. Profile -->
        <div class="service-card">
            <div>
                <div class="service-icon">👤</div>
                <div class="service-title">KYC & Personal Profile</div>
                <div class="service-desc">
                    Inspect your registered personal details, update phone number, and modify your residential delivery address and city records.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f1f5f9; color: var(--text-muted); font-weight: 600;">Profile Settings</span>
                <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    View Profile &rarr;
                </a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
