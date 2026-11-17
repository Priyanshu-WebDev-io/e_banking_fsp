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
    last_name VARCHAR(50) DEFAULT '',

    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,

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

-- =============================================
-- 3. Admins Table (Admin Module)
-- =============================================
CREATE TABLE IF NOT EXISTS admins (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Mock Customers (Password for all: user123)
-- =============================================
INSERT INTO users (user_id, first_name, last_name, email, phone, password_hash, address, city, state, pincode, status)
VALUES
(1, 'Rahul', 'Sharma', 'rahul@gmail.com', '9876543210', 'user123', '42 MG Road', 'Mumbai', 'Maharashtra', '400001', 'ACTIVE'),
(2, 'Priyanshu', 'Kumar', 'priyanshu@gmail.com', '9907500629', 'user123', '15 Brigade Road', 'Bengaluru', 'Karnataka', '560001', 'ACTIVE'),
(3, 'Ananya', 'Patel', 'ananya@gmail.com', '9812345678', 'user123', '88 Park Avenue', 'Delhi', 'Delhi', '110001', 'ACTIVE')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);

-- =============================================
-- Mock Bank Accounts
-- =============================================
INSERT INTO accounts (account_id, account_number, user_id, account_type, balance, branch_name, ifsc_code, status)
VALUES
(1, '100100100101', 1, 'SAVINGS', 50000.00, 'Main Branch - Mumbai', 'EBANK000101', 'ACTIVE'),
(2, '100100200202', 2, 'CURRENT', 85000.00, 'Indiranagar - Bengaluru', 'EBANK000201', 'ACTIVE'),
(3, '100100300303', 3, 'SAVINGS', 25000.00, 'Connaught Place - Delhi', 'EBANK000301', 'ACTIVE')
ON DUPLICATE KEY UPDATE balance = VALUES(balance);

-- =============================================
-- Mock Admins (Password for all: admin123)
-- =============================================
INSERT INTO admins (admin_id, username, email, full_name, password_hash)
VALUES
(1, 'admin', 'admin@gmail.com', 'System Administrator', 'admin123'),
(2, 'priyanshu_admin', 'priyanshu.admin@gmail.com', 'Priyanshu (Admin)', 'admin123')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);


