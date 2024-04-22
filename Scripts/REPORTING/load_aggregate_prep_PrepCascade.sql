IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.dbo.AggregatePrepCascade') AND type in (N'U')) 
    DROP TABLE REPORTING.dbo.AggregatePrepCascade
GO

with eligible_screened_data AS  (
	SELECT DISTINCT 
        MFLCode,		
        f.FacilityName,
        County,
        SubCounty,
        p.PartnerName,
        a.AgencyName,
        pat.Gender,
        age.DATIMAgeGroup as AgeGroup,
        ass.month AssMonth,
        ass.year AssYear,
        EOMONTH(ass.Date) as AsofDate,
        Sum(EligiblePrep) As EligiblePrep,
        sum(ScreenedPrep) As Screened
	FROM NDWH.dbo.FactPrepAssessments prep
	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate ass ON ass.DateKey = AssessmentVisitDateKey 
	GROUP BY 
            MFLCode,
			f.FacilityName,
			County,
			SubCounty,
			p.PartnerName,
			a.AgencyName,
			pat.Gender,
			age.DATIMAgeGroup,
			ass.Month,
			ass.Year,
            EOMONTH(ass.Date)
),
prepStart AS (
	SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		pat.Gender,
		age.DATIMAgeGroup as AgeGroup,
		enrol.month EnrollmentMonth, 
		enrol.year EnrollmentYear,
        EOMONTH(enrol.Date) as AsofDate,
		Count (distinct (concat(PrepNumber,PatientPKHash,MFLCode))) As StartedPrep
	FROM NDWH.dbo.FactPrepAssessments prep
	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate enrol ON enrol.DateKey = prep.PrepEnrollmentDateKey	
	WHERE prep.PrepEnrollmentDateKey IS NOT NULL
	GROUP BY MFLCode,
			f.FacilityName,
			County,
			SubCounty,
			p.PartnerName,
			a.AgencyName,
			pat.Gender,
			age.DATIMAgeGroup,
			enrol.Month,
			enrol.Year,
            EOMONTH(enrol.Date)
),
prep_ct as (
    select 
        facility.MFLCode,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        patient.Gender,
        age_group.DATIMAgeGroup as AgeGroup,
        date_visit.Month,
        date_visit.Year, 
        EOMONTH(date_visit.Date) as AsofDate,
        count(distinct(concat(patient.PrepNumber,visits.PatientKey))) As PrepCT
	from NDWH.dbo.FactPrepVisits as visits
    left join NDWH.dbo.DimPatient as patient on patient.PatientKey = visits.PatientKey
    left join NDWH.dbo.DimDate as date_visit on date_visit.DateKey = visits.VisitDateKey
    left join NDWH.dbo.DimAgency as agency on agency.Agencykey = visits.AgencyKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = visits.Partnerkey
    left join NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = visits.AgeGroupKey 
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = visits.FacilityKey
    left join NDWH.dbo.DimDate as prep_enroll on prep_enroll.Datekey = patient.PrepEnrollmentDatekey
	where VisitDateKey is not null 
        and date_visit.Date <> prep_enroll.Date 
	group by 
        facility.MFLCode,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        date_visit.Month ,
        date_visit.Year,
        patient.Gender,
        age_group.DATIMAgeGroup,
        EOMONTH(date_visit.Date)
),
eligible_screened_data_prep_start as (	
SELECT
	coalesce(eligible_screened_data.MFLCode, prepStart.MFLCode) AS MFLCode,		
	coalesce(eligible_screened_data.FacilityName, prepStart.FacilityName) AS FacilityName,
	coalesce(eligible_screened_data.County, prepStart.County) AS County,
	coalesce(eligible_screened_data.SubCounty, prepStart.SubCounty) AS SubCounty,
	coalesce(eligible_screened_data.PartnerName, prepStart.PartnerName) AS PartnerName,
	coalesce(eligible_screened_data.AgencyName, prepStart.AgencyName) AS AgencyName,
	coalesce(eligible_screened_data.Gender, prepStart.Gender) AS Gender,
	coalesce(eligible_screened_data.AgeGroup, prepStart.AgeGroup) AS AgeGroup,
	coalesce(eligible_screened_data.AssMonth, prepStart.EnrollmentMonth) AS AssMonth,
	coalesce(eligible_screened_data.AssYear, prepStart.EnrollmentYear) AS AssYear,
    coalesce(eligible_screened_data.AsofDate, prepStart.AsofDate) AS AsofDate,
	coalesce(eligible_screened_data.EligiblePrep, 0) AS EligiblePrep,
	coalesce(eligible_screened_data.Screened, 0) AS Screened,
	coalesce(prepStart.StartedPrep, 0) AS StartedPrep
FROM eligible_screened_data 
FULL OUTER JOIN prepStart on eligible_screened_data.MFLCode = prepStart.MFLCode 
    and prepStart.FacilityName = eligible_screened_data.FacilityName 
    and prepStart.County = eligible_screened_data.County 
    and prepStart.SubCounty = eligible_screened_data.SubCounty 
    and prepStart.PartnerName = eligible_screened_data.PartnerName 
    and prepStart.AgencyName = eligible_screened_data.AgencyName 
    and prepStart.Gender = eligible_screened_data.Gender 
    and prepStart.AgeGroup = eligible_screened_data.AgeGroup 
    and eligible_screened_data.AssMonth = prepStart.EnrollmentMonth 
    and eligible_screened_data.AssYear = prepStart.EnrollmentYear
),
eligible_screened_data_prep_start_prep_ct as (
    select 
        coalesce(eligible_screened_data_prep_start.MFLCode, prep_ct.MFLCode)  as MFLCode,
        coalesce(eligible_screened_data_prep_start.FacilityName, prep_ct.FacilityName) as FacilityName,
        coalesce(eligible_screened_data_prep_start.County, prep_ct.County) as County,
        coalesce(eligible_screened_data_prep_start.SubCounty, prep_ct.SubCounty) as SubCounty,
        coalesce(eligible_screened_data_prep_start.PartnerName, prep_ct.PartnerName) as PartnerName,
        coalesce(eligible_screened_data_prep_start.AgencyName, prep_ct.AgencyName) as AgencyName,
        coalesce(eligible_screened_data_prep_start.Gender, prep_ct.Gender) as Gender,
        coalesce(eligible_screened_data_prep_start.AgeGroup, prep_ct.AgeGroup) as AgeGroup,
        coalesce(eligible_screened_data_prep_start.AssMonth, prep_ct.Month) as Month,
        coalesce(eligible_screened_data_prep_start.AssYear, prep_ct.Year) as Year,
        coalesce(eligible_screened_data_prep_start.AsofDate, prep_ct.AsofDate) as AsofDate,
        coalesce(eligible_screened_data_prep_start.EligiblePrep, 0) as EligiblePrep,
        coalesce(eligible_screened_data_prep_start.Screened, 0) as Screened,
        coalesce(eligible_screened_data_prep_start.StartedPrep, 0) as StartedPrep,
        coalesce(prep_ct.PrepCT, 0) as PrepCT
    from eligible_screened_data_prep_start
    full join prep_ct on prep_ct.MFLCode  = eligible_screened_data_prep_start.MFLCode 
        and prep_ct.FacilityName = eligible_screened_data_prep_start.FacilityName 
        and prep_ct.County = eligible_screened_data_prep_start.County 
        and prep_ct.SubCounty = eligible_screened_data_prep_start.SubCounty 
        and prep_ct.PartnerName = eligible_screened_data_prep_start.PartnerName 
        and prep_ct.AgencyName = eligible_screened_data_prep_start.AgencyName 
        and prep_ct.Gender = eligible_screened_data_prep_start.Gender 
        and prep_ct.AgeGroup = eligible_screened_data_prep_start.AgeGroup 
        and prep_ct.Month = eligible_screened_data_prep_start.AssMonth
        and prep_ct.Year = eligible_screened_data_prep_start.AssYear 
),
prep_turned_positive as (
    select 
        facility.MFLCode,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        patient.Gender,
        age_group.DATIMAgeGroup as AgeGroup,
        date_test.[Month] as TestMonth,
        date_test.[Year] as TestYear,
        EOMONTH(date_test.Date) as AsofDate,
        count(distinct tests.PatientKey) as CountPositive
    from NDWH.dbo.FactHTSClientTests as tests
    inner join NDWH.dbo.FactPrepAssessments as assessments on assessments.PatientKey = tests.PatientKey
    left join NDWH.dbo.DimPatient as patient on patient.PatientKey = tests.PatientKey
    left join NDWH.dbo.DimDate as date_test on date_test.DateKey = tests.DateTestedKey
    left join NDWH.dbo.DimAgency as agency on agency.Agencykey = tests.AgencyKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = tests.Partnerkey
    left join NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = tests.AgeGroupKey 
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = tests.FacilityKey
    where FinalTestResult = 'Positive'
        and patient.PrepEnrollmentDateKey is not null
    group by 
        facility.MFLCode,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        partner.PartnerName,
        agency.AgencyName,
        patient.Gender,
        age_group.DATIMAgeGroup,
        date_test.[Month],
        date_test.[Year],
        EOMONTH(date_test.Date)
),
eligible_screened_data_prep_start_prep_ct_turned_positive as (
    select
        coalesce(eligible_screened_data_prep_start_prep_ct.MFLCode, prep_turned_positive.MFLCode)  as MFLCode,
        coalesce(eligible_screened_data_prep_start_prep_ct.FacilityName, prep_turned_positive.FacilityName) as FacilityName,
        coalesce(eligible_screened_data_prep_start_prep_ct.County, prep_turned_positive.County) as County,
        coalesce(eligible_screened_data_prep_start_prep_ct.SubCounty, prep_turned_positive.SubCounty) as SubCounty,
        coalesce(eligible_screened_data_prep_start_prep_ct.PartnerName, prep_turned_positive.PartnerName) as PartnerName,
        coalesce(eligible_screened_data_prep_start_prep_ct.AgencyName, prep_turned_positive.AgencyName) as AgencyName,
        coalesce(eligible_screened_data_prep_start_prep_ct.Gender, prep_turned_positive.Gender) as Gender,
        coalesce(eligible_screened_data_prep_start_prep_ct.AgeGroup, prep_turned_positive.AgeGroup) as AgeGroup,
        coalesce(eligible_screened_data_prep_start_prep_ct.Month, prep_turned_positive.TestMonth) as Month,
        coalesce(eligible_screened_data_prep_start_prep_ct.Year, prep_turned_positive.TestYear) as Year,
        coalesce(eligible_screened_data_prep_start_prep_ct.AsofDate, prep_turned_positive.AsofDate) as AsofDate,
        coalesce(eligible_screened_data_prep_start_prep_ct.EligiblePrep, 0) as EligiblePrep,
        coalesce(eligible_screened_data_prep_start_prep_ct.Screened, 0) as Screened,
        coalesce(eligible_screened_data_prep_start_prep_ct.StartedPrep, 0) as StartedPrep,
        coalesce(eligible_screened_data_prep_start_prep_ct.PrepCT, 0) as PrepCT,
        coalesce(prep_turned_positive.CountPositive, 0) as TurnedPositive,
        cast(getdate() as date) as LoadDate 
    from eligible_screened_data_prep_start_prep_ct
    full join prep_turned_positive on prep_turned_positive.MFLCode  = eligible_screened_data_prep_start_prep_ct.MFLCode 
        and prep_turned_positive.FacilityName = eligible_screened_data_prep_start_prep_ct.FacilityName 
        and prep_turned_positive.County = eligible_screened_data_prep_start_prep_ct.County 
        and prep_turned_positive.SubCounty = eligible_screened_data_prep_start_prep_ct.SubCounty 
        and prep_turned_positive.PartnerName = eligible_screened_data_prep_start_prep_ct.PartnerName 
        and prep_turned_positive.AgencyName = eligible_screened_data_prep_start_prep_ct.AgencyName 
        and prep_turned_positive.Gender = eligible_screened_data_prep_start_prep_ct.Gender 
        and prep_turned_positive.AgeGroup = eligible_screened_data_prep_start_prep_ct.AgeGroup 
        and prep_turned_positive.TestMonth = eligible_screened_data_prep_start_prep_ct.Month
        and prep_turned_positive.TestYear = eligible_screened_data_prep_start_prep_ct.Year
)
select 
    *
into REPORTING.dbo.AggregatePrepCascade
from eligible_screened_data_prep_start_prep_ct_turned_positive;
