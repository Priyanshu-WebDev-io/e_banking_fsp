-- =============================================
-- E-Banking System - Database Schema
-- Database: ebanking
-- =============================================

CREATE DATABASE IF NOT EXISTS ebanking;

USE ebanking;

-- =============================================
-- 1. Users Table (User Module)
-- =============================================
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

-- =============================================
-- 2. Accounts Table (Accounts Module)
-- =============================================
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    account_type ENUM('SAVINGS', 'CURRENT', 'SALARY', 'FIXED_DEPOSIT') DEFAULT 'SAVINGS',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 500.00,
    branch_name VARCHAR(100) DEFAULT 'Main Branch - Mumbai',
    ifsc_code VARCHAR(20) DEFAULT 'EBANK000101',
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED', 'CLOSED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Sample Test User (Password: password123)
INSERT INTO users (first_name, last_name, email, phone, password_hash, date_of_birth, address, city, state, pincode, status)
VALUES ('John', 'Doe', 'john.doe@example.com', '9876543210', 'password123', '1995-05-15', '123 Main Street', 'Mumbai', 'Maharashtra', '400001', 'ACTIVE')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);

-- Sample Test Account
INSERT INTO accounts (account_number, user_id, account_type, balance, branch_name, ifsc_code, status)
SELECT '100100982341', user_id, 'SAVINGS', 25000.00, 'Main Branch - Mumbai', 'EBANK000101', 'ACTIVE'
FROM users WHERE email = 'john.doe@example.com'
ON DUPLICATE KEY UPDATE account_number = VALUES(account_number);
