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

clear all
import delimited "panel_WCV_2020_full.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg wcv subdist_agro_sum_x subdist_med_sum_x ///
	subdist_edu_sum_x subdist_transportadmin_sum_x subdist_population subdist_area_x num i.dist, robust
	est store a5
	estadd local fe Yess
	estadd local sfe District	

esttab a5 using "table_3aWCV_IN.tex", replace ///
	keep(subdist_agro_sum_x subdist_med_sum_x ///
			subdist_edu_sum_x subdist_transportadmin_sum_x subdist_population subdist_area_x num _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
	label stats(r2 fe sfe N, fmt(%9.6f %9.0f %9.0fc) ///
	labels("R-squared" "Fixed Effects" "State FEs" "Number of observations")) ///
	plain b(%9.6f) se(%9.6f) se nonumbers lines parentheses fragment ///
	varlabels(_cons Constant) 

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

clear all
import delimited "panel_theil_2020.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg theil subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum subdist_population subdist_area num i.dist, robust
	est store a5
	estadd local fe Yes
	estadd local sfe District
	
esttab a5 using "table_3btheil_IN.tex", replace ///
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
import delimited "2020catdata.csv", clear

encode state, gen (states)
encode district, gen (dist)

reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist, robust
	est store a5
	estadd local fe Yes
	estadd local sfe District	

reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road					, robust
	est store a1
	estadd local fe No
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road					i.states, robust
	est store a2
	estadd local fe No
	estadd local sfe Yes
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num, robust
	est store a3
	estadd local fe Yes
	estadd local sfe No
	
reg alesina subdist_agro_sum subdist_med_sum ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num i.states, robust
	est store a4
	estadd local fe Yes
	estadd local sfe State
	
reg alesina subdist_agro_sum subdist_med_sum ///
	availability_of_primary_school availability_of_middle_school ///
	availability_of_high_school availability_of_ssc_school availability_of_govt_degree_coll ///
	subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist		, robust
	est store a6
	estadd local fe Yes
	estadd local sfe District	
	
reg alesina subdist_agro_sum availability_of_phc_chc availability_of_jan_aushadhi_ken ///
	is_aanganwadi_centre_available ///
	subdist_edu_sum subdist_transportadmin_sum villages_road subdist_population subdist_area num i.dist, robust	
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
	
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
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
