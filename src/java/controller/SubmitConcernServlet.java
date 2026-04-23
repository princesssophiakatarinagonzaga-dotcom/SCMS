package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubmitConcernServlet")
public class SubmitConcernServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        String category   = request.getParameter("category");
        String type       = request.getParameter("type");
        String department = request.getParameter("department");
        String title      = request.getParameter("title");
        String priority   = request.getParameter("priority");
        String details    = request.getParameter("details");
        String resolution = request.getParameter("resolution");

        // Basic validation
        if (isEmpty(category) || isEmpty(type) || isEmpty(title) || isEmpty(details)) {
            request.setAttribute("submitError", "Please fill in all required fields.");
            request.getRequestDispatcher("StudentDashboardServlet").forward(request, response);
            return;
        }

        // Clamp title length
        if (title.length() > 120) title = title.substring(0, 120);

        try (Connection conn = DBConnection.getConnection()) {

            // Generate reference number: SCM-YYYY-NNNNN
            String year = new SimpleDateFormat("yyyy").format(new Date());

            // Get next sequence value (Oracle)
            // If you don't have a sequence, use: SELECT NVL(MAX(complaint_id),0)+1 FROM complaints
            String refNo;
            try {
                PreparedStatement seqPs = conn.prepareStatement("SELECT complaint_seq.NEXTVAL FROM dual");
                ResultSet seqRs = seqPs.executeQuery();
                seqRs.next();
                long seq = seqRs.getLong(1);
                refNo = String.format("SCM-%s-%05d", year, seq);
            } catch (SQLException ex) {
                // Fallback if sequence doesn't exist
                PreparedStatement maxPs = conn.prepareStatement(
                    "SELECT NVL(MAX(complaint_id), 10000) + 1 FROM complaints");
                ResultSet maxRs = maxPs.executeQuery();
                maxRs.next();
                long nextId = maxRs.getLong(1);
                refNo = String.format("SCM-%s-%05d", year, nextId);
            }

            String sql =
                "INSERT INTO complaints " +
                "  (complaint_id, student_id, category, type, department, title, " +
                "   details, resolution, priority, status, submitted_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', SYSDATE, SYSDATE)";

            // Derive a numeric ID from the ref (Oracle sequence or manual)
            // If complaint_id is VARCHAR, just use refNo directly.
            // If complaint_id is NUMBER, parse the sequence value.
            // Adjust the INSERT to match your actual PK type.
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, refNo);                          // complaint_id (VARCHAR)
            ps.setInt   (2, userId);                         // student_id
            ps.setString(3, category);
            ps.setString(4, type);
            ps.setString(5, department != null ? department : "");
            ps.setString(6, title);
            ps.setString(7, details);
            ps.setString(8, resolution != null ? resolution : "");
            ps.setString(9, priority  != null ? priority   : "Low");
            ps.executeUpdate();

            // Forward to confirmation page with details as request attributes
            request.setAttribute("refNo",      refNo);
            request.setAttribute("category",   category);
            request.setAttribute("type",       type);
            request.setAttribute("department", department);
            request.setAttribute("title",      title);

            request.getRequestDispatcher("submit_confirmation.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboardServlet?error=submit");
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}