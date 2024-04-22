
BEGIN
    --truncate table [ODS].[dbo].[MNCH_CwcVisits]
	MERGE [ODS].[dbo].[MNCH_CwcVisits] AS a
			USING(
					SELECT Distinct p.[PatientMnchID],p.[PatientPk],P.[SiteCode],p.[FacilityName],P.EMR,p.[Project],cast(p.[DateExtracted] as date)[DateExtracted]
						  ,cast(p.[VisitDate] as date)[VisitDate],[VisitID],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate],[OxygenSaturation]
						  ,[MUAC],[WeightCategory],[Stunted],[InfantFeeding],[MedicationGiven],[TBAssessment],[MNPsSupplementation],[Immunization]
						  ,[DangerSigns],[Milestones],[VitaminA],[Disability],[ReceivedMosquitoNet],[Dewormed],[ReferredFrom],[ReferredTo],[ReferralReasons]
						  ,[FollowUP],cast([NextAppointment] as date)[NextAppointment],p.[Date_Last_Modified]
							,ZScore,ZScoreAbsolute
							,HeightLength,Refferred,RevisitThisYear,RecordUUID
					  FROM [MNCHCentral].[dbo].[CwcVisits] P (Nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,tn.[VisitDate],Max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[CwcVisits] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode,tn.[VisitDate])tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[VisitDate] = b.[VisitDate]
						and a.RecordUUID = b.RecordUUID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Last_Modified,ZScore,ZScoreAbsolute,HeightLength,Refferred,RevisitThisYear,LoadDate,RecordUUID)  
						VALUES(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Last_Modified,ZScore,ZScoreAbsolute,HeightLength,Refferred,RevisitThisYear,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.Height				=b.Height,
							a.Weight				=b.Weight,
							a.Temp					=b.Temp,
							a.PulseRate				=b.PulseRate,
							a.RespiratoryRate		=b.RespiratoryRate	,
							a.OxygenSaturation		=b.OxygenSaturation	,
							a.MUAC					=b.MUAC	,
							a.WeightCategory		=b.WeightCategory,
							a.Stunted				=b.Stunted,
							a.InfantFeeding			=b.InfantFeeding,
							a.MedicationGiven		=b.MedicationGiven,
							a.TBAssessment			=b.TBAssessment	,
							a.MNPsSupplementation	=b.MNPsSupplementation	,
							a.Immunization			=b.Immunization	,
							a.DangerSigns			=b.DangerSigns,
							a.Milestones			=b.Milestones,
							a.VitaminA				=b.VitaminA	,
							a.Disability			=b.Disability,
							a.ReceivedMosquitoNet	=b.ReceivedMosquitoNet,
							a.Dewormed				=b.Dewormed	,
							a.ReferredFrom			=b.ReferredFrom	,
							a.ReferredTo			=b.ReferredTo,
							a.ReferralReasons		=b.ReferralReasons,
							a.FollowUP				=b.FollowUP,
							a.HeightLength			=b.HeightLength,
							a.Refferred				=b.Refferred,
							a.RevisitThisYear		=b.RevisitThisYear,
							a.RecordUUID             =b.RecordUUID;

				with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[MNCH_CwcVisits](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;
END


