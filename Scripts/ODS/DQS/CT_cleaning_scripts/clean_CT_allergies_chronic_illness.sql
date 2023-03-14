-- clean ChronicIllness
UPDATE [ODS].[DBO].[CT_AllergiesChronicIllness] 
    SET ChronicIllness = lkp_chronic_illness.target_name
FROM [ODS].[DBO].[CT_AllergiesChronicIllness] AS allergies_chronic_illness
INNER JOIN lkp_chronic_illness ON lkp_chronic_illness.source_name = allergies_chronic_illness.ChronicIllness

GO

-- clean ChronicOnsetDate
UPDATE [ODS].[DBO].[CT_AllergiesChronicIllness] 
    SET ChronicOnsetDate = CAST('1900-01-01' AS DATE)
WHERE ChronicOnsetDate < CAST('1900-01-01' AS DATE) OR ChronicOnsetDate > GETDATE()

GO

-- clean AllergyCausativeAgent
UPDATE [ODS].[DBO].[CT_AllergiesChronicIllness] 
    SET AllergyCausativeAgent = lkp_allergy_causative_agent.target_name
FROM [ODS].[DBO].[CT_AllergiesChronicIllness] AS allergies_chronic_illness
INNER JOIN lkp_allergy_causative_agent ON lkp_allergy_causative_agent.source_name = allergies_chronic_illness.AllergyCausativeAgent

GO


-- clean AllergicReaction
UPDATE [ODS].[DBO].[CT_AllergiesChronicIllness] 
    SET AllergicReaction = lkp_allergic_reaction.target_name
FROM [ODS].[DBO].[CT_AllergiesChronicIllness] AS allergies_chronic_illness
INNER JOIN lkp_allergic_reaction ON lkp_allergic_reaction.source_name = allergies_chronic_illness.AllergicReaction

GO


-- clean AllergySeverity
UPDATE [ODS].[DBO].[CT_AllergiesChronicIllness] 
    SET AllergySeverity = CASE 
                            WHEN AllergySeverity = 'Fatal' THEN 'Fatal'
                            WHEN AllergySeverity IN ('Mild|Mild|Mild', 'Mild|Mild', 'Mild') THEN 'Mild'
                            WHEN AllergySeverity IN ('Moderate|Moderate', 'Moderate') THEN 'Moderate'
                            WHEN AllergySeverity = 'Severe' THEN 'Severe'
                            WHEN AllergySeverity IN ('Unknown', 'Moderate|Mild') THEN 'Unknown'
                        END
WHERE AllergySeverity IN ('Fatal', 'Mild|Mild|Mild', 'Mild|Mild', 'Mild', 'Moderate|Moderate', 'Moderate', 'Severe', 'Unknown', 'Moderate|Mild')

GO