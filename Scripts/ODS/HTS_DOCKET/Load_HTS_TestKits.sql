BEGIN
	MERGE [ODS].[dbo].[HTS_TestKits] AS a
	USING(SELECT DISTINCT a.[FacilityName]
		  ,a.[SiteCode]
		  ,a.[PatientPk]
		  ,a.[HtsNumber]
		  ,a.[Emr]
		  ,a.[Project]
		  ,a.[EncounterId]
		  ,a.[TestKitName1]
		  ,a.[TestKitLotNumber1]
		  ,a.[TestKitExpiry1]
		  ,a.[TestResult1]
		  ,a.[TestKitName2]
		  ,a.[TestKitLotNumber2]
		  ,[TestKitExpiry2]
		  ,a.[TestResult2]
		  ,a.RecordUUID
			
	  FROM [HTSCentral].[dbo].[HtsTestKits](NoLock) a
	  Inner join ( select ct.sitecode,ct.patientPK,ct.[EncounterId],ct.[TestKitName1],ct.[TestResult2],ct.[TestKitLotNumber1],
	  max(ID) As MaxID,max(cast(DateExtracted as date))MaxDateExtracted  from [HTSCentral].[dbo].[HtsTestKits] ct
									group by ct.sitecode,ct.patientPK,ct.[EncounterId],ct.[TestKitName1],ct.[TestResult2],ct.[TestKitLotNumber1])tn
									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK 
									and cast(a.DateExtracted as date) = tn.MaxDateExtracted
									and a.[EncounterId] = tn.[EncounterId]
									and a.[TestKitName1] =tn.[TestKitName1]
									and a.[TestResult2] =tn.[TestResult2]
									and a.[TestKitLotNumber1] = tn.[TestKitLotNumber1]
									and a.ID = tn.MaxID
									
	  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
	  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode) AS b 
	ON(
		a.PatientPK  = b.PatientPK 
	and a.SiteCode = b.SiteCode	
	
	and a.EncounterId  = b.EncounterId 
	and a.[EncounterId] = b.[EncounterId]
	and a.[TestKitName1] =b.[TestKitName1]
	and a.[TestResult2] =b.[TestResult2]
	and a.[TestKitLotNumber1] = b.[TestKitLotNumber1]
	and a.RecordUUID = b.RecordUUID
	 
	)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2,LoadDate,RecordUUID)  
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2,Getdate(),RecordUUID)
	WHEN MATCHED THEN
		UPDATE SET 
			
			a.[TestKitName1]		=b.[TestKitName1],
			a.[TestKitLotNumber1]	=b.[TestKitLotNumber1],
			a.[TestKitExpiry1]		=b.[TestKitExpiry1],
			a.[TestResult1]			=b.[TestResult1],
			a.[TestKitName2]		=b.[TestKitName2],
			a.[TestKitLotNumber2]	=b.[TestKitLotNumber2],
			a.[TestKitExpiry2]		=b.[TestKitExpiry2],
			a.[TestResult2]			=b.[TestResult2],
			a.RecordUUID            =b.RecordUUID;

END