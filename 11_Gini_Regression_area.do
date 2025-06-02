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
log using "011_Reg.log", replace

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
cls
clear all
//import delimited "gini_pa.csv", clear
import delimited "2020catdata_area.csv", clear

set matsize 6000

keep if alesina >0
encode state, gen (states)
encode district, gen (dist)
gen farm = total_hhd_engaged_in_farm_activi/total_hhd
replace str = "." if str == ""
replace str = "." if str == "inf"
destring str, generate(st_ratio)

gen pschool_per_1000 = availability_of_primary_school/no_1000s
gen midschool_per_1000 = availability_of_middle_school/no_1000s
gen highschool_per_1000 = availability_of_high_school/no_1000s
gen sscschool_per_1000 = availability_of_ssc_school/no_1000s
gen degreecol_per_1000 = availability_of_govt_degree_coll/no_1000s
gen allotherschools = availability_of_middle_school + availability_of_high_school + ///
						availability_of_ssc_school + availability_of_govt_degree_coll	
gen school_per_1000 = allotherschools/no_1000s

//keep if state != "KERALA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"

//global inf subdist_agro_sum subdist_transportadmin_sum share_roads
global inf share_roads share_rails share_pubtn arg_per_1000 adm_per_1000  
global con num nearest_urban_proximity // total_population //area
global edu pschool_per_1000 midschool_per_1000 ///
			highschool_per_1000 sscschool_per_1000 
//global edu availability_of_primary_school availability_of_middle_school ///
//		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
//global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global med phc_per_1000 aanganwadi_per_100 veter_per_1000
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
label var degreecol_per_1000 "Degree Colleges per 1000 people"
label var availability_of_govt_degree_coll "Govt. Degree Colleges per 1000 people"
label var farm "Share of Households in agriculture"
label var share_roads "Share of Villages with Roads"
label var share_rails "Share of Villages with Railway"
label var share_pubtn "Share of Villages with Public Transport"
label var med_per_1000 "Medical Facilities per 1000 people"
label var edu_per_1000 "Educational Facilities per 1000 people"
label var adm_per_1000 "Administrative/Transport Facilities per 1000 people"
label var arg_per_1000 "Agricultural Facilities per 1000 people"
label var phc_per_1000 "PHC per 1000 people"
label var aanganwadi_per_100_reg "Aanganwadi Centre per 100 children"
label var veter_per_1000 "Veterinary Facilities per 1000 people"
//label var subdist_population "Subdistrict Population"
//label var subdist_area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"

keep if num >8
//keep if subdist_ntl_pa <= 28

//reg alesina $qos school_per_1000 med_per_1000 $inf $con  i.dist,robust

//reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist,robust
//reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist,robust
	est store a5
	estadd local fe Yes
	estadd local sfe District
	
reg alesina med_per_1000 edu_per_1000 $inf ,robust
	est store a1
	estadd local fe No
	estadd local sfe No

reg alesina med_per_1000 edu_per_1000 $inf i.states,robust
	est store a2
	estadd local fe No
	estadd local sfe State
	
reg alesina med_per_1000 edu_per_1000 $inf $con ,robust
	est store a3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina med_per_1000 edu_per_1000 $inf $con i.states,robust
	est store a4
	estadd local fe Yes
	estadd local sfe State

//reg alesina med_per_1000 subdist_edu_sum $inf $con i.dist,robust
//	est store a5
//	estadd local fe Yes
//	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con  i.dist,robust
	est store a6
	estadd local fe Yes
	estadd local sfe District	

reg alesina $med edu_per_1000 $inf $con i.dist,robust
	est store a7
	estadd local fe Yes
	estadd local sfe District

esttab a1 a2 a3 a4 a5 a6 a7 using "table_Gini_IN.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 		

*********************
**Multicollinearity**
*********************	
	
corr med_per_1000 edu_per_1000 adm_per_1000 arg_per_1000 share_roads share_rails share_pubtn
pca med_per_1000 edu_per_1000 adm_per_1000 arg_per_1000 share_roads share_rails share_pubtn
estat kmo
predict pc1 pc2 pc3 pc4, score
reg alesina pc1 pc2 i.dist, robust


reg alesina med_per_1000 $edu $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap3
	estadd local fe Yes
	estadd local sfe District	
	
	
