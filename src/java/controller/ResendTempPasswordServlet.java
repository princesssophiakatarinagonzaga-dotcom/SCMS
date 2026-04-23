package controller;

import util.DBConnection;
import util.EmailUtil;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.Random;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ResendTempPasswordServlet")
public class ResendTempPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect("forgot_temp_password.jsp");
            return;
        }

        email = email.trim().toLowerCase();

        try (Connection conn = DBConnection.getConnection()) {

            // must exist in BOTH tables
            String sql =
                "SELECT u.user_id " +
                "FROM users u " +
                "JOIN main_personnel m ON LOWER(u.email)=LOWER(m.email) " +
                "WHERE LOWER(u.email)=? " +
                "AND u.is_verified='Y' " +
                "AND u.must_change_password='Y' " +
                "AND (u.temp_password IS NULL OR u.temp_expiry < CURRENT_TIMESTAMP)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("forgot_temp_password.jsp?error=notfound");
                return;
            }

            // generate OTP
            String otp = String.valueOf(100000 + new Random().nextInt(900000));
            Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(10));

            PreparedStatement up = conn.prepareStatement(
                "UPDATE users SET otp_code=?, otp_expiry=?, otp_type='TEMP_RESET' " +
                "WHERE LOWER(email)=?"
            );

            up.setString(1, otp);
            up.setTimestamp(2, expiry);
            up.setString(3, email);
            up.executeUpdate();

            EmailUtil.sendOTPEmailHTML(email, otp);

            HttpSession session = request.getSession();
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpType", "TEMP_RESET");

            response.sendRedirect("otp_verification.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgot_temp_password.jsp?error=server");
        }
    }
}