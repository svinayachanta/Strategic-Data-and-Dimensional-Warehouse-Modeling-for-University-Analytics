-- Access Controls and Permissions


-- Create roles
CREATE ROLE test_role


-- Assign permissions to roles
GRANT CONTROL ON DATABASE :: EducationalInstitutionDatabase TO db_developer;
GRANT ALL PRIVILEGES ON DATABASE EducationalInstitutionDatabase TO test_role;
GRANT SELECT, INSERT, UPDATE ON Student TO test_role;
GRANT SELECT ON Course TO db_faculty;

--Create Login
CREATE LOGIN testuser WITH PASSWORD = 'Password@1'

-- Create Users
CREATE USER testuser FOR LOGIN testuser WITH DEFAULT_SCHEMA = dbo

-- Assign users to roles
EXEC sp_addrolemember 'test_role', 'testuser';










-- Enable Transparent Data Encryption (TDE) for the database
-- Transparent Data Encryption encrypts the entire database to protect data at rest.
USE EducationalInstitutionDatabase;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
GO

ALTER DATABASE EducationalInstitutionDatabase
SET ENCRYPTION ON;
GO


-- Implement Column-Level Encryption (Always Encrypted):
-- Create a Column Master Key and Column Encryption Key.
-- Encrypt sensitive columns using Always Encrypted.
-- Create Column Master Key
CREATE COLUMN MASTER KEY CMK_Auto1
WITH (
    KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
    KEY_PATH = N'CurrentUser/my/MyServerCert'
);

-- Create Column Encryption Key
CREATE COLUMN ENCRYPTION KEY CEK_Auto1
WITH VALUES (
    COLUMN MASTER KEY = CMK_Auto1,
    ALGORITHM = N'RSA_OAEP',
    ENCRYPTED_VALUE = 0x01000000...
);

-- Encrypt sensitive columns in Student table
CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', COLUMN_ENCRYPTION_KEY = CEK_Auto1) NOT NULL,
    LastName NVARCHAR(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', COLUMN_ENCRYPTION_KEY = CEK_Auto1) NOT NULL,
    DateOfBirth DATE,
    Gender CHAR(1),
    Nationality NVARCHAR(50),
    AddressLine1 NVARCHAR(100),
    AddressLine2 NVARCHAR(100),
    City NVARCHAR(50),
    State NVARCHAR(50),
    ZipCode NVARCHAR(10),
    Country NVARCHAR(50),
    PhoneNumber NVARCHAR(15),
    Email NVARCHAR(100) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', COLUMN_ENCRYPTION_KEY = CEK_Auto1) NOT NULL,
    EnrollmentDate DATE,
    GraduationDate DATE
);
