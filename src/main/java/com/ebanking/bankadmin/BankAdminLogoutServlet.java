package com.ebanking.bankadmin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/bank-admin/logout")
public class BankAdminLogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("bankAdminId");
            session.removeAttribute("bankAdminUsername");
            session.removeAttribute("bankAdminName");
            session.removeAttribute("bankAdminEmail");
            session.removeAttribute("bankAdminBankId");
            session.removeAttribute("bankAdminBankName");
            session.removeAttribute("bankAdminBankCode");
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin&loggedOut=true");
    }
}
