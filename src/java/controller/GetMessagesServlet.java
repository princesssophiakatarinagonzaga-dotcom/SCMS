package controller;

import util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String ref = request.getParameter("ref");
        if (ref == null || ref.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBConnection.getConnection()) {

            String sql =
                "SELECT m.message_text, " +
                "       u.first_name || ' ' || u.last_name AS sender_name, " +
                "       CASE WHEN r.role_name = 'STUDENT' THEN 'student' ELSE 'staff' END AS role, " +
                "       TO_CHAR(m.sent_at, 'Mon DD, YYYY HH:MI AM') AS sent_at " +
                "FROM messages m " +
                "JOIN users u ON m.sender_id = u.user_id " +
                "JOIN roles r ON u.role_id = r.role_id " +
                "WHERE m.concern_id = ? " +
                "ORDER BY m.sent_at ASC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, ref);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

                String msg        = escJson(rs.getString("message_text"));
                String senderName = escJson(rs.getString("sender_name"));
                String role       = escJson(rs.getString("role"));
                String sentAt     = escJson(rs.getString("sent_at"));

                json.append("{")
                    .append("\"message\":\"").append(msg).append("\",")
                    .append("\"senderName\":\"").append(senderName).append("\",")
                    .append("\"role\":\"").append(role).append("\",")
                    .append("\"sentAt\":\"").append(sentAt).append("\"")
                    .append("}");
            }
            json.append("]");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}