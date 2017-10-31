**********************************************************************************;
*	PROGRAM NAME: VA Data Management- P2										 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Determine which VA hospitals have lower/higher observed MR			 *;
**********************************************************************************;

%let va='/folders/myfolders/bios6623-delgoulding/Project2/Code/vadata2.sas7bdat'; /*location of data*/
%let yr1_1=34;
%let yr3_1=38;
%let final=39;

*-- import data --*;
Data va;
set &va;
if proced >= 2 then delete; /* delete procedures not 0 or 1 */
run;

*-- DATA MANAGEMENT --*; 
*-- create variable to examine this time period to adjusted period --*;
data va;
set va;
if sixmonth=&final then ratefinal = 1;
if &yr1_1<=sixmonth<=&yr3_1 then ratefinal=0;
run;

title 'Frequency procedures this period compared to adjusted periods';
proc freq data=va;
tables ratefinal*(sixmonth proced hospcode); /*4424 this 6month, 26000 ish total*/
run;

title 'Examination of covariates this period';
proc means data=va  n nmiss mean std q1 q3 p50 min max median t probt;
where sixmonth=&final;
run; /*bmi has some extreme values, albumin lots missing, procedure missing 100*/

*-- BMI QUALITY CONTROL CHECK --*; 
*-- new BMI variables --*;
data va;
set va;
bmi_a = ((weight)/(height**2))*703; /*used Brian Hixon's bmi code, couldn't get my bmi to work*/
if bmi_a < 19 then bmi2 = bmi;
else bmi2 = bmi_a; 			/*new bmi*/
bmi_dif = bmi - bmi_a;      /*bmi difference*/
run;

proc univariate data=va plots;
class ratefinal;
var bmi2;
run;

*-- check new bmi variable --*;
proc print data=va ;
where bmi_dif >=1 and sixmonth=&final; /*.5 , 1 , 5 : decided 1 may be sensitive enough cut off*/
var hospcode bmi bmic height weight bmi_dif sixmonth; /*hospitals 1-16 ALL BMIs changed, weight lower for those hospitals hospital 18 & 23 had 1 change*/
run;

proc univariate data=va plots;
class hospcode;
var weight; /*1-16 weights very low compared to others*/
run;

proc means mean min max q1 q3;
where sixmonth=&final;
class hospcode;
var bmi_a bmi bmi2;
run;

proc univariate data=va plots;
where sixmonth=&final;
var bmi2;
run;


*--1592 BMIs changed greater than 1, all in sixmonth 39, in hospitals 1-16
decided 1-16 are using KG instead of lbs, kept the old BMI variable for those hospitals--*;


