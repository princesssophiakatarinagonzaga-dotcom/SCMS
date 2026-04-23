package controller;

import util.DBConnection;
import util.EmailUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.Random;

@WebServlet("/ResendOTPServlet")
public class ResendOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email   = (String) session.getAttribute("otpEmail");
        String otpType = (String) session.getAttribute("otpType");

        long last = session.getAttribute("otpCooldown") != null
                ? (long) session.getAttribute("otpCooldown") : 0;
        long now = System.currentTimeMillis();

        if (now - last < 30000) {
            response.sendRedirect("otp_verification.jsp?cooldown=true");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            String otp    = String.valueOf(100000 + new Random().nextInt(900000));
            Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(10));

            // Preserve otp_type so VerifyOTPServlet still knows the context
            String sql =
                "UPDATE SYSTEM.users " +
                "SET otp_code = ?, otp_expiry = ?, otp_type = ? " +
                "WHERE LOWER(email) = LOWER(?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, otp);
            ps.setTimestamp(2, expiry);
            ps.setString(3, otpType);
            ps.setString(4, email);
            ps.executeUpdate();

            EmailUtil.sendOTPEmailHTML(email, otp);

            session.setAttribute("otpCooldown", now);

            response.sendRedirect("otp_verification.jsp?resent=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("otp_verification.jsp?error=server");
        }
    }
}