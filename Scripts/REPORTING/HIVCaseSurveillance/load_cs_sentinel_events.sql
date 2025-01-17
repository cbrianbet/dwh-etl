IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsSentinelEvents]', N'U') IS NOT NULL 
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsSentinelEvents];
begin
 with   MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
         SDP,
        SDP_Agency as Agency 
    from ODS.care.All_EMRSites 
 ),
 confirmed_reported_cases_and_art as (
        select 
                ctpatients.PatientKey,
                ctpatients.Gender,
                art.AgeLastVisit,
                art.Agegroupkey,
                ctpatients.sitecode,
                case when  confirmed_date.Date is not null Then 1 Else 0 End as NewCaseReported,
                Case when art_date.Date is not null then 1 Else 0 End as LinkedToART,
                case when art_date.Date is null Then 1 Else 0 End as NotLinkedOnART,
                  confirmed_date.Date as DateConfirmedPositive,
                eomonth(confirmed_date.Date) as CohortYearMonth,
                case 
                    when art_date.Date < confirmed_date.Date then confirmed_date.Date
                    else art_date.Date
                end as StartARTDate,
                DATEDIFF(year,ctpatients.DOB,confirmed_date.Date) as AgeatDiagnosis 
                      
        from [NDWH].[Dim].[DimPatient] as ctpatients
            left join  NDWH.Fact.FACTART as art on ctpatients.patientkey=art.PatientKey
            left join [NDWH].[Dim].[DimDate] as confirmed_date on confirmed_date.DateKey = ctpatients.DateConfirmedHIVPositiveKey
            left join [NDWH].[Dim].[DimDate] as art_date on art_date.DateKey = art.StartARTDateKey
            left join [NDWH].[Dim].[DimAgeGroup]as age on age.AgeGroupKey=art.AgeGroupKey
          
           
          
            where DateConfirmedHIVPositiveKey is not null
            
 ) ,

 BaselineCD4s As (
    SELECT
    PatientKey,
    BaselineCD4,
    BaselineCD4Date
    from [NDWH].[Fact].[FactCD4]
    where BaselineCD4 is not null
 ),
 OtherCD4s As (
   Select 
   Patientkey,
   coalesce (secondCD4,LastCD4) as OtherCD4s,
    coalesce (secondCD4Date,LastCD4Date)OtherCD4sDate,
   LastCD4Percentage as OtherCD4Percent,
   LastCD4Date as OtherCD4PercentDate
  from [NDWH].[Fact].[FactCD4]
 
 ),
 BaselineWHO As (
    Select 
     Patientkey,
    WHOStageATART,
    AgeAtARTStart
    from  NDWH.Fact.FACTARTBaselines
 ),

ViralLoads as (
    SELECT
    PatientKey,
    FirstVL ,
    IsSuppressedInitialViralload,
    SecondVL as FirstFollowupViralloads,
    IsSuppressedSecondFollowupViralloads as IsSuppressedFirstFollowUpViralloads,
    ThirdVL as SecondFollowupviralloads,
    IsSuppressedThirdFollowupViralloads as IsSuppressedSecondFollowupviralloads
    from NDWH.Fact.FactViralLoads as vls 
),

RegimenChanges as (
  Select 
  Patientkey,
  Facilitykey,
  StartRegimen,
  CurrentRegimen,
  case when StartRegimen = CurrentRegimen Then 0 Else 1 End as RegimenChanged
  from NDWH.Fact.FACTART
  where StartRegimen is not null
),
OptimizedRegimen as (
  Select 
    Patientkey,
    Facilitykey,
    StartRegimen,
    CurrentRegimen,
    case when  CurrentRegimen like '3TC+DTG+TDF' THEN 1
    Else  0 END AS OptimizedRegimen
  from NDWH.Fact.FACTART
),

 SecondLatestHighVls as (
  SELECT
  PatientKey,
  FacilityKey,
  cast (LatestVLDate2Key as date) as LatestVLDate2Key,
  LatestVL2
  from NDWH.Fact.FactViralLoads as secondlatestvls
   LEFT JOIN Ndwh.Dim.Dimdate AS SecondVLDate
                      ON SecondVLDate.Datekey = secondlatestvls.LatestVLDate2Key
  where TRY_CAST(LatestVL2 as float) >=1000 
    AND DATEDIFF(month, LatestVLDate2Key , GETDATE()) <= 26
),
ConsecutiveHighVls as  (
  SELECT
  latestvls.Patientkey,
  latestvls.FacilityKey,
  LatestVL1,
  cast (LatestVLDate1Key as date ) as LatestVLDate
  from NDWH.Fact.FactViralLoads as latestvls
  inner join SecondLatestHighVls on SecondLatestHighVls.PatientKey=latestvls.PatientKey
   LEFT JOIN Ndwh.Dim.Dimdate AS LatestVLDate
                      ON LatestVLDate.Datekey = latestvls.LatestVLDate1Key
    where TRY_CAST(LatestVL1 as float) >=1000 and  datediff(month, LatestVLDate1Key , eomonth(dateadd(mm,-1,getdate()))) <= 14

),
LatestSuppressedVL as (
Select
  latestvls.Patientkey,
  latestvls.FacilityKey,
  LatestVL1 as LatestVLSuppressed,
  cast (LatestVLDate1Key as date ) as LatestVLDate
  from NDWH.Fact.FactViralLoads as latestvls
    LEFT JOIN Ndwh.Dim.Dimdate AS LatestVLDate
                      ON latestvlDate.Datekey = latestvls.LatestVLDate1Key
  where TRY_CAST(LatestVL2 as float) <1000 
  OR Latestvl1 IN ( 'undetectable', 'NOT DETECTED',
                                     '0 copies/ml',
                                     'LDL',
                                     'Less than Low Detectable Level')
),
Retained as (
  Select
  Patientkey,
  FacilityKey,
  case when artoutcomekey= 6 then 1 Else 0 End as PatientRetained
  from NDWH.Fact.FACTART
)
 select 
    confirmed_reported_cases_and_art.PatientKey,
    Gender,
    AgeLastVisit,
    SiteCode,
    County,
    subCounty,
    SDP as PartnerName,
    AgencyName,
    NewCaseReported,
    LinkedToART,
    NotLinkedOnART,
    DateConfirmedPositive,
    CohortYearMonth,
    StartARTDate,
    AgeatDiagnosis,
    case when BaselineCD4 is not null Then 1 Else 0 End as WithBaselineCD4,
    case when BaselineCD4 is  null Then 1 Else 0 End as WithoutBaselineCD4,
    case when  BaselineCD4 is not null and Try_CONVERT(FLOAT, BaselineCD4) < 200 Then 1 Else 0 End as CD4Lessthan200,
    case when  BaselineCD4 is not null and Try_CONVERT(FLOAT, BaselineCD4) >= 200 Then 1 Else 0 End as CD4Morethan200,
CASE 
    WHEN 
       ((ISNUMERIC(OtherCD4s) = 1 AND TRY_CONVERT(float, OtherCD4s) IS NOT NULL AND TRY_CONVERT(float, OtherCD4s) < 200)
        OR 
       (AgeatDiagnosis <= 5 AND ISNUMERIC(OtherCD4Percent) = 1 AND TRY_CONVERT(float, OtherCD4Percent) IS NOT NULL AND TRY_CONVERT(float, OtherCD4Percent) < 25))
        AND whostageAtART IN (3, 4)
    THEN 1 
    ELSE 0 
END AS AHD,
case when whostageAtART is null then 1 else 0 End as NotStaged,
    BaselineWHO.WHOStageATART,
  BaselineWHO.AgeAtARTStart,
   age.DATIMAgeGroup as ARTStartAgeGroup,
   case when vls.FirstVL is not null then 1 Else 0 End as WithInitialViralLoad,
   case when vls.FirstVL is null then 1 Else 0 End as WithoutInitialViralLoad,
   coalesce(vls.IsSuppressedInitialViralload,0) As IsSuppressedInitialViralload,
  case when IsSuppressedInitialViralload=0 Then 1 Else 0 End as IsNotSuppressedInitialViralload,
   case when vls.FirstFollowupViralloads is not null then 1 Else 0 End As WithFirstFollowupViralload,
   coalesce (IsSuppressedFirstFollowupViralloads,0) as IsSuppressedFirstFollowupViralloads,
   case when vls.SecondFollowupviralloads is not null then 1 Else 0 End As WithSecondFollowupViralloads,
   coalesce (IsSuppressedSecondFollowupViralloads,0) As IssuppressedSecondFollowupViralloads,
   coalesce (RegimenChanged,0) as RegimenChanged,
   case when RegimenChanged=0 Then 1 else 0 End as RegimenNotChanged,
   OptimizedRegimen,
   case when LatestVL1 is not null then 1 Else 0 End as TreatmentFailure,
   case when LatestVLSuppressed is not null then 1 Else 0 End as LatestVLSuppressed,
   case when LatestVLSuppressed is null then 1 Else 0 End as LatestVLNotSuppressed,
   coalesce (PatientRetained,0) as PatientRetained,
   case when PatientRetained=0 then 1 Else 0 End as PatientNotRetained
 into [HIVCaseSurveillance].[dbo].[CsSentinelEvents]
 from confirmed_reported_cases_and_art 
 left join BaselineCD4s on BaselineCD4s.PatientKey=confirmed_reported_cases_and_art.PatientKey
 left join BaselineWHO on BaselineWHO.patientkey=confirmed_reported_cases_and_art.PatientKey
 left join [NDWH].[Dim].[DimAgeGroup]age on age.AgeGroupKey = confirmed_reported_cases_and_art.AgeGroupKey
 left join NDWH.Dim.DimFacility as facility on facility.MFLCode = confirmed_reported_cases_and_art.SiteCode
 left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = confirmed_reported_cases_and_art.SiteCode
 left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
 left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
 left join OtherCD4s on OtherCD4s.Patientkey=confirmed_reported_cases_and_art.Patientkey
 left join RegimenChanges on RegimenChanges.Patientkey=confirmed_reported_cases_and_art.PatientKey
 left join OptimizedRegimen on OptimizedRegimen.Patientkey=confirmed_reported_cases_and_art.PatientKey
 left join ConsecutiveHighVls on ConsecutiveHighVls.PatientKey=confirmed_reported_cases_and_art.PatientKey
 left join LatestSuppressedVL on LatestSuppressedVL.PatientKey=confirmed_reported_cases_and_art.PatientKey
 left join Retained on Retained.Patientkey=confirmed_reported_cases_and_art.PatientKey
 left join Viralloads as vls on vls.PatientKey=confirmed_reported_cases_and_art.PatientKey
 end
