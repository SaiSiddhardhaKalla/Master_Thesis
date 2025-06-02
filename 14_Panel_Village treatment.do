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
import delimited "Panel_Village.csv", clear

label var num "Number of Villages"
label var all_weather_road "Share of Villages with Roads"
label var railway "Share of Villages with Railway"
label var bus "Share of Villages with Public Transport"
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
label var period "2020"

		 
keep if alesina >0


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


global inf all_weather_road bus railway
global con num village_area_sqkm nearest_town_distance sc_pop_share st_pop_share //
global med phc mcwc veterinary_hospital aanganwadi
global edu p_school m_school h_school ssc_school iti


gen edu2 = p_school + m_school + h_school + ssc_school + iti
gen med2 = phc + aanganwadi + veterinary_hospital + dispensary
gen adm2 = cooperative_bank + mandis + post_office

label var med2 "Medical Facilities"


//encode district, gen (dist)
encode unique_id, gen (subdist)
//encode unique_dist_id, gen (dist)
encode district, gen(dist)
encode state, gen (states)


gen reg = 0
replace reg = 1 if region=="A"
label var reg "Region"

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************

/*
					
// Pooled OLS	
reg alesina med edu adm $inf population $con i.year ///
			i.dist, robust
	est store pols2
	estadd local fe Yes
reg alesina med edu adm $inf population $con i.year ///
			i.dist if inlist(zone, "South", "West"), robust
	est store pols2sw
	estadd local fe Yes
reg alesina med edu adm $inf population $con i.year ///
			i.dist if inlist(zone, "North", "East","Central"), robust
	est store pols2ne
	estadd local fe Yes
esttab pols2 pols2sw pols2ne using "vil_treat_pols2.tex", replace /// a6 a7
    keep(edu med adm $inf ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.4f) se(%9.4f) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
*/
	
*****************************************************************
*****************************************************************
*************************** Panel *******************************
*****************************************************************
*****************************************************************

xtset vil_code year
xtdescribe

xi: xtreg alesina med edu adm $inf population $con i.year ///
			, fe vce(cluster subdist)
	est store s1
	estadd local fe Yes
xi: xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store s2
	estadd local fe Yes
xi: xtreg alesina med edu adm $inf population $con i.year ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store s3
	estadd local fe Yes
	
* Combine all the stored results into one LaTeX file
esttab s1 s2 s3 using "vil_treat_panel_stock.tex", replace /// a6 a7
    keep(edu med adm $inf population ///
         $con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.4e) se(%9.4e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)

*****************************************************************
*****************************************************************
**************************** DID ********************************
*****************************************************************
*****************************************************************

xtreg alesina i.treated##i.period med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store t1
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "South", "West"), fe vce(cluster subdist)
	est store t2
	estadd local fe Yes
xtreg alesina i.treated##i.period med2 edu adm $inf population $con ///
			if inlist(zone, "Central", "East", "North"), fe vce(cluster subdist)
	est store t3
	estadd local fe Yes
	
esttab t1 t2 t3 using "vil_treat_DiD_binary.tex", replace /// a6 a7
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	


xtreg alesina i.treated##i.period##i.reg med2 edu adm $inf population $con, ///
			fe vce(cluster subdist)
	est store d1
	estadd local fe Yes
esttab d1 using "vil_treat_3DiD_binary.tex", replace /// a6 a7
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)	


*****************************************************************
*****************************************************************
*************************** Change ******************************
*****************************************************************
*****************************************************************
		

cls
clear all
import delimited "Panel_Viltreat_change.csv", clear // 

set matsize 8000

label var num_change "Number of Villages"

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

global con bus_change railway_change all_weather_road_change ///
			nearest_town_distance_change village_area_sqkm ///
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
	
esttab c1 c2 c3 using "change_viltreat_stock.tex", replace /// a6 a7
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
esttab m1 m2 m3 using "change_viltreat_medstock.tex", replace /// a6 a7
    keep($med edu_change adm_change ///
	$con _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) collabels(none) ///
    label stats(r2 fe N, fmt(%9.3f %9.0f %9.0fc) ///
    labels("R-squared" "Fixed Effects" "Number of observations")) ///
    plain b(%9.3e) se(%9.3e) se nonumbers lines parentheses fragment ///
    varlabels(_cons Constant)
*****************************************************************
*****************************************************************












log close




