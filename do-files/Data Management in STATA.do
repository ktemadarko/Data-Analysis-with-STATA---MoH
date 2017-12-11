//////////////////////////////////////////////////////////////
************************************************************/
//https://github.com/eolamijuwon/MoH-advanced-data-analysis/
*******BASIC DATA MANAGEMENT IN STATA
cd "K:\STATA\MoH-advanced-data-analysis\datasets\"
****Remember to SET MORE OFF
	set more off
	************
//Reading Dates into STATA
	**Begin by importing/opening a STATA data file
	//Remember that import is different from open
	*HINT: Open - a STATA data. *Import - a data from another source e.g excel spreadsheet
	import delimited "PMTCT_CMIS.csv", varnames(1) clear
	browse //Browse the dataset to note data structure
	*All date related variables including Date of birth, dateofvist, ancstartdate and hivdiagnosed date are string
	***Remember variable types? 
	
	//Generate a new dateofbirth, note that the existing is structured as MDY
	generate dob_pmtct= date(dateofbirth_pmtct, "MDY") //genereate a new date of birth
	format dob_pmtct %td //format as a date.
	****************************
	//Repeat this process for others.
	generate ancstartdate_pmtct= date(ancstart_pmtct, "MDY") //genereate a new date of ANC Start
	format ancstartdate_pmtct %td //format as a date. ***ancstrt_pmtct

	generate hivdiagn_pmtct= date(hivdiagnosisdate_pmtct, "MDY") //genereate a new date of HIV diagnosis
	format hivdiagn_pmtct %td //format as a date.

	generate dov_pmtct= date(dateofvisit_pmtct, "MDY") //genereate a new date of visit
	format dov_pmtct %td //format as a date.
	drop dateofbirth_pmtct dateofvisit_pmtct hivdiagnosisdate_pmtct ancstart_pmtct //drop the previous date of birth variable
save "PMTCT_CMIS"
	clear

//Creating and REcoding Variables
use "DHS_wm.dta"
	tabulate v012 //Tabulate Age
	//Recode age into 10 years age groups 15-24
	recode v012 (15/24=0 "15-24") (25/34=1 "25-34") (35/44=2 "35-44") (45/49=3 "45-49"), gen(age_group)
	tabulate age_group
	tabulate age_group,nolabel
	
	//An Alternative
	recode v012 (15/24=1) (25/34=2) (35/44=3) (45/49=4), gen(age_grp)
	tabulate age_grp //Does this make sense?
	**These are assigned values, provide labels for better understanding.
	label define age_grplab 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-49"
	label values age_grp age_grplab
	tabulate age_grp //Does this make sense?
	
	//An alternative way of creating variables
	tabulate v130 
	**Combine all Christian denominations into one group, muslim into another
	******Traditional into another and those with none into another such that
	************************we have four (4) categories
	describe v130 //Note that variable is a byte, meaning that each category 
	******************************has a label which can be recoded.
	tabulate v130, nolabel //nolabel
	tabulate v130 //with label
	gen religion=.
	replace religion=1 if v130==2|v130==3|v130==4|v130==5|v130==6|v130==7
	replace religion=2 if v130==8
	replace religion=3 if v130==1|v130==96
	replace religion=4 if v130==9
	tabulate religion
		**Assign labels to each value
		label define religion 1 "Christian" 2 "Muslim" 3 "Others" 4 "None"
		label values religion religion
		tabulate religion

***LET'S WORK WITH ANOTHER DATASET
use "PMTCT_CMIS.dta", clear
	*****Use the codes above to re-create the date variables
	***************************************
	tab1 dob_pmtct dov_pmtct hivdiagn_pmtct ancstrt_pmtct
	
	*Start Over
		generate age_anc=int((ancstartdate_pmtct-dob_pmtct)/365.5) //Starting with the most recent (ANC Start).
		ta age_anc //Does this make any sense? Any quality issue that needs to be explained?
	|
		**For all Inaccurate age - replace to missing
		replace age_anc=. if age_anc<15|age_anc>49
		ta age_anc //Does this make any sense NOW?
		ta age_anc,missing //Do you see the dot (.)?

//LABELLING VARIABLES
***Apparently, our data is not nicely looking yet.
****Provide a summary description of each variable
label variable pid "Patient's Unique Identifier" 
//Note how this is different from label values or label define
label variable sex_pmtct "Sex"
label variable facilityname_pmtct "Facility Name"
label variable region_pmtct "Reigion"
label variable dob_pmtct "Date of Birth"


save, replace

/*SUBSETTING VARIABLES
use "DHS_wm.dta", clear
****Often times, we get a really huge dataset with soo much
**variables when in actual fact we only need a few variables
****An example is a DHS survey - Often referred to as Multiple purpose
***DROP* AND *KEEP* are very useful commands in this case
*-DROP-drops
*-KEEP-keeps
drop b4_17 b5_01 b5_04 b10_16 b10_17 b10_18 b10_19 b10_20 b11_01 ///
b11_02 b11_03 b11_04 b11_05 b11_06 b11_07 b11_08 b11_09 b11_10 ///
	b11_11 b11_12 b11_13 b11_14 b11_15 b11_16 b11_17 b11_18 ///
		b11_19 b11_20 b12_01 b12_02 b12_03 b12_04 b12_05 ///
		b12_06 b12_07 b12_08 b12_09 b12_10 b12_11 ///
		b12_12 b12_13 b12_14 b12_15 b12_16 b12_17 ///
		b12_18 b12_19 b12_20 b15_01 b15_02 b15_03 ///
		b15_04 b15_05 b15_06 b15_07 b15_08 b15_09 ///
		b15_10 b15_11 b15_12 b15_13 b15_14 b15_15 ///
	b15_16 b15_17 b15_18 b15_19 b15_20 b16_01 ///
b16_02 b16_03 b16_04 b16_05 b16_06 b16_07 ///
b16_08 b16_09 b16_10 b16_11 b16_12 b16_13 ///
b16_14 b16_15 b16_16 b16_17 b16_18 b16_19 ///
	b16_20 v201 v202 v203 v204 v205 v206 ///
		v207 v208 v209 v210 v211 v212 v213 ///
****Take note of the difference between /// and //
keep caseid v000 v001 v002 v003 v004 v005 v012 v013 v024
****************
*******DISCUSS******
//What is different?


//SUBSETTING VARIABLES
import delimited "PMTCT_CMIS.txt", varnames(1) clear*/
	****RERUN THE PREVIOUS COMMANDS FOR PMTCT
	tabulate region_pmtct //Note the number of Women in each region
	tabulate age_anc if region_pmtct=="HHOHHO"
	//Understand why we use "HHOHHO" instead of actual label values?
	tabulate region_pmtct if age_anc>30 //Tabulate region if age is greater than 30
	tabulate region_pmtct if age_anc>30&age_anc<50 //Tabulate region if age is between 30-50
	tabulate age_anc if (age_anc>30&age_anc<50)&(region_pmtct=="HHOHHO"|region_pmtct=="LUBOMBO")
		//Tabulate region if age is between 30-50 and region is HHOHHO or LUBOMBO
	tabulate age_anc if dov_pmtct>d(01sep2016)&(region_pmtct=="HHOHHO"|region_pmtct=="LUBOMBO")
		//Tabulate age at ANC if date of visit was after 01 Sep 2016 and region is HHOHHO or LUBOMBO
	tab region age if
	****SUGGEST MORE INTERESTING SUBSETTING OPTIONS
	
	bysort region_pmtct: tab facilityname_pmtct
	bysort region_pmtct: tab facilityname_pmtct if (age_anc>30&age_anc<50)
	bysort region_pmtct: tab facilityname_pmtct if dov_pmtct>d(01sep2016)
	
****EXCERCISES - 
	*GENERATE A NEW VARIABLE - AGE AT HIV DIAGNOSIS
	*RECODE THE AGE AT DIAGNOSIS INTO 5 YEARS AGE GROUP AND PROVIDE LABELS
	*{GROUP 1} CROSS-TABULATE AGE GROUP WITH REGION FOR WOMEN WHO ATTENDED ANC SINCE 01 JANUARY 2017
	*{GROUP 2} CROSS-TABULATE AGE GROUP WITH REGION FOR WOMEN WHO ATTENDED ANC BETWEEN JANUARY-SEPTEMBER 2017
	*{GROUP 3} TABULATE AGE GROUP WITH REGION FOR WOMEN WHO WERE DIAGNOSED BEFORE 01 JULY 2017
	*{GROUP 4} TABULATE REGION FOR WOMEN WHO WERE BORN AFTER 01 JANUARY 1980 AND STARTED ANC BETWEEN 01 SEP 2016 - 31 OCT 2017
	*{GROUP 5} CROSS-TABULATE REGION WITH AGE GROUP FOR WOMEN BETWEEN 20-34 YEARS AND DIAGNOSED IN 01-30 SEP 2016 OR 01-31 OCT 2017
	************************ALL AGE GROUPS IN THE ABOVE REFERS TO AGE GROUP AT DIAGNOSIS NOT NECESSARILLY THEIR CURRENT AGE
******
 gen hivdiag_month=month(hivdiagn_pmtct)
  gen hivdiag_year=year(hivdiagn_pmtct)

	*CREATE A NEW VARIABLE DIAGNOSIS STATUS - 1 "NOT DIAGNOSED" 2 "DIAGNOSED
	*****HINT - THOSE NOT DIAGNOSED ARE MISSING
	*{GROUP 1} PROVIDE THE PERCENTAGE OF ANC WOMEN 20-34 YEARS WHO WERE NOT DIAGNOSED.
	*{GROUP 2} HOW MANY PREGNANT WOMEN 15-24 YEARS WERE DIAGNOSED IN 2017?
	*{GROUP 3} HOW MANY PREGNANT WOMEN IN HHOHHO REGION WERE NOT DIAGNOSED?
	*{GROUP 4} HOW MANY PREGNANT WOMEN IN THE REGIONS EXCLUDING HHOHHO WERE DIAGNOSED BEFORE 2017
	*{GROUP 5} HOW MANY OF THE WOMEN WHO STARTED ANC BETWEEN SEP 2016 - OCTOBER 2017 WERE NOT DIAGNOSED
	
*****PROVIDE ANALYSIS RESULTS IN THE SPREADSHEET PROVIDED IN THE LINK BELOW
***https://docs.google.com/spreadsheets/d/1z9pILqPlqIFolo9LMNd4Pzfwa5wsrLN65N0mHLKyJJY/edit?usp=sharing
loc url https://docs.google.com/spreadsheets/d/1z9pILqPlqIFolo9LMNd4Pzfwa5wsrLN65N0mHLKyJJY/edit?usp=sharing
if c(os)=="MacOSX" {
    !open `url'
}
else if c(os)=="Unix" {
    // requires xdg-utils
    !xdg-open `url'
}
else if c(os)=="Windows" {
    !cmd /c start `url'
}
//	
****ALSO REMEMBER TO SAVE YOUR COMMANDS IN A DO-FILE AND LOG OUTPUTS
log using "K:\Traininh\Data Management in STATA.log", replace //Rmba to change file names
log close
****
****END
****		
