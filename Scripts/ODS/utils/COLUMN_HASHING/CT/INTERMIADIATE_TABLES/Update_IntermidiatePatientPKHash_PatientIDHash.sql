update ODS.[Intermediate].Intermediate_ARTOutcomes 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_BaseLineViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_EncounterHTSTests 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update ODS.[Intermediate].Intermediate_LastestPrepAssessments 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);
       
update ODS.[Intermediate].Intermediate_LastestWeightHeight 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);;

update ODS.[Intermediate].Intermediate_LastOTZVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastOVCVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastPatientEncounter 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastPatientEncounterAsAt 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastPharmacyDispenseDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastVisitAsAt 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LastVisitDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_LatestViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_OrderedViralLoads 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_PharmacyDispenseAsAtDate 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_PregnancyAsATInitiation 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_PregnancyDuringART 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);

update ODS.[Intermediate].Intermediate_PrepLastVisit 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update ODS.[Intermediate].Intermediate_ViralLoadsIntervals 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2)

update ODS.[Intermediate].intermediate_LatestObs 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);
