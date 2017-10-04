**********************************************************************************;
*	PROGRAM NAME: Project 1 BIOS6623 code										 *;
*	DATE CREATED: September 2017												 *;
*	LAST UPDATED: September 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate quality of life changes with ART treatment & hard drug use *;
*	Looking at participants baseline compared @ y2/ looking @ covariates		 *;
**********************************************************************************;

*--macro variables to limit data, can change later if need--*;
%let yr_base=0;
%let yr_mid=1;
%let yr_end=2;


*--import HIV data --* ; 
proc import dbms=xls out=hiv                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project1/Raw Data/hiv_6623.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 
*--limiting data to baseline, 1 , and 2 --*;
data hiv2;
set hiv;
where &yr_base<=years<=&yr_end;
run; 
*-- changing some values to missing and create categories to investigators suggestion --*;
data hiv2;
set hiv2;
if bmi = 999 then bmi = . ;
if bmi = -1 then bmi = . ;
if heropiate = -9 then heropiate = . ;
if CESD = -1 then CESD= . ;
if income = 9 then income = . ;
if race= 1 then race_cat = 0;
else if race then race_cat = 1;
if dkgrp = 3 then alcohol_use=1;
else if dkgrp then alcohol_use=0;
if smoke = 3 then smoker= 1;
else if smoke then smoker= 0;
if income = 1 then income_cat=1;
if income IN (2 , 3 , 4) then income_cat=0;
else if income  then income_cat=2;
if edubase IN( 1, 2, 3) then highschool= 1;
else if edubase then highschool = 0 ;
if adh = 1 or 2 then adhered = 1;
else if adh then adhered = 0;
run;

*--creating formats--*;
run;
proc format;
value ny
	0= 'no'
	1= 'yes';
value education
	1= '>8th grade'
	2= '9-11'
	3= '12th'
	4= 'some college'
	5= 'Bachelors'
	6= 'some post graduate'
	7= 'Post-graduate degree';
value income 
	1= '<10'
	2='10-19'
	3= '20-29'
	4= '30-39'
	5= '40-49'
	6= '50-59'
	7= '>60';
run;
*--looking at data and make sure numeric --*;
proc contents data=hiv2;
run;
*-- creating a dataset with just BASE --*;
data hivbase;
set hiv2;
where years=&yr_base;
run;
data hiv2yr (keep=newid agg_ment2 agg_phys2 leun2 vload2 harddrugs2);
set hiv2;
where years=&yr_end;
rename agg_ment = agg_ment2;
rename agg_phys = agg_phys2;
rename leu3n = leun2;
rename vload= vload2;
rename hard_drugs=harddrugs2;
run;
data hiv3;
merge hivbase 
	  hiv2yr ;
by newid;
run;

*-- descriptive statistics overall and by hard drug use group --*;
proc freq data=hivbase;
tables everart art; /*no one has taken ART previously*/
run;

title 'Categorical Descriptives';
proc freq data=hiv3; /*only want to have those with 2 year data in demographic table*/
tables hard_drugs*(highschool race_cat alcohol_use smoker income_cat adhered idu heropiate dkgrp smoke dyslip kid liv34 
diab hashv hashf);
format hard_drugs ny. idu ny. heropiate ny. smoker ny. 
dyslip ny. kid ny. liv34 ny. diab ny. hashv ny. hashf ny. ;
run;

title 'Continuous Descriptives';
proc means data=hivbase n nmiss mean std min max median t probt ;
class hard_drugs; /*block for overall means*/
var bmi age cesd agg_phys agg_ment TCHOL TRIG LDL LEU3N	VLOAD; 
run;

*-- looking for BMI outlier --*;
proc print data=hivbase;
var newid bmi; /*newid 113- possibly remove*/ /*changed to missing in excel*/
run;

*-- looking at overall change in drug use sample size --*;
data hivpost;
set hiv2;
where years=&yr_end;
run;
proc freq data=hivpost;
tables hard_drugs;
run;
data hivmid;
set hiv2;
where years=&yr_mid;
run;
proc freq data=hivmid;
tables hard_drugs;
run;
proc print data=hiv2;
where hard_drugs = 1;
var newid years;
run;
proc print data=hiv2;
where newid IN(95 102 104 700 703);
var newid hard_drugs years;
run; 

proc univariate data=hiv3  plot;
class hard_drugs;
var vleu3n vload agg_ment agg_phys;
run; 

proc univariate data=hiv3 plot;
class hard_drugs;
var vleu3n vload agg_ment agg_phys;
run;

data hiv4;
set hiv3;
vload_chg = vload2 - vload;
leun_chg = 





