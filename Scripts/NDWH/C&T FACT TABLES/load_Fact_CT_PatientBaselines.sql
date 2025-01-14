
DECLARE @TableName NVARCHAR(128) = N'[NDWH].[Fact].[FactCTPatientsBaselines]';

IF OBJECT_ID(@TableName, N'U') IS NOT NULL 
BEGIN
    EXEC('DROP TABLE ' + @TableName);
END

BEGIN
    WITH MFL_partner_agency_combination AS (
        SELECT DISTINCT 
            MFL_Code,
            SDP,
            SDP_Agency AS Agency
        FROM ODS.care.All_EMRSites 
    ),
    CT_Patients AS (
        SELECT DISTINCT 
            CT_Patients.PatientPKHash,
            CT_Patients.SiteCode
        FROM ODS.care.CT_Patient AS CT_Patients
        WHERE voided = 0
    ),
    CT_PatientVisits AS (
        SELECT DISTINCT 
            ROW_NUMBER() OVER(PARTITION BY CT_PatientVisits.SiteCode, CT_PatientVisits.PatientPKHash ORDER BY VisitDate ASC) AS rank,
            CT_PatientVisits.PatientPKHash,
            CT_PatientVisits.SiteCode,
            CT_PatientVisits.Adherence,
            CT_PatientVisits.AdherenceCategory
        FROM ODS.Care.CT_PatientVisits
    ),
    Baseline_Adherence AS (
        SELECT 
            PatientPKHash,
            SiteCode,
            Adherence,
            AdherenceCategory
        FROM CT_PatientVisits
        WHERE rank = 1 AND AdherenceCategory IN ('ARV Adherence', 'ART', 'ARVAdherence', 'ARV', 'ART|CTX')
    ),
    Baseline_Vls AS (
        SELECT
            PatientPKHash,
            SiteCode,
            CASE 
                WHEN CAST(REPLACE(TestResult, ',', '') AS FLOAT) >= 1000.00 THEN 'UNSUPPRESSED' 
                WHEN CAST(REPLACE(TestResult, ',', '') AS FLOAT) BETWEEN 200.00 AND 999.00 THEN 'High Risk LLV'
                WHEN CAST(REPLACE(TestResult, ',', '') AS FLOAT) BETWEEN 50.00 AND 199.00 THEN 'Low Risk LLV'
                WHEN CAST(REPLACE(TestResult, ',', '') AS FLOAT) < 50 THEN 'LDL'
                ELSE
                    CASE
                        WHEN TestResult IN ('Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level') THEN 'LDL' 
                        ELSE NULL 
                    END 
            END AS BaselineVLOutcomes
        FROM ODS.Intermediate.Intermediate_BaseLineViralLoads
    )
    SELECT 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        adherence,
        CAST(GETDATE() AS DATE) AS LoadDate
    INTO NDWH.Fact.FactCTPatientsBaselines
    FROM CT_Patients
    LEFT JOIN NDWH.Dim.DimPatient AS patient ON patient.PatientPKHash = CT_Patients.PatientPKHash
        AND patient.SiteCode = CT_Patients.SiteCode
    LEFT JOIN NDWH.Dim.DimFacility AS facility ON facility.MFLCode = CT_Patients.SiteCode
    LEFT JOIN MFL_partner_agency_combination ON MFL_partner_agency_combination.MFL_Code = CT_Patients.SiteCode
    LEFT JOIN NDWH.Dim.DimPartner AS partner ON partner.PartnerName = MFL_partner_agency_combination.SDP
    LEFT JOIN NDWH.Dim.DimAgency AS agency ON agency.AgencyName = MFL_partner_agency_combination.Agency
    LEFT JOIN Baseline_Adherence ON Baseline_Adherence.PatientPKHash = CT_Patients.PatientPKHash 
        AND Baseline_Adherence.SiteCode = CT_Patients.SiteCode;

    ALTER TABLE NDWH.Fact.FactCTPatientsBaselines ADD PRIMARY KEY(FactKey);
END


