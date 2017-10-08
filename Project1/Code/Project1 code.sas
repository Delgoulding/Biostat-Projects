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
*-- change some values to missing and create categories to investigators suggestion --*;
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
else if adh = ' ' then adhered = . ;
run;
*-- check to see if new categories match old--*;
/*proc freq data=hiv2;
tables educbas highschool adh adhered income income_cat smoke smoker race race_cat dkgrp alcohol_use;
run;*/

*-- limit to data to just base and two years
	Create a dataset with just BASE --*;
data hivbase;
set hiv2;
where years=&yr_base;
run;
*-- create a dataset with just 2year  
	rename outcome variables @ two years
	keep adherence @ two years --*;
data hiv2yr (keep=newid agg_ment2 agg_phys2 leun2 vload2 harddrugs2 adhered);
set hiv2;
where years=&yr_end;
rename agg_ment = agg_ment2;
rename agg_phys = agg_phys2;
rename leu3n = leun2;
rename vload= vload2;
rename hard_drugs=harddrugs2;
run;
*--merge new dataset and keep only variables needed for two year analysis--*;
data hiv3;
merge hivbase 
	  hiv2yr ;
by newid;
if harddrugs2 = ' ' then delete;
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

title 'Sample size for drug use @ baseline';
proc freq data=hiv3;
table base_drug; /*39 participants used hard drugs at baseline & have 2yr data*/
run;
*-- descriptive statistics overall and by hard drug use group --*;
proc freq data=hiv3;
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
class base_drug; /*block this for overall means*/
var bmi age cesd agg_phys agg_ment TCHOL TRIG LDL LEU3N	VLOAD vlog ;
run;

*-- looking for BMI outlier --*;
/*proc print data=hivbase;
var newid bmi; /*newid 113- possibly remove- changed to missing in excel and re-ran*/
/*run; */


*--looking at outcomes for assumption fit --*;
proc univariate data=hiv3  plots;
class base_drug;
var leu3n vlog agg_ment agg_phys; /*vload may need to be log transformed*/
histogram leu3n vlog agg_ment agg_phys;
run; 
proc univariate data=hiv3  plots;
class base_drug;
var leun2 vload agg_ment2 agg_phys2; /*vload may need to be log transformed*/
histogram leun2 vlog2 agg_ment2 agg_phys2;
run; 
*-- log transformation of viral load --*;
data hiv3; 
set hiv3;
vlog = log10(vload);
vlog2 = log10(vload2);
run;
*-- checking to see if log transformation is better and it is --*;
proc univariate data=hiv3  plots;
class base_drug;
var leu3n vlog agg_ment agg_phys; /*vload changed tp vlog*/
histogram leu3n vlog agg_ment agg_phys;
run; 
*-- create delta variables --*;
data hiv4;
set hiv3;
vload_d = vlog2 - vlog;
leun_d = leun2- leu3n;
agg_md = agg_ment2 - agg_ment;
agg_pd = agg_phys2 - agg_phys;
run;
*-- looking at crude estimates and assumption fit --*;
proc univariate data=hiv4 plots;
class base_drug;
var vload_d leun_d agg_md agg_pd;
histogram vload_d leun_d agg_md agg_pd;
run;
*-- crude and adjusted models delta aggregate physical health --*;
proc glm data=hiv4;
class base_drug/ ref=first;
model agg_pd = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug race_cat hashv alcohol_use smoker income_cat highschool adhered/ ref=first;
model agg_pd = base_drug agg_phys age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered/ solution clparm;
run;
*-- check relationship between covariate and outcome--*;
proc corr data=hiv4;
var agg_pd agg_phys age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered; /*only baseline scores are weakly correlated */
run;
*-- crude and adjusted models delta aggregate mental health --*;
proc glm data=hiv4;
class base_drug/ ref=first;
model agg_md = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug race_cat hashv alcohol_use smoker income_cat highschool adhered/ ref=first;
model agg_md = base_drug agg_ment age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered/ solution;
run;
*-- check relationship between covariate and outcome--*;
proc corr data=hiv4;
var agg_md agg_ment age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered; /*only baseline scores are weakly correlated */
run;
*-- crude and adjusted models delta viral load --*;
proc glm data=hiv4;
class base_drug/ ref=first;
model vload_d = base_drug / solution clparm;
run;
proc glm data=hiv4;
class base_drug race_cat hashv alcohol_use smoker income_cat highschool adhered/ ref=first;
model vload_d = base_drug vlog age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered/ solution;
run;
*-- check relationship between covariate and outcome--*;
proc corr data=hiv4; /*highschool and race are moderately correlated-  multicolinearity?*/
var vload_d vlog age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered; /*only baseline scores are weakly correlated */
run;
*-- crude and adjusted models delta cd4--*;
proc glm data=hiv4; /*crude significant*/
class base_drug/ ref=first;
model leun_d = base_drug / solution clparm;
run;
proc glm data=hiv4; /*adjusted made cd4count decrease a little, but both models sign*/
class base_drug race_cat hashv alcohol_use smoker income_cat highschool adhered / ref=first;
model leun_d = base_drug leu3n age bmi race_cat  hashv alcohol_use smoker income_cat highschool adhered/ solution;
run;
*-- check relationship between covariate and outcome--*;
proc corr data=hiv4; /*highschool and race are moderately correlated-  multicolinearity?*/
var leun_d leu3n age bmi race_cat hashv alcohol_use smoker income_cat highschool adhered ; /*only baseline scores are weakly correlated */
run;

*-- This is looking at overall change in drug use sample size
	create new dataset for each of the three years --*;
proc print data=hiv2;
where hard_drugs = 1;
var newid years; /*some participants changed from 1 to 0 or 0 to 1, while others dropped out*/
run;
data hivmiss;
merge hivbase 
	  hiv2yr;
by newid;
run;
data hivmiss;
set hivmiss;
if hard_drugs = 0 and harddrugs2=0 then drug=0;
if hard_drugs = 1 and harddrugs2 = 1 then drug = 1;
if hard_drugs = 1 and harddrugs2 = 0 then drug= 2;
if hard_drugs = 0 and harddrugs2 = 1 then drug= 4;
if hard_drugs = 1 and harddrugs2 = ' ' then drug=5;
if hard_drugs = 0 and harddrugs2 = ' ' then drug=6;
vlog = log10(vload);
vlog2 = log10(vload2);
vload_d = vlog2 - vlog;
run;
*-- examine size in each group --*;
proc freq data=hivmiss;
table drug;
run;
*-- examine baseline differences in outcome variables if investigator is interested --*;
proc means data=hivmiss;
class drug;
var agg_ment agg_phys vlog leu3n; /*those that stopped using had lower mental and CD4 cell counts. Those that dropped out had lower physical*/
run;
