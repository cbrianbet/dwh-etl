---Ushauri_PatientAppointments
UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[Mhealth].[Mhealth_Ushauri_PatientAppointments] a
WHERE PatientPKHash IS NULL;

UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		 PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
		 NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2)
FROM [ODS].[Mhealth].[Mhealth_Ushauri_PatientAppointments] a

----End
---Ushauri_Patient
UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[Mhealth].[Mhealth_Ushauri_Patient] a
WHERE PatientPKHash IS NULL;


UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		 PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
		 NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2)
FROM [ODS].[Mhealth].[Mhealth_Ushauri_Patient] a

	UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		PatientHEI_IDHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientHEI_ID  as nvarchar(36))), 2),
		PatientMNCH_IDHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientMNCH_ID  as nvarchar(36))), 2)

FROM [ODS].[Mhealth].[Mhealth_Ushauri_HEI]  a

	UPDATE a
	SET  ReferralPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.ReferralPatientPK  as nvarchar(36))), 2)

FROM [ODS].[Mhealth].[Mhealth_FacilityReferral_Patient]  a

----End

----Ushauri_PatientLabs
UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[Mhealth].[Mhealth_mLab_PatientLab] a
WHERE PatientPKHash IS NULL;
----End
