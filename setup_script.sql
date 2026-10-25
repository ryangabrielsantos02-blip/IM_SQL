-- 1. DATABASE CREATION AND INITIALIZATION
-- Drops the database if it already exists to allow for clean, repeated runs
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'EquipmentBorrowingDB')
BEGIN
    ALTER DATABASE EquipmentBorrowingDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EquipmentBorrowingDB;
END
GO

CREATE DATABASE EquipmentBorrowingDB;
GO

USE EquipmentBorrowingDB;
GO

-- 2. TABLE CREATION WITH CONSTRAINTS

-- User Table 
CREATE TABLE [User] (
    userID VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('BORROWER', 'CUSTODIAN'))
);

-- Equipment Table
CREATE TABLE Equipment (
    equipmentID VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    serialNumber VARCHAR(50) NOT NULL UNIQUE,
    condition VARCHAR(50) NOT NULL,
    availabilityStatus VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL
);

-- BorrowRequest Table
CREATE TABLE BorrowRequest (
    requestID VARCHAR(10) PRIMARY KEY,
    borrowerID VARCHAR(10) NOT NULL,
    dateRequested DATE NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    requestReturnDate DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    rejectionReason VARCHAR(255) NULL,
    dateBorrowed DATE NULL,
    dateReturned DATE NULL,
    returnRequested BIT NOT NULL DEFAULT 0, -- 0 = False, 1 = True
    declaredReturnCondition VARCHAR(50) NULL,
    CONSTRAINT FK_BorrowRequest_User FOREIGN KEY (borrowerID) REFERENCES [User](userID)
);

-- ReturnRecord Table
CREATE TABLE ReturnRecord (
    returnID VARCHAR(10) PRIMARY KEY,
    requestID VARCHAR(10) NOT NULL UNIQUE,
    receivedBy VARCHAR(10) NOT NULL,
    dateReturned DATE NOT NULL,
    conditionAtReturn VARCHAR(50) NOT NULL,
    isLate BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ReturnRecord_Request FOREIGN KEY (requestID) REFERENCES BorrowRequest(requestID),
    CONSTRAINT FK_ReturnRecord_Custodian FOREIGN KEY (receivedBy) REFERENCES [User](userID)
);

-- DamageReports Table
CREATE TABLE DamageReports (
    reportID VARCHAR(10) PRIMARY KEY,
    returnID VARCHAR(10) NOT NULL,
    borrowerID VARCHAR(10) NOT NULL,
    description VARCHAR(500) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH')),
    actionTaken VARCHAR(500) NULL,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT FK_DamageReports_Return FOREIGN KEY (returnID) REFERENCES ReturnRecord(returnID),
    CONSTRAINT FK_DamageReports_Borrower FOREIGN KEY (borrowerID) REFERENCES [User](userID)
);
GO

-- 3. MOCK DATA SEEDING

-- Insert Borrowers & Custodians into User table
INSERT INTO [User] (userID, name, email, password, role) VALUES 
('BR01', 'Ryan', 'ryan@gmail.com', 'pass', 'BORROWER'),
('BR02', 'Clark', 'clark@gmail.com', 'pass', 'BORROWER'),
('CU01', 'Euan', 'euan@gmail.com', 'pass', 'CUSTODIAN'),
('CU02', 'Bien', 'bien@gmail.com', 'pass', 'CUSTODIAN'); 

-- Insert Items into Equipment table
INSERT INTO Equipment (equipmentID, name, category, serialNumber, condition, availabilityStatus, location) VALUES 
('EQ01', 'Dell Latitude Laptop', 'LAPTOP', 'SN-LAP-001', 'GOOD', 'AVAILABLE', 'Shelf 1'),
('EQ02', 'Epson Projector X20', 'PROJECTOR', 'SN-PRJ-002', 'GOOD', 'AVAILABLE', 'Shelf 3'), 
('EQ03', 'Sony Mirrorless Camera', 'CAMERA', 'SN-CAM-003', 'FAIR', 'AVAILABLE', 'Cabinet B'); 

-- Insert Request logs into BorrowRequest table
INSERT INTO BorrowRequest (requestID, borrowerID, dateRequested, purpose, requestReturnDate, status, rejectionReason, dateBorrowed, dateReturned, returnRequested, declaredReturnCondition) VALUES 
('BRQ01', 'BR01', '2026-04-01', 'Capstone Project Presentation', '2026-04-10', 'RETURNED', NULL, '2026-04-02', '2026-04-09', 1, 'GOOD'), 
('BRQ02', 'BR02', '2026-04-05', 'Multimedia Recording', '2026-04-15', 'RELEASED', NULL, '2026-04-06', NULL, 0, NULL); 

-- Insert Closed tasks into ReturnRecord table
INSERT INTO ReturnRecord (returnID, requestID, receivedBy, dateReturned, conditionAtReturn, isLate) VALUES 
('RR01', 'BRQ01', 'CU01', '2026-04-09', 'GOOD', 0); 

-- Insert Issue logs into DamageReports table
INSERT INTO DamageReports (reportID, returnID, borrowerID, description, severity, actionTaken, status) VALUES 
('DR01', 'RR01', 'BR01', 'Minor scratch on the casing panel', 'LOW', 'Polished and inspected for structural safety', 'RESOLVED');
GO
