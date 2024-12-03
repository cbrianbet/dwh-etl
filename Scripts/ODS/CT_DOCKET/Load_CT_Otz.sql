
BEGIN


			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME

		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_Logs].[dbo].[CT_Otz_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[OtzExtract](NoLock)

			INSERT INTO  [ODS_Logs].[dbo].[CT_Otz_Log](MaxVisitDate,LoadStartDateTime)
			VALUES(@MaxVisitDate_Hist,GETDATE())

			MERGE [ODS].[Care].[CT_Otz] AS a
				USING(SELECT Distinct
							P.[PatientCccNumber] AS PatientID
							,P.[PatientPID] AS PatientPK
							,F.Code AS SiteCode
							,F.Name AS FacilityName
							,OE.[VisitId] AS VisitID
							,OE.[VisitDate] AS VisitDate
							,P.[Emr] AS Emr
							,CASE
									P.[Project]
									WHEN 'I-TECH' THEN 'Kenya HMIS II'
									WHEN 'HMIS' THEN 'Kenya HMIS II'
									ELSE P.[Project]
							END AS Project
							,OE.[OTZEnrollmentDate]
							,OE.[TransferInStatus]
							,OE.[ModulesPreviouslyCovered]
							,OE.[ModulesCompletedToday]
							,OE.[SupportGroupInvolvement]
							,OE.[Remarks]
							,OE.[TransitionAttritionReason]
							,OE.[OutcomeDate]
							,P.ID
							,OE.[Date_Created]
							,OE.[Date_Last_Modified]
							,OE.RecordUUID
							,OE.voided
							,VoidingSource = Case
													when OE.voided = 1 Then 'Source'
													Else Null
											END
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) OE ON OE.[PatientId] = P.ID
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						INNER JOIN (
										SELECT  F.code as SiteCode
												,p.[PatientPID] as PatientPK
												,InnerOE.voided
												,InnerOE.VisitDate
												,InnerOE.VisitID
												,max(InnerOE.ID) As maxID
												,MAX(InnerOE.created )AS Maxdatecreated
										FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
											INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) InnerOE ON InnerOE.[PatientId] = P.ID
											INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
										GROUP BY F.code
												,p.[PatientPID]
												,InnerOE.voided
												,InnerOE.VisitDate
												,InnerOE.VisitID
							) tm
							ON	f.code = tm.[SiteCode] and
								p.PatientPID=tm.PatientPK and
								OE.voided = tm.voided and
								OE.created = tm.Maxdatecreated and
								OE.ID =tm.maxID  and
								OE.VisitDate = tm.VisitDate

					WHERE P.gender != 'Unknown' AND F.code >0
				) AS b
						ON(
							 a.PatientPK  = b.PatientPK
							and a.SiteCode = b.SiteCode
							and a.VisitID	=b.VisitID
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
								,OTZEnrollmentDate
								,TransferInStatus
								,ModulesPreviouslyCovered
								,ModulesCompletedToday
								,SupportGroupInvolvement
								,Remarks
								,TransitionAttritionReason
								,OutcomeDate
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
								,OTZEnrollmentDate
								,TransferInStatus
								,ModulesPreviouslyCovered
								,ModulesCompletedToday
								,SupportGroupInvolvement
								,Remarks
								,TransitionAttritionReason
								,OutcomeDate
								,[Date_Created]
								,[Date_Last_Modified]
								,RecordUUID
								,voided
								,VoidingSource
								,Getdate()
							)

					WHEN MATCHED THEN
						UPDATE SET
						a.PatientID						=b.PatientID,
						a.TransferInStatus				=b.TransferInStatus,
						a.ModulesPreviouslyCovered		=b.ModulesPreviouslyCovered,
						a.ModulesCompletedToday			=b.ModulesCompletedToday,
						a.SupportGroupInvolvement		=b.SupportGroupInvolvement,
						a.Remarks						=b.Remarks,
						a.TransitionAttritionReason		=b.TransitionAttritionReason,
						a.[Date_Created]				=b.[Date_Created],
						a.[Date_Last_Modified]			=b.[Date_Last_Modified],
						 a.RecordUUID					=b.RecordUUID,
						 a.OTZEnrollmentDate			=b.OTZEnrollmentDate,
						a.voided						=b.voided
						;


					UPDATE [ODS_Logs].[dbo].[CT_Otz_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;


	END
