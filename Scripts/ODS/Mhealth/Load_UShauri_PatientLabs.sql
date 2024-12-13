---- Loads data from MhealthCentral to ODS
-----truncate table[ODS].[dbo].[Mhealth_mLab_PatientLab]
BEGIN

  MERGE  [ODS].[Mhealth].[Mhealth_mLab_PatientLab] AS a
  USING (
    SELECT DISTINCT [PatientPK]
					,[PatientPKHash]
					, [PatientID]
					, [PatientIDHash]
					, [SiteCode]
					, [FacilityName]
					, [OrderedbyDate]
					, [ReportedbyDate]
					, [TestName]
					, [TestResult]
					, [Units]
					, [LabName]
    FROM [MhealthCentral].[dbo].[CT_PatientLabs] (NOLOCK)
  ) AS b
  ON (a.Ushauri_PatientPK = b.PatientPK and
       a.sitecode   = b.sitecode and
      a.[OrderedbyDate] = b.[OrderedbyDate] and
	  a.[TestName]     = b.[TestName] and
	  a.[TestResult]   = b.[TestResult] and
	  a.ReportedbyDate  = b. ReportedbyDate and
	  a.units     = b.units  and
	  a.labName     = b.labName
	  )
  WHEN NOT MATCHED THEN
    INSERT ([Ushauri_PatientPK]
			, [Ushauri_PatientPKHash]
			, [PatientID]
			, [PatientIDHash]
			, [SiteCode]
			, [FacilityName]
			, [OrderedbyDate]
			, [ReportedbyDate]
			, [TestName]
			, [TestResult]
			, [Units]
			, [LabName]
			,LoadDate
		)
    VALUES (b.[PatientPK]
			, b.[PatientPKHash]
			, b.[PatientID]
			, b.[PatientIDHash]
			, b.[SiteCode]
			, b.[FacilityName]
			, b.[OrderedbyDate]
			, b.[ReportedbyDate]
			, b.[TestName]
			, b.[TestResult]
			, b.[Units]
			, b.[LabName]
			,Getdate()
			)
    WHEN MATCHED THEN
    UPDATE
    SET
      a.[OrderedbyDate] = b.[OrderedbyDate],
      a.[ReportedbyDate] = b.[ReportedbyDate],
      a.[TestName] = b.[TestName],
      a.[TestResult] = b.[TestResult],
      a.[Units] = b.[Units],
      a.[LabName] = b.[LabName];

END;
