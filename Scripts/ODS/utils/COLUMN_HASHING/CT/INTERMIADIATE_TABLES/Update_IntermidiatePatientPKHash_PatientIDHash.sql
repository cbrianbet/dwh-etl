update ODS.dbo.Intermediate_ARTOutcomes 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_BaseLineViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_EncounterHTSTests 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update ODS.dbo.Intermediate_LastestPrepAssessments 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);
       
update ODS.dbo.Intermediate_LastestWeightHeight 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);;

update ODS.dbo.Intermediate_LastOTZVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastOVCVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastPatientEncounter 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastPatientEncounterAsAt 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastPharmacyDispenseDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastVisitAsAt 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LastVisitDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_LatestViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_OrderedViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_PharmacyDispenseAsAtDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_PregnancyAsATInitiation 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_PregnancyDuringART 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.dbo.Intermediate_PrepLastVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update ODS.dbo.Intermediate_ViralLoadsIntervals 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2)

update ODS.dbo.intermediate_LatestObs 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);
