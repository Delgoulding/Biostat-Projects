**********************************************************************************;
*	PROGRAM NAME: VA Descriptives- P2											 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Determine which VA hospitals have lower/higher observed MR			 *;
**********************************************************************************;

%let final=39;


*-- import data --*;
proc import dbms=xls out=va2                                                                                                      
datafile="/folders/myfolders/bios6623-delgoulding/Project2/Code/VA.xls";  /*location of data*/                                                                                            
getnames=YES;                                                                                                                           
run; 

*-- TABLE 1 DESCRIPTIVE STATSTICS --*;
*-- median, 25th, 75th percentiles bmi albumin by hospital--*;
ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project2/bmi.xls' /*location on computer for tables*/
STYLE=minimal;

title 'BMI by hospital';
proc means data=va2  n nmiss p50 q1 q3  ;
where sixmonth=&final;
var bmi2 ;
class hospcode;
run;
ods tagsets.excelxp close;

ODS TAGSETS.EXCELXP
file='/folders/myfolders/bios6623-delgoulding/Project2/albumin.xls' /*change location*/
STYLE=minimal;
title 'albumin by hospital';
proc means data=va2  n nmiss p50 q1 q3  ;
where sixmonth=&final;
var albumin ;
class hospcode;
run;
ods tagsets.excelxp close;

*-- median, 25, 75th overall --*;
proc means data=va2 n nmiss p50 q1 q3;
where sixmonth=&final;
var bmi albumin;
run;

*--frequency of asa and procedure--*;
title 'frequency of asa and procedures';
proc freq data=va2;
where sixmonth=&final;
tables asa proced  ;
run;

*--examining regression fit of covariates --*;
proc univariate plots data=va2;
class ratefinal;
var death30 asa proced albumin bmi2;
histogram death30 asa proced albumin bmi2;
run;

*--MISSING DATA ANALYSIS--*;
*-- look at amount missing per hospital, does one hospital have more missingness? --*;
*--asa missing--*;
data missing;
set va2; 
if asa NE '.' and death30=0 then missasa= 0; 
if asa= '.' and death30=0 then missasa= 1;
if asa NE '.' and death30=1 then missasa=2;
if asa= '.' and death30=1 then missasa= 3;
run;
title 'Percent missing asa per hospital';
proc freq data=missing;
where sixmonth=&final;
tables missasa missasa*hospcode /Chisq; /*very low percent missing 2.6%, no large percentage per hospital*/
run;
*-- bmi missing --*; 
data missing;
set missing; 
if bmi2 NE '.' and death30=0 then missb= 0; 
if bmi2= '.' and death30=0 then missb= 1;
if bmi2 NE '.' and death30=1 then missb=2;
if bmi2= '.' and death30=1 then missb= 3;
run;
title 'Percent missing bmi per hospital';
proc freq data=missing;
where sixmonth=&final;
tables missb missb*hospcode /Chisq; /*hospital 7 and 34, missing equally from both*/
run;
*-- procedures missing --*; 
data missing;
set missing; 
if proced NE '.' and death30=0 then missp= 0; 
if proced= '.' and death30=0 then missp= 1;
if proced NE '.' and death30=1 then missp=2;
if proced= '.' and death30=1 then missp= 3;
run;
title 'Percent missing procedure per hospital';
proc freq data=missing;
where sixmonth=&final;
tables missp missp*hospcode /Chisq; /*hospital 7 and 34, missing equally from both*/
run;
*-- albumin missing --*; 
data missing;
set missing; 
if albumin NE . and death30=0 then missa= 0; 
if albumin= . and death30=0 then missa= 1;
if albumin NE . and death30=1 then missa=2;
if albumin= . and death30=1 then missa= 3;
run;
proc univariate data=missing plots;
class hospcode;
var missa;
run; 
proc freq data=missing ;
where sixmonth=&final; 
tables missa missa*hospcode ; /*equally missing*/
run;
proc freq data=missing;
where sixmonth=&final;
tables missa*missp;
run;
proc freq data=missing;
where sixmonth=&final;
tables missa*asa; 
run;
data missing;
set missing;
if asa IN (1,2,3) then bhealth=0;
if asa IN (4,5) then bhealth=1;
run; 
proc freq data=missing;
where sixmonth=&final;
tables missa*bhealth; /*albumin missing not related to asa*/
run;
*--Is albumin a useful variable in determining mortality?--*;
proc sort data=missing;
by missa;
run;
proc boxplot data=missing;
plot albumin*missa;
run;
proc glm data=missing;
where sixmonth=&final;
class missa / ref=first;
model albumin=missa / solution;
run;

proc ttest data=missing;
where sixmonth=&final;
class death30;
var albumin;
run;
proc glm data=missing;
class death30  bhealth / ref=first;
model albumin=death30 bmi2  bhealth / solution;
run;

*--THE BEST HOSPITAL? --*;
data missing;
set missing;
if missasa = 0 then best=1;
if missasa = 2 then best=1;
if missb = 2 then best=1;
if missb = 0 then best=1;
if missp = 2 then best=1;
if missp = 0 then best=1;
else best= 0;
run;

ODS TAGSETS.EXCELXP 
file='/folders/myfolders/bios6623-delgoulding/Project2/besthosp.xls' /*location on computer for tables*/
STYLE=minimal;

title 'hospitals with low percent missing';
proc freq data=missing;
where sixmonth=&final;
tables best*hospcode /nocum norow nofreq nopercent;
run;
ods tagsets.excelxp close;


