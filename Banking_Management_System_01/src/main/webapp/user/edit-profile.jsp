<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    java.util.function.BiFunction<String, String, String> getVal = (reqKey, sessKey) -> {
        Object val = request.getAttribute(reqKey);
        if (val == null) {
            val = session.getAttribute(sessKey);
        }
        return val != null ? val.toString() : "";
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card">
        <div class="brand-header">
            <h2>Edit Profile</h2>
            <p>Update your personal information below</p>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <%
            }
        %>

        <form action="${pageContext.request.contextPath}/user/update-profile" method="post">
            <input type="hidden" name="userId" value="<%= userId %>">

            <div class="form-row">
                <div class="form-group">
                    <label for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" value="<%= firstName %>" required>
                </div>

                <div class="form-group">
                    <label for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" value="<%= lastName %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email Address (Read-only)</label>
                    <input type="email" id="email" value="<%= email %>" readonly>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="text" id="phone" name="phone" value="<%= phone %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth" value="<%= dateOfBirth %>">
                </div>

                <div class="form-group">
                    <label for="city">City</label>
                    <input type="text" id="city" name="city" value="<%= city %>">
                </div>
            </div>

            <div class="form-group">
                <label for="address">Address</label>
                <textarea id="address" name="address"><%= address %></textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="state">State</label>
                    <input type="text" id="state" name="state" value="<%= state %>">
                </div>

                <div class="form-group">
                    <label for="pincode">Pincode</label>
                    <input type="text" id="pincode" name="pincode" value="<%= pincode %>">
                </div>
            </div>

            <div class="actions-bar">
                <button type="submit" class="btn btn-primary" style="flex: 1;">Save Changes</button>
                <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-secondary" style="flex: 1;">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
