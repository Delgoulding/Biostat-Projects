**********************************************************************************;
*	PROGRAM NAME: MCI Analysis													 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Evaluate different rate of decline by MCI and change point			 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=animal2                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/animals.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run;


*-- ANIMALS ANALYSIS--*;

*-- PEV= demind and age, can expect an interaction between demind and age
	Want to account for longitudinal data (correlation between subjects data)
	Want to account for individual intercepts (random intercept) --*;

*-- create interaction terms --*;	
data animal2;
set animal2;
demind_age = demind*age; /*age not centered*/ 
demind_agen= demind*age_int; /*age centered on 67*/
changepnt = max(0,(age - (ageonset - 4)));
run; 

*-- PEV: demind age_int, changept COV: gender, ses INT: demind_agen*; 

*-- model 1: random intercept --*; 
proc mixed data=animal2 plots=all;
class id demind gender ;
model animals= demind age_int changepnt demind_agen ses gender   / solution;
*-- model 1: random intercept --*; 
proc mixed data=animal2 plots=all;
class id demind gender ;
model animals= demind age_int changepnt  ses gender   / solution;
/*random intercept / subject=id type=un g gcorr v vcorr;
run; /*-2LL: 7904.6 REML 7886.4 ML */

proc mixed data=animal2  plots=all;
class id demind gender ;
model animals= demind age_int demind_agen changepnt ses gender   / solution;
random intercept  / subject=id type=un g gcorr v vcorr;
run; /*-2LL: 7904.6 REML 7886.4 ML */

*-- model 2: random slope --*;
proc mixed data=animal2  plots=all;
class id demind gender ;
model animals= demind age_int changepnt demind_agen ses gender   / solution;
random age_int  / subject=id type=un g gcorr v vcorr;
run; /*-2LL 8075.2 REML 8056.1 ML*/ 

*-- model 3: random intercept & slope --*;
proc mixed data=animal2plots=all;
class id demind gender /ref=first;
model animals= demind age_int demind_agen changepnt ses gender  / solution;
random intercept age_int  / subject=id type=un g gcorr v vcorr;
run; /*7893.7 REML 7876.3 ML*/ 


data test;
 intR= 1-probchi( 7904.6-7893.7,1); /*keep slope*/
 slopeR= 1-probchi( 8075.2 -7893.7,1); 
  mess= 1-probchi( 10000 -7893.7,1); 
run;

