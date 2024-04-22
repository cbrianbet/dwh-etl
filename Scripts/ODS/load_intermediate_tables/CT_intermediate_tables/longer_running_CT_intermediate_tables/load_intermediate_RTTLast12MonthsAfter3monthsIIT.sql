--truncate table first
truncate table ODS.dbo.Intermediate_RTTLast12MonthsAfter3monthsIIT


--declare start and end dates i.e. within the last 12 months form reporting period
declare @start_date date;
select @start_date = dateadd(month, -12, eomonth(dateadd(month, -1, getdate())));

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
with clinical_visits_as_of_date as (
    /* get visits */
    select 
        PatientPKHash,
        PatientIDHash,
        PatientID,
        PatientPK,
        SiteCode,
        VisitDate,
        NextAppointmentDate,
        CurrentRegimen as RegimenAsof  
    from  ODS.dbo.CT_PatientVisits
    where SiteCode > 0
    and VisitDate <= @as_of_date
),
    pharmacy_visits_as_of_date as (
     /* get pharmacy dispensations*/
    select 
        PatientPKHash,
        PatientIDHash,
        PatientID,
        PatientPK,
        SiteCode,
        DispenseDate,
        ExpectedReturn
    from ODS.dbo.CT_PatientPharmacy
    where SiteCode > 0 
    and DispenseDate <= @as_of_date
    ),
visit_encounter_as_of_date_ordering as (
     /* order visits as of date by the VisitDate */
    select 
        clinical_visits_as_of_date.*,
        row_number() over (partition by PatientPK,  SiteCode order by VisitDate desc) as rank
    from clinical_visits_as_of_date
    ),
pharmacy_dispense_as_of_date_ordering as (
    /* order pharmacy dispensations as of date by the VisitDate */
    select 
        pharmacy_visits_as_of_date.*,
        row_number() over (partition by PatientPK,  SiteCode order by DispenseDate desc) as rank
    from pharmacy_visits_as_of_date
),
last_visit_encounter_as_of_date as (
    /*get the latest visit record for patients*/
    select 
        *
    from visit_encounter_as_of_date_ordering
    where rank = 1

    ),
second_last_visit_encounter_as_of_date  as (
    /*get the second latest visit record for patients*/
    select 
        *
    from visit_encounter_as_of_date_ordering
    where rank = 2

    ),
last_pharmacy_dispense_as_of_date as (
    /*get the latest pharmacy dispensations record for patients*/
    select
        *
    from pharmacy_dispense_as_of_date_ordering
    where rank = 1
    ),
second_last_pharmacy_dispense_as_of_date as (
    /*get the second latest pharmacy dispensations record for patients*/
    select
        *
    from pharmacy_dispense_as_of_date_ordering
    where rank = 2
),
visits_and_dispense_encounters_combined_tbl as (
    /* combine latest visits and latest pharmacy dispensation records*/
    /* we don't include the CT_ARTPatients table logic because this table has only the latest records of the patients (no history) */
    select  distinct coalesce (last_visit.PatientIDHash, last_dispense.PatientIDHash) as PatientIDHash,
            coalesce(last_visit.SiteCode, last_dispense.SiteCode) as SiteCode,
            coalesce(last_visit.PatientPKHash, last_dispense.PatientPKHash) as PatientPKhash,
            coalesce(last_visit.PatientPK, last_dispense.PatientPK) as PatientPK,
            coalesce(last_visit.PatientID, last_dispense.PatientId) as PatientID,
            case
                when last_visit.VisitDate >= last_dispense.DispenseDate then last_visit.VisitDate 
                else isnull(last_dispense.DispenseDate, last_visit.VisitDate)
            end as LastEncounterDate,
            case 
                when last_visit.NextAppointmentDate >= last_dispense.ExpectedReturn then last_visit.NextAppointmentDate 
                else isnull(last_dispense.ExpectedReturn, last_visit.NextAppointmentDate)  
            end as NextAppointmentDate,
            RegimenAsOf
    from last_visit_encounter_as_of_date as last_visit
    full join last_pharmacy_dispense_as_of_date as last_dispense on  last_visit.SiteCode = last_dispense.SiteCode 
        and last_visit.PatientPK = last_dispense.PatientPK
    where 
        case
            when last_visit.VisitDate >= last_dispense.DispenseDate then last_visit.VisitDate 
        else isnull(last_dispense.DispenseDate, last_visit.VisitDate)
        end is not null
),
 secondlast_visits_and_dispense_encounters_combined_tbl as (
    /* combine second last_visits latest visits and latest pharmacy dispensation records*/
    /* we don't include the CT_ARTPatients table logic because this table has only the latest records of the patients (no history) */
    select  distinct coalesce (second_last_visit.PatientIDHash, second_last_dispense.PatientIDHash) as PatientIDHash,
            coalesce(second_last_visit.SiteCode, second_last_dispense.SiteCode) as SiteCode,
            coalesce(second_last_visit.PatientPKhash, second_last_dispense.PatientPKhash) as PatientPKhash ,
            coalesce(second_last_visit.PatientPK, second_last_dispense.PatientPK) as PatientPK ,
            coalesce(second_last_visit.PatientID, second_last_dispense.PatientId) as PatientId ,
            case
                when second_last_visit.VisitDate >= second_last_dispense.DispenseDate then second_last_visit.VisitDate 
                else isnull(second_last_dispense.DispenseDate, second_last_visit.VisitDate)
            end as LastEncounterDate,
            case 
                when second_last_visit.NextAppointmentDate >= second_last_dispense.ExpectedReturn then second_last_visit.NextAppointmentDate 
                else isnull(second_last_dispense.ExpectedReturn, second_last_visit.NextAppointmentDate)  
            end as NextAppointmentDate
    from second_last_visit_encounter_as_of_date as second_last_visit
    full join second_last_pharmacy_dispense_as_of_date as second_last_dispense on  second_last_visit.SiteCode = second_last_dispense.SiteCode 
        and second_last_visit.PatientPK = second_last_dispense.PatientPK
    where 
        case
            when second_last_visit.VisitDate >= second_last_dispense.DispenseDate then second_last_visit.VisitDate 
        else isnull(second_last_dispense.DispenseDate, second_last_visit.VisitDate)
        end is not null
),
second_last_encounter as (
    /* preparing the second latest encounter records as of date */
    select
         secondlast_visits_and_dispense_encounters_combined_tbl .PatientIDHash,
         secondlast_visits_and_dispense_encounters_combined_tbl .SiteCode,
         secondlast_visits_and_dispense_encounters_combined_tbl .PatientPK,
         secondlast_visits_and_dispense_encounters_combined_tbl .PatientID,
         secondlast_visits_and_dispense_encounters_combined_tbl .PatientPKhash,
         secondlast_visits_and_dispense_encounters_combined_tbl .LastEncounterDate as Second_Last_EncounterDate,
        case 
            when datediff(dd,secondlast_visits_and_dispense_encounters_combined_tbl .LastEncounterDate, secondlast_visits_and_dispense_encounters_combined_tbl.NextAppointmentDate) >= 365 then dateadd(day, 30,  secondlast_visits_and_dispense_encounters_combined_tbl .LastEncounterDate)
            else secondlast_visits_and_dispense_encounters_combined_tbl.NextAppointmentDate 
        end As second_last_NextAppointmentDate    
    from secondlast_visits_and_dispense_encounters_combined_tbl
),
last_encounter as (
    /* preparing the latest encounter records as of date */
    select
        visits_and_dispense_encounters_combined_tbl.PatientIDHash,
        visits_and_dispense_encounters_combined_tbl.SiteCode,
        visits_and_dispense_encounters_combined_tbl.PatientPK,
        visits_and_dispense_encounters_combined_tbl.PatientID,
        visits_and_dispense_encounters_combined_tbl.PatientPKhash,
        visits_and_dispense_encounters_combined_tbl.LastEncounterDate,
        case 
            when datediff(dd, visits_and_dispense_encounters_combined_tbl.LastEncounterDate, visits_and_dispense_encounters_combined_tbl.NextAppointmentDate) >= 365 then dateadd(day, 30, LastEncounterDate)
            else visits_and_dispense_encounters_combined_tbl.NextAppointmentDate 
        end As NextAppointmentDate,
        RegimenAsOf   
    from visits_and_dispense_encounters_combined_tbl
),
last_and_second_last_encounters_combined as (
    select 
        last_encounter.*,
        second_last_encounter.second_last_NextAppointmentDate as ExpectedNextAppointmentDate,
		second_last_encounter.Second_Last_EncounterDate as ExpectedLastEncounter
    from last_encounter
        left join second_last_encounter on   second_last_encounter.PatientPK=last_encounter.PatientPK
        and second_last_encounter.SiteCode=last_encounter.SiteCode
)
insert into ODS.dbo.Intermediate_RTTLast12MonthsAfter3monthsIIT
select 
    last_and_second_last_encounters_combined.PatientIDHash as PatientIDHash,
    last_and_second_last_encounters_combined.PatientPKhash,
    last_and_second_last_encounters_combined.PatientID,
    last_and_second_last_encounters_combined.PatientPK,
    last_and_second_last_encounters_combined.SiteCode as MFLCode,
    cast (last_and_second_last_encounters_combined.ExpectedLastEncounter as date) as ExpectedLastEncounter ,
    cast (last_and_second_last_encounters_combined.ExpectedNextAppointmentDate as date) as ExpectedNextAppointmentDate ,
    cast (last_and_second_last_encounters_combined.LastEncounterDate as date) as LastEncounterDate,
    datediff(dd, last_and_second_last_encounters_combined.ExpectedNextAppointmentDate, last_and_second_last_encounters_combined.LastEncounterDate) As DiffExpectedTCADateLastEncounter ,
    @as_of_date as AsofDate
from last_and_second_last_encounters_combined 
where last_and_second_last_encounters_combined.NextAppointmentDate > last_and_second_last_encounters_combined.LastEncounterDate
 and datediff(day, last_and_second_last_encounters_combined.ExpectedNextAppointmentDate, last_and_second_last_encounters_combined.LastEncounterDate) > 90 /* RTT more than 90 days (3 months) */
 and last_and_second_last_encounters_combined.ExpectedNextAppointmentDate <> '1900-01-01' /* ommit nulls */
 and datediff(month, last_and_second_last_encounters_combined.LastEncounterDate, @end_date) <= 12 /* encounter has to be within the last 12 months */



fetch next from cursor_AsOfDates into @as_of_date
end