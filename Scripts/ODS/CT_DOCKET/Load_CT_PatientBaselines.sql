BEGIN

		
		MERGE INTO [ODS].[Care].CT_PatientBaselines AS a
		USING(SELECT  Distinct 
						P.[PatientCccNumber] AS PatientID
						,P.[PatientPID] AS PatientPK
						,F.Code AS SiteCode
						,PB.ID
						,PB.[eCD4]
						,PB.[eCD4Date]
						,PB.[eWHO]
						,PB.[eWHODate]
						,PB.[bCD4]
						,PB.[bCD4Date]
						,PB.[bWHO]
						,PB.[bWHODate]
						,PB.[lastWHO]
						,PB.[lastWHODate]
						,PB.[lastCD4]
						,PB.[lastCD4Date]
						,PB.[m12CD4]
						,PB.[m12CD4Date]
						,PB.[m6CD4]
						,PB.[m6CD4Date]
						,P.[Emr]
						,CASE P.[Project] 
							WHEN 'I-TECH' THEN 'Kenya HMIS II' 
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project] 
						END AS [Project] 
						,PB.[Processed]
						,PB.[bWAB]
						,PB.[bWABDate]
						,PB.[eWAB]
						,PB.[eWABDate]
						,PB.[lastWAB]
						,PB.[lastWABDate]
						,PB.[Date_Created]
						,PB.[Date_Last_Modified]
						,PB.RecordUUID
						,PB.voided
						,VoidingSource = Case 
													when PB.voided = 1 Then 'Source'
													Else Null
											END 

		FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 	
			INNER JOIN [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock) PB ON PB.[PatientId]= P.ID 
			INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
			INNER JOIN (
								SELECT	F.code as SiteCode
										,p.[PatientPID] as PatientPK
										,InnerPB.voided
										,MAX(InnerPB.ID) AS MaxdID
										, MAX(InnerPB.created) AS Maxdatecreated
								FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  						
									INNER JOIN [DWAPICentral].[dbo].[PatientBaselinesExtract] InnerPB  WITH(NoLock)  ON InnerPB.[PatientId]= P.ID 
									INNER JOIN [DWAPICentral].[dbo].[Facility] F WITH(NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
								GROUP BY F.code
										,p.[PatientPID]
										,InnerPB.voided
							) tm 
							ON	f.code = tm.[SiteCode] and 
								p.PatientPID=tm.PatientPK and 
								PB.voided=tm.voided and  
								PB.ID = tm.MaxdID    and
								PB.created = tm.Maxdatecreated
		WHERE p.gender!='Unknown' AND F.code >0
	) b

		ON a.patientPK = b.PatientPK  
		and a.sitecode = b.sitecode 
		and a.voided   = b.voided
		


		WHEN NOT MATCHED THEN 
		INSERT(
				ID
				,PatientID
				,PatientPK
				,SiteCode
				,bCD4
				,bCD4Date
				,bWHO
				,bWHODate
				,eCD4
				,eCD4Date
				,eWHO
				,eWHODate
				,lastWHO
				,lastWHODate
				,lastCD4
				,lastCD4Date
				,m12CD4
				,m12CD4Date
				,m6CD4
				,m6CD4Date
				,Emr
				,Project
				,[bWAB]
				,[bWABDate]
				,[eWAB]
				,[eWABDate]
				,[lastWAB]
				,[lastWABDate]
				,[Date_Created]
				,[Date_Last_Modified]
				,RecordUUID
				,voided
				,VoidingSource
				,LoadDate
			)
		VALUES(
				ID
				,PatientID
				,PatientPK
				,SiteCode
				,[eCD4]
				,[eCD4Date]
				,[eWHO]
				,bWHODate
				,[bCD4]
				,[bCD4Date]
				,[bWHO]
				,[bWHODate]
				,[lastWHO]
				,[lastWHODate]
				,[lastCD4]
				,[lastCD4Date]
				,[m12CD4]
				,[m12CD4Date]
				,[m6CD4]
				,[m6CD4Date]
				,[Emr]
				,[Project]
				,[bWAB]
				,[bWABDate]
				,[eWAB]
				,[eWABDate]
				,[lastWAB]
				,[lastWABDate]
				,[Date_Created]
				,[Date_Last_Modified]
				,RecordUUID
				,voided
				,VoidingSource
				,Getdate()
			)

		WHEN MATCHED THEN
			UPDATE SET 
						a.PatientID		=b.PatientID,
						a.bCD4			= b.bCD4,					
						a.bCD4Date		= b.bCD4Date,
						a.bWHO			= b.bWHO,
						a.bWHODate		= b.bWHODate,
						a.eCD4			= b.eCD4,
						a.eCD4Date		= b.eCD4Date,
						a.eWHO			= b.eWHO,
						a.eWHODate		= b.eWHODate,
						a.lastWHO		= b.lastWHO	,
						a.lastWHODate	= b.lastWHODate,
						a.lastCD4		= b.lastCD4	,
						a.lastCD4Date	= b.lastCD4Date,
						a.m12CD4		= b.m12CD4	,
						a.m12CD4Date	= b.m12CD4Date,
						a.m6CD4			= b.m6CD4,
						a.m6CD4Date		= b.m6CD4Date,				
						a.bWAB			= b.bWAB,
						a.bWABDate		= b.bWABDate,
						a.eWAB			= b.eWAB,
						a.eWABDate		= b.eWABDate,
						a.lastWAB		= b.lastWAB	,
						a.lastWABDate	= b.lastWABDate,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.RecordUUID			=b.RecordUUID,
						a.voided		=b.voided;


					
END
