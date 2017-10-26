This is the README file for Project 2- dataset 2

In the code folder is the SAS code 
In the document folder is outputs and an excel file for tables created
In the report folder is the interim report



DATA NOTES:
Data received from 44 VA hospitals (hospcode).
VA investigators want to know if the death rate (death30) is unusually high OR low. 

Primary goal/ question: What is the observed death rate from heart surgery at each hospital for the most recent 6 month period(39)?  

Data Notes:
2.5 years of past data to help develop hospital adjusted estimates of expected risk
BMI, height, weight gathered
Condition @ procedure start recording (1good, 5bad)
Types of heart surgery (2)
Albumin- protein in liver
4424 procedures this six month review

Data Management:
BMI Summary
Procedure missing 103 (delete or keep?) IF delete, missing data
delete people with the 2 procedure 
rate as percents or per 1000

Data Plan:
Make an average OR (34-38) per 44 hospitals
*anchor OR (39) compared to past OR (34-38)
Compare OR 
Variable definitions:
Adjusted DR: #deathrates/n procedures (34-38)
Expected DR: Death30 in logistic regression
Observed DR: Actual Death30 (39) 

adjusted for: bmi, albumin, asa, 

observed, #died #seen rate and health procedure adjusted expected rate @ hospital level
Pooling all the data for the rate is okay with us


all data: median / interquartile 

obs/exp >1.2 (clinical feedback from hospitals) (hospitals that differ from 20% or more)

table 1: average variation across 6 month is ___ (either median/25/75 OR mean sd **) 

	 