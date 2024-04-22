BEGIN
				;with cte AS ( Select            
					P.PatientPID,            
					IE.PatientId,            
					F.code,
					IE.VisitID,
					IE.VisitDate,
					IE.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,IE.VisitID,IE.VisitDate
					ORDER BY IE.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) IE ON IE.[PatientId] = P.ID AND IE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown')      
		
			delete pb from      [DWAPICentral].[dbo].[IptExtract](NoLock) pb
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PB.[PatientId]= P.ID AND PB.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on pb.PatientId = cte.PatientId  
				and cte.Created = pb.created 
				and cte.Code =  f.Code     
				and cte.VisitID = pb.VisitID
				and cte.VisitDate = pb.VisitDate
			where  Row_Num  > 1;

			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_Ipt_Log]  (NoLock);
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[IptExtract](NoLock);
	
					
		INSERT INTO  [ODS_logs].[dbo].[CT_Ipt_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@VisitDate,GETDATE());

	       ---- Refresh [ODS].[dbo].[CT_Ipt]
			MERGE [ODS].[dbo].[CT_Ipt] AS a
				USING(SELECT Distinct
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
						IE.[IndicationForIPT] AS IndicationForIPT
					   ,P.ID,IE.[Date_Created],IE.[Date_Last_Modified]
					   ,IE.[TPTInitiationDate],IE.IPTDiscontinuation,IE.DateOfDiscontinuation,
					   IE.RecordUUID,IE.voided
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) IE ON IE.[PatientId] = P.ID 
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0 

					INNER JOIN (
								SELECT F.code as SiteCode,p.[PatientPID] as PatientPK,
								visitID,VisitDate,InnerIE.voided,
								max(InnerIE.ID) As Max_ID,
								MAX(cast(InnerIE.created as date)) AS Maxdatecreated
								FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
								INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) InnerIE ON InnerIE.[PatientId] = P.ID 
								INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0 
								GROUP BY F.code,p.[PatientPID],visitID,VisitDate,InnerIE.voided
							) tm 
							ON f.code = tm.[SiteCode] and p.PatientPID=tm.PatientPK and 
							IE.visitID = tm.visitID and IE.VisitDate = tm.VisitDate and
							cast(IE.created as date) = tm.Maxdatecreated
							and IE.ID = tm.Max_ID
					WHERE P.gender != 'Unknown'  AND F.code >0) AS b 
						ON(
						 a.PatientPK	= b.PatientPK 
						and a.SiteCode	= b.SiteCode
						and a.VisitID	=b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.voided	= b.voided
						and a.ID		=b.ID
						and a.RecordUUID  = b.RecordUUID
						and a.[Date_Created] = b.[Date_Created]
						and a.[Date_Last_Modified] = b.[Date_Last_Modified])
					
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OnTBDrugs,OnIPT,EverOnIPT,Cough,Fever,NoticeableWeightLoss,NightSweats,Lethargy,ICFActionTaken,TestResult,TBClinicalDiagnosis,ContactsInvited,EvaluatedForIPT,StartAntiTBs,TBRxStartDate,TBScreening,IPTClientWorkUp,StartIPT,IndicationForIPT,[Date_Created],[Date_Last_Modified],[TPTInitiationDate],IPTDiscontinuation,DateOfDiscontinuation,RecordUUID,voided,LoadDate)  
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OnTBDrugs,OnIPT,EverOnIPT,Cough,Fever,NoticeableWeightLoss,NightSweats,Lethargy,ICFActionTaken,TestResult,TBClinicalDiagnosis,ContactsInvited,EvaluatedForIPT,StartAntiTBs,TBRxStartDate,TBScreening,IPTClientWorkUp,StartIPT,IndicationForIPT,[Date_Created],[Date_Last_Modified],[TPTInitiationDate],IPTDiscontinuation,DateOfDiscontinuation,RecordUUID,voided,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 
						a.PatientID				=b.PatientID,						
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
						a.IndicationForIPT		=b.IndicationForIPT,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.[TPTInitiationDate]	= b.[TPTInitiationDate],
						a.IPTDiscontinuation    = b.IPTDiscontinuation,
						a.DateOfDiscontinuation   = b.DateOfDiscontinuation,
						a.RecordUUID			 = b.RecordUUID,
						a.voided				= b.voided;
						

					UPDATE [ODS_logs].[dbo].[CT_Ipt_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;
				
END