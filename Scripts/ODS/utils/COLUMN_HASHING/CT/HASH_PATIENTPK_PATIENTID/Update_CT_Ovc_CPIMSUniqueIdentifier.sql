	update Ovc
		set CPIMSUniqueIdentifierHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Ovc.CPIMSUniqueIdentifier  as nvarchar(36))), 2)
	from [ODS].[Care].[CT_Ovc]  Ovc		
	WHERE Ovc.CPIMSUniqueIdentifierHash IS NULL;
