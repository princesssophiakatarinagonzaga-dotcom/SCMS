package controller;

import util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Admin assigns a manager to a concern.
 * POST params: ref (complaint_id), managerId (user_id of manager)
 */
@WebServlet("/AssignManagerServlet")
public class AssignManagerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || (Integer) session.getAttribute("role_id") != 3) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String ref       = request.getParameter("ref");
        String managerIdStr = request.getParameter("managerId");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (ref == null || managerIdStr == null) {
            out.print("{\"success\":false}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int managerId = Integer.parseInt(managerIdStr.trim());

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE complaints SET assigned_to = ?, updated_at = SYSDATE " +
                "WHERE complaint_id = ?");
            ps.setInt   (1, managerId);
            ps.setString(2, ref);
            ps.executeUpdate();

            out.print("{\"success\":true}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}