
BEGIN

			DECLARE @MaxDispenseDate_Hist			DATETIME,
				  @DispenseDate					DATETIME,
				  @MaxCreatedDate				DATETIME

			SELECT @MaxDispenseDate_Hist =  MAX(MaxDispenseDate) FROM [ODS_logs].[dbo].[CT_PharmacyVisit_Log]  (NoLock)
			SELECT @DispenseDate = MAX(DispenseDate) FROM [DWAPICentral].[dbo].[PatientPharmacyExtract] WITH (NOLOCK)

			INSERT INTO  [ODS_logs].[dbo].[CT_PharmacyVisit_Log](MaxDispenseDate,LoadStartDateTime)
			VALUES(@DispenseDate,GETDATE())

			MERGE [ODS].[Care].[CT_PatientPharmacy] AS a
				USING(SELECT Distinct
							P.[PatientCccNumber] AS PatientID
							,P.[PatientPID] AS PatientPK
							,F.[Name] AS FacilityName
							,F.Code AS SiteCode
							,PP.[VisitID] As VisitID
							,PP.[Drug] As Drug
							,PP.[DispenseDate] AS DispenseDate
							,PP.[Duration] As Duration
							,PP.[ExpectedReturn] As ExpectedReturn
							,PP.[TreatmentType] As TreatmentType
							,PP.[PeriodTaken] As PeriodTaken
							,PP.[ProphylaxisType] As ProphylaxisType
							,P.[Emr] As Emr
							,CASE P.[Project]
								WHEN 'I-TECH'	THEN 'Kenya HMIS II'
								WHEN 'HMIS'		THEN 'Kenya HMIS II'
								ELSE P.[Project]
							END AS [Project]
							,PP.[Voided] As Voided
							,VoidingSource = Case
										when PP.voided = 1 Then 'Source'
										Else Null
									 END
							,PP.[Processed]  As Processed
							,PP.[Provider] As  [Provider]
							,PP.[RegimenLine] As RegimenLine
							,PP.[Created]As Created
							,PP.RegimenChangedSwitched As RegimenChangedSwitched
							,PP.RegimenChangeSwitchReason As RegimenChangeSwitchReason
							,PP.StopRegimenReason As StopRegimenReason
							,PP.StopRegimenDate As StopRegimenDate
							,PP.ID
							,PP.[Date_Created]
							,PP.[Date_Last_Modified]
							,PP.RecordUUID
						FROM [DWAPICentral].[dbo].[PatientExtract] P
							INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract] PP ON PP.[PatientId]= P.ID
							INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
							INNER JOIN (
										SELECT  F.code as SiteCode
												,p.[PatientPID] as PatientPK
												,InnerPP.voided
												,InnerPP.DispenseDate
												,max(InnerPP.ID) As maxID
												,MAX(InnerPP.created )AS Maxdatecreated
										FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)
											INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract]  InnerPP WITH(NoLock)  ON InnerPP.[PatientId]= P.ID
											INNER JOIN [DWAPICentral].[dbo].[Facility] F WITH(NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
										GROUP BY F.code,p.[PatientPID],InnerPP.voided,InnerPP.DispenseDate
							) tm
							ON	f.code = tm.[SiteCode] and
								p.PatientPID=tm.PatientPK and
								PP.voided = tm.voided and
								PP.created = tm.Maxdatecreated and
								PP.ID =tm.maxID  and
								PP.DispenseDate = tm.DispenseDate

						WHERE p.gender!='Unknown' AND F.code >0
					) AS b
						ON(
							 a.SiteCode		= b.SiteCode and
							 a.PatientPK	= b.PatientPK and
							 a.DispenseDate = b.DispenseDate and
							 a.voided		= b.voided
						)

			WHEN NOT MATCHED THEN
					INSERT(
							ID
							,PatientID
							,SiteCode
							,FacilityName
							,PatientPK
							,VisitID
							,Drug
							,DispenseDate
							,Duration
							,ExpectedReturn
							,TreatmentType
							,PeriodTaken
							,ProphylaxisType
							,Emr
							,Project
							,RegimenLine
							,RegimenChangedSwitched
							,RegimenChangeSwitchReason
							,StopRegimenReason
							,StopRegimenDate
							, [Date_Created]
							,[Date_Last_Modified]
							,RecordUUID
							,voided
							,VoidingSource
							,LoadDate
						)
					VALUES(
							ID
							,PatientID
							,SiteCode
							,FacilityName
							,PatientPK
							,VisitID
							,Drug
							,DispenseDate
							,Duration
							,ExpectedReturn
							,TreatmentType
							,PeriodTaken
							,ProphylaxisType
							,Emr
							,Project
							,RegimenLine
							,RegimenChangedSwitched
							,RegimenChangeSwitchReason
							,StopRegimenReason
							,StopRegimenDate
							,[Date_Created]
							,[Date_Last_Modified]
							,RecordUUID
							,voided
							,VoidingSource
							,Getdate()
						)

			WHEN MATCHED THEN
					UPDATE SET
						a.PatientID					=b.PatientID,
						a.FacilityName				=b.FacilityName,
						a.PeriodTaken				=b.PeriodTaken,
						a.ProphylaxisType			=b.ProphylaxisType,
						a.RegimenLine				=b.RegimenLine,
						a.RegimenChangedSwitched	=b.RegimenChangedSwitched,
						a.RegimenChangeSwitchReason	=b.RegimenChangeSwitchReason,
						a.StopRegimenReason			=b.StopRegimenReason,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.RecordUUID				=b.RecordUUID,
						a.voided					=b.voided;


				UPDATE [ODS_logs].[dbo].[CT_PharmacyVisit_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxDispenseDate = @DispenseDate;


	END
