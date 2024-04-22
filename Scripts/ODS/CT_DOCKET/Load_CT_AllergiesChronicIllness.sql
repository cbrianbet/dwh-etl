
BEGIN

	;with cte AS ( Select            
			P.PatientPID,            
			ACI.PatientId,            
			F.code,
			ACI.VisitID,
			ACI.VisitDate,
			ACI.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,ACI.VisitID,ACI.VisitDate
			ORDER BY ACI.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
			INNER JOIN [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract](NoLock) ACI ON ACI.[PatientId] = P.ID AND ACI.Voided = 0
			INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0

			WHERE P.gender != 'Unknown')      
		
			delete ACI from  [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract] (NoLock) ACI
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON ACI.[PatientId]= P.ID AND ACI.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on ACI.PatientId = cte.PatientId  
				and cte.Created = ACI.created 
				and cte.Code =  f.Code     
				and cte.VisitID = ACI.VisitID
				and cte.VisitDate = ACI.VisitDate
			where  Row_Num  > 1;
 
	 DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
			SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS_logs].[dbo].[CT_AllergiesChronicIllness_Log]  (NoLock)
			SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract] WITH (NOLOCK) 					
					
			INSERT INTO  [ODS_logs].[dbo].[CT_AllergiesChronicIllness_Log](MaxVisitDate,LoadStartDateTime)
			VALUES(@VisitDate,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_AllergiesChronicIllness]
			MERGE [ODS].[dbo].[CT_AllergiesChronicIllness] AS a
				USING(SELECT distinct
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,ACI.ID,
						F.Name AS FacilityName,ACI.[VisitId] AS VisitID,ACI.[VisitDate] AS VisitDate, P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						ACI.[ChronicIllness] AS ChronicIllness,ACI.[ChronicOnsetDate] AS ChronicOnsetDate,ACI.[knownAllergies] AS knownAllergies,
						ACI.[AllergyCausativeAgent] AS AllergyCausativeAgent,ACI.[AllergicReaction] AS AllergicReaction,ACI.[AllergySeverity] AS AllergySeverity,
						ACI.[AllergyOnsetDate] AS AllergyOnsetDate,ACI.[Skin] AS Skin,ACI.[Eyes] AS Eyes,ACI.[ENT] AS ENT,ACI.[Chest] AS Chest,ACI.[CVS] AS CVS,
						ACI.[Abdomen] AS Abdomen,ACI.[CNS] AS CNS,ACI.[Genitourinary] AS Genitourinary
						,ACI.[Date_Created],ACI.[Date_Last_Modified],
						 ACI.RecordUUID,ACI.voided
						 ,ACI.Controlled
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract](NoLock) ACI ON ACI.[PatientId] = P.ID 
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0

					WHERE P.gender != 'Unknown' AND F.code >0) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitDate = b.VisitDate
						and a.VisitID = b.VisitID
						and a.voided   = b.voided
						---and a.ID =b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(ID,AllergiesChronicIllnessUnique_ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,ChronicIllness,ChronicOnsetDate,knownAllergies,AllergyCausativeAgent,AllergicReaction,AllergySeverity,AllergyOnsetDate,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary,[Date_Created],[Date_Last_Modified], RecordUUID,voided,Controlled,LoadDate)  
						VALUES(ID,ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,ChronicIllness,ChronicOnsetDate,knownAllergies,AllergyCausativeAgent,AllergicReaction,AllergySeverity,AllergyOnsetDate,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary,[Date_Created],[Date_Last_Modified], RecordUUID,voided,Controlled,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PatientID				=b.PatientID,							
							a.ChronicIllness		=b.ChronicIllness,
							a.ChronicOnsetDate		=b.ChronicOnsetDate,
							a.knownAllergies		=b.knownAllergies,
							a.AllergyCausativeAgent	=b.AllergyCausativeAgent,
							a.AllergicReaction		=b.AllergicReaction,
							a.AllergySeverity		=b.AllergySeverity,
							a.AllergyOnsetDate		=b.AllergyOnsetDate,
							a.Skin					=b.Skin,
							a.Eyes					=b.Eyes,
							a.ENT					=b.ENT,
							a.Chest					=b.Chest,
							a.CVS					=b.CVS,
							a.Abdomen				=b.Abdomen,
							a.CNS					=b.CNS,
							a.Genitourinary			=b.Genitourinary,
							a.[Date_Created]		=b.[Date_Created],
							a.[Date_Last_Modified]	=b.[Date_Last_Modified],
							a.RecordUUID			=b.RecordUUID,
							a.voided		=b.voided,
							a.Controlled    = b.Controlled;
												
					
					UPDATE [ODS_logs].[dbo].[CT_AllergiesChronicIllness_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;
					

	END
