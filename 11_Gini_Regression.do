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
//import delimited "2020catdata_uncensored.csv", clear // This is the old file
//import delimited "2020catdata_main.csv", clear // This is secondary file
//import delimited "2020catdata_old.csv", clear // This is main file 2
import delimited "2020MA_Final.csv", clear // This is main file
//import delimited "2017MA_Final.csv", clear // This is main file
//import delimited "2020catdata_villages.csv", clear // File for only villages
//import delimited "2020catdata_towns.csv", clear // File for only towns
//import delimited "gini_pc.csv", clear

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
gen aanganwadi_per_1000 = is_aanganwadi_centre_available/no_1000s
gen jan_per_1000 = availability_of_jan_aushadhi_ken/no_1000s

//keep if state != "KERALA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"


global inf share_roads  share_pubtn  adm_per_1000 share_rails arg_per_1000
global con num area nearest_urban_proximity
global edu pschool_per_1000 midschool_per_1000 ///
			highschool_per_1000 sscschool_per_1000 degreecol_per_1000
global med phc_per_1000 aanganwadi_per_100 veter_per_1000 ///
			jan_per_1000 mchc_per_1000
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
label var subdist_population "Subdistrict Population"
label var area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"

keep if num >2
//keep if dist_ntl_pc <= 0.1

//reg alesina $qos school_per_1000 med_per_1000 $inf $con  i.dist,robust

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
	
esttab a1 a2 a3 a4 a5  using "table_Gini_IN.tex", replace /// a6 a7
	keep(edu_per_1000 med_per_1000 ///
			$inf $con  _cons) /// $edu $med
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.3f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 		

*********************
**Multicollinearity**
*********************	
	
corr med_per_1000 edu_per_1000 adm_per_1000 arg_per_1000 share_roads share_rails share_pubtn
pca med_per_1000 edu_per_1000 adm_per_1000 arg_per_1000 share_roads share_rails share_pubtn
estat kmo
predict pc1 pc2 pc3 pc4, score
reg alesina pc1 i.dist, robust
//reg alesina pc1 pc2 i.dist, robust	
	
****************
**Region Level**
****************
/*
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if region == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if region == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if region == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if region == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if region == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Region.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
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

reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Zone.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
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

reg alesina med_per_1000 $edu $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 $edu $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 $edu $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 $edu $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 $edu $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Zone_Edu.tex", replace ///
	keep($edu med_per_1000 ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

*** Med ***
	
reg alesina $med edu_per_1000 $inf $con i.dist if zone == "north",robust
	est store North
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if zone == "south",robust
	est store South
	estadd local fe Yes
	estadd local sfe District
reg alesina $med edu_per_1000 $inf $con i.dist if zone == "west",robust
	est store West
	estadd local fe Yes
	estadd local sfe District
reg alesina $med edu_per_1000 $inf $con i.dist if zone == "east",robust	
	est store East
	estadd local fe Yes
	estadd local sfe District
reg alesina $med edu_per_1000 $inf $con i.dist if zone == "central",robust	
	est store Central
	estadd local fe Yes
	estadd local sfe District
	
esttab North South West East Central using "table_Gini_Zone_Med.tex", replace ///
	keep(edu_per_1000 $med ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

************************************************************
**State Level***************************State Level*********
************************************************************

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
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "KARNATAKA",robust
	est store ka1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "KARNATAKA",robust
	est store ka2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "KARNATAKA",robust
	est store ka3
	estadd local fe Yes
	estadd local sfe District
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "TELANGANA",robust
	est store ts1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "TELANGANA",robust
	est store ts2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "TELANGANA",robust
	est store ts3
	estadd local fe Yes
	estadd local sfe District
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "TAMIL NADU",robust
	est store tn3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "KERALA",robust
	est store kl1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "KERALA",robust
	est store kl2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "KERALA",robust
	est store kl3
	estadd local fe Yes
	estadd local sfe District
/*	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "GOA",robust
	est store ga1
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "GOA",robust
	est store ga2
	estadd local fe Yes
	estadd local sfe District	
*/	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "WEST BENGAL",robust
	est store wb1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "WEST BENGAL",robust
	est store wb2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "WEST BENGAL",robust
	est store wb3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "CHHATTISGARH",robust
	est store ch3
	estadd local fe Yes
	estadd local sfe District	
	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "ODISHA",robust
	est store or1
	estadd local fe Yes
	estadd local sfe District		
reg alesina $med edu_per_1000 $inf $con i.dist if state == "ODISHA",robust
	est store or2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "ODISHA",robust
	est store or3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "ASSAM",robust
	est store as1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "ASSAM",robust
	est store as2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "ASSAM",robust
	est store as3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "TRIPURA",robust
	est store tr1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "TRIPURA",robust
	est store tr2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "TRIPURA",robust
	est store tr3
	estadd local fe Yes
	estadd local sfe District	
/*	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "ANDAMAN AND NICOBAR ISLANDS",robust
	est store an1
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "ANDAMAN AND NICOBAR ISLANDS",robust
	est store an2
	estadd local fe Yes
	estadd local sfe District
*/		
reg alesina med_per_1000 $edu $inf $con i.dist if state == "JHARKHAND",robust
	est store jh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "JHARKHAND",robust
	est store jh2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "JHARKHAND",robust
	est store jh3
	estadd local fe Yes
	estadd local sfe District		
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "BIHAR",robust
	est store bh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "BIHAR",robust
	est store bh2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "BIHAR",robust
	est store bh3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "UTTAR PRADESH",robust
	est store up3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk2
	estadd local fe Yes
	estadd local sfe District	
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "UTTARAKHAND",robust
	est store uk3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "PUNJAB",robust
	est store pb1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "PUNJAB",robust
	est store pb2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "PUNJAB",robust
	est store pb3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "HARYANA",robust
	est store hr1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "HARYANA",robust
	est store hr2
	estadd local fe Yes
	estadd local sfe District		
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "HARYANA",robust
	est store hr3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "RAJASTHAN",robust
	est store rj3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "MADHYA PRADESH",robust
	est store mp3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "MAHARASHTRA",robust
	est store mh3
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina med_per_1000 $edu $inf $con i.dist if state == "GUJARAT",robust
	est store gj1
	estadd local fe Yes
	estadd local sfe District	
reg alesina $med edu_per_1000 $inf $con i.dist if state == "GUJARAT",robust
	est store gj2
	estadd local fe Yes
	estadd local sfe District
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if state == "GUJARAT",robust
	est store gj3
	estadd local fe Yes
	estadd local sfe District	

esttab ap3 ap1 ap2 ts3 ts1 ts2 a5 using "test_1.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab tn3 tn1 tn2 kl3 kl1 kl2 a5 using "test_2.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab ka3 ka1 ka2 mh3 mh1 mh2 a5 using "test_3.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
		
esttab as3 as1 as2 tr3 tr1 tr2 a5 using "test_4.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab wb3 wb1 wb2 or3 or1 or2 a5 using "test_5.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
esttab ch3 ch1 ch2 mp3 mp1 mp2 a5 using "test_6.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab jh3 jh1 jh2 bh3 bh1 bh2 a5 using "test_7.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab uk3 uk1 uk2 up3 up1 up2 a5 using "test_8.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab pb3 pb1 pb2 hr3 hr1 hr2 a5 using "test_9.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant)	

esttab gj3 gj1 gj2 rj3 rj1 rj2 a5 using "test_10.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab gj3 mh3 ts3 tn3 kl3 ka3 ap3 rj3 pb3 hr3 wb3 tr3 or3 jh3 bh3 as3 up3 uk3 mp3 ch3 using "all_in_whole.tex", replace ///
	keep(edu_per_1000 med_per_1000 ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.3f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 		

esttab gj1 mh1 ts1 tn1 kl1 ka1 ap1 rj1 pb1 hr1 wb1 tr1 or1 jh1 bh1 as1 up1 uk1 mp1 ch1 using "edu_in_whole.tex", replace ///
	keep($edu med_per_1000 ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.3f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab gj2 mh2 ts2 tn2 kl2 ka2 ap2 rj2 pb2 hr2 wb2 tr2 or2 jh2 bh2 as2 up2 uk2 mp2 ch2 using "med_in_whole.tex", replace ///
	keep(edu_per_1000 $med ///
			$inf $con _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.3f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.3f) se(%9.3f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "2020cat_w_data.csv", clear


keep if wcv >0
keep if num >2
//keep if dist_ntl_pc <= 0.1
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

//global inf subdist_agro_sum subdist_transportadmin_sum share_roads
global inf arg_per_1000 adm_per_1000 share_roads share_rails share_pubtn //
global con area num nearest_urban_proximity
global edu primaryschool_per_100 midschool_per_1000 ///
			highschool_per_1000 sscschool_per_1000 
//global edu availability_of_primary_school availability_of_middle_school ///
//		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
//global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global med phc_per_1000 aanganwadi_per_100_reg veter_per_1000
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
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
label var subdist_population "Subdistrict Population"
label var area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"

reg wcv med_per_1000 edu_per_1000 $inf $con i.dist,robust

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "2020cat_t_data.csv", clear


keep if theil >0
keep if num >2
//keep if dist_ntl_pc <= 0.1
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

//global inf subdist_agro_sum subdist_transportadmin_sum share_roads
global inf arg_per_1000 adm_per_1000 share_roads share_rails share_pubtn //
global con area num nearest_urban_proximity
global edu primaryschool_per_100 midschool_per_1000 ///
			highschool_per_1000 sscschool_per_1000 
//global edu availability_of_primary_school availability_of_middle_school ///
//		   availability_of_high_school availability_of_ssc_school ///
//		   availability_of_govt_degree_coll
//global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global med phc_per_1000 aanganwadi_per_100_reg veter_per_1000
global qos st_ratio is_primary_school_with_electrici ///
		   primary_school_toilet is_primary_school_with_computer_ ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_
		   
label var num "Number of Villages"
label var primaryschool_per_100 "Primary Schools per 100 students"
label var midschool_per_1000 "Middle Schools per 1000 people"
label var highschool_per_1000 "High Schools per 1000 people"
label var sscschool_per_1000 "SSC Schools per 1000 people"
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
label var subdist_population "Subdistrict Population"
label var area "Subdistrict Area"
label var nearest_urban_proximity "Average Distance to Urban Centre"

//keep if theil < 
reg theil med_per_1000 edu_per_1000 $inf $con i.dist,robust

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
	
log close
