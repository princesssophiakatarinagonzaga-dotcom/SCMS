package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    /* ===========================
       1. SESSION VALIDATION
       =========================== */
    HttpSession session = request.getSession(false);

    if (session == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String email = (String) session.getAttribute("email");

    Boolean forceChange = (Boolean) session.getAttribute("forceChange");
    Boolean allowReset  = (Boolean) session.getAttribute("allowPasswordReset");

    // Allow ONLY valid flows (first login or reset password)
    if (email == null ||
        (!Boolean.TRUE.equals(forceChange) && !Boolean.TRUE.equals(allowReset))) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* ===========================
       2. INPUT VALIDATION
       =========================== */
    String newPassword     = request.getParameter("new_password");
    String confirmPassword = request.getParameter("confirm_password");

    // Prevent NULL crash first (IMPORTANT FIX)
    if (newPassword == null || confirmPassword == null) {
        invalid(request, response, "Password fields cannot be empty.");
        return;
    }

    // Check password match
    if (!newPassword.equals(confirmPassword)) {
        invalid(request, response, "Passwords do not match.");
        return;
    }

    /* ===========================
       3. PASSWORD SECURITY RULE
       =========================== */

    // At least:
    // - 8 characters
    // - 1 letter
    // - 1 number
    // - 1 special character
    String regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&^#()_+=\\-]).{8,}$";

    if (!newPassword.matches(regex)) {
        invalid(request, response,
            "Password must be at least 8 characters and include letters, numbers, and a special character.");
        return;
    }

    try (Connection conn = DBConnection.getConnection()) {

        /* ===========================
           4. HASH PASSWORD (BCrypt)
           =========================== */
        String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        /* ===========================
           5. UPDATE USER PASSWORD IN DB
           =========================== */
        String sql =
            "UPDATE users SET " +
            "password = ?, " +
            "temp_password = NULL, " +
            "otp_expiry = NULL, " +
            "must_change_password = 'N' " +
            "WHERE LOWER(email) = LOWER(?)";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, hashed);
        ps.setString(2, email);

        int updated = ps.executeUpdate();
        System.out.println("Password update rows affected: " + updated);

        /* ===========================
           6. REFRESH USER SESSION DATA
           =========================== */
        PreparedStatement ps2 = conn.prepareStatement(
            "SELECT role_id, first_name, last_name, program " +
            "FROM users WHERE LOWER(email)=LOWER(?)"
        );

        ps2.setString(1, email);
        ResultSet rs2 = ps2.executeQuery();

        if (rs2.next()) {

            session.setAttribute("role_id", rs2.getInt("role_id"));

            session.setAttribute("fullName",
                rs2.getString("last_name") + ", " + rs2.getString("first_name"));

            session.setAttribute("program", rs2.getString("program"));

            // Flag used by success page redirect logic
            session.setAttribute("passwordChangeSuccess", true);
        }

        /* ===========================
           7. REDIRECT TO SUCCESS PAGE
           =========================== */
        response.sendRedirect("password_set_successfully.jsp");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=server");
    }
}

/* ===========================
   ERROR HANDLER METHOD
   =========================== */
private void invalid(HttpServletRequest request,
                     HttpServletResponse response,
                     String message)
        throws ServletException, IOException {

    request.setAttribute("passwordError", message);
    request.getRequestDispatcher("create_new_password.jsp").forward(request, response);
}
}