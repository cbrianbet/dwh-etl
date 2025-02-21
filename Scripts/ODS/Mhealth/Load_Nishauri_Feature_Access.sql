---- Loads Nishauri Feature Access data from MhealthCentral to ODS
BEGIN MERGE [ODS].[Mhealth].[Mhealth_Nishauri_Feature_Access] AS a USING (
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
    [DateCreated],
    [PKV],
    [FeatureAccess],
    [DOB_Date],
    [FeatureAccessDate_Date]
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
        [DateCreated],
        [PKV],
        [FeatureAccess],
        [DOB_Date],
        [FeatureAccessDate_Date],
        ROW_NUMBER() OVER (
          PARTITION BY [PatientPK],
          [SiteCode],
          [FeatureAccessDate_Date],
          [FeatureAccess]
          ORDER BY
            [DateCreated] DESC
        ) AS rn
      FROM
        [MhealthCentral].[dbo].[Nishauri_Feature_Access] (NOLOCK)
    ) AS sub
  WHERE
    sub.rn = 1
) AS b ON (
  a.[SiteCode] = b.[SiteCode]
  AND a.[PatientPK] = b.[PatientPK]
  AND a.[FeatureAccessDate] = b.[FeatureAccessDate_Date]
  AND a.[FeatureAccess] = b.[FeatureAccess]
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
    [DateCreated],
    [PKV],
    [FeatureAccess],
    [DOB],
    [FeatureAccessDate]
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
    b.[DateCreated],
    b.[PKV],
    b.[FeatureAccess],
    b.[DOB_Date],
    b.[FeatureAccessDate_Date]
  )
  WHEN MATCHED THEN
UPDATE
SET
  a.[PartnerName] = b.[PartnerName],
  a.[SiteType] = b.[SiteType],
  a.[PatientIDHash] = b.[PatientIDHash],
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
  a.[DateCreated] = b.[DateCreated],
  a.[FeatureAccess] = b.[FeatureAccess],
  a.[DOB] = b.[DOB_Date],
  a.[FeatureAccessDate] = b.[FeatureAccessDate_Date];

END;
