package controller;

import util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Integer senderId = (Integer) session.getAttribute("userId");
        String  ref      = request.getParameter("ref");
        String  message  = request.getParameter("message");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (ref == null || message == null || message.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Insert message
            String ins =
                "INSERT INTO messages (complaint_id, sender_id, message, sent_at) " +
                "VALUES (?, ?, ?, SYSDATE)";

            PreparedStatement ps = conn.prepareStatement(ins);
            ps.setString(1, ref);
            ps.setInt   (2, senderId);
            ps.setString(3, message.trim());
            ps.executeUpdate();

            // Also update complaint updated_at
            PreparedStatement upd = conn.prepareStatement(
                "UPDATE complaints SET updated_at = SYSDATE WHERE complaint_id = ?");
            upd.setString(1, ref);
            upd.executeUpdate();

            // Return fresh thread (reuse GetMessagesServlet logic inline)
            String sql =
                "SELECT m.message, " +
                "       u.first_name || ' ' || u.last_name AS sender_name, " +
                "       CASE WHEN u.role_id = 1 THEN 'student' ELSE 'staff' END AS role, " +
                "       TO_CHAR(m.sent_at, 'Mon DD, YYYY HH:MI AM') AS sent_at " +
                "FROM messages m " +
                "JOIN users u ON m.sender_id = u.user_id " +
                "WHERE m.complaint_id = ? " +
                "ORDER BY m.sent_at ASC";

            PreparedStatement sel = conn.prepareStatement(sql);
            sel.setString(1, ref);
            ResultSet rs = sel.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{")
                    .append("\"message\":\"").append(esc(rs.getString("message"))).append("\",")
                    .append("\"senderName\":\"").append(esc(rs.getString("sender_name"))).append("\",")
                    .append("\"role\":\"").append(esc(rs.getString("role"))).append("\",")
                    .append("\"sentAt\":\"").append(esc(rs.getString("sent_at"))).append("\"")
                    .append("}");
            }
            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"")
                .replace("\n","\\n").replace("\r","\\r").replace("\t","\\t");
    }
}