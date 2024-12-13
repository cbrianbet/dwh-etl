IF OBJECT_ID(N'[ODS].[Intermediate].[intermediate_ARTBaselines]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[intermediate_ARTBaselines];

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.Care.All_EMRSites 
),
 ARTPatients as (
    Select 
    Patientpk,
    PatientPKHash,
    SiteCode,
    StartARTDate,
    DATEDIFF(year,dob,StartARTDate) as AgeATARTStart
    from ODS.Care.CT_ARTPatients
),
Baseline_Who as (
	select
		distinct visits.PatientPK, 
		visits.WhoStage,
        visits.SiteCode
	from ODS.Care.CT_PatientVisits as visits
	inner join ARTPatients as art on visits.SiteCode = art.SiteCode 
		and visits.PatientPK = art.PatientPK 
		and visits.VisitDate = art.StartARTDate
	WHERE  VISITS.VOIDED=0
 )

	select 
		patient.PatientPKHash,
        patient.PatientPK,
		patient.SiteCode,
		WhoStage as WhoStageAtART,
        AgeATARTStart,
        cast(getdate() as date) as LoadDate
        into ODS.[Intermediate].intermediate_ARTBaselines
	from ARTPatients as patient
    left join Baseline_Who on Baseline_Who.PatientPK=patient.PatientPK and Baseline_Who.Sitecode=patient.Sitecode

END
