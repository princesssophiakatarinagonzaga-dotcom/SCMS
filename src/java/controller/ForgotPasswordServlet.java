package controller;

import util.DBConnection;
import util.EmailUtil;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.Random;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = request.getParameter("email");
        if (email == null) email = "";
        email = email.trim().toLowerCase();

        try (Connection conn = DBConnection.getConnection()) {

            String sql =
                "SELECT user_id FROM users " +
                "WHERE LOWER(email) = LOWER(?) AND access_status = 'Active' AND is_verified = 'Y'";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("forgot_password.jsp?error=notfound");
                return;
            }

            String otp = String.valueOf(100000 + new Random().nextInt(900000));
            Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(10));

            String update =
                "UPDATE users SET otp_code = ?, otp_expiry = ?, otp_type = 'FORGOT' " +
                "WHERE LOWER(email) = LOWER(?)";

            PreparedStatement ps2 = conn.prepareStatement(update);
            ps2.setString(1, otp);
            ps2.setTimestamp(2, expiry);
            ps2.setString(3, email);
            ps2.executeUpdate();

            EmailUtil.sendOTPEmailHTML(email, otp);

            HttpSession session = request.getSession();
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpType", "FORGOT");
            session.setAttribute("allowPasswordReset", true);

            response.sendRedirect("otp_verification.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgot_password.jsp?error=server");
        }
    }
}