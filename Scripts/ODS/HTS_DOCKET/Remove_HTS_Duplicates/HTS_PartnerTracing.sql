with cte AS ( Select           
		a.[PatientPk],           
		a.[SiteCode],  
		TraceDate,
		[BookingDate],
		 ROW_NUMBER() OVER (PARTITION BY a.[PatientPk],a.[SiteCode],TraceDate,[BookingDate]
		ORDER BY a.[PatientPk] desc) Row_Num
         FROM [ODS].[HTS].[HTS_PartnerTracings]  a)

	delete from cte where Row_Num>1