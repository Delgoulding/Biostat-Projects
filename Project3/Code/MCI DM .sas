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

*--count visits & number outcomes to assist in selecting less than three--*;
proc sql;
create table mci as
select *, count(id) as total_visits
from ad
group by id
order by id;
quit;

data new2;
set mci;
if total_visits <2 then delete; /*drop participants with less than 3 visits*/ 
run;

*--examine data for outliers/missing data--*;
proc contents data=new2;
run;
proc means data=new2 n nmiss min max q1 q3 mean median; /*missing 1800 ish from all four outcomes. Nothing else looks too unusual*/ 
run;




