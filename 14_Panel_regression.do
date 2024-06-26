*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
cls
clear all
capture log close
set more off
pause on
#delimit ;
cd "/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/ma2020/" ; // home folder
#delimit cr
log using "011_Panel.log", replace
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************


//import delimited "Panel.csv", clear // 
import delimited "Panel_Raw.csv", clear // This is main file
//import delimited "Panel_Clean.csv", clear // 
//import delimited "Panel_Raw_change.csv", clear //
//import delimited "Panel_Clean_change.csv", clear // 


set matsize 8000

label var num "Number of Villages"
label var share_roads "Share of Villages with Roads"
label var share_rails "Share of Villages with Railway"
label var share_pubtn "Share of Villages with Public Transport"
label var population "Population"
label var med "Medical Facilities"
label var edu "Educational Facilities"
label var adm "Administrative Facilities"
label var med_per_1000 "Medical Facilities per 1000 people"
label var edu_per_1000 "Educational Facilities per 1000 people"
label var adm_per_1000 "Administrative Facilities per 1000 people"
label var subdistrictarea "Subdistrict Area"
label var nearest_town_distance "Average Distance to Urban Centre"
label var phc "Primary Healthcare Centre"
label var mcwc "Maternal and Child Welfare Centre"
label var veterinary_hospital "Veterinary Hospital"
label var aanganwadi "Aanganwadi"
label var phc_per_1000 "Primary Healthcare Centre per 1000 people"
label var mcwc_per_1000 "Maternal and Child Welfare Centre per 1000 people"
label var vet_per_1000 "Veterinary Hospital per 1000 people"
label var aanganwadi_per_1000 "Aanganwadi per 1000 people"
label var p_school "Primary School"
label var m_school "Middle School"
label var h_school "High School"
label var ssc_school "Senior Secondary School"
label var iti "Vocational Institute"
label var p_sch_per_1000 "Primary School per 1000 people"
label var m_sch_per_1000 "Middle School per 1000 people"
label var h_sch_per_1000 "High School per 1000 people"
label var ssc_sch_per_1000 "Senior Secondary School per 1000 people"      
label var iti_per_1000 "Vocational Institute per 1000 people"      

		 
	
keep if alesina >0
bysort unique_id: gen count = _N
* Drop values that occur only once
drop if count == 1
* Drop the count variable as it's no longer needed
drop count


gen zone = ""
replace zone = "South" if state == "ANDHRA PRADESH"
replace zone = "East" if state == "ASSAM"
replace zone = "East" if state == "BIHAR"
replace zone = "Central" if state == "CHHATTISGARH"
replace zone = "West" if state == "GOA"
replace zone = "West" if state == "GUJARAT"
replace zone = "North" if state == "HARYANA"
replace zone = "East" if state == "JHARKHAND"
replace zone = "South" if state == "KARNATAKA"
replace zone = "South" if state == "KERALA"
replace zone = "Central" if state == "MADHYA PRADESH"
replace zone = "West" if state == "MAHARASHTRA"
replace zone = "East" if state == "ODISHA"
replace zone = "North" if state == "PUNJAB"
replace zone = "North" if state == "RAJASTHAN"
replace zone = "South" if state == "TAMIL NADU"
replace zone = "South" if state == "TELANGANA"
replace zone = "East" if state == "TRIPURA"
replace zone = "Central" if state == "UTTAR PRADESH"
replace zone = "Central" if state == "UTTARAKHAND"
replace zone = "East" if state == "WEST BENGAL"

//keep if num>2
drop if year==2017

global inf share_roads share_pubtn  
global con num subdistrictarea nearest_town_distance //village_area_sqkm
global med phc mcwc veterinary_hospital aanganwadi
global edu p_school m_school h_school ssc_school iti
global edu_access p_sch_per_1000 m_sch_per_1000 h_sch_per_1000 ///
		ssc_sch_per_1000 iti_per_1000
global med_access phc_per_1000 mcwc_per_1000 vet_per_1000 aanganwadi_per_1000 


gen edu2 = p_school + m_school + h_school + ssc_school + iti
gen med2 = phc + aanganwadi + veterinary_hospital
gen adm2 = cooperative_bank + mandis + post_office

gen edu2_per1000 = edu2/no_1000s
gen med2_per1000 = med2/no_1000s
gen adm2_per1000 = adm2/no_1000s

//encode district, gen (dist)
encode unique_id, gen (subdist)
//encode unique_dist_id, gen (dist)
encode district, gen(dist)
encode state, gen (states)

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

/*
drop if inlist(state, "ANDHRA PRADESH", "TELANGANA", "KARNATAKA", "KERALA", ///
						"TAMIL NADU","MAHARASHTRA","GUJARAT","GOA")
						

// Pooled OLS
reg alesina med_per_1000 edu_per_1000 adm_per_1000 $inf $con i.year i.subdist, vce(cluster subdist)
	est store pols
	estadd local fe Yes

esttab pols using "test_pols.tex", replace /// a6 a7
    keep(edu_per_1000 med_per_1000 adm_per_1000 ///
        $inf $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
	
reg alesina med edu adm share_roads share_pubtn population $con i.year i.subdist, vce(cluster subdist)
	est store pols2
	estadd local fe Yes
	
esttab pols2 using "test_pols2.tex", replace /// a6 a7
    keep(edu med adm share_roads share_pubtn population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
*/
	
*****************************************************************
*****************************************************************

// xtreg
xtset subdist year
xtdescribe
xtreg alesina med edu adm $inf population $con i.year, fe //vce(cluster subdist)
	est store s1
	estadd local fe Yes
	
xtreg alesina med edu adm $inf population $con i.year if inlist(zone, "South", "West"), fe
	est store s2
	estadd local fe Yes
xtreg alesina med edu adm $inf population $con i.year if inlist(zone, "Central", "East", "North"), fe
	est store s3
	estadd local fe Yes
* Combine all the stored results into one LaTeX file
esttab s1 s2 s3 using "test_panel_sum.tex", replace /// a6 a7
    keep(edu med adm share_roads share_pubtn population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.4e) se(%9.4e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

	
* Get the list of unique states
levelsof state, local(states)

* Loop through each state and run the regression
foreach state of local states {
    di "Processing state: `state'"
    
    * Create a valid name for storing the estimates by replacing spaces and special characters
    local state_name_clean = strtoname("state`state'")
    
    * Subset data for the current state
    tempvar state_subset
    gen `state_subset' = (state == "`state'")
 
	xtset subdist year
    * Run regression on the subset data
    xtreg alesina med edu adm $inf population  $con i.year if `state_subset', fe
    est store `state_name_clean' // Store the results with a unique name
    estadd local fe Yes // Add fixed effects information
}

* Combine all the stored results into one LaTeX file
esttab p1 state* using "test_panel_sum.tex", replace /// a6 a7
    keep(edu med adm share_roads share_pubtn population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.4e) se(%9.4e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

*****************************************************************
*****************************************************************

xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  i.year, fe //vce(cluster subdist)
	est store a1
	estadd local fe Yes
xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store a2
	estadd local fe Yes
xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store a3
	estadd local fe Yes

esttab a1 a2 a3 using "test_panel.tex", replace /// a6 a7
    keep(edu_per_1000 med_per_1000 adm_per_1000 ///
        $inf $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

	
* Get the list of unique states
levelsof state, local(states)

* Loop through each state and run the regression
foreach state of local states {
    di "Processing state: `state'"
    
    * Create a valid name for storing the estimates by replacing spaces and special characters
    local state_name_clean = strtoname("state`state'")
    
    * Subset data for the current state
    tempvar state_subset
    gen `state_subset' = (state == "`state'")
 
	xtset subdist year
    * Run regression on the subset data
    qui xtreg alesina med_per_1000 edu_per_1000 adm_per_1000 $inf $con i.year if `state_subset', fe
    est store `state_name_clean' // Store the results with a unique name
    estadd local fe Yes // Add fixed effects information
}

* Combine all the stored results into one LaTeX file
esttab p2 state* using "test_panel.tex", replace /// a6 a7
    keep(edu_per_1000 med_per_1000 adm_per_1000 ///
        $inf $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

*****************************************************************
*****************************************************************

xtreg alesina med_per_1000 edu_per_1000 adm_per_1000 $inf $con i.year, fe
estimate store fe
xtreg alesina med_per_1000 edu_per_1000 adm_per_1000 $inf $con i.year, re
estimate store re
hausman fe re

xtreg alesina med edu adm $inf population $con i.year, fe 
	est store t1
	estadd local fe Yes
xtreg alesina $med edu adm $inf population $con i.year, fe
	est store t2
	estadd local fe Yes
xtreg alesina med $edu adm $inf population $con i.year, fe
	est store t3
	estadd local fe Yes

xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  i.year, fe
	est store t4
	estadd local fe Yes
xtreg alesina $med_access edu_per_1000 adm_per_1000 $inf $con i.year, fe
	est store t5
	estadd local fe Yes
xtreg alesina med_per_1000 $edu_access $inf $con i.year, fe
	est store t6
	estadd local fe Yes

esttab t1 t2 t3 using "test_panel_1.tex", replace /// a6 a7
    keep(edu med adm $edu $med ///
        $inf population $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

esttab t4 t5 t6 using "test_panel_2.tex", replace /// a6 a7
    keep(edu_per_1000 med_per_1000 adm_per_1000 ///
		$med_access $edu_access ///
        $inf $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

*****************************************************************
*****************************************************************	

xtreg alesina $med edu adm $inf population $con i.year, fe
	est store t2
	estadd local fe Yes
xtreg alesina $med edu adm $inf population $con i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store m1
	estadd local fe Yes
xtreg alesina $med edu adm $inf population $con i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store m2
	estadd local fe Yes	
	
xtreg alesina med $edu adm $inf population $con i.year, fe
	est store t3
	estadd local fe Yes	
xtreg alesina med $edu adm $inf population $con i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store e1
	estadd local fe Yes
xtreg alesina med $edu adm $inf population $con i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store e2
	estadd local fe Yes	
	
esttab t2 m1 m2 t3 e1 e2 using "state_stock.tex", replace /// a6 a7
    keep(edu med adm $edu $med ///
        $inf population $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
	
xtreg alesina $med_access edu_per_1000 adm_per_1000 $inf $con i.year, fe
	est store t5
	estadd local fe Yes
xtreg alesina $med_access edu_per_1000 adm_per_1000 $inf $con i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store ma1
	estadd local fe Yes
xtreg alesina $med_access edu_per_1000 adm_per_1000 $inf $con i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store ma2
	estadd local fe Yes
	
xtreg alesina med_per_1000 $edu_access adm_per_1000 $inf $con i.year, fe
	est store t6
	estadd local fe Yes	
xtreg alesina med_per_1000 $edu_access adm_per_1000 $inf $con i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store ea1
	estadd local fe Yes
xtreg alesina med_per_1000 $edu_access adm_per_1000 $inf $con i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store ea2
	estadd local fe Yes
	
	
esttab t5 ma1 ma2 t6 ea1 ea2 using "state_Access.tex", replace /// a6 a7
    keep(edu_per_1000 med_per_1000 adm_per_1000 ///
		$med_access $edu_access ///
        $inf $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	
	
/*
cls
clear all
import delimited "Panel_Raw_change.csv", clear // 

keep if inlist(state, "ANDHRA PRADESH", "TELANGANA", "KARNATAKA", "KERALA", ///
						"TAMIL NADU","MAHARASHTRA","GUJARAT","GOA")
						

encode district, gen (dist)
encode unique_id, gen (subdist)
global edu p_sch_per_1000_change m_sch_per_1000_change h_sch_per_1000_change ssc_sch_per_1000_change
global med phc_per_1000_change mcwc_per_1000_change vet_per_1000_change aanganwadi_per_1000_change 
global con bank_per_1000_change po_per_1000_change mandi_per_1000_change 
global con2 share_roads_change share_rails_change share_pubtn_change nearest_town_distance_change

reg alesina_change med_per_1000_change edu_per_1000_change adm_per_1000_change $con2 i.dist,robust
	est store c1
	estadd local fe Yes
esttab c1 using "test_change_1.tex", replace /// a6 a7
    keep(edu_per_1000_change med_per_1000_change adm_per_1000_change ///
	$con2 _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)


reg alesina_change $med $edu $con $con2 i.dist,robust
reg alesina_change edu_change med_change adm_change $con2 i.dist,robust
*/




/*
xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year

estimate store fe
xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year, fe cluster(dist)
xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year, re cluster(dist)
xttest0
estimate store re

hausman fe re

xtreg alesina med_per_1000 $edu $inf $con i.year, fe
xtreg alesina $med edu_per_1000 $inf $con i.year, fe
xtreg alesina $med $edu $inf $con i.year, fe

xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year i.dist, robust
reg alesina  med_per_1000 edu_per_1000 $inf $con i.year i.dist, vce(cluster dist)

xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year if state == "ANDAMAN & NICOBAR", fe

*/
log close






//xtreg alesina edu2_per1000 med2_per1000 ///
//			adm2_per1000 share_roads share_pubtn $con i.year, fe
			
			




