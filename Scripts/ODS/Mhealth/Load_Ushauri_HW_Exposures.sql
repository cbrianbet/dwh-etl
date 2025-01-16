---- Loads Ushauri_HW_Exposures data from MhealthCentral to ODS
-- truncate table [ODS].[Mhealth].[Mhealth_Ushauri_HWExposure]
BEGIN
  MERGE [ODS].[Mhealth].[Mhealth_Ushauri_HWExposure]
  AS a
  USING (
			SELECT DISTINCT
				[UserPK],
				[UserPKHash],
				[PartnerName],
				[SiteCode],
				[SiteType],
				[Emr],
				[FacilityName],
				[Gender],
				[DOB_Date] As [DOB],
				[Department],
				[ExposureDate_Date] As [ExposureDate],
				[PEPDate_Date] As [PEPDate],
				[ExposureLocation],
				[ExposureType],
				[DeviceUsed],
				[ResultOf],
				[DevicePurpose],
				[ExposureWhen],
				[ExposureDescription],
				[PatientHIVStatus],
				[PatientHBVStatus],
				[PreviousExposures],
				[PreviousPEPInitiated],
				[DOB_Date],
				[ExposureDate_Date],
				[PEPDate_Date]
			FROM [MhealthCentral].[dbo].[HW_EXPOSURES] (NOLOCK)
  ) AS b
  ON (
      a.[UserPK]=b.[UserPK] AND
      a.[PartnerName]=b.[PartnerName] AND
      a.[SiteCode]=b.[SiteCode] AND
      a.[ExposureDate]=b.[ExposureDate] AND
      a.[PEPDate]=b.[PEPDate_Date]
    )
  WHEN NOT MATCHED THEN
    INSERT ([UserPK],
				[UserPKHash],
				[PartnerName],
				[SiteCode],
				[SiteType],
				[Emr],
				[FacilityName],
				[Gender],
				[DOB],
				[Department],
				[ExposureDate],
				[PEPDate],
				[ExposureLocation],
				[ExposureType],
				[DeviceUsed],
				[ResultOf],
				[DevicePurpose],
				[ExposureWhen],
				[ExposureDescription],
				[PatientHIVStatus],
				[PatientHBVStatus],
				[PreviousExposures],
				[PreviousPEPInitiated],
				[LoadDate]
    )
    VALUES (b.[UserPK],
			b.[UserPKHash],
			b.[PartnerName],
			b.[SiteCode],
			b.[SiteType],
			b.[Emr],
			b.[FacilityName],
			b.[Gender],
			b.[DOB],
			b.[Department],
			b.[ExposureDate],
			b.[PEPDate],
			b.[ExposureLocation],
			b.[ExposureType],
			b.[DeviceUsed],
			b.[ResultOf],
			b.[DevicePurpose],
			b.[ExposureWhen],
			b.[ExposureDescription],
			b.[PatientHIVStatus],
			b.[PatientHBVStatus],
			b.[PreviousExposures],
			b.[PreviousPEPInitiated]
		  ,Getdate()
      )
    WHEN MATCHED THEN
    UPDATE
    SET
        a.[PartnerName]=b.[PartnerName],
        a.[SiteType]=b.[SiteType],
        a.[FacilityName]=b.[FacilityName],
        a.[Gender]=b.[Gender],
        a.[DOB]=b.[DOB_Date],
        a.[Department]=b.[Department],
        a.[ExposureDate]=b.[ExposureDate_Date],
        a.[PEPDate]=b.[PEPDate_Date],
        a.[ExposureLocation]=b.[ExposureLocation],
        a.[ExposureType]=b.[ExposureType],
        a.[DeviceUsed]=b.[DeviceUsed],
        a.[ResultOf]=b.[ResultOf],
        a.[DevicePurpose]=b.[DevicePurpose],
        a.[ExposureWhen]=b.[ExposureWhen],
        a.[ExposureDescription]=b.[ExposureDescription],
        a.[PatientHIVStatus]=b.[PatientHIVStatus],
        a.[PatientHBVStatus]=b.[PatientHBVStatus],
        a.[PreviousExposures]=b.[PreviousExposures],
        a.[PreviousPEPInitiated]=b.[PreviousPEPInitiated];
END;
