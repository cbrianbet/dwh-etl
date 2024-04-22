BEGIN

			MERGE [ODS].[dbo].[Ushauri_HEI] AS a
				USING(SELECT Distinct
						PatientPK As UshauriPatientPK,PatientPKHash As UshauriPatientPKHash,PartnerName,SiteCode,SiteType,Emr,Project,
						FacilityName,PatientMNCH_ID,PatientHEI_ID,[1stDNAPCRDate],[2ndDNAPCRDate],
						[3rdDNAPCRDate],ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,[1stDNAPCR],[2ndDNAPCR],[3rdDNAPCR],ConfirmatoryPCR,
						BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCriteria,DateCreated,DateModified,[1stDNAPCRDate_Date],
						[2ndDNAPCRDate_Date],[3rdDNAPCRDate_Date],ConfirmatoryPCRDate_Date,BasellineVLDate_Date,FinalyAntibodyDate_Date,
						HEIExitDate_Date,DateCreated_Date,DateModified_Date

					FROM [MhealthCentral].[dbo].[pmtct_MNCH_HEI](NoLock) P
					) AS b	
						ON(
						 a.[UshauriPatientPK]  = b.UshauriPatientPK 
						and a.SiteCode = b.SiteCode	
						and a.PatientHEI_ID = b.PatientHEI_ID
						
						)
					
					WHEN NOT MATCHED THEN 
						INSERT(UshauriPatientPK,UshauriPatientPKHash,PartnerName,SiteCode,SiteType,Emr,Project,FacilityName,PatientMNCH_ID,PatientHEI_ID,[1stDNAPCRDate],[2ndDNAPCRDate],[3rdDNAPCRDate],ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,[1stDNAPCR],[2ndDNAPCR],[3rdDNAPCR],ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCriteria,DateCreated,DateModified,[1stDNAPCRDate_Date],[2ndDNAPCRDate_Date],[3rdDNAPCRDate_Date],ConfirmatoryPCRDate_Date,BasellineVLDate_Date,FinalyAntibodyDate_Date,HEIExitDate_Date,DateCreated_Date,DateModified_Date,LoadDate) 
						VALUES(UshauriPatientPK,UshauriPatientPKHash,PartnerName,SiteCode,SiteType,Emr,Project,FacilityName,PatientMNCH_ID,PatientHEI_ID,[1stDNAPCRDate],[2ndDNAPCRDate],[3rdDNAPCRDate],ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,[1stDNAPCR],[2ndDNAPCR],[3rdDNAPCR],ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCriteria,DateCreated,DateModified,[1stDNAPCRDate_Date],[2ndDNAPCRDate_Date],[3rdDNAPCRDate_Date],ConfirmatoryPCRDate_Date,BasellineVLDate_Date,FinalyAntibodyDate_Date,HEIExitDate_Date,DateCreated_Date,DateModified_Date,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 						
						a.[PartnerName]					=		b.[PartnerName],
						a.[SiteType]					=		b.[SiteType],
						a.[Emr]							=		b.[Emr],
						a.[Project]						=		b.[Project],
						a.[FacilityName]				=		b.[FacilityName],
						a.[1stDNAPCRDate]				=		b.[1stDNAPCRDate],
						a.[2ndDNAPCRDate]				=		b.[2ndDNAPCRDate],
						a.[3rdDNAPCRDate]				=		b.[3rdDNAPCRDate],
						a.[ConfirmatoryPCRDate]			=		b.[ConfirmatoryPCRDate],
						a.[BasellineVLDate]				=		b.[BasellineVLDate],
						a.[FinalyAntibodyDate]			=		b.[FinalyAntibodyDate],
						a.[1stDNAPCR]					=		b.[1stDNAPCR],
						a.[2ndDNAPCR]					=		b.[2ndDNAPCR],
						a.[3rdDNAPCR]					=		b.[3rdDNAPCR],
						a.[ConfirmatoryPCR]				=		b.[ConfirmatoryPCR],
						a.[BasellineVL]					=		b.[BasellineVL],
						a.[FinalyAntibody]				=		b.[FinalyAntibody],
						a.[HEIExitDate]					=		b.[HEIExitDate],
						a.[HEIHIVStatus]				=		b.[HEIHIVStatus],
						a.[HEIExitCriteria]				=		b.[HEIExitCriteria],
						a.[DateCreated]					=		b.[DateCreated],
						a.[DateModified]				=		b.[DateModified],
						a.[1stDNAPCRDate_Date]			=		b.[1stDNAPCRDate_Date],
						a.[2ndDNAPCRDate_Date]			=		b.[2ndDNAPCRDate_Date],
						a.[3rdDNAPCRDate_Date]			=		b.[3rdDNAPCRDate_Date],
						a.[ConfirmatoryPCRDate_Date]	=		b.[ConfirmatoryPCRDate_Date],
						a.[BasellineVLDate_Date]		=		b.[BasellineVLDate_Date],
						a.[FinalyAntibodyDate_Date]		=		b.[FinalyAntibodyDate_Date],
						a.[HEIExitDate_Date]			=		b.[HEIExitDate_Date],
						a.[DateCreated_Date]			=		b.[DateCreated_Date],
						a.[DateModified_Date]			=		b.[DateModified_Date]
						;

		
	END