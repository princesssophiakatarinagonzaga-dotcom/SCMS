package controller;

import util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Handles JSON POST from manager/admin modals to update a concern.
 * Expects Content-Type: application/json
 * Body: { "ref":"...", "category":"...", "type":"...", "dept":"...",
 *         "priority":"...", "status":"...", "assignedId":"..." }
 */
@WebServlet("/UpdateConcernServlet")
public class UpdateConcernServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Read raw JSON body
        StringBuilder sb = new StringBuilder();
        try (java.io.BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        String body = sb.toString();

        String ref        = extractJson(body, "ref");
        String category   = extractJson(body, "category");
        String type       = extractJson(body, "type");
        String dept       = extractJson(body, "dept");
        String priority   = extractJson(body, "priority");
        String status     = extractJson(body, "status");
        String assignedId = extractJson(body, "assignedId");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (ref == null || ref.isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Missing ref\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            StringBuilder sql = new StringBuilder(
                "UPDATE complaints SET updated_at = SYSDATE");

            if (category != null && !category.isEmpty())
                sql.append(", category = '").append(sanitize(category)).append("'");
            if (type != null && !type.isEmpty())
                sql.append(", type = '").append(sanitize(type)).append("'");
            if (dept != null && !dept.isEmpty())
                sql.append(", department = '").append(sanitize(dept)).append("'");
            if (priority != null && !priority.isEmpty())
                sql.append(", priority = '").append(sanitize(priority)).append("'");
            if (status != null && !status.isEmpty())
                sql.append(", status = '").append(sanitize(status)).append("'");
            if (assignedId != null && !assignedId.isEmpty()) {
                try {
                    int aid = Integer.parseInt(assignedId.trim());
                    sql.append(", assigned_to = ").append(aid);
                } catch (NumberFormatException ignored) {}
            }

            sql.append(" WHERE complaint_id = ?");

            PreparedStatement ps = conn.prepareStatement(sql.toString());
            ps.setString(1, ref);
            ps.executeUpdate();

            out.print("{\"success\":true}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // Minimal JSON field extractor (avoids pulling in a JSON library)
    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;
        int colon = json.indexOf(':', idx + search.length());
        if (colon < 0) return null;
        int start = json.indexOf('"', colon + 1);
        if (start < 0) return null;
        int end = json.indexOf('"', start + 1);
        if (end < 0) return null;
        return json.substring(start + 1, end);
    }

    // Prevent SQL injection for the dynamic UPDATE (use parameterized for all inputs ideally)
    private String sanitize(String s) {
        if (s == null) return "";
        return s.replace("'", "''"); // Oracle single-quote escape
    }
}