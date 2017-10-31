**********************************************************************************;
*	PROGRAM NAME: VA MR Analysis- P2											 *;
*	DATE CREATED: October 2017													 *;
*	LAST UPDATED: October 2017 													 *;
*	PROGRAMMER: DeLayna Goulding -Used code from Brian Hixon & Dan Taylor!! 	 *;
*	PURPOSE: Determine which VA hospitals have lower/higher observed MR			 *;
**********************************************************************************;


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