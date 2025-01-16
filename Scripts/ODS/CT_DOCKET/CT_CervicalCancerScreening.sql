BEGIN
			MERGE [ODS].[Care].[CT_CervicalCancerScreening] AS a
				USING(SELECT DISTINCT 
						f.code AS SiteCode,p.PatientPID AS PatientPK,p.PatientCccNumber AS PatientID,ccs.[Emr],ccs.[Project],ccs.[Voided],ccs.[Processed]
						  ,ccs.[Id],[FacilityName],[VisitID],[VisitDate],[VisitType],[ScreeningMethod],[TreatmentToday]
						  ,[ReferredOut],[NextAppointmentDate],[ScreeningType],[ScreeningResult],[PostTreatmentComplicationCause]
						  ,[OtherPostTreatmentComplication],[ReferralReason],ccs.[Created],ccs.[Date_Created],ccs.[Date_Last_Modified]
					  FROM [DWAPICentral].[dbo].[CervicalCancerScreeningExtract] ccs
					  INNER JOIN [DWAPICentral].[dbo].[PatientExtract] P 
						ON ccs.[PatientId]= P.ID 
					  INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
					  WHERE p.gender!='Unknown'AND F.code >0 ) AS b 
						ON(
						 a.SiteCode = b.SiteCode
						and  a.PatientPK  = b.PatientPK 
						and	 a.visitID = b.visitID
						and  a.visitDate = b.visitDate					

						)

				WHEN NOT MATCHED THEN 
					INSERT(SiteCode,PatientPK,PatientID,Emr,Project,Voided,Processed,Id,FacilityName,VisitID,VisitDate,VisitType,ScreeningMethod,TreatmentToday,ReferredOut,NextAppointmentDate,ScreeningType,ScreeningResult,PostTreatmentComplicationCause,OtherPostTreatmentComplication,ReferralReason,Created,Date_Created,Date_Last_Modified,LoadDate)  
					VALUES(SiteCode,PatientPK,PatientID,Emr,Project,Voided,Processed,Id,FacilityName,VisitID,VisitDate,VisitType,ScreeningMethod,TreatmentToday,ReferredOut,NextAppointmentDate,ScreeningType,ScreeningResult,PostTreatmentComplicationCause,OtherPostTreatmentComplication,ReferralReason,Created,Date_Created,Date_Last_Modified,Getdate())
			
				WHEN MATCHED THEN
					UPDATE SET 
						a.PatientID									=b.PatientID,
						a.FacilityName								=b.FacilityName,
						a.ScreeningType								=b.ScreeningType,
						a.ScreeningResult							=b.ScreeningResult,
						a.PostTreatmentComplicationCause			=b.PostTreatmentComplicationCause,
						a.ReferralReason							=b.ReferralReason,
						a.[Date_Created]							=b.[Date_Created],
						a.[Date_Last_Modified]						=b.[Date_Last_Modified];
				
	END
