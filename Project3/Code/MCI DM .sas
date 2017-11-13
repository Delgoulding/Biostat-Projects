**********************************************************************************;
*	PROGRAM NAME: MCI Data Management											 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: What is happening with people's memory as they age & onset MCI		 *;
*	accelaration compared to normal aging process. 								 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=ad                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/Project3Data.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 

*-- create a visit variable/ 0=baseline --*;
data ad;
set ad;
by id;
if first.id then visit= 0;
else visit + 1;
run;

*--examine data for outliers/missing data--*;
proc contents data=ad;
run;
proc means data=ad n nmiss min max q1 q3 mean median; /*missing 1800 ish from all four outcomes. Nothing else looks too unusual*/ 
run;


