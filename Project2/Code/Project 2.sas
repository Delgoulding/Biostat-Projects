**********************************************************************************;
*	PROGRAM NAME: Project 2 BIOS6623 code										 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding	                            				 *;
*	PURPOSE: Data management													 *;
**********************************************************************************;
*--Macros --*;
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
if proced >= 2 then delete; /* delete procedures that are not 1 or 2 */
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
where bmi_dif >=1; /*decided that a difference of 1 might narrow down*/
var hospcode bmi bmic height weight bmi_dif sixmonth; /*there are some BMIs that went drastically down, all BMIs are off a little?*/
run;
proc print data=va ;
where bmi_dif <=.05 and sixmonth=&final; /*two or three that did not change per hospital were missing*/
var hospcode bmi bmic height weight bmi_dif sixmonth; /*there are some BMIs that went drastically down, all BMIs are off a little?*/
run;
proc freq data=va;
table hospcode*death30;
where sixmonth=&final;
run;
*--1592 BMIs changed greater than 1 point, all in sixmonth 39--*;
proc freq data=va;
where bmi_dif >1;
tables hospcode*(bmi bmic bmi_dif); /*there are some BMIs that went drastically down*/
run;
proc means data=va mean ;
where bmi_dif <=0.5 and sixmonth=&final;
class hospcode;
var bmi bmic; /*1-16 almost 100 BMIS change and two hospitals had etreme values that were good*/
run;
data va;
set va;
if bmi_dif >=.05 then bmi2=bmic;
else bmi2=bmi;
run;

proc means data=va;
where sixmonth=&final;
var albumin bmi2;
run;

proc means data=va  n nmiss mean std q1 q3 p50 min max median t probt;
where sixmonth=&final;
var bmi2 albumin;
class hospcode;
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
where sixmonth=&final;
tables hospcode*(death30)/chisq fisher;
run;


proc freq data=va_delete;
tables hospcode*(death30)/chisq;
where sixmonth=&final;
run;

proc univariate plots data=va;
class ratefinal;
var death30 asa proced albumin bmi2;
histogram death30 asa proced albumin bmi2;
run;

/* Model 1: Logistic Regression with all covariates. Want to compare predicted values with albumin model v. without. ASA is creating a lot of noise, to adjust for this will collapse the categories. */
proc logistic data=va plots=all;
    class proced asa;
    model death30 (event='1')=proced asa albumin BMI2 / cl;
    OUTPUT OUT=work.predicted PREDICTED=ESTPROB L=LOWER95 U=UPPER95;
    run;
    
/*Run a model without albumin and compare predicted probabilites */

/* Model 2: Logisitic Regression without albumin. Compare predicted values with model 1 */
proc logistic data=va    class proced asa;
    model death30 (event='1')=proced asa albumin BMI2 / cl;
    OUTPUT OUT=work.predicted PREDICTED=ESTPROB L=LOWER95 U=UPPER95;
    run;

/* Determine which groups to combine in ASA */
proc freq data=WORK.ANALYSIS;
    tables asa / plots=(freqplot cumfreqplot);
    weight death30;
run;


data va;
set va;
if asa<4 then NEWasa=1;
if asa => 4 then NEWasa=2;
run;


/* Model 3: Logistic Regression without albumin and dichotomized ASA*/
proc logistic data=va plots=all;
    class proced NEWasa;
    model death30 (event='1')=proced NEWasa BMI2 / cl;
    OUTPUT OUT=work.predicted PREDICTED=ESTPROB L=LOWER95 U=UPPER95;
    run;


proc logistic data = va;
class proced(ref="0") newasa / param=ref;
model death30 (event = "1") = BMI2 proced newasa albumin/ covb;
run;

/* model without albumin*/
proc logistic data = va;
class proced(ref="0") newasa (ref="1") / param=ref;
model death30 (event = "1") = BMI2 proced newasa/ covb;
output out = expected predicted = exp;
run;

/*creates dataset with previous 5 periods*/
data expected;
set expected;
if sixmonth lt '39';
run;

/*expected rate by hospital*/
proc means data = expected mean stderr;
class hospcode;
var exp;
run;

data final;
set va;
if sixmonth = '39';
run;

proc freq data=final;
tables death30*hospcode / out = observed outpct;
run;

proc ttest data=va ; /*no bias?*/
class death30;
var albumin ;
run;




