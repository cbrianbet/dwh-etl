
BEGIN
	MERGE [ODS].[dbo].[MNCH_CwcEnrolments] AS a
			USING(
					SELECT Distinct [PatientIDCWC],[HEIID],P.[PatientPk],P.[SiteCode],P.[EMR],F.Name FacilityName,P.[Project],cast(P.[DateExtracted] as date)[DateExtracted]
						  ,P.[PKV],[MothersPkv],cast([RegistrationAtCWC] as date) [RegistrationAtCWC],cast([RegistrationAtHEI] as date)[RegistrationAtHEI]
						  ,[VisitID],[Gestation],[BirthWeight],[BirthLength],[BirthOrder],[BirthType],[PlaceOfDelivery],[ModeOfDelivery],[SpecialNeeds]
						  ,[SpecialCare],[HEI],[MotherAlive],[MothersCCCNo],[TransferIn],[TransferInDate],[TransferredFrom],[HEIDate],[NVP]
						  ,[BreastFeeding],[ReferredFrom],[ARTMother],[ARTRegimenMother]
						  ,cast([ARTStartDateMother] as date) [ARTStartDateMother]
						  ,P.[Date_Created]
						  ,P.[Date_Last_Modified]
						  ,RecordUUID
					  FROM [MNCHCentral].[dbo].[CwcEnrolments]P(Nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,Max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[CwcEnrolments] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
					  INNER JOIN [MNCHCentral].[dbo].[Facilities]F on F.Id=P.FacilityId ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.visitID =b.visitID
						and a.RecordUUID = b.RecordUUID
						--and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified,LoadDate,RecordUUID)  
						VALUES(PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.BirthWeight		=b.BirthWeight,
							a.BirthLength		=b.BirthLength,
							a.BirthOrder		=b.BirthOrder,
							a.BirthType			=b.BirthType,
							a.PlaceOfDelivery	=b.PlaceOfDelivery,
							a.ModeOfDelivery	=b.ModeOfDelivery,
							a.SpecialNeeds		=b.SpecialNeeds,
							a.SpecialCare		=b.SpecialCare,
							a.HEI				=b.HEI,
							a.MotherAlive		=b.MotherAlive,
							a.TransferIn		=b.TransferIn,
							a.TransferInDate	=b.TransferInDate,
							a.TransferredFrom	=b.TransferredFrom,
							a.HEIDate			=b.HEIDate,
							a.NVP				=b.NVP,
							a.BreastFeeding		=b.BreastFeeding,
							a.ReferredFrom		=b.ReferredFrom	,
							a.ARTMother			=b.ARTMother,
							a.ARTRegimenMother	=b.ARTRegimenMother,
							a.RecordUUID        = b.RecordUUID;

					
					with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[dbo].[MNCH_CwcEnrolments](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;
END



