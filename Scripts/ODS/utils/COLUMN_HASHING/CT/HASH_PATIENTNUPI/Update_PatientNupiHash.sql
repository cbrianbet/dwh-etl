

UPDATE ODS.Care.CT_Patient 
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM ODS.Care.CT_Patient 
where NupiHash is null;

UPDATE ODS.Care.CT_Patient 
	set NupiHash = ''
FROM ODS.Care.CT_Patient 
where Nupi ='';