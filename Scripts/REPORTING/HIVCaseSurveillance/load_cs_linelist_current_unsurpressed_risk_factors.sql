IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistCurrentUnsurpressedRiskFactors]', N'U') IS NOT NULL
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistCurrentUnsurpressedRiskFactors];

BEGIN

    with ncd_mental_illness as (
    select 
    PatientKey 
    from NDWH.Fact.FactNCD
    where [Mental illness] = 1
    ),
    alcohol_drug_abuse_last_one_year as (
        select 
            *
        from NDWH.Fact.FactLatestObs
        where HasAlcoholOrDrugUseLastOneYear = 1
    ),
    missed_appointments as (
        select 
            PatientKey,
            ARTOutcomeDescription,
            LastVisitDate,
            NextAppointmentDate
        from NDWH.dbo.FACTART as art
        left join NDWH.Dim.DimARTOutcome as outcome on art.ARTOutcomeKey = outcome.ARTOutcomeKey
        where ARTOutcomeDescription in ('LOSS TO FOLLOW UP', 'UNDOCUMENTED LOSS')
    ),
    current_unsurpressed as (
        select 
            PatientKey,
            FacilityKey,
            PartnerKey,
            AgencyKey,
            AgeGroupKey,
            HasValidVL,
            ValidVLSup,
            ValidVLResultCategory1,
            ValidVLResultCategory2,
            LowViremia,
            HighViremia
        from NDWH.Fact.FactViralLoads
        where HasValidVL = 1 and ValidVLSup = 0
    )
    select 
        eomonth(confirm_date.date) as CohortYearMonth,
        facility.FacilityName,
        facility.MFLCode,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        patient.gender as Gender,
        age_group.DATIMAgeGroup as AgeGroup,
        case when current_unsurpressed.PatientKey is not null then 1 else 0 end as IsCurrentlyUnsurpressed,
        case when ncd_mental_illness.PatientKey is not null then 1 else 0 end as HasHistoryOfmentalIllness,
        case when alcohol_drug_abuse_last_one_year.Patientkey is not null then 1 else 0 end as HasAlchoholOrDrugAbuseLastOneYear,
        case when missed_appointments.PatientKey is not null then 1 else 0 end as HasMissedAppointments
    into HIVCaseSurveillance.dbo.CsLinelistCurrentUnsurpressedRiskFactors
    from current_unsurpressed
    left join ncd_mental_illness on ncd_mental_illness.PatientKey = current_unsurpressed.PatientKey
    left join alcohol_drug_abuse_last_one_year on alcohol_drug_abuse_last_one_year.PatientKey = current_unsurpressed.PatientKey
    left join missed_appointments on missed_appointments.PatientKey = current_unsurpressed.PatientKey
    left join NDWH.Dim.DimPatient as patient on patient.PatientKey = current_unsurpressed.PatientKey
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = current_unsurpressed.AgeGroupKey
    left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = current_unsurpressed.FacilityKey
    left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = current_unsurpressed.PartnerKey
    left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = current_unsurpressed.AgencyKey
    left join NDWH.Dim.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey

END
