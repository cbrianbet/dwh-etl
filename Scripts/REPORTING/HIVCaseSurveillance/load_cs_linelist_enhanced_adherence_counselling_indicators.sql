IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistEnhancedAdherenceCounsellingIndicators]', N'U') IS NOT NULL
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistEnhancedAdherenceCounsellingIndicators];

BEGIN

    with unsurpressed_as_of_one_year_ago as (
        select 
            PatientKey,
            FacilityKey,
            IsValidVL,
            VLSup,
            TestResult,
            TestName,
            cast(OrderedByDate as date) as LastOrderedByDate,
            AsOfDate,
            AgeAsOfDate
        from NDWH.[Fact].[FactViralLoad_Historical]
        where datediff(month, AsOfDate, eomonth(dateadd(mm,-1,getdate()))) = 12 
            and IsValidVL = 1 
            and VLSup = 0 
    ),
    vl_tests_within_three_months_from_as_of_date as (
        select 
            vl.PatientKey,
            unsurpressed_as_of_one_year_ago.AsOfDate,
            unsurpressed_as_of_one_year_ago.LastOrderedByDate,
            vl_date.Date as RepeatOrderedByDate,
            datediff(day, unsurpressed_as_of_one_year_ago.LastOrderedByDate, vl_date.[Date]) as diff_in_days,
            row_number() over (partition by vl.PatientKey order by vl_date.Date asc) as rank,
            vl.TestResult as RepeatVLResult
        from NDWH.Fact.FactVLLastTwoYears as vl
        left join unsurpressed_as_of_one_year_ago on unsurpressed_as_of_one_year_ago.PatientKey = vl.PatientKey
        left join NDWH.Dim.DimDate as vl_date on vl_date.DateKey = vl.OrderedbyDateKey
        where datediff(day, unsurpressed_as_of_one_year_ago.LastOrderedByDate, vl_date.Date) between 7 and 90 -- diff between one week & 3 months
    ),
    earliest_repeat_vl_within_three_months as (
        select
        PatientKey, 
        case
            when ISNUMERIC(RepeatVLResult) = 1 then
                case 
                    when cast(replace(RepeatVLResult,',','') AS float) >= 1000.00 then 'UNSUPPRESSED' 
                    when cast(replace(RepeatVLResult,',','') as float) between 200.00 and 999.00  then 'High Risk LLV '
                    when cast(replace(RepeatVLResult,',','') as float) between 50.00 and 199.00 then 'Low Risk LLV'
                    when cast(replace(RepeatVLResult,',','') as float) < 50 then 'LDL'
                end
        else
            case
                when RepeatVLResult IN ('Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level') then 'LDL' 
                else null 
            end 
        end as RepeatVLCategory
        from vl_tests_within_three_months_from_as_of_date
        where rank = 1
    ),
    eac_session_after_last_unsurpressed_vl as (
        select 
            eac.PatientKey,
            unsurpressed_as_of_one_year_ago.LastOrderedByDate,
            eac_date.Date as eac_date
        from NDWH.Fact.FactEACVisitsLastTwoYears as eac
        left join NDWH.Dim.DimDate as eac_date on eac_date.DateKey = eac.VisitDateKey
        left join unsurpressed_as_of_one_year_ago on unsurpressed_as_of_one_year_ago.PatientKey = eac.PatientKey
        where datediff(day, unsurpressed_as_of_one_year_ago.LastOrderedByDate, eac_date.Date) between 1 and 180 -- diff within 6 months
        
    ), 
    patients_at_least_one_eac_session_after_last_unsurpressed_vl as (
    select 
        distinct PatientKey
    from eac_session_after_last_unsurpressed_vl
    ),
    metrics as (
    select 
        unsurpressed_as_of_one_year_ago.PatientKey,
        unsurpressed_as_of_one_year_ago.FacilityKey,
        unsurpressed_as_of_one_year_ago.AgeAsOfDate,
        case when unsurpressed_as_of_one_year_ago.PatientKey is not null then 1 else 0 end as IsUnsurpressedAsOfOneYearAgo,
        case when earliest_repeat_vl_within_three_months.PatientKey is null then 1 else 0 end as WithoutRepeatVLWithinThreeMonths,
        earliest_repeat_vl_within_three_months.RepeatVLCategory as RepeatVLCategory,
        case when patients_at_least_one_eac_session_after_last_unsurpressed_vl.PatientKey is null then 1 else 0 end as WithoutEACSessionAfterLastUnsurpressedVL,
        case when earliest_repeat_vl_within_three_months.Patientkey is not null and earliest_repeat_vl_within_three_months.RepeatVLCategory not in ('LDL', 'Low Risk LLV') then 1 else 0 end as IsSuspectedTreatmentFailure
    from unsurpressed_as_of_one_year_ago
    left join earliest_repeat_vl_within_three_months on unsurpressed_as_of_one_year_ago.PatientKey = earliest_repeat_vl_within_three_months.PatientKey
    left join patients_at_least_one_eac_session_after_last_unsurpressed_vl on patients_at_least_one_eac_session_after_last_unsurpressed_vl.PatientKey = unsurpressed_as_of_one_year_ago.PatientKey
    )
    select 
        patient.PatientPKhash,
        patient.Gender,
        age_group.DATIMAgegroup as AgeGroup,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        facility.MFLCode,
        IsunsurpressedAsOfOneYearAgo,
        WithoutRepeatVLWithinThreeMonths,
        RepeatVLCategory,
        WithoutEACSessionAfterLastUnsurpressedVL,
        IsSuspectedTreatmentFailure
    into HIVCaseSurveillance.dbo.CsLinelistEnhancedAdherenceCounsellingIndicators
    from metrics
    left join NDWH.Dim.DimPatient as patient on patient.Patientkey = metrics.Patientkey
    left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = metrics.FacilityKey
    left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = metrics.AgeAsOfDate
END