<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer bankAdminId = (Integer) session.getAttribute("bankAdminId");
    if (bankAdminId == null) {
        response.sendRedirect(request.getContextPath() + "/bank-admin/login.jsp");
        return;
    }

    String bankAdminName = (String) session.getAttribute("bankAdminName");
    String bankAdminBankName = (String) session.getAttribute("bankAdminBankName");
    if (bankAdminBankName == null || bankAdminBankName.isEmpty()) {
        bankAdminBankName = "All Partner Banks";
    }

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
    <title>Loan Applications Desk - Bank Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 18px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .stat-info h4 {
            font-size: 0.78rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .bank-nav-bar {
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
        .bank-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .bank-nav-bar .nav-link:hover {
            background: #ecfdf5;
            color: #047857;
        }
        .bank-nav-bar .nav-link.active {
            background: #059669;
            color: #ffffff;
        }
        .filter-nav {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 18px;
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
            background: #059669;
            color: #ffffff;
            border-color: #059669;
        }
        .review-box {
            display: flex;
            gap: 8px;
            flex-direction: column;
            margin-top: 6px;
        }
        .review-box textarea {
            width: 100%;
            padding: 6px;
            font-size: 0.8rem;
            border: 1px solid var(--border);
            border-radius: 4px;
            resize: vertical;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🏦 Bank Admin Operations Portal</h2>
        <div class="user-info">
            <span class="badge" style="background: #d1fae5; color: #065f46; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">
                🏛️ <%= bankAdminBankName %>
            </span>
            <span>Welcome, <strong><%= bankAdminName %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/bank-admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="bank-nav-bar">
        <a href="${pageContext.request.contextPath}/bank-admin/dashboard" class="nav-link">📊 Operations Command</a>
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link active">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="nav-link">👥 Customer Directory</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("loan_approved".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Loan application approved! Funds disbursed into customer account and recorded in transaction ledger.
        </div>
    <% } else if ("loan_rejected".equals(successParam)) { %>
        <div class="alert alert-warning" style="margin-bottom: 20px;">
            Loan application was rejected with remarks recorded.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
        </div>
    <% } %>

    <!-- KPI Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">📜</div>
            <div class="stat-info">
                <h4>Total Applications</h4>
                <div class="stat-value"><%= totalLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fef3c7; color: #d97706;">⏳</div>
            <div class="stat-info">
                <h4>Pending Underwriting</h4>
                <div class="stat-value" style="color: #b45309;"><%= pendingLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #dcfce7; color: #166534;">✅</div>
            <div class="stat-info">
                <h4>Disbursed Loans</h4>
                <div class="stat-value" style="color: #166534;"><%= disbursedLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fee2e2; color: #991b1b;">❌</div>
            <div class="stat-info">
                <h4>Rejected Loans</h4>
                <div class="stat-value" style="color: #991b1b;"><%= rejectedLoans %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #faf5ff; color: #9333ea;">💰</div>
            <div class="stat-info">
                <h4>Disbursed Capital</h4>
                <div class="stat-value" style="color: #1d4ed8; font-size: 1.3rem;"><%= currencyFormat.format(totalDisbursedAmount) %></div>
            </div>
        </div>
    </div>

    <!-- Filter Buttons -->
    <div class="filter-nav">
        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=ALL" class="filter-btn <%= (selectedStatus == null || "ALL".equalsIgnoreCase(selectedStatus)) ? "active" : "" %>">All Loans (<%= totalLoans %>)</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=PENDING" class="filter-btn <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Pending Review (<%= pendingLoans %>)</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=DISBURSED" class="filter-btn <%= "DISBURSED".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Disbursed (<%= disbursedLoans %>)</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=REJECTED" class="filter-btn <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">Rejected (<%= rejectedLoans %>)</a>
    </div>

    <!-- Loans Review Table -->
    <div class="card">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Application #</th>
                        <th>Applicant</th>
                        <th>Product & Bank</th>
                        <th>Principal / Terms</th>
                        <th>Monthly EMI</th>
                        <th>Purpose</th>
                        <th>Status</th>
                        <th>Admin Underwriting</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (loans != null && !loans.isEmpty()) {
                        for (Map<String, Object> l : loans) {
                            String st = (String) l.get("status");
                            boolean isPending = "PENDING".equalsIgnoreCase(st);
                            int loanId = (Integer) l.get("loanId");
                    %>
                        <tr id="loan-<%= loanId %>">
                            <td>
                                <strong><%= l.get("applicationNumber") %></strong>
                                <div style="font-size: 0.75rem; color: #64748b;"><%= l.get("createdAt") %></div>
                            </td>
                            <td>
                                <div><strong><%= l.get("customerName") %></strong></div>
                                <div style="font-size: 0.8rem; color: #64748b;"><%= l.get("customerEmail") %></div>
                                <div style="font-size: 0.8rem; color: #64748b;"><%= l.get("customerPhone") %></div>
                            </td>
                            <td>
                                <div><strong><%= l.get("productName") %></strong></div>
                                <div><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= l.get("bankName") %></span></div>
                                <div style="font-size: 0.78rem; color: #64748b;">Acc: <%= l.get("accountNumber") %></div>
                            </td>
                            <td>
                                <div style="font-weight: 700; color: #1d4ed8; font-size: 1.05rem;"><%= currencyFormat.format(l.get("principalAmount")) %></div>
                                <div style="font-size: 0.8rem; color: #64748b;">Rate: <%= l.get("interestRate") %>% &bull; <%= l.get("tenureMonths") %> Months</div>
                                <div style="font-size: 0.78rem; color: #64748b;">Total: <%= currencyFormat.format(l.get("totalRepayable")) %></div>
                            </td>
                            <td style="font-weight: 700; color: #b45309;">
                                <%= currencyFormat.format(l.get("monthlyEmi")) %>/mo
                            </td>
                            <td style="max-width: 180px; font-size: 0.82rem; color: #334155;">
                                <%= l.get("purpose") != null ? l.get("purpose") : "-" %>
                            </td>
                            <td>
                                <span class="badge" style="<%= isPending ? "background: #fef3c7; color: #92400e;" : ("DISBURSED".equalsIgnoreCase(st) ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;") %>">
                                    <%= st %>
                                </span>
                                <% if (l.get("remarks") != null && !((String)l.get("remarks")).isEmpty()) { %>
                                    <div style="font-size: 0.75rem; color: #64748b; margin-top: 4px;"><em>"<%= l.get("remarks") %>"</em></div>
                                <% } %>
                            </td>
                            <td style="min-width: 220px;">
                                <% if (isPending) { %>
                                    <form action="${pageContext.request.contextPath}/bank-admin/loans" method="post" class="review-box">
                                        <input type="hidden" name="loanId" value="<%= loanId %>">
                                        <textarea name="remarks" placeholder="Review remarks (optional)..." rows="2"></textarea>
                                        <div style="display: flex; gap: 6px;">
                                            <button type="submit" name="decision" value="APPROVE" class="btn btn-success" style="flex: 1; padding: 6px 10px; font-size: 0.8rem;" onclick="return confirm('Approve this loan and disburse funds to customer account immediately?');">
                                                ✅ Approve & Disburse
                                            </button>
                                            <button type="submit" name="decision" value="REJECT" class="btn btn-danger" style="flex: 1; padding: 6px 10px; font-size: 0.8rem;" onclick="return confirm('Reject this loan application?');">
                                                ❌ Reject
                                            </button>
                                        </div>
                                    </form>
                                <% } else { %>
                                    <div style="font-size: 0.82rem; color: #64748b;">
                                        Processed
                                        <% if (l.get("disbursedAt") != null) { %>
                                            <div style="font-size: 0.75rem;"><%= l.get("disbursedAt") %></div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No loan applications found matching this status filter.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
