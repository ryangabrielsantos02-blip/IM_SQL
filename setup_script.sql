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



/*
==============================================================
EQUIPMENT BORROWING AND ACCOUNTABILITY SYSTEM
COMPLETE CRUD DEMONSTRATION SCRIPT
Database: EquipmentBorrowingDB

C - CREATE (INSERT)
R - READ   (SELECT, WHERE, JOIN)
U - UPDATE (UPDATE + VERIFY)
D - DELETE (DELETE + VERIFY)

TABLES:
1. [User]
2. Equipment
3. BorrowRequest
4. BorrowRequestItems
5. ReturnRecord
6. DamageReports

DEMONSTRATION:
- Request BR98 contains THREE equipment items.
- Request BRR99 contains ONE equipment item.
- All six tables receive demonstration records.
- Updates are verified using SELECT.
- Demonstration records are deleted at the end.
- Original records are not intentionally modified.
==============================================================
*/

USE EquipmentBorrowingDB;
GO
    /* ======================================================
       PART 1: CREATE (INSERT)
       Insert records in the correct foreign-key order.
       ====================================================== */

    -- 1. USER TABLE
    -- Create one borrower and one custodian.
    INSERT INTO [User]
        (userID, name, email, password, role)
    VALUES
        ('BR98', 'Demo Borrower', 'demo.borrower98@example.com',
         'demo_password', 'BORROWER'),
        ('CU98', 'Demo Custodian', 'demo.custodian98@example.com',
         'demo_password', 'CUSTODIAN');


    -- 2. EQUIPMENT TABLE
    -- Create four equipment records.
    -- EQ98, EQ99, and EQ97 will belong to Request BR98.
    -- EQ96 will belong to Request BR99.
    INSERT INTO Equipment
        (equipmentID, name, category, serialNumber,
         condition, availabilityStatus, location)
    VALUES
        ('EQ98', 'Demo Laptop', 'LAPTOP', 'SN-DEMO-098',
         'GOOD', 'AVAILABLE', 'Demo Storage'),
        ('EQ99', 'Demo Projector', 'PROJECTOR', 'SN-DEMO-099',
         'GOOD', 'AVAILABLE', 'Demo Storage'),
        ('EQ97', 'Demo Camera', 'CAMERA', 'SN-DEMO-097',
         'GOOD', 'AVAILABLE', 'Demo Storage'),
        ('EQ96', 'Demo Monitor', 'MONITOR', 'SN-DEMO-096',
         'GOOD', 'AVAILABLE', 'Demo Storage');


    -- 3. BORROWREQUEST TABLE
    -- Create TWO borrowing requests.
    -- BR98 contains three equipment items.
    -- BR99 is a normal request for one equipment item.
    INSERT INTO BorrowRequest
        (requestID, borrowerID, dateRequested, purpose,
         requestReturnDate, status, rejectionReason,
         dateBorrowed, dateReturned, returnRequested,
         declaredReturnCondition)
    VALUES
        ('BR98', 'BR98', '2026-10-26',
         'Class presentation requiring multiple equipment items',
         '2026-10-30', 'RETURNED', NULL,
         '2026-10-26', '2026-10-27', 0, 'GOOD'),

        ('BRQ99', 'BR98', '2026-10-26',
         'Borrowing equipment for a class activity',
         '2026-10-30', 'PENDING', NULL,
         NULL, NULL, 0, NULL);

--CHECK
select * from Equipment;
select * from BorrowRequest
select * from [User];

    -- 4. BORROWREQUESTITEMS TABLE
    -- This associative table links requests to equipment.
    -- BR98 has THREE rows: laptop, projector, and camera.
    -- BRQ99 has ONE row: monitor.
    INSERT INTO BorrowRequestItems
        (requestID, equipmentID)
    VALUES
        ('BR98', 'EQ98'),
        ('BR98', 'EQ99'),
        ('BR98', 'EQ97'),
        ('BR99', 'EQ96');

--CHECK
select * from BorrowRequestItems;

    -- 5. RETURNRECORD TABLE
    -- Record the return of Request BR98.
    -- The request and receiving custodian must already exist.
    INSERT INTO ReturnRecord
        (returnID, requestID, receivedBy, dateReturned,
         conditionAtReturn, isLate)
    VALUES
        ('RR98', 'BR98', 'CU98', '2026-10-27',
         'GOOD', 0);


    -- 6. DAMAGEREPORTS TABLE
    -- Create a demonstration damage report.
    -- The return record and borrower must already exist.
    INSERT INTO DamageReports
        (reportID, returnID, borrowerID, description,
         severity, actionTaken, status)
    VALUES
        ('DR98', 'RR98', 'BR98',
         'Demonstration report for a minor equipment issue.',
         'LOW', NULL, 'PENDING');


    -- VERIFY CREATE
    -- Confirm that records were added to all six tables.
    SELECT * FROM [User]
    WHERE userID IN ('BR98', 'CU98');

    SELECT * FROM Equipment
    WHERE equipmentID IN ('EQ96', 'EQ97', 'EQ98', 'EQ99');

    SELECT * FROM BorrowRequest
    WHERE requestID IN ('BR98', 'BR99');

    SELECT * FROM BorrowRequestItems
    WHERE requestID IN ('BR98', 'BR99');

    SELECT * FROM ReturnRecord
    WHERE returnID = 'RR98';

    SELECT * FROM DamageReports
    WHERE reportID = 'DR98';


    /* ======================================================
       PART 2: READ (SELECT)
       Retrieve records using SELECT, WHERE, and JOIN.
       ====================================================== */

    -- A. BASIC SELECT
    -- Display all equipment records.
    SELECT *
    FROM Equipment;


    -- B. WHERE
    -- Display equipment that is currently available.
    SELECT *
    FROM Equipment
    WHERE availabilityStatus = 'AVAILABLE';


    -- C. WHERE
    -- Display requests submitted by the demonstration borrower.
    SELECT *
    FROM BorrowRequest
    WHERE borrowerID = 'BR98';


    -- D. JOIN
    -- Display borrowing requests with borrower names.
    SELECT
        BR.requestID,
        U.userID AS borrowerID,
        U.name AS borrowerName,
        BR.purpose,
        BR.dateRequested,
        BR.requestReturnDate,
        BR.status
    FROM BorrowRequest AS BR
    INNER JOIN [User] AS U
        ON BR.borrowerID = U.userID;


    -- E. JOIN: IMPORTANT MANY-TO-MANY DEMONSTRATION
    -- Connect BorrowRequest, BorrowRequestItems, and Equipment.
    -- BR98 should appear THREE times, once for each item.
    -- BRR99 should appear ONCE.
    SELECT
        BR.requestID,
        U.name AS borrowerName,
        BR.purpose,
        BRI.equipmentID,
        E.name AS equipmentName,
        E.category,
        E.availabilityStatus
    FROM BorrowRequest AS BR
    INNER JOIN [User] AS U
        ON BR.borrowerID = U.userID
    INNER JOIN BorrowRequestItems AS BRI
        ON BR.requestID = BRI.requestID
    INNER JOIN Equipment AS E
        ON BRI.equipmentID = E.equipmentID
    WHERE BR.requestID IN ('BR98', 'BR99')
    ORDER BY BR.requestID, BRI.equipmentID;


    -- F. JOIN
    -- Display return details with borrower and custodian names.
    SELECT
        RR.returnID,
        RR.requestID,
        B.name AS borrowerName,
        C.name AS receivedByCustodian,
        RR.dateReturned,
        RR.conditionAtReturn,
        RR.isLate
    FROM ReturnRecord AS RR
    INNER JOIN BorrowRequest AS BR
        ON RR.requestID = BR.requestID
    INNER JOIN [User] AS B
        ON BR.borrowerID = B.userID
    INNER JOIN [User] AS C
        ON RR.receivedBy = C.userID
    WHERE RR.returnID = 'RR98';


    -- G. JOIN
    -- Display damage reports with related return information.
    SELECT
        DR.reportID,
        DR.description,
        DR.severity,
        DR.actionTaken,
        DR.status,
        RR.returnID,
        RR.requestID,
        U.name AS borrowerName
    FROM DamageReports AS DR
    INNER JOIN ReturnRecord AS RR
        ON DR.returnID = RR.returnID
    INNER JOIN [User] AS U
        ON DR.borrowerID = U.userID
    WHERE DR.reportID = 'DR98';


    /* ======================================================
       PART 3: UPDATE
       Change existing records and verify the changes.
       ====================================================== */

    -- A. Update the availability of the demonstration monitor.
    UPDATE Equipment
    SET availabilityStatus = 'UNAVAILABLE'
    WHERE equipmentID = 'EQ96';


    -- B. Verify the equipment update.
    SELECT
        equipmentID,
        name,
        availabilityStatus
    FROM Equipment
    WHERE equipmentID = 'EQ96';


    -- C. Update the demonstration damage report.
    UPDATE DamageReports
    SET status = 'RESOLVED',
        actionTaken = 'Demonstration repair completed.'
    WHERE reportID = 'DR98';


    -- D. Verify the damage report update.
    SELECT
        reportID,
        description,
        severity,
        actionTaken,
        status
    FROM DamageReports
    WHERE reportID = 'DR98';


    /* ======================================================
       PART 4: DELETE
       Remove only the demonstration records.
       Delete child records before parent records to avoid
       violating foreign-key constraints.
       ====================================================== */

    -- A. Delete the damage report first.
    DELETE FROM DamageReports
    WHERE reportID = 'DR98';


    -- B. Delete the return record after its damage report.
    DELETE FROM ReturnRecord
    WHERE returnID = 'RR98';


    -- C. Delete the request-to-equipment links.
    DELETE FROM BorrowRequestItems
    WHERE requestID IN ('BR98', 'BRR99');


    -- D. Delete both demonstration borrowing requests.
    DELETE FROM BorrowRequest
    WHERE requestID IN ('BR98', 'BRR99');


    -- E. Delete the demonstration equipment.
    DELETE FROM Equipment
    WHERE equipmentID IN ('EQ96', 'EQ97', 'EQ98', 'EQ99');


    -- F. Delete the demonstration users last.
    DELETE FROM [User]
    WHERE userID IN ('BR98', 'CU98');


    -- G. VERIFY DELETE
    -- All six queries should return zero rows.
    SELECT * FROM [User]
    WHERE userID IN ('BR98', 'CU98');

    SELECT * FROM Equipment
    WHERE equipmentID IN ('EQ96', 'EQ97', 'EQ98', 'EQ99');

    SELECT * FROM BorrowRequest
    WHERE requestID IN ('BR98', 'BRR99');

    SELECT * FROM BorrowRequestItems
    WHERE requestID IN ('BR98', 'BRR99');

    SELECT * FROM ReturnRecord
    WHERE returnID = 'RR98';

    SELECT * FROM DamageReports
    WHERE reportID = 'DR98';



