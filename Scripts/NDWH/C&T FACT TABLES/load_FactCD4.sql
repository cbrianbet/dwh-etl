IF OBJECT_ID(N'[NDWH].[Fact].[FactCD4]', N'U') IS NOT NULL 
	DROP TABLE  [NDWH].[Fact].[FactCD4];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP   as SDP,
	    SDP_Agency  as Agency
	from ODS.Care.All_EMRSites 
),
 CD4s as (SELECT 
        ROW_NUMBER() OVER (PARTITION BY PatientPK, Sitecode ORDER BY OrderedbyDate DESC) AS RowNum,
        PatientPKHash,
        PatientPk,
        SiteCode,
		OrderedbyDate,
        TestName,
        TestResult
    FROM ODS.Care.CT_PatientLabs
    WHERE 
        TestName like '%CD4%'
      ),

	  LatestCD4s as (Select * from CD4s
	  where RowNum=1
	  ),

      BCD4s as (SELECT 
        ROW_NUMBER() OVER (PARTITION BY PatientPK, Sitecode ORDER BY OrderedbyDate Asc) AS RowNum,
        PatientPKHash,
        PatientPk,
        SiteCode,
		OrderedbyDate,
        TestName,
        TestResult
    FROM ODS.Care.CT_PatientLabs
    WHERE 
        TestName like '%CD4%'
      ),

	  BaselineCD4s as (Select * from BCD4s
	  where RowNum=1
	  ),

      OtherCD4s as (Select * from CD4s
      Where RowNum=2
      ),

source_CD4 as (
	select
		distinct baselines.PatientIDHash,
		baselines.PatientPKHash,
		baselines.SiteCode,
		CD4atEnrollment,
		CD4atEnrollment_Date as CD4atEnrollmentDate,
		BaselineCD4s.TestResult as BaselineCD4,
		BaselineCD4s.OrderedbyDate as BaselineCD4Date,
		LatestCD4s.OrderedbyDate as LastCD4Date,
        Case When LatestCD4s.TestName='CD4 Count'Then LatestCD4s.TestResult Else Null End as LastCD4,
        Case When LatestCD4s.TestName='CD4 Percentage' Then LatestCD4s.TestResult Else Null End as LastCD4Percentage,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit,
        OtherCD4s.TestResult as SecondCD4,
        OtherCD4s.OrderedbyDate as SecondCD4Date
	from ODS.Care.CT_PatientBaselines as baselines
	left join ODS.Care.CT_Patient as patient on patient.PatientPK = baselines.PatientPK
	and patient.SiteCode = baselines.SiteCode
	left join ODS.[Intermediate].Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = baselines.PatientPK
		and last_encounter.SiteCode = baselines.SiteCode
    left join LatestCD4s on LatestCD4s.PatientPK=baselines.PatientPK and LatestCD4s.Sitecode=baselines.SiteCode
    left join BaselineCD4s on BaselineCD4s.PatientPk=baselines.PatientPK and BaselineCD4s.SiteCode=baselines.SiteCode

    left join OtherCD4s on OtherCD4s.Patientpk=baselines.Patientpk and OtherCD4s.Sitecode=baselines.Sitecode

)

select 
	Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
	source_CD4.CD4atEnrollment,
	source_CD4.CD4atEnrollmentDate,
	source_CD4.BaselineCD4,
	source_CD4.BaselineCD4Date,
	source_CD4.LastCD4,
	source_CD4.LastCD4Date,
    source_CD4.LastCD4Percentage,
    source_CD4.SecondCD4,
    source_CD4.SecondCD4Date,
	 cast(getdate() as date) as LoadDate
into NDWH.Fact.FactCD4
from source_CD4 as source_CD4
left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash = source_CD4.PatientPKHash
    and patient.SiteCode = source_CD4.SiteCode
left join NDWH.Dim.DimFacility as facility on facility.MFLCode = source_CD4.SiteCode
left join NDWH.Dim.DimDate as cd4_enrollment on cd4_enrollment.Date = source_CD4.CD4atEnrollmentDate
left join NDWH.Dim.DimDate as last_cd4 on last_cd4.Date = source_CD4.LastCD4Date
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_CD4.SiteCode
left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = source_CD4.AgeLastVisit
WHERE patient.voided =0;

alter table NDWH.Fact.FactCD4 add primary key(FactKey);
END

