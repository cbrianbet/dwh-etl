with cte AS ( Select           
		a.[PatientPk],           
		a.[SiteCode],            
		a.DateExtracted, ROW_NUMBER() OVER (PARTITION BY a.[PatientPk],a.[SiteCode]
		ORDER BY a.DateExtracted desc) Row_Num
       from [ODS].[HTS].[HTS_ClientLinkages] a)

	delete from cte where Row_Num>1