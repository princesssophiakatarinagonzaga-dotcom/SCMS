package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/StudentDashboardServlet")
public class StudentDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null
                || !Integer.valueOf(1).equals(session.getAttribute("role_id"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        try (Connection conn = DBConnection.getConnection()) {

            // ── Stats ──────────────────────────────────────────────────────
            String statSql =
                "SELECT " +
                "  COUNT(*) AS total, " +
                "  SUM(CASE WHEN status = 'Pending'     THEN 1 ELSE 0 END) AS pending, " +
                "  SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS open, " +
                "  SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS review, " +
                "  SUM(CASE WHEN status = 'Closed'      THEN 1 ELSE 0 END) AS closed " +
                "FROM SYSTEM.concerns WHERE student_id = ?";

            PreparedStatement statPs = conn.prepareStatement(statSql);
            statPs.setInt(1, userId);
            ResultSet statRs = statPs.executeQuery();
            if (statRs.next()) {
                request.setAttribute("total",   statRs.getInt("total"));
                request.setAttribute("pending", statRs.getInt("pending"));
                request.setAttribute("open",    statRs.getInt("open"));
                request.setAttribute("review",  statRs.getInt("review"));
                request.setAttribute("closed",  statRs.getInt("closed"));
            }

            // ── Concerns list ──────────────────────────────────────────────
            String listSql =
                "SELECT c.concern_id AS id, c.title, c.status, c.priority, " +
                "  c.created_at AS submitted_at, c.updated_at, " +
                "  mc.category_name AS category, ct.type_name AS type, " +
                "  d.department_name AS department " +
                "FROM SYSTEM.concerns c " +
                "JOIN SYSTEM.main_categories mc ON c.category_id = mc.category_id " +
                "JOIN SYSTEM.concern_types   ct ON c.type_id     = ct.type_id " +
                "JOIN SYSTEM.departments      d  ON c.department_id = d.department_id " +
                "WHERE c.student_id = ? " +
                "ORDER BY c.created_at DESC";

            PreparedStatement listPs = conn.prepareStatement(listSql);
            listPs.setInt(1, userId);
            ResultSet listRs = listPs.executeQuery();

            List<Map<String, Object>> complaints = new ArrayList<>();
            while (listRs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("ID",           listRs.getInt("id"));
                row.put("TITLE",        listRs.getString("title"));
                row.put("STATUS",       listRs.getString("status"));
                row.put("PRIORITY",     listRs.getString("priority"));
                row.put("CATEGORY",     listRs.getString("category"));
                row.put("TYPE",         listRs.getString("type"));
                row.put("DEPARTMENT",   listRs.getString("department"));
                row.put("SUBMITTED_AT", listRs.getTimestamp("submitted_at") != null
                    ? listRs.getTimestamp("submitted_at").toString().substring(0, 16) : "—");
                row.put("UPDATED_AT",   listRs.getTimestamp("updated_at") != null
                    ? listRs.getTimestamp("updated_at").toString().substring(0, 16) : "—");
                complaints.add(row);
            }
            request.setAttribute("complaints", complaints);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("student_dashboard.jsp")
               .forward(request, response);
    }
}