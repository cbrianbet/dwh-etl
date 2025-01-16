MERGE [ODS].[Care].[CT_FacilityManifest] AS a
	USING( SELECT DISTINCT 
			ID,Emr,Project,Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag
		   FROM [DWAPICentral].[dbo].[FacilityManifest](NoLock)
		) AS b 
	ON(a.ID =b.ID)
		WHEN NOT MATCHED THEN 
	INSERT(ID,Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag,CreatedOn)
	VALUES(ID,Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag,Getdate())
	
	WHEN MATCHED THEN
    UPDATE SET 		
			
		a.[PatientCount]=b.[PatientCount],
		a.[DateRecieved]=b.[DateRecieved],
		a.[Name]		=b.[Name]	,	
		a.[EmrName]		=b.[EmrName],		
		a.[EmrSetup]	=b.[EmrSetup],	
		a.[UploadMode]	=b.[UploadMode],	
		a.[Start]		=b.[Start],		
		a.[End]			=b.[End],			
		a.[Tag]			=b.[Tag];
	--WHEN NOT MATCHED BY SOURCE 
	--THEN
	--/* The Record is in the target table but doen't exit on the source table*/
	--	Delete;


