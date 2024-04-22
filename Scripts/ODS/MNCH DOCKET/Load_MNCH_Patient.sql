
BEGIN
	MERGE [ODS].[dbo].[MNCH_Patient] AS a
			USING(
					SELECT distinct P.[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[FacilityName],[Pkv],[PatientMnchID],[PatientHeiID],[Gender],[DOB],[FirstEnrollmentAtMnch],[Occupation]
						  ,[MaritalStatus],[EducationLevel],[PatientResidentCounty],[PatientResidentSubCounty],[PatientResidentWard],[InSchool]
						  ,[Date_Created],[Date_Last_Modified],[NUPI],RecordUUID
					  FROM [MNCHCentral].[dbo].[MnchPatients] P(nolock)
					   inner join (select tn.PatientPK,tn.SiteCode,Max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchPatients] (NoLock)tn
					group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.RecordUUID = b.RecordUUID
						
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI,LoadDate,RecordUUID)  
						VALUES(PatientPk,SiteCode,Emr,Project,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.Gender = b.Gender,
							a.DOB = b.DOB,
							a.FirstEnrollmentAtMnch = b.FirstEnrollmentAtMnch,
							a.Occupation = b.Occupation,
							a.MaritalStatus = b.MaritalStatus,
							a.EducationLevel = b.EducationLevel,
							a.PatientResidentCounty = b.PatientResidentCounty,
							a.PatientResidentSubCounty = b.PatientResidentSubCounty,
							a.PatientResidentWard = b.PatientResidentWard,
							a.InSchool = b.InSchool,
							a.RecordUUID = b.RecordUUID;

				with cte AS (
						Select
						Sitecode,
						PatientPK,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[dbo].[MNCH_Patient](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;

			update ods.dbo.MNCH_Patient
set voided =0
where voided is null
END


