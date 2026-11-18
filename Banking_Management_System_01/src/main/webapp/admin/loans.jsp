<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    String adminUsername = (String) session.getAttribute("adminUsername");

    Integer totalLoans = (Integer) request.getAttribute("totalLoans");
    if (totalLoans == null) totalLoans = 0;

    Integer pendingLoans = (Integer) request.getAttribute("pendingLoans");
    if (pendingLoans == null) pendingLoans = 0;

    Integer disbursedLoans = (Integer) request.getAttribute("disbursedLoans");
    if (disbursedLoans == null) disbursedLoans = 0;

    Integer rejectedLoans = (Integer) request.getAttribute("rejectedLoans");
    if (rejectedLoans == null) rejectedLoans = 0;

    BigDecimal totalDisbursedAmount = (BigDecimal) request.getAttribute("totalDisbursedAmount");
    if (totalDisbursedAmount == null) totalDisbursedAmount = BigDecimal.ZERO;

    String selectedStatus = (String) request.getAttribute("selectedStatus");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> loans = (List<Map<String, Object>>) request.getAttribute("loans");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loan Applications Review Desk - E-Banking Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 18px;
            margin-bottom: 24px;
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
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
        }
        .stat-info h4 {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .admin-nav-bar {
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
        .admin-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .admin-nav-bar .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
        }
        .admin-nav-bar .nav-link.active {
            background: var(--primary);
            color: #ffffff;
        }
        .filter-btn {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid var(--border);
            background: #ffffff;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .filter-btn.active {
            background: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }
        .badge-pending {
            background: #fef3c7;
            color: #92400e;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🛡️ E-Banking Admin Portal</h2>
        <div class="user-info">
            <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">Admin</span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">📊 Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link">🏛️ Partner Banks</a>
        <a href="${pageContext.request.contextPath}/admin/customers" class="nav-link">👥 Customers</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link active">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("loan_approved".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Loan application approved! Funds have been directly disbursed to customer's account and recorded in ledger.
        </div>
    <% } else if ("loan_rejected".equals(successParam)) { %>
        <div class="alert alert-warning" style="margin-bottom: 20px; background: #fffbeb; color: #b45309; border: 1px solid #fde68a;">
            ⚠️ Loan application has been rejected and customer remarks logged.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            ❌ Loan Action Error: <%= errorParam %>
        </div>
    <% } %>

    <!-- Loan Metrics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #fefce8; color: #a16207;">⏳</div>
            <div class="stat-info">
                <h4>Pending Review</h4>
                <div class="stat-value" style="color: #a16207;"><%= pendingLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f0fdf4; color: #15803d;">✅</div>
            <div class="stat-info">
                <h4>Disbursed Loans</h4>
                <div class="stat-value" style="color: var(--success);"><%= disbursedLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">💰</div>
            <div class="stat-info">
                <h4>Total Capital Disbursed</h4>
                <div class="stat-value" style="color: var(--primary); font-size: 1.35rem;"><%= currencyFormat.format(totalDisbursedAmount) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fef2f2; color: #b91c1c;">🚫</div>
            <div class="stat-info">
                <h4>Rejected Loans</h4>
                <div class="stat-value" style="color: var(--danger);"><%= rejectedLoans %></div>
            </div>
        </div>
    </div>

    <!-- Loans Desk Table Card -->
    <div class="card" style="margin-bottom: 40px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 18px;">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main);">📜 Loan Applications Review Desk (<%= loans != null ? loans.size() : 0 %>)</h3>
                <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 2px;">
                    Review applicant risk criteria, evaluate tenure & EMI, and execute one-click automated disbursals.
                </p>
            </div>

            <!-- Filter Pills -->
            <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/admin/loans" class="filter-btn <%= selectedStatus == null || selectedStatus.isEmpty() || "ALL".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">All</a>
                <a href="${pageContext.request.contextPath}/admin/loans?status=PENDING" class="filter-btn <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Pending Review</a>
                <a href="${pageContext.request.contextPath}/admin/loans?status=DISBURSED" class="filter-btn <%= "DISBURSED".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Disbursed</a>
                <a href="${pageContext.request.contextPath}/admin/loans?status=REJECTED" class="filter-btn <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Rejected</a>
            </div>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Application Ref</th>
                        <th>Customer & Account</th>
                        <th>Scheme & Type</th>
                        <th>Principal & Tenure</th>
                        <th>Monthly EMI</th>
                        <th>Status</th>
                        <th>Administrative Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (loans != null && !loans.isEmpty()) {
                        for (Map<String, Object> l : loans) {
                            Integer lId = (Integer) l.get("loanId");
                            String appNum = (String) l.get("applicationNumber");
                            String cName = (String) l.get("customerName");
                            String cEmail = (String) l.get("customerEmail");
                            String accNum = (String) l.get("accountNumber");
                            String bName = (String) l.get("bankName");
                            String pName = (String) l.get("productName");
                            BigDecimal principal = (BigDecimal) l.get("principalAmount");
                            BigDecimal emi = (BigDecimal) l.get("monthlyEmi");
                            BigDecimal rate = (BigDecimal) l.get("interestRate");
                            Integer tenure = (Integer) l.get("tenureMonths");
                            String lStatus = (String) l.get("status");
                            String remarks = (String) l.get("remarks");
                            java.sql.Timestamp appliedAt = (java.sql.Timestamp) l.get("createdAt");
                            java.sql.Timestamp disbursedAt = (java.sql.Timestamp) l.get("disbursedAt");

                            String badgeClass = "badge-pending";
                            if ("DISBURSED".equalsIgnoreCase(lStatus) || "APPROVED".equalsIgnoreCase(lStatus)) {
                                badgeClass = "badge-active";
                            } else if ("REJECTED".equalsIgnoreCase(lStatus)) {
                                badgeClass = "badge-inactive";
                            }
                %>
                    <tr>
                        <td>
                            <code><%= appNum %></code><br>
                            <small style="color: var(--text-muted);"><%= appliedAt != null ? appliedAt.toString().substring(0, 16) : "" %></small>
                        </td>
                        <td>
                            <strong><%= cName %></strong><br>
                            <small style="color: var(--text-muted);"><%= cEmail %></small><br>
                            <small>Acc #<%= accNum %> (🏛️ <%= bName %>)</small>
                        </td>
                        <td>
                            <strong><%= pName %></strong><br>
                            <small style="color: var(--text-muted);"><%= rate %>% p.a.</small>
                        </td>
                        <td>
                            <strong style="color: var(--primary);"><%= currencyFormat.format(principal) %></strong><br>
                            <small><%= tenure %> months</small>
                        </td>
                        <td>
                            <strong><%= currencyFormat.format(emi) %></strong>/mo<br>
                            <small style="color: var(--text-muted);">Total: <%= currencyFormat.format(emi.multiply(BigDecimal.valueOf(tenure))) %></small>
                        </td>
                        <td>
                            <span class="badge <%= badgeClass %>" style="font-size: 0.72rem;"><%= lStatus %></span>
                            <% if (remarks != null && !remarks.trim().isEmpty()) { %>
                                <div style="font-size: 0.72rem; color: var(--text-muted); margin-top: 3px; max-width: 140px; word-break: break-word;">
                                    <%= remarks %>
                                </div>
                            <% } %>
                        </td>
                        <td style="white-space: nowrap;">
                            <% if ("PENDING".equalsIgnoreCase(lStatus)) { %>
                                <form action="${pageContext.request.contextPath}/loan" method="post" style="display: flex; flex-direction: column; gap: 6px;">
                                    <input type="hidden" name="action" value="review">
                                    <input type="hidden" name="loanId" value="<%= lId %>">
                                    <input type="text" name="remarks" placeholder="Admin remarks (optional)" style="padding: 4px 8px; font-size: 0.75rem; border: 1px solid var(--border); border-radius: 4px; width: 150px;">
                                    <div style="display: flex; gap: 6px;">
                                        <button type="submit" name="decision" value="APPROVE" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem; background: var(--success); border-color: var(--success);" onclick="return confirm('Approve loan and instantly disburse <%= currencyFormat.format(principal) %> to account #<%= accNum %>?')">
                                            ✓ Disburse
                                        </button>
                                        <button type="submit" name="decision" value="REJECT" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.75rem; color: var(--danger); border-color: var(--danger);" onclick="return confirm('Reject loan application <%= appNum %>?')">
                                            ✗ Reject
                                        </button>
                                    </div>
                                </form>
                            <% } else if ("DISBURSED".equalsIgnoreCase(lStatus)) { %>
                                <span style="color: var(--success); font-weight: 600; font-size: 0.8rem;">✓ Funds Disbursed</span><br>
                                <small style="color: var(--text-muted); font-size: 0.72rem;"><%= disbursedAt != null ? disbursedAt.toString().substring(0, 16) : "" %></small>
                            <% } else { %>
                                <span style="color: var(--text-muted); font-size: 0.8rem;">Closed</span>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No loan applications found matching this status filter.
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
