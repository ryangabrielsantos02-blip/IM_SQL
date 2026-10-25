/*
========================================================
       SQL SERVER COMMAND REVIEWER / CHEAT SHEET
       Database: EquipmentBorrowingDB
========================================================

1. DATABASE COMMANDS
--------------------------------------------------------
USE EquipmentBorrowingDB;
    -- Select the database to work with.

GO
    -- Separates batches in SQL Server tools.

CREATE DATABASE DatabaseName;
    -- Creates a database.

2. TABLE COMMANDS
--------------------------------------------------------
CREATE TABLE Example (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
    -- Creates a table with two columns.

ALTER TABLE Equipment
ADD description VARCHAR(200);
    -- Adds a new column to an existing table.

DROP TABLE Example;
    -- Deletes a table and its data. USE WITH CAUTION!

3. CRUD OPERATIONS
--------------------------------------------------------

C = CREATE / INSERT (Add a record)
INSERT INTO Equipment
    (equipmentId, name, category)
VALUES
    ('EQ05', 'Keyboard', 'ACCESSORY');

R = READ / SELECT (View records)
SELECT * FROM Equipment;
    -- Displays all columns and rows.

SELECT equipmentId, name
FROM Equipment;
    -- Displays selected columns.

SELECT * FROM Equipment
WHERE equipmentId = 'EQ01';
    -- Finds a specific record.

U = UPDATE (Modify a record)
UPDATE Equipment
SET availabilityStatus = 'BORROWED'
WHERE equipmentId = 'EQ01';

D = DELETE (Remove a record)
DELETE FROM Equipment
WHERE equipmentId = 'EQ05';

4. FILTERING AND SORTING
--------------------------------------------------------
WHERE availabilityStatus = 'AVAILABLE';
    -- Filters rows by a condition.

AND
    -- Both conditions must be true.

OR
    -- At least one condition must be true.

NOT
    -- Reverses a condition.

ORDER BY name ASC;
    -- Sorts alphabetically, ascending.

ORDER BY name DESC;
    -- Sorts in descending order.

SELECT DISTINCT category FROM Equipment;
    -- Shows unique categories.

SELECT COUNT(*) AS TotalEquipment
FROM Equipment;
    -- Counts records.

5. NULL AND SEARCH
--------------------------------------------------------
WHERE dateReturned IS NULL;
    -- Finds missing return dates.

WHERE dateReturned IS NOT NULL;
    -- Finds records with return dates.

WHERE name LIKE '%Laptop%';
    -- Finds text containing "Laptop".

WHERE name LIKE 'Lap%';
    -- Finds text starting with "Lap".

6. SQL SYMBOLS
--------------------------------------------------------
[]       -- Delimits SQL Server names: [User]
()       -- Groups columns, values, or conditions
''       -- Encloses text: 'EQ01'
*        -- All columns: SELECT *
;        -- Ends a SQL statement
,        -- Separates columns or values
=        -- Equals / assigns a value
<>       -- Not equal to
>        -- Greater than
<        -- Less than
>=       -- Greater than or equal to
<=       -- Less than or equal to

*/
