IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistCurrentVLCategories]', N'U') IS NOT NULL
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistCurrentVLCategories];

BEGIN

    with VLResults as ( 
        select 
                PatientKey,
                FacilityKey,
                PartnerKey,
                AgencyKey,
                AgeGroupKey,
                HasValidVL,
                ValidVLSup,
                ValidVLResultCategory2 as CurrentVLCategory
        from NDWH.Fact.FactViralLoads
        where HasValidVL = 1
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
        CurrentVLCategory
    into HIVCaseSurveillance.dbo.CsLinelistCurrentVLCategories
    from VLResults
    left join NDWH.Dim.DimPatient as patient on patient.PatientKey = VLResults.PatientKey
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = VLResults.AgeGroupKey
    left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = VLResults.FacilityKey
    left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = VLResults.PartnerKey
    left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = VLResults.AgencyKey
    left join NDWH.Dim.DimDate as confirm_date on confirm_date.DateKey = patient.DateConfirmedHIVPositiveKey

END
