---------------Insert into FactArtHistory before droping FactART for new data
BEGIN
	INSERT INTO [NDWH].[dbo].[factarthistory]
            ([facilitykey],
             [partnerkey],
             [agencykey],
             [patientkey],
             [asofdatekey],
             [artoutcomekey],
             [nextappointmentdate],
             [lastencounterdate],
             [loaddate],
             datetimestamp)
SELECT [facilitykey],
       [partnerkey],
       [agencykey],
       [patientkey],
       [asofdatekey],
       artoutcomekey,
       [nextappointmentdate],
       lastvisitdate,
       [loaddate],
       Getdate() AS DateTimeStamp
FROM   [NDWH].[dbo].[factart] 
END

---------------End


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
    pbfw.Pregnant,
    pbfw.Breastfeeding
        from 
ODS.dbo.CT_Patient Patient
inner join ODS.dbo.CT_ARTPatients ART on ART.PatientPK=Patient.Patientpk and ART.SiteCode=Patient.SiteCode
left join ODS.dbo.Intermediate_PregnancyAsATInitiation   Pre on Pre.Patientpk= Patient.PatientPK and Pre.SiteCode=Patient.SiteCode
left join ODS.dbo.Intermediate_LastPatientEncounter las on las.PatientPK =Patient.PatientPK  and las.SiteCode =Patient.SiteCode 
left join ODS.dbo.Intermediate_ARTOutcomes  outcome on outcome.PatientPK=Patient.PatientPK and outcome.SiteCode=Patient.SiteCode
left join ODS.dbo.intermediate_LatestObs obs on obs.PatientPK=Patient.PatientPK and obs.SiteCode=Patient.SiteCode
left join ODS.dbo.Intermediate_Pbfw pbfw on pbfw.PatientPK=Patient.PatientPK and pbfw.SiteCode=Patient.SiteCode

),

   DepressionScreening as (Select 
   PatientPkHash,
   sitecode,
   VisitDate,
 ROW_NUMBER()OVER (PARTITION by SiteCode,PatientPK  ORDER BY VisitDate Desc ) As NUM,
   PHQ_9_rating
   from ODS.dbo.CT_DepressionScreening
   ),
   LatestDepressionScreening As (Select
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
        ScreenedDiabetes,
        ScreenedBPLastVisit
    from Patient
    left join ODS.dbo.Intermediate_LatestDiabetesTests as latest_diabetes_test on latest_diabetes_test.PatientPKHash = Patient.PatientPKHash
        and latest_diabetes_test.SiteCode = Patient.SiteCode
    left join ODS.dbo.Intermediate_LastVisitDate as visit on visit.PatientPK = Patient.PatientPK
        and visit.SiteCode = Patient.SiteCode
),
rtt_within_last_12_months as (
  select 
    distinct PatientPKHash,
    MFLCode
  from ODS.dbo.Intermediate_RTTLast12MonthsAfter3monthsIIT
)
   Select 
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

            Pregnant,
            Breastfeeding,
            case 
              when rtt_within_last_12_months.PatientPkHash is not null then 1 
              else 0 
            end as IsRTTLast12MonthsAfter3monthsIIT,
            end_month.DateKey as AsOfDateKey,
            cast(getdate() as date) as LoadDate
INTO NDWH.dbo.FACTART 
from  Patient
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
WHERE pat.voided =0;
alter table NDWH.dbo.FactART add primary key(FactKey)



END