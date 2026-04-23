package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ManagerDashboardServlet")
public class ManagerDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null
                || !Integer.valueOf(2).equals(session.getAttribute("role_id"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        try (Connection conn = DBConnection.getConnection()) {

            // ── Stats ──────────────────────────────────────────────────────
            String statSql =
                "SELECT " +
                "  COUNT(*) AS assigned, " +
                "  SUM(CASE WHEN status = 'Pending'     THEN 1 ELSE 0 END) AS pending, " +
                "  SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS inprogress, " +
                "  SUM(CASE WHEN status = 'Closed'      THEN 1 ELSE 0 END) AS closed, " +
                "  SUM(CASE WHEN priority = 'Critical'  THEN 1 ELSE 0 END) AS critical " +
                "FROM SYSTEM.concerns WHERE assigned_manager_id = ?";

            PreparedStatement statPs = conn.prepareStatement(statSql);
            statPs.setInt(1, userId);
            ResultSet statRs = statPs.executeQuery();
            if (statRs.next()) {
                request.setAttribute("assigned",   statRs.getInt("assigned"));
                request.setAttribute("pending",    statRs.getInt("pending"));
                request.setAttribute("inProgress", statRs.getInt("inprogress"));
                request.setAttribute("closed",     statRs.getInt("closed"));
                request.setAttribute("critical",   statRs.getInt("critical"));
            }

            // ── Concerns list ──────────────────────────────────────────────
            String listSql =
                "SELECT c.concern_id AS id, c.title, c.status, c.priority, " +
                "  c.created_at AS submitted_at, c.updated_at, " +
                "  mc.category_name AS category, ct.type_name AS type, " +
                "  d.department_name AS department, " +
                "  u.last_name || ', ' || u.first_name AS student_name, " +
                "  u.school_id AS student_id, " +
                "  (SELECT last_name || ', ' || first_name FROM SYSTEM.users " +
                "   WHERE user_id = c.assigned_manager_id) AS assigned_to " +
                "FROM SYSTEM.concerns c " +
                "JOIN SYSTEM.main_categories mc ON c.category_id = mc.category_id " +
                "JOIN SYSTEM.concern_types   ct ON c.type_id     = ct.type_id " +
                "JOIN SYSTEM.departments      d  ON c.department_id = d.department_id " +
                "JOIN SYSTEM.users            u  ON c.student_id = u.user_id " +
                "WHERE c.assigned_manager_id = ? " +
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
                row.put("STUDENT_NAME", listRs.getString("student_name"));
                row.put("STUDENT_ID",   listRs.getString("student_id"));
                row.put("ASSIGNED_TO",  listRs.getString("assigned_to"));
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

        request.getRequestDispatcher("manager_dashboard.jsp")
               .forward(request, response);
    }
}