*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
clear all
capture log close
set more off
pause on
#delimit ;
cd "/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/ma2020/" ; // home folder
#delimit cr
log using "test.log", replace

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
******************************************************* ALL INDIA ***************************************************************************************
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "ma_ntl_data.csv", clear

encode district_name, gen (dist)
encode state_name, gen (states)

gen lnavg_ntl = ln(avg_ntl)
gen lntotalhousehold =ln(total_hhd) 
gen lntotalpop =ln(total_population) 

gen agroshare = total_hhd_engaged_in_farm_activi/total_hhd
gen bpl = total_hhd_having_bpl_cards/total_hhd

label var avg_ntl "Average Radiance"
label var lnavg_ntl "log(Average Radiance)"
label var lntotalpop "log(Population)"
label var transportadmin "Transport/Admin Facilities"
label var edu "Educational Facilities"
label var med "Medical Facilities"
label var road "Availability of Rural Roads"
label var agro "Agricultural Facilities"
label var area_sq_km "Village Area (in sq. km)"
label var agroshare "Share of households in Agriculture"
label var bpl "Share of households BPL"

levelsof state_name, local(states_list)

// destring avg_ntl, replace

reg lnavg_ntl transportadmin edu med road agro															, robust
	est store a1
	estadd local fe No
reg lnavg_ntl transportadmin edu med road agro 													i.states, robust
	est store a2
	estadd local fe Yes
reg lnavg_ntl transportadmin edu med road agro nearest_urban_proximity lntotalpop area_sq_km			, robust
	est store a3
reg lnavg_ntl transportadmin edu med road agro nearest_urban_proximity lntotalpop area_sq_km 	i.states, robust
	est store a4
	estadd local fe Yes
reg lnavg_ntl transportadmin edu med road agro nearest_urban_proximity lntotalpop area_sq_km ///
																				  agroshare bpl i.states, robust
	est store a5
	estadd local fe Yes
	
esttab a1 a2 a4 a5 using "table_1_IN.tex", replace ///
	keep(transportadmin edu med ///
			road agro lntotalpop area_sq_km agroshare bpl _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe N, fmt(%9.4f %9.0f %9.0fc) ///
	labels("R-squared" "State FEs" "Number of observations")) ///
	plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
******************************************************* States ******************************************************************************************
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "ma_ntl_data.csv", clear

encode district_name, gen (dist)
encode state_name, gen (states)

gen lnavg_ntl = ln(avg_ntl)
gen lntotalhousehold =ln(total_hhd) 
gen lntotalpop =ln(total_population) 

gen agroshare = total_hhd_engaged_in_farm_activi/total_hhd
gen bpl = total_hhd_having_bpl_cards/total_hhd

label var avg_ntl "Average Radiance"
label var lnavg_ntl "log(Average Radiance)"
label var lntotalpop "log(Population)"
label var transportadmin "Transport/Admin Facilities"
label var edu "Educational Facilities"
label var med "Medical Facilities"
label var road "Availability of Rural Roads"
label var agro "Agricultural Facilities"
label var area_sq_km "Village Area (in sq. km)"
label var agroshare "Share of households in Agriculture"
label var bpl "Share of households BPL"

keep if state_name == "WEST BENGAL"
reg lnavg_ntl transportadmin edu med road agro nearest_urban_proximity lntotalpop area_sq_km ///
																				  agroshare bpl i.dist, robust
	est store b1
	estadd local fe Yes

esttab b1 using "state_WB.csv", replace ///
	keep(transportadmin edu med ///
			road agro lntotalpop area_sq_km agroshare bpl _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe N, fmt(%9.4f %9.0f %9.0fc) ///
	labels("R-squared" "State FEs" "Number of observations")) ///
	plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 


*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "ma_ntl_data_test.csv", clear

encode district, gen (dist)
encode state, gen (states)


gen lnavg_rad_2sd = ln(average_2sd)
gen lnavg_rad_20per = ln(average_20perncetile)
gen lntotalhousehold =ln(totalhousehold) 
gen lntotalpop =ln(totalpopulation) 



reg lnavg_rad_2sd transportadmin education medical roads agro, robust
reg lnavg_rad_2sd transportadmin education medical roads agro lntotalpop, robust
reg lnavg_rad_2sd transportadmin education medical roads agro lntotalpop i.states, robust

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
******************************************************* Gini ********************************************************************************************
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "2020data.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum									, robust
	est store a1
	estadd local fe No
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum 								i.states, robust
	est store a2
	estadd local fe No
	estadd local sfe Yes
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum subdist_population subdist_area num, robust
	est store a3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum subdist_population subdist_area num i.states, robust
	est store a4
	estadd local fe Yes
	estadd local sfe Yes
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum subdist_population subdist_area num i.dist, robust
	est store a5
	estadd local fe Yes
	estadd local sfe District	

esttab a1 a2 a3 a4 a5 using "table_3_IN.tex", replace ///
	keep(subdist_agro_sum subdist_med_sum ///
			subdist_edu_sum subdist_transportadmin_sum subdist_population subdist_area num _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "2020distdata.csv", clear

encode state, gen (states)

reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum									, robust
	est store b1
	estadd local fe No
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum 								i.states, robust
	est store b2
	estadd local fe No
	estadd local sfe Yes
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum dist_population subdist_area num, robust
	est store b3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum dist_population subdist_area num i.states, robust
	est store b4
	estadd local fe Yes
	estadd local sfe Yes
	
esttab b1 b2 b3 b4 using "table_4_IN.tex", replace ///
	keep(subdist_agro_sum subdist_med_sum ///
			subdist_edu_sum subdist_transportadmin_sum dist_population subdist_area num _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 


*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
cls
clear all
import delimited "2020catdata.csv", clear

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

//keep if state != "GOA"
//keep if state != "ANDAMAN AND NICOBAR ISLANDS"

global inf subdist_agro_sum subdist_transportadmin_sum villages_road 
global con subdist_population subdist_area num nearest_urban_proximity
global edu2 primaryschool_per_100 midschool_per_1000 ///
			highschool_per_1000 sscschool_per_1000 
global edu availability_of_primary_school availability_of_middle_school ///
		   availability_of_high_school availability_of_ssc_school ///
		   availability_of_govt_degree_coll
//global med availability_of_phc_chc is_aanganwadi_centre_available is_veterinary_hospital_available 
global med phc_per_1000 aanganwadi_per_100_reg is_veterinary_hospital_available
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
label var farm "Share of Households in agriculture"

reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
//reg alesina med_per_1000 subdist_edu_sum $inf $con i.dist,robust
	est store a5
	estadd local fe Yes
	estadd local sfe District	

reg alesina subdist_med_sum subdist_edu_sum $inf ,robust
//reg alesina subdist_med_sum subdist_edu_sum $inf ,robust
	est store a1
	estadd local fe No
	estadd local sfe No

reg alesina subdist_med_sum subdist_edu_sum $inf i.states,robust
	est store a2
	estadd local fe No
	estadd local sfe State
	
reg alesina subdist_med_sum subdist_edu_sum $inf $con ,robust
//reg alesina subdist_med_sum subdist_edu_sum $inf $con ,robust
	est store a3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina subdist_med_sum subdist_edu_sum $inf $con i.states,robust
	est store a4
	estadd local fe Yes
	estadd local sfe State

reg alesina subdist_med_sum subdist_edu_sum $inf $con i.dist,robust
//reg alesina med_per_1000 subdist_edu_sum $inf $con i.dist,robust
//	est store a5
//	estadd local fe Yes
//	estadd local sfe District	
	
reg alesina subdist_med_sum $edu $inf $con  i.dist,robust
//reg alesina subdist_med_sum $edu $inf $con i.dist,robust
	est store a6
	estadd local fe Yes
	estadd local sfe District	
	
//reg alesina $med2 subdist_edu_sum $inf $con i.dist,robust
reg alesina $med subdist_edu_sum $inf $con i.dist,robust
	est store a7
	estadd local fe Yes
	estadd local sfe District
/*	
reg alesina subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum													, robust	

reg alesina subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum subdist_population subdist_area num 				, robust	

reg alesina subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum										i.states	, robust
		
reg alesina subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum subdist_population subdist_area num i.dist		, robust	
*/
esttab a1 a2 a3 a4 a5 a6 a7 using "table_3a_IN.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
/*	
reg alesina subdist_agro_sum subdist_med_sum ///
	is_primary_school_with_electrici primary_school_toilet ///
	is_primary_school_have_drinking_ availability_of_mid_day_meal_sch  ///
	is_primary_school_with_playgroun is_primary_school_with_computer_ ///
	availability_of_middle_school availability_of_high_school ///
	availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist		, robust
*/
***************
**Zonal Level**
***************

reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist if region == "north",robust
	est store n1
	estadd local fe Yes
	estadd local sfe District	

reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist if region == "south",robust
reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist if region == "west",robust
reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist if region == "east",robust	
reg alesina med_per_1000 primaryschool_per_100 $inf $con i.dist if region == "central",robust



***************
**State Level**
***************

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

esttab ap3 ap1 ap2 ts3 ts1 ts2 a6 a7 using "table_3a_1.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab tn3 tn1 tn2 kl3 kl1 kl2 a6 a7 using "table_3a_2.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab ka3 ka1 ka2 mh3 mh1 mh2 a6 a7 using "table_3a_3.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
		
esttab as3 as1 as2 tr3 tr1 tr2 a6 a7 using "table_3a_4.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	

esttab wb3 wb1 wb2 or3 or1 or2 a6 a7 using "table_3a_5.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 
	
esttab ch3 ch1 ch2 mp3 mp1 mp2 a6 a7 using "table_3a_6.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab jh3 jh1 jh2 bh3 bh1 bh2 a6 a7 using "table_3a_7.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab uk3 uk1 uk2 up3 up1 up2 a6 a7 using "table_3a_8.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
esttab pb3 pb1 pb2 hr3 hr1 hr2 a6 a7 using "table_3a_9.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant)	

esttab gj3 gj1 gj2 rj3 rj1 rj2 a6 a7 using "table_3a_10.tex", replace ///
	keep(subdist_edu_sum subdist_med_sum ///
			$inf $con $edu $med _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

**********************
**Quality of Schools**
**********************


replace str = "." if str == ""
replace str = "." if str == "inf"
destring str, generate(st_ratio)



reg alesina subdist_med_sum $qos $inf $con i.dist,robust

reg alesina subdist_med_sum str_ratio is_primary_school_with_electrici ///
		   primary_school_toilet  ///
		   is_primary_school_with_playgroun ///
		   availability_of_mid_day_meal_sch is_primary_school_have_drinking_ ///
		   $inf $con i.dist,robust



	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "2020cat_t_data.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg theil subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist, robust
	est store a1
	estadd local fe Yes
	estadd local sfe District
	
reg theil subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist, robust
	est store a2
	estadd local fe Yes
	estadd local sfe District
	
reg theil subdist_agro_sum availability_of_phc_chc availability_of_jan_aushadhi_ken ///
	is_aanganwadi_centre_available ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist, robust	
	est store a3
	estadd local fe Yes
	estadd local sfe District

esttab a1 a2 a3 using "table_3atheil_IN.tex", replace ///
	keep(subdist_agro_sum subdist_med_sum ///
			subdist_edu_sum subdist_transportadmin_sum villages_road ///
			availability_of_primary_school availability_of_middle_school ///
			availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
			availability_of_phc_chc availability_of_jan_aushadhi_ken is_aanganwadi_centre_available ///
			subdist_population subdist_area num _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 	
/*	
reg theil subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum	villages_road									, robust	

reg theil subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum villages_road subdist_population subdist_area num, robust	
*/

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "2020cat_w_data.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg wcv subdist_agro_sum_x subdist_med_sum_x ///
	subdist_edu_sum_x subdist_transportadmin_sum_x subdist_population subdist_area_x num i.dist, robust
	est store a1
	estadd local fe Yes
	estadd local sfe District	

reg wcv subdist_agro_sum_x subdist_med_sum_x ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum_x villages_road_x subdist_population subdist_area_x num i.dist, robust
	est store a2
	estadd local fe Yes
	estadd local sfe District
	
reg wcv subdist_agro_sum_x availability_of_phc_chc availability_of_jan_aushadhi_ken ///
	is_aanganwadi_centre_available ///
	subdist_edu_sum_x subdist_transportadmin_sum_x villages_road_x subdist_population subdist_area_x num i.dist, robust	
	est store a3
	estadd local fe Yes
	estadd local sfe District

esttab a1 a2 a3 using "table_3awcv_IN.tex", replace ///
	keep(subdist_agro_sum_x subdist_med_sum_x ///
			subdist_edu_sum_x subdist_transportadmin_sum_x villages_road_x ///
			availability_of_primary_school availability_of_middle_school ///
			availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
			availability_of_phc_chc availability_of_jan_aushadhi_ken is_aanganwadi_centre_available ///
			subdist_population subdist_area_x num _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
	
log close 
