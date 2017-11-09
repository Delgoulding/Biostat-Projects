**********************************************************************************;
*	PROGRAM NAME: AD Data Management- P3										 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: What is happening with people's memory as they age & with there onset*;
*	accelaration compared to normal aging process. 								 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=ad                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/Project3Data.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 

proc means data=ad n nmiss min max q1 q3 mean median;
run;

proc univariate data=ad plots;
class id;
var logmemI logmemII animals blockR;
run; 

proc freq data=ad; /*389 subjects*/
tables demind*id;
run;