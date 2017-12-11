//////////////////////////////////////////////////////////////
************************************************************/
//https://github.com/eolamijuwon/MoH-advanced-data-analysis/
*******BASIC DATA MANAGEMENT IN STATA
cd "K:\STATA\MoH-advanced-data-analysis\datasets\"
****Remember to SET MORE OFF
	set more off
	************
//COMBINING STATA DATA FILES
*Appending vs Merging - How do they differ?
	
	use "DHS_wm.dta", clear
	use "PMTCT_CMIS.dta", clear
	
	**************************
	**Appending Data Files****
	**************************
	clear
	append using "DHS_wm.dta" "PMTCT_CMIS.dta"
	clear
	
	clear
	cd "K:\STATA\DHS\"
	append using "Lesotho 2014" "Malawi 2015-16" "Namibia 2013" "Zimbabwe 2015" "Zambia 2013-14"
	save "Sub-SAfrica", replace
	***Take note of the increase in sample
	
	**************************
	****Merging Data Files****
	**************************
	import excel "HTS_CMIS.xlsx", sheet("Sheet1") firstrow case(lower) clear
	drop determineresult elisaresult dnapcrresult unigoldresult clearviewresult ///
		mostrec_resultsstatus rel_resultsstatus determine elisa dnapcr	referraldate  ///
			unigold clearview mostrectestdate retest ancvisit cwfvisit pepvisit ///
			martenityvisit pncvisit fpvisit tbvisit art preart preartstartdate ///
			relationship rel_testdate rel_testname referredto referralreason htssite ///
			linkeddate dateofvisit entrypoint testname

	generate dob_hts= date(dateofbirth, "YMD") //genereate a new date of HIV diagnosis
	format dob_hts %td //format as a date.

	generate testdte_hts= date(testdate, "YMD") //genereate a new date of HIV diagnosis
	format testdte_hts %td //format as a date.

	generate resultrec_dte_hts= date(testresultsrecievedate, "YMD") //genereate a new date of HIV diagnosis
	format resultrec_dte_hts %td //format as a date.

	generate artstartdte_hts= date(artstartdate, "YMD") //genereate a new date of HIV diagnosis
	format artstartdte_hts %td //format as a date.
	
	gen region_hts=proper(region)
		
	drop dateofbirth testdate testresultsrecievedate artstartdate region
	label var dob_hts "Date of Birth"
	label var testdte_hts "Test Date"
	label var resultrec_dte_hts "Results Recieved Date"
	label var artstartdte_hts "ART Start Date"

	save "HIV Testing Services", replace
merge 1:1 pid using "PMTCT_CMIS.dta"
	
//RESHAPING DATA FROM LONG TO WIDE
	*********************
	duplicates report pid
	browse pid  testdte_hts resultrec_dte_hts artstartdte_hts
	duplicates tag pid, gen(dup)
	
	by pid testdte_hts, sort: generate x = _n
	keep if x==1
	drop x

	duplicates report pid
	
	sort pid dob_hts testdte_hts resultrec_dte_hts artstartdte_hts
	by pid , sort: generate x = _n
	reshape wide sex maritalstatus resultsstatus facilityname region ///
		dob_hts testdte_hts resultrec_dte_hts artstartdte_hts, i(pid) j(x)

	drop sex2 sex3 sex4 sex5 maritalstatus2 maritalstatus3 maritalstatus4 maritalstatus5 ///
		dob_hts2 dob_hts3 dob_hts4 dob_hts5 artstartdte_hts4 artstartdte_hts2 ///
			artstartdte_hts3 artstartdte_hts4 artstartdte_hts5
	
//RESHAPING DATA FROM WIDE TO LONG

	reshape long sex maritalstatus resultsstatus facilityname region ///
		dob_hts testdte_hts resultrec_dte_hts artstartdte_hts, i(pid) j(j)
	
	replace dob_hts=dob_hts[_n-1] if pid==pid[_n-1]&dob_hts==.
	replace maritalstatus=maritalstatus[_n-1] if pid==pid[_n-1]&maritalstatus==""
	replace artstartdte_hts=artstartdte_hts[_n-1] if pid==pid[_n-1]&artstartdte_hts==.
	replace sex=sex[_n-1] if pid==pid[_n-1]&sex==""
	
	format dob_hts %td
	format artstartdte_hts %td

//COLLAPSING DATA ACROSS OBSERVATIONS


//WORKING ACROSS VARIABLES USING foreach.
import excel "HTS_CMIS.xlsx", sheet("Sheet1") firstrow case(lower) clear
	drop determineresult elisaresult dnapcrresult unigoldresult clearviewresult ///
		mostrec_resultsstatus rel_resultsstatus determine elisa dnapcr	referraldate  ///
			unigold clearview mostrectestdate retest ancvisit cwfvisit pepvisit ///
			martenityvisit pncvisit fpvisit tbvisit art preart preartstartdate ///
			relationship rel_testdate rel_testname referredto referralreason htssite ///
			linkeddate dateofvisit testoption entrypoint testname

ds (dateofbirth testdate testresultsrecievedate artstartdate) 
	foreach v of var `r(varlist)' {
		gen `v'_hts= date(`v', "YMD")
		format `v'_hts %td
}
//


****EXERCISE
***Merge both PMTCT and HTS Data
***Prep and manage the data - for completeness
****Analyse and Provide answers for the listed questions.
*1). Of all the women that were tested, how many also had any ANC visit.
*2). How many women attended ANC between 01 Sept 2016 - 30 Sept 2017
*3). Using the testdate in HTS data, how many pregnant women were tested.
*4). Using the testdate in HTS data, how many pregnant women were tested and diagnosed positive.
*5). Using the testdate in HTS data, how many pregnant women recieved their first test result
*6). How many pregnant women recieved their most recent test result.

