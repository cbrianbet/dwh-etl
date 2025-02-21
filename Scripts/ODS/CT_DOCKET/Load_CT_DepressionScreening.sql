BEGIN

		DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME

		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_DepressionScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock)

		INSERT INTO  [ODS_logs].[dbo].[CT_DepressionScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_DepressionScreening]
			MERGE [ODS].[Care].[CT_DepressionScreening]AS a
				USING(SELECT distinct
							P.[PatientCccNumber] AS PatientID
							,P.[PatientPID] AS PatientPK
							,F.Code AS SiteCode
							,F.Name AS FacilityName
							,DS.[VisitId] AS VisitID
							,DS.[VisitDate] AS VisitDate,P.[Emr]
							,CASE
									P.[Project]
									WHEN 'I-TECH' THEN 'Kenya HMIS II'
									WHEN 'HMIS' THEN 'Kenya HMIS II'
									ELSE P.[Project]
							END AS Project
							,DS.[PHQ9_1]
							,DS.[PHQ9_2]
							,DS.[PHQ9_3]
							,DS.[PHQ9_4]
							,DS.[PHQ9_5]
							,DS.[PHQ9_6]
							,DS.[PHQ9_7]
							,DS.[PHQ9_8]
							,DS.[PHQ9_9]
							,DS.[PHQ_9_rating]
							,DS.[DepressionAssesmentScore]
							,P.ID
							,DS.[Date_Created]
							,DS.[Date_Last_Modified]
							,DS.RecordUUID
							,DS.voided
							,VoidingSource = Case
													when DS.voided = 1 Then 'Source'
													Else Null
											END
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock) DS ON DS.[PatientId] = P.ID
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						INNER JOIN (
										SELECT  F.code as SiteCode
												,p.[PatientPID] as PatientPK
												,InnerDS.voided
												,InnerDS.VisitDate
												,InnerDS.VisitID
												,max(InnerDS.ID) As maxID
												,MAX(InnerDS.created )AS Maxdatecreated
										FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
											INNER JOIN [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock) InnerDS ON InnerDS.[PatientId] = P.ID
											INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
										GROUP BY F.code
												,p.[PatientPID]
												,InnerDS.voided
												,InnerDS.VisitDate
												,InnerDS.VisitID
							) tm
							ON	f.code = tm.[SiteCode] and
								p.PatientPID=tm.PatientPK and
								DS.voided = tm.voided and
								DS.created = tm.Maxdatecreated and
								DS.ID =tm.maxID  and
								DS.VisitDate = tm.VisitDate
					WHERE P.gender != 'Unknown' AND F.code >0
				) AS b
						ON(
						 a.PatientPK  = b.PatientPK
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate
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
								,PHQ9_1
								,PHQ9_2
								,PHQ9_3
								,PHQ9_4
								,PHQ9_5
								,PHQ9_6
								,PHQ9_7
								,PHQ9_8
								,PHQ9_9
								,PHQ_9_rating
								,DepressionAssesmentScore
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
								,PHQ9_1
								,PHQ9_2
								,PHQ9_3
								,PHQ9_4
								,PHQ9_5
								,PHQ9_6
								,PHQ9_7
								,PHQ9_8
								,PHQ9_9
								,PHQ_9_rating
								,DepressionAssesmentScore
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
						a.PHQ9_1					=b.PHQ9_1,
						a.PHQ9_2					=b.PHQ9_2,
						a.PHQ9_3					=b.PHQ9_3,
						a.PHQ9_4					=b.PHQ9_4,
						a.PHQ9_5					=b.PHQ9_5,
						a.PHQ9_6					=b.PHQ9_6,
						a.PHQ9_7					=b.PHQ9_7,
						a.PHQ9_8					=b.PHQ9_8,
						a.PHQ9_9					=b.PHQ9_9,
						a.PHQ_9_rating				=b.PHQ_9_rating,
						a.DepressionAssesmentScore	=b.DepressionAssesmentScore,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.RecordUUID				=b.RecordUUID,
						a.voided					=b.voided;


					UPDATE [ODS_logs].[dbo].[CT_DepressionScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;



	END
