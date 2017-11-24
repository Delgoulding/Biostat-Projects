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
	Want to account for repeated observations (correlated data)
	Want to account for individual intercepts (random intercept) --*;
proc mixed data=animal2 plots=all;
class id demind gender /ref=first;
model animals= demind age ses gender changept demind*age / solution;
random intercept  / subject=id type=un g gcorr v vcorr;
run; 


