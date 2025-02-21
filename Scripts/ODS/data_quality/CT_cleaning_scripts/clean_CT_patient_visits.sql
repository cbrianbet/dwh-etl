-- clean OIDate
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET OIDate = NULL
WHERE OIDate < CAST('2000-01-01' AS DATE) OR OIDate > GETDATE()

GO

-- clean Weight
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET Weight = CAST(999 AS FLOAT)
WHERE Weight < CAST(0 AS FLOAT) OR Weight > CAST(200 AS FLOAT)

GO

-- clean Height
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET Height = CAST(999 AS FLOAT)
WHERE Height < CAST(0 AS FLOAT) OR Height > CAST(250 AS FLOAT)

GO

-- clean StabilityAssessment
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET StabilityAssessment = CASE 
                                WHEN StabilityAssessment = 'Stable1' THEN 'Stable'
                                WHEN StabilityAssessment = 'Not Stable' THEN 'Unstable'
                                WHEN StabilityAssessment COLLATE SQL_Latin1_General_CP1_CS_AS = 'stable' THEN 'Stable'
                            END
WHERE StabilityAssessment COLLATE SQL_Latin1_General_CP1_CS_AS IN ('Stable1', 'Not Stable', 'stable')

GO

-- clean Pregnant
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET Pregnant = CASE 
                        WHEN Pregnant IN ('True', 'LIVE BIRTH') THEN 'Yes'
                        WHEN Pregnant IN ('No - Miscarriage (mc)', 'No - Induced Abortion (ab)', 'RECENTLY MISCARRIAGED') THEN 'No'
                        WHEN Pregnant = 'UNKNOWN' THEN NULL
                    END
WHERE Pregnant IN ('True', 'LIVE BIRTH', 'No - Miscarriage (mc)', 'No - Induced Abortion (ab)', 'RECENTLY MISCARRIAGED', 'UNKNOWN')

GO

-- clean FamilyPlanningMethod
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET FamilyPlanningMethod = lkp_family_planning_method.target_name 
FROM [ODS].[Care].[CT_PatientVisits]AS PatientVisits
INNER JOIN [ODS].[lkp].lkp_family_planning_method ON lkp_family_planning_method.source_name = PatientVisits.FamilyPlanningMethod

GO

-- clean PwP
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET PwP = lkp_pwp.target_name
	FROM [ODS].[Care].[CT_PatientVisits]AS PatientVisits
INNER JOIN [ODS].[lkp].lkp_pwp 
	ON lkp_pwp.source_name = PatientVisits.PwP

GO

-- clean DifferentiatedCare
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET DifferentiatedCare = CASE 
                                WHEN DifferentiatedCare = 'Standard Care' THEN 'Standard Care'
                                WHEN DifferentiatedCare IN ('Express Care','Express','Fast Track care','Differentiated care model','MmasRecommendation0') THEN 'Fast Track'
                                WHEN DifferentiatedCare IN  ('Community ART Distribution_Point', 'Individual Patient ART Distribution_community', 'Community Based Dispensing', 'Community ART distribution - HCW led', 'Community_Based_Dispensing') THEN 'Community ART Distribution HCW Led'
                                WHEN DifferentiatedCare IN  ('Community ART distribution � Peer led','Community ART Distribution - Peer Led') THEN 'Community ART Distribution peer led'
                                WHEN DifferentiatedCare IN ('Facility ART Distribution Group', 'FADG') THEN 'Facility ART distribution Group'
                            END 
WHERE DifferentiatedCare IN ('Standard Care', 'Community ART Distribution_Point', 'Express Care', 'Express', 'Fast Track care', 'Differentiated care model', 'MmasRecommendation0', 
                                'Community ART Distribution_Point', 'Individual Patient ART Distribution_community', 'Community Based Dispensing', 'Community ART distribution - HCW led',
                                'Community_Based_Dispensing', 'Community ART distribution � Peer led', 'Community ART Distribution - Peer Led', 'Facility ART Distribution Group', 'FADG'
                            )

GO


-- clean VisitDate
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET VisitDate = NULL
WHERE VisitDate < CAST('1980-01-01' AS DATE) OR VisitDate > GETDATE()

GO

-- clean NextAppointmentDate
UPDATE [ODS].[Care].[CT_PatientVisits]
    SET NextAppointmentDate = NULL
WHERE NextAppointmentDate < CAST('1900-01-01' AS DATE) OR DATEDIFF(day, VisitDate, NextAppointmentDate) > 365

GO
---Clean BP values
UPDATE ods.[Care].CT_PatientVisits
SET BP = NULL
WHERE 
    BP = 'u78/,67' OR
    BP = 'S115/78' OR
    BP = 'q97/52' OR
    BP = 'n112/58' OR
    BP = 'i78/56' OR
    BP = 'I67/89' OR
    BP = '9o/80' OR
    BP = '999/999' OR
    BP =  '0/0'

Go

-- clean BP
   UPDATE [ODS].[Care].[CT_PatientVisits]
    SET BP = replace(ltrim(rtrim(BP)),'-','/')
	WHERE ltrim(rtrim(BP)) not like '%/%';

	  UPDATE [ODS].[Care].[CT_PatientVisits]
    SET BP = replace(BP,' ','')
	WHERE ltrim(rtrim(BP)) not like '%/%';

Go
