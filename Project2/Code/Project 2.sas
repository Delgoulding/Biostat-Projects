**********************************************************************************;
*	PROGRAM NAME: Project 2 BIOS6623 code										 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate quality of life changes with ART treatment & hard drug use *;
*	Looking at participants baseline compared @ y2/ looking @ covariates		 *;
**********************************************************************************;

%let va='/folders/myfolders/bios6623-delgoulding/Project2/Code/vadata2.sas7bdat';

Data va;
set &va;
run;

proc contents data=va;
run;