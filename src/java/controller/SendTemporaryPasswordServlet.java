package controller;

import util.DBConnection;
import util.EmailUtil;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/SendTemporaryPasswordServlet")
public class SendTemporaryPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");

        // Generate 8-char temp password
        String tempRaw    = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        String tempHashed = BCrypt.hashpw(tempRaw, BCrypt.gensalt());
        Timestamp expiry  = new Timestamp(System.currentTimeMillis() + (10L * 60 * 1000));

        try (Connection conn = DBConnection.getConnection()) {

            String sql =
                "UPDATE SYSTEM.users " +
                "SET temp_password = ?, temp_expiry = ?, must_change_password = 'Y' " +
                "WHERE LOWER(email) = LOWER(?) AND is_verified = 'Y'";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, tempHashed);
            ps.setTimestamp(2, expiry);
            ps.setString(3, email);

            int rows = ps.executeUpdate();

            if (rows == 0) {
                response.sendRedirect("login.jsp?error=server");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
            return;
        }

        // Send the plaintext temp password by email
        String subject  = "Your Temporary Password - TIP-SC";
        String htmlBody =
            "<html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='background:#fff;padding:30px;border-radius:8px;max-width:500px;margin:0 auto;'>" +
            "<h2 style='color:#333;'>Temporary Password</h2>" +
            "<p style='color:#666;'>Your temporary password for TIP-SC is:</p>" +
            "<div style='background:#C8A800;color:#fff;padding:15px;text-align:center;" +
            "font-size:22px;font-weight:bold;border-radius:5px;letter-spacing:3px;'>" +
            tempRaw + "</div>" +
            "<p style='color:#666;margin-top:20px;'>This password expires in <strong>10 minutes</strong> " +
            "and is valid for <strong>one sign-in only</strong>.</p>" +
            "<p style='color:#999;font-size:12px;'>You will be prompted to set a permanent password upon first login.</p>" +
            "<hr style='border:none;border-top:1px solid #ddd;margin-top:30px;'/>" +
            "<p style='color:#999;font-size:12px;'>TIP-SC System</p>" +
            "</div></body></html>";

        EmailUtil.sendHtmlEmail(email, subject, htmlBody);

        // Pass email to the next page for display
        request.setAttribute("sentEmail", email);
        request.getRequestDispatcher("request_temporary_password.jsp").forward(request, response);
    }
}