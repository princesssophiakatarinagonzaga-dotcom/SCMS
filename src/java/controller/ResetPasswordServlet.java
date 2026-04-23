package controller;

import util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");
        String newPassword = request.getParameter("new_password");

        if (newPassword == null || newPassword.isEmpty()) {
            response.sendRedirect("create_new_password.jsp");
            return;
        }

        String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        try (Connection conn = DBConnection.getConnection()) {

            String sql =
                "UPDATE users SET password = ?, otp_code = NULL, otp_expiry = NULL, otp_type = NULL " +
                "WHERE LOWER(email) = LOWER(?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashed);
            ps.setString(2, email);
            
            int rows = ps.executeUpdate();
            System.out.println("ROWS UPDATED = " + rows);

            session.invalidate();
            response.sendRedirect("password_set_successfully.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("create_new_password.jsp?error=server");
        }
    }
}