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
    status ENUM('PENDING', 'ACTIVE', 'INACTIVE', 'BLOCKED', 'CLOSED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_accounts_bank FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE SET NULL
);

-- =============================================
-- 4. Admins Table (Platform Admin Module - Commissions & Platform Governance)
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
-- 4b. Bank Admins Table (Bank Admin Module - Accounts, Loans & Cards)
-- =============================================
CREATE TABLE IF NOT EXISTS bank_admins (
    bank_admin_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_id INT NULL,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bank_admin_bank FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE SET NULL
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
    status ENUM('PENDING', 'ACTIVE', 'BLOCKED', 'CANCELLED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cards_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    CONSTRAINT fk_cards_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =============================================
-- 8. Loan Products Table (Loans Module)
-- =============================================
CREATE TABLE IF NOT EXISTS loan_products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    loan_type ENUM('PERSONAL', 'HOME', 'VEHICLE', 'EDUCATION') NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    min_amount DECIMAL(15, 2) NOT NULL DEFAULT 10000.00,
    max_amount DECIMAL(15, 2) NOT NULL DEFAULT 5000000.00,
    min_tenure_months INT NOT NULL DEFAULT 6,
    max_tenure_months INT NOT NULL DEFAULT 60,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 9. Loan Applications Table (Loans Module)
-- =============================================
CREATE TABLE IF NOT EXISTS loan_applications (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    application_number VARCHAR(30) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    bank_id INT NOT NULL,
    product_id INT NULL,
    loan_type ENUM('PERSONAL', 'HOME', 'VEHICLE', 'EDUCATION') NOT NULL,
    principal_amount DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    tenure_months INT NOT NULL,
    monthly_emi DECIMAL(15, 2) NOT NULL,
    total_repayable DECIMAL(15, 2) NOT NULL,
    remaining_balance DECIMAL(15, 2) NOT NULL,
    purpose VARCHAR(255),
    status ENUM('PENDING', 'APPROVED', 'DISBURSED', 'REJECTED', 'CLOSED') DEFAULT 'PENDING',
    remarks VARCHAR(255) DEFAULT '',
    disbursed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_loan_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_bank FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_product FOREIGN KEY (product_id) REFERENCES loan_products(product_id) ON DELETE SET NULL
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
-- Mock Platform Admins (Password for all: admin123)
-- =============================================
INSERT INTO admins (admin_id, username, email, full_name, password_hash)
VALUES
(1, 'admin', 'admin@gmail.com', 'Platform Commission Administrator', 'admin123'),
(2, 'priyanshu_admin', 'priyanshu.admin@gmail.com', 'Priyanshu (Platform Admin)', 'admin123')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- =============================================
-- Mock Bank Admins (Password for all: admin123)
-- =============================================
INSERT INTO bank_admins (bank_admin_id, bank_id, username, email, full_name, password_hash)
VALUES
(1, NULL, 'bankadmin', 'bankadmin@gmail.com', 'Lead Bank Operations Administrator', 'admin123'),
(2, 1, 'sbi_admin', 'sbi.admin@gmail.com', 'SBI Bank Administrator', 'admin123'),
(3, 2, 'hdfc_admin', 'hdfc.admin@gmail.com', 'HDFC Bank Administrator', 'admin123'),
(4, 3, 'icici_admin', 'icici.admin@gmail.com', 'ICICI Bank Administrator', 'admin123')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- =============================================
-- Mock Cards (Simulated Debit & Credit Cards)
-- =============================================
INSERT INTO cards (card_id, card_number, card_type, account_id, user_id, card_holder_name, expiry_date, cvv_hash, daily_limit, status)
VALUES
(1, '4532 8912 3456 7890', 'DEBIT', 1, 1, 'RAHUL SHARMA', '11/29', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 50000.00, 'ACTIVE'),
(2, '5412 7634 9812 4321', 'CREDIT', 2, 2, 'PRIYANSHU KUMAR', '08/30', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 100000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE card_number = VALUES(card_number);

-- =============================================
-- Mock Loan Products & Applications
-- =============================================
INSERT INTO loan_products (product_id, product_name, loan_type, interest_rate, min_amount, max_amount, min_tenure_months, max_tenure_months, status)
VALUES
(1, 'Quick Personal Loan', 'PERSONAL', 10.50, 10000.00, 500000.00, 6, 48, 'ACTIVE'),
(2, 'Prime Home Loan', 'HOME', 8.25, 500000.00, 10000000.00, 12, 240, 'ACTIVE'),
(3, 'Auto Drive Vehicle Loan', 'VEHICLE', 9.00, 50000.00, 2000000.00, 12, 84, 'ACTIVE'),
(4, 'Scholar Education Loan', 'EDUCATION', 7.50, 50000.00, 3000000.00, 12, 120, 'ACTIVE')
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name);

INSERT INTO loan_applications (loan_id, application_number, user_id, account_id, bank_id, product_id, loan_type, principal_amount, interest_rate, tenure_months, monthly_emi, total_repayable, remaining_balance, purpose, status)
VALUES
(1, 'LNAPP202611001', 1, 1, 1, 1, 'PERSONAL', 100000.00, 10.50, 12, 8815.00, 105780.00, 105780.00, 'Home renovation and appliance purchase', 'PENDING')
ON DUPLICATE KEY UPDATE application_number = VALUES(application_number);


