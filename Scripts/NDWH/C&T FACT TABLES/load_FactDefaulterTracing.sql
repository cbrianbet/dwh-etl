begin tran
IF OBJECT_ID(N'[NDWH].[Fact].[FactDefaulterTracing]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactDefaulterTracing];

with MFL_partner_agency_combination as (
	select 
		distinct 
		MFL_Code,
		SDP,
		SDP_Agency As Agency
	from ODS.Care.All_EMRSites 
),
latest_differentiated_care as (
	select
		distinct visits.SiteCode,
		visits.PatientPKHash,
		visits.DifferentiatedCare
	from ODS.Care.CT_PatientVisits as visits
	inner join ODS.[Intermediate].Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK
		and visits.VisitDate = last_visit.LastVisitDate  
),
visits_data as (
    select
	    defaulter_trace.PatientPKHash,
	    defaulter_trace.PatientIDHash,
	    defaulter_trace.SiteCode,
	    VisitID,
	    VisitDate,
	    TracingType,
	    TracingOutcome,
	    IsFinalTrace,
	    Comments,
	    Null as is_reached,
	    latest_differentiated_care.DifferentiatedCare collate Latin1_General_CI_AS as DifferentiatedCare,
	    datediff(yy, patient.DOB, defaulter_trace.VisitDate) as AgeAtVisit
    from ODS.Care.CT_DefaulterTracing as defaulter_trace
    left join ODS.Care.CT_Patient as patient on patient.PatientPKHash = defaulter_trace.PatientPKHash
        and patient.SiteCode = defaulter_trace.SiteCode
    left join latest_differentiated_care on latest_differentiated_care.PatientPKHash = defaulter_trace.PatientPKHash
	and latest_differentiated_care.SiteCode = patient.SiteCode    
    where IsFinalTrace = 'Yes' and defaulter_trace.SiteCode >= 0
)
select 
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
    visit.DateKey as VisitDateKey,
    diff_care.DifferentiatedCareKey,
    VisitID,
    TracingType,
    TracingOutcome,
    Comments,
    is_reached,
     cast(getdate() as date) as LoadDate
into NDWH.Fact.FactDefaulterTracing
from visits_data
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = visits_data.SiteCode
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash collate Latin1_General_CI_AS = visits_data.PatientPKHash collate Latin1_General_CI_AS
    and patient.SiteCode = visits_data.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = visits_data.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimDate as visit on visit.Date = visits_data.VisitDate
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = visits_data.AgeAtVisit
left join NDWH.Dim.DimDifferentiatedCare as diff_care on diff_care.DifferentiatedCare = visits_data.DifferentiatedCare
WHERE patient.voided =0;

alter table NDWH.Fact.FactDefaulterTracing add primary key(FactKey);

Update a 
    Set is_reached = case  
                            when TracingOutcome like '%No contact%' then 0 
                            else 1 
                        end
from NDWH.Fact.FactDefaulterTracing a;

rollback tran
