-- clean DateLastUsedPrev
UPDATE ODS.PrEP.PrEP_Patient
    SET DateLastUsedPrev = NULL
WHERE DateLastUsedPrev = ''

GO

-- clean PrevPrepReg
UPDATE ODS.PrEP.PrEP_Patient
    SET PrevPrepReg = NULL
WHERE PrevPrepReg = ''

GO

--clean ClientPreviouslyonPrep
UPDATE ODS.PrEP.PrEP_Patient
    SET ClientPreviouslyonPrep = NULL
WHERE ClientPreviouslyonPrep = ''

GO

-- clean DateStartedPrEPattransferringfacility
UPDATE ODS.PrEP.PrEP_Patient
    SET DateStartedPrEPattransferringfacility = NULL
WHERE DateStartedPrEPattransferringfacility = ''

GO


-- clean TransferFromFacility
UPDATE ODS.PrEP.PrEP_Patient
    SET TransferFromFacility = NULL
WHERE TransferFromFacility = ''

GO

-- clean TransferInDate
UPDATE ODS.PrEP.PrEP_Patient
    SET TransferInDate = NULL
WHERE TransferInDate = ''

GO


-- clean Refferedfrom
UPDATE ODS.PrEP.PrEP_Patient
    SET Refferedfrom = NULL
WHERE Refferedfrom = ''

GO

-- clean KeyPopulationType
UPDATE ODS.PrEP.PrEP_Patient
    SET KeyPopulationType = CASE KeyPopulationType
                                WHEN '160579' THEN 'FSW'
                                WHEN '160578' THEN 'MSM'
                                WHEN '165084' THEN 'MSW'
                                WHEN '105' then 'PWID'
                            END 
WHERE KeyPopulationType IN ('160579', '160578','165084', '105')

GO

-- clean PopulationType
UPDATE ODS.PrEP.PrEP_Patient
    SET PopulationType = NULL
WHERE PopulationType = ''

GO

-- clean Inschool
UPDATE ODS.PrEP.PrEP_Patient
    SET Inschool = CASE Inschool
                    WHEN '1' THEN 'Yes'
                    WHEN '2' THEN 'No'
                END
WHERE Inschool IN ('1', '2')


-- clean MaritalStatus
UPDATE ODS.PrEP.PrEP_Patient
    SET MaritalStatus = CASE MaritalStatus
                            WHEN 'Married' THEN  'Married Monogamous'
                            WHEN 'Never married' THEN 'Single'
                            WHEN 'Living with partner' THEN 'Cohabiting'
                            WHEN  'Polygamous' THEN 'Married Polygamous'
                            WHEN 'OTHER NON-CODED' THEN 'Unknown'
                            WHEN 'Separated' THEN 'Divorced'
                        END 
WHERE MaritalStatus IN ('Married', 'Never married', 'Living with partner', 'Polygamous', 'OTHER NON-CODED', 'Separated')

-- clean ReferralPoint
UPDATE ODS.PrEP.PrEP_Patient
    SET ReferralPoint = NULL
WHERE ReferralPoint = ''

GO

-- clean ClientType
UPDATE ODS.PrEP.PrEP_Patient
    SET ClientType = NULL
WHERE ClientType = ''

GO

-- clean Ward
UPDATE ODS.PrEP.PrEP_Patient
    SET Ward = NULL
WHERE Ward = ''

GO

-- clean LandMark
UPDATE ODS.PrEP.PrEP_Patient
    SET LandMark = NULL
WHERE LandMark = ''

GO

-- clean Location
UPDATE ODS.PrEP.PrEP_Patient
    SET LandMark = NULL
WHERE Location = ''

GO

-- clean SubCounty
UPDATE ODS.PrEP.PrEP_Patient
    SET SubCounty = NULL
WHERE SubCounty = ''

GO

-- clean County
UPDATE ODS.PrEP.PrEP_Patient
    SET County = CASE 
                    WHEN County IN ('THARAKA - NITHI', 'Tharaka-Nithi') THEN 'Tharaka Nithi'
                    WHEN County IN ('North Alego', 'West Sakwa', 'Ugunja', 'North Ugenya', 'Ugenya West', 'Ukwala', 'West Alego') THEN 'Siaya'
                    WHEN County IN ('Kabuoch South/Pala', 'Gwassi North', 'Homa Bay Arunjo', 'HOMABAY', 'Kendu Bay Town', 'Kwabwai', 'Homa Bay East') THEN 'Homa Bay'
                    WHEN County IN ('Kakrao') THEN 'Migori'
                    WHEN County IN ('Kamahuha', 'Kambiti', 'Nginda', 'Muranga') THEN 'Murang''a'
                    WHEN County IN ('KIAMBU''') THEN  'Kiambu'
                    WHEN County IN ('Majoge') THEN 'Kisii'
                    WHEN County IN ('Nangina') THEN 'Busia'
                    WHEN County IN ('Shamata') THEN 'Nyandarua'
                    WHEN County IN ('Kagen') THEN 'NOT DOCUMENTED'
                    WHEN County IN ('...') THEN 'NOT DOCUMENTED'
                    WHEN County IN ('') THEN NULL
                 END
WHERE County IN ('THARAKA - NITHI', 'Tharaka-Nithi', 'North Alego', 'West Sakwa', 
'Ugunja', 'North Ugenya', 'Ugenya West', 'Ukwala', 'West Alego', 'Kabuoch South/Pala', 'Gwassi North',
 'Homa Bay Arunjo', 'HOMABAY', 'Kendu Bay Town', 'Kwabwai', 'Homa Bay East', 'Kakrao', 
 'Kamahuha', 'Kambiti', 'Nginda', 'Muranga', 'KIAMBU''', 'Majoge', 'Nangina', 'Shamata', 'Kagen', '...', '')

-- clean CountyofBirth
UPDATE ODS.PrEP.PrEP_Patient
    SET CountyofBirth = NULL
WHERE CountyofBirth = ''

GO

-- clean Sex
UPDATE ODS.PrEP.PrEP_Patient
    SET Sex = NULL
WHERE Sex = ''

GO

UPDATE a
    SET Voided = 0             
    from ODS.PrEP.PrEP_Patient a
WHERE Voided is null
GO

