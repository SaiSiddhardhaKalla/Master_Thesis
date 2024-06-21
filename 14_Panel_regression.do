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
cls
clear all

//import delimited "Panel.csv", clear // This is main file
import delimited "Panel_Raw.csv", clear // This is main file
//import delimited "Panel_Clean.csv", clear // This is main file


set matsize 8000

keep if alesina >0
keep if num>2
//drop if year==2017

global inf share_roads share_pubtn  adm_per_1000 
global con num subdistrictarea nearest_town_distance
global edu p_sch_per_1000 m_sch_per_1000 h_sch_per_1000 ///
		ssc_sch_per_1000 iti_per_1000
global med phc_per_1000 mcwc_per_1000 vet_per_1000 aanganwadi_per_1000

gen edu2 = p_school + m_school + h_school + ssc_school + iti
gen med2 = phc + aanganwadi + veterinary_hospital
gen adm2 = cooperative_bank + mandis + post_office

gen edu2_per1000 = edu2/no_1000s
gen med2_per1000 = med2/no_1000s
gen adm2_per1000 = adm2/no_1000s

encode district, gen (dist)
encode unique_id, gen (subdist)
encode state, gen (states)

reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if year==2020,robust 
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist if year==2011,robust
reg alesina med_per_1000 edu_per_1000 $inf $con i.dist i.year,robust

reg alesina edu med adm share_roads share_pubtn $con i.dist if year==2020, robust
reg alesina edu med adm share_roads share_pubtn $con i.dist if year==2011, robust
reg alesina edu med adm share_roads share_pubtn $con i.dist i.year, robust

xtset subdist year
xtreg alesina med edu adm share_roads share_pubtn population $con i.year, fe
xtreg alesina med_per_1000 edu_per_1000 $inf $con i.year, fe


xtreg alesina phc mcwc aanganwadi  veterinary_hospital edu adm share_roads share_pubtn population i.year, fe
xtreg alesina $med edu_per_1000 $inf $con i.year, fe

xtreg alesina med p_school m_school h_school ssc_school iti adm share_roads share_pubtn population i.year, fe
xtreg alesina med_per_1000 $edu $inf $con i.year, fe




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
			
			




