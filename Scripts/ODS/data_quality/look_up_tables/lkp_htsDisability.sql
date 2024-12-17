IF OBJECT_ID(N'[ODS].[lkp].[lkp_htsDisability]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_htsDisability];
BEGIN
            -- create table statement
	CREATE TABLE [ODS].[lkp].[lkp_htsDisability](
		source_Disability VARCHAR(100) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
		target_Disability VARCHAR(100) NOT NULL,
		DateImported DATE NOT NULL
	)
	-- insert table
	INSERT INTO [ODS].[lkp].[lkp_htsDisability](
				source_Disability,
				target_Disability,
				DateImported
	)
	VALUES          
('Blind/Visually Impaired','Visually Impaired',GETDATE()),
('Deaf/Hearing Impaired','Hearing Impaired',GETDATE()),
('Mental','Mentally Challenged',GETDATE()),
('Physically Challenged','Physically Challenged',GETDATE()),
('Blind','Visually Impaired',GETDATE()),
(' V: Visual impairment','Visually Impaired',GETDATE()),
('B','Visually Impaired',GETDATE()),
('D','Hearing Impaired',GETDATE()),
('M','Mentally Challenged',GETDATE()),
('Deaf','Hearing Impaired',GETDATE()),
('Deaf/Hearing Impaired','Hearing Impaired',GETDATE()),
('M: Mentally Challenged','Mentally Challenged',GETDATE()),
('Mentally Challenged','Mentally Challenged',GETDATE()),
('P','Physically Challenged',GETDATE()),
('H: Hearing impairment','Hearing Impaired',GETDATE()),
(' B: Blind/Visually impaired','Visually Impaired',GETDATE()),
(' D: Deaf/hearing impaired','Hearing Impaired',GETDATE()),
(' H: Hearing impairment','Hearing Impaired',GETDATE()),
(' M: Mentally Challenged','Mentally Challenged',GETDATE()),
(' P: Physically Challenged','Physically Challenged',GETDATE()),
('  Other; P: Physically Challenged','Physically Challenged',GETDATE()),
('P: Physically Challenged','Physically Challenged',GETDATE()),
(' B: Blind/Visually impaired; D: Deaf/hearing impaired',' Visually/Hearing impaired',GETDATE()),
(' P: Physically Challenged; V: Visual impairment',' Physically Challenged/Hearing Impared',GETDATE()),
(' D: Deaf/hearing impaired; M: Mentally Challenged','Hearing Impaired/Mentally Challenged',GETDATE()),
(' H: Hearing impairment; P: Physically Challenged','Hearing Impaired/Physically Challenged',GETDATE()),
(' M: Mentally Challenged; P: Physically Challenged','Mentally Challenged/Physically Challenged',GETDATE()),
('D: Deaf/hearing impaired','Hearing Impared',GETDATE()),
(' Other; P: Physically Challenged','Physically Challenged',GETDATE()),
(' H: Hearing impairment; M: Mentally Challenged','Hearing Impaired/Mentally Challenged',GETDATE()),
(' D: Deaf/hearing impaired; Other','Hearing Impaired',GETDATE()),
('O','Other',GETDATE()),
('Other','Other',GETDATE()),
('Other(Specify)','Other',GETDATE()),
('NA','NULL',GETDATE())


END