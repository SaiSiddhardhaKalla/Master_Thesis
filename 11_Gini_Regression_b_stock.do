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
import delimited "2020catdata_uncensored.csv", clear
//import delimited "2020catdata.csv", clear

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

//keep if state != "GOA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"

global inf subdist_agro_sum subdist_transportadmin_sum share_roads
//global inf adm_per_1000 arg_per_1000 share_roads
global con subdist_area num nearest_urban_proximity subdist_population
global edu availability_of_primary_school availability_of_middle_school ///
		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var availability_of_primary_school "Sum of Primary Schools"
label var availability_of_middle_school "Sum of Middhle Schools"
label var availability_of_high_school "Sum of High Schools"
label var availability_of_ssc_school "Sum of SSC Schools"
label var availability_of_govt_degree_coll "Sum of Govt. Degree Colleges"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
label var degreecol_per_1000 "Degree Colleges per 1000 people"
label var availability_of_govt_degree_coll "Govt. Degree Colleges per 1000 people"
label var farm "Share of Households in agriculture"
label var share_roads "Share of Villages with Roads"
label var subdist_med_sum "Sum of Medical Facilities"
label var subdist_edu_sum "Sum of Educational Facilities"
label var adm_per_1000 "Sum of Administrative/Transport Facilities"
label var arg_per_1000 "Sum of Agricultural Facilities"
label var phc_per_1000 "PHC per 1000 people"
label var aanganwadi_per_100_reg "Aanganwadi Centre per 100 children"
label var veter_per_1000 "Veterinary Facilities per 1000 people"
label var subdist_population "Subdistrict Population"
label var subdist_area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"

keep if num >8
keep if dist_ntl_pc <= 0.1


//reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
//reg alesina subdist_med_sum primaryschool_per_100 $inf $con i.dist,robust
	est store a5
	estadd local fe Yes
	estadd local sfe District
	
reg alesina subdist_med_sum subdist_edu_sum $inf ,robust
	est store a1
	estadd local fe No
	estadd local sfe No

reg alesina subdist_med_sum subdist_edu_sum $inf i.states,robust
	est store a2
	estadd local fe No
	estadd local sfe State
	
reg alesina subdist_med_sum subdist_edu_sum $inf $con ,robust
	est store a3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.states,robust
	est store a4
	estadd local fe Yes
	estadd local sfe State

//reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
//	est store a5
//	estadd local fe Yes
//	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con  i.dist,robust
	est store a6
	estadd local fe Yes
	estadd local sfe District	

//keep if dist_ntl_pc <= 0.04
reg alesina $med subdist_edu_sum $inf $con i.dist,robust
	est store a7
	estadd local fe Yes
	estadd local sfe District
	
esttab a1 a2 a3 a4 a5 a6 a7 using "table_Gini_Stock_IN.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 		

*********************
**Multicollinearity**
*********************	
	
corr subdist_med_sum subdist_edu_sum subdist_transportadmin_sum subdist_agro_sum
pca subdist_med_sum subdist_edu_sum subdist_transportadmin_sum subdist_agro_sum
estat kmo
predict pc1 pc2 pc3 pc4, score
reg alesina pc1 i.dist, robust
//reg alesina pc1 pc2 i.dist, robust	
	
****************
**Region Level**
****************
/*
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if region == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if region == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if region == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if region == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if region == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Region.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 		
*/
************************************************************
**Zonal Level***************************Zonal Level*********
************************************************************

reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Stock_Zone.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
****************
***Zone Level***
****************

*** Edu ***

reg alesina subdist_med_sum $edu $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum $edu $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum $edu $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum $edu $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum $edu $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Zone_Stock_Edu.tex", replace ///
	keep($edu subdist_med_sum ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

*** Med ***
	
reg alesina $med subdist_edu_sum $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina $med subdist_edu_sum $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina $med subdist_edu_sum $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina $med subdist_edu_sum $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Zone_Stock_Med.tex", replace ///
	keep(subdist_edu_sum $med ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

************************************************************
**State Level***************************State Level*********
************************************************************

reg alesina subdist_med_sum $edu $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "ANDHRA PRADESH",robust
	est store ap3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "KARNATAKA",robust
	est store ka1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "KARNATAKA",robust
	est store ka2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "KARNATAKA",robust
	est store ka3
	estadd local fe Yes
	estadd local sfe District
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "TELANGANA",robust
	est store ts1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "TELANGANA",robust
	est store ts2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "TELANGANA",robust
	est store ts3
	estadd local fe Yes
	estadd local sfe District
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "KERALA",robust
	est store kl1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "KERALA",robust
	est store kl2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "KERALA",robust
	est store kl3
	estadd local fe Yes
	estadd local sfe District
/*	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "GOA",robust
	est store ga1
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "GOA",robust
	est store ga2
	estadd local fe Yes
	estadd local sfe District	
*/	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "WESTBENGAL",robust
	est store wb1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "WESTBENGAL",robust
	est store wb2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "WESTBENGAL",robust
	est store wb3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch3
	estadd local fe Yes
	estadd local sfe District	
	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "ODISHA",robust
	est store or1
	estadd local fe Yes
	estadd local sfe District		
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "ODISHA",robust
	est store or2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "ODISHA",robust
	est store or3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "ASSAM",robust
	est store as1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "ASSAM",robust
	est store as2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "ASSAM",robust
	est store as3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "TRIPURA",robust
	est store tr1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "TRIPURA",robust
	est store tr2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "TRIPURA",robust
	est store tr3
	estadd local fe Yes
	estadd local sfe District	
/*	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "ANDAMAN AND NICOBAR ISLANDS",robust
	est store an1
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "ANDAMAN AND NICOBAR ISLANDS",robust
	est store an2
	estadd local fe Yes
	estadd local sfe District
*/		
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "JHARKHAND",robust
	est store jh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "JHARKHAND",robust
	est store jh2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "JHARKHAND",robust
	est store jh3
	estadd local fe Yes
	estadd local sfe District		
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "BIHAR",robust
	est store bh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "BIHAR",robust
	est store bh2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "BIHAR",robust
	est store bh3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk2
	estadd local fe Yes
	estadd local sfe District	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "PUNJABB",robust
	est store pb1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "PUNJABB",robust
	est store pb2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "PUNJABB",robust
	est store pb3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "HARYANA",robust
	est store hr1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "HARYANA",robust
	est store hr2
	estadd local fe Yes
	estadd local sfe District		
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "HARYANA",robust
	est store hr3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con i.dist if state == "GUJARAT",robust
	est store gj1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med subdist_edu_sum $inf $con i.dist if state == "GUJARAT",robust
	est store gj2
	estadd local fe Yes
	estadd local sfe District
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist if state == "GUJARAT",robust
	est store gj3
	estadd local fe Yes
	estadd local sfe District	

esttab ap3 ap1 ap2 ts3 ts1 ts2 a5 using "test_Stock_1.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab tn3 tn1 tn2 kl3 kl1 kl2 a5 using "test_Stock_2.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab ka3 ka1 ka2 mh3 mh1 mh2 a5 using "test_Stock_3.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
		
esttab as3 as1 as2 tr3 tr1 tr2 a5 using "test_Stock_4.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab wb3 wb1 wb2 or3 or1 or2 a5 using "test_Stock_5.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
esttab ch3 ch1 ch2 mp3 mp1 mp2 a5 using "test_Stock_6.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab jh3 jh1 jh2 bh3 bh1 bh2 a5 using "test_Stock_7.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab uk3 uk1 uk2 up3 up1 up2 a5 using "test_Stock_8.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab pb3 pb1 pb2 hr3 hr1 hr2 a5 using "test_Stock_9.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant)	

esttab gj3 gj1 gj2 rj3 rj1 rj2 a5 using "test_Stock_10.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "2020cat_w_data.csv", clear


keep if wcv >0
keep if num >8
keep if dist_ntl_pc <= 0.1
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

//keep if state != "GOA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"

global inf subdist_agro_sum subdist_transportadmin_sum share_roads
//global inf adm_per_1000 arg_per_1000 share_roads
global con subdist_area num nearest_urban_proximity subdist_population
global edu availability_of_primary_school availability_of_middle_school ///
		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var availability_of_primary_school "Sum of Primary Schools"
label var availability_of_middle_school "Sum of Middhle Schools"
label var availability_of_high_school "Sum of High Schools"
label var availability_of_ssc_school "Sum of SSC Schools"
label var availability_of_govt_degree_coll "Sum of Govt. Degree Colleges"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
label var degreecol_per_1000 "Degree Colleges per 1000 people"
label var availability_of_govt_degree_coll "Govt. Degree Colleges per 1000 people"
label var share_roads "Share of Villages with Roads"
label var subdist_med_sum "Sum of Medical Facilities"
label var subdist_edu_sum "Sum of Educational Facilities"
label var adm_per_1000 "Sum of Administrative/Transport Facilities"
label var arg_per_1000 "Sum of Agricultural Facilities"
label var phc_per_1000 "PHC per 1000 people"
label var aanganwadi_per_100_reg "Aanganwadi Centre per 100 children"
label var veter_per_1000 "Veterinary Facilities per 1000 people"
label var subdist_population "Subdistrict Population"
label var subdist_area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"


reg wcv subdist_med_sum subdist_edu_sum $inf $con i.dist,robust

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "2020cat_t_data.csv", clear


keep if theil >0
keep if num >8
keep if dist_ntl_pc <= 0.1
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

//keep if state != "GOA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"

global inf subdist_agro_sum subdist_transportadmin_sum share_roads
//global inf adm_per_1000 arg_per_1000 share_roads
global con subdist_area num nearest_urban_proximity subdist_population
global edu availability_of_primary_school availability_of_middle_school ///
		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var availability_of_primary_school "Sum of Primary Schools"
label var availability_of_middle_school "Sum of Middhle Schools"
label var availability_of_high_school "Sum of High Schools"
label var availability_of_ssc_school "Sum of SSC Schools"
label var availability_of_govt_degree_coll "Sum of Govt. Degree Colleges"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
label var degreecol_per_1000 "Degree Colleges per 1000 people"
label var availability_of_govt_degree_coll "Govt. Degree Colleges per 1000 people"
label var share_roads "Share of Villages with Roads"
label var subdist_med_sum "Sum of Medical Facilities"
label var subdist_edu_sum "Sum of Educational Facilities"
label var adm_per_1000 "Sum of Administrative/Transport Facilities"
label var arg_per_1000 "Sum of Agricultural Facilities"
label var phc_per_1000 "PHC per 1000 people"
label var aanganwadi_per_100_reg "Aanganwadi Centre per 100 children"
label var veter_per_1000 "Veterinary Facilities per 1000 people"
label var subdist_population "Subdistrict Population"
label var subdist_area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"


//keep if theil < 
reg theil subdist_med_sum subdist_edu_sum $inf $con i.dist,robust

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
	
log close
