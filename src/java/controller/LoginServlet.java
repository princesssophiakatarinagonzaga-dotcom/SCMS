package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===========================
        // 1. INPUT FROM LOGIN FORM
        // ===========================
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("=== LoginServlet Started ===");
        System.out.println("Email: " + email);

        try (Connection conn = DBConnection.getConnection()) {

            // ===========================
            // 2. CHECK main_personnel FIRST
            // ===========================
            String mainSql =
                "SELECT record_id FROM main_personnel " +
                "WHERE LOWER(email) = LOWER(?) AND is_active = 'Y'";

            PreparedStatement mainPs = conn.prepareStatement(mainSql);
            mainPs.setString(1, email);
            ResultSet mainRs = mainPs.executeQuery();

            if (!mainRs.next()) {
                // Not enrolled at all
                response.sendRedirect("enrollment_not_found.jsp");
                return;
            }

            // ===========================
            // 3. CHECK users TABLE
            // ===========================
            String userSql =
                "SELECT user_id, first_name, last_name, password, temp_password, " +
                "must_change_password, role_id, program, department, " +
                "is_verified, access_status, otp_expiry " +
                "FROM users " +
                "WHERE LOWER(email) = LOWER(?) AND access_status = 'Active'";

            PreparedStatement userPs = conn.prepareStatement(userSql);
            userPs.setString(1, email);
            ResultSet userRs = userPs.executeQuery();

            if (!userRs.next()) {
                // In main_personnel but never started registration
                // Show "not verified yet, redirecting" flash then bounce to register.jsp
                redirectWithRedirecting(request, response,
                    "Email not yet verified. Redirecting...", "register.jsp");
                return;
            }

            // ===========================
            // 4. EXTRACT USER DATA
            // ===========================
            int    userId        = userRs.getInt("user_id");
            int    roleId        = userRs.getInt("role_id");
            String fullName      = userRs.getString("last_name") + ", " + userRs.getString("first_name");
            String program       = userRs.getString("program");
            String department    = userRs.getString("department");
            String isVerified    = userRs.getString("is_verified");
            String permanentHash = userRs.getString("password");
            String tempHash      = userRs.getString("temp_password");
            String mustChange    = userRs.getString("must_change_password");
            Timestamp otpExpiry  = userRs.getTimestamp("otp_expiry");

            // ===========================
            // 5. NOT YET VERIFIED
            //    (registered but OTP not confirmed)
            // ===========================
            if (!"Y".equals(isVerified)) {
                redirectWithRedirecting(request, response,
                    "Email not yet verified. Redirecting...", "register.jsp");
                return;
            }

            // ===========================
            // 6. FORCE PASSWORD CHANGE FLOWS
            // ===========================
            if ("Y".equals(mustChange) || tempHash != null) {

                // Check if temp password has expired
                // otp_expiry is reused here as the temp password expiry timestamp
                boolean tempExpired = (otpExpiry == null) ||
                    otpExpiry.before(new Timestamp(System.currentTimeMillis()));

                if (tempExpired) {
                    // Temp password expired — send them through OTP flow to get a new one
                    HttpSession session = request.getSession();
                    session.setAttribute("otpEmail", email);
                    session.setAttribute("otpType",  "RESET");
                    session.setAttribute("otpUserId", userId);
                    response.sendRedirect("otp_verification.jsp");
                    return;
                }

                // Temp password still valid — let them use it
                response.sendRedirect("set_new_password.jsp");
                return;
            }

            // ===========================
            // 7. NORMAL LOGIN — PASSWORD CHECK
            //    (verified, must_change = N, temp_password = NULL)
            // ===========================
            boolean passwordMatch = false;
            if (permanentHash != null) {
                passwordMatch = BCrypt.checkpw(password, permanentHash);
            }

            if (!passwordMatch) {
                redirectWithError(request, response, "Invalid password.");
                return;
            }

            // ===========================
            // 8. CREATE SESSION
            // ===========================
            HttpSession session = request.getSession();
            session.setAttribute("user_id",    userId);
            session.setAttribute("role_id",    roleId);
            session.setAttribute("fullName",   fullName);
            session.setAttribute("program",    program);
            session.setAttribute("department", department);

            // ===========================
            // 9. ROLE-BASED REDIRECT
            // ===========================
            if (roleId == 1) {
                response.sendRedirect("StudentDashboardServlet");
            } else if (roleId == 2) {
                response.sendRedirect("ManagerDashboardServlet");
            } else if (roleId == 3) {
                response.sendRedirect("AdminDashboardServlet");
            } else {
                response.sendRedirect("login.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(request, response, "A server error occurred. Please try again.");
        }

        System.out.println("=== LoginServlet Ended ===");
    }

    // ===========================
    // ERROR HANDLER (FLASH MESSAGE)
    // ===========================
    private void redirectWithError(HttpServletRequest request,
                                   HttpServletResponse response,
                                   String message)
            throws IOException {
        HttpSession session = request.getSession(true);
        session.setAttribute("loginError", message);
        response.sendRedirect("login.jsp");
    }

    // ===========================
    // REDIRECTING HANDLER
    // Stores message + destination so login.jsp can
    // show the message then auto-redirect after 2s
    // ===========================
    private void redirectWithRedirecting(HttpServletRequest request,
                                         HttpServletResponse response,
                                         String message,
                                         String destination)
            throws IOException {
        HttpSession session = request.getSession(true);
        session.setAttribute("loginRedirectMsg",  message);
        session.setAttribute("loginRedirectDest", destination);
        response.sendRedirect("login.jsp");
    }
}