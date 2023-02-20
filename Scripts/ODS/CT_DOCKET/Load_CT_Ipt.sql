BEGIN
			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Ipt_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[IptExtract](NoLock)
	
					
		INSERT INTO  [ODS].[dbo].[CT_Ipt_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@VisitDate,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_Ipt]
			MERGE [ODS].[dbo].[CT_Ipt] AS a
				USING(SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
						IE.[VisitId] AS VisitID,IE.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						IE.[OnTBDrugs] AS OnTBDrugs,IE.[OnIPT] AS OnIPT,IE.[EverOnIPT] AS EverOnIPT,IE.[Cough] AS Cough,
						IE.[Fever] AS Fever,IE.[NoticeableWeightLoss] AS NoticeableWeightLoss,IE.[NightSweats] AS NightSweats,
						IE.[Lethargy] AS Lethargy,IE.[ICFActionTaken] AS ICFActionTaken,IE.[TestResult] AS TestResult,
						IE.[TBClinicalDiagnosis] AS TBClinicalDiagnosis,IE.[ContactsInvited] AS ContactsInvited,
						IE.[EvaluatedForIPT] AS EvaluatedForIPT,IE.[StartAntiTBs] AS StartAntiTBs,IE.[TBRxStartDate] AS TBRxStartDate,
						IE.[TBScreening] AS TBScreening,IE.[IPTClientWorkUp] AS IPTClientWorkUp,IE.[StartIPT] AS StartIPT,
						IE.[IndicationForIPT] AS IndicationForIPT,GETDATE() AS DateImported
					   ,P.ID as PatientUnique_ID
					   ,IE.PatientID as UniquePatientIptID
					   ,IE.ID as IptVisitUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) IE ON IE.[PatientId] = P.ID AND IE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID	=b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.PatientUnique_ID =b.UniquePatientIptID
						and a.IptVisitUnique_ID = b.IptVisitUnique_ID)
					
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OnTBDrugs,OnIPT,EverOnIPT,Cough,Fever,NoticeableWeightLoss,NightSweats,Lethargy,ICFActionTaken,TestResult,TBClinicalDiagnosis,ContactsInvited,EvaluatedForIPT,StartAntiTBs,TBRxStartDate,TBScreening,IPTClientWorkUp,StartIPT,IndicationForIPT,DateImported,CKV,PatientUnique_ID,IptVisitUnique_ID,PatientPKHash,PatientIDHash,CKVHash) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OnTBDrugs,OnIPT,EverOnIPT,Cough,Fever,NoticeableWeightLoss,NightSweats,Lethargy,ICFActionTaken,TestResult,TBClinicalDiagnosis,ContactsInvited,EvaluatedForIPT,StartAntiTBs,TBRxStartDate,TBScreening,IPTClientWorkUp,StartIPT,IndicationForIPT,DateImported,CKV,PatientUnique_ID,IptVisitUnique_ID,PatientPKHash,PatientIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
						
						a.FacilityName			=b.FacilityName,						
						a.OnTBDrugs				=b.OnTBDrugs,
						a.OnIPT					=b.OnIPT,
						a.EverOnIPT				=b.EverOnIPT,
						a.Cough					=b.Cough,
						a.Fever					=b.Fever,
						a.NoticeableWeightLoss	=b.NoticeableWeightLoss,
						a.NightSweats			=b.NightSweats,
						a.Lethargy				=b.Lethargy,
						a.ICFActionTaken		=b.ICFActionTaken,
						a.TestResult			=b.TestResult,
						a.TBClinicalDiagnosis	=b.TBClinicalDiagnosis,
						a.ContactsInvited		=b.ContactsInvited,
						a.EvaluatedForIPT		=b.EvaluatedForIPT,
						a.StartAntiTBs			=b.StartAntiTBs,
						a.TBRxStartDate			=b.TBRxStartDate,
						a.TBScreening			=b.TBScreening,
						a.IPTClientWorkUp		=b.IPTClientWorkUp,
						a.StartIPT				=b.StartIPT,
						a.IndicationForIPT		=b.IndicationForIPT;


					UPDATE [ODS].[dbo].[CT_Ipt_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;

					INSERT INTO [ODS].[dbo].[CT_IptCount_Log]([SiteCode],[CreatedDate],[IptCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS IptCount 
					FROM [ODS].[dbo].[CT_Ipt] 
					--WHERE @MaxCreatedDate  > @MaxCreatedDate
					GROUP BY SiteCode;

					
END