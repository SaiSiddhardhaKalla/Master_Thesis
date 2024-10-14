*********************************************************************************************************************************************************
cls
clear all
capture log close
set more off
pause on
#delimit ;
cd "/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/ma2020/" ; // home folder
#delimit cr
log using "xxx_dhs3.log", replace
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

timer clear
timer on 1

cls
clear all
import delimited "dhs3.csv", clear

set matsize 8000

label var all_weather_road "Share of Villages with Roads"
label var railway "Share of Villages with Railway"
label var bus "Share of Villages with Public Transport"
label var population "Population"
//label var med "Medical Facilities"
//label var edu "Educational Facilities"
//label var adm "Administrative Facilities"

label var subdistrictarea "Subdistrict Area"
//label var nearest_town_distance "Average Distance to Urban Centre"
label var phc "Primary Healthcare Centre"
label var mcwc "Maternal and Child Welfare Centre"
label var veterinary_hospital "Veterinary Hospital"
label var aanganwadi "Aanganwadi"

label var p_school "Primary School"
label var m_school "Middle School"
label var h_school "High School"
label var ssc_school "Senior Secondary School"
label var iti "Vocational Institute"

label var treated "Treatment"
label var period "2020"

encode district, gen(dist)
encode state, gen (states)
encode subdistrict, gen(subd)
encode gp, gen(gps)
encode unique_id, gen (gp_encode)
encode fertilitypreference, gen (fertility)
encode metwithananganwadiworkerashaorot, gen (asha)
encode highesteducationallevel, gen (edu)
//encode respondentworkedinlast12months, gen (work_lastyear)
//encode respondentworksforfamilyothersse, gen (work_where)
//encode respondentcurrentlyworking, gen (curr_work)
encode servicesfamilylifeeducation, gen (ser_famedu)
encode servicesfamilyplanning, gen (ser_famplan) 
encode servicesimmunization, gen (ser_immu) 
encode servicesantenatalcare, gen (ser_antenatal) 
encode servicesdeliverycare, gen (ser_deli) 
encode servicesbirthpreparedness, gen (ser_birthprep) 
encode servicespostnatalcare, gen (ser_postnatal) 
encode servicestreatmentforsickchild, gen (ser_sickkid) 
encode servicesearlychildhoodcare, gen (ser_earlychildcare) 
encode servicesgrowthmonitoringofchild, gen (ser_childgrowth) 
encode servicespreschooleducation, gen (ser_preschool) 
encode servicesnutritionhealtheducation, gen (ser_nutrition)
encode respondentworksforfamilyothersse, gen (who_work)
encode typeofemployment, gen (type_work)

global services ser_famplan ser_antenatal ser_postnatal 
			   
global services_all ser_famplan ser_immu ser_antenatal ser_deli  /// ser_preschool
			ser_postnatal ser_earlychildcare  

gen reg = 0
replace reg = 1 if region=="A"
label var reg "Region"




drop if missing(treated)
drop if missing(period)
drop if missing(fertility)

gen dob = 1 if respondentsyearofbirth >= 1989
replace dob = 0 if respondentsyearofbirth < 1989

gen age_2019 = 2019 - respondentsyearofbirth

//drop if age_2019>35
//drop if age_2019<19

**************************************************************************
**************************************************************************

//mlogit fertility i.treated##i.dob edu asha, base (2) vce(cluster gp_encode)
mlogit fertility i.treated##i.dob edu asha ///
				ser_famplan ser_antenatal, base (2) vce(cluster gp_encode)
	eststo full
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)
esttab using "Fertility_pref_IN.tex", ///
  title("MCWC impact on Fertility Preferences") ///
  label replace ///
  b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
  alignment(d{3.2}) ///
  compress
 
  
*****************************************
*****************************************
** Have another
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** No more
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** Sterelized
lincom _b[5._predict#2._at] - _b[5._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[5._predict#4._at] - _b[5._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** Undecided
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'

**************************************************************************
**************************************************************************

//mlogit fertility i.treated##i.dob if reg==0 , base (2)
mlogit fertility i.treated##i.dob edu asha  ///
				ser_famplan if reg==0 , base (2) vce(cluster gp_encode)			
	eststo NE
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)
esttab using "NE_Fertility_pref.tex", ///
  title("MCWC impact on Fertility Preferences") ///
  label replace ///
  b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
  alignment(d{3.2}) ///
  compress
  
*****************************************
*****************************************
** Have another
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean11 = r(estimate)
local se11 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean21 = r(estimate)
local se21 = r(se)
* Calculate the Difference
local difference1 = `mean21' - `mean11'
display "Difference: `difference1'"
* Calculate the Combined Standard Error
local se_combined1 = sqrt(`se21'^2 + `se11'^2)
display "Combined SE: `se_combined1'"
* Calculate the Z-Score
local z_score1 = `difference1' / `se_combined1'
display "Z-Score: `z_score1'"
* Calculate the Z-statistic
local z = (`mean21' - `mean11') / sqrt(`se21'^2 + `se11'^2)
display `z'
*****************************************
*****************************************
** No more
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean12 = r(estimate)
local se12 = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean22 = r(estimate)
local se22 = r(se)
* Calculate the Difference
local difference2 = `mean22' - `mean12'
display "Difference: `difference2'"
* Calculate the Combined Standard Error
local se_combined2 = sqrt(`se22'^2 + `se12'^2)
display "Combined SE: `se_combined2'"
* Calculate the Z-Score
local z_score2 = `difference2' / `se_combined2'
display "Z-Score: `z_score2'"
* Calculate the Z-statistic
local z = (`mean22' - `mean12') / sqrt(`se22'^2 + `se12'^2)
display `z'
*****************************************
*****************************************
** Sterelized
lincom _b[5._predict#2._at] - _b[5._predict#1._at]
local mean13 = r(estimate)
local se13 = r(se)
lincom _b[5._predict#4._at] - _b[5._predict#3._at]
local mean23 = r(estimate)
local se23 = r(se)
* Calculate the Difference
local difference3 = `mean23' - `mean13'
display "Difference: `difference3'"
* Calculate the Combined Standard Error
local se_combined3 = sqrt(`se23'^2 + `se13'^2)
display "Combined SE: `se_combined3'"
* Calculate the Z-Score
local z_score3 = `difference3' / `se_combined3'
display "Z-Score: `z_score3'"
* Calculate the Z-statistic
local z = (`mean23' - `mean13') / sqrt(`se23'^2 + `se13'^2)
display `z'
*****************************************
*****************************************
** Undecided
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean14 = r(estimate)
local se14 = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean24 = r(estimate)
local se24 = r(se)
* Calculate the Difference
local difference4 = `mean24' - `mean14'
display "Difference: `difference4'"
* Calculate the Combined Standard Error
local se_combined4 = sqrt(`se24'^2 + `se14'^2)
display "Combined SE: `se_combined4'"
* Calculate the Z-Score
local z_score4 = `difference4' / `se_combined4'
display "Z-Score: `z_score4'"
* Calculate the Z-statistic
local z = (`mean24' - `mean14') / sqrt(`se24'^2 + `se14'^2)
display `z'

**************************************************************************
**************************************************************************

//mlogit fertility i.treated##i.dob if reg==1 , base (2)
mlogit fertility i.treated##i.dob edu asha ser_famplan ///
			ser_antenatal  ///
			ser_postnatal  /// 
				 if reg==1 , base (2) vce(cluster gp_encode)
	eststo SW
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)
esttab using "SW_Fertility_pref.tex", ///
  title("MCWC impact on Fertility Preferences") ///
  label replace ///
  b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
  alignment(d{3.2}) ///
  compress
  
*****************************************
*****************************************
** Have another
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1a = r(estimate)
local se1a = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2a = r(estimate)
local se2a = r(se)
* Calculate the Difference
local difference_a = `mean2a' - `mean1a'
display "Difference: `difference_a'"
* Calculate the Combined Standard Error
local se_combined_a = sqrt(`se2a'^2 + `se1a'^2)
display "Combined SE: `se_combined_a'"
* Calculate the Z-Score
local z_score_a = `difference_a' / `se_combined_a'
display "Z-Score: `z_score_a'"
* Calculate the Z-statistic
local z = (`mean2a' - `mean1a') / sqrt(`se2a'^2 + `se1a'^2)
display `z'
*****************************************
*****************************************
** No more
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean1b = r(estimate)
local se1b = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean2b = r(estimate)
local se2b = r(se)
* Calculate the Difference
local difference_b = `mean2b' - `mean1b'
display "Difference: `difference_b'"
* Calculate the Combined Standard Error
local se_combined_b = sqrt(`se2b'^2 + `se1b'^2)
display "Combined SE: `se_combined_b'"
* Calculate the Z-Score
local z_score_b = `difference_b' / `se_combined_b'
display "Z-Score: `z_score_b'"
* Calculate the Z-statistic
local z = (`mean2b' - `mean1b') / sqrt(`se2b'^2 + `se1b'^2)
display `z'
*****************************************
*****************************************
** Sterelized
lincom _b[5._predict#2._at] - _b[5._predict#1._at]
local mean1c = r(estimate)
local se1c = r(se)
lincom _b[5._predict#4._at] - _b[5._predict#3._at]
local mean2c = r(estimate)
local se2c = r(se)
* Calculate the Difference
local difference_c = `mean2c' - `mean1c'
display "Difference: `difference_c'"
* Calculate the Combined Standard Error
local se_combined_c = sqrt(`se2c'^2 + `se1c'^2)
display "Combined SE: `se_combined_c'"
* Calculate the Z-Score
local z_score_c = `difference_c' / `se_combined_c'
display "Z-Score: `z_score_c'"
* Calculate the Z-statistic
local z = (`mean2c' - `mean1c') / sqrt(`se2c'^2 + `se1c'^2)
display `z'
*****************************************
*****************************************
** Undecided
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean1d = r(estimate)
local se1d = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean2d = r(estimate)
local se2d = r(se)
* Calculate the Difference
local difference_d = `mean2d' - `mean1d'
display "Difference: `difference_d'"
* Calculate the Combined Standard Error
local se_combined_d = sqrt(`se2d'^2 + `se1d'^2)
display "Combined SE: `se_combined_d'"
* Calculate the Z-Score
local z_score_d = `difference_d' / `se_combined_d'
display "Z-Score: `z_score_d'"
* Calculate the Z-statistic
local z = (`mean2d' - `mean1d') / sqrt(`se2d'^2 + `se1d'^2)
display `z'

**************************************************************************
**************************************************************************



** Have another
* Calculate the Difference
local differencei = `difference_a' - `difference1'
display "Difference: `differencei'"
* Calculate the Combined Standard Error
local se_combinedi = sqrt(`se_combined_a'^2 + `se_combined1'^2)
display "Combined SE: `se_combinedi'"
* Calculate the Z-Score
local z_scorei = `differencei' / `se_combinedi'
display "Z-Score: `z_scorei'"
* Calculate the Z-statistic
local z = (`difference_a' - `difference1') / sqrt(`se_combined_a'^2 + `se_combined1'^2)
display `z'

*****************************************
*****************************************
** No more
* Calculate the Difference
local differenceii = `difference_b' - `difference2'
display "Difference: `differenceii'"
* Calculate the Combined Standard Error
local se_combinedii = sqrt(`se_combined_b'^2 + `se_combined2'^2)
display "Combined SE: `se_combinedii'"
* Calculate the Z-Score
local z_scoreii = `differenceii' / `se_combinedii'
display "Z-Score: `z_scoreii'"
* Calculate the Z-statistic
local z = (`difference_b' - `difference2') / sqrt(`se_combined_b'^2 + `se_combined2'^2)
display `z'

*****************************************
*****************************************
** Sterelized
* Calculate the Difference
local differenceiii = `difference_c' - `difference3'
display "Difference: `differenceiii'"
* Calculate the Combined Standard Error
local se_combinediii = sqrt(`se_combined_c'^2 + `se_combined3'^2)
display "Combined SE: `se_combinediii'"
* Calculate the Z-Score
local z_scoreiii = `differenceiii' / `se_combinediii'
display "Z-Score: `z_scoreiii'"
* Calculate the Z-statistic
local z = (`difference_c' - `difference3') / sqrt(`se_combined_c'^2 + `se_combined3'^2)
display `z'

*****************************************
*****************************************
** Undecided
* Calculate the Difference
local differenceiiii = `difference_d' - `difference4'
display "Difference: `differenceiiii'"
* Calculate the Combined Standard Error
local se_combinediiii = sqrt(`se_combined_d'^2 + `se_combined4'^2)
display "Combined SE: `se_combinediiii'"
* Calculate the Z-Score
local z_scoreiiii = `differenceiiii' / `se_combinediiii'
display "Z-Score: `z_scoreiiii'"
* Calculate the Z-statistic
local z = (`difference_d' - `difference4') / sqrt(`se_combined_d'^2 + `se_combined4'^2)
display `z'

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************


gen work = .
replace work = 1 if respondentcurrentlyworking =="yes"
replace work = 0 if respondentcurrentlyworking =="no"
//replace work = . if respondentcurrentlyworking = .

preserve
drop if work==.
tab work
tab treated
tab dob
tab dob if work==1
tab dob if work==0



/*
logit work i.treated##i.dob asha edu $services, vce(cluster gp_encode)
margins treated, dydx(dob) pwcompare

logit work i.treated##i.dob asha edu $services if reg==0, vce(cluster gp_encode)
margins treated, dydx(dob) pwcompare

logit work i.treated##i.dob asha edu $services if reg ==1, vce(cluster gp_encode)
margins treated, dydx(dob) pwcompare
*/

logit work i.treated##i.dob asha edu $services, robust
margins treated, dydx(dob) pwcompare

logit work i.treated##i.dob asha edu $services if reg==1, robust
margins treated, dydx(dob) pwcompare

logit work i.treated##i.dob asha edu $services if reg ==0, robust
margins treated, dydx(dob) pwcompare


local differencework =  0.0319266 - ( -0.0090399) 
display "Difference: `differencework'"
* Calculate the Combined Standard Error
*local se_combinedwork = sqrt(0.0220501^2 + 0.0115321^2)
local se_combinedwork = sqrt(0.0188531^2 + 0.0094484^2)
display "Combined SE: `se_combinedwork'"
* Calculate the Z-Score
local z_scorework = `differencework' / `se_combinedwork'
display "Z-Score: `z_scorework'"


gen another = 0
replace another = 1 if fertilitypreference=="have another"

gen no_more = 0
replace no_more = 1 if fertilitypreference=="no more"

gen infecund = 0
replace infecund = 1 if fertilitypreference=="declared infecund"

gen sterilized = 0
replace sterilized = 1 if fertilitypreference=="sterilized (respondent or partner)"

gen undecided = 0
replace undecided = 1 if fertilitypreference=="undecided"

logit work another no_more sterilized undecided asha edu $services, vce(cluster gp_encode)

logit work another no_more sterilized undecided asha edu $services if reg==1, robust

logit work another no_more sterilized undecided asha edu $services if reg==0, robust



*****************************************
*****************************************

mlogit type_work i.treated##i.dob asha edu ser_famplan, base(4) vce(cluster subd)
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)

*****************************************
*****************************************
** For Agro
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Clerical
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Not Working
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Professional
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Sales
lincom _b[7._predict#2._at] - _b[7._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[7._predict#4._at] - _b[7._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For services/domestic
lincom _b[8._predict#2._at] - _b[8._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[8._predict#4._at] - _b[8._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For labour
lincom _b[9._predict#2._at] - _b[9._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[9._predict#4._at] - _b[9._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
**************************************************************************
**************************************************************************


mlogit type_work i.treated##i.dob asha edu ser_famplan if reg==1, base (4) vce(cluster subd)
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)

*****************************************
*****************************************
** For Agro
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean1a = r(estimate)
local se1a = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean2a = r(estimate)
local se2a = r(se)
* Calculate the Difference
local differencea = `mean2a' - `mean1a'
display "Difference: `differencea'"
* Calculate the Combined Standard Error
local se_combineda = sqrt(`se2a'^2 + `se1a'^2)
display "Combined SE: `se_combineda'"
* Calculate the Z-Score
local z_scorea = `differencea' / `se_combineda'
display "Z-Score: `z_scorea'"
* Calculate the Z-statistic
local z = (`mean2a' - `mean1a') / sqrt(`se2a'^2 + `se1a'^2)
display `z'
*****************************************
*****************************************
** For Clerical
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1b = r(estimate)
local se1b = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2b = r(estimate)
local se2b = r(se)
* Calculate the Difference
local differenceb = `mean2b' - `mean1b'
display "Difference: `difference'"
* Calculate the Combined Standarbd Error
local se_combinedb = sqrt(`se2b'^2 + `se1b'^2)
display "Combined SE: `se_combinedb'"
* Calculate the Z-Score
local z_scoreb = `differenceb' / `se_combinedb'
display "Z-Score: `z_scoreb'"
* Calculate the Z-statistic
local z = (`mean2b' - `mean1b') / sqrt(`se2b'^2 + `se1b'^2)
display `z'
*****************************************
*****************************************
** For Not Working
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean1c = r(estimate)
local se1c = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean2c = r(estimate)
local se2c = r(se)
* Calculate the Difference
local differencec = `mean2c' - `mean1c'
display "Difference: `differencec'"
* Calculate the Combined Standard Error
local se_combinedc = sqrt(`se2c'^2 + `se1c'^2)
display "Combined SE: `se_combinedc'"
* Calculate the Z-Score
local z_scorec = `differencec' / `se_combinedc'
display "Z-Score: `z_scorec'"
* Calculate the Z-statistic
local z = (`mean2c' - `mean1c') / sqrt(`se2c'^2 + `se1c'^2)
display `z'
*****************************************
*****************************************
** For Professional
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean1d = r(estimate)
local se1d = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean2d = r(estimate)
local se2d = r(se)
* Calculate the Difference
local differenced = `mean2d' - `mean1d'
display "Difference: `differenced'"
* Calculate the Combined Standard Error
local se_combinedd = sqrt(`se2d'^2 + `se1d'^2)
display "Combined SE: `se_combinedd'"
* Calculate the Z-Score
local z_scored = `differenced' / `se_combinedd'
display "Z-Score: `z_scored'"
* Calculate the Z-statistic
local z = (`mean2d' - `mean1d') / sqrt(`se2d'^2 + `se1d'^2)
display `z'
*****************************************
*****************************************
** For Sales
lincom _b[7._predict#2._at] - _b[7._predict#1._at]
local mean1e = r(estimate)
local se1e = r(se)
lincom _b[7._predict#4._at] - _b[7._predict#3._at]
local mean2e = r(estimate)
local se2e = r(se)
* Calculate the Difference
local differencee = `mean2e' - `mean1e'
display "Difference: `differencee'"
* Calculate the Combined Standard Error
local se_combinede = sqrt(`se2e'^2 + `se1e'^2)
display "Combined SE: `se_combinede'"
* Calculate the Z-Score
local z_scoree = `differencee' / `se_combinede'
display "Z-Score: `z_scoree'"
* Calculate the Z-statistic
local z = (`mean2e' - `mean1e') / sqrt(`se2e'^2 + `se1e'^2)
display `z'
*****************************************
*****************************************
** For services/domestic
lincom _b[8._predict#2._at] - _b[8._predict#1._at]
local mean1f = r(estimate)
local se1f = r(se)
lincom _b[8._predict#4._at] - _b[8._predict#3._at]
local mean2f = r(estimate)
local se2f = r(se)
* Calculate the Difference
local differencef = `mean2f' - `mean1f'
display "Difference: `differencef'"
* Calculate the Combined Standard Error
local se_combinedf = sqrt(`se2f'^2 + `se1f'^2)
display "Combined SE: `se_combinedf'"
* Calculate the Z-Score
local z_scoref = `differencef' / `se_combinedf'
display "Z-Score: `z_scoref'"
* Calculate the Z-statistic
local z = (`mean2f' - `mean1f') / sqrt(`se2f'^2 + `se1f'^2)
display `z'
*****************************************
*****************************************
** For labour
lincom _b[9._predict#2._at] - _b[9._predict#1._at]
local mean1g = r(estimate)
local se1g = r(se)
lincom _b[9._predict#4._at] - _b[9._predict#3._at]
local mean2g = r(estimate)
local se2g = r(se)
* Calculate the Difference
local differenceg = `mean2g' - `mean1g'
display "Difference: `differenceg'"
* Calculate the Combined Standard Error
local se_combinedg = sqrt(`se2g'^2 + `se1g'^2)
display "Combined SE: `se_combinedg'"
* Calculate the Z-Score
local z_scoreg = `differenceg' / `se_combinedg'
display "Z-Score: `z_scoreg'"
* Calculate the Z-statistic
local z = (`mean2g' - `mean1g') / sqrt(`se2g'^2 + `se1g'^2)
display `z'
**************************************************************************
**************************************************************************


mlogit type_work i.treated##i.dob asha edu ser_famplan if reg==0, base (4) vce(cluster subd)
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)

*****************************************
*****************************************
** For Agro
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean11 = r(estimate)
local se11 = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean21 = r(estimate)
local se21 = r(se)
* Calculate the Difference
local difference1 = `mean21' - `mean11'
display "Difference: `difference1'"
* Calculate the Combined Standard Error
local se_combined1 = sqrt(`se21'^2 + `se11'^2)
display "Combined SE: `se_combined1'"
* Calculate the Z-Score
local z_score1 = `difference1' / `se_combined1'
display "Z-Score: `z_score1'"
* Calculate the Z-statistic
local z = (`mean21' - `mean11') / sqrt(`se21'^2 + `se11'^2)
display `z'
*****************************************
*****************************************
** For Clerical
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean12 = r(estimate)
local se12 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean22 = r(estimate)
local se22 = r(se)
* Calculate the Difference
local difference2 = `mean22' - `mean12'
display "Difference: `difference2'"
* Calculate the Combined Standard Error
local se_combined2 = sqrt(`se22'^2 + `se12'^2)
display "Combined SE: `se_combined2'"
* Calculate the Z-Score
local z_score2 = `difference2' / `se_combined2'
display "Z-Score: `z_score2'"
* Calculate the Z-statistic
local z = (`mean22' - `mean12') / sqrt(`se22'^2 + `se12'^2)
display `z'
*****************************************
*****************************************
** For Not Working
lincom _b[4._predict#2._at] - _b[4._predict#1._at]
local mean13 = r(estimate)
local se13 = r(se)
lincom _b[4._predict#4._at] - _b[4._predict#3._at]
local mean23 = r(estimate)
local se23 = r(se)
* Calculate the Difference
local difference3 = `mean23' - `mean13'
display "Difference: `difference3'"
* Calculate the Combined Standard Error
local se_combined3 = sqrt(`se23'^2 + `se13'^2)
display "Combined SE: `se_combined3'"
* Calculate the Z-Score
local z_score3 = `difference3' / `se_combined3'
display "Z-Score: `z_score3'"
* Calculate the Z-statistic
local z = (`mean23' - `mean13') / sqrt(`se23'^2 + `se13'^2)
display `z'
*****************************************
*****************************************
** For Professional
lincom _b[6._predict#2._at] - _b[6._predict#1._at]
local mean14 = r(estimate)
local se14 = r(se)
lincom _b[6._predict#4._at] - _b[6._predict#3._at]
local mean24 = r(estimate)
local se24 = r(se)
* Calculate the Difference
local difference4 = `mean24' - `mean14'
display "Difference: `difference4'"
* Calculate the Combined Standard Error
local se_combined4 = sqrt(`se24'^2 + `se14'^2)
display "Combined SE: `se_combined4'"
* Calculate the Z-Score
local z_score4 = `difference4' / `se_combined4'
display "Z-Score: `z_score4'"
* Calculate the Z-statistic
local z = (`mean24' - `mean14') / sqrt(`se24'^2 + `se14'^2)
display `z'
*****************************************
*****************************************
** For Sales
lincom _b[7._predict#2._at] - _b[7._predict#1._at]
local mean15 = r(estimate)
local se15 = r(se)
lincom _b[7._predict#4._at] - _b[7._predict#3._at]
local mean25 = r(estimate)
local se25 = r(se)
* Calculate the Difference
local difference5 = `mean25' - `mean15'
display "Difference: `difference5'"
* Calculate the Combined Standard Error
local se_combined5 = sqrt(`se25'^2 + `se15'^2)
display "Combined SE: `se_combined5'"
* Calculate the Z-Score
local z_score5 = `difference5' / `se_combined5'
display "Z-Score: `z_score5'"
* Calculate the Z-statistic
local z = (`mean25' - `mean15') / sqrt(`se25'^2 + `se15'^2)
display `z'
*****************************************
*****************************************
** For services/domestic
lincom _b[8._predict#2._at] - _b[8._predict#1._at]
local mean16 = r(estimate)
local se16 = r(se)
lincom _b[8._predict#4._at] - _b[8._predict#3._at]
local mean26 = r(estimate)
local se26 = r(se)
* Calculate the Difference
local difference6 = `mean26' - `mean16'
display "Difference: `difference6'"
* Calculate the Combined Standard Error
local se_combined6 = sqrt(`se26'^2 + `se16'^2)
display "Combined SE: `se_combined6'"
* Calculate the Z-Score
local z_score6 = `difference6' / `se_combined6'
display "Z-Score: `z_score6'"
* Calculate the Z-statistic
local z = (`mean26' - `mean16') / sqrt(`se26'^2 + `se16'^2)
display `z'
*****************************************
*****************************************
** For labour
lincom _b[9._predict#2._at] - _b[9._predict#1._at]
local mean17 = r(estimate)
local se17 = r(se)
lincom _b[9._predict#4._at] - _b[9._predict#3._at]
local mean27 = r(estimate)
local se27 = r(se)
* Calculate the Difference
local difference7 = `mean27' - `mean17'
display "Difference: `difference7'"
* Calculate the Combined Standard Error
local se_combined7 = sqrt(`se27'^2 + `se17'^2)
display "Combined SE: `se_combined7'"
* Calculate the Z-Score
local z_score7 = `difference7' / `se_combined7'
display "Z-Score: `z_score7'"
* Calculate the Z-statistic
local z = (`mean27' - `mean17') / sqrt(`se27'^2 + `se17'^2)
display `z'

**************************************************************************
**************************************************************************


** For Agro
* Calculate the Difference
local differencei = `differencea' - `difference1'
display "Difference: `differencei'"
* Calculate the Combined Standard Error
local se_combinedi = sqrt(`se_combineda'^2 + `se_combined1'^2)
display "Combined SE: `se_combinedi'"
* Calculate the Z-Score
local z_scorei = `differencei' / `se_combinedi'
display "Z-Score: `z_scorei'"
* Calculate the Z-statistic
local z = (`differencea' - `difference1') / sqrt(`se_combineda'^2 + `se_combined1'^2)
display `z'

*****************************************
*****************************************
** For Clerical
* Calculate the Difference
local differenceii = `differenceb' - `difference2'
display "Difference: `differenceii'"
* Calculate the Combined Standard Error
local se_combinedii = sqrt(`se_combinedb'^2 + `se_combined2'^2)
display "Combined SE: `se_combinedii'"
* Calculate the Z-Score
local z_scoreii = `differenceii' / `se_combinedii'
display "Z-Score: `z_scoreii'"
* Calculate the Z-statistic
local z = (`differenceb' - `difference2') / sqrt(`se_combinedb'^2 + `se_combined2'^2)
display `z'

*****************************************
*****************************************
** For Not work
* Calculate the Difference
local differenceiii = `differencec' - `difference3'
display "Difference: `differenceiii'"
* Calculate the Combined Standard Error
local se_combinediii = sqrt(`se_combinedc'^2 + `se_combined3'^2)
display "Combined SE: `se_combinediii'"
* Calculate the Z-Score
local z_scoreiii = `differenceiii' / `se_combinediii'
display "Z-Score: `z_scoreiii'"
* Calculate the Z-statistic
local z = (`differencec' - `difference3') / sqrt(`se_combinedc'^2 + `se_combined3'^2)
display `z'
*****************************************
*****************************************
** For Professional
* Calculate the Difference
local differenceii = `differenced' - `difference4'
display "Difference: `differenceii'"
* Calculate the Combined Standard Error
local se_combinedii = sqrt(`se_combinedd'^2 + `se_combined4'^2)
display "Combined SE: `se_combinedii'"
* Calculate the Z-Score
local z_scoreii = `differenceii' / `se_combinedii'
display "Z-Score: `z_scoreii'"
* Calculate the Z-statistic
local z = (`differenced' - `difference4') / sqrt(`se_combinedd'^2 + `se_combined4'^2)
display `z'

*****************************************
*****************************************
** For Sales
* Calculate the Difference
local differenceiii = `differencee' - `difference5'
display "Difference: `differenceiii'"
* Calculate the Combined Standard Error
local se_combinediii = sqrt(`se_combinede'^2 + `se_combined5'^2)
display "Combined SE: `se_combinediii'"
* Calculate the Z-Score
local z_scoreiii = `differenceiii' / `se_combinediii'
display "Z-Score: `z_scoreiii'"
* Calculate the Z-statistic
local z = (`differencee' - `difference5') / sqrt(`se_combinede'^2 + `se_combined5'^2)
display `z'

*****************************************
*****************************************
** For services/domestic
* Calculate the Difference
local differenceii = `differencef' - `difference6'
display "Difference: `differenceii'"
* Calculate the Combined Standard Error
local se_combinedii = sqrt(`se_combinedf'^2 + `se_combined6'^2)
display "Combined SE: `se_combinedii'"
* Calculate the Z-Score
local z_scoreii = `differenceii' / `se_combinedii'
display "Z-Score: `z_scoreii'"
* Calculate the Z-statistic
local z = (`differencef' - `difference6') / sqrt(`se_combinedf'^2 + `se_combined6'^2)
display `z'

*****************************************
*****************************************
** For labour
* Calculate the Difference
local differenceiii = `differenceg' - `difference7'
display "Difference: `differenceiii'"
* Calculate the Combined Standard Error
local se_combinediii = sqrt(`se_combinedg'^2 + `se_combined7'^2)
display "Combined SE: `se_combinediii'"
* Calculate the Z-Score
local z_scoreiii = `differenceiii' / `se_combinediii'
display "Z-Score: `z_scoreiii'"
* Calculate the Z-statistic
local z = (`differenceg' - `difference7') / sqrt(`se_combinedg'^2 + `se_combined7'^2)
display `z'

**************************************************************************
**************************************************************************

restore

**************************************************************************
**************************************************************************  

* Stop timer 1
timer off 1

* Display and log the time taken
timer list 1
  
log close

/*

*****************************************
*****************************************
** For Family
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Others
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'
*****************************************
*****************************************
** For Self
lincom _b[3._predict#2._at] - _b[3._predict#1._at]
local mean1 = r(estimate)
local se1 = r(se)
lincom _b[3._predict#4._at] - _b[3._predict#3._at]
local mean2 = r(estimate)
local se2 = r(se)
* Calculate the Difference
local difference = `mean2' - `mean1'
display "Difference: `difference'"
* Calculate the Combined Standard Error
local se_combined = sqrt(`se2'^2 + `se1'^2)
display "Combined SE: `se_combined'"
* Calculate the Z-Score
local z_score = `difference' / `se_combined'
display "Z-Score: `z_score'"
* Calculate the Z-statistic
local z = (`mean2' - `mean1') / sqrt(`se2'^2 + `se1'^2)
display `z'

**************************************************************************
**************************************************************************



mlogit type_work i.treated##i.dob asha edu ser_famplan ser_postnatal if reg==0, base (4) vce(cluster subd)
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)

*****************************************
*****************************************
** For Family
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean1a = r(estimate)
local se1a = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean2a = r(estimate)
local se2a = r(se)
* Calculate the Difference
local difference_a = `mean2a' - `mean1a'
display "Difference: `difference_a'"
* Calculate the Combined Standard Error
local se_combined_a = sqrt(`se2a'^2 + `se1a'^2)
display "Combined SE: `se_combined_a'"
* Calculate the Z-Score
local z_score_a = `difference_a' / `se_combined_a'
display "Z-Score: `z_score_a'"
* Calculate the Z-statistic
local z = (`mean2a' - `mean1a') / sqrt(`se2a'^2 + `se1a'^2)
display `z'
*****************************************
*****************************************
** For Others
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean1b = r(estimate)
local se1b = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean2b = r(estimate)
local se2b = r(se)
* Calculate the Difference
local difference_b = `mean2b' - `mean1b'
display "Difference: `difference_b'"
* Calculate the Combined Standard Error
local se_combined_b = sqrt(`se2b'^2 + `se1b'^2)
display "Combined SE: `se_combined_b'"
* Calculate the Z-Score
local z_score_b = `difference_b' / `se_combined_b'
display "Z-Score: `z_score_b'"
* Calculate the Z-statistic
local z = (`mean2b' - `mean1b') / sqrt(`se2b'^2 + `se1b'^2)
display `z'
*****************************************
*****************************************
** For Self
lincom _b[3._predict#2._at] - _b[3._predict#1._at]
local mean1c = r(estimate)
local se1c = r(se)
lincom _b[3._predict#4._at] - _b[3._predict#3._at]
local mean2c = r(estimate)
local se2c = r(se)
* Calculate the Difference
local difference_c = `mean2c' - `mean1c'
display "Difference: `difference_c'"
* Calculate the Combined Standard Error
local se_combined_c = sqrt(`se2c'^2 + `se1c'^2)
display "Combined SE: `se_combined_c'"
* Calculate the Z-Score
local z_score_c = `difference_c' / `se_combined_c'
display "Z-Score: `z_score_c'"
* Calculate the Z-statistic
local z = (`mean2c' - `mean1c') / sqrt(`se2c'^2 + `se1c'^2)
display `z'

**************************************************************************
**************************************************************************


mlogit type_work i.treated##i.dob asha edu ser_famplan ser_postnatal if reg==1, base (4) vce(cluster subd)
margins, at(dob=(0 1) treated=(0 1)) post
matrix list e(b)

*****************************************
*****************************************
** For Family
lincom _b[1._predict#2._at] - _b[1._predict#1._at]
local mean11 = r(estimate)
local se11 = r(se)
lincom _b[1._predict#4._at] - _b[1._predict#3._at]
local mean21 = r(estimate)
local se21 = r(se)
* Calculate the Difference
local difference1 = `mean21' - `mean11'
display "Difference: `difference1'"
* Calculate the Combined Standard Error
local se_combined1 = sqrt(`se21'^2 + `se11'^2)
display "Combined SE: `se_combined1'"
* Calculate the Z-Score
local z_score1 = `difference1' / `se_combined1'
display "Z-Score: `z_score1'"
* Calculate the Z-statistic
local z = (`mean21' - `mean11') / sqrt(`se21'^2 + `se11'^2)
display `z'
*****************************************
*****************************************
** For Others
lincom _b[2._predict#2._at] - _b[2._predict#1._at]
local mean12 = r(estimate)
local se12 = r(se)
lincom _b[2._predict#4._at] - _b[2._predict#3._at]
local mean22 = r(estimate)
local se22 = r(se)
* Calculate the Difference
local difference2 = `mean22' - `mean12'
display "Difference: `difference2'"
* Calculate the Combined Standard Error
local se_combined2 = sqrt(`se22'^2 + `se12'^2)
display "Combined SE: `se_combined2'"
* Calculate the Z-Score
local z_score2 = `difference2' / `se_combined2'
display "Z-Score: `z_score2'"
* Calculate the Z-statistic
local z = (`mean22' - `mean12') / sqrt(`se22'^2 + `se12'^2)
display `z'
*****************************************
*****************************************
** For Self
lincom _b[3._predict#2._at] - _b[3._predict#1._at]
local mean13 = r(estimate)
local se13 = r(se)
lincom _b[3._predict#4._at] - _b[3._predict#3._at]
local mean23 = r(estimate)
local se23 = r(se)
* Calculate the Difference
local difference3 = `mean23' - `mean13'
display "Difference: `difference3'"
* Calculate the Combined Standard Error
local se_combined3 = sqrt(`se23'^2 + `se13'^2)
display "Combined SE: `se_combined3'"
* Calculate the Z-Score
local z_score3 = `difference3' / `se_combined3'
display "Z-Score: `z_score3'"
* Calculate the Z-statistic
local z = (`mean23' - `mean13') / sqrt(`se23'^2 + `se13'^2)
display `z'

**************************************************************************
**************************************************************************


** For Family
* Calculate the Difference
local differencei = `difference_a' - `difference1'
display "Difference: `differencei'"
* Calculate the Combined Standard Error
local se_combinedi = sqrt(`se_combined_a'^2 + `se_combined1'^2)
display "Combined SE: `se_combinedi'"
* Calculate the Z-Score
local z_scorei = `differencei' / `se_combinedi'
display "Z-Score: `z_scorei'"
* Calculate the Z-statistic
local z = (`difference_a' - `difference1') / sqrt(`se_combined_a'^2 + `se_combined1'^2)
display `z'

*****************************************
*****************************************
** For Others
* Calculate the Difference
local differenceii = `difference_b' - `difference2'
display "Difference: `differenceii'"
* Calculate the Combined Standard Error
local se_combinedii = sqrt(`se_combined_b'^2 + `se_combined2'^2)
display "Combined SE: `se_combinedii'"
* Calculate the Z-Score
local z_scoreii = `differenceii' / `se_combinedii'
display "Z-Score: `z_scoreii'"
* Calculate the Z-statistic
local z = (`difference_b' - `difference2') / sqrt(`se_combined_b'^2 + `se_combined2'^2)
display `z'

*****************************************
*****************************************
** For Self
* Calculate the Difference
local differenceiii = `difference_c' - `difference3'
display "Difference: `differenceiii'"
* Calculate the Combined Standard Error
local se_combinediii = sqrt(`se_combined_c'^2 + `se_combined3'^2)
display "Combined SE: `se_combinediii'"
* Calculate the Z-Score
local z_scoreiii = `differenceiii' / `se_combinediii'
display "Z-Score: `z_scoreiii'"
* Calculate the Z-statistic
local z = (`difference_c' - `difference3') / sqrt(`se_combined_c'^2 + `se_combined3'^2)
display `z'


**************************************************************************
**************************************************************************
*/
