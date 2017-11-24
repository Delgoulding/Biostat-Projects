**********************************************************************************;
*	PROGRAM NAME: MCI Descriptive Statistics									 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Descriptive of MCI/NO MCI participants' animal memory outcome		 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=animal                                                                                                   
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/animals.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 


*-- DESCRIPTIVE STATISTICS: TABLE 1 --*;
*-- create a baseline dataset to examine demographics --*; 
proc sort data=animal;
by id;
run; 

data base;
set animal;
by id;
if first.id then output base;
run;


*-- look at demographic differences between MCI groups at first visit --*; 
title 'Categorical @ Baseline';
proc freq data=base;
tables gender*demind/chisq; /*144 participants*/
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project3/table1.xls' /*location on computer for tables*/
STYLE=minimal;

title 'Continuous @ Baseline';
proc means data=base  n nmiss min max mean std  ;
var age ageonset ses logmemI logmemII animals blockR  ;
class demind;
run;
ods tagsets.excelxp close;

proc ttest data=base   ;
var age  ses  animals   ;
class demind;
run;


*-- create a fiveyr dataset to examine any demographic change --*; 
proc sort data=animal;
by visit_n;
run;

data five;
set animal;
by visit_n;
if visit_n=4 then output five;
run;

*-- look at demographic differences between MCI groups after 5 years --*; 
title 'Categorical @ Baseline';
proc freq data=five;
tables gender*demind/chisq; /*212 participants*/
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project3/table2.xls' /*location on computer for tables*/
STYLE=minimal;

title 'Continuous @ Baseline';
proc means data=five  n nmiss min max mean std  ;
var age ageonset ses logmemI logmemII animals blockR  ;
class demind;
run;
ods tagsets.excelxp close;

proc ttest data=five   ;
var age  ses  animals   ;
class demind;
run;

*-- average visits --*; 
proc ttest data=animals  ;
var visit_n  ;
class demind;
run;


*-- ANIMAL OUTCOME DESCRIPTIVES --*;
*-- baseline outcome scores --*; 
proc univariate data=first plots;
class demind;
var  animals  ;
histogram;
run; 

/*overall the outcome @baseline looks good and satisfies assumptions */

*-- SPAGHETTI PLOTS --*; 
proc sgplot data=mci2;
title 'Spagehetti Plot of Wechsler Memory Scale Logical Memory I Story A ';
series x=age y=logmemI / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=mci2;
title 'Spagehetti Plot of Wechsler Memory Scale Logical Memory II Story A ';
series x=age y=logmemII / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=animal;
title 'Category fluency for animals';
series x=age y=animals / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=mci2;
title 'Wechsler Adult Intelligence Scale-Revised Block Design';
series x=age y=blockR / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

/* plots show unique intercepts and slopes for each participant, but overall there is a
decrease with age and demind has lower scores */