
---------------Insert into FactArtHistory before droping FactART for new data
BEGIN
	MERGE [NDWH].[dbo].[FactARTHistory] AS a
using(SELECT  [Factkey]
			  ,[PatientKey]
			  ,[FacilityKey]
			  ,[PartnerKey]
			  ,[AgencyKey]
			  ,[AgeGroupKey]
			  ,[StartARTDateKey]
			  ,[LastARTDateKey]
			  ,[DateConfirmedPosKey]
			  ,[ARTOutcomeKey]
			  ,[CurrentRegimen]
			  ,[CurrentRegimenline]
			  ,[StartRegimen]
			  ,[StartRegimenLine]
			  ,[AgeAtEnrol]
			  ,[AgeAtARTStart]
			  ,[AgeLastVisit]
			  ,[Agegrouping]
			  ,[TimetoARTDiagnosis]
			  ,[TimetoARTEnrollment]
			  ,[PregnantARTStart]
			  ,[PregnantAtEnrol]
			  ,[LastVisitDate]
			  ,[NextAppointmentDate]
			  ,[StartARTAtThisfacility]
			  ,[PreviousARTStartDate]
			  ,[PreviousARTRegimen]
			  ,[WhoStage]
			  ,[PHQ_9_rating]
			  ,[ScreenedForDepression]
			  ,[ScreenedBPLastVisit]
			  ,[ScreenedDiabetes]
			  ,[ScreenedDepressionDate]
			  ,[AppointmentsCategory]
			  ,[Pregnant]
			  ,[Breastfeeding]
			  ,[IsRTTLast12MonthsAfter3monthsIIT]
			  ,[SwitchedToSecondLineLast12Months]
			  ,[AsOfDateKey]
			  ,[LoadDate]
		FROM [NDWH].[dbo].[FACTART]
	 ) As b
	 ON (
			a.FacilityKey		= b.FacilityKey		and
			a.PatientKey		= b.PatientKey		and
			a.AsOfDateKey		= b.AsOfDateKey		and
			a.[ARTOutcomeKey]   = b.[ARTOutcomeKey]

		)

when not matched THEN
	INSERT ([PatientKey]
			  ,[FacilityKey]
			  ,[PartnerKey]
			  ,[AgencyKey]
			  ,[AgeGroupKey]
			  ,[StartARTDateKey]
			  ,[LastARTDateKey]
			  ,[DateConfirmedPosKey]
			  ,[ARTOutcomeKey]
			  ,[CurrentRegimen]
			  ,[CurrentRegimenline]
			  ,[StartRegimen]
			  ,[StartRegimenLine]
			  ,[AgeAtEnrol]
			  ,[AgeAtARTStart]
			  ,[AgeLastVisit]
			  ,[Agegrouping]
			  ,[TimetoARTDiagnosis]
			  ,[TimetoARTEnrollment]
			  ,[PregnantARTStart]
			  ,[PregnantAtEnrol]
			  ,[LastVisitDate]
			  ,[NextAppointmentDate]
			  ,[StartARTAtThisfacility]
			  ,[PreviousARTStartDate]
			  ,[PreviousARTRegimen]
			  ,[WhoStage]
			  ,[PHQ_9_rating]
			  ,[ScreenedForDepression]
			  ,[ScreenedBPLastVisit]
			  ,[ScreenedDiabetes]
			  ,[ScreenedDepressionDate]
			  ,[AppointmentsCategory]
			  ,[Pregnant]
			  ,[Breastfeeding]
			  ,[IsRTTLast12MonthsAfter3monthsIIT]
			  ,[SwitchedToSecondLineLast12Months]
			  ,[AsOfDateKey]
			  ,[LoadDate]	
			  ,[DateTimeStamp]
			)
VALUES ([PatientKey]
			  ,[FacilityKey]
			  ,[PartnerKey]
			  ,[AgencyKey]
			  ,[AgeGroupKey]
			  ,[StartARTDateKey]
			  ,[LastARTDateKey]
			  ,[DateConfirmedPosKey]
			  ,[ARTOutcomeKey]
			  ,[CurrentRegimen]
			  ,[CurrentRegimenline]
			  ,[StartRegimen]
			  ,[StartRegimenLine]
			  ,[AgeAtEnrol]
			  ,[AgeAtARTStart]
			  ,[AgeLastVisit]
			  ,[Agegrouping]
			  ,[TimetoARTDiagnosis]
			  ,[TimetoARTEnrollment]
			  ,[PregnantARTStart]
			  ,[PregnantAtEnrol]
			  ,[LastVisitDate]
			  ,[NextAppointmentDate]
			  ,[StartARTAtThisfacility]
			  ,[PreviousARTStartDate]
			  ,[PreviousARTRegimen]
			  ,[WhoStage]
			  ,[PHQ_9_rating]
			  ,[ScreenedForDepression]
			  ,[ScreenedBPLastVisit]
			  ,[ScreenedDiabetes]
			  ,[ScreenedDepressionDate]
			  ,[AppointmentsCategory]
			  ,[Pregnant]
			  ,[Breastfeeding]
			  ,[IsRTTLast12MonthsAfter3monthsIIT]
			  ,[SwitchedToSecondLineLast12Months]
			  ,[AsOfDateKey]
			  ,[LoadDate]	
			  ,Getdate()
			);
END
---------------End
-----------------------Archive  FactARTHistory where the months exceed 12 months
insert into [NDWH].[dbo].[FACTARTHistory_Archive]( [PatientKey]
												  ,[FacilityKey]
												  ,[PartnerKey]
												  ,[AgencyKey]												 
												  ,[ARTOutcomeKey]
												  ,[AsOfDateKey]
												  ,[PatientPKHash]
												  ,[PatientIDHash]
												  ,[SiteCode]
												  ,[age]
												  ,[AgeGroup]
												  ,[StartARTDate]
												  ,[PartnerName]
												  ,[AgencyName]
												  ,[ARTOutcome]
												  ,[CurrentRegimen]
												  ,[CurrentRegimenline]
												  ,[StartRegimen]
												  ,[StartRegimenLine]
												  ,[AgeAtEnrol]
												  ,[AgeAtARTStart]
												  ,[AgeLastVisit]
												  ,[Agegrouping]
												  ,[TimetoARTDiagnosis]
												  ,[TimetoARTEnrollment]
												  ,[PregnantARTStart]
												  ,[PregnantAtEnrol]
												  ,[LastVisitDate]
												  ,[NextAppointmentDate]
												  ,[StartARTAtThisfacility]
												  ,[PreviousARTStartDate]
												  ,[PreviousARTRegimen]
												  ,[WhoStage]
												  ,[PHQ_9_rating]
												  ,[ScreenedForDepression]
												  ,[ScreenedBPLastVisit]
												  ,[ScreenedDiabetes]
												  ,[ScreenedDepressionDate]
												  ,[AppointmentsCategory]
												  ,[Pregnant]
												  ,[Breastfeeding]
												  ,[IsRTTLast12MonthsAfter3monthsIIT]
												  ,[SwitchedToSecondLineLast12Months]
												  ,[AsOfDate]
												  ,[ISTxCurr]
												  ,[DifferentiatedCare]
												  ,[LoadDate]
												  ,[Eligible4VL]
												  ,[Last12MonthVL]
												  ,[Last12MVLSup]
												  ,[LastVL]
												  ,[LastVLDate]
												  ,[Last12MVLResult]
												  ,[HighViremia]
												  ,[LowViremia]
												  ,[DateTimeStamp])
	SELECT [PatientKey]
      ,[FacilityKey]
      ,[PartnerKey]
      ,[AgencyKey]     
      ,[ARTOutcomeKey]
      ,[AsOfDateKey]
      ,[PatientPKHash]
      ,[PatientIDHash]
      ,[SiteCode]
      ,[age]
      ,[AgeGroup]
      ,[StartARTDate]
      ,[PartnerName]
      ,[AgencyName]
      ,[ARTOutcome]
      ,[CurrentRegimen]
      ,[CurrentRegimenline]
      ,[StartRegimen]
      ,[StartRegimenLine]
      ,[AgeAtEnrol]
      ,[AgeAtARTStart]
      ,[AgeLastVisit]
      ,[Agegrouping]
      ,[TimetoARTDiagnosis]
      ,[TimetoARTEnrollment]
      ,[PregnantARTStart]
      ,[PregnantAtEnrol]
      ,[LastVisitDate]
      ,[NextAppointmentDate]
      ,[StartARTAtThisfacility]
      ,[PreviousARTStartDate]
      ,[PreviousARTRegimen]
      ,[WhoStage]
      ,[PHQ_9_rating]
      ,[ScreenedForDepression]
      ,[ScreenedBPLastVisit]
      ,[ScreenedDiabetes]
      ,[ScreenedDepressionDate]
      ,[AppointmentsCategory]
      ,[Pregnant]
      ,[Breastfeeding]
      ,[IsRTTLast12MonthsAfter3monthsIIT]
      ,[SwitchedToSecondLineLast12Months]
      ,[AsOfDate]
      ,[ISTxCurr]
      ,[DifferentiatedCare]
      ,[LoadDate]
      ,[Eligible4VL]
      ,[Last12MonthVL]
      ,[Last12MVLSup]
      ,[LastVL]
      ,[LastVLDate]
      ,[Last12MVLResult]
      ,[HighViremia]
      ,[LowViremia]
      ,[DateTimeStamp]
  FROM [NDWH].[dbo].[FactARTHistory]
  where datediff(month,AsOfDateKey,getdate()) > 12
  order by AsOfDateKey desc;

----------------------END
-------------------Delete the archived records from [NDWH].[dbo].[FactARTHistory]

DELETE [NDWH].[dbo].[FactARTHistory]
WHERE datediff(month,AsOfDateKey,getdate()) > 12;
----------End
IF OBJECT_ID(N'[NDWH].[dbo].[FACTART]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FACTART];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	  SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),
Patient As ( 
  Select     
			  Patient.PatientIDHash,
			  Patient.PatientPKHash,
			  Patient.PatientPK,
			  cast (Patient.SiteCode as nvarchar) As SiteCode,
			  DATEDIFF(yy,Patient.DOB,Patient.RegistrationAtCCC) AgeAtEnrol,
			  DATEDIFF(yy,Patient.DOB,ART.StartARTDate) AgeAtARTStart,
			  ART.StartARTAtThisfacility,
			  ART.PreviousARTStartDate,
			  ART.PreviousARTRegimen,
			  ART.StartARTDate,
			  LastARTDate,
			  CASE WHEN [Patient].DateConfirmedHIVPositive IS NOT NULL AND ART.StartARTDate IS NOT NULL
						 THEN CASE WHEN Patient.DateConfirmedHIVPositive<= ART.StartARTDate THEN DATEDIFF(DAY,Patient.DateConfirmedHIVPositive,ART.StartARTDate)
							ELSE NULL END
						ELSE NULL END AS TimetoARTDiagnosis,
			  CASE WHEN Patient.RegistrationAtCCC IS NOT NULL AND ART.StartARTDate IS NOT NULL
						THEN CASE WHEN Patient.RegistrationAtCCC<=ART.StartARTDate  THEN DATEDIFF(DAY,Patient.[RegistrationAtCCC],ART.StartARTDate)
						ELSE NULL END
						ELSE NULL END AS TimetoARTEnrollment,
			 Pre.PregnantARTStart,
			 Pre.PregnantAtEnrol,
			 las.LastEncounterDate As LastVisitDate,
			 las.NextAppointmentDate,
			 datediff(yy, patient.DOB, las.LastEncounterDate) as AgeLastVisit,
			 lastRegimen,
			 StartRegimen,
			 lastRegimenline,
			 StartRegimenline,
			 obs.WHOStage,
			 Patient.DateConfirmedHIVPositive,
			 outcome.ARTOutcome,
			 Case When DATEDIFF(DAY, las.LastEncounterDate,las.NextAppointmentDate) <=89 THEN '<3 Months'
			 when DATEDIFF(DAY, las.LastEncounterDate,las.NextAppointmentDate) >=90 and DATEDIFF(DAY, las.LastEncounterDate,las.NextAppointmentDate) <=150 THEN '<3-5 Months'
			 When DATEDIFF(DAY, las.LastEncounterDate,las.NextAppointmentDate) >151 THEN '>6+ Months'
			 Else 'Unclassified'
			 END As AppointmentsCategory,
			pbfw_at_confirm_pos.PbfwAtConfirmedPositive
			from ODS.dbo.CT_Patient Patient
			inner join ODS.dbo.CT_ARTPatients ART on ART.PatientPK=Patient.Patientpk and ART.SiteCode=Patient.SiteCode
			left join ODS.dbo.Intermediate_PregnancyAsATInitiation   Pre on Pre.Patientpk= Patient.PatientPK and Pre.SiteCode=Patient.SiteCode
			left join ODS.dbo.Intermediate_LastPatientEncounter las on las.PatientPK =Patient.PatientPK  and las.SiteCode =Patient.SiteCode 
			left join ODS.dbo.Intermediate_ARTOutcomes  outcome on outcome.PatientPK=Patient.PatientPK and outcome.SiteCode=Patient.SiteCode
			left join ODS.dbo.intermediate_LatestObs obs on obs.PatientPK=Patient.PatientPK and obs.SiteCode=Patient.SiteCode
			left join ODS.dbo.Intermediate_PbfwAtConfimationPositive as pbfw_at_confirm_pos on pbfw_at_confirm_pos.PatientPK = Patient.PatientPK and pbfw_at_confirm_pos.SiteCode = Patient.SiteCode
),
OrderedPBFW As (
                  select 
					row_number() over(partition by  SiteCode,PatientPK order by AsOfDate desc) as rank, 
					SiteCode,
					PatientPK,
					PatientPkHash,						
					Ispregnant,
					IsBreastFeeding,										
					AsOfDate						
				from ODS.dbo.Intermediate_PregnantAndBreastFeeding

			),
MaxOrderedPBFW As (
					select SiteCode
						   ,PatientPK
						   ,PatientPkHash
						   ,Ispregnant
						   ,IsBreastFeeding	
						   ,AsOfDate
					from OrderedPBFW
					where rank =1 
				),
CombinedPatientAndPBFW as (

							select  Patient.PatientIDHash,
									Patient.PatientPKHash,
									Patient.PatientPK,
									Patient.SiteCode,
									AgeAtEnrol,
									AgeAtARTStart,
									StartARTAtThisfacility,
									PreviousARTStartDate,
									PreviousARTRegimen,
									StartARTDate,
									LastARTDate,
									TimetoARTDiagnosis,
									TimetoARTEnrollment,
									PregnantARTStart,
									PregnantAtEnrol,
									LastVisitDate,
									NextAppointmentDate,
									AgeLastVisit,
									lastRegimen,
									StartRegimen,
									lastRegimenline,
									StartRegimenline,
									WHOStage,
									DateConfirmedHIVPositive,
									ARTOutcome,
									AppointmentsCategory,
									case when pbfw.IsPregnant = 1 then 'Yes' else 'No' end as Pregnant,
									case when pbfw.IsBreastfeeding = 1 then 'Yes' else 'No' end as Breastfeeding,
									PbfwAtConfirmedPositive
								from Patient 
								left join MaxOrderedPBFW pbfw
								on Patient.SiteCode = pbfw.SiteCode and Patient.PatientPK = pbfw.PatientPK 
							),

DepressionScreening as (
							Select 
								PatientPkHash,
								sitecode,
								VisitDate,
								ROW_NUMBER()OVER (PARTITION by SiteCode,PatientPK  ORDER BY VisitDate Desc ) As NUM,
								PHQ_9_rating
						   from ODS.dbo.CT_DepressionScreening
					),
   LatestDepressionScreening As (
								   Select
										PatientPkHash,
										Sitecode,
										visitdate as ScreenedDepressionDate,
										PHQ_9_rating
									from DepressionScreening
									where Num=1
   
								),
ncd_screening as (
					select 
						patient.PatientPKHash,
						patient.SiteCode,
						case 
							when latest_diabetes.Controlled in ('Yes', 'No') then  1 
							else 0
						end as ScreenedDiabetes,
						case 
						when latest_hypertension.Controlled in ('Yes', 'No') then  1 
						else 0
						end as ScreenedBPLastVisit   
					from  CombinedPatientAndPBFW Patient
					left join ODS.dbo.Intermediate_NCDControlledStatusLastVisit as latest_diabetes on latest_diabetes.PatientPKHash = Patient.PatientPKHash
						and latest_diabetes.SiteCode = Patient.SiteCode
						and latest_diabetes.Disease = 'Diabetes'
					left join ODS.dbo.Intermediate_NCDControlledStatusLastVisit as latest_hypertension on latest_hypertension.PatientPKHash = Patient.PatientPKHash
						and latest_hypertension.SiteCode = Patient.SiteCode
						and latest_hypertension.Disease = 'Hypertension'
				),
rtt_within_last_12_months as (
							  select distinct
									 PatientPKHash,
									MFLCode
							  from ODS.dbo.Intermediate_RTTLast12MonthsAfter3monthsIIT
							),
partitioned_regimen_line_data as (
									select 
										pharmacy.PatientPKHash,
										pharmacy.SiteCode,
										pharmacy.DispenseDate,
										pharmacy.RegimenLine,
										pharmacy.RegimenChangedSwitched,
										art.LastRegimenLine,
										row_number() over (partition by pharmacy.PatientPKHash, pharmacy.SiteCode order by DispenseDate desc) as rank
									from ODS.dbo.CT_PatientPharmacy as pharmacy
									left join ODS.dbo.CT_ARTPatients as art on art.PatientPKHash = pharmacy.PatientPKHash
									  and art.SiteCode = pharmacy.SiteCode
									where RegimenLine = 'First Line' and RegimenChangedSwitched = 'Switch'
								),
swithced_to_second_line_in_last_12_monhts as (
												select 
													PatientPKHash,
													SiteCode,
													DispenseDate,
													RegimenChangedSwitched
												from partitioned_regimen_line_data
												where rank = 1 and datediff(month, DispenseDate, eomonth(dateadd(mm,-1,getdate()))) <= 12
												  and LastRegimenLine = 'Second Line'
											),

 UnsuppressedAtlastVl as (
							SELECT
								PatientPKHash,
								SiteCode,
								TestResult,
								OrderedbyDate
							from ODS.dbo.Intermediate_OrderedViralLoads
							where   try_cast (TestResult as decimal) > 1000 and  rank=1
						),
  UnsuppressedAtsecondLastVL as (
									 SELECT
										PatientPKHash,
										SiteCode,
										TestResult,
										OrderedbyDate
									from ODS.dbo.Intermediate_OrderedViralLoads
									where   try_cast (TestResult as decimal) > 1000 and  rank=2
  
								),
ConfirmedTreatmentFailure as (
								SELECT
									UnsuppressedAtlastVl.PatientPKHash,
									UnsuppressedAtlastVl.SiteCode,
									UnsuppressedAtlastVl.TestResult,
									UnsuppressedAtlastVl.OrderedbyDate
							   from  UnsuppressedAtlastVl
							   inner join UnsuppressedAtsecondLastVL 
								on UnsuppressedAtlastVl.PatientPKHash=UnsuppressedAtsecondLastVL.PatientPKHash and 
									UnsuppressedAtlastVl.SiteCode=UnsuppressedAtsecondLastVL.SiteCode


							),
TBLamResults as (
					Select 
						Patientpkhash,
						sitecode,
						TestResult,
						OrderedbyDate
					from ODS.dbo.ct_PatientLabs
					where testname='TB LAM'
				),
OrderedTBLamResults As (
						 select 
							row_number() over(partition by  SiteCode,Patientpkhash order by OrderedbyDate desc) as rank, 
							Patientpkhash,
							sitecode,
							TestResult,
							OrderedbyDate
						from TBLamResults
					),
MaxOrderedTBLamResults As (
							select Patientpkhash,
								sitecode,
								TestResult,
								OrderedbyDate
							from OrderedTBLamResults
							where rank =1 
						),
TBLamPos as (
				Select 
					Patientpkhash,
					sitecode,
					TestResult,
					OrderedbyDate
				from ODS.dbo.ct_PatientLabs
				where testname='TB LAM'and TestResult='Present'
			),
OrderedTBLamPos As (
                     select 
						row_number() over(partition by  SiteCode,Patientpkhash order by OrderedbyDate desc) as rank, 
						Patientpkhash,
						sitecode,
						TestResult,
						OrderedbyDate
					from TBLamResults

					),
MaxOrderedTBLamPos As (
						select Patientpkhash,
								sitecode,
								TestResult,
								OrderedbyDate
						from OrderedTBLamResults
						where rank =1 

					),
OnTBDrugs as (
				Select 
					PatientPKHash,
					SiteCode,
					VisitDate
				from ODS.dbo.CT_Ipt
				where OnTBDrugs='Yes'
			),
OrderedOnTBDrugs As (
                     select 
						row_number() over(partition by  SiteCode,Patientpkhash order by VisitDate desc) as rank, 
						PatientPKHash,
						SiteCode,
						VisitDate
					from OnTBDrugs
				),
MaxOrderedOrderedOnTBDrugs As (
									select PatientPKHash,
										SiteCode,
										VisitDate
									from OrderedOnTBDrugs
									where rank =1 
								),

TBLamPosonTBRx as (
					Select 
						TBLamPos.PatientPKHash,
						TBLamPos.SiteCode
					from MaxOrderedTBLamPos TBLamPos
					inner join MaxOrderedOrderedOnTBDrugs OnTBDrugs 
						on TBLamPos.PatientPKHash=OnTBDrugs.PatientPKHash and 
							TBLamPos.SiteCode=OnTBDrugs.SiteCode
					where TBLamPos.OrderedbyDate <OnTBDrugs.VisitDate
				),
SerumCrag as (
				Select 
					PatientPKHash,
					SiteCode,
					OrderedbyDate,
					TestResult
				from ODS.dbo.CT_PatientLabs
				where testname in ('Crag test','Serum Crypto','serum cryptococcal ag')
			),
OrderedSerumCrag As (
						 select 
							row_number() over(partition by  SiteCode,Patientpkhash order by OrderedbyDate desc) as rank, 
							PatientPKHash,
							SiteCode,
							OrderedbyDate,
							TestResult
						from SerumCrag
					),
MaxOrderedSerumCrag As (
							select PatientPKHash,
									SiteCode,
									OrderedbyDate,
									TestResult
							from OrderedSerumCrag
							where rank =1 
						),

CSFCrAg as (
				Select 
					  PatientPKHash,
					  SiteCode,
					  OrderedbyDate,
					  TestResult
				from ODS.dbo.CT_PatientLabs
				where testname ='CSF Crypto'
			),

OrderedOnCSFCrAg As (
						 select 
							row_number() over(partition by  SiteCode,Patientpkhash order by OrderedbyDate desc) as rank, 
							PatientPKHash,
							SiteCode,
							OrderedbyDate,
							TestResult
						from CSFCrAg
					),
MaxOrderedCSFCrAg As (
						select PatientPKHash,
								SiteCode,
								OrderedbyDate,
								TestResult
						from OrderedOnCSFCrAg
						where rank =1 
					),
Fluconazole as (
				  Select 
					  PatientPKHash,
					  SiteCode
				 from ODS.dbo.CT_PatientPharmacy
				 where Drug like '%Fluconazole%'
				),

PreemtiveCMTheraphy as (
							Select 
								Fluconazole.PatientPKHash,
								Fluconazole.SiteCode
							from Fluconazole
								inner join SerumCrag on Fluconazole.Patientpkhash=SerumCrag.Patientpkhash and Fluconazole.Sitecode=SerumCrag.Sitecode
						),
InitiatedCMTreatment as (
							Select
								  CSFCrAg.PatientPKHash,
								  CSFCrAg.sitecode
							from MaxOrderedCSFCrAg CSFCrAg
							inner join Fluconazole on CSFCrAg.PatientPKHash=Fluconazole.PatientPKHash and CSFCrAg.SiteCode=Fluconazole.SiteCode
							where TestResult='1.00'
						)
  select
            Factkey = IDENTITY(INT, 1, 1),
            pat.PatientKey,
            fac.FacilityKey,
            partner.PartnerKey,
            agency.AgencyKey,
            age_group.AgeGroupKey,
            StartARTDate.DateKey As StartARTDateKey,
            LastARTDate.DateKey  as LastARTDateKey,
            DateConfirmedPos.DateKey as DateConfirmedPosKey,
            ARTOutcome.ARTOutcomeKey,
            lastRegimen As CurrentRegimen,
            LastRegimenLine As CurrentRegimenline,
            StartRegimen,
            StartRegimenLine,
            AgeAtEnrol,
            AgeAtARTStart,
            AgeLastVisit,
            CASE
              WHEN floor( AgeLastVisit ) < 15 THEN
              'Child' 
              WHEN floor( AgeLastVisit ) >= 15 THEN
              'Adult' ELSE 'Aii' 
            END AS Agegrouping,
            TimetoARTDiagnosis,
            TimetoARTEnrollment,
            PregnantARTStart,
            PregnantAtEnrol,
            Patient.LastVisitDate,
            Patient.NextAppointmentDate,
            StartARTAtThisfacility,
            PreviousARTStartDate,
            PreviousARTRegimen,
            WhoStage,
            PHQ_9_rating,
            case when LatestDepressionScreening.Patientpkhash is not null then 1 else 0 End as ScreenedForDepression,
            coalesce(ncd_screening.ScreenedBPLastVisit, 0) as ScreenedBPLastVisit,
            coalesce(ncd_screening.ScreenedDiabetes, 0) as ScreenedDiabetes,
			      ScreenedDepressionDate,
            AppointmentsCategory,
            end_month.Date as AsOfDate,
            Pregnant,
            Breastfeeding,
            case 
              when rtt_within_last_12_months.PatientPkHash is not null then 1 
              else 0 
            end as IsRTTLast12MonthsAfter3monthsIIT,
            case 
              when swithced_to_second_line_in_last_12_monhts.PatientPkHash is not null then 1 
              else 0
            end as SwitchedToSecondLineLast12Months,
            end_month.DateKey as AsOfDateKey,
            Patient.PbfwAtConfirmedPositive as IsPbfwAtConfirmationPositive,
            Case When ConfirmedTreatmentFailure.PatientPKHash is not null then 1 else 0 End as ConfirmedTreatmentFailure,
            case when TBLamResults.PatientPKHash is not null then 1 else 0 end as DoneTBLamTest,
            case when TBLamResults.TestResult='Present' Then 1 else 0 End as TBLamPositive,
            case when TBLamPosonTBRx.PatientPKHash is not null then 1 Else 0 End as TBLamPosonTBRx,
            case when SerumCrag.PatientPKHash is not null then 1 Else 0 End as DoneCragTest,
            case when SerumCrag.TestResult='Positive' then 1 Else 0 end as CrAgPositive,
            case when CSFCrAg.Patientpkhash is not null then 1 Else 0 end as CSFCrAg,
            case when CSFCrAg.TestResult='1.00' then 1 else 0 End as CSFCrAgPositive,
            case when PreemtiveCMTheraphy.PatientPKHash is not null then 1 Else 0 End as PreemtiveCMTheraphy,
            case when InitiatedCMTreatment.PatientPKHash is not null then 1 Else 0 End as InitiatedCMTreatment,
            case when MaxOrderedOrderedOnTBDrugs.Patientpkhash is not null then 1 Else 0 End as OnTBTreatment,
            cast(getdate() as date) as LoadDate
INTO NDWH.dbo.FACTART 
from  CombinedPatientAndPBFW Patient
left join NDWH.dbo.DimPatient as Pat on pat.PatientPKHash=Patient.PatientPkHash and Pat.SiteCode=Patient.SiteCode
left join NDWH.dbo.Dimfacility fac on fac.MFLCode=Patient.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code  = Patient.SiteCode 
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = Patient.AgeLastVisit
left join NDWH.dbo.DimDate as StartARTDate on StartARTDate.Date = Patient.StartARTDate
left join NDWH.dbo.DimDate as LastARTDate on  LastARTDate.Date=Patient.LastARTDate
left join NDWH.dbo.DimDate as DateConfirmedPos on  DateConfirmedPos.Date=Patient.DateConfirmedHIVPositive
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join ODS.dbo.Intermediate_ARTOutcomes As IOutcomes  on IOutcomes.PatientPKHash = Patient.PatientPkHash  and IOutcomes.SiteCode = Patient.SiteCode
left join LatestDepressionScreening on LatestDepressionScreening.Patientpkhash=patient.patientpkhash and LatestDepressionScreening.sitecode=patient.sitecode
left join NDWH.dbo.DimARTOutcome ARTOutcome on ARTOutcome.ARTOutcome=IOutcomes.ARTOutcome
left join ncd_screening on ncd_screening.PatientPKHash = patient.PatientPKHash
  and ncd_screening.SiteCode = patient.SiteCode
left join NDWH.dbo.DimDate as end_month on end_month.Date = eomonth(dateadd(mm,-1,getdate()))
left join rtt_within_last_12_months on rtt_within_last_12_months.PatientPKHash = Patient.PatientPKHash
  and rtt_within_last_12_months.MFLCode = Patient.SiteCode
left join swithced_to_second_line_in_last_12_monhts on swithced_to_second_line_in_last_12_monhts.PatientPKHash = Patient.PatientPKHash
  and swithced_to_second_line_in_last_12_monhts.SiteCode = Patient.SiteCode
  left join ConfirmedTreatmentFailure on ConfirmedTreatmentFailure.PatientPKHash=Patient.patientpkhash and ConfirmedTreatmentFailure.SiteCode=Patient.sitecode
  left join MaxOrderedTBLamResults TBLamResults on TBLamResults.PatientPKHash=Patient.PatientPKHash and TBLamResults.SiteCode=Patient.SiteCode
  left join TBLamPosonTBRx on TBLamPosonTBRx.PatientPKHash=Patient.PatientPKHash and TBLamPosonTBRx.SiteCode=Patient.SiteCode
  left join MaxOrderedSerumCrag SerumCrag on SerumCrag.PatientPKHash=Patient.PatientPKHash and SerumCrag.SiteCode=Patient.SiteCode
  left join MaxOrderedCSFCrAg CSFCrAg on CSFCrAg.Patientpkhash=Patient.PatientPKHash and CSFCrAg.SiteCode=Patient.SiteCode
  left join PreemtiveCMTheraphy on PreemtiveCMTheraphy.PatientPKHash=Patient.PatientPKHash and PreemtiveCMTheraphy.SiteCode=Patient.SiteCode
  left join InitiatedCMTreatment on InitiatedCMTreatment.PatientPKHash=Patient.PatientPKHash and InitiatedCMTreatment.SiteCode=Patient.SiteCode
  left join MaxOrderedOrderedOnTBDrugs on MaxOrderedOrderedOnTBDrugs.Patientpkhash=Patient.Patientpkhash and MaxOrderedOrderedOnTBDrugs.sitecode=Patient.sitecode
WHERE pat.voided =0 ;
alter table NDWH.dbo.FactART add primary key(FactKey)
END
