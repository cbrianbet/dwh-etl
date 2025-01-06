MERGE [ODS].[HTS].[HTS_FacilityManifest] AS a
	USING( SELECT distinct [Id]
				  ,[SiteCode],[Name],[Sent],[Recieved],[DateLogged],[DateArrived],[Status]
				  ,[StatusDate],[FacilityId],[EmrId],[EmrName],[EmrSetup],[RefId],[End]
				  ,[Session],[Start],[Tag]
			FROM [HTSCentral].[dbo].[Manifests](nolock)
		) AS b 
	ON(a.ID =b.ID)
		WHEN NOT MATCHED THEN 
	INSERT(Id,SiteCode,[Name],[Sent],Recieved,DateLogged,DateArrived,[Status],StatusDate,FacilityId,EmrId,EmrName,EmrSetup,RefId,[End],[Session],[Start],Tag,Loaddate)
	VALUES(Id,SiteCode,[Name],[Sent],Recieved,DateLogged,DateArrived,[Status],StatusDate,FacilityId,EmrId,EmrName,EmrSetup,RefId,[End],[Session],[Start],Tag,Getdate())
	
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
		a.[EmrId]=b.[EmrId],
		a.[EmrName]=b.[EmrName],
		a.[EmrSetup]=b.[EmrSetup],
		a.[End]=b.[End],
		a.[Session]=b.[Session],
		a.[Start]=b.[Start],
		a.[Tag]=b.[Tag];


