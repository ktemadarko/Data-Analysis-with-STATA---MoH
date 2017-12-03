**************
**READING DATA
//Inputting raw data files into STATA

//From variables to datasets - Import data in different formats into Stata
	****The command below imports a microsoft excel saved dataset.
	**import**dataType - excel***location\filename**sheet number** use first row as variable name***all lowercase
	import excel "K:\Traininh\PMTCT_CMIS.xlsx", sheet("Sheet1") firstrow case(lower) clear

	****The command below imports a (comma, tab, space) delimited saved dataset.
	**import**a delimited data***location\filename***use first row as variable name**
	*****For data saved as csv
		import delimited "K:\Traininh\PMTCT_CMIS.csv", varnames(1) clear
	*****For data saved as txt
		import delimited "K:\Traininh\PMTCT_CMIS.txt", varnames(1) clear

//Using and saving STATA data files
	**Save current dataset
		save "PMTCT_new"
		save "PMTCT_new", replace //The replace option instructs STATA to 
	//replace any existing dataset with the same file name with this

	**Open a previously saved dataset
		Use "PMTCT_new" //Take NOTE - STATA is case sensitive
		use "PMTCT_new"
		use "PMTCT_new", clear //The clear option instructs STATA to 
	//clear memory, regardless of whether a dataset is in use.


//From datasets to variables - Export data in Stata into different formats
	****Export a STATA data to Excel
	export excel using "K:\Traininh\pmtc.xlsx", firstrow(variables)
		drop sex_pmtct dateofbirth_pmtct //this command drops variables sex_pmtct and dateofbirth
		
	****The next few lines not only export to excel 
	export excel using "K:\Traininh\pmtc.xlsx", sheet("excel_reg") sheetmodify firstrow(variables)
		drop facilityname_pmtct region_pmtct  //this command drops facilityname region_pmtct
	export excel using "K:\Traininh\pmtc.xlsx", sheet("excel_fac_reg") sheetmodify firstrow(variables)
