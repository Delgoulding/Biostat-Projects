**********************************************************************************;
*	PROGRAM NAME: MCI Descriptive Statistics									 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: What is happening with people's memory as they age & onset MCI		 *;
*	accelaration compared to normal aging process. 								 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=mci2                                                                                                   
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/mci.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 


*-- create a baseline dataset to examine demographics --*; 
data first;
set mci2;
by id;
if first.id then output first;
run;

*-- DESCRIPTIVE STATISTICS: TABLE 1 --*;
*-- look at demographic differences between MCI group --*; 
title 'Categorical @ Baseline';
proc freq data=first;
tables gender*demind/chisq; /*213 participants*/
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project3/table1.xls' /*location on computer for tables*/
STYLE=minimal;

title 'Continuous @ Baseline';
proc means data=first  n nmiss min max mean std t  probt ;
var age ageonset ses logmemI logmemII animals blockR  ;
class demind;
run;
ods tagsets.excelxp close;

*-- average visits --*; 
proc means data=mci2  n nmiss min max mean std t  probt ;
var visit  ;
class demind;
run;

*-- baseline outcome scores --*; 
proc univariate data=first plots;
class demind;
var logmemI logmemII animals blockR ;
histogram;
run; 

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

proc sgplot data=mci2;
title 'Category fluency for animals';
series x=age y=animals / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

proc sgplot data=mci2;
title 'Wechsler Adult Intelligence Scale-Revised Block Design';
series x=age y=blockR / group=id grouplc=demind name='grouping';
keylegend 'grouping' / type=linecolor;
run;

*-- plots show unique intercepts and slopes for each participant, but overall there is a
decrease across visits --*;