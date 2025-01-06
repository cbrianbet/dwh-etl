UPDATE [ODS].[MNCH].[MNCH_Patient]
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM [ODS].[MNCH].[MNCH_Patient] 
where NupiHash is null ;


UPDATE [ODS].[MNCH].[MNCH_Patient] 
	set NupiHash = ''
FROM [ODS].[MNCH].[MNCH_Patient] 
where Nupi ='' ;