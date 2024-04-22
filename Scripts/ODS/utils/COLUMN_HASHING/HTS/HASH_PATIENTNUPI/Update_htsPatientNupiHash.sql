UPDATE [ODS].[dbo].[HTS_clients]
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM [ODS].[dbo].[HTS_clients] ;


UPDATE [ODS].[dbo].[HTS_clients]
	set NupiHash = ''
FROM [ODS].[dbo].[HTS_clients]
where Nupi ='' ;
