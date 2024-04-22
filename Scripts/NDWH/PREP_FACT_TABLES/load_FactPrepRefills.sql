IF OBJECT_ID(N'[NDWH].[dbo].[FactPrepRefills]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactPrepRefills];

BEGIN

with MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
        SDP,
    SDP_Agency  as Agency
    from ODS.dbo.All_EMRSites 
),
PrepPatients as (
    select distinct 
        Patient.PrepNumber,
        Patient.PatientPk,
        Patient.PrepEnrollmentDate, 
        Patient.SiteCode
    from ODS.dbo.PrEP_Patient Patient
    where Patient.PrepNumber is not null
),
prep_refills_ordered as (
    select
        ROW_NUMBER () OVER (PARTITION BY PrepNumber, PatientPk, SiteCode ORDER BY DispenseDate Asc) As RowNumber,
        PrepNumber
        ,PatientPk
        ,SiteCode
        ,HtsNumber
        ,RegimenPrescribed
        ,DispenseDate
    from ODS.dbo.PrEP_Pharmacy 
  ),
PrepRefil1stMonth as (
    select  
        Refil.PrepNumber,
        Refil.PatientPK,
        Refil.SiteCode,
        Refil.HtsNumber,
        RegimenPrescribed,
        Refil.DispenseDate,
        Patients.PrepEnrollmentDate,
        DATEDIFF(dd, Patients.PrepEnrollmentDate, Refil.DispenseDate) as RefillFirstMonthDiffInDays
    from prep_refills_ordered as  Refil
    left join ODS.dbo.PrEP_Patient Patients on Refil.PrepNumber=Patients.PrepNumber and Refil.PatientPk=Patients.PatientPk 
        and Refil.SiteCode=Patients.SiteCode
    where Refil.PrepNumber is not null 
        and DATEDIFF(dd, Patients.PrepEnrollmentDate, Refil.DispenseDate) between 23 and 37 --- giving 7 day window period
        and Refil.RowNumber = 1
),
PrepRefil3rdMonth as (
    select 
        Refil.PrepNumber,
        Refil.PatientPk,
        Refil.SiteCode,
        Refil.HtsNumber,
        Refil.RegimenPrescribed,
        Refil.DispenseDate,
        Patients.PrepEnrollmentDate,
        datediff(dd, Patients.PrepEnrollmentDate, Refil.DispenseDate) as RefillThirdMonthDiffInDays
    from ODS.dbo.PrEP_Pharmacy Refil
    left join ODS.dbo.PrEP_Patient Patients on Refil.PrepNumber=Patients.PrepNumber 
        and Refil.PatientPk=Patients.PatientPk and Refil.SiteCode=Patients.SiteCode
    where Refil.PrepNumber is not null 
        and datediff(dd, Patients.PrepEnrollmentDate, Refil.DispenseDate) between 83 and 97 --- giving 7 day window period
),
tests as (
    select 
        distinct
            PatientPK,
            SiteCode,
            TestDate,
            FinalTestResult
    from ODS.dbo.HTS_ClientTests as tests
),
source_data as (
    select 
        distinct refills.PatientPKHash,
        refills.SiteCode,
        refills.PrepNumber,
        refills.DispenseDate,
        refill_month_1.RefillFirstMonthDiffInDays,
        refill_month_1.DispenseDate as DispenseDateMonth1,
        tests_month_1.TestDate as TestDateMonth1,
        tests_month_1.FinalTestResult as TestResultsMonth1,  
        refill_month_3.RefillThirdMonthDiffInDays,
        refill_month_3.DispenseDate as DispenseDateMonth3,
        tests_month_3.TestDate as TestDateMonth3,
        tests_month_3.FinalTestResult as TestResultsMonth3
    from ODS.dbo.PrEP_Pharmacy as refills
    left join PrepRefil1stMonth as refill_month_1 on refill_month_1.PatientPK = refills.PatientPK
        and refill_month_1.SiteCode = refills.Sitecode
    left join PrepRefil3rdMonth as refill_month_3 on refill_month_3.PatientPK = refills.PatientPK
        and refill_month_3.Sitecode = refills.Sitecode
    left join tests as tests_month_1 on tests_month_1.PatientPK = refill_month_1.PatientPK
        and tests_month_1.SiteCode = refill_month_1.SiteCode
        and tests_month_1.TestDate = refill_month_1.DispenseDate
    left join tests as tests_month_3 on tests_month_3.PatientPK = refill_month_3.PatientPK
        and tests_month_3.SiteCode = refill_month_3.SiteCode
        and tests_month_3.TestDate = refill_month_3.DispenseDate
)
select
    FactKey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    agency.AgencyKey,
    partner.PartnerKey,
    age_group.AgeGroupKey,
    patient.Gender,
    dispense_date.DateKey as DispenseDateKey,
    source_data.RefillFirstMonthDiffInDays,
    source_data.TestResultsMonth1,
    refill_month_1.DateKey as DateTestMonth1Key,
    dispense_month_1.DateKey as DateDispenseMonth1,
    source_data.RefillThirdMonthDiffInDays,
    source_data.TestResultsMonth3,
    refill_month_3.DateKey as DateTestMonth3Key,
    dispense_month_3.DateKey as DateDispenseMonth3,
    cast(getdate() as date) as LoadDate
into NDWH.dbo.FactPrepRefills
from source_data
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = source_data.Sitecode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = source_data.PatientPKHash
    and patient.SiteCode = source_data.SiteCode
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, source_data.DispenseDate)
left join NDWH.dbo.DimDate as refill_month_1 on refill_month_1.Date = source_data.TestDateMonth1
left join NDWH.dbo.DimDate as dispense_month_1 on dispense_month_1.Date = source_data.DispenseDateMonth1
left join NDWH.dbo.DimDate as refill_month_3 on refill_month_3.Date = source_data.TestDateMonth3
left join NDWH.dbo.DimDate as dispense_month_3 on dispense_month_3.Date = source_data.DispenseDateMonth3
left join NDWH.dbo.DimDate as dispense_date on dispense_date.Date = source_data.DispenseDate
WHERE patient.voided =0;

alter table NDWH.dbo.FactPrepRefills add primary key(FactKey);

END

