IF OBJECT_ID(N'[REPORTING].[dbo].LineListPBFW', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListPBFW

GO


with viral_load_metrics as (
    select
        PatientKey,
        EligibleVL,
        PBFW_ValidVL,
        PBFW_ValidVLSup,
        PBFW_ValidVLResultCategory,
        RepeatVls,
        RepeatSuppressed,
        RepeatUnSuppressed      
    from NDWH.Fact.FactViralLoads
)
select 
    patient.PatientPKHash,
    patient.NUPI,
    patient.PatientIDHash,
    facility.MFLCode,
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    patient.DOB,
    agegroup.DATIMAgeGroup as AgeGroup,
    anc1.Date as ANC1Date,
    anc2.Date as ANC2Date,
    anc3.Date as ANC3Date,
    anc4.Date as ANC4Date,
    KnownPositive,
    NewPositives as NewPositive,
    case 
        when RecieivedART = 1 and KnownPositive = 1 then  1 
        else 0 
    end as KnownPositiveOnART,
    case 
        when viral_load_metrics.EligibleVL = 1 and KnownPositive = 1 then 1
        else 0
    end as KnowPositivesEligibleVL,
    case 
        when viral_load_metrics.PBFW_ValidVL = 1 and KnownPositive = 1 then 1
        else 0
    end as KnowPositivesValidVL,
    viral_load_metrics.PBFW_ValidVLResultCategory,
    case 
        when viral_load_metrics.PBFW_ValidVLSup = 1 and KnownPositive = 1 then 1 
        else 0
    end as KnowPositivesSupVL,
    case 
        when viral_load_metrics.PBFW_ValidVLSup = 0  and PBFW_ValidVL=1 and  KnownPositive = 1 then 1
        else 0
    end as  KnowPositivesUnSupVL,
    case 
        when viral_load_metrics.PBFW_ValidVLSup = 0 and ReceivedEAC1 = 1 then 1
        else 0 
    end as UnSupReceivedEAC1,
    case 
        when viral_load_metrics.PBFW_ValidVLSup = 0 and ReceivedEAC2 = 1 then 1
        else 0 
    end as UnSupReceivedEAC2,
    case 
        when viral_load_metrics.PBFW_ValidVLSup = 0 and ReceivedEAC3 = 1 then 1
        else 0 
    end as UnSupReceivedEAC3,        
    case when viral_load_metrics.RepeatVls = 1 then 1 else 0 end as HasRepeatVL,
    case when viral_load_metrics.RepeatSuppressed = 1 then 1 else 0 end as HasRepeatVLSupressed,
    case when viral_load_metrics.RepeatUnSuppressed = 1 then 1 else 0 end as HasRepeatVLUnSuppressed,
    case when viral_load_metrics.RepeatUnSuppressed = 1 and pbfw.PBFWRegLineSwitch =1 and Knownpositive=1  and viral_load_metrics.PBFW_ValidVL=1 Then 1 else 0 end as HasRegLineSwitch
into [REPORTING].[dbo].LineListPBFW
from NDWH.Fact.FactPBFW as pbfw
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = pbfw.PatientKey
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = pbfw.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.Partnerkey = pbfw.PartnerKey 
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = pbfw.AgencyKey 
left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = pbfw.AgeGroupKey
left join NDWH.Dim.DimDate as anc1 on anc1.DateKey = ANCDate1Key
left join NDWH.Dim.DimDate as anc2 on anc2.DateKey = ANCDate2Key
left join NDWH.Dim.DimDate as anc3 on anc3.DateKey = ANCDate3Key
left join NDWH.Dim.DimDate as anc4 on anc4.DateKey = ANCDate4Key
left join viral_load_metrics on viral_load_metrics.PatientKey = pbfw.patientkey;