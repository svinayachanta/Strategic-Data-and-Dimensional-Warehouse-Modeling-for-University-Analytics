-- Student Table
CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
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
    GraduationDate DATE
);
-- Indexes
CREATE INDEX IX_Student_Email ON Student (Email);
CREATE INDEX IX_Student_Name ON Student (FirstName, LastName);



-- Scholarship Table
CREATE TABLE Scholarship (
    ScholarshipID INT PRIMARY KEY IDENTITY(1,1),
    ScholarshipName NVARCHAR(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    EligibilityCriteria TEXT
);
-- Indexes
CREATE INDEX IX_Scholarship_Name ON Scholarship (ScholarshipName);



-- StudentScholarship Table
CREATE TABLE StudentScholarship (
    StudentID INT NOT NULL,
    ScholarshipID INT NOT NULL,
    AwardDate DATE NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (ScholarshipID) REFERENCES Scholarship(ScholarshipID),
    PRIMARY KEY (StudentID, ScholarshipID)
);
-- Indexes
CREATE INDEX IX_StudentScholarship_StudentID ON StudentScholarship (StudentID);
CREATE INDEX IX_StudentScholarship_ScholarshipID ON StudentScholarship (ScholarshipID);



-- Department Table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    FacultyCount INT CHECK (FacultyCount >= 0)
);
-- Indexes
CREATE INDEX IX_Department_Name ON Department (DepartmentName);



-- Faculty Table
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    PhoneNumber NVARCHAR(15),
    Email NVARCHAR(100) UNIQUE NOT NULL,
    HireDate DATE NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
-- Indexes
CREATE INDEX IX_Faculty_Name ON Faculty (FirstName, LastName);
CREATE INDEX IX_Faculty_DepartmentID ON Faculty (DepartmentID);



-- Campus Table
CREATE TABLE Campus (
    CampusID INT PRIMARY KEY IDENTITY(1,1),
    CampusName NVARCHAR(100) NOT NULL,
    CampusLocation NVARCHAR(100) NOT NULL
);
-- Indexes
CREATE INDEX IX_Campus_Name ON Campus (CampusName);



-- Course Table
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(100) NOT NULL,
    CourseCode NVARCHAR(10) UNIQUE NOT NULL,
    Credits INT NOT NULL CHECK (Credits > 0),
    DepartmentID INT NOT NULL,
    CampusID INT NOT NULL,
    Semester NVARCHAR(10) NOT NULL,
    Year INT NOT NULL CHECK (Year > 2000),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (CampusID) REFERENCES Campus(CampusID)
);
-- Indexes
CREATE INDEX IX_Course_Code ON Course (CourseCode);
CREATE INDEX IX_Course_Name ON Course (CourseName);
CREATE INDEX IX_Course_DepartmentID ON Course (DepartmentID);



-- Enrollment Table
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Enrolled', 'Completed', 'Withdrawn')),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
-- Indexes
CREATE INDEX IX_Enrollment_StudentID ON Enrollment (StudentID);
CREATE INDEX IX_Enrollment_CourseID ON Enrollment (CourseID);



-- Grade Table
CREATE TABLE Grade (
    GradeID INT PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT NOT NULL,
    Grade CHAR(2) NOT NULL CHECK (Grade IN ('A', 'B', 'C', 'D', 'F')),
    GradeDate DATE NOT NULL,
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollment(EnrollmentID)
);
-- Indexes
CREATE INDEX IX_Grade_EnrollmentID ON Grade (EnrollmentID);
CREATE INDEX IX_Grade_Grade ON Grade (Grade);



-- Program Table
CREATE TABLE Program (
    ProgramID INT PRIMARY KEY IDENTITY(1,1),
    ProgramName NVARCHAR(100) NOT NULL,
    EducationLevel NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    CampusID INT NOT NULL,
    DurationYears INT NOT NULL CHECK (DurationYears > 0),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (CampusID) REFERENCES Campus(CampusID)
);
-- Indexes
CREATE INDEX IX_Program_Name ON Program (ProgramName);



-- Admission Table
CREATE TABLE Admission (
    AdmissionID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ProgramID INT NOT NULL,
    AdmissionDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Accepted', 'Rejected')),
    DecisionDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);
-- Indexes
CREATE INDEX IX_Admission_StudentID ON Admission (StudentID);
CREATE INDEX IX_Admission_ProgramID ON Admission (ProgramID);


-- Fee Table
CREATE TABLE Fee (
    FeeID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    FeeDate DATE NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
-- Indexes
CREATE INDEX IX_Fee_StudentID ON Fee (StudentID);
CREATE INDEX IX_Fee_CourseID ON Fee (CourseID);
CREATE INDEX IX_Fee_FeeDate ON Fee (FeeDate);
