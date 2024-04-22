IF OBJECT_ID(N'[REPORTING].[dbo].[LineListHTSRiskCategorizationAndTestResults]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LineListHTSRiskCategorizationAndTestResults]
GO

BEGIN

with source_data as (
	select 
		row_number() over (partition by tests.FacilityKey, tests.PatientKey, tests.DateTestedKey, tests.TestType order by tests.DateTestedKey desc) as num,
		patient.PatientPKHash,
		patient.PatientKey,
		patient.DOB,
		patient.Gender,
		facility.FacilityName,
		facility.County,
		facility.SubCounty,
		facility.MFLCode,
		partner.PartnerName,
		agency.AgencyName,
		facility.latitude,
		facility.longitude,
		testDate.Date as TestDate,
		elig.VisitDateKey,
		elig.HIVRiskCategory,
		elig.HtsRiskScore,
		tests.FinalTestResult as HTSResult,
		elig.ReasonRefferredForTesting,
		tests.ReferredServices,
        tests.EntryPoint
	from 
		NDWH.dbo.FactHTSClientTests as tests
	left join NDWH.dbo.FactHTSEligibilityExtract elig on elig.PatientKey = tests.PatientKey
		and elig.VisitDateKey = tests.DateTestedKey
	left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = tests.FacilityKey
	left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = tests.AgencyKey
	left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = tests.PartnerKey
	left join NDWH.dbo.DimPatient as patient on patient.PatientKey = tests.PatientKey
	left join NDWH.dbo.DimDate as testDate on testDate.DateKey =tests.DateTestedKey
	where 
		testDate.Date>='2023-04-01' and TestType='Initial Test'
),
prep_assessments_odering as (
	select 
		row_number() OVER (PARTITION BY PatientKey ORDER BY AssessmentVisitDateKey DESC) as num,
        PatientKey,
		AssessmentVisitDateKey
	from NDWH.dbo.FactPrepAssessments
),
latest_prep_assessment as (
	select 
		*
	from prep_assessments_odering
	where num = 1
)
select 
		PatientPKHash,
		DOB,
		Gender,
		FacilityName,
		County,
		SubCounty,
		MFLCode,
		PartnerName,
		AgencyName,
		latitude,
		longitude,
		TestDate,
		VisitDateKey,
		HIVRiskCategory,
		HtsRiskScore,
		HTSResult,
		ReasonRefferredForTesting,
		case
			when latest_prep_assessment.PatientKey is not null then 1
			else 0
		end as ReferredForPreventativeServices,
		ReferredServices,
        EntryPoint
into REPORTING.dbo.LineListHTSRiskCategorizationAndTestResults
from source_data
left join latest_prep_assessment on latest_prep_assessment.PatientKey = source_data.PatientKey
where source_data.num = 1

END