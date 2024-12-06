BEGIN
		 DECLARE	@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME

		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_GbvScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[GbvScreeningExtract](NoLock)


		INSERT INTO  [ODS_logs].[dbo].[CT_GbvScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())
	       ---- Refresh [ODS].[dbo].[CT_GbvScreening]
			MERGE [ODS].[dbo].[CT_GbvScreening] AS a
				USING(SELECT Distinct
							P.[PatientCccNumber] AS PatientID
							,P.[PatientPID] AS PatientPK
							,F.Code AS SiteCode
							,F.Name AS FacilityName
							,GSE.[VisitId] AS VisitID
							,GSE.[VisitDate] AS VisitDate
							,P.[Emr]
							,CASE
								P.[Project]
								WHEN 'I-TECH' THEN 'Kenya HMIS II'
								WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project]
							END AS Project
							,GSE.[IPV] AS IPV
							,GSE.[PhysicalIPV]
							,GSE.[EmotionalIPV]
							,GSE.[SexualIPV]
							,GSE.[IPVRelationship]
							,GSE.ID
							,GSE.[Date_Created]
							,GSE.[Date_Last_Modified]
							,GSE.RecordUUID
							,GSE.voided
							,VoidingSource = Case
													when GSE.voided = 1 Then 'Source'
													Else Null
											END
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
							INNER JOIN [DWAPICentral].[dbo].[GbvScreeningExtract](NoLock) GSE ON GSE.[PatientId] = P.ID
							INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
							INNER JOIN (
								SELECT F.code as SiteCode
										,p.[PatientPID] as PatientPK
										,InnerGSE.visitDate
										,InnerGSE.VisitID
										,InnerGSE.voided
										,max(InnerGSE.ID) As Max_ID
										,MAX(cast(InnerGSE.created as date)) AS Maxdatecreated
								FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
									INNER JOIN [DWAPICentral].[dbo].[GbvScreeningExtract](NoLock) InnerGSE ON InnerGSE.[PatientId] = P.ID
									INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
								GROUP BY F.code
										,p.[PatientPID]
										,InnerGSE.visitDate
										,InnerGSE.VisitID
										,InnerGSE.voided
							) tm
							ON	f.code = tm.[SiteCode] and
								p.PatientPID=tm.PatientPK and
								GSE.visitDate = tm.visitDate and
								GSE.VisitID = tm.VisitID and
								GSE.voided = tm.voided and
								cast(GSE.created as date) = tm.Maxdatecreated and
								GSE.ID = tm.Max_ID
						WHERE P.gender != 'Unknown' AND F.code >0
				) AS b
						ON(
							 a.PatientPK  = b.PatientPK
							and a.SiteCode = b.SiteCode
							and a.VisitID			=b.VisitID
							and a.VisitDate			=b.VisitDate
							and a.voided   = b.voided
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
								,IPV
								,PhysicalIPV
								,EmotionalIPV
								,SexualIPV
								,IPVRelationship
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
								,IPV
								,PhysicalIPV
								,EmotionalIPV
								,SexualIPV
								,IPVRelationship
								,[Date_Created]
								,[Date_Last_Modified]
								,RecordUUID
								,voided
								,VoidingSource
								,Getdate()
							)

					WHEN MATCHED THEN
						UPDATE SET
						a.PatientID			=b.PatientID,
						a.IPV				=b.IPV,
						a.PhysicalIPV		=b.PhysicalIPV,
						a.EmotionalIPV		=b.EmotionalIPV,
						a.SexualIPV			=b.SexualIPV,
						a.IPVRelationship	=b.IPVRelationship,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						 a.RecordUUID			=b.RecordUUID,
						a.voided		=b.voided
						;


					UPDATE [ODS_logs].[dbo].[CT_GbvScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;


	END
