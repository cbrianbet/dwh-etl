
BEGIN
		MERGE [ODS].[dbo].[HTS_PartnerTracings] AS a
			USING(SELECT DISTINCT  a.[FacilityName]
			  ,a.[SiteCode]
			  ,a.[PatientPk]
			  ,a.[HtsNumber]
			  ,a.[Emr]
			  ,a.[Project]
			  ,a.[TraceType]
			  ,a.[TraceDate]
			  ,a.[TraceOutcome]
			  ,a.[BookingDate] 
			  ,a.RecordUUID
			  	 
		  FROM [HTSCentral].[dbo].[HtsPartnerTracings](NoLock) a
		  inner join (select tn.[SiteCode],tn.[PatientPk],tn.[HtsNumber],tn.[TraceType],tn.[TraceDate],tn.BookingDate,tn.[TraceOutcome],
		  max(ID) As MaxID,max(cast(DateExtracted as date))MaxDateExtracted from [HTSCentral].[dbo].[HtsPartnerTracings](NoLock) tn
		               group by tn.[SiteCode],tn.[PatientPk],tn.[HtsNumber],tn.[TraceType],tn.BookingDate,tn.[TraceDate],tn.[TraceOutcome]
					)tm
			on a.[SiteCode] =tm.[SiteCode] and a.[PatientPk] =tm.[PatientPk] and a.[TraceType] = tm.[TraceType] and a.BookingDate =tm.BookingDate and cast(a.DateExtracted as date) = MaxDateExtracted
	       and a.ID = tm.MaxID
		INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
		  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
		  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode
			and a.TraceDate  = b.TraceDate 			
			and a.BookingDate  = b.BookingDate 
			and a.[TraceOutcome] = b.[TraceOutcome]
			and a.[TraceType] = b.[TraceType]
			and a.RecordUUID  = b.RecordUUID

			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate,LoadDate,RecordUUID)  
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate,Getdate(),RecordUUID)

	WHEN MATCHED THEN
		UPDATE SET 
			a.[FacilityName]=b.[FacilityName],
			
			a.[TraceType]	=b.[TraceType],
			a.[TraceDate]	=b.[TraceDate],
			a.[TraceOutcome]=b.[TraceOutcome],
			a.[BookingDate]	=b.[BookingDate],
			a.RecordUUID    = b.RecordUUID;

		
END

