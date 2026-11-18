<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String qs = request.getQueryString();
    String target = request.getContextPath() + "/login.jsp" + (qs != null && !qs.isEmpty() ? "?" + qs : "");
    response.sendRedirect(target);
%>
