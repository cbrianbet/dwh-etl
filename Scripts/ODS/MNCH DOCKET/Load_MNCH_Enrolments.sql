
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Enrolments]
	MERGE [ODS].[dbo].[MNCH_Enrolments] AS a
			USING(
					SELECT distinct p.[PatientMnchID],p.[PatientPk],P.[SiteCode],p.[FacilityName],P.EMR,p.[Project],cast(p.[DateExtracted] as date)[DateExtracted]
						  ,[ServiceType],cast([EnrollmentDateAtMnch] as date) [EnrollmentDateAtMnch],[MnchNumber],[FirstVisitAnc],[Parity],[Gravidae]
						  ,[LMP],[EDDFromLMP],[HIVStatusBeforeANC],cast([HIVTestDate]as date)[HIVTestDate],[PartnerHIVStatus]
						  ,cast([PartnerHIVTestDate] as date)[PartnerHIVTestDate],[BloodGroup],[StatusAtMnch],p.[Date_Last_Modified],RecordUUID
					  FROM [MNCHCentral].[dbo].[MnchEnrolments]P (nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchEnrolments] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode)tm
						on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[EnrollmentDateAtMnch] = b.[EnrollmentDateAtMnch]
						and a.RecordUUID = b.RecordUUID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Last_Modified,LoadDate,RecordUUID)  
						VALUES(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Last_Modified,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ServiceType	 =b.ServiceType,
							a.Parity = b.Parity,
							a.Gravidae = b.Gravidae,
							a.LMP = b.LMP,
							a.EDDFromLMP = b.EDDFromLMP,
							a.HIVStatusBeforeANC = b.HIVStatusBeforeANC,
							a.HIVTestDate = b.HIVTestDate,
							a.PartnerHIVStatus = b.PartnerHIVStatus,
							a.PartnerHIVTestDate = b.PartnerHIVTestDate,
							a.BloodGroup = b.BloodGroup,
							a.StatusAtMnch = b.StatusAtMnch,
							a.RecordUUID   = b.RecordUUID;

				with cte AS (
						Select
						Sitecode,
						PatientPK,
						[EnrollmentDateAtMnch],

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,[EnrollmentDateAtMnch] ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[dbo].[MNCH_Enrolments] (NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;
END



