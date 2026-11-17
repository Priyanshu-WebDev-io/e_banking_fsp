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
-- 2. Banks Table (Banks Module)
-- =============================================
CREATE TABLE IF NOT EXISTS banks (
    bank_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(100) NOT NULL UNIQUE,
    bank_code VARCHAR(10) NOT NULL UNIQUE,
    ifsc_prefix VARCHAR(10) NOT NULL,
    commission_rate DECIMAL(5, 2) NOT NULL DEFAULT 0.50,
    status ENUM('ACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- 3. Accounts Table (Accounts Module)
-- =============================================
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    bank_id INT NULL,
    account_type ENUM('SAVINGS', 'CURRENT', 'SALARY', 'FIXED_DEPOSIT') DEFAULT 'SAVINGS',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 500.00,
    branch_name VARCHAR(100) DEFAULT 'Main Branch - Mumbai',
    ifsc_code VARCHAR(20) DEFAULT 'EBANK000101',
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED', 'CLOSED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_accounts_bank FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE SET NULL
);

-- =============================================
-- 4. Admins Table (Admin Module)
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
-- 5. Transactions Table (Transactions Module)
-- =============================================
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    reference_number VARCHAR(30) NOT NULL UNIQUE,
    from_account_id INT NULL,
    to_account_id INT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER') NOT NULL,
    status ENUM('SUCCESS', 'FAILED', 'PENDING') DEFAULT 'SUCCESS',
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trans_from FOREIGN KEY (from_account_id) REFERENCES accounts(account_id) ON DELETE SET NULL,
    CONSTRAINT fk_trans_to FOREIGN KEY (to_account_id) REFERENCES accounts(account_id) ON DELETE SET NULL
);

-- =============================================
-- 6. Commissions Table (Commission Module)
-- =============================================
CREATE TABLE IF NOT EXISTS commissions (
    commission_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_id INT NOT NULL,
    transaction_id INT NOT NULL,
    commission_rate DECIMAL(5, 2) NOT NULL,
    commission_amount DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comm_bank FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE CASCADE,
    CONSTRAINT fk_comm_trans FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE
);

-- =============================================
-- 7. Cards Table (Cards Module)
-- =============================================
CREATE TABLE IF NOT EXISTS cards (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    card_number VARCHAR(25) NOT NULL UNIQUE,
    card_type ENUM('DEBIT', 'CREDIT') NOT NULL DEFAULT 'DEBIT',
    account_id INT NOT NULL,
    user_id INT NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    expiry_date VARCHAR(7) NOT NULL,
    cvv_hash VARCHAR(64) NOT NULL,
    daily_limit DECIMAL(15, 2) DEFAULT 50000.00,
    status ENUM('PENDING', 'ACTIVE', 'BLOCKED', 'CANCELLED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cards_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    CONSTRAINT fk_cards_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
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
-- Mock Partner Banks
-- =============================================
INSERT INTO banks (bank_id, bank_name, bank_code, ifsc_prefix, commission_rate, status)
VALUES
(1, 'State Bank of India', 'SBIN', 'SBIN000101', 0.50, 'ACTIVE'),
(2, 'HDFC Bank', 'HDFC', 'HDFC000201', 0.75, 'ACTIVE'),
(3, 'ICICI Bank', 'ICIC', 'ICIC000301', 0.60, 'ACTIVE'),
(4, 'Axis Bank', 'UTIB', 'UTIB000401', 0.70, 'ACTIVE'),
(5, 'Punjab National Bank', 'PUNB', 'PUNB000501', 0.50, 'ACTIVE')
ON DUPLICATE KEY UPDATE bank_name = VALUES(bank_name);

-- =============================================
-- Mock Bank Accounts
-- =============================================
INSERT INTO accounts (account_id, account_number, user_id, bank_id, account_type, balance, branch_name, ifsc_code, status)
VALUES
(1, '100100100101', 1, 1, 'SAVINGS', 50000.00, 'Main Branch - Mumbai', 'SBIN000101', 'ACTIVE'),
(2, '100100200202', 2, 2, 'CURRENT', 85000.00, 'Indiranagar - Bengaluru', 'HDFC000201', 'ACTIVE'),
(3, '100100300303', 3, 3, 'SAVINGS', 25000.00, 'Connaught Place - Delhi', 'ICIC000301', 'ACTIVE')
ON DUPLICATE KEY UPDATE balance = VALUES(balance);

-- =============================================
-- Mock Admins (Password for all: admin123)
-- =============================================
INSERT INTO admins (admin_id, username, email, full_name, password_hash)
VALUES
(1, 'admin', 'admin@gmail.com', 'System Administrator', 'admin123'),
(2, 'priyanshu_admin', 'priyanshu.admin@gmail.com', 'Priyanshu (Admin)', 'admin123')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- =============================================
-- Mock Cards (Simulated Debit & Credit Cards)
-- =============================================
INSERT INTO cards (card_id, card_number, card_type, account_id, user_id, card_holder_name, expiry_date, cvv_hash, daily_limit, status)
VALUES
(1, '4532 8912 3456 7890', 'DEBIT', 1, 1, 'RAHUL SHARMA', '11/29', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 50000.00, 'ACTIVE'),
(2, '5412 7634 9812 4321', 'CREDIT', 2, 2, 'PRIYANSHU KUMAR', '08/30', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 100000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE card_number = VALUES(card_number);


