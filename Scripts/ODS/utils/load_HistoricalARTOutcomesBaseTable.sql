use Historical;

-- NB:first you need to create the table that everything will go into: dbo.HistoricalARTOutcomesBaseTable
--truncate the table if you need to load afresh 
truncate table Historical.dbo.HistoricalARTOutcomesBaseTable;


-- declare your start and end dates.
declare 
@start_date date = <>,
@end_date date = <>;

---creating a temporary table with end of day dates for each month between start and end
with dates as (
      select datefromparts(year(@start_date), month(@start_date), 1) as dte
      union all
      select dateadd(month, 1, dte)
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
        SiteCode,
        VisitDate,
        NextAppointmentDate,
        PopulationType,
        KeyPopulationType,
        CurrentRegimen,
        DifferentiatedCare,
        Emr
    from  ODS.dbo.CT_PatientVisits
    where SiteCode > 0 and VisitDate <= @as_of_date
),
pharmacy_visits_as_of_date as (
     /* get pharmacy dispensations as of date */
    select 
        PatientPKHash,
        PatientIDHash,
        SiteCode,
        DispenseDate,
        ExpectedReturn,
        Emr
    from ODS.dbo.CT_PatientPharmacy
    where SiteCode > 0 and DispenseDate <= @as_of_date  
),
patient_art_and_enrollment_info as (
     /* get patients' ART start date */
    select
        distinct ARTPatients.PatientIDHash,
        ARTPatients.PatientPKHash,
        ARTPatients.SiteCode,
        ARTPatients.StartARTDate,
        ARTPatients.StartRegimen,
        ARTPatients.StartRegimenLine,
		ARTPatients.ExpectedReturn,
        Patients.RegistrationAtCCC as EnrollmentDate,
        Patients.DOB,
        Patients.Gender,
        Patients.DateConfirmedHIVPositive,
        datediff(yy, Patients.DOB, Patients.RegistrationAtCCC) as AgeEnrollment
    from ODS.dbo.CT_ARTPatients as ARTPatients
    left join ODS.dbo.CT_Patient as Patients on Patients.PatientPKHash = ARTPatients.PatientPKHash
    	and Patients.SiteCode = ARTPatients.SiteCode
),
visit_encounter_as_of_date_ordering as (
     /* order visits as of date by the VisitDate */
    select 
        clinical_visits_as_of_date.*,
        row_number() over (partition by PatientPKHash, SiteCode order by VisitDate desc) as rank
    from clinical_visits_as_of_date
),
pharmacy_dispense_as_of_date_ordering as (
    /* order pharmacy dispensations as of date by the VisitDate */
    select 
        pharmacy_visits_as_of_date.*,
        row_number() over (partition by PatientPKHash, SiteCode order by DispenseDate desc) as rank
    from pharmacy_visits_as_of_date
),
last_visit_encounter_as_of_date as (
    /*get the latest visit record for patients for as of date */
    select 
        *
    from visit_encounter_as_of_date_ordering
    where rank = 1
),
last_pharmacy_dispense_as_of_date as (
    /*get the latest pharmacy dispensations record for patients for as of date */
    select
        *
    from pharmacy_dispense_as_of_date_ordering
    where rank = 1
),
exits_as_of_date as (
    /* get exits as of date */
    select 
        PatientIDHash,
        PatientPKHash,
        SiteCode,
        ExitDate,
        ExitReason,
		ReEnrollmentDate,
		EffectiveDiscontinuationDate
    from ODS.dbo.CT_PatientStatus
    where ExitDate <= @as_of_date 
),
exits_as_of_date_ordering as (
    /* order the exits by the ExitDate*/
    select 
        PatientIDHash,
        PatientPKHash,
        SiteCode,
        ExitDate,
        ExitReason,
		ReEnrollmentDate,
		EffectiveDiscontinuationDate,
        row_number() over (partition by PatientPKHash, SiteCode order by ExitDate desc) as rank
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
    /* combine latest visits and latest pharmacy dispensation records as of date */
    /* we don't include the CT_ARTPatients table logic because this table has only the latest records of the patients (no history) */
    select  distinct coalesce (last_visit.PatientIDHash, last_dispense.PatientIDHash) as PatientIDHash,
            coalesce(last_visit.SiteCode, last_dispense.SiteCode) as SiteCode,
            coalesce(last_visit.PatientPKHash, last_dispense.PatientPKHash) as PatientPKHash ,
            coalesce(last_visit.Emr, last_dispense.Emr) as Emr,
            DifferentiatedCare,
            case
                when last_visit.VisitDate >= last_dispense.DispenseDate then last_visit.VisitDate 
                else isnull(last_dispense.DispenseDate, last_visit.VisitDate)
            end as LastEncounterDate,
            case 
                when last_visit.NextAppointmentDate >= last_dispense.ExpectedReturn then last_visit.NextAppointmentDate 
                else isnull(last_dispense.ExpectedReturn, last_visit.NextAppointmentDate)  
            end as NextAppointmentDate
    from last_visit_encounter_as_of_date as last_visit
    full join last_pharmacy_dispense_as_of_date as last_dispense on last_visit.SiteCode = last_dispense.SiteCode 
        and last_visit.PatientPKHash = last_dispense.PatientPKHash
    where 
        case
            when last_visit.VisitDate >= last_dispense.DispenseDate then last_visit.VisitDate 
        else isnull(last_dispense.DispenseDate, last_visit.VisitDate)
        end is not null
),
last_encounter_cleaned as (
    /* cleaning TCA dates far away */
    select
        visits_and_dispense_encounters_combined_tbl.PatientIDHash,
        visits_and_dispense_encounters_combined_tbl.SiteCode,
        visits_and_dispense_encounters_combined_tbl.PatientPKHash,
        visits_and_dispense_encounters_combined_tbl.Emr,
        visits_and_dispense_encounters_combined_tbl.LastEncounterDate,
        DifferentiatedCare,
        case 
			when datediff(dd, @as_of_date, visits_and_dispense_encounters_combined_tbl.NextAppointmentDate) >= 365 then dateadd(day, 30, LastEncounterDate)
            else visits_and_dispense_encounters_combined_tbl.NextAppointmentDate 
        end As NextAppointmentDate    
    from visits_and_dispense_encounters_combined_tbl
	where LastEncounterDate is not null
),
last_encounter as (
    /* preparing the latest encounter records as of date */
    select
		last_encounter_cleaned.PatientIDHash,
		last_encounter_cleaned.SiteCode,
		last_encounter_cleaned.PatientPKHash,
		last_encounter_cleaned.Emr,
		last_encounter_cleaned.LastEncounterDate,
        last_encounter_cleaned.DifferentiatedCare,
		case 
			when visits_and_dispense_encounters_combined_tbl.NextAppointmentDate > last_encounter_cleaned.NextAppointmentDate then visits_and_dispense_encounters_combined_tbl.NextAppointmentDate
			else last_encounter_cleaned.NextAppointmentDate
		end as NextAppointmentDate
    from last_encounter_cleaned
	left join visits_and_dispense_encounters_combined_tbl on visits_and_dispense_encounters_combined_tbl.PatientPKHash = last_encounter_cleaned.PatientPKHash
		and visits_and_dispense_encounters_combined_tbl.SiteCode = last_encounter_cleaned.SiteCode 
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
 		CASE
            WHEN  last_exit_as_of_date.ExitReason  in ('DIED','dead','Death','Died') THEN 'D'--1
            WHEN DATEDIFF( dd, last_encounter.NextAppointmentDate, EOMONTH(@as_of_date)) > 30 and last_exit_as_of_date.ExitReason is null THEN 'uL'--Date diff btw TCA  and Last day of Previous month--2
            WHEN  last_exit_as_of_date.ExitDate IS NOT NULL and last_exit_as_of_date.ExitReason not in ('DIED','dead','Death','Died') and  last_exit_as_of_date.ReEnrollmentDate between DATEADD(MONTH, DATEDIFF(MONTH, 0, @as_of_date)-1, 0) and DATEADD(MONTH, DATEDIFF(MONTH, -1, @as_of_date)-1, -1) THEN 'V'--3
            WHEN  last_exit_as_of_date.ExitDate IS NOT NULL and last_exit_as_of_date.ExitReason not in ('DIED','dead','Death','Died') and  last_exit_as_of_date.EffectiveDiscontinuationDate >=  EOMONTH(@as_of_date) THEN 'V'--4
 	        WHEN  patient_art_and_enrollment_info.startARTDate > EOMONTH(@as_of_date) THEN 'NP'--5
            WHEN  last_exit_as_of_date.EffectiveDiscontinuationDate is not null and last_exit_as_of_date.ReEnrollmentDate is Null Then SUBSTRING(last_exit_as_of_date.ExitReason,1,1) --6
            WHEN  last_exit_as_of_date.ExitDate IS NOT NULL and last_exit_as_of_date.ExitReason not in ('DIED','dead','Death','Died') and last_exit_as_of_date.EffectiveDiscontinuationDate between DATEADD(MONTH, DATEDIFF(MONTH, 0, @as_of_date)-1, 0) and DATEADD(MONTH, DATEDIFF(MONTH, -1, @as_of_date)-1, -1) THEN SUBSTRING(last_exit_as_of_date.ExitReason,1,1)--When a TO and LFTU has an discontinuationdate during the reporting Month --7
            WHEN  last_exit_as_of_date.ExitDate IS NOT NULL and last_exit_as_of_date.ExitReason not in ('DIED','dead','Death','Died') and  last_encounter.NextAppointmentDate > EOMONTH(@as_of_date)  THEN 'V'--8
            WHEN  DATEDIFF(dd, last_encounter.NextAppointmentDate, EOMONTH(@as_of_date)) <=30 THEN 'V'-- Date diff btw TCA  and LAst day of Previous month-- must not be late by 30 days -- 9
			WHEN  last_encounter.NextAppointmentDate > EOMONTH(@as_of_date)   Then 'V' --10
            WHEN last_encounter.NextAppointmentDate IS NULL THEN 'NV' --11
			ELSE SUBSTRING(last_exit_as_of_date.ExitReason,1,1)
		END
	AS ARTOutcome,
	@as_of_date as AsOfDate
    from last_encounter
    left join last_exit_as_of_date on last_exit_as_of_date.SiteCode = last_encounter.SiteCode
        and last_exit_as_of_date.PatientPKHash = last_encounter.PatientPKHash
    left join patient_art_and_enrollment_info on patient_art_and_enrollment_info.SiteCode = last_encounter.SiteCode
        and patient_art_and_enrollment_info.PatientPKHash = last_encounter.PatientPKHash
    where patient_art_and_enrollment_info.startARTDate is not null
)
insert into Historical.dbo.HistoricalARTOutcomesBaseTable
select 
    ARTOutcomesCompuation.PatientIDHash as PatientIDHash,
    ARTOutcomesCompuation.PatientPKHash as PatientPKHash,
    ARTOutcomesCompuation.SiteCode as MFLCode,
    ARTOutcomesCompuation.ARTOutcome,
    ARTOutcomesCompuation.DifferentiatedCare,
	ARTOutcomesCompuation.LastEncounterDate,
	ARTOutcomesCompuation.NextAppointmentDate,
	ARTOutcomesCompuation.AsOfDate
from ARTOutcomesCompuation

fetch next from cursor_AsOfDates into @as_of_date
end


--free up objects
drop table #months
close cursor_AsOfDates
deallocate cursor_AsOfDates