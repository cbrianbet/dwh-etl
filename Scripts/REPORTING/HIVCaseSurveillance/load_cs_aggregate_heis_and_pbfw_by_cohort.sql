IF OBJECT_ID(N'HIVCaseSurveillance.dbo.CsAggregateHEIsAndPBFWbyCohort', N'U') IS NOT NULL 
	DROP TABLE HIVCaseSurveillance.dbo.CsAggregateHEIsAndPBFWbyCohort;

with art_patients as (
    select 
                art.PatientKey,
                patient.Gender,
                art.AgeLastVisit,
                art.FacilityKey,
                PartnerKey,
                AgencyKey,
                patient.dob,
                eomonth(confirmed_date.Date) as CohortYearMonth,
                IsPbfwAtConfirmationPositive
            from NDWH.dbo.FACTART as art 
            left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art.PatientKey
            left join NDWH.dbo.DimDate as confirmed_date on confirmed_date.DateKey = patient.DateConfirmedHIVPositiveKey
            left join NDWH.dbo.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
    )
    select
        CohortYearMonth,
        coalesce(agegroup.DATIMAgeGroup, 'Missing') as AgeGroup,
        coalesce(art_patients.Gender, 'Missing') as Gender,
        coalesce(facility.FacilityName, 'Missing') as FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        sum(case when datediff(month, dob, art_patients.CohortYearMonth) <= 24 then 1 else 0 end) as HeisConfirmedPositive,
        sum(case when IsPbfwAtConfirmationPositive = 1 then 1 else 0 end) as PbfwAtConfiramtionPositive
    into HIVCaseSurveillance.dbo.CsAggregateHEIsAndPBFWbyCohort
    from art_patients
    left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = art_patients.AgeLastVisit
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = art_patients.FacilityKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = art_patients.PartnerKey
    left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = art_patients.AgencyKey
    where CohortYearMonth is not null
    group by
        CohortYearMonth,	
        coalesce(agegroup.DATIMAgeGroup, 'Missing'), 
        coalesce(art_patients.Gender, 'Missing'),
        coalesce(facility.FacilityName, 'Missing'),
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName