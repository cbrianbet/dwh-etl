BEGIN
			MERGE [ODS].[Care].[CT_IITRiskScores] AS a
				USING(SELECT DISTINCT  
							P.PatientCccNumber
							,p.PatientPID As PatientPK
							,F.Code As SiteCode
							,F.[Name]
							,IIT.[Emr]
							,IIT.[Project]
							,IIT.[Voided]
							,IIT.[Processed]
							,IIT.[Id]
							,[FacilityName]
							,[PatientId]
							,[SourceSysUUID]
							,[RiskScore]
							,[RiskFactors]
							,[RiskDescription]
							,[RiskEvaluationDate]
							,IIT.[Created]
							,IIT.[Date_Created]
							,IIT.[Date_Last_Modified]
							,VoidingSource = Case 
					   						when IIT.voided = 1 Then 'Source'
											Else Null
										END
					  FROM [DWAPICentral].[dbo].[IITRiskScoresExtract] IIT
						INNER JOIN [DWAPICentral].[dbo].[PatientExtract] P ON IIT.[PatientId]= P.ID 
						INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
						INNER JOIN (
								SELECT	F.code as SiteCode
										,p.[PatientPID] as PatientPK
										,InnerIIT.voided
										,max(InnerIIT.ID) As Max_ID
										,MAX(cast(InnerIIT.created as date)) AS Maxdatecreated
								FROM [DWAPICentral].[dbo].[IITRiskScoresExtract] InnerIIT
									INNER JOIN [DWAPICentral].[dbo].[PatientExtract] P ON InnerIIT.[PatientId]= P.ID 
									INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
								GROUP BY F.code
										,p.[PatientPID]
										,InnerIIT.voided
							) tm 
							ON	f.code = tm.[SiteCode] and 
								p.PatientPID=tm.PatientPK and 
								cast(IIT.created as date) = tm.Maxdatecreated and
								IIT.ID = tm.Max_ID

					  WHERE p.gender!='Unknown' AND F.code >0 
				) AS b 
						ON(
							a.Sitecode = b.Sitecode and
							a.PatientPK  = b.PatientPK 	 and
							a.voided  = b.voided

						)

				WHEN NOT MATCHED THEN 
					INSERT(
							SiteCode
							,PatientID
							,PatientPK
							,Emr
							,Project
							,Voided
							,VoidingSource
							,Processed
							,Id
							,FacilityName
							,SourceSysUUID
							,RiskScore
							,RiskFactors
							,RiskDescription
							,RiskEvaluationDate
							,Created
							,Date_Created
							,Date_Last_Modified
							,LoadDate)  
					VALUES(
							SiteCode
							,PatientID
							,PatientPK
							,Emr
							,Project
							,Voided
							,VoidingSource
							,Processed
							,Id
							,FacilityName
							,SourceSysUUID
							,RiskScore
							,RiskFactors
							,RiskDescription
							,RiskEvaluationDate
							,Created
							,Date_Created
							,Date_Last_Modified
							,Getdate()
						)
			
				WHEN MATCHED THEN
					UPDATE SET 
						a.FacilityName						=	b.FacilityName,
						a.SourceSysUUID						=	b.SourceSysUUID,
						a.RiskScore							=	b.RiskScore,
						a.RiskFactors						=	b.RiskFactors,
						a.RiskDescription					=	b.RiskDescription,
						a.RiskEvaluationDate				=	b.RiskEvaluationDate,
						a.Created							=	b.Created,
						a.Date_Last_Modified				=	b.Date_Last_Modified,	
						a.Date_Created						=	b.Date_Created;
				
	END
