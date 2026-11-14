<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // Helper to get from request attribute first, then fallback to session attribute
    java.util.function.BiFunction<String, String, String> getVal = (reqKey, sessKey) -> {
        Object val = request.getAttribute(reqKey);
        if (val == null) {
            val = session.getAttribute(sessKey);
        }
        return val != null ? val.toString() : "-";
    };

    String firstName = getVal.apply("firstName", "firstName");
    String lastName = getVal.apply("lastName", "lastName");
    String email = getVal.apply("email", "email");
    String phone = getVal.apply("phone", "phone");
    String dateOfBirth = getVal.apply("dateOfBirth", "dateOfBirth");
    String address = getVal.apply("address", "address");
    String city = getVal.apply("city", "city");
    String state = getVal.apply("state", "state");
    String pincode = getVal.apply("pincode", "pincode");
    String status = getVal.apply("status", "status");
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
