package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import service.AuditLogService;

import java.io.IOException;

@WebFilter("/*")
public class AuditFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        String url = req.getRequestURI();

        // Do not intercept user module or static files with legacy Hibernate audit
        if (!url.contains("/user/") && (url.contains("login")
                || url.contains("transaction")
                || url.contains("loan")
                || url.contains("customer"))) {

            try {
                new AuditLogService()
                        .logActivity(
                                1,
                                "SYSTEM",
                                "ADMIN",
                                "ACCESS",
                                url,
                                req.getRemoteAddr(),
                                "SUCCESS");
            } catch (Throwable t) {
                // Safeguard: never let audit logging failures cause a 500 error for the user
                System.err.println("[AuditFilter Warning] Could not record audit log: " + t.getMessage());
            }
        }

        chain.doFilter(request, response);
    }
}
