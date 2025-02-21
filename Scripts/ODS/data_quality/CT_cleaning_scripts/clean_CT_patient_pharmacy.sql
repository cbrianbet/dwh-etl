--clean Drug
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET Drug = lkp_regimen.target_name 
FROM [ODS].[Care].[CT_PatientPharmacy] AS PatientPharmacy
INNER JOIN ods.lkp.lkp_regimen ON lkp_regimen.source_name = PatientPharmacy.Drug

GO

--clean Duration
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET Duration = 999
WHERE CAST(Duration AS FLOAT) < 0

GO

-- clean ExpectedReturn
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET ExpectedReturn = NULL
WHERE ExpectedReturn < CAST('1900-01-01' AS DATE) 

GO

-- clean TreatmentType
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET TreatmentType = lkp_treatment_type.target_name
FROM [ODS].[Care].[CT_PatientPharmacy] AS PatientPharmacy
INNER JOIN ods.lkp.lkp_treatment_type ON lkp_treatment_type.source_name = PatientPharmacy.TreatmentType

GO

-- clean PeriodTaken
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET PeriodTaken = 999
WHERE ISNUMERIC(PeriodTaken) = 0 OR TRY_CAST(PeriodTaken AS FLOAT) < 0

GO

--clean ProphylaxisType
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET ProphylaxisType = lkp_prophylaxis_type.target_name
FROM [ODS].[Care].[CT_PatientPharmacy] AS PatientPharmacy
INNER JOIN ods.lkp.lkp_prophylaxis_type ON lkp_prophylaxis_type.source_name = PatientPharmacy.ProphylaxisType

GO

-- clean Emr
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET Emr = CASE
                WHEN Emr = 'Open Medical Records System - OpenMRS' THEN 'OpenMRS'
                WHEN Emr = 'Ampath AMRS' THEN 'AMRS'
            END
WHERE Emr IN ('Open Medical Records System - OpenMRS', 'Ampath AMRS')

GO

-- clean Project
UPDATE [ODS].[Care].[CT_PatientPharmacy]
    SET Project = CASE
                    WHEN Project IN ('Ampathplus', 'AMPATH') THEN  'Ampath Plus'
                    WHEN Project IN ('UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM', 'IRDO')  THEN 'Kenya HMIS II'
            END
WHERE Project IN ('Ampathplus', 'AMPATH', 'UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM', 'IRDO')

GO

-- clean RegimenLine
UPDATE ODS.[Care].CT_PatientPharmacy
    SET RegimenLine = ODS.lkp.lkp_RegimenLineMap.Target_Regimen
FROM ODS.[Care].CT_PatientPharmacy AS Pharmacy
INNER JOIN ods.lkp.lkp_RegimenLineMap ON lkp_RegimenLineMap.Source_Regimen = Pharmacy.RegimenLine