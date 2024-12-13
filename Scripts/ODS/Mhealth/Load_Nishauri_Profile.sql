---- Loads Nishauri Profile data from MhealthCentral to ODS
BEGIN MERGE [ODS].[Mhealth].[Mhealth_Nishauri_Profile] AS a USING (
  SELECT
    [PatientPK],
    [PatientPKHash],
    [PartnerName],
    [SiteCode],
    [SiteType],
    [PatientID],
    [PatientIDHash],
    [FacilityID],
    [Emr],
    [Project],
    [FacilityName],
    [Gender],
    [MaritalStatus],
    [PatientResidentCounty],
    [PatientResidentLocation],
    [PatientResidentSubCounty],
    [PatientResidentSubLocation],
    [PatientResidentVillage],
    [PatientResidentWard],
    [PKV],
    [DOB_Date],
    [DateCreated_Date]
  FROM
    (
      SELECT
        DISTINCT [PatientPK],
        [PatientPKHash],
        [PartnerName],
        [SiteCode],
        [SiteType],
        [PatientID],
        [PatientIDHash],
        [FacilityID],
        [Emr],
        [Project],
        [FacilityName],
        [Gender],
        [MaritalStatus],
        [PatientResidentCounty],
        [PatientResidentLocation],
        [PatientResidentSubCounty],
        [PatientResidentSubLocation],
        [PatientResidentVillage],
        [PatientResidentWard],
        [PKV],
        [DOB_Date],
        [DateCreated_Date],
        ROW_NUMBER() OVER (
          PARTITION BY [PatientPK],
          [SiteCode]
          ORDER BY
            [DateCreated_Date] DESC
        ) AS rn
      FROM
        [MhealthCentral].[dbo].[Nishauri_Profile] (NOLOCK)
    ) AS sub
  WHERE
    sub.rn = 1
) AS b ON (
  a.[SiteCode] = b.[SiteCode]
  AND a.[PatientPK] = b.[PatientPK]
)
WHEN NOT MATCHED THEN
INSERT
  (
    [PatientPK],
    [PatientPKHash],
    [PartnerName],
    [SiteCode],
    [SiteType],
    [PatientID],
    [PatientIDHash],
    [FacilityID],
    [Emr],
    [Project],
    [FacilityName],
    [Gender],
    [MaritalStatus],
    [PatientResidentCounty],
    [PatientResidentLocation],
    [PatientResidentSubCounty],
    [PatientResidentSubLocation],
    [PatientResidentVillage],
    [PatientResidentWard],
    [PKV],
    [DOB],
    [DateCreated]
  )
VALUES
  (
    b.[PatientPK],
    b.[PatientPKHash],
    b.[PartnerName],
    b.[SiteCode],
    b.[SiteType],
    b.[PatientID],
    b.[PatientIDHash],
    b.[FacilityID],
    b.[Emr],
    b.[Project],
    b.[FacilityName],
    b.[Gender],
    b.[MaritalStatus],
    b.[PatientResidentCounty],
    b.[PatientResidentLocation],
    b.[PatientResidentSubCounty],
    b.[PatientResidentSubLocation],
    b.[PatientResidentVillage],
    b.[PatientResidentWard],
    b.[PKV],
    b.[DOB_Date],
    b.[DateCreated_Date]
  )
  WHEN MATCHED THEN
UPDATE
SET
  a.[PartnerName] = b.[PartnerName],
  a.[SiteType] = b.[SiteType],
  a.[FacilityID] = b.[FacilityID],
  a.[Emr] = b.[Emr],
  a.[Project] = b.[Project],
  a.[FacilityName] = b.[FacilityName],
  a.[Gender] = b.[Gender],
  a.[MaritalStatus] = b.[MaritalStatus],
  a.[PatientResidentCounty] = b.[PatientResidentCounty],
  a.[PatientResidentLocation] = b.[PatientResidentLocation],
  a.[PatientResidentSubCounty] = b.[PatientResidentSubCounty],
  a.[PatientResidentSubLocation] = b.[PatientResidentSubLocation],
  a.[PatientResidentVillage] = b.[PatientResidentVillage],
  a.[PatientResidentWard] = b.[PatientResidentWard],
  a.[DOB] = b.[DOB_Date],
  a.[DateCreated] = b.[DateCreated_Date];

END;
