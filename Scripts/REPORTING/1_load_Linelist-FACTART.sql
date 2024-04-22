IF OBJECT_ID(N'[REPORTING].[dbo].[Linelist_FACTART]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[Linelist_FACTART];
BEGIN

with ncd_indicators as (
    select 
        PatientKey,
        Hypertension as HasHypertension,
        IsHyperTensiveAndScreenedBPLastVisit,
        IsHyperTensiveAndBPControlledAtLastVisit,
        Diabetes as HasDiabetes,
        IsDiabeticAndScreenedDiabetes,
        IsDiabeticAndDiabetesControlledAtLastTest,
        hypertension.Date as FirstHypertensionRecoredeDate,
        diabetes.Date as FirstDiabetesRecordedDate,
        dyslipidemia.Date as FirstDyslipidemiaRecordedDate,
        [Mental illness],
        Dyslipidemia
    from NDWH.dbo.FactNCD as ncd
    left join NDWH.dbo.DimDate as hypertension on hypertension.DateKey = ncd.FirstHypertensionRecoredeDateKey
    left join NDWH.dbo.DimDate as diabetes on diabetes.DateKey = ncd.FirstDiabetesRecordedDateKey 
    left join NDWH.dbo.DimDate as dyslipidemia on dyslipidemia.DateKey =ncd.FirstDyslipidemiaRecordedDateKey
)
Select distinct 
    pat.PatientIDHash,
    pat.PatientPKHash,
    pat.Gender,
    pat.DOB,
    pat.MaritalStatus,
    pat.Nupi,
    pat.PatientSource,
    pat.ClientType,
    pat.SiteCode,
    fac.FacilityName,
    fac.County,
    fac.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    age.age,
    age.DATIMAgeGroup as AgeGroup,
    startdate.Date as StartARTDate,
    ART.CurrentRegimen,
    ART.CurrentRegimenline,
    ART.StartRegimen,
    ART.StartRegimenLine,
    ART.AgeAtEnrol,
    ART.AgeAtARTStart,
    ART.TimetoARTDiagnosis,
    ART.TimetoARTEnrollment,
    ART.PregnantARTStart,
    ART.PregnantAtEnrol,
    ART.LastVisitDate,
    ART.NextAppointmentDate,
    ART.StartARTAtThisfacility,
    ART.PreviousARTStartDate,
    ART.PreviousARTRegimen,
    case 
        when outcome.ARTOutcome is null then 'Others'
        else outcome.ARTOutcomeDescription
    end as ARTOutcomeDescription,
    vl.EligibleVL as Eligible4VL,
    vl.HasValidVL,
    vl.ValidVLSup,
    vl.LastVL,
    lastVL.Date as LastVLDate,
    vl.ValidVLResult,
    vl.ValidVLResultCategory1 as ValidVLResultCategory1,
    vl.ValidVLResultCategory2 as ValidVLResultCategory2,
    vl.HighViremia,
    vl.LowViremia,
    pat.ISTxCurr,
	dif.DifferentiatedCare,
    art.ScreenedBPLastVisit,
    art.ScreenedDiabetes,
    coalesce(ncd.HasHypertension, 0) as HasHypertension, 
    coalesce(ncd.IsHyperTensiveAndScreenedBPLastVisit, 0) as IsHyperTensiveAndScreenedBPLastVisit,
    coalesce(ncd.IsHyperTensiveAndBPControlledAtLastVisit, 0) as IsHyperTensiveAndBPControlledAtLastVisit,
    coalesce(ncd.HasDiabetes, 0) as HasDiabetes,
    coalesce(ncd.IsDiabeticAndScreenedDiabetes, 0) as IsDiabeticAndScreenedDiabetes,
    coalesce(ncd.IsDiabeticAndDiabetesControlledAtLastTest, 0) as IsDiabeticAndDiabetesControlledAtLastTest,
    ncd.FirstHypertensionRecoredeDate,
    ncd.FirstDiabetesRecordedDate,
    CD4.LastCD4,
    CD4.LastCD4Percentage,
    ART.WhoStage,
    Case When (age.Age >= 5 AND ART.WhoStage in (3,4))
        OR age.Age<5 
            OR (age.Age >= 5 AND CONVERT(FLOAT, CD4.LastCD4) < 200)Then 1 
        Else 0 
    End as AHD,
    CASE WHEN startdate.Date > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) OR  ART.WhoStage IN (3, 4) Or Try_cast (LastVL as float) >=200.00 Then 1 ELSE 0 END AS EligibleCD4,
    obs.TBScreening,
    ART.PHQ_9_rating,
    ART.ScreenedForDepression,
	ScreenedDepressionDate,
    case when ncd.[Mental illness] is null then 0 else ncd.[Mental illness] end as HasMentalIllness,
    case when ncd.Dyslipidemia is null then 0 else ncd.Dyslipidemia end as HasDyslipidemia,
    onMMD,
    StabilityAssessment,
    AppointmentsCategory,
	art.Pregnant,
	art.Breastfeeding,
    art.IsRTTLast12MonthsAfter3monthsIIT,
    cast (AsOfDateKey as date) as EndofMonthDate,
    cast(getdate() as date) as LoadDate
INTO [REPORTING].[dbo].[Linelist_FACTART]
from  NDWH.dbo.FACTART As ART 
left join NDWH.dbo.DimPatient pat on pat.PatientKey = ART.PatientKey
left join NDWH.dbo.DimPartner partner on partner.PartnerKey = ART.PartnerKey
left join NDWH.dbo.DimAgency agency on agency.AgencyKey = ART.AgencyKey
left join NDWH.dbo.DimFacility fac on fac.FacilityKey = ART.FacilityKey
left join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = ART.AgeGroupKey
left join NDWH.dbo.DimDate startdate on startdate.DateKey = ART.StartARTDateKey
left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey=ART.ARTOutcomeKey
left join NDWH.dbo.FactViralLoads as vl on vl.PatientKey = ART.PatientKey
left join NDWH.dbo.FactLatestObs as obs on obs.PatientKey = ART.PatientKey
left join NDWH.dbo.DimDifferentiatedCare as dif on dif.DifferentiatedCareKey = obs.DifferentiatedCareKey
left join NDWH.dbo.DimDate as lastVL on lastVL.DateKey =  vl.LastVLDateKey
left join ncd_indicators as ncd on ncd.PatientKey = ART.PatientKey
left join NDWH.dbo.FactCD4 as CD4 on CD4.PatientKey= ART.PatientKey
left join NDWH.dbo.DimDate as end_month on end_month.DateKey = ART.AsOfDateKey;

END

      