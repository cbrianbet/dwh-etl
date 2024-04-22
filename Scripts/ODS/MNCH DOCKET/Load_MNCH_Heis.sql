
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Heis]
	MERGE [ODS].[dbo].[MNCH_Heis] AS a
			USING(
					SELECT distinct P.[PatientPk],P.[SiteCode],P.[Emr],P.[Project],P.[Processed],P.[QueueId],P.[Status],P.[StatusDate]/*,P.[DateExtracted]*/
						  ,P.[FacilityId],P.[FacilityName],P.[PatientMnchID],[DNAPCR1Date],[DNAPCR2Date],[DNAPCR3Date],[ConfirmatoryPCRDate],[BasellineVLDate]
						  ,[FinalyAntibodyDate],[DNAPCR1],[DNAPCR2],[DNAPCR3],[ConfirmatoryPCR],[BasellineVL],[FinalyAntibody]
						  ,[HEIExitDate],[HEIHIVStatus],[HEIExitCritearia],P.[Date_Created],P.[Date_Last_Modified],RecordUUID
					  FROM [MNCHCentral].[dbo].[Heis] P
					INNER JOIN (SELECT tn.PatientPk,tn.SiteCode,Max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[Heis] (NOLOCK)tn
								GROUP BY  tn.PatientPk,tn.SiteCode)tm
					 on p.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
					 INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.RecordUUID  = b.RecordUUID
						 --vand a.[DNAPCR1Date]  = b.[DNAPCR1Date]
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate/*,DateExtracted */,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified,LoadDate,RecordUUID)  
						VALUES(PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate/*,DateExtracted */,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified,Getdate(),RecordUUID)

				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[DNAPCR1Date]=b.[DNAPCR1Date],
							a.[DNAPCR2Date]=b.[DNAPCR2Date],
							a.[DNAPCR3Date]=b.[DNAPCR3Date],
							a.[ConfirmatoryPCRDate]=b.[ConfirmatoryPCRDate],
							a.[BasellineVLDate]=b.[BasellineVLDate],
							a.[FinalyAntibodyDate]=b.[FinalyAntibodyDate],
							a.[DNAPCR1]=b.[DNAPCR1],
							a.[DNAPCR2]=b.[DNAPCR2],
							a.[DNAPCR3]=b.[DNAPCR3],
							a.[ConfirmatoryPCR]=b.[ConfirmatoryPCR],
							a.[BasellineVL]=b.[BasellineVL],
							a.[FinalyAntibody]=b.[FinalyAntibody],
							a.[HEIExitDate]=b.[HEIExitDate],
							a.[HEIHIVStatus]=b.[HEIHIVStatus],
							a.[HEIExitCritearia]=b.[HEIExitCritearia],
							a.[Date_Created]=b.[Date_Created],
							a.[Date_Last_Modified]=b.[Date_Last_Modified],
							a.[RecordUUID]=b.[RecordUUID];

					;with cte AS ( Select            
									P.PatientPK,            
									P.SiteCode,
					
					ROW_NUMBER() OVER (PARTITION BY P.SiteCode,P.PatientPK
					ORDER BY RecordUUID desc) Row_Num
					FROM [ODS].[dbo].[MNCH_Heis] p)   
		
				delete from cte
				where  Row_Num  > 1;  	

				
END




