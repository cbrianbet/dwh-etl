MERGE [ODS].[Care].[CBS_FacilityManifest] AS a
	USING( SELECT DISTINCT [Id]
				  ,[SiteCode],[Name],[Sent],[Recieved],[DateLogged],[DateArrived],[Status]
				  ,[StatusDate],[FacilityId],[ManifestType],[EmrId],[EmrName],[EmrSetup]
				  ,[End],[Session],[Start],[Tag]
			FROM [CBSCentral].[dbo].[Manifests](nolock)
		) AS b 
	ON(a.ID =b.ID)
		WHEN NOT MATCHED THEN 
	INSERT(Id,SiteCode,[Name],[Sent],Recieved,DateLogged,DateArrived,[Status],StatusDate,FacilityId,ManifestType,EmrId,EmrName,EmrSetup,[End],[Session],[Start],Tag,Loaddate)
	VALUES(Id,SiteCode,[Name],[Sent],Recieved,DateLogged,DateArrived,[Status],StatusDate,FacilityId,ManifestType,EmrId,EmrName,EmrSetup,[End],[Session],[Start],Tag,Getdate())
	
	WHEN MATCHED THEN
    UPDATE SET 		
			
		a.[SiteCode]=b.[SiteCode],
		a.[Name]=b.[Name],
		a.[Sent]=b.[Sent],
		a.[Recieved]=b.[Recieved],
		a.[DateLogged]=b.[DateLogged],
		a.[DateArrived]=b.[DateArrived],
		a.[Status]=b.[Status],
		a.[StatusDate]=b.[StatusDate],
		a.[FacilityId]=b.[FacilityId],
		a.[ManifestType]=b.[ManifestType],
		a.[EmrId]=b.[EmrId],
		a.[EmrName]=b.[EmrName],
		a.[EmrSetup]=b.[EmrSetup],
		a.[End]=b.[End],
		a.[Session]=b.[Session],
		a.[Start]=b.[Start],
		a.[Tag]=b.[Tag];


