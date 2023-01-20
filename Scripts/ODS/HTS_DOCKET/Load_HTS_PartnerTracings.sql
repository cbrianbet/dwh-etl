BEGIN
		MERGE [ODS].[dbo].[HTS_PartnerTracings] AS a
			USING(SELECT DISTINCT a.[FacilityName]
			  ,a.[SiteCode]
			  ,a.[PatientPk]
			  ,a.[HtsNumber]
			  ,a.[Emr]
			  ,a.[Project]
			  ,[TraceType]
			  ,[TraceDate]
			  ,[TraceOutcome]
			  ,[BookingDate]    
		  FROM [HTSCentral].[dbo].[HtsPartnerTracings](NoLock) a
		  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
		  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
		  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode						
			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate)

	WHEN MATCHED THEN
		UPDATE SET 
			a.[FacilityName]=b.[FacilityName],
			a.[HtsNumber]	=b.[HtsNumber],
			a.[Emr]			=b.[Emr],
			a.[Project]		=b.[Project],
			a.[TraceType]	=b.[TraceType],
			a.[TraceDate]	=b.[TraceDate],
			a.[TraceOutcome]=b.[TraceOutcome],
			a.[BookingDate]	=b.[BookingDate]
	
	WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END
	