-- =============================================
-- E-Banking System - User Module Database Schema
-- Database: ebanking
-- =============================================

CREATE DATABASE IF NOT EXISTS ebanking;

USE ebanking;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,

    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,

    password_hash VARCHAR(255) NOT NULL,

    date_of_birth DATE,

    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),

    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED')
        DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- Sample Test User (Password: password123)
INSERT INTO users (first_name, last_name, email, phone, password_hash, date_of_birth, address, city, state, pincode, status)
VALUES ('John', 'Doe', 'john.doe@example.com', '9876543210', 'password123', '1995-05-15', '123 Main Street', 'Mumbai', 'Maharashtra', '400001', 'ACTIVE')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);
