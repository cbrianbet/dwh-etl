-- clean ContactAge
UPDATE [ODS].[DBO].[CT_ContactListing]
    SET ContactAge = 999
WHERE ContactAge < 0 OR ContactAge > 120

GO


-- clean ContactSex
UPDATE [ODS].[DBO].[CT_ContactListing]
    SET ContactSex = CASE 
                        WHEN ContactSex = 'U' THEN 'Undefined'
                        WHEN ContactSex = 'M' THEN 'Male'
                        WHEN ContactSex = 'F' THEN 'Female'
                    END
WHERE ContactSex IN ('U', 'M', 'F')

GO

-- clean RelationshipWithPatient
UPDATE [ODS].[DBO].[CT_ContactListing]
    SET RelationshipWithPatient = CASE 
                                    WHEN RelationshipWithPatient IN ('Daughter', 'Son') THEN 'Child'
                                    WHEN RelationshipWithPatient = 'Co-wife' THEN 'Sexual Partner'
                                    WHEN RelationshipWithPatient = 'Select' THEN 'OTHER'
                                    WHEN RelationshipWithPatient IN ('undefined', 'None') THEN 'Undefined'
                                    WHEN RelationshipWithPatient = 'Nice' THEN 'Niece'
                                END
WHERE RelationshipWithPatient IN ('Daughter', 'Son', 'Co-wife', 'Select', 'undefined', 'None', 'Niece')

GO


-- clean IPVScreeningOutcome
UPDATE [ODS].[DBO].[CT_ContactListing]
    SET IPVScreeningOutcome = CASE 
                                WHEN IPVScreeningOutcome = '0' THEN 'False'
                                WHEN IPVScreeningOutcome = 'No' THEN 'False'
                                WHEN IPVScreeningOutcome = 'Yes' THEN 'True'
                                WHEN IPVScreeningOutcome  IN ('1065', '1066') THEN 'OTHER'
                            END
 WHERE IPVScreeningOutcome IN ('0', 'No', 'Yes', '1065', '1066')

 GO


