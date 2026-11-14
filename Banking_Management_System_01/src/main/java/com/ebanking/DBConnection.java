package com.ebanking;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/ebanking?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String USER =
            "root";

    // Set your MySQL password here (or pass via environment variable DB_PASSWORD)
    private static final String PASSWORD = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
        );
    }
}
