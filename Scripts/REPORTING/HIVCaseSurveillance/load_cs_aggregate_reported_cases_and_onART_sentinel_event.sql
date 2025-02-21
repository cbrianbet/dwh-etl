--truncate table first
truncate table [HIVCaseSurveillance].[dbo].[CsAggregateOnARTSentinelEvent];

--declare start and end dates i.e. within the last 12 months form reporting period
declare @start_date date;
select @start_date = dateadd(month, -11, eomonth(dateadd(month, -1, getdate())));

declare @end_date date;
select @end_date = eomonth(dateadd(month, -1, getdate()));


--- create a temp table to store end of month for each month
with dates as (
     
 select datefromparts(year(@start_date), month(@start_date), 1) as dte
      union all
      select dateadd(month, 1, dte) --incrementing month by month until the date is less than or equal to @end_date
      from dates
      where dateadd(month, 1, dte) <= @end_date
      )
select 
	eomonth(dte) as end_date
into #months
from dates
option (maxrecursion 0);   

--declare as of date
declare @as_of_date as date;

--declare cursor
declare cursor_AsOfDates cursor for
select * from #months

open cursor_AsOfDates

fetch next from cursor_AsOfDates into @as_of_date
while @@FETCH_STATUS = 0

begin

    with confirmed_reported_cases_and_art as (
        select 
                art.PatientKey,
                patient.Gender,
                art.AgeLastVisit,
                art.FacilityKey,
                PartnerKey,
                AgencyKey,
                eomonth(confirmed_date.Date) as CohortYearMonth,
                case 
					when art_date.Date < confirmed_date.Date then confirmed_date.Date
					else art_date.Date
				end as StartARTDate
            from NDWH.dbo.FACTART as art 
            left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art.PatientKey
            left join NDWH.dbo.DimDate as confirmed_date on confirmed_date.DateKey = patient.DateConfirmedHIVPositiveKey
            left join NDWH.dbo.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
    ),
    confirmed_cases_summary as (
    select
        CohortYearMonth,
        coalesce(agegroup.DATIMAgeGroup, 'Missing') as AgeGroup,
        coalesce(confirmed_reported_cases_and_art.Gender, 'Missing') as Gender,
        coalesce(facility.FacilityName, 'Missing') as FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        sum(case when confirmed_reported_cases_and_art.CohortYearMonth is not null then 1 else 0 end) as ReportedCases
    from confirmed_reported_cases_and_art
    left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = confirmed_reported_cases_and_art.AgeLastVisit
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = confirmed_reported_cases_and_art.FacilityKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = confirmed_reported_cases_and_art.PartnerKey
    left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = confirmed_reported_cases_and_art.AgencyKey
    group by
        CohortYearMonth,	
        coalesce(agegroup.DATIMAgeGroup, 'Missing'), 
        coalesce(confirmed_reported_cases_and_art.Gender, 'Missing'),
        coalesce(facility.FacilityName, 'Missing'),
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName
    ),
    start_art_summary as (
        select
            CohortYearMonth,
            coalesce(agegroup.DATIMAgeGroup, 'Missing') as AgeGroup,
            coalesce(confirmed_reported_cases_and_art.Gender, 'Missing') as Gender,
            coalesce(facility.FacilityName, 'Missing') as FacilityName,
            facility.County,
            facility.SubCounty,
            partner.PartnerName,
            agency.AgencyName,
            sum(case when confirmed_reported_cases_and_art.StartARTDate is not null then 1 else 0 end) as StartARTClients
        from confirmed_reported_cases_and_art
        left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = confirmed_reported_cases_and_art.AgeLastVisit
        left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = confirmed_reported_cases_and_art.FacilityKey
        left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = confirmed_reported_cases_and_art.PartnerKey
        left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = confirmed_reported_cases_and_art.AgencyKey
        where StartARTDate <= @as_of_date
        group by
            CohortYearMonth,
            coalesce(agegroup.DATIMAgeGroup, 'Missing'),
            coalesce(confirmed_reported_cases_and_art.Gender, 'Missing'),
            coalesce(facility.FacilityName, 'Missing'),
            facility.County,
            facility.SubCounty,
            partner.PartnerName,
            agency.AgencyName
    )
	insert into [HIVCaseSurveillance].[dbo].[CsAggregateOnARTSentinelEvent]
    select 
        confirmed_cases_summary.CohortYearMonth,
        @as_of_date as AsOfDate,
        confirmed_cases_summary.AgeGroup,
        confirmed_cases_summary.Gender,
        confirmed_cases_summary.FacilityName,
        confirmed_cases_summary.County,
        confirmed_cases_summary.SubCounty,
        confirmed_cases_summary.PartnerName,
        confirmed_cases_summary.AgencyName,
        sum(ReportedCases) as ReportedCases,
        sum(StartARTClients) as StartARTClients
    from confirmed_cases_summary
    left join start_art_summary  on confirmed_cases_summary.CohortYearMonth = start_art_summary.CohortYearMonth
        and confirmed_cases_summary.Gender = start_art_summary.Gender
        and confirmed_cases_summary.AgeGroup = start_art_summary.AgeGroup
        and confirmed_cases_summary.FacilityName = start_art_summary.FacilityName
    group by 
        confirmed_cases_summary.CohortYearMonth,
        confirmed_cases_summary.AgeGroup,
        confirmed_cases_summary.Gender,
        confirmed_cases_summary.FacilityName,
        confirmed_cases_summary.County,
        confirmed_cases_summary.SubCounty,
        confirmed_cases_summary.PartnerName,
        confirmed_cases_summary.AgencyName
    
    fetch next from cursor_AsOfDates into @as_of_date

end

--free up objects
drop table #months;
close cursor_AsOfDates;
deallocate cursor_AsOfDates;