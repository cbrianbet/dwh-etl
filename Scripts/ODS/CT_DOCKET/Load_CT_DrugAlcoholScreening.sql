BEGIN
		DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME

		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_DrugAlcoholScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract] WITH (NOLOCK)

		INSERT INTO  [ODS_logs].[dbo].[CT_DrugAlcoholScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@VisitDate,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_DrugAlcoholScreening]
			MERGE [ODS].[Care].[CT_DrugAlcoholScreening] AS a
				USING(SELECT distinct
							P.[PatientCccNumber] AS PatientID
							,P.[PatientPID] AS PatientPK
							,F.Code AS SiteCode
							,F.Name AS FacilityName
							,DAS.[VisitId] AS VisitID
							,DAS.[VisitDate] AS VisitDate
							,P.[Emr] AS Emr
							,CASE
								P.[Project]
								WHEN 'I-TECH' THEN 'Kenya HMIS II'
								WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project]
							 END AS Project
							 ,DAS.[DrinkingAlcohol] AS DrinkingAlcohol
							 ,DAS.[Smoking] AS Smoking
							 ,DAS.[DrugUse] AS DrugUse
							 ,DAS.ID
							 ,DAS.[Date_Created]
							 ,DAS.[Date_Last_Modified]
							 ,DAS.RecordUUID
							 ,DAS.voided
							 ,VoidingSource = Case
													when DAS.voided = 1 Then 'Source'
													Else Null
											END
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
							INNER JOIN [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock) DAS ON DAS.[PatientId] = P.ID
							INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
							INNER JOIN (
										SELECT  F.code as SiteCode
												,p.[PatientPID] as PatientPK
												,InnerDAS.voided
												,InnerDAS.VisitDate
												,InnerDAS.VisitID
												,max(InnerDAS.ID) As maxID
												,MAX(InnerDAS.created )AS Maxdatecreated
										FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
											INNER JOIN [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock) InnerDAS ON InnerDAS.[PatientId] = P.ID
											INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
										GROUP BY F.code
												,p.[PatientPID]
												,InnerDAS.voided
												,InnerDAS.VisitDate
												,InnerDAS.VisitID
							) tm
							ON	f.code = tm.[SiteCode] and
								p.PatientPID=tm.PatientPK and
								DAS.voided = tm.voided and
								DAS.created = tm.Maxdatecreated and
								DAS.ID =tm.maxID  and
								DAS.VisitDate = tm.VisitDate
						WHERE P.gender != 'Unknown' AND F.code >0
					) AS b
						ON(
							 a.PatientPK  = b.PatientPK
							and a.SiteCode = b.SiteCode
							and a.VisitID = b.VisitID
							and a.VisitDate	=b.VisitDate
							and a.voided   = b.voided
							--and a.ID =b.ID
						)

					WHEN NOT MATCHED THEN
						INSERT(
								ID
								,PatientID
								,PatientPK
								,SiteCode
								,FacilityName
								,VisitID
								,VisitDate
								,Emr
								,Project
								,DrinkingAlcohol
								,Smoking
								,DrugUse
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
								,FacilityName
								,VisitID
								,VisitDate
								,Emr
								,Project
								,DrinkingAlcohol
								,Smoking
								,DrugUse
								,[Date_Created]
								,[Date_Last_Modified]
								, RecordUUID
								,voided
								,VoidingSource
								,Getdate()
							)

					WHEN MATCHED THEN
						UPDATE SET
						a.PatientID			=b.PatientID,
						a.DrinkingAlcohol	=b.DrinkingAlcohol,
						a.Smoking			=b.Smoking,
						a.DrugUse			=b.DrugUse,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.RecordUUID			=b.RecordUUID,
						a.voided		=b.voided;


					UPDATE [ODS_logs].[dbo].[CT_DrugAlcoholScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;


	END
