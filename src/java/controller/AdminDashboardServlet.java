package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null
                || !Integer.valueOf(3).equals(session.getAttribute("role_id"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // ── Stats ──────────────────────────────────────────────────────
            String statSql =
                "SELECT " +
                "  COUNT(*) AS total, " +
                "  SUM(CASE WHEN status = 'Pending'     THEN 1 ELSE 0 END) AS pending, " +
                "  SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS inreview, " +
                "  SUM(CASE WHEN status = 'Closed'      THEN 1 ELSE 0 END) AS closed " +
                "FROM SYSTEM.concerns";

            ResultSet statRs = conn.prepareStatement(statSql).executeQuery();
            if (statRs.next()) {
                request.setAttribute("totalComplaints", statRs.getInt("total"));
                request.setAttribute("pending",         statRs.getInt("pending"));
                request.setAttribute("inReview",        statRs.getInt("inreview"));
                request.setAttribute("closed",          statRs.getInt("closed"));
            }

            // ── Active staff count ─────────────────────────────────────────
            ResultSet staffCountRs = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM SYSTEM.users " +
                "WHERE role_id IN (2,3) AND access_status = 'Active'")
                .executeQuery();
            if (staffCountRs.next()) {
                request.setAttribute("activeStaff", staffCountRs.getInt("cnt"));
            }

            // ── All concerns ───────────────────────────────────────────────
            String listSql =
                "SELECT c.concern_id AS id, c.title, c.status, c.priority, " +
                "  c.created_at AS submitted_at, " +
                "  mc.category_name AS category, ct.type_name AS type, " +
                "  d.department_name AS department, " +
                "  u.last_name || ', ' || u.first_name AS student_name, " +
                "  (SELECT last_name || ', ' || first_name FROM SYSTEM.users " +
                "   WHERE user_id = c.assigned_manager_id) AS assigned_to " +
                "FROM SYSTEM.concerns c " +
                "JOIN SYSTEM.main_categories mc ON c.category_id = mc.category_id " +
                "JOIN SYSTEM.concern_types   ct ON c.type_id     = ct.type_id " +
                "JOIN SYSTEM.departments      d  ON c.department_id = d.department_id " +
                "JOIN SYSTEM.users            u  ON c.student_id = u.user_id " +
                "ORDER BY c.created_at DESC";

            ResultSet listRs = conn.prepareStatement(listSql).executeQuery();
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
                row.put("ASSIGNED_TO",  listRs.getString("assigned_to"));
                row.put("SUBMITTED_AT", listRs.getTimestamp("submitted_at") != null
                    ? listRs.getTimestamp("submitted_at").toString().substring(0, 16) : "—");
                complaints.add(row);
            }
            request.setAttribute("complaints", complaints);

            // ── Staff list ─────────────────────────────────────────────────
            String staffSql =
                "SELECT user_id AS id, " +
                "  last_name || ', ' || first_name AS full_name, " +
                "  email, department, role_label, access_status AS account_status " +
                "FROM SYSTEM.users WHERE role_id IN (2,3) ORDER BY last_name";

            ResultSet staffRs = conn.prepareStatement(staffSql).executeQuery();
            List<Map<String, Object>> staffList = new ArrayList<>();
            while (staffRs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("ID",             staffRs.getInt("id"));
                row.put("FULL_NAME",      staffRs.getString("full_name"));
                row.put("EMAIL",          staffRs.getString("email"));
                row.put("DEPARTMENT",     staffRs.getString("department"));
                row.put("ROLE_LABEL",     staffRs.getString("role_label"));
                row.put("ACCOUNT_STATUS", staffRs.getString("account_status"));
                staffList.add(row);
            }
            request.setAttribute("staffList", staffList);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("admin_dashboard.jsp")
               .forward(request, response);
    }
}