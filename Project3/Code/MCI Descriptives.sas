**********************************************************************************;
*	PROGRAM NAME: MCI Descriptive Statistics									 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: What is happening with people's memory as they age & onset MCI		 *;
*	accelaration compared to normal aging process. 								 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=ad2                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/mci.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 


*-- looking at data for any extreme or missing values --*; 
proc means data=ad2 n nmiss min max q1 q3 mean median;
run;

proc sort data=ad2;
by id age;
run;

*-- create a baseline dataset to examine demographics --*; 
data base;
set ad2;
by id;
if first.id then output base;
run;

title 'Categorical @ Baseline';
proc freq data=base;
tables gender*demind/chisq;
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project3/table1.xls' /*location on computer for tables*/
STYLE=minimal;

title 'Continuous @ Baseline';
proc means data=base  n nmiss min max mean std t  probt ;
var age ageonset ses logmemI logmemII animals blockR ;
class demind;
run;
ods tagsets.excelxp close;


proc univariate data=base plots;
class demind;
var logmemI logmemII animals blockR demind age ageonset SES ;
histogram;
run; 
