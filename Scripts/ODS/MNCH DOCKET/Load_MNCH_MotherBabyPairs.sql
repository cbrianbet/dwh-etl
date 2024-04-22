
BEGIN
	BEGIN
		update MNCHCentral.[dbo].[MotherBabyPairs]
			set MNCHCentral.[dbo].[MotherBabyPairs].FacilityId = [Facilities].id
			FROM MNCHCentral.[dbo].[MotherBabyPairs], [MNCHCentral].[dbo].[Facilities]
			where [MotherBabyPairs].SiteCode =Facilities.SiteCode;
	END

	MERGE [ODS].[dbo].[MNCH_MotherBabyPairs] AS a
			USING(
					SELECT distinct [PatientIDCCC],P.[PatientPk],[BabyPatientPK],[MotherPatientPK],[BabyPatientMncHeiID],[MotherPatientMncHeiID]
						  ,P.[SiteCode],F.Name FacilityName,P.[EMR],P.[Project]
						  ,P.[Date_Last_Modified],p.DateExtracted
						  ,convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash 
						  ,convert(nvarchar(64), hashbytes('SHA2_256', cast(BabyPatientPK  as nvarchar(36))), 2)BabyPatientPKHash
						  ,convert(nvarchar(64), hashbytes('SHA2_256', cast(MotherPatientPK  as nvarchar(36))), 2)MotherPatientPKHash
						  ,convert(nvarchar(64), hashbytes('SHA2_256', cast(MotherPatientMncHeiID  as nvarchar(36))), 2)MotherPatientMncHeiIDHash
						  ,RecordUUID
					  FROM [MNCHCentral].[dbo].[MotherBabyPairs] P (Nolock)
						INNER JOIN (select tn.PatientPK,tn.SiteCode,max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[MotherBabyPairs] (NoLock)tn
						GROUP BY tn.PatientPK,tn.SiteCode)tm
							ON P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted
							and p.ID = tm.MaxID
						INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(

						 a.PatientPK			= b.PatientPK 
					    and a.SiteCode			= b.SiteCode
						and a.[BabyPatientPK]	= b.[BabyPatientPK]
						and a.RecordUUID    = b.RecordUUID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,Date_Last_Modified,DateExtracted,PatientPKHash,BabyPatientPKHash,MotherPatientPKHash,MotherPatientMncHeiIDHash,LoadDate,RecordUUID)  
						VALUES(PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,Date_Last_Modified,DateExtracted,PatientPKHash,BabyPatientPKHash,MotherPatientPKHash,MotherPatientMncHeiIDHash,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.FacilityName	 =b.FacilityName,
							a.DateExtracted  = b.DateExtracted,
							a.RecordUUID   = b.RecordUUID;

					;with cte AS ( Select         
								p.[PatientPk],           
								p.[SiteCode], 
								BabyPatientMncHeiID,[BabyPatientPK],
								 ROW_NUMBER() OVER (PARTITION BY p.[PatientPk],p.[SiteCode],BabyPatientMncHeiID,[BabyPatientPK]
								ORDER BY p.[PatientPk],p.[SiteCode],BabyPatientMncHeiID desc) Row_Num
							   FROM [ODS].[dbo].[MNCH_MotherBabyPairs] p)

					delete from cte where Row_Num>1
END
