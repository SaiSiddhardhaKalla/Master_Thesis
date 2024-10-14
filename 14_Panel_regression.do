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


//import delimited "Panel_Raw22.csv", clear // 
import delimited "Panel_Raw.csv", clear // This is main file
//import delimited "Panel_Clean.csv", clear // 

set matsize 8000

label var num "Number of Villages"
label var share_roads "Share of Villages with Roads"
label var share_rails "Share of Villages with Railway"
label var share_pubtn "Share of Villages with Public Transport"
label var population "Population"
label var med "Medical Facilities"
label var edu "Educational Facilities"
label var adm "Administrative Facilities"
label var subdistrictarea "Subdistrict Area"
label var nearest_town_distance "Average Distance to Urban Centre"
label var phc "Primary Healthcare Centre"
label var mcwc "Maternal and Child Welfare Centre"
label var veterinary_hospital "Veterinary Hospital"
label var aanganwadi "Aanganwadi"
label var p_school "Primary School"
label var m_school "Middle School"
label var h_school "High School"
label var ssc_school "Senior Secondary School"
label var iti "Vocational Institute"
label var sc_pop_share "Share of SC Population"
label var st_pop_share "Share of ST Population"
label var treated "Treatment"
label var intensity "Treatment Intensity"
label var period "2020"

/*
label var med_per_1000 "Medical Facilities per 1000 people"
label var edu_per_1000 "Educational Facilities per 1000 people"
label var adm_per_1000 "Administrative Facilities per 1000 people"     
label var phc_per_1000 "Primary Healthcare Centre per 1000 people"
label var mcwc_per_1000 "Maternal and Child Welfare Centre per 1000 people"
label var vet_per_1000 "Veterinary Hospital per 1000 people"
label var aanganwadi_per_1000 "Aanganwadi per 1000 people"
label var p_sch_per_1000 "Primary School per 1000 people"
label var m_sch_per_1000 "Middle School per 1000 people"
label var h_sch_per_1000 "High School per 1000 people"
label var ssc_sch_per_1000 "Senior Secondary School per 1000 people"      
label var iti_per_1000 "Vocational Institute per 1000 people" 
*/
		 
keep if alesina >0
bysort unique_id: gen count = _N
* Drop values that occur only once
drop if count == 1
* Drop the count variable as it's no longer needed
drop count
//drop zone

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

global inf share_roads share_pubtn share_rails
global con num subdistrictarea nearest_town_distance // sc_pop_share st_pop_share //village_area_sqkm
global med phc mcwc veterinary_hospital aanganwadi dispensary
global edu p_school m_school h_school ssc_school iti
global edu_access p_sch_per_1000 m_sch_per_1000 h_sch_per_1000 ///
		ssc_sch_per_1000 iti_per_1000
global med_access phc_per_1000 mcwc_per_1000 vet_per_1000 aanganwadi_per_1000 


gen edu2 = p_school + m_school + h_school + ssc_school + iti
gen med2 = phc + aanganwadi + veterinary_hospital + dispensary
gen adm2 = cooperative_bank + mandis + post_office

label var med2 "Medical Facilities"

//gen edu2_per1000 = edu2/no_1000s
//gen med2_per1000 = med2/no_1000s
//gen adm2_per1000 = adm2/no_1000s

//encode district, gen (dist)
encode unique_id, gen (subdist)
//encode unique_dist_id, gen (dist)
encode district, gen(dist)
encode state, gen (states)

gen reg = 0
replace reg = 1 if region=="A"
drop if state=="ANDAMAN & NICOBAR"
label var reg "Region"

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
					
/*
// Pooled OLS	
reg alesina med edu adm $inf population, robust
	est store p1
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con, robust
	est store p2
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con i.year ///
			i.dist, robust
	est store pols2
	estadd local rfe Yes
	estadd local tfe Yes

reg alesina med edu adm $inf population if inlist(zone, "South", "West"), robust
	est store p1sw
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con if ///
			inlist(zone, "South", "West"), robust
	est store p2sw
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con i.year ///
			i.dist if inlist(zone, "South", "West"), robust
	est store pols2sw
	estadd local rfe Yes
	estadd local tfe Yes
	
reg alesina med edu adm $inf population ///
			if inlist(zone, "North", "East","Central"), robust
	est store p1ne
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con if ///
			inlist(zone, "North", "East","Central"), robust
	est store p2ne
	estadd local rfe No
	estadd local tfe No
reg alesina med edu adm $inf population $con i.year ///
			i.dist if inlist(zone, "North", "East","Central"), robust
	est store pols2ne
	estadd local rfe Yes
	estadd local tfe Yes
	
esttab p1 p2 pols2 p1sw p2sw pols2sw ///
			p1ne p2ne pols2ne using "test_pols2.tex", replace /// a6 a7
    keep(edu med adm $inf ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 rfe tfe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Regional Fixed Effects" "Time Fixed Effects" "Number of observations")) ///
    plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
*/
	
*****************************************************************
*****************************************************************
*************************** Panel *******************************
*****************************************************************
*****************************************************************

// xtreg
xtset subdist year
xtdescribe

xi: xtreg alesina med edu adm $inf i.year ///
			,fe vce(cluster subdist)
	est store s1
	estadd local fe No
	estadd local tfe No
//xi: xtreg alesina med edu adm $inf population $con ///
//			, vce(cluster subdist)
//	est store s2
//	estadd local fe Yes
//	estadd local tfe No
xi: xtreg alesina med edu adm $inf population $con i.year ///
			,fe  vce(cluster subdist)
	est store s3
	estadd local fe Yes
	estadd local tfe Yes

xi: xtreg alesina med edu adm $inf i.year ///
			if inlist(zone, "South", "West"),fe vce(cluster subdist)
	est store s1sw
	estadd local fe No
	estadd local tfe No
//xi: xtreg alesina med edu adm $inf population $con ///
//			if inlist(zone, "South", "West"),  vce(cluster subdist)
//	est store s2sw
//	estadd local fe Yes
//	estadd local tfe No
xi: xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store s3sw
	estadd local fe Yes
	estadd local tfe Yes
	
xi: xtreg alesina med edu adm $inf i.year ///
			if inlist(zone, "Central", "East", "North"),fe vce(cluster subdist)
	est store s1ne
	estadd local fe No
	estadd local tfe No
//xi: xtreg alesina med edu adm $inf population $con ///
//			if inlist(zone, "Central", "East", "North"), vce(cluster subdist)
//	est store s2ne
//	estadd local fe Yes
//	estadd local tfe No
xi: xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store s3ne
	estadd local fe Yes
	estadd local tfe Yes
	
* Combine all the stored results into one LaTeX file
esttab s1 s3 s1sw s3sw s1ne s3ne using "test_panel_stock.tex", replace /// a6 a7
    keep(edu med adm share_roads share_pubtn population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe tfe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Time Fixed Effects" "Number of observations")) ///
    plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

/*
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
    xi: xtreg alesina med edu adm $inf population $con i.year if `state_subset', re vce(cluster subdist)
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
*/

xi: xtreg alesina $med edu adm $inf i.year ///
			,fe vce(cluster subdist)
	est store s1
	estadd local fe No
	estadd local tfe No
xi: xtreg alesina $med edu adm $inf population $con i.year ///
			,fe  vce(cluster subdist)
	est store s3
	estadd local fe Yes
	estadd local tfe Yes

xi: xtreg alesina $med edu adm $inf i.year ///
			if inlist(zone, "South", "West"),fe vce(cluster subdist)
	est store s1sw
	estadd local fe No
	estadd local tfe No
xi: xtreg alesina $med edu adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store s3sw
	estadd local fe Yes
	estadd local tfe Yes
	
xi: xtreg alesina $med edu adm $inf i.year ///
			if inlist(zone, "Central", "East", "North"),fe vce(cluster subdist)
	est store s1ne
	estadd local fe No
	estadd local tfe No
xi: xtreg alesina $med edu adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store s3ne
	estadd local fe Yes
	estadd local tfe Yes
	
/*	
xtreg alesina med $edu adm $inf population $con i.year, fe vce(cluster dist)
	est store ep1
	estadd local fe Yes	
xtreg alesina med $edu adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster dist)
	est store ep2
	estadd local fe Yes
xtreg alesina med $edu adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dist)
	est store ep3
	estadd local fe Yes	
*/
	
esttab s1 s3 s1sw s3sw s1ne s3ne using "panel_med_stock.tex", replace /// a6 a7
    keep(edu $med adm share_roads share_pubtn population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe tfe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Time Fixed Effects" "Number of observations")) ///
    plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

	
*****************************************************************
*****************************************************************

* Using re and dist cluster

xtreg alesina med edu adm $inf population $con i.year ///
			, re vce(cluster subdist)
xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), re vce(cluster subdist)
xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), re vce(cluster subdist)


*****************************************************************
*****************************************************************

/*
xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  ///
			i.year, fe vce(cluster dist)
	est store a1
	estadd local fe Yes
xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  ///
			i.year if inlist(zone, "South", "West"), fe vce(cluster dist)
	est store a2
	estadd local fe Yes
xtreg alesina med_per_1000 edu_per_1000  adm_per_1000 $inf $con  ///
			i.year if inlist(zone, "Central", "East", "North"), fe vce(cluster dist)
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
*/

*****************************************************************
*****************************************************************
**************************** DID ********************************
*****************************************************************
*****************************************************************

xtreg alesina i.treated##i.period, ///
			fe vce(cluster subdist)
	est store t1
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf, ///
			fe vce(cluster subdist)
	est store t2
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store t3
	estadd local fe Yes

xtreg alesina i.treated##i.period ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store t1sw
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store t2sw
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store t3sw
	estadd local fe Yes	
	
xtreg alesina i.treated##i.period ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store t1ne
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store t2ne
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store t3ne
	estadd local fe Yes
	

esttab t1 t2 t3 t1sw t2sw t3sw t1ne t2ne t3ne using "DiD_binary.tex", replace ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Region Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)			

*****************************************************************
*****************************************************************


xtreg alesina c.intensity##i.period, ///
			fe vce(cluster subdist)
	est store i1
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf, ///
			fe vce(cluster subdist)
	est store i2
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store i3
	estadd local fe Yes

xtreg alesina c.intensity##i.period ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store i1sw
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store i2sw
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store i3sw
	estadd local fe Yes	
	
xtreg alesina c.intensity##i.period ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store i1ne
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store i2ne
	estadd local fe Yes
xtreg alesina c.intensity##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store i3ne
	estadd local fe Yes
	
esttab i1 i2 i3 i1sw i2sw i3sw i1ne i2ne i3ne using "DiD_intensity.tex", replace /// 
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Region Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	
	
*****************************************************************
*****************************************************************


xtreg alesina i.treated##i.period##i.reg, ///
			fe vce(cluster subdist)
	est store db1
	estadd local fe Yes
xtreg alesina i.treated##i.period##i.reg med2 edu adm $inf, ///
			fe vce(cluster subdist)
	est store db2
	estadd local fe Yes
xtreg alesina i.treated##i.period##i.reg med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store db3
	estadd local fe Yes
	
xtreg alesina c.intensity##i.period##i.reg, ///
			fe vce(cluster subdist)
	est store di1
	estadd local fe Yes
xtreg alesina c.intensity##i.period##i.reg med2 edu adm $inf, ///
			fe vce(cluster subdist)
	est store di2
	estadd local fe Yes
xtreg alesina c.intensity##i.period##i.reg med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store di3
	estadd local fe Yes
	

esttab db1 db2 db3 di1 di2 di3 using "DiD_3D.tex", replace /// a6 a7
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	

*****************************************************************
*****************************************************************


xi: xtreg alesina med edu adm $inf population $con i.year if inlist(zone, "South", "West"), fe 
estimate store fe
xi: xtreg alesina med edu adm $inf population $con i.year if inlist(zone, "South", "West"), re 
xtoverid
estimate store re
hausman fe re


*****************************************************************
*****************************************************************
*************************** Change ******************************
*****************************************************************
*****************************************************************
		

cls
clear all
import delimited "Panel_Raw_change.csv", clear // 

set matsize 8000

label var num_change "Number of Villages"
label var share_roads "Share of Villages with Roads"
label var share_rails "Share of Villages with Railway"
label var share_pubtn "Share of Villages with Public Transport"
label var population "Population"
label var med "Medical Facilities"
label var edu "Educational Facilities"
label var adm "Administrative Facilities"
label var med_change "Medical Facilities Changes"
label var edu_change "Educational Facilities Changes"
label var adm_change "Administrative Facilities Changes"
label var subdistrictarea "Subdistrict Area"
label var nearest_town_distance "Average Distance to Urban Centre"
label var phc "Primary Healthcare Centre"
label var mcwc_change "Maternal and Child Welfare Centre"
label var veterinary_hospital "Veterinary Hospital"
label var aanganwadi "Aanganwadi"
label var p_school "Primary School"
label var m_school "Middle School"
label var h_school "High School"
label var ssc_school "Senior Secondary School"
label var iti "Vocational Institute"
label var sc_pop_share "Share of SC Population"
label var st_pop_share "Share of ST Population"
label var treated "Treatment"
label var intensity "Treatment Intensity"
label var period "2020"

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
						

encode district, gen (dist)
encode unique_id, gen (subdist)

global con share_roads_change share_rails_change share_pubtn_change ///
			nearest_town_distance_change num_change subdistrictarea ///
			sc_pop_share st_pop_share
global med phc_change mcwc_change veterinary_hospital_change aanganwadi_change			

reg alesina_change med_change edu_change adm_change $con i.dist,robust
	est store c1
	estadd local fe Yes
reg alesina_change med_change edu_change adm_change $con i.dist ///
					if inlist(zone,"South","West"),robust
	est store c2
	estadd local fe Yes
reg alesina_change med_change edu_change adm_change $con i.dist ///
					if inlist(zone,"North","East","Central"),robust
	est store c3
	estadd local fe Yes
	
esttab c1 c2 c3 using "change_stock.tex", replace /// a6 a7
    keep(med_change edu_change adm_change ///
	$con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)


qui reg alesina_change $med edu_change adm_change $con i.dist,robust
	est store m1
	estadd local fe Yes
qui reg alesina_change $med edu_change adm_change $con i.dist ///
					if inlist(zone,"South","West"),robust
	est store m2
	estadd local fe Yes
qui reg alesina_change $med edu_change adm_change $con i.dist ///
					if inlist(zone,"North","East","Central"),robust
	est store m3
	estadd local fe Yes
esttab m1 m2 m3 using "change_medstock.tex", replace /// a6 a7
    keep($med edu_change adm_change ///
	$con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
	
*****************************************************************
*****************************************************************
// Balance Test
	
global filters treated num subdistrictarea population
eststo model1: reg avg_ntl $filters, robust
eststo model2: reg population $filters, robust
eststo model3: reg p_school $filters, robust
eststo model4: reg m_school $filters, robust
eststo model5: reg h_school $filters, robust
eststo model6: reg ssc_school $filters, robust
eststo model7: reg arts_and_science_degree_college $filters, robust
eststo model8: reg phc $filters, robust
eststo model9: reg mcwc $filters, robust
eststo model10: reg veterinary_hospital $filters, robust
eststo model11: reg aanganwadi $filters, robust
eststo model12: reg share_pubtn $filters, robust
eststo model13: reg share_rails $filters, robust
eststo model14: reg share_roads $filters, robust
eststo model15: reg nearest_town_distance $filters, robust




esttab model1 model2 model3 model4 model5 model6 model7 model8 model9 ///
		model10 model11 model12 model13 model14 model15 model16 model17 model18 ///
		using "regression_results.tex", replace label se compress
	

log close

*****************************************************************
*****************************************************************	
/*
xtreg alesina $med edu adm $inf population $con i.year, fe
	est store mp1
	estadd local fe Yes
xtreg alesina $med edu adm $inf population $con i.year if inlist(zone, "South", "West"), fe //vce(cluster subdist)
	est store mp2
	estadd local fe Yes
xtreg alesina $med edu adm $inf population $con i.year if inlist(zone, "Central", "East", "North"), fe //vce(cluster subdist)
	est store mp3
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
	
esttab mp1 mp2 mp3 using "state_stock.tex", replace /// a6 a7
    keep($med edu adm  ///
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



