BEGIN

		--Truncate table [ODS].[dbo].[HTS_ClientTracing]
		MERGE [ODS].[dbo].[HTS_ClientTracing] AS a
			USING(SELECT DISTINCT  a.[FacilityName]
				  ,a.[SiteCode]
				  ,a.[PatientPk]
				  ,a.[HtsNumber]
				  ,a.[Emr]
				  ,a.[Project]     
				  ,[TracingType]
				  ,[TracingDate]
				  ,[TracingOutcome]
				  ,a.RecordUUID
			  FROM [HTSCentral].[dbo].[HtsClientTracing] (NoLock)a
			INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
				Inner join ( select innerCT.sitecode,innerCT.patientPK,innerCT.htsNumber,innerCT.voided,max(ID)As MaxID,max(Dateextracted)MaxDateextracted
				from [HTSCentral].[dbo].[HtsClientTracing] innerCT
									group by innerCT.sitecode,innerCT.patientPK,innerCT.htsNumber,innerCT.voided
						  )tn

									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK
									and a.Dateextracted = tn.MaxDateextracted
									and a.htsNumber = tn.htsNumber
									and a.voided = tn.voided
									and a.ID = tn.MaxID
			  
			  where a.TracingType is not null and a.TracingOutcome is not null
			  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode	
			and a.[TracingDate] = b.[TracingDate]
			and a.HtsNumber  = b.HtsNumber
			and a.TracingType  = b.TracingType
			and a.TracingOutcome = b.TracingOutcome
			and a.FacilityName  = b.FacilityName
			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome,RecordUUID,LoadDate)  
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome,RecordUUID,Getdate())

	WHEN MATCHED THEN
		UPDATE SET 
				a.[FacilityName]	=b.[FacilityName],
				
				a.[TracingType]		=b.[TracingType],
				a.[TracingDate]		=b.[TracingDate],
				a.[TracingOutcome]	=b.[TracingOutcome],
				a.RecordUUID    =b.RecordUUID;
END

