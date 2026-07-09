package com.Medconnect.Filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false); // Don't create a new session
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Exclude static assets or login/signup/home URLs from checks
        if (requestURI.endsWith("login.jsp") || requestURI.endsWith("signup.jsp") ||
            requestURI.endsWith("index.jsp") || requestURI.contains("/Component/") ||
            requestURI.contains("/images/") || requestURI.endsWith("LoginServlet") ||
            requestURI.endsWith("SignupNewUser")) {
            chain.doFilter(request, response);
            return;
        }

        // Check if session exists and contains userId
        if (session == null || session.getAttribute("userId") == null || session.getAttribute("role") == null) {
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=Please login to access this resource.");
            return;
        }

        String role = (String) session.getAttribute("role");

        // Role-based Access Control
        if (requestURI.contains("/admin/") && !"admin".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=Access denied. Admin privileges required.");
            return;
        }
        
        if (requestURI.contains("/doctor/") && !"doctor".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=Access denied. Doctor privileges required.");
            return;
        }
        
        if (requestURI.contains("/receptionist/") && !"receptionist".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=Access denied. Receptionist privileges required.");
            return;
        }
        
        if (requestURI.contains("/patient/") && !"patient".equals(role)) {
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=Access denied. Patient privileges required.");
            return;
        }

        // Proceed if checks pass
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
