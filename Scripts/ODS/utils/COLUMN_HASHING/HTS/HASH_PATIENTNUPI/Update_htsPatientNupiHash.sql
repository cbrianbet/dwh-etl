UPDATE [ODS].[HTS].[HTS_clients]
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM [ODS].[HTS].[HTS_clients] ;


UPDATE [ODS].[HTS].[HTS_clients]
	set NupiHash = ''
FROM [ODS].[HTS].[HTS_clients]
where Nupi ='' ;
