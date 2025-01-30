if object_id(N'[HIVCaseSurveillance].[dbo].[CSAggregateTestedNegativePrepStart]', N'U') is not null 			
	drop table [HIVCaseSurveillance].[dbo].[CSAggregateTestedNegativePrepStart]
go

begin
    --  Accepted days between testing neg to starting prep
    declare @DaystoStartPrEP INT = 90 ;

    -- Minimum eligible age for PrEP start
    declare @MinimumDaysToPrEPStart INT = 15 ;

    with source_data as (
        select 
            row_number() over (partition by tests.FacilityKey, tests.PatientKey, tests.TestType order by tests.DateTestedKey desc) as num,
            elig.VisitDateKey,
            elig.HIVRiskCategory,
            elig.HtsRiskScore,
            case 
                when patient.PrepEnrollmentDateKey is not null and datediff(day, testDate.Date, prepStart.Date) <= @DaystoStartPrEP then 1 else 0 end as IsStartedOnPrep,
            patient.PatientKey,
            agegroup.DATIMAgeGroup,
            patient.Gender,
            facility.FacilityName,
            facility.latitude,
            facility.longitude,
            facility.County,
            facility.SubCounty,
            facility.MFLCode,
            partner.PartnerName,
            agency.AgencyName
        from NDWH.Fact.FactHTSClientTests as tests
        left join NDWH.Fact.FactHTSEligibilityExtract elig on elig.PatientKey = tests.PatientKey
            and elig.VisitDateKey = tests.DateTestedKey
        left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = tests.FacilityKey
        left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = tests.AgencyKey
        left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = tests.PartnerKey
        left join NDWH.Dim.DimPatient as patient on patient.PatientKey = tests.PatientKey
        left join NDWH.Dim.DimDate as testDate on testDate.DateKey =tests.DateTestedKey
        left join NDWH.Dim.DimDate as prepStart on prepStart.DateKey = patient.PrepEnrollmentDateKey
        left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = tests.AgeGroupKey
        where 
        tests.TestType = 'Initial Test' 
        and HIVRiskCategory is not null
        and agegroup.Age >= @MinimumDaysToPrEPStart --only picking for 15+ year olds who are eligible for PrEP
    )
    select
        DATIMAgeGroup as AgeGroup,
        Gender,
        FacilityName,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        HIVRiskCategory,
        count(*) as TestedNegative,
        sum(IsStartedOnPrep) as StartedOnPrep
    into [HIVCaseSurveillance].[dbo].[CSAggregateTestedNegativePrepStart]
    from source_data
    group by 
        DATIMAgeGroup,
        Gender,
        FacilityName,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        HIVRiskCategory

end