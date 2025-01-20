IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSPNSChildren]', N'U') IS NOT NULL 	
drop TABLE REPORTING.[dbo].[AggregateHTSPNSChildren]
GO

with pns_and_tests as ( 
	select distinct 
		pns.PatientKey,
		facility.MFLCode,
        facility.FacilityKey,
        pns.AgencyKey,
        pns.PartnerKey,
        pns.AgeGroupKey,
		pns.ScreenedForIpv,
		pns.CccNumber,
        pns.RelationsipToIndexClient,
        pns.KnowledgeOfHivStatus,
		tests.FinalTestResult,
		pns.DateElicitedKey,
        pns.DateLinkedToCareKey,
		tests.DateTestedKey
	from NDWH.Fact.FactHTSPartnerNotificationServices as pns
    left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = pns.FacilityKey
	left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = pns.PartnerPatientPk
        and patient.SiteCode = facility.MFLCode
    left join NDWH.Fact.FactHTSClientTests as tests on tests.PatientKey = patient.PatientKey
    where 
		TestType in ('Initial Test', 'Initial') and 
		pns.RelationsipToIndexClient in ('Child') 
),
pns_tests_linkages as ( 
select 
    pns_and_tests.*,
    linkages.ReportedCCCNumber  
from pns_and_tests
left join NDWH.Fact.FactHTSClientLinkages as linkages on linkages.PatientKey = pns_and_tests.PatientKey
),
line_list_dataset as (
	select distinct
        dataset.PatientKey,
		facility.MFLCode,
		facility.FacilityName,
		facility.County,
		facility.SubCounty,
		patner.PartnerName,
		agency.AgencyName,
		RelationsipToIndexClient, 
		FinalTestResult,
		elicited.Date as DateElicited,
		tested.Date as TestDate,
		tested.year,
		tested.month,
		FORMAT(cast(tested.Date as date), 'MMMM') MonthName, 
        EOMONTH(tested.date) as AsOfDate,
		Gender,
		DATIMAgeGroup as Agegroup,
		case 
			when (dataset.PatientKey is not null) then 1 
		    else 0 
        end  elicited,
		case 
			when (FinalTestResult is not null ) then 1
		    else 0 
        end as tested,
		case 
			when (FinalTestResult = 'Positive' ) then 1
		    else 0 
        end as positive,        
		case 
			when (FinalTestResult = 'Positive' and ReportedCCCNumber is not null ) then 1 
		    else 0 
        end  Linked,
		case 
			when (KnowledgeOfHivStatus = 'Positive') then 1 
		    else 0 
        end as  KP    
	from  pns_tests_linkages as dataset
	left join NDWH.Dim.DimPatient as patient ON patient.PatientKey = dataset.PatientKey
	left join NDWH.Dim.DimPartner as patner ON patner.PartnerKey = dataset.PartnerKey
	left join NDWH.Dim.DimFacility as facility  ON facility.FacilityKey = dataset.FacilityKey
	left join NDWH.Dim.DimAgency agency ON agency.AgencyKey = dataset.AgencyKey	
	left join NDWH.Dim.DimDate as elicited on elicited.DateKey = dataset.DateElicitedKey
	left join NDWH.Dim.DimDate as tested on tested.DateKey = dataset.DateTestedKey
	left join NDWH.Dim.DimDate linked on linked.DateKey = dataset.DateLinkedToCareKey
	left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = dataset.AgeGroupKey

)
select 
	Mflcode, 
	FacilityName, 
	County, 
	SubCounty, 
	PartnerName, 
	AgencyName,
	Gender,
	Agegroup,
	year,
	month,
	MonthName,
    AsOfDate, 
	sum(elicited) as ChildrenElicited,
	sum(tested) as ChildrenTested,
	sum(positive) as ChildrenPositive,
    sum(Linked) as ChildrenLinked,
	sum(KP) as ChildrenKnownPositive,
    CAST(GETDATE() AS DATE) AS LoadDate  
    into REPORTING.dbo.AggregateHTSPNSChildren
from line_list_dataset
group by 
    Mflcode,
    FacilityName,
    County,
    subcounty,
    PartnerName,
    year,
    month,
    monthName,
    AsOfDate,
    Gender,
    Agegroup,
    AgencyName;