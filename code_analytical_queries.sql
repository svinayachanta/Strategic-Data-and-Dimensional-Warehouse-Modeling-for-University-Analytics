--Student Performance Analysis
SELECT 
    c.CourseName,
    c.CourseCode,
    AVG(CASE 
        WHEN g.Grade = 'A' THEN 4.0
        WHEN g.Grade = 'B' THEN 3.0
        WHEN g.Grade = 'C' THEN 2.0
        WHEN g.Grade = 'D' THEN 1.0
        ELSE 0.0
    END) AS AvgGrade
FROM 
    GradeFact gf
JOIN 
    CourseDim c ON gf.CourseID = c.CourseID
JOIN 
    DateDim d ON gf.GradeDateKey = d.DateKey
WHERE 
    d.Semester = 'Fall' AND d.Year = 2023
GROUP BY 
    c.CourseName, c.CourseCode
ORDER BY 
    AvgGrade DESC;

--Scholarship Distribution
SELECT 
    d.DepartmentName,
    SUM(saf.Amount) AS TotalScholarshipAmount
FROM 
    ScholarshipAwardFact saf
JOIN 
    StudentDim sd ON saf.StudentID = sd.StudentID
JOIN 
    DepartmentDim d ON sd.DepartmentID = d.DepartmentID
GROUP BY 
    d.DepartmentName
ORDER BY 
    TotalScholarshipAmount DESC;


--Enrollment Trends
SELECT 
    p.ProgramName,
    COUNT(e.StudentID) AS NumberOfEnrollments
FROM 
    EnrollmentFact e
JOIN 
    ProgramDim p ON e.ProgramID = p.ProgramID
JOIN 
    DateDim d ON e.EnrollmentDateKey = d.DateKey
WHERE 
    d.Year >= YEAR(GETDATE()) - 3
GROUP BY 
    p.ProgramName
ORDER BY 
    NumberOfEnrollments DESC;


--Faculty Workload
SELECT 
    f.FirstName + ' ' + f.LastName AS FacultyName,
    d.DepartmentName,
    COUNT(c.CourseID) AS NumberOfCourses
FROM 
    FacultyDim f
JOIN 
    CourseDim c ON f.FacultyID = c.FacultyID
JOIN 
    DepartmentDim d ON f.DepartmentID = d.DepartmentID
GROUP BY 
    f.FirstName, f.LastName, d.DepartmentName
ORDER BY 
    NumberOfCourses DESC;

--Fee Collection Analysis
SELECT 
    c.CourseName,
    d.Semester,
    d.Year,
    SUM(ff.FeeAmount) AS TotalFeeCollected
FROM 
    FeeFact ff
JOIN 
    CourseDim c ON ff.CourseID = c.CourseID
JOIN 
    DateDim d ON ff.FeeDateKey = d.DateKey
GROUP BY 
    c.CourseName, d.Semester, d.Year
ORDER BY 
    TotalFeeCollected DESC;


--Admission Status
SELECT 
    p.ProgramName,
    a.Status,
    COUNT(a.StudentID) AS Count
FROM 
    AdmissionFact a
JOIN 
    ProgramDim p ON a.ProgramID = p.ProgramID
GROUP BY 
    p.ProgramName, a.Status
ORDER BY 
    p.ProgramName, a.Status;


--Student Graduation Trends
SELECT 
    YEAR(sd.GraduationDate) AS GraduationYear,
    COUNT(sd.StudentID) AS NumberOfGraduates
FROM 
    StudentDim sd
WHERE 
    sd.GraduationDate IS NOT NULL
GROUP BY 
    YEAR(sd.GraduationDate)
ORDER BY 
    GraduationYear DESC;


--Course Enrollment
SELECT 
    c.CourseName,
    COUNT(e.StudentID) AS EnrollmentCount
FROM 
    EnrollmentFact e
JOIN 
    CourseDim c ON e.CourseID = c.CourseID
GROUP BY 
    c.CourseName
ORDER BY 
    EnrollmentCount DESC;
