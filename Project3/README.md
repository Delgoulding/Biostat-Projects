This is the README file for Project 3.

ABOUT
Primary Questions:
What is the rate of memory decline based on these measures over the aging process in healthy individuals?

What is the rate of memory decline based on these measures over the aging process in those diagnosed with MCI/dementia during the study?

Additional Question:
Is there a period of time before the diagnosis of MCI/dementia in which the rate of the memory decline changes (or accelerates)?

Longterm goal: biomarkers Short term: what is noticeable compared to aging process

VARIABLES
Explanatory:
(1) Demind: Binary MCI, based on two consecutive CDRS > 0.5  
(2) ageonset: Age Onset for MCI, missing for NO MCI group 
(3) age
Outcomes: 
(1) Wechsler Memory Scale Logical Memory I Story A (logmemI) 
(2) Wechsler Memory Scale Logical Memory II Story A (logmemII) 
(3) category fluency for animals (animals)
(4) Wechsler Adult Intelligence Scale-Revised Block Design (blockR)
Covariates
SES: continuous SES status 
Gender: 1= male, 2=female
		
FOLDERS
(1)Code
	(a) DM MCI: Data Management Code
	(b) MCI Descriptives: Descriptive Statistics Code
	(c) MCI Analysis:
(2)Reports
	(a) Interim Report
	(b) Report 3
(3)Documents
 

TABLE 1: averages for first visit (baseline). maybe differences five years out. 
and then average time to onset

SPLINE TERM USED TO ALLOW FOR LINEAR/QUADRATIC TRENDS TO CHANGE AT SOME POINT PRIOR TO DEMENTIA DIAGNOSIS 

	 