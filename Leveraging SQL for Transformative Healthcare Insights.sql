-- Create database

create database Healthcare_Database;

-- Create Tables

CREATE TABLE Hospital_Records (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    bmi INT,
    family_history_of_hypertension TINYINT(1),
    department_name VARCHAR(100) NOT NULL,
    days_in_the_hospital INT
);

CREATE TABLE Appointment (
    visit_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    patient_name VARCHAR(100) NOT NULL,
    appointment_date DATE NOT NULL,
    arrival_time TIME NOT NULL,
    appointment_time TIME NOT NULL,
    admission_time TIME NOT NULL
);

CREATE TABLE Lab_Results (
    result_id INT PRIMARY KEY,
    visit_id INT NOT NULL,
    test_name VARCHAR(100) NOT NULL,
    test_date DATE NOT NULL,
    result_value FLOAT NOT NULL
);

CREATE TABLE Outpatient_Visits (
    visit_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    visit_date DATE NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    reason_for_visit VARCHAR(255) NOT NULL,
    diagnosis VARCHAR(255),
    medication_prescribed VARCHAR(255),
    smoker_status CHAR(1) NOT NULL
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    address VARCHAR(255) NOT NULL
);


-- Find all the patient's record in the appointments table

select*
from healthcare_database.appointment;

-- Find the patient ID of patients who had an appointmetn in the pediatrics department

select patient_id, department_name
from healthcare_database.appointment
where department_name = 'Pediatrics';

-- Find out how many days on average the patients spent in the Cardiology department of the hospital

select avg(days_in_the_hospital) as averge_days_cardiology
From healthcare_database.hospital_records
where department_name = 'Cardiology';

-- Compare the average number of days patients are spending in each depaartment of the hospital

select department_name, avg(days_in_the_hospital) as avg_days_per_department
from healthcare_database.hospital_records
group by department_name
order by avg_days_per_department desc;

-- Categorize patients based on their length of the stay in hospital

select patient_id, days_in_the_hospital,
case
when days_in_the_hospital <=3 then 'Short'
when days_in_the_hospital <=5 then 'Medium'
else 'Long'
end as stay_category
from healthcare_database.hospital_records;

-- Count the number iof patients in each category created

select
case
when days_in_the_hospital <=3 then 'Short'
when days_in_the_hospital <=5 then 'Medium'
else 'Long'
end as stay_category,
count(*) as number_of_records
from healthcare_database.hospital_records
group by 
case
when days_in_the_hospital <=3 then 'Short'
when days_in_the_hospital <=5 then 'Medium'
else 'Long'
end;

-- Getting the current date and time
Select now() as today;

-- Extract the day of week from the "appointment_date" column in integer

SELECT 
    appointment_date,
    DAYOFWEEK(appointment_date) AS day_of_the_week
FROM 
    healthcare_database.appointment;
    
-- Extract the hour from the "appointment_time" column
select
    appointment_date,
hour(appointment_time) as appointment_hours
FROM 
    healthcare_database.appointment;

-- Extracr the day of week from "appointemnt_timr column in character strings

SELECT 
    appointment_time,
    DAYNAME(appointment_time) AS day_of_the_week
FROM 
    healthcare_database.appointment;
    
-- Add five days to date

SELECT ADDDATE('2024-10-01', INTERVAL 5 DAY) AS new_date;

-- Subtract two month from date

SELECT 
    DATE_SUB('2024-10-01', INTERVAL 2 MONTH) AS new_date;

-- Retrieve the amount of datebetween JAn 1st 2024 to Jan 10th 2024

SELECT 
    DATEDIFF('2024-01-10', '2024-01-01') AS date_difference;

-- Retrive the number of months between Jan 1st 2023 and May 10th 2024

SELECT 
    PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM '2024-05-10'), EXTRACT(YEAR_MONTH FROM '2023-01-01')) AS months_between;

-- Calculate the difference between the arival time and appointment time in hours

SELECT 
    arrival_time,
    appointment_time,
    TIMESTAMPDIFF(MINUTE, appointment_time, arrival_time) AS time_difference
FROM 
    healthcare_database.appointment;
    
-- Which patients on 'patient' table were hospitalized and for how many days.

select p.patient_id, Days_in_the_hospital
from healthcare_database.patients as p
 inner join  healthcare_database.hospital_records as hr
 on p.patient_id = hr.patient_id;

-- Verify who has a hospital records

select p.patient_id, Days_in_the_hospital
from healthcare_database.patients as p
 left join  healthcare_database.hospital_records as hr
 on p.patient_id = hr.patient_id
 where Days_in_the_hospital is null;

-- Flag patients who are at the risk due to interaction between their medication and smoke status

select patient_id, diagnosis, medication_prescribed, smoker_status,
case
when smoker_status = 'Y' and medication_prescribed in ('Insulin', 'Metformin', 'Lisinopril')
then 'Potential Safety Concern: Smoking and Medication Interactions'
else  'No Safety Concern'
End as 'Safety_Concern'
from healthcare_database.outpatient_visits;

-- Classify patients into high, medium or low risk based on their BMI and family risk of hypertension

select patient_id, patient_name, bmi, family_history_of_hypertension,
case
when bmi >= 30 and family_history_of_hypertension = 'Y' then 'High Risk'
when bmi >= 25 and family_history_of_hypertension = 'Y' then 'Medium Risk'
else 'Low Risk'
end risk_category
from healthcare_database.hospital_records;

/*create a series of case statements to predict the likehood of hypertension developemnt based on patient's age,
BMI and family history of hypertension

Exclude childern from this model*/

select
p.patient_id,
p.patient_name,
Case
When family_history_of_hypertension = 'Yes' then 1
When family_history_of_hypertension = 'No' then 0
end as family_history_of_hypertension,
Case
When BMI < 18.5 then 'underweight'
When BMI >= 18.5 and BMI < 25 then 'normal'
When BMI >= 25 and BMI <30 then 'overweight'
else 'Obese'
end as BMI_Category,
Case
When TIMESTAMPDIFF(YEAR, p.date_of_birth, NOW()) >= 50 then 1
else 0
End as age_over_50,
Case 
When (family_history_of_hypertension = 'Yes' or TIMESTAMPDIFF(YEAR, p.date_of_birth, NOW()) >=50) and BMI >=30
Then 'High Risk'
When (family_history_of_hypertension = 'Yes' or TIMESTAMPDIFF(YEAR, p.date_of_birth, NOW()) >=50) and BMI >=25 and BMI <30
Then 'Medium Risk'
Else 'Low Risk'
End as Hypertension_prediction
from healthcare_database.patients as p
inner join healthcare_database.hospital_records as hr
on p.patient_id = hr.patient_id
where TIMESTAMPDIFF(YEAR, p.date_of_birth, NOW()) >=18;

/*Challenge: Identify Individuals at high risks of developing diabetes within a population base on smoker statu and glucose levels

- Individuals who are smoker and have glucose level more or equal to 126 are considered at high risk
- Individuals who are smokers and have glucose level more or equal to 100, but less than are consider at Medium Risk
- Everyone else is Low Risk*/

select 
case
when smoker_status = 'Y' or result_value >= 126 then 'High Risk for Diabetes'
when smoker_status = 'Y' or (result_value >= 100 and result_value <126) then 'Medium Risk for Diabetes'
else 'Low Risk for Diabetes'
end as risk_category,
count(*) as  population_count
from 
healthcare_database.outpatient_visits as ov
inner join healthcare_database.lab_results as lr
on ov.visit_id = lr.visit_id
where test_name = 'fasting blood sugar'
group by 
case
when smoker_status = 'Y' or result_value >= 126 then 'High Risk for Diabetes'
when smoker_status = 'Y' or (result_value >= 100 and result_value <126) then 'Medium Risk for Diabetes'
else 'Low Risk for Diabetes'
end;

/*I/*dentify a cohort of patients with chronic diseases, including hypertension, hyperlipemia, and diabetes.
Only include patients who have visited the clinic within the last year*/

SELECT
    patient_id,
    diagnosis,
    visit_date
FROM healthcare_database.outpatient_visits
WHERE diagnosis IN ('Hypertension', 'Hyperlipidemia', 'Diabetes')
AND visit_date BETWEEN DATE_SUB(NOW(), INTERVAL 1 YEAR) AND NOW();

-- Examine the demographic characteristics of diabetic patients by gender and age group

select
gender,
CASE 
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 18 AND 30 THEN '18-30'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 31 AND 50 THEN '31-50'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 51 AND 70 THEN '51-70'
    ELSE '71+'
END AS age_group,
count(*) as patient_count
from healthcare_database.patients as p
inner join healthcare_database.outpatient_visits as ov
on p.patient_id = ov.patient_id
where diagnosis = 'Diabetes'
group by
gender,
CASE 
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 18 AND 30 THEN '18-30'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 31 AND 50 THEN '31-50'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, NOW()) BETWEEN 51 AND 70 THEN '51-70'
    ELSE '71+'
END;


-- Investigate the main reason for diabetic patients to visit the hospital

Select
reason_for_visit,
count(*) as visit_count
from healthcare_database.outpatient_visits
where diagnosis = 'Diabetes'
group by reason_for_visit;


-- Distribution of smoker status amonng diabetic patients by gender

select
gender,
smoker_status,
count(*) as patient_count
from healthcare_database.outpatient_visits as pv
inner join healthcare_database.patients as p
on pv.patient_id = p.patient_id
where diagnosis = 'Diabetes'
group by
gender,
smoker_status;

/*Develop a query to explore the different relationship between age, gender, medication prescribed and blood sugar
control among diabetic patients who had a fasting blood sugar test*/

select
p.patient_id,
patient_name,
gender,
timestampdiff(year, p.date_of_birth, now()) as age,
lr.result_value as fasting_blood_sugar,
medication_prescribed,
test_date,
ov.diagnosis as diabetes_status
from healthcare_database.outpatient_visits as ov
inner join healthcare_database.patients as p
on ov.patient_id = p.patient_id
inner join healthcare_database.lab_results as lr
on lr.visit_id = ov.visit_id
where ov.diagnosis = 'Diabetes' and lr.test_name = 'Fasting Blood Sugar';

/*Buold a query that retrieves that appointemtn data, focus on patient arrival time and when patient was admitted across different 
department*/

SELECT
    department_name,
    AVG(TIMESTAMPDIFF(MINUTE, arrival_time, admission_time)) AS avg_wait_time,
    MIN(TIMESTAMPDIFF(MINUTE, arrival_time, admission_time)) AS min_wait_time,
    MAX(TIMESTAMPDIFF(MINUTE, arrival_time, admission_time)) AS max_wait_time,
    COUNT(*) AS total_appointments
FROM healthcare_database.appointment
GROUP BY department_name;

-- Build a query to ensure the patients are getting their lab test done on the same day as their visit

select
      ov.visit_id,
      ov.visit_date,
      ov.doctor_name,
      lr.test_name,
      lr.test_date,
      timestampdiff(day, ov.visit_date, lr.test_date) as days_between_visit_and_test
from 
      healthcare_database.outpatient_visits as ov
inner join 
	  healthcare_database.lab_results as lr
on  
	  ov.visit_id = lr.visit_id;
      
-- Identify the readmission rates per department

SELECT
    department_name,
    COUNT(patient_id) AS total_patients,
    COUNT(CASE WHEN days_in_the_hospital = 1 THEN patient_id END) AS readmitted_patients,
    (COUNT(CASE WHEN days_in_the_hospital = 1 THEN patient_id END) * 100.0 / COUNT(patient_id)) AS readmission_rate
FROM healthcare_database.hospital_records
GROUP BY department_name;

-- Show the profile of the patients being readmitted

SELECT
    department_name,
    gender,
    avg(bmi) as avg_bmi,
    COUNT(p.patient_id) AS total_patients,
    avg(timestampdiff(year, date_of_birth, now())) as avg_age,
    COUNT(CASE WHEN days_in_the_hospital = 1 THEN p.patient_id END) AS readmitted_patients,
    (COUNT(CASE WHEN days_in_the_hospital = 1 THEN p.patient_id END) * 100.0 / COUNT(p.patient_id)) AS readmission_rate
FROM healthcare_database.hospital_records AS hr
inner join healthcare_database.patients as p
on p.patient_id = hr.patient_id
GROUP BY department_name, gender;

-- Challenge: find out the distribution of appointments across each day in the hospital

SELECT 
    DAYNAME(appointment_date) AS weekday_name,  -- Extracts the weekday name (e.g., 'Monday', 'Tuesday')
    COUNT(*) AS appointment_count
FROM healthcare_database.appointment
GROUP BY DAYNAME(appointment_date)
ORDER BY appointment_count DESC;

-- What is the demographic profile of the paitent population, including age and gender distribution?

select gender,
case 
when timestampdiff(year, date_of_birth, now()) between 0 and 17 then 'Pediatric'
when timestampdiff(year, date_of_birth, now()) between 18 and 64 then 'Adult'
else 'Senior'
end as age_group,
count(*) as patient_count
from healthcare_database.patients
group by
gender,
case 
when timestampdiff(year, date_of_birth, now()) between 0 and 17 then 'Pediatric'
when timestampdiff(year, date_of_birth, now()) between 18 and 64 then 'Adult'
else 'Senior'
end;

/*Which diagnosis are most prevalent among patients, and how do they very across different demographic groups,
including gender and age?*/

select gender,diagnosis,
case 
when timestampdiff(year, date_of_birth, now()) between 0 and 17 then 'Pediatric'
when timestampdiff(year, date_of_birth, now()) between 18 and 64 then 'Adult'
else 'Senior'
end as age_group,
count(*) as patient_count
from healthcare_database.patients as p
inner join healthcare_database.outpatient_visits as ov
on p.patient_id = ov.patient_id
group by
gender, diagnosis,
case 
when timestampdiff(year, date_of_birth, now()) between 0 and 17 then 'Pediatric'
when timestampdiff(year, date_of_birth, now()) between 18 and 64 then 'Adult'
else 'Senior'
end;

/*What are the most common appointment times throughout the day, and how does the distribution of appointment times
vary across different hours?*/

SELECT 
    HOUR(appointment_time) AS appointment_hour,  -- Extracts only the hour (0-23)
    COUNT(*) AS appointment_count
FROM healthcare_database.appointment
GROUP BY HOUR(appointment_time)
ORDER BY appointment_count DESC;

-- What are most commonly ordered lab test?

select
test_name,
count(*) as test_count
from healthcare_database.lab_results
group by test_name
order by test_count desc;

/*Typically, fasting blood sugar levels fails between 70-100mg/dl. Our goal is to identify patients whose lab result
are outside this normal range to implement early intervention*/

select 
p.patient_id,
p.patient_name,
result_value
from healthcare_database.patients as p
inner join healthcare_database.outpatient_visits as ov
on p.patient_id = ov.patient_id
inner join healthcare_database.lab_results as lr
on ov.visit_id = lr.visit_id
where lr.test_name = 'Fasting Blood Sugar'
and (lr.result_value < 70 or lr.result_value >100);

/*Asess how many patients are considered high, medium and low risk

HighRisk: patients who are smoker and have been diagnosed with either hypertension or diabetes.
Medium Risk: patients who are non-smokers and have been diagnosed with either hypertension or diabetes.
Low Risk: patients who do not fall into the High or Medium Risk categories. This patients who are not smokers
         and do not have a diagnosis of hypertension or diabetes.*/
         
select
case
when smoker_status = 'Y' and (diagnosis + 'Hypertension' or diagnosis = 'Diabetes') then 'High Risk'
When smoker_status = 'N' and (diagnosis + 'Hypertension' or diagnosis = 'Diabetes') then 'Medium Risk'
Else 'Low Risk'
End as risk_categorgy,
count(patient_id) as num_patients
from healthcare_database.outpatient_visits
group by 
case
when smoker_status = 'Y' and (diagnosis + 'Hypertension' or diagnosis = 'Diabetes') then 'High Risk'
When smoker_status = 'N' and (diagnosis + 'Hypertension' or diagnosis = 'Diabetes') then 'Medium Risk'
Else 'Low Risk'
End;

/*Find out information about patients who had multiple visits with 30 days of their previous medical visit
- Indentify those patients
- Date if intial visit
- Reason of the intial visit
- Readmission date
- Reason for readmissiom
- Number of days between the initial visit and readmission
- Readmission visit recorded must have happened after the intial visit*/

SELECT
    ov_initial.patient_id,
    ov_initial.visit_date AS initial_visit_date,
    ov_initial.reason_for_visit AS initial_visit,
    ov_readmit.visit_date AS readmit_date,
    ov_readmit.reason_for_visit AS reason_for_readmission,
    TIMESTAMPDIFF(DAY, ov_initial.visit_date, ov_readmit.visit_date) AS days_between_initial_and_readmission
FROM healthcare_database.outpatient_visits AS ov_initial
INNER JOIN healthcare_database.outpatient_visits AS ov_readmit
ON ov_initial.patient_id = ov_readmit.patient_id
WHERE TIMESTAMPDIFF(DAY, ov_initial.visit_date, ov_readmit.visit_date) <= 30
AND ov_readmit.visit_date > ov_initial.visit_date
ORDER BY ov_initial.patient_id, ov_initial.visit_date;
