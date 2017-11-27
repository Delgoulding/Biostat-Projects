**********************************************************************************;
*	PROGRAM NAME: MCI Analysis													 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate different rate of decline by MCI and change point			 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=animals                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/animals.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run;


*-- ANIMALS ANALYSIS--*;

*-- PEV= demind and age, can expect an interaction between demind and age
	Want to account for longitudinal data (correlation between subjects data)
	Want to account for individual intercepts (random intercept) --*;

*-- create interaction terms --*;	
data animal3;
set animals;
demind_age = demind*age; /*age not centered*/ 
demind_agen= demind*age_int /*age centered on 67*/
changepnt = max(0,(age - ageonset + 4));
run; 

*-- PEV: demind age_int, changept COV: gender, ses INT: demind_agen*; 

*-- model 0: just looking at fixed effects --*; 
title 'no random effects';
proc mixed data=animal3  plots=all;
class id demind gender ;
model animals= demind age_int changepnt demind_agen ses gender   / solution;

*-- model 1: random intercept --*; 
title 'random intercept';
proc mixed data=animal3 plots=all;
class id demind gender ;
model animals= demind age_int demind_agen changepnt ses gender   / solution;
random intercept  / subject=id type=un g gcorr v vcorr;
run; /*-2LL: 7904.6 REML  */
title 'random slope';

*-- model 2: random slope --*;
proc mixed data=animal3  plots=all;
class id demind gender ;
model animals= demind age_int changepnt demind_agen ses gender   / solution;
random age_int  / subject=id type=un g gcorr v vcorr;
run; /*-2LL 8075.2 REML */ 
title 'random intercept and slope';

*-- model 3: random intercept & slope --*;
proc mixed data=animal3  plots=all;
class id demind gender /ref=first;
model animals= demind age_new demind_agen changepnt ses gender  / solution cl;
random intercept age_new  / subject=id type=un g gcorr v vcorr;
run; /*7893.7 REML */ 
proc mixed data=animal3  plots=all;
class id demind gender /ref=first;
model animals= demind age_new demind_agen changepnt ses gender  / solution cl;
random intercept age_int  / subject=id type=un g gcorr v vcorr;
run;

*--attempting to do a likelihood ratio test: got this code from Chris Czaja --*;
data test;
 intR= 1-probchi(7886.4-7876.3,1); /*keep full model*/
 slopeR= 1-probchi( 8056.1 -7876.3,1); /*keep slope only model?*/
run;

*--correlation between variables in the model --*;
proc corr data=animal3;
var demind changepnt ses gender age_int ; /*change point and demind STRONGLY correlated*/
run;

