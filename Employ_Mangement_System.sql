create database emp_management;
use emp_management;

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
select*from JobDepartment;
select*from salarybonus;
select*from employee;
select*from Qualification;
select*from leaves;
select *from payroll;


# 1-Employee Insights

#How many unique employees are currently in the system?
SELECT 
    COUNT(DISTINCT emp_id) AS unique_employees
FROM
    employee;

# Which departments have the highest number of employees?
SELECT 
    d.jobdept, COUNT(e.emp_id) AS max_employees
FROM
    employee e
        JOIN
    JobDepartment d ON d.job_id = e.job_id
GROUP BY d.jobdept
ORDER BY max_employees DESC
LIMIT 1;

# What is the average salary per department?
SELECT 
    *
FROM
    (SELECT 
        d.jobdept, AVG(s.amount) AS avg_salary
    FROM
        JobDepartment d
    JOIN salarybonus s ON d.job_id = s.job_id
    GROUP BY d.jobdept) d;

#●	Who are the top 5 highest-paid employees? 
 with top_5 as( SELECT 
    e.emp_id, e.firstname, s.amount
FROM
    employee e
        JOIN
    salarybonus s ON e.job_id = s.job_id
ORDER BY s.amount DESC
LIMIT 5)select *from top_5;
 
 #What is the total salary expenditure across the company
 SELECT 
    SUM(amount) total_salary
FROM
    employee e
        JOIN
    salarybonus s ON e.job_id = s.job_id;
 
 
 # 2-JOB ROLE AND DEPARTMENT ANALYSIS
 
 
 # How many different job roles exist in each department? 
 
 SELECT 
    j.jobdept, COUNT(j.job_id) count_job
FROM
    jobdepartment j
        JOIN
    employee e ON j.job_id = e.job_id
GROUP BY j.jobdept;
 
#What is the average salary range per department?
select * from jobdepartment;
select * from (SELECT 
    jobdept,
    AVG((CAST(REPLACE(SUBSTRING_INDEX(salaryrange, '-', 1),
            '$',
            '')
        AS UNSIGNED) + CAST(REPLACE(SUBSTRING_INDEX(salaryrange, '-', - 1),
            '$',
            '')
        AS UNSIGNED)) / 2) AS avg_salary_range
FROM
    jobdepartment
GROUP BY jobdept)d;

# Which job roles offer the highest salary?
SELECT 
    jobdept,
    (CAST(REPLACE(SUBSTRING_INDEX(salaryrange, '-', - 1),
            '$',
            '')
        AS UNSIGNED)) AS high_salary_range
FROM
    jobdepartment
ORDER BY high_salary_range DESC
LIMIT 2;


# Which departments have the highest total salary allocation? 
 with high_salary as (SELECT 
    j.jobdept, SUM(s.amount) AS high_salary
FROM
    jobdepartment j
        JOIN
    salarybonus s ON j.job_id = s.job_id
GROUP BY j.jobdept
ORDER BY high_salary DESC
LIMIT 1)select*from high_salary;

# 3-QUALIFICATION AND SKILLS ANALYSIS


# How many employees have at least one qualification listed? 
select * from Qualification;
with emp_count as (SELECT 
    emp_id,position,COUNT(DISTINCT Emp_ID) AS  Employee_Count from qualification
    group by emp_id,position
    having Employee_Count>=1)
    select count(*) as employ_count from emp_count;


#Which positions require the most qualifications? 
select *from (SELECT 
    q.position, COUNT(q.position) most_qualification
FROM
    qualification q
        JOIN
    employee e ON e.emp_id = q.emp_id
GROUP BY position)d;


#Which employees have the highest number of qualifications? 
with high_qual as (SELECT 
    e.emp_id,
    e.firstname,
    COUNT(q.requirements) max_qualification
FROM
    qualification q
        JOIN
    employee e ON e.emp_id = q.emp_id
GROUP BY e.emp_id , e.firstname
ORDER BY max_qualification DESC)select *from high_qual;


#-4LEAVE AND ABSENCE PATTERNS 

#Which year had the most employees taking leaves? 

SELECT 
   emp_id, count(YEAR(date)),year(date) as most_employ from leaves
    group by emp_id,year(date);


#What is the average number of leave days taken by its employees per department?
SELECT 
    e.emp_id,e.firstname,j.jobdept, AVG(DAY(l.date)) avg_days
FROM
jobdepartment j
join employee e
    ON j.job_id = e.job_id
    join
    leaves l
      on l.emp_id = e.emp_id
   
GROUP BY e.emp_id,e.firstname,j.jobdept;
#Which employees have taken the most leaves? 

select * from (SELECT 
    e.emp_id, e.firstname, COUNT(DAY(l.date)) most_leaves
FROM
    leaves l
        JOIN
    employee e ON l.emp_id = e.emp_id
GROUP BY e.emp_id)d;



#What is the total number of leave days taken company-wide?
select count(day(date)) as total_days from leaves;

#How do leave days correlate with payroll amounts?
SELECT 
    l.leave_ID,
    l.emp_ID,
    l.date AS leave_date,
    l.reason,
    p.payroll_ID,
    p.total_amount
FROM
    Leaves l
        LEFT JOIN
    Payroll p ON l.leave_ID = p.leave_ID
ORDER BY l.emp_ID , l.date;


#PAYROLL AND COMPENSATION ANALYSIS
select *from payroll;
 #What is the total monthly payroll processed? 
 SELECT 
    MONTH(date), SUM(total_amount) total_month_payroll
FROM
    payroll
GROUP BY MONTH(date);


#What is the average bonus given per department? 
select *from (SELECT 
    j.jobdept, AVG(s.bonus) avg_bonus
FROM
    jobdepartment j
        JOIN
    salarybonus s ON j.job_id = s.job_id
GROUP BY j.jobdept)d;


#Which department receives the highest total bonuses? 
with high_bonus as (SELECT 
    j.jobdept, SUM(s.bonus) avg_bonus
FROM
    jobdepartment j
        JOIN
    salarybonus s ON j.job_id = s.job_id
GROUP BY j.jobdept
ORDER BY avg_bonus DESC
LIMIT 1)select *from high_bonus;

#What is the average value of total_amount after considering leave deductions?
SELECT 
    AVG(total_amount_dt)
FROM
    (SELECT 
        l.leave_id,
            s.salary_id,
            (p.total_amount - (s.amount / 30) * DAY(l.date)) total_amount_dt
    FROM
        salarybonus s
    JOIN payroll p ON s.job_id = p.job_id
    JOIN leaves l ON l.leave_id = p.leave_id) d;
    





