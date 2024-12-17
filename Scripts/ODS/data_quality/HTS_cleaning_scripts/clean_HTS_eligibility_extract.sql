--clean WeightLoss
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET WeightLoss = CASE WeightLoss
                        WHEN '0' THEN 'No'
                        WHEN '1' THEN 'Yes'
                    END
WHERE WeightLoss in ('0', '1')

GO

-- clean NightSweats
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET NightSweats = CASE NightSweats
                        WHEN '0' THEN 'No'
                        WHEN '1' THEN 'Yes'
                    END
WHERE NightSweats in ('0', '1')

GO

-- clean Fever
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET Fever = CASE NightSweats
                    WHEN '0' THEN 'No'
                    WHEN '1' THEN 'Yes'
                END
WHERE Fever in ('0', '1')

GO

-- clean DateTestedProvider
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET DateTestedProvider = NULL
WHERE DateTestedProvider < CAST('1980-01-01' AS DATE)

GO

-- clean Cough
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET Cough = CASE Cough
                        WHEN '0' THEN 'No'
                        WHEN '1' THEN 'Yes'
                END
WHERE Cough in ('0', '1')

GO

-- clean Pregnant
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET Pregnant = CASE Pregnant
                        WHEN '0' THEN 'No'
                        WHEN '1' THEN 'Yes'
                    END
WHERE Pregnant in ('0', '1')

GO
-- clean IsHealthWorker
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET IsHealthWorker = CASE IsHealthWorker
                            WHEN '0' THEN 'No'
                            WHEN '1' THEN 'Yes'
                        END
WHERE IsHealthWorker in ('0', '1')

GO

-- clean PatientType
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET PatientType = CASE PatientType
                        WHEN 'HP:Hospital Patient' THEN 'Hospital Patient'
                        WHEN 'NP:Non-Hospital Patient' THEN 'Non-Hospital Patient'
                    END
WHERE PatientType in ('HP:Hospital Patient', 'NP:Non-Hospital Patient')

GO

-- clean VisitDate
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET VisitDate = NULL
WHERE VisitDate < CAST('2019-01-01' AS DATE)

GO

--clean TracingOutcome
--UPDATE ODS.dbo.HTS_EligibilityExtract
--    SET TracingOutcome = 'Contacted and Not Linked'  column doesn't exit
--WHERE TracingOutcome IN ('Contacted but not linked')

GO

-- clean TypeGBV
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET TypeGBV = NULL
WHERE TypeGBV = ''
GO

-- clean ReceivedServices
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET ReceivedServices = NULL
WHERE ReceivedServices = ''

-- clean ResultOfHIVSelf
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET ResultOfHIVSelf = NULL
WHERE ResultOfHIVSelf = ''


--clean ReasonsForIneligibility
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET ReasonsForIneligibility = NULL
WHERE ReasonsForIneligibility = ''

-- clean ChildReasonsForIneligibility
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET ChildReasonsForIneligibility = NULL
WHERE ChildReasonsForIneligibility = ''

-- clean Pregnant
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET Pregnant = CASE Pregnant
                        WHEN '0' THEN 'No'
                        WHEN '1' THEN 'Yes'
                    END
WHERE Pregnant in ('0', '1')


-- clean PartnerHIVStatus
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET PartnerHIVStatus = NULL
WHERE PartnerHIVStatus = ''

-- clean RelationshipWithContact
UPDATE ODS.[HTS].HTS_EligibilityExtract
    SET RelationshipWithContact = NULL
WHERE RelationshipWithContact = ''