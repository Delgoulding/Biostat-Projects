**********************************************************************************;
*	PROGRAM NAME: Project 1 BIOS6623 code										 *;
*	DATE CREATED: September 2017												 *;
*	LAST UPDATED: September 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate quality of life changes with ART treatment & hard drug use *;
*	Looking at participants baseline compared @ y2/ looking @ covariates		 *;
**********************************************************************************;


options nocenter nodate nonumber source2 mprint symbolgen;
ods escapechar='~';
%let bold_style=~S={font_size=14pt font_weight=bold}~; 

*--macro variables to limit data, can change later if need--*;
%let yr_base=0;
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
*-- changing some values to missing --*;
data hivbase;
set hivbase;
if bmi = 999 then bmi = . ;
if heropiate = -9 then heropiate = . ;
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
proc contents data=hiv;
run;
*-- creating a dataset with just BASE --*;
data hivbase;
set hiv2;
where years=&yr_base;
run;
proc sort data=hivbase;
by hard_drugs;
run;
*-- descriptive statistics overall and by hard drug use group --*;
proc freq data=hivbase;
tables everart art; /*no one has taken ART previously*/
run;
title 'Categorical Descriptives';
proc freq data=hivbase;
tables hard_drugs*(educbas race income adh idu heropiate dkgrp smoke dyslip kid liv34 
diab hashv hashf);
format hard_drugs ny.  educbas education. race ny. income income. adh ny. idu ny. heropiate ny. smoke ny. 
dyslip ny. kid ny. liv34 ny. diab ny. hashv ny. hashf ny. ;
run;
title 'Continuous Descriptives';
proc means data=hivbase n nmiss mean std min max median t probt ;
class hard_drugs; /*block for overall means*/
var bmi age cesd agg_phys agg_ment TCHOL TRIG LDL LEU3N	VLOAD; 
run;





