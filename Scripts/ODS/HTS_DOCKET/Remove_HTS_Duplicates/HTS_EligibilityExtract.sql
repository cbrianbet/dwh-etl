with cte AS ( Select           
		a.[PatientPk],           
		a.[SiteCode],            
		a.encounterID,
		visitID,ROW_NUMBER() OVER (PARTITION BY a.[PatientPk],a.[SiteCode],encounterID,visitID
		ORDER BY a.encounterID ) Row_Num
       from [ODS].[HTS].[HTS_EligibilityExtract] a)

	delete from cte where Row_Num>1