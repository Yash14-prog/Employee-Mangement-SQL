create database EmployeeManagement;

use EmployeeManagement;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT * from JobDepartment;
SELECT * from SalaryBonus;
SELECT * from Employee;
SELECT * from Qualification;
SELECT * from Leaves;
SELECT * from Payroll;

-- 1. EMPLOYEE INSIGHTS

-- 1(a)How many unique employees are currently in the system?

SELECT 
    COUNT(DISTINCT emp_ID) AS unique_employees
FROM
    Employee;

-- 1(b)Which departments have the highest number of employees?

SELECT 
    jobdept, COUNT(e.emp_ID) AS employee_count
FROM
    JobDepartment AS jd
        INNER JOIN
    Employee AS e ON jd.Job_ID = e.Job_ID
GROUP BY jobdept
ORDER BY employee_count DESC
limit 2; 

-- 1(c)What is the average salary per department?

SELECT 
    jd.jobdept, round(AVG(sb.amount),2) AS avg_salary
FROM
    JobDepartment AS jd
        INNER JOIN
    SalaryBonus AS sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
order by avg_salary DESC;

-- 1(d)Who are the top 5 highest-paid employees?

SELECT 
    e.emp_ID, e.firstname, e.lastname, sb.amount AS salary
FROM
    Employee AS e
        INNER JOIN
    SalaryBonus AS sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- 1(e)What is the total salary expenditure across the company?
    
SELECT SUM(annual+bonus) AS total_salary_expenditure
FROM SalaryBonus ;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- 2(a)How many different job roles exist in each department?

SELECT 
    jobdept AS Department, COUNT(DISTINCT name) AS Job_Roles
FROM
    JobDepartment
GROUP BY jobdept;

-- 2(b)What is the average salary range per department?

SELECT 
    jd.jobdept AS Department, round(AVG(sb.amount),2)AS avg_salary,
    min(sb.amount) as min_salary,
    max(sb.amount) as max_salary
FROM
    JobDepartment jd
        JOIN
    SalaryBonus AS sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- 2(c)Which job roles offer the highest salary?

SELECT 
    jd.name AS job_role, jd.jobdept, sb.amount AS highest_salary
FROM
    JobDepartment jd
        JOIN
    SalaryBonus AS sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 2;

-- 2(d)Which departments have the highest total salary allocation?

SELECT 
    jd.jobdept, SUM(sb.amount) AS total_salary_allocation
FROM
    JobDepartment jd
        JOIN
    SalaryBonus AS sb ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary_allocation DESC
limit 2;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- 3(a)How many employees have at least one qualification listed?

SELECT 
    COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM
    Qualification ;
    
-- 3(b)Which positions require the most qualifications?

SELECT 
    Position, COUNT(Requirements) AS qualification
FROM
    Qualification 
GROUP BY Position
ORDER BY qualification DESC;

-- 3(c)Which employees have the highest number of qualifications?

SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(q.QualID) AS qualification_count
FROM
    Employee e
        JOIN
    Qualification AS q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID , e.firstname , e.lastname
ORDER BY qualification_count DESC;

-- 4. LEAVE AND ABSENCE PATTERNS

-- 4(a)Which year had the most employees taking leaves?

SELECT 
    YEAR(date) AS leave_year,
    COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM Leaves 
GROUP BY YEAR(date)
ORDER BY employees_on_leave DESC;

-- 4(b)What is the average number of leave days taken by its employees per department?

SELECT jd.jobdept AS department,
       round(COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID)) AS avg_leave_days
FROM Employee AS e
JOIN JobDepartment AS jd ON e.Job_ID = jd.Job_ID
JOIN Leaves AS  l ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;

-- 4(c)Which employees have taken the most leaves?

SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    COUNT(l.leave_ID) AS total_leaves
FROM
    Employee AS e
        JOIN
    Leaves AS l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID , e.firstname , e.lastname
ORDER BY total_leaves DESC;

-- 4(d)What is the total number of leave days taken company-wide?

SELECT 
    COUNT(leave_id) AS total_leave_days
FROM
    Leaves;

-- 4(e)How do leave days correlate with payroll amounts?

SELECT 
    p.LEAVE_ID,
    COUNT(l.DATE) AS leave_days,
    SUM(P.TOTAL_AMOUNT) AS TOTAL_payroll
FROM
    Payroll AS p
        INNER JOIN
    Leaves as l ON p.leave_ID = l.leave_ID
GROUP BY p.LEAVE_ID;


-- 5. PAYROLL AND COMPENSATION ANALYSIS

-- 5(a)What is the total monthly payroll processed?

SELECT DATE_FORMAT(date, '%Y-%m') AS month,
       SUM(total_amount) AS monthly_payroll
FROM Payroll
GROUP BY month;

-- 5(b)What is the average bonus given per department?

SELECT 
    jd.jobdept, round(AVG(sb.bonus),2) AS avg_bonus
FROM
    JobDepartment jd
        JOIN
    SalaryBonus AS sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY avg_bonus DESC;

-- 5(c)Which department receives the highest total bonuses?

SELECT 
    jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM
    JobDepartment jd
        JOIN
    SalaryBonus AS sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC
LIMIT 1;

-- 5(d)What is the average value of total_amount after considering leave deductions?

SELECT 
    round(AVG(total_amount),2)
    AS avg_payroll_after_deductions
FROM
    Payroll ; 
    