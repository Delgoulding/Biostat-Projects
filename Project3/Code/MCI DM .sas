**********************************************************************************;
*	PROGRAM NAME: MCI Data Management											 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Examine MCI database for issues/corrections  						 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=mci                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/Project3Data.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 

*--examine data for outliers/missing data--*;
proc contents data=mci;
run;
proc means data=mci n nmiss min max q1 q3 mean median; 
run;
/*missing 1800 from all four outcomes, but there doesn't look to be extreme values
or a high amount of missing data, one person is missing SES so deleting that participant based on investigator request*/ 


*-- create and delete variables --*;
data mci;
set mci;
changept = max(0,age - ageonset +4); /*change point for rate of decline prior to mci*/
age_int = age-67;					/*intercept age for interpretation*/
age_onset = ageonset - 67;			/*intercept age onset for interpretation*/
if ses = '.' then delete; 			/*delete the missing ses*/
run;
data count;
set mci;
by id;
if first.id then visit_n = 0; visit_n + 1; /*visit number*/
run;

*-- CREATE DATASET FOR ANIMAL OUTCOME --*;
*--count visits & number outcomes to remove participants <3 animal outcomes--*;
proc sql;
create table mci2 as
select * 
,count(id) as total_visits
,count(animals) as total_animal
from count
group by id
order by id;
quit;


*-- SAVE THIS DATASET --*;
data animals;
set mci2;
if total_animal <3 then delete;
run;

