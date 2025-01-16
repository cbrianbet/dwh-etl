BEGIN

			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME

		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_Ovc_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[OvcExtract](NoLock)


					INSERT INTO  [ODS_logs].[dbo].[CT_Ovc_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_Ovc]
			MERGE [ODS].[Care].[CT_Ovc] AS a
				USING(SELECT Distinct
								P.[PatientCccNumber] AS PatientID
								,P.[PatientPID] AS PatientPK
								,F.Code AS SiteCode
								,F.Name AS FacilityName
								,OE.[VisitId] AS VisitID
								,OE.[VisitDate] AS VisitDate
								,P.[Emr]
								,CASE
										P.[Project]
										WHEN 'I-TECH' THEN 'Kenya HMIS II'
										WHEN 'HMIS' THEN 'Kenya HMIS II'
										ELSE P.[Project]
								END AS Project
								,OE.[OVCEnrollmentDate]
								,OE.[RelationshipToClient]
								,OE.[EnrolledinCPIMS]
								,OE.[CPIMSUniqueIdentifier]
								,OE.[PartnerOfferingOVCServices]
								,OE.[OVCExitReason]
								,OE.[ExitDate]
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
						INNER JOIN [DWAPICentral].[dbo].[OvcExtract](NoLock) OE ON OE.[PatientId] = P.ID
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
											INNER JOIN [DWAPICentral].[dbo].[OvcExtract](NoLock) InnerOE ON InnerOE.[PatientId] = P.ID
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
					WHERE P.gender != 'Unknown'AND F.code >0 ) AS b
						ON(
							 a.PatientPK  = b.PatientPK
							and a.SiteCode = b.SiteCode
							and a.VisitID	=b.VisitID
							and a.VisitDate	=b.VisitDate
							and a.voided   = b.voided
							and a.[RelationshipToClient] = b.[RelationshipToClient]
							--and a.ID = b.ID
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
								,OVCEnrollmentDate
								,RelationshipToClient
								,EnrolledinCPIMS
								,CPIMSUniqueIdentifier
								,PartnerOfferingOVCServices
								,OVCExitReason
								,ExitDate
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
								,OVCEnrollmentDate
								,RelationshipToClient
								,EnrolledinCPIMS
								,CPIMSUniqueIdentifier
								,PartnerOfferingOVCServices
								,OVCExitReason
								,ExitDate
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
						a.RelationshipToClient		=b.RelationshipToClient,
						a.EnrolledinCPIMS			=b.EnrolledinCPIMS,
						a.CPIMSUniqueIdentifier		=b.CPIMSUniqueIdentifier,
						a.PartnerOfferingOVCServices=b.PartnerOfferingOVCServices,
						a.OVCExitReason				=b.OVCExitReason,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified];


				UPDATE [ODS_logs].[dbo].[CT_Ovc_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

	END
