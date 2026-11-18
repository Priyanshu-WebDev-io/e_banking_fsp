<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    String firstName = (String) request.getAttribute("firstName");
    if (firstName == null) firstName = (String) session.getAttribute("firstName");
    if (firstName == null) firstName = "-";

    String lastName = (String) request.getAttribute("lastName");
    if (lastName == null) lastName = (String) session.getAttribute("lastName");
    if (lastName == null) lastName = "-";

    String email = (String) request.getAttribute("email");
    if (email == null) email = (String) session.getAttribute("email");
    if (email == null) email = "-";

    String phone = (String) request.getAttribute("phone");
    if (phone == null) phone = (String) session.getAttribute("phone");
    if (phone == null) phone = "-";

    String dateOfBirth = (String) request.getAttribute("dateOfBirth");
    if (dateOfBirth == null) dateOfBirth = (String) session.getAttribute("dateOfBirth");
    if (dateOfBirth == null) dateOfBirth = "-";

    String address = (String) request.getAttribute("address");
    if (address == null) address = (String) session.getAttribute("address");
    if (address == null) address = "-";

    String city = (String) request.getAttribute("city");
    if (city == null) city = (String) session.getAttribute("city");
    if (city == null) city = "-";

    String state = (String) request.getAttribute("state");
    if (state == null) state = (String) session.getAttribute("state");
    if (state == null) state = "-";

    String pincode = (String) request.getAttribute("pincode");
    if (pincode == null) pincode = (String) session.getAttribute("pincode");
    if (pincode == null) pincode = "-";

    String status = (String) request.getAttribute("status");
    if (status == null) status = (String) session.getAttribute("status");
    if (status == null) status = "ACTIVE";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="navbar-custom">
        <h2>Customer Profile</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2>Customer Profile</h2>
            <p>Your registered personal and contact information</p>
        </div>

        <div class="table-responsive">
            <table class="data-table">
                <tr>
                    <th>Customer ID</th>
                    <td><strong>#<%= userId %></strong></td>
                </tr>
                <tr>
                    <th>First Name</th>
                    <td><%= firstName %></td>
                </tr>
                <tr>
                    <th>Last Name</th>
                    <td><%= lastName %></td>
                </tr>
                <tr>
                    <th>Email Address</th>
                    <td><%= email %></td>
                </tr>
                <tr>
                    <th>Phone Number</th>
                    <td><%= phone %></td>
                </tr>
                <tr>
                    <th>Date of Birth</th>
                    <td><%= dateOfBirth %></td>
                </tr>
                <tr>
                    <th>Residential Address</th>
                    <td><%= address %></td>
                </tr>
                <tr>
                    <th>City</th>
                    <td><%= city %></td>
                </tr>
                <tr>
                    <th>State</th>
                    <td><%= state %></td>
                </tr>
                <tr>
                    <th>Pincode</th>
                    <td><%= pincode %></td>
                </tr>
                <tr>
                    <th>Account Status</th>
                    <td>
                        <span class="badge badge-<%= status.toLowerCase() %>">
                            <%= status %>
                        </span>
                    </td>
                </tr>
            </table>
        </div>

        <div class="actions-bar">
            <a href="${pageContext.request.contextPath}/user/update-profile" class="btn btn-primary" style="flex: 1;">Edit Profile</a>
            <a href="dashboard.jsp" class="btn btn-secondary" style="flex: 1;">Back to Dashboard</a>
        </div>
    </div>
</div>

</body>
</html>
