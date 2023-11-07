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
	
	
esttab a1 a2 a4 using "table_1_IN.tex", replace ///
	keep(transportadmin edu med ///
			road agro lntotalpop area_sq_km _cons) ///
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

log close 
