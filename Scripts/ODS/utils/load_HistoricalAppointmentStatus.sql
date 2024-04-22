use Historical;

-- NB:first you need to create the table that everything will go into: dbo.HistoricalARTOutcomesBaseTable
--truncate the table if you need to load afresh 
truncate table Historical.dbo.HistoricalAppointmentStatus;


---declare your start and end dates.
declare 
@start_date date = <>,
@end_date date = <>;

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
    /* get visits as of date */
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
    where SiteCode > 0 and NextAppointmentDate >= DATEADD(month, -6, @as_of_date) 

),
    pharmacy_visits_as_of_date as (
     /* get pharmacy dispensations as of date */
    select 
        PatientPKHash,
        PatientIDHash,
        PatientID,
        PatientPK,
        SiteCode,
        DispenseDate,
        ExpectedReturn
    from ODS.dbo.CT_PatientPharmacy
    where SiteCode > 0 and ExpectedReturn >= DATEADD(month, -6, @as_of_date) 
    ),

    patient_art_and_enrollment_info as (
     /* get patients' ART start date */
    select
        distinct CT_ARTPatients.PatientIDHash,
        CT_ARTPatients.PatientPKHash,
        CT_ARTPatients.PatientPK,
        CT_ARTPatients.PatientId,
        CT_ARTPatients.SiteCode,
        CT_ARTPatients.StartARTDate,
		CT_ARTPatients.ExpectedReturn,
        CT_ARTPatients.StartRegimen,
        CT_ARTPatients.StartRegimenLine,
        CT_Patient.RegistrationAtCCC as EnrollmentDate,
        CT_Patient.DOB,
        CT_Patient.Gender,
        CT_Patient.DateConfirmedHIVPositive,
        datediff(yy, CT_Patient.DOB, CT_Patient.RegistrationAtCCC) as AgeEnrollment
    from ODS.dbo.CT_ARTPatients
    left join ODS.dbo.CT_Patient  on  CT_Patient.PatientPK = CT_ARTPatients.PatientPK
    and CT_Patient.SiteCode = CT_ARTPatients.SiteCode
	where  ODS.dbo.CT_ARTPatients.SiteCode > 0 and ODS.dbo.CT_ARTPatients.ExpectedReturn <=@as_of_date
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
    /*get the latest visit record for patients for as of date */
    select 
        *
    from visit_encounter_as_of_date_ordering
    where rank = 1

    ),

    second_last_visit_encounter_as_of_date  as (
    /*get the second latest visit record for patients for as of date */
    select 
        *
    from visit_encounter_as_of_date_ordering
    where rank = 2

    ),
last_pharmacy_dispense_as_of_date as (
    /*get the latest pharmacy dispensations record for patients for as of date */
    select
        *
    from pharmacy_dispense_as_of_date_ordering
    where rank = 1
    ),
second_last_pharmacy_dispense_as_of_date as (
    /*get the second latest pharmacy dispensations record for patients for as of date */
    select
        *
    from pharmacy_dispense_as_of_date_ordering
    where rank = 2
    ),

effective_discontinuation_ordering as (
    /*order the effective discontinuation by the EffectiveDiscontinuationDate*/
    select 
        PatientIDHash,
        PatientPKHash,
        PatientID,
        PatientPK,
        SiteCode,
        EffectiveDiscontinuationDate,
        ExitDate,
        ExitReason,
        row_number() over (partition by PatientPK,  SiteCode order by EffectiveDiscontinuationDate desc) as rank
    from ODS.dbo.CT_PatientStatus
    where ExitDate is not null and EffectiveDiscontinuationDate is not null

    ),
latest_effective_discontinuation as (
    /*get the latest discontinuation record*/
    select 
        *
    from effective_discontinuation_ordering
    where rank = 1

    ),
exits_as_of_date as (
    /* get exits as of date */
    select 
        PatientIDHash,
        PatientPKHash,
         PatientID,
        PatientPK,
        SiteCode,
        ExitDate,
        ExitReason,
		ReEnrollmentDate
    from ODS.dbo.CT_PatientStatus
    where  ExitDate <= @as_of_date
    --ExitDate>= DATEADD(month, -6, @as_of_date) 

),
    exits_as_of_date_ordering as (
    /* order the exits by the ExitDate*/
    select 
        PatientIDHash,
        PatientPKHash,
         PatientID,
        PatientPK,
        SiteCode,
        ExitDate,
        ExitReason,
		ReEnrollmentDate,
        row_number() over (partition by PatientPK, SiteCode order by ExitDate desc) as rank
    from exits_as_of_date

    ),
last_exit_as_of_date as (
    /* get latest exit_date as of date */
    select 
        *
    from exits_as_of_date_ordering
    where rank = 1
    ),
    visits_and_dispense_encounters_combined_tbl as (
    /* combine latest visits and latest pharmacy dispensation records as of date - 'borrowed logic from the view vw_PatientLastEnconter*/
    /* we don't include the stg_ARTPatients table logic because this table has only the latest records of the patients (no history) */
    select  distinct coalesce (last_visit.PatientIDHash, last_dispense.PatientIDHash) as PatientIDHash,
            coalesce(last_visit.SiteCode, last_dispense.SiteCode) as SiteCode,
            coalesce(last_visit.PatientPKHash, last_dispense.PatientPKHash) as PatientPKhash ,
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

 Uploads as (
Select  [DateRecieved],ROW_NUMBER()OVER(Partition by Sitecode Order by [DateRecieved] Desc) as Num ,
	SiteCode,
    cast( [DateRecieved]as date) As DateReceived
from ODS.dbo.CT_FacilityManifest 
    ),

 Uploads_as_of_date as (
    /* get Uploads as of date */
    select 
        SiteCode,
        DateRecieved
    from ODS.dbo.CT_FacilityManifest 
    where DateRecieved <=@as_of_date
    ),
  Uploads_as_of_date_ordering as (
    /* order the Uploads by the DateReceived*/
    select 
        SiteCode,
        DateRecieved,
        row_number() over (partition by  SiteCode order by DateRecieved desc) as rank
    from Uploads_as_of_date
    ),

    last_upload_as_of_date as (
    /* get latest upload_date as of date */
    select 
        SiteCode,
        DateRecieved
    from Uploads_as_of_date_ordering
    where rank = 1
    ),
 secondlast_visits_and_dispense_encounters_combined_tbl as (
    /* combine latest visits and latest pharmacy dispensation records as of date - 'borrowed logic from the view vw_PatientLastEnconter*/
    /* we don't include the stg_ARTPatients table logic because this table has only the latest records of the patients (no history) */
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
            when datediff(dd, @as_of_date, secondlast_visits_and_dispense_encounters_combined_tbl.NextAppointmentDate) >= 365 then dateadd(day, 30,  secondlast_visits_and_dispense_encounters_combined_tbl .LastEncounterDate)
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
            when datediff(dd, @as_of_date, visits_and_dispense_encounters_combined_tbl.NextAppointmentDate) >= 365 then dateadd(day, 30, LastEncounterDate)
            else visits_and_dispense_encounters_combined_tbl.NextAppointmentDate 
        end As NextAppointmentDate,
        RegimenAsOf   
    from visits_and_dispense_encounters_combined_tbl
     ),

ARTOutcomesCompuation as (
    /* computing the ART_Outcome as of date - 'borrowed logic from the view vw_ARTOutcomeX'*/
    select 
        last_encounter.*,
        patient_art_and_enrollment_info.startARTDate,
        last_exit_as_of_date.ExitDate,
        patient_art_and_enrollment_info.EnrollmentDate,
        patient_art_and_enrollment_info.AgeEnrollment,
        patient_art_and_enrollment_info.StartRegimen,
        patient_art_and_enrollment_info.StartRegimenLine,
        patient_art_and_enrollment_info.DateConfirmedHIVPositive,
        patient_art_and_enrollment_info.Gender,
        datediff(year, patient_art_and_enrollment_info.DOB, last_encounter.LastEncounterDate) as AgeLastVisit,
        second_last_encounter.second_last_NextAppointmentDate as ExpectedNextAppointmentDate,
		second_last_encounter.Second_Last_EncounterDate as ExpectedLastEncounter,
        datediff(mm, patient_art_and_enrollment_info.StartARTDate, eomonth(@as_of_date)) ARTDurationMonths,
        @as_of_date as AsOfDate
    from last_encounter
    left join latest_effective_discontinuation on latest_effective_discontinuation.PatientPK = last_encounter.PatientPK
        and latest_effective_discontinuation.SiteCode = last_encounter.SiteCode
    left join last_exit_as_of_date on  last_exit_as_of_date.PatientPK = last_encounter.PatientPK
        and last_exit_as_of_date.SiteCode = last_encounter.SiteCode
    left join patient_art_and_enrollment_info on  patient_art_and_enrollment_info.PatientPK = last_encounter.PatientPK
        and patient_art_and_enrollment_info.SiteCode = last_encounter.SiteCode
        left join second_last_encounter on   second_last_encounter.PatientPK=last_encounter.PatientPK
        and second_last_encounter.SiteCode=last_encounter.SiteCode
    left join last_upload_as_of_date on  last_upload_as_of_date.SiteCode=last_encounter.SiteCode
),
Summary AS (
select 
    ARTOutcomesCompuation.PatientIDHash as PatientIDHash,
    ARTOutcomesCompuation.PatientPKhash,
    ARTOutcomesCompuation.PatientID,
    ARTOutcomesCompuation.PatientPK,
    ARTOutcomesCompuation.SiteCode as MFLCode,
    cast (ARTOutcomesCompuation.ExpectedLastEncounter as date) as ExpectedLastEncounter ,
    cast (ARTOutcomesCompuation.ExpectedNextAppointmentDate as date) as ExpectedNextAppointmentDate ,
    cast (ARTOutcomesCompuation.LastEncounterDate as date) as LastEncounterDate,
    DATEDIFF(dd, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) As DiffExpectedTCADateLastEncounter,
    case 
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) < 0 Then 'Came before'
    When   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate)= 0 Then 'On time'
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) between 1 and 7 Then 'Missed 1-7 days'
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) between 8 and 14 Then 'Missed 8-14 days'
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) between 15 and 30 Then 'Missed 15-30 days'
    when   last_upload_as_of_date.DateRecieved < ARTOutcomesCompuation.ExpectedNextAppointmentDate   Then 'LostinHMIS'
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) between 31 and 60 Then 'IIT and RTT within 30 days'
    when   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate)  > 60 Then 'IIT and RTT beyond 30 days'
    When   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) >= 91 and ARTOutcomesCompuation.ExpectedNextAppointmentDate <>'1900-01-01'  Then 'Still IIT'
   -- When   DATEDIFF(day, ARTOutcomesCompuation.ExpectedNextAppointmentDate, ARTOutcomesCompuation.LastEncounterDate) >= 91 and ARTOutcomesCompuation.ExpectedNextAppointmentDate <>'1900-01-01'  Then 'IIT and RTT beyond 30 days'
    else 	
     Case when last_exit_as_of_date.exitReason	in ('dead','Death','Died') Then 'Dead'
        when last_exit_as_of_date.exitReason in ('Lost','Lost to followup','LTFU','ltfu') Then 'Still IIT'
        When last_exit_as_of_date.exitReason in ('Stopped','Stopped Treatment') Then 'Stopped'
        When last_exit_as_of_date.exitReason in ('Transfer','Transfer Out','transfer_out','Transferred out') Then 'Transfer-Out'
        When last_exit_as_of_date.exitReason not in ('dead','Death','Died','Lost','Lost to followup','LTFU','ltfu','Stopped','Stopped Treatment','Transfer','Transfer Out','transfer_out','Transferred out') Then 'Other'
    else last_exit_as_of_date.exitReason 
     END
    	end as AppointmentStatus,
	ARTOutcomesCompuation.AsOfDate,
    ARTOutcomesCompuation.StartARTDate,
    ARTOutcomesCompuation.ARTDurationMonths,
    last_upload_as_of_date.DateRecieved,
    RegimenAsof
from ARTOutcomesCompuation  
left join last_exit_as_of_date on  last_exit_as_of_date.PatientPK= ARTOutcomesCompuation.PatientPK
    and last_exit_as_of_date.sitecode=ARTOutcomesCompuation.sitecode
 left  join  last_upload_as_of_date on  last_upload_as_of_date.SiteCode=ARTOutcomesCompuation.SiteCode 
where ARTOutcomesCompuation.NextAppointmentDate > ARTOutcomesCompuation.LastEncounterDate
   -- AND ARTOutcomesCompuation.NextAppointmentDate > DATEADD(month, -6, ARTOutcomesCompuation.AsOfDate)
),
unscheduled_visits_as_of_date as (
    select 
        PatientPK,
        SiteCode,
        @as_of_date as AsOfDate,
        count(*) as NoOfUnscheduledVisits
    from ODS.dbo.CT_PatientVisits
    where VisitType like '%unscheduled%'
    and VisitDate <= @as_of_date
    group by 
        PatientPK,
        SiteCode
)
insert into Historical.dbo.HistoricalAppointmentStatus
Select 
    summary.* ,
	unscheduled_visits_as_of_date.NoOfUnscheduledVisits

from Summary
left join unscheduled_visits_as_of_date on unscheduled_visits_as_of_date.PatientPK = summary.PatientPK 
    and unscheduled_visits_as_of_date.SiteCode = summary.MFLCode
    and unscheduled_visits_as_of_date.AsOfDate = summary.AsOfDate
where AppointmentStatus in ('Came before','Dead','IIT and RTT beyond 30 days','IIT and RTT within 30 days','LostinHMIS','LTFU','Missed 1-7 days','Missed 15-30 days','Missed 8-14 days','On time','Still IIT','Stopped','Transfer-Out') 

fetch next from cursor_AsOfDates into @as_of_date

end

--free up objects
drop table #months
close cursor_AsOfDates 
deallocate cursor_AsOfDates 
