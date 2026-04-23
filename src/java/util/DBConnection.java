package util;

import java.sql.*;

public class DBConnection {
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        String url  = "jdbc:oracle:thin:@localhost:1521:xe";
        String user = "SYSTEM";
        String pass = "phainon";

        Connection conn = DriverManager.getConnection(url, user, pass);

        // Force all unqualified table names to resolve under SYSTEM
        Statement stmt = conn.createStatement();
        stmt.execute("ALTER SESSION SET CURRENT_SCHEMA = SYSTEM");
        stmt.close();

        return conn;
    }

    // Both SCMS_System and MAIN_System are in the same XE instance
    // so one connection method covers both tables
    public static Connection getMainConnection() throws SQLException {
        return getConnection();
    }
}