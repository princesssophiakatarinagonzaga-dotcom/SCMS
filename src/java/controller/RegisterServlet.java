package controller;

import util.DBConnection;
import util.EmailUtil;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.Random;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roleParam  = request.getParameter("role");
        String schoolId   = request.getParameter("school_id");
        String email      = request.getParameter("email");
        String lastName   = request.getParameter("last_name");
        String firstName  = request.getParameter("first_name");
        String campus     = request.getParameter("campus");
        String program    = request.getParameter("program");
        String department = request.getParameter("department");

        int roleId = 1;
        if ("MANAGER".equalsIgnoreCase(roleParam)) roleId = 2;
        if ("ADMIN".equalsIgnoreCase(roleParam))   roleId = 3;

        // Default role_label based on role
        String roleLabel = roleId == 2 ? "Manager" : roleId == 3 ? "Admin" : "Student";

        try (Connection conn = DBConnection.getConnection()) {

            // Clean inputs
            schoolId   = schoolId   == null ? "" : schoolId.trim();
            email      = email      == null ? "" : email.trim().toLowerCase();
            lastName   = lastName   == null ? "" : lastName.trim();
            firstName  = firstName  == null ? "" : firstName.trim();
            campus     = campus     == null ? "" : campus.trim().toUpperCase();
            program    = program    == null ? "" : program.trim();
            department = department == null ? "" : department.trim();

            System.out.println("\n========== REGISTER DEBUG ==========");
            System.out.println("ROLE: " + roleParam + " (" + roleId + ")");
            System.out.println("SCHOOL ID: " + schoolId);
            System.out.println("EMAIL: " + email);
            System.out.println("NAME: " + firstName + " " + lastName);
            System.out.println("CAMPUS: " + campus);
            System.out.println("PROGRAM: " + program);
            System.out.println("DEPARTMENT: " + department);

            // ================================================================
            // STEP 1: Verify against MAIN_System's main_personnel table
            // NOTE: This uses a SEPARATE DB connection to MAIN_System.
            //       If your DBConnection only points to SCMS_System,
            //       you need a second DBConnection method e.g.
            //       DBConnection.getMainConnection()
            // ================================================================
            String mainSql;
            PreparedStatement psMain;

            if (roleId == 1) {
                // STUDENT — must match school_id, email, name, campus, program
                mainSql =
                    "SELECT 1 FROM SYSTEM.main_personnel " +
                    "WHERE school_id = ? " +
                    "AND LOWER(email) = LOWER(?) " +
                    "AND LOWER(last_name) = LOWER(?) " +
                    "AND LOWER(first_name) = LOWER(?) " +
                    "AND campus = ? " +
                    "AND role_type = 'STUDENT' " +
                    "AND LOWER(program) = LOWER(?) " +
                    "AND is_active = 'Y'";

                psMain = conn.prepareStatement(mainSql);
                psMain.setString(1, schoolId);
                psMain.setString(2, email);
                psMain.setString(3, lastName);
                psMain.setString(4, firstName);
                psMain.setString(5, campus);
                psMain.setString(6, program);

            } else if (roleId == 2) {
                // MANAGER/EMPLOYEE — must match school_id, email, name, campus, department
                mainSql =
                    "SELECT 1 FROM SYSTEM.main_personnel " +
                    "WHERE school_id = ? " +
                    "AND LOWER(email) = LOWER(?) " +
                    "AND LOWER(last_name) = LOWER(?) " +
                    "AND LOWER(first_name) = LOWER(?) " +
                    "AND campus = ? " +
                    "AND role_type = 'EMPLOYEE' " +
                    "AND LOWER(department) = LOWER(?) " +
                    "AND is_active = 'Y'";

                psMain = conn.prepareStatement(mainSql);
                psMain.setString(1, schoolId);
                psMain.setString(2, email);
                psMain.setString(3, lastName);
                psMain.setString(4, firstName);
                psMain.setString(5, campus);
                psMain.setString(6, department);

            } else {
                // ADMIN
                mainSql =
                    "SELECT 1 FROM SYSTEM.main_personnel " +
                    "WHERE school_id = ? " +
                    "AND LOWER(email) = LOWER(?) " +
                    "AND LOWER(last_name) = LOWER(?) " +
                    "AND LOWER(first_name) = LOWER(?) " +
                    "AND campus = ? " +
                    "AND role_type = 'ADMIN' " +
                    "AND is_active = 'Y'";

                psMain = conn.prepareStatement(mainSql);
                psMain.setString(1, schoolId);
                psMain.setString(2, email);
                psMain.setString(3, lastName);
                psMain.setString(4, firstName);
                psMain.setString(5, campus);
            }

            ResultSet rsMain = psMain.executeQuery();

            if (!rsMain.next()) {
                System.out.println("NOT FOUND IN MAIN SYSTEM");
                response.sendRedirect("enrollment_not_found.jsp");
                return;
            }

            System.out.println("FOUND IN MAIN SYSTEM");

            // ================================================================
            // STEP 2: Check if already registered in SCMS_System users table
            // FIX: was "users" without schema — use plain "users" if your
            //      DBConnection connects as SYSTEM (owner of the table).
            //      If it doesn't, prefix with SYSTEM.users
            // ================================================================
            String checkSql =
                "SELECT is_verified FROM SYSTEM.users " +
                "WHERE school_id = ? AND LOWER(email) = LOWER(?)";

            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setString(1, schoolId);
            psCheck.setString(2, email);
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next()) {
                String isVerified = rsCheck.getString("is_verified");

                if ("Y".equals(isVerified)) {
                    // Already fully registered
                    System.out.println("ALREADY REGISTERED");
                    response.sendRedirect("registered_already.jsp");
                    return;
                } else {
                    // Unverified entry exists — resend OTP
                    System.out.println("UNVERIFIED ENTRY — RESENDING OTP");

                    String otp     = String.valueOf(100000 + new Random().nextInt(900000));
                    Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(10));

                    // FIX: column is otp_expiry (not temp_expiry)
                    PreparedStatement psUpdate = conn.prepareStatement(
                        "UPDATE SYSTEM.users " +
                        "SET otp_code = ?, otp_expiry = ?, otp_type = 'REGISTER' " +
                        "WHERE school_id = ? AND LOWER(email) = LOWER(?)");
                    psUpdate.setString(1, otp);
                    psUpdate.setTimestamp(2, expiry);
                    psUpdate.setString(3, schoolId);
                    psUpdate.setString(4, email);
                    psUpdate.executeUpdate();

                    EmailUtil.sendOTPEmailHTML(email, otp);

                    HttpSession session = request.getSession();
                    session.setAttribute("otpEmail", email);
                    session.setAttribute("otpType",  "REGISTER");
                    response.sendRedirect("otp_verification.jsp");
                    return;
                }
            }

            // ================================================================
            // STEP 3: New user — insert pending record then send OTP
            // FIX 1: added role_label column
            // FIX 2: otp_expiry instead of temp_expiry
            // FIX 3: access_status = 'Active' so LoginServlet can find them
            //        after they verify (is_verified flipped to 'Y' by OtpServlet)
            // FIX 4: department stored in plain department column
            // FIX 5: program is NULL for non-students
            // ================================================================
            String otp    = String.valueOf(100000 + new Random().nextInt(900000));
            Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(10));

            PreparedStatement psInsert = conn.prepareStatement(
                "INSERT INTO SYSTEM.users " +
                "  (school_id, first_name, last_name, email, role_id, " +
                "   program, department, " +
                "   otp_code, otp_type, otp_expiry, " +
                "   must_change_password, is_verified, access_status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'REGISTER', ?,  'Y', 'N', 'Active')"
            );

            psInsert.setString(1, schoolId);
            psInsert.setString(2, firstName);
            psInsert.setString(3, lastName);
            psInsert.setString(4, email);
            psInsert.setInt   (5, roleId);
            // program — only meaningful for students
            psInsert.setString(6, roleId == 1 ? program : null);
            // department — only meaningful for manager/admin
            psInsert.setString(7, roleId != 1 ? department : null);
            //psInsert.setString(8, roleLabel);
            psInsert.setString(8, otp);
            psInsert.setTimestamp(9, expiry);
            psInsert.executeUpdate();

            System.out.println("PENDING USER INSERTED");

            EmailUtil.sendOTPEmailHTML(email, otp);

            HttpSession session = request.getSession();
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpType",  "REGISTER");
            response.sendRedirect("otp_verification.jsp");

        } catch (Exception e) {
            System.out.println("REGISTER ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");
        }
    }
}