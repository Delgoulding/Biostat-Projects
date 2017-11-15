**********************************************************************************;
*	PROGRAM NAME: MCI Analysis													 *;
*	DATE CREATED: November 2017													 *;
*	LAST UPDATED: November 2017 												 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: What is happening with people's memory as they age & onset MCI		 *;
*	accelaration compared to normal aging process. 								 *;
**********************************************************************************;

*-- import data --*;
proc import dbms=xls out=p3                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project3/Code/mci.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run;

*-- LOGICAL MEMORY I ANALYSIS--*;
*-- make two datasets for greater than 3 --*;
proc sql;
create table logI as
select *, count(logmemI) as total_logmemI
from p3
group by id
order by id;
quit;

data logI;
set logI;
if total_logmemI <3 then delete;
run;

proc mixed data=logI;
class id demind gender /ref=first;
model logmemI= demind age ses gender demind*age / solution;
random intercept age / subject=id g gcorr v vcorr;
run; 

*-- LOGICAL MEMORY II ANALYSIS--*;
*-- make two datasets for greater than 3  --*;
proc sql;
create table logII as
select *, count(logmemII) as total_logmemII
from p3
group by id
order by id;
quit;

data logII;
set logII;
if total_logmemII <3 then delete;
run;

proc mixed data=logI;
class id demind gender /ref=first;
model logmemII= demind age ses gender demind*age / solution;
random intercept age / subject=id type=un g gcorr v vcorr;
run; 


*-- ANIMALS ANALYSIS--*;
*-- make two datasets for greater than 3 --*;
proc sql;
create table animalz as
select *, count(animals) as total_animal
from p3
group by id
order by id;
quit;

data animals;
set animalz;
if total_animal <3 then delete;
run;

proc mixed data=animals;
class id demind gender /ref=first;
model animals= demind age ses gender demind*age / solution;
random intercept age / subject=id type=un g gcorr v vcorr;
run; 


*-- Block ANALYSIS--*;
*-- make two datasets for greater than 3 --*;
proc sql;
create table block as
select *, count(blockR) as total_block
from p3
group by id
order by id;
quit;

data blockz;
set block;
if blockR <3 then delete;
run;

proc mixed data=blockz;
class id demind gender /ref=first;
model blockR= demind age ses gender demind*age / solution;
random intercept age / subject=id g gcorr v vcorr;
run; 


