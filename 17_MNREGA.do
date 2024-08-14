*********************************************************************************************************************************************************
cls
clear all
capture log close
set more off
pause on
#delimit ;
cd "/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/ma2020/" ; // home folder
#delimit cr
log using "011_Panel_treatments.log", replace
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "NREGA_test_block.csv", clear
//import delimited "NREGA_test_sub.csv", clear



label var all_weather_road "Share of Villages with Roads"
label var railway "Share of Villages with Railway"
label var bus "Share of Villages with Public Transport"
label var population "Population"
//label var med "Medical Facilities"
//label var edu "Educational Facilities"
//label var adm "Administrative Facilities"

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

//label var sc_pop_share "Share of SC Population"
//label var st_pop_share "Share of ST Population"
label var treated "Treatment"
label var period "2020"

gen zone = ""
replace zone = "South" if state == "Andhra Pradesh"
replace zone = "East" if state == "Assam"
replace zone = "East" if state == "Bihar"
replace zone = "Central" if state == "Chhattisgarh"
replace zone = "West" if state == "Goa"
replace zone = "West" if state == "Gujarat"
replace zone = "North" if state == "Haryana"
replace zone = "East" if state == "Jharkhand"
replace zone = "South" if state == "Karnataka"
replace zone = "South" if state == "Kerala"
replace zone = "Central" if state == "Madhya Pradesh"
replace zone = "West" if state == "Maharashtra"
replace zone = "East" if state == "Odisha"
replace zone = "North" if state == "Punjab"
replace zone = "North" if state == "Rajasthan"
replace zone = "South" if state == "Tamil Nadu"
replace zone = "South" if state == "Telangana"
replace zone = "East" if state == "Tripura"
replace zone = "Central" if state == "Uttar Pradesh"
replace zone = "Central" if state == "Uttarakhand"
replace zone = "East" if state == "West Bengal"

global inf all_weather_road bus railway
global con village_area_sqkm nearest_town_distance //sc_pop_share st_pop_share //
global med phc mcwc veterinary_hospital aanganwadi
global adm cooperative_bank mandis post_office
global edu p_school m_school h_school ssc_school iti
global med2 phc aanganwadi veterinary_hospital


encode district, gen(dist)
encode state, gen (states)
encode block, gen(dev_block)
encode unique_id, gen (blk)


gen reg = 0
replace reg = 1 if region=="A"
label var reg "Region"

gen womenshare = active_workers_women/total_active_workers
gen regwomen = registered_workers_women/total_registered_workers

gen int_term = treated*period

*****************************************************************
*****************************************************************
/*
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist, robust
	est store pols2
	estadd local fe Yes
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist if inlist(zone, "South", "West"), robust
	est store pols2sw
	estadd local fe Yes
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist if inlist(zone, "North", "East","Central"), robust
	est store pols2ne
	estadd local fe Yes
*/	
*****************************************************************
*****************************************************************
	
xtset block_lgd year	

xtreg womenshare $med $edu $adm $inf population $con i.year ///
			, fe vce(cluster dev_block)
xtreg womenshare $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
xtreg womenshare $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)

*****************************************************************
*****************************************************************

xtreg womenshare i.treated##i.period, fe vce(cluster dev_block)

//reghdfe womenshare int_term absorb (district year) group (dev_block)

xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con, ///
			fe vce(cluster dev_block)
	est store t1
	estadd local fe Yes
xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
	est store t2
	estadd local fe Yes
xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
	est store t3
	estadd local fe Yes
	
xtreg womenshare i.treated##i.period##i.reg $med2 $edu $adm $inf population $con ///
			, fe vce(cluster dev_block)
			
*****************************************************************
*****************************************************************

xtreg regwomen $med $edu $adm $inf population $con i.year ///
			, fe vce(cluster dev_block)
xtreg regwomen $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)			
xtreg regwomen $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
			
			
xtreg regwomen i.treated##i.period, fe vce(cluster dev_block)
	
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con, ///
			fe vce(cluster dev_block)
	est store t1
	estadd local fe Yes
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
	est store t2
	estadd local fe Yes
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
	est store t3
	estadd local fe Yes


	est store d2
	estadd local fe Yes
esttab d2 using "DiD_3DDDDD.tex", replace /// a6 a7
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	

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
log using "011_Panel_treatments.log", replace
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

cls
clear all
import delimited "NREGA_test_gp.csv", clear



label var all_weather_road "Share of Villages with Roads"
label var railway "Share of Villages with Railway"
label var bus "Share of Villages with Public Transport"
label var population "Population"
//label var med "Medical Facilities"
//label var edu "Educational Facilities"
//label var adm "Administrative Facilities"

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

//label var sc_pop_share "Share of SC Population"
//label var st_pop_share "Share of ST Population"
label var treated "Treatment"
label var period "2020"

gen zone = ""
replace zone = "South" if state == "Andhra Pradesh"
replace zone = "East" if state == "Assam"
replace zone = "East" if state == "Bihar"
replace zone = "Central" if state == "Chhattisgarh"
replace zone = "West" if state == "Goa"
replace zone = "West" if state == "Gujarat"
replace zone = "North" if state == "Haryana"
replace zone = "East" if state == "Jharkhand"
replace zone = "South" if state == "Karnataka"
replace zone = "South" if state == "Kerala"
replace zone = "Central" if state == "Madhya Pradesh"
replace zone = "West" if state == "Maharashtra"
replace zone = "East" if state == "Odisha"
replace zone = "North" if state == "Punjab"
replace zone = "North" if state == "Rajasthan"
replace zone = "South" if state == "Tamil Nadu"
replace zone = "South" if state == "Telangana"
replace zone = "East" if state == "Tripura"
replace zone = "Central" if state == "Uttar Pradesh"
replace zone = "Central" if state == "Uttarakhand"
replace zone = "East" if state == "West Bengal"

global inf all_weather_road bus railway
global con village_area_sqkm nearest_town_distance //sc_pop_share st_pop_share //
global med phc mcwc veterinary_hospital aanganwadi
global adm cooperative_bank mandis post_office
global edu p_school m_school h_school ssc_school iti
global med2 phc aanganwadi veterinary_hospital


encode district, gen(dist)
encode state, gen (states)
encode block, gen(dev_block)
//destring gp, replace
//encode unique_id, gen (blk)


gen reg = 0
replace reg = 1 if region=="A"
label var reg "Region"

gen womenshare = active_workers_women/total_active_workers
gen regwomen = registered_workers_women/total_registered_workers

gen int_term = treated*period

*****************************************************************
*****************************************************************
/*
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist, robust
	est store pols2
	estadd local fe Yes
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist if inlist(zone, "South", "West"), robust
	est store pols2sw
	estadd local fe Yes
reg womenshare $med $edu $adm $inf population $con i.year ///
			i.dist if inlist(zone, "North", "East","Central"), robust
	est store pols2ne
	estadd local fe Yes
*/	
*****************************************************************
*****************************************************************
	
xtset gpcode year	

xtreg womenshare $med $edu $adm $inf population $con i.year ///
			, fe vce(cluster gpcode)
xtreg womenshare $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
xtreg womenshare $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)

*****************************************************************
*****************************************************************

xtreg womenshare i.treated##i.period, fe //vce(cluster dev_block)

//reghdfe womenshare int_term absorb (district year) group (dev_block)

xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con, ///
			fe vce(cluster dev_block)
	est store t1
	estadd local fe Yes
xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
	est store t2
	estadd local fe Yes
xtreg womenshare i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
	est store t3
	estadd local fe Yes
	
xtreg womenshare i.treated##i.period##i.reg $med2 $edu $adm $inf population $con ///
			, fe vce(cluster dev_block)
			
*****************************************************************
*****************************************************************

xtreg regwomen $med $edu $adm $inf population $con i.year ///
			, fe vce(cluster dev_block)
xtreg regwomen $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)			
xtreg regwomen $med $edu $adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
			
			
xtreg regwomen i.treated##i.period, fe vce(cluster dev_block)
	
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con, ///
			fe vce(cluster dev_block)
	est store t1
	estadd local fe Yes
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster dev_block)
	est store t2
	estadd local fe Yes
xtreg regwomen i.treated##i.period $med2 $edu $adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster dev_block)
	est store t3
	estadd local fe Yes


	est store d2
	estadd local fe Yes
esttab d2 using "DiD_3DDDDD.tex", replace /// a6 a7
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)













