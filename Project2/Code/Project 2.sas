**********************************************************************************;
*	PROGRAM NAME: Project 2 BIOS6623 code										 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Find VA hospitals with low or high death rates compared to adjusted *;
**********************************************************************************;

%let va='/folders/myfolders/bios6623-delgoulding/Project2/Code/vadata2.sas7bdat';
%let yr1_1=34;
%let yr1_2=35;
%let yr2_1=36;
%let yr2_2=37;
%let yr3_1=38;
%let final=39;

*--Data set is SAS so no need to import --*;
Data va;
set &va;
if proced >= 2 then delete; /* delete 2 procedures */
run;

proc contents data=va;
run;

data va;
set va;
if sixmonth=&final then ratefinal = 1;
if &yr1_1<=sixmonth<=&yr3_1 then ratefinal=0;
run;

proc freq data=va;
tables ratefinal*(sixmonth proced hospcode); /*4424 this 6month, 26000 ish total*/
run;

proc means data=va  n nmiss mean std q1 q3 p50 min max median t probt;
where sixmonth=&final;
run; /*bmi has some extreme values maybe*/
proc print data=va;
where proced = . and sixmonth=&final ;
var hospcode proced sixmonth death30;
run;

data va;
set va;
bmic = weight/(height**2)*703; /*create a new BMI variables*/
run;

data va;
set va;
bmi_dif = bmi - bmic; /*create a delta to determine how different the bmis are*/
run;

proc print data=va ;
where bmi_dif >1; /*decided that a difference of 1 might narrow down*/
var hospcode bmi bmi2 height weight bmi_dif sixmonth; /*there are some BMIs that went drastically down, all BMIs are off a little?*/
run;
*--1592 BMIs changed greater than 1 point, all in sixmonth 39--*;
proc freq data=va;
where bmi_dif >1;
tables hospcode*(bmi bmi2 bmi_dif); /*there are some BMIs that went drastically down*/
run;
proc means data=va mean ;
where bmi_dif >1;
class hospcode;
var bmi bmi2; /*1-16 almost 100 BMIS change and two hospitals had etreme values that were good*/
run;
data va;
set va;
if bmi >65 then bmi2=bmic;
else bmi2=bmi;
run;
proc univariate data=va plots;
class hospcode;
var weight; /*1-16 almost 100 BMIS change and two hospitals had etreme values that were good*/
run;
*--summary of bmi error by section and hospital--*;
proc freq data=va;
tables hospcode death30 asa proced sixmonth; /*44 hospitals, death30 not missing*/
run;

proc freq data=va;
tables hospcode*(death30)/chisq;
where sixmonth=&first_yr1;
run;

proc univariate plots data=va;
class ratefinal;
var death30 asa proced albumin;
histogram death30 asa proced albumin;
run;

proc sql;
create table va_demog as
select hospcode
	,proced 
	,death30
	,asa
	,albumin
	,sixmonth
from va ;
quit;
run;

data va;
set va;
array h {*} ;
do i = 1 - 44;
 h(i) = (hospcode=i);
end;
drop i;
run;

data demograph_var;
set va;
drop proced
	,death30
	,asa
	,albumin
	,sixmonth
from va;
run;
proc contents data=cea_vars out=cea_vars (keep=name varnum) noprint;
run;
proc sort data=cea_vars out=cea_vars;
by varnum;
run;

*-- Create exposure table --*;
%macro exposure;
data _null_;
set cea_vars;
by varnum;
if first.varnum then do;
	i+1;
	call symputx('name'||left(put(i,2.)),name);
	call symputx('end',left(put(i,2.)));
end;
run;

%do i=1 %to &end;
proc sql;
create table &&name&i as
select "&&name&i" as var 
	,sum(&&name&i^= '' and localid NOTIN &casegr) as Comparison_Denominator
	,sum(&&name&i= 'Yes' and localid NOTIN &casegr )/sum(&&name&i^= '' and localid NOTIN &casegr) as Comparison_Rate format 8.2
	,sum(&&name&i^= '' and localid IN &casegr) as Case_Denominator
	,sum(&&name&i= 'Yes' and localid IN &casegr )/sum(&&name&i^= '' and localid IN &casegr) as Case_Rate format 8.2
	,(sum(&&name&i= 'Yes' and localid IN &casegr) * sum(&&name&i= 'No' and localid NOTIN &casegr))/(sum(&&name&i= 'No' and localid IN &casegr) * sum(&&name&i= 'Yes' and localid NOTIN &casegr))as Odds_Ratio format 8.2
from exposures;
quit;
%end;

data exposure ;
length var $22.;
set %do i=1 %to &end;
    &&name&i
  %end;;
run;
%mend;

%exposure;

*-- Export exposure table to Excel  --*;
ods tagsets.Excelxp file="J:\Programs\Enterics\FoodNet\Case Exposure Ascertainment\CEA_exposure_table.xls" style=analysis ;
options (sheet_label = 'Rate_Table');
;
proc print data=exposure;
run;
ods _all_ close;


data va;
set va;
array h{*} h1 - h44;
do i = 1 - 44;
 h(i) = (hospcode=i);
end;
drop i;
run;

*-- Create CEA variables and sort --*;
data hos_code;
set va;
keep hospcode ;
run;

*-- Create exposure table --*;
%macro deathrate;
data _null_;
set hos_code;
by hospcode;
if first.varnum then do;
	i+1;
end;
run;

%do i=1 %to &end;
proc sql;
create table &&name&i as
select "&&name&i" as var 
	,sum(death30 when sixmonth=&first_yr1 and &&name&i) as year1_6month 8.22
	,sum(death30 when sixmonth=&second_yr1 and &&name&i) as year1_12month 8.22
	,sum(death30 when sixmonth=&first_yr2 and &&name&i) as year2_6month 8.22
	,sum(death30 when sixmonth=&second_yr2 and &&name&i) as year2_12month 8.22
	,sum(death30 when sixmonth=&first_yr3 and &&name&i) as year3_6month 8.22
	,sum(death30 when sixmonth=&first_yr2 and &&name&i) as year3_final 8.22
from va;
quit;
%end;

data deathrate ;
length var $22.;
set %do i=1 %to &end;
    &&name&i
  %end;;
run;
%mend;

%deathrate;

*-- Export exposure table to Excel  --*;
ods tagsets.Excelxls file="C:/Users/delaynagoulding/Desktop/hospital" style=analysis ;
;
proc print data=deathrate;
run;
ods _all_ close;