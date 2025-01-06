IF OBJECT_ID(N'[ODS].[lkp].[lkp_htsStrategy]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_htsStrategy];
BEGIN
            -- create table statement
	CREATE TABLE [ODS].[lkp].[lkp_htsStrategy](
		Source_htsStrategy VARCHAR(100) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
		Target_htsStrategy VARCHAR(100) NOT NULL,
		DateImported DATE NOT NULL
	)
	-- insert table
	INSERT INTO [ODS].[lkp].[lkp_htsStrategy](
				Source_htsStrategy,
				Target_htsStrategy,
				DateImported
	)
	VALUES          
	('NULL','NULL',GETDATE()),
('ANC','HP/PITC',GETDATE()),
('CCC','HP/PITC',GETDATE()),
('HB','Home Based Testing',GETDATE()),
('HB: Home-based','Home Based Testing',GETDATE()),
('HBTC','Home Based Testing',GETDATE()),
('Home Based Testing','Home Based Testing',GETDATE()),
('HP','HP/PITC',GETDATE()),
('HP/PITC','HP/PITC',GETDATE()),
('HP: Health Facility Patients','HP/PITC',GETDATE()),
('HTS for Non-Patient [NP]','NP: HTS for non-patients',GETDATE()),
('Integrated VCT Center','VI: Integrated VCT sites',GETDATE()),
('IPD-Adult','HP/PITC',GETDATE()),
('IPD-Child','HP/PITC',GETDATE()),
('Maternity','HP/PITC',GETDATE()),
('MCH','HP/PITC',GETDATE()),
('MO: Mobile and Outreach','MO: Mobile and outreach',GETDATE()),
('Mobile Outreach','MO: Mobile and outreach',GETDATE()),
('Mobile Outreach HTS','MO: Mobile and outreach',GETDATE()),
('Non-Provider Initiated Testing','NP: HTS for non-patients',GETDATE()),
('Not Completed','O:Other ',GETDATE()),
('NP','HTS for non-patients',GETDATE()),
('NP: Non-Patients','HTS for non-patients',GETDATE()),
('OPD','HP/PITC',GETDATE()),
('Other','Other ',GETDATE()),
('Outreach','MO: Mobile and outreach',GETDATE()),
('PeD','Other ',GETDATE()),
('PITC','HP/PITC',GETDATE()),
('PMTCT','HP/PITC',GETDATE()),
('PNS','HP/PITC',GETDATE()),
('Provider Initiated Testing(PITC)','HP/PITC',GETDATE()),
('Stand Alone VCT Center','VS: Stand Alone VCT Center',GETDATE()),
('TB','HP/PITC',GETDATE()),
('VCT','VS: Stand Alone VCT Center',GETDATE()),
('VI','VI: Integrated VCT sites',GETDATE()),
('VI: Integrated VCT sites','VI: Integrated VCT sites',GETDATE()),
('VS','VS: Stand Alone VCT Center',GETDATE()),
('VS: Stand-alone VCT sites','VS: Stand Alone VCT Center',GETDATE()),
(' ','O:Other',GETDATE()),
('NULL','O:Other',GETDATE()),
('HTS for Non-Patient','NP: HTS for non-patients',GETDATE()),
('HTS for Non-Patient[NP]','HTS for non-patients',GETDATE()),
('Non Provider Initiated Testing','HTS for non-patients',GETDATE()),
('164163','HP/PITC',GETDATE()),
('164953','NP: HTS for non-patients',GETDATE()),
('164954','VI: Integrated VCT sites',GETDATE()),
('164955','VS: Stand Alone VCT Center',GETDATE()),
('159938','Home Based Testing',GETDATE()),
('159939','MO: Mobile and outreach',GETDATE()),
('161557','Index Testing',GETDATE()),
('166606','SNS - Social Networks',GETDATE()),
('5622','O:Other',GETDATE()),
('NA','NULL',GETDATE())


END
