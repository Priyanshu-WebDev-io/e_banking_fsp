package com.ebanking;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

@WebListener
public class AppCleanupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Web application startup
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 1. Deregister JDBC drivers loaded by this webapp classloader
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        Enumeration<Driver> drivers = DriverManager.getDrivers();

        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() == cl) {
                try {
                    DriverManager.deregisterDriver(driver);
                } catch (SQLException e) {
                    sce.getServletContext().log("Failed to deregister JDBC driver: " + driver, e);
                }
            }
        }

        // 2. Shut down MySQL's AbandonedConnectionCleanupThread to prevent thread leaks
        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
        } catch (Exception e) {
            sce.getServletContext().log("Error shutting down MySQL AbandonedConnectionCleanupThread", e);
        }
    }
}
