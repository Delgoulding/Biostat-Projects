**********************************************************************************;
*	PROGRAM NAME: MCI Descriptive Statistics									 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Descriptive of MCI/NO MCI participants' animal memory outcome		 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=animals                                                                                                   
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/animals.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 


*-- DESCRIPTIVE STATISTICS: TABLE 1 --*;
*-- create a baseline dataset to examine demographics --*; 
proc sort data=animals;
by id age;
run; 

data base;
set animals;
by id;
if first.id then output base; /*baseline*/
run;

data last;
set animals;
by id;
if last.id then output last; /*last visit*/
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

proc ttest data=base  ;
var age  ses  animals visit_n  ;
class demind;
run;


*-- look at demographic differences between MCI groups at last visit to get average time followed --*; 
proc ttest data=last  ;
var age  ses  animals visit_n  ;
class demind;
run;


*-- look at demographic differences between MCI groups after 10 years --*; 
proc sort data=animals;
by visit_n  ;
run;

data ten;
set animals;
by visit_n;
if visit_n=9 then output ten;
run;

title 'Categorical @ Baseline';
proc freq data=ten;
tables gender*demind/chisq; /*212 participants*/
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project3/table2.xls' /*location on computer for tables*/
STYLE=minimal;

title 'Continuous @ Baseline';
proc means data=ten  n nmiss min max mean std  ;
var age ageonset ses logmemI logmemII animals blockR  ;
class demind;
run;
ods tagsets.excelxp close;

proc ttest data=ten   ;
var age  ses  animals   ;
class demind;
run;

*-- average visits --*; 
proc ttest data=animal  ;
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
proc sgplot data=animals;
title 'Spagehetti Plot of Wechsler Memory Scale Logical Memory I Story A ';
series x=age y=logmemI / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=animals;
title 'Spagehetti Plot of Wechsler Memory Scale Logical Memory II Story A ';
series x=age y=logmemII / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=animals;
title 'Category fluency for animals';
series x=age y=animals / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=animals;
title 'Wechsler Adult Intelligence Scale-Revised Block Design';
series x=age y=blockR / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

/* plots show unique intercepts and slopes for each participant, but overall there is a
decrease with age and demind has lower scores */

*-- examining drop out --*;
proc sgplot data=last;
vbox total_visits / group=demind;
run;

proc print data=last;
where total_visits <11 and demind=0; /*demind0=51 compared to 15*/
var id total_visits;
run;