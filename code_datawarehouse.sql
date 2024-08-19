-- Create Date Dimension Table
CREATE TABLE DateDim (
    DateKey INT,
    Date DATE,
    Day INT,
    Month INT,
    Year INT,
    Quarter INT,
    MonthName NVARCHAR(20),
    QuarterName NVARCHAR(20),
    PRIMARY KEY (DateKey)
)

-- Populate Date Dimension Table
DECLARE @StartDate DATE = '2015-01-01';
DECLARE @EndDate DATE = '2025-12-31';

WITH DateRange AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateRange
    WHERE DateValue < @EndDate
)
INSERT INTO DateDim (DateKey, Date, Day, Month, Year, Quarter, MonthName, QuarterName)
SELECT
    CONVERT(INT, FORMAT(DateValue, 'yyyyMMdd')) AS DateKey,
    DateValue AS Date,
    DAY(DateValue) AS Day,
    MONTH(DateValue) AS Month,
    YEAR(DateValue) AS Year,
    DATEPART(QUARTER, DateValue) AS Quarter,
    DATENAME(MONTH, DateValue) AS MonthName,
    'Q' + CAST(DATEPART(QUARTER, DateValue) AS NVARCHAR) AS QuarterName
FROM DateRange
OPTION (MAXRECURSION 0);
GO


-- Create Student Dimension Table
CREATE TABLE StudentDim (
    StudentID INT,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    Nationality NVARCHAR(50),
    AddressLine1 NVARCHAR(100) NOT NULL,
    AddressLine2 NVARCHAR(100),
    City NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    ZipCode NVARCHAR(10) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15),
    Email NVARCHAR(100) UNIQUE NOT NULL,
    EnrollmentDate DATE NOT NULL,
    GraduationDate DATE,
    PRIMARY KEY (StudentID) 
)
-- Indexes for Student Dimension
CREATE NONCLUSTERED INDEX IX_Email ON StudentDim (Email);
CREATE NONCLUSTERED INDEX IX_EnrollmentDate ON StudentDim (EnrollmentDate);
CREATE NONCLUSTERED INDEX IX_Country ON StudentDim (Country);
CREATE NONCLUSTERED INDEX IX_State ON StudentDim (State);



-- Create Faculty Dimension Table
CREATE TABLE FacultyDim (
    FacultyID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    PhoneNumber NVARCHAR(15),
    Email NVARCHAR(100) UNIQUE NOT NULL,
    HireDate DATE NOT NULL
)
-- Indexes for Faculty Dimension
CREATE NONCLUSTERED INDEX IX_Email ON FacultyDim (Email);
CREATE NONCLUSTERED INDEX IX_DepartmentID ON FacultyDim (DepartmentID);
CREATE NONCLUSTERED INDEX IX_HireDate ON FacultyDim (HireDate);



-- Create Department Dimension Table
CREATE TABLE DepartmentDim (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    FacultyCount INT CHECK (FacultyCount >= 0)
);
-- Indexes for Department Dimension
CREATE NONCLUSTERED INDEX IX_DepartmentName ON DepartmentDim (DepartmentName);



-- Create Campus Dimension Table
CREATE TABLE CampusDim (
    CampusID INT PRIMARY KEY,
    CampusName NVARCHAR(100) NOT NULL,
    CampusLocation NVARCHAR(100) NOT NULL
);
-- Indexes for Campus Dimension
CREATE NONCLUSTERED INDEX IX_CampusName ON CampusDim (CampusName);
CREATE NONCLUSTERED INDEX IX_CampusLocation ON CampusDim (CampusLocation);



-- Create Course Dimension Table
CREATE TABLE CourseDim (
    CourseID INT PRIMARY KEY,
    CourseName NVARCHAR(100) NOT NULL,
    CourseCode NVARCHAR(10) UNIQUE NOT NULL,
    Credits INT NOT NULL CHECK (Credits > 0),
    DepartmentID INT NOT NULL,
    CampusID INT NOT NULL,
    Semester NVARCHAR(10) NOT NULL,
    Year INT NOT NULL CHECK (Year > 2000)
);
-- Indexes for Course Dimension
CREATE NONCLUSTERED INDEX IX_CourseCode ON CourseDim (CourseCode);
CREATE NONCLUSTERED INDEX IX_DepartmentID ON CourseDim (DepartmentID);
CREATE NONCLUSTERED INDEX IX_CampusID ON CourseDim (CampusID);
CREATE NONCLUSTERED INDEX IX_Semester_Year ON CourseDim (Semester, Year);



-- Create Scholarship Dimension Table
CREATE TABLE ScholarshipDim (
    ScholarshipID INT PRIMARY KEY,
    ScholarshipName NVARCHAR(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    EligibilityCriteria TEXT
);
-- Indexes for Scholarship Dimension
CREATE NONCLUSTERED INDEX IX_ScholarshipName ON ScholarshipDim (ScholarshipName);



-- Create Program Dimension Table
CREATE TABLE ProgramDim (
    ProgramID INT PRIMARY KEY,
    ProgramName NVARCHAR(100) NOT NULL,
    EducationLevel NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    CampusID INT NOT NULL,
    DurationYears INT NOT NULL CHECK (DurationYears > 0)
);
-- Indexes for Program Dimension
CREATE NONCLUSTERED INDEX IX_ProgramName ON ProgramDim (ProgramName);
CREATE NONCLUSTERED INDEX IX_DepartmentID ON ProgramDim (DepartmentID);
CREATE NONCLUSTERED INDEX IX_CampusID ON ProgramDim (CampusID);
CREATE NONCLUSTERED INDEX IX_EducationLevel ON ProgramDim (EducationLevel);



-- Create Admission Dimension Table
CREATE TABLE AdmissionDim (
    AdmissionID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    ProgramID INT NOT NULL,
    AdmissionDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Accepted', 'Rejected')),
    DecisionDate DATE
)
-- Indexes for Admission Dimension
CREATE NONCLUSTERED INDEX IX_StudentID ON AdmissionDim (StudentID);
CREATE NONCLUSTERED INDEX IX_ProgramID ON AdmissionDim (ProgramID);
CREATE NONCLUSTERED INDEX IX_AdmissionDate ON AdmissionDim (AdmissionDate);
CREATE NONCLUSTERED INDEX IX_Status ON AdmissionDim (Status);
CREATE NONCLUSTERED INDEX IX_DecisionDate ON AdmissionDim (DecisionDate);


-- Create Enrollment Fact Table
CREATE TABLE EnrollmentFact (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    EnrollmentDateKey INT,
    Status NVARCHAR(20),
    FOREIGN KEY (StudentID) REFERENCES StudentDim(StudentID),
    FOREIGN KEY (CourseID) REFERENCES CourseDim(CourseID),
    FOREIGN KEY (EnrollmentDateKey) REFERENCES DateDim(DateKey),
)

-- Create Non-Clustered Index on StudentID
CREATE NONCLUSTERED INDEX idx_EnrollmentFact_StudentID
ON EnrollmentFact (StudentID);

-- Create Non-Clustered Index on CourseID
CREATE NONCLUSTERED INDEX idx_EnrollmentFact_CourseID
ON EnrollmentFact (CourseID);

-- Create Non-Clustered Index on EnrollmentDateKey
CREATE NONCLUSTERED INDEX idx_EnrollmentFact_EnrollmentDateKey
ON EnrollmentFact (EnrollmentDateKey);

-- Create Composite Non-Clustered Index on StudentID, CourseID, and EnrollmentDateKey
CREATE NONCLUSTERED INDEX idx_EnrollmentFact_StudentID_CourseID_EnrollmentDateKey
ON EnrollmentFact (StudentID, CourseID, EnrollmentDateKey);




-- Create Grade Fact Table
CREATE TABLE GradeFact (
    GradeID INT,
    EnrollmentID INT,
    Grade CHAR(2),
    GradeDateKey INT,
    FOREIGN KEY (EnrollmentID) REFERENCES EnrollmentFact(EnrollmentID),
    FOREIGN KEY (GradeDateKey) REFERENCES DateDim(DateKey),
	PRIMARY KEY (GradeID, GradeDateKey)
)
-- Create Non-Clustered Index on EnrollmentID
CREATE NONCLUSTERED INDEX idx_GradeFact_EnrollmentID
ON GradeFact (EnrollmentID);

-- Create Non-Clustered Index on GradeDateKey
CREATE NONCLUSTERED INDEX idx_GradeFact_GradeDateKey
ON GradeFact (GradeDateKey);

-- Create Composite Non-Clustered Index on EnrollmentID and GradeDateKey
CREATE NONCLUSTERED INDEX idx_GradeFact_EnrollmentID_GradeDateKey
ON GradeFact (EnrollmentID, GradeDateKey);



-- Create Fee Fact Table
CREATE TABLE FeeFact (
    FeeID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    FeeAmount DECIMAL(10, 2),
    FeeDateKey INT,
    FOREIGN KEY (StudentID) REFERENCES StudentDim(StudentID),
    FOREIGN KEY (CourseID) REFERENCES CourseDim(CourseID),
    FOREIGN KEY (FeeDateKey) REFERENCES DateDim(DateKey)
)
-- Create Non-Clustered Index on StudentID
CREATE NONCLUSTERED INDEX idx_FeeFact_StudentID
ON FeeFact (StudentID);

-- Create Non-Clustered Index on CourseID
CREATE NONCLUSTERED INDEX idx_FeeFact_CourseID
ON FeeFact (CourseID);

-- Create Non-Clustered Index on FeeDateKey
CREATE NONCLUSTERED INDEX idx_FeeFact_FeeDateKey
ON FeeFact (FeeDateKey);

-- Create Composite Non-Clustered Index on StudentID, CourseID, and FeeDateKey
CREATE NONCLUSTERED INDEX idx_FeeFact_StudentID_CourseID_FeeDateKey
ON FeeFact (StudentID, CourseID, FeeDateKey);



-- Create Admission Fact Table
CREATE TABLE AdmissionFact (
    AdmissionID INT PRIMARY KEY,
    StudentID INT,
    ProgramID INT,
    AdmissionDateKey INT,
    Status NVARCHAR(20),
    DecisionDateKey INT,
    FOREIGN KEY (StudentID) REFERENCES StudentDim(StudentID),
    FOREIGN KEY (ProgramID) REFERENCES ProgramDim(ProgramID),
    FOREIGN KEY (AdmissionDateKey) REFERENCES DateDim(DateKey),
    FOREIGN KEY (DecisionDateKey) REFERENCES DateDim(DateKey)
)
-- Create Non-Clustered Index on StudentID
CREATE NONCLUSTERED INDEX idx_AdmissionFact_StudentID
ON AdmissionFact (StudentID);

-- Create Non-Clustered Index on ProgramID
CREATE NONCLUSTERED INDEX idx_AdmissionFact_ProgramID
ON AdmissionFact (ProgramID);

-- Create Non-Clustered Index on AdmissionDateKey
CREATE NONCLUSTERED INDEX idx_AdmissionFact_AdmissionDateKey
ON AdmissionFact (AdmissionDateKey);

-- Create Non-Clustered Index on DecisionDateKey
CREATE NONCLUSTERED INDEX idx_AdmissionFact_DecisionDateKey
ON AdmissionFact (DecisionDateKey);

-- Create Composite Non-Clustered Index on StudentID, ProgramID, and AdmissionDateKey
CREATE NONCLUSTERED INDEX idx_AdmissionFact_StudentID_ProgramID_AdmissionDateKey
ON AdmissionFact (StudentID, ProgramID, AdmissionDateKey);



-- Create Scholarship Award Fact Table
CREATE TABLE ScholarshipAwardFact (
    ScholarshipAwardID INT PRIMARY KEY,
    StudentID INT,
    ScholarshipID INT,
    AwardDateKey INT,
    Amount DECIMAL(10, 2),
    FOREIGN KEY (StudentID) REFERENCES StudentDim(StudentID),
    FOREIGN KEY (ScholarshipID) REFERENCES ScholarshipDim(ScholarshipID),
    FOREIGN KEY (AwardDateKey) REFERENCES DateDim(DateKey)
)
-- Create Non-Clustered Index on StudentID
CREATE NONCLUSTERED INDEX idx_ScholarshipAwardFact_StudentID
ON ScholarshipAwardFact (StudentID);

-- Create Non-Clustered Index on ScholarshipID
CREATE NONCLUSTERED INDEX idx_ScholarshipAwardFact_ScholarshipID
ON ScholarshipAwardFact (ScholarshipID);

-- Create Non-Clustered Index on AwardDateKey
CREATE NONCLUSTERED INDEX idx_ScholarshipAwardFact_AwardDateKey
ON ScholarshipAwardFact (AwardDateKey);

-- Create Composite Non-Clustered Index on StudentID, ScholarshipID, and AwardDateKey
CREATE NONCLUSTERED INDEX idx_ScholarshipAwardFact_StudentID_ScholarshipID_AwardDateKey
ON ScholarshipAwardFact (StudentID, ScholarshipID, AwardDateKey);
