# Leveraging-SQL-for-Transformative-Healthcare-Insights

Highlights of My Work Include:

Appointment Wait Time Analysis:
I crafted queries to calculate both complete and fractional appointment wait times by using functions like TIMESTAMPDIFF and TIME_TO_SEC. This helped quantify operational efficiency and pinpoint bottlenecks.

Patient Readmission Tracking:
By joining outpatient visit data on patient IDs, I was able to identify readmissions within 30 days of an initial visit. This involved calculating the difference in days between visits to flag potential high-risk cases.

Risk Stratification with CASE Statements:
I developed comprehensive risk prediction models by combining factors such as BMI, family history of hypertension, and age (using TIMESTAMPDIFF(YEAR, date_of_birth, NOW())). This allowed me to categorize patients into risk groups—'High Risk', 'Medium Risk', and 'Low Risk'—to support proactive patient care.

Aggregated Insights by Demographics:
I grouped data by department and gender to derive meaningful metrics, such as average BMI, readmission rates, and patient counts. These insights are vital for understanding patient demographics and tailoring intervention strategies.
