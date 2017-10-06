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
if race= 1 then race_cat = 0;
else if race then race_cat = 1;
if dkgrp = 3 then alcohol_use=1;
if dkgrp IN(0,1,2) then alcohol_use=0;
if smoke = 3 then smoker= 1;
else if smoke then smoker= 0;
if income = 1 then income_cat=1;
if income IN(2,3,4) then income_cat=0;
if income IN(5,6,7,8) then income_cat=2;
if income = 9 then income_cat= '.';
if educbas IN(1,2,3) then highschool= 1;
else if educbas then highschool = 0 ;
if adh IN(1,2) then adhered = 1;
else if adh IN(3,4) then adhered = 0;
else if adh = ' ' then adhered = '.';
run;
*-- check to see if new categories match old--*;
proc freq data=hiv2;
tables educbas highschool adh adhered income income_cat smoke smoker race race_cat dkgrp alcohol_use;
run;

*--looking at data and make sure numeric --*;
proc contents data=hiv2;
run;
*-- creating a dataset with just BASE --*;
data hivbase;
set hiv2;
where years=&yr_base;
run;
*-- creating a dataset with just 2year and renaming outcome variables --*;
data hiv2yr (keep=newid agg_ment2 agg_phys2 leun2 vload2 harddrugs2 adhered);
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
proc print data=hiv3;
var newid hard_drugs harddrugs2; /*some participants are not hard drug users at year 2*/
run;
*-- creating a drug use at baseline variable --*;
data hiv3;
set hiv3;
if hard_drugs= 1 and harddrugs2=1 then base_drug= 1;
if hard_drugs= 0 and harddrugs2=0 then base_drug=0;
if hard_drugs= 1 and harddrugs2=0 then base_drug=1;
if hard_drugs= 0 and harddrugs2=1 then base_drug=0;
run;
proc freq data=hiv3;
table base_drug; /*39 participants used hard drugs at baseline & have 2yr data*/
run;
*-- descriptive statistics overall and by hard drug use group --*;
proc freq data=hivbase;
tables everart art; /*no one has taken ART previously*/
run;

title 'Categorical Descriptives';
proc freq data=hiv3; /*only want to have those with 2 year data in demographic table*/
tables base_drug*(highschool race_cat alcohol_use smoker income_cat adhered idu heropiate dkgrp smoke dyslip kid liv34 
diab hashv hashf);
format base_drug ny. ;
run;

title 'Continuous Descriptives';
proc means data=hiv3 n nmiss mean std min max median t probt ;
class base_drug; 
var bmi age cesd agg_phys agg_ment TCHOL TRIG LDL LEU3N	VLOAD vlog ;
run;

*-- deleting participants that do not have year 2 data --*;
data hivdelete;
set hiv3;
if harddrugs2 = ' ' then delete;
run;

title 'Continuous Descriptives';
proc means data=hivdelete n nmiss mean std min max median t probt ; 
var bmi age cesd agg_phys agg_ment TCHOL TRIG LDL LEU3N	VLOAD vlog ;
run;

*-- looking for BMI outlier --*;
proc print data=hivbase;
var newid bmi; /*newid 113- possibly remove*/ /*changed to missing in excel and re-ran*/
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
var newid years; /*some participants changed from 1 to 0 or 0 to 1, while others dropped out*/
run;
*--looking at outcomes for assumption fit --*;
proc univariate data=hiv3  plots;
class base_drug;
var leu3n vlog agg_ment agg_phys; /*vload may need to be log transformed*/
histogram leu3n vlog agg_ment agg_phys;
run; 
data hiv3; /*added vlog to previous statement in place of vload, much better*/
set hiv3;
vlog = log10(vload);
vlog2 = log10(vload2);
run;

data hiv4;
set hiv3;
vload_d = vlog2 - vlog;
leun_d = leun2- leu3n;
agg_md = agg_ment2 - agg_ment;
agg_pd = agg_phys2 - agg_phys;
run;

proc univariate data=hiv4 plots;
class base_drug;
var vload_d leun_d agg_md agg_pd;
run;
*-- crude and adjusted models aggregate physical health change--*;
proc glm data=hiv4;
class base_drug/ ref=first;
model agg_pd = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug highschool income_cat smoker race_cat alcohol_use hashv/ ref=first;
model agg_pd = base_drug highschool income_cat smoker race_cat age alcohol_use hashv agg_phys/ solution clparm;
run;
*-- seeing if any of the variables are closely related --*;
proc corr data=hiv4;
var agg_pd highschool income_cat smoker race_cat age alcohol_use hashv agg_phys; /*only baseline scores are weakly correlated */
run;

proc glm data=hiv4;
class base_drug/ ref=first;
model agg_md = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug highschool income_cat smoker race_cat alcohol_use hashv/ ref=first;
model agg_md = base_drug  highschool income_cat smoker race_cat age alcohol_use hashv agg_ment/ solution;
run;

proc glm data=hiv4;
class base_drug/ ref=first;
model vload_d = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug highschool income_cat smoker race_cat alcohol_use hashv/ ref=first;
model vload_d = base_drug  highschool income_cat smoker race_cat age alcohol_use hashv vlog/ solution;
run;
proc corr data=hiv4; /*highschool and race are moderately correlated-  multicolinearity?*/
var vload_d highschool income_cat smoker race_cat age alcohol_use hashv vlog; /*only baseline scores are weakly correlated */
run;

proc glm data=hiv4;
class base_drug/ ref=first;
model leun_d = base_drug / solution clparm;
run;
proc glm data=hiv4; /*adjusted made cd4count decrease a little, but both models sign*/
class base_drug income_cat smoker race_cat alcohol_use hashv/ ref=first;
model leun_d = base_drug  income_cat smoker race_cat age alcohol_use hashv leu3n/ solution;
run;

proc corr data=hiv4; /*highschool and race are moderately correlated-  multicolinearity?*/
var leun_d highschool income_cat smoker race_cat age alcohol_use hashv leu3n; /*only baseline scores are weakly correlated */
run;
