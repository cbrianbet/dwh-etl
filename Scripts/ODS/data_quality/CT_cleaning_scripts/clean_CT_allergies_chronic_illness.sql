-- clean ChronicOnsetDate
UPDATE [ODS].[Care].[CT_AllergiesChronicIllness] 
    SET ChronicOnsetDate = NULL
WHERE ChronicOnsetDate < CAST('1900-01-01' AS nvarchar(50)) --ChronicOnsetDate is not longer a date column

GO

-- clean AllergyCausativeAgent
UPDATE [ODS].[Care].[CT_AllergiesChronicIllness] 
    SET AllergyCausativeAgent = lkp_allergy_causative_agent.target_name
FROM [ODS].[Care].[CT_AllergiesChronicIllness] AS allergies_chronic_illness
INNER JOIN ods.lkp.lkp_allergy_causative_agent ON lkp_allergy_causative_agent.source_name = allergies_chronic_illness.AllergyCausativeAgent

GO


-- clean AllergicReaction
UPDATE [ODS].[Care].[CT_AllergiesChronicIllness] 
    SET AllergicReaction = lkp_allergic_reaction.target_name
FROM [ODS].[Care].[CT_AllergiesChronicIllness] AS allergies_chronic_illness
INNER JOIN ods.lkp.lkp_allergic_reaction ON lkp_allergic_reaction.source_name = allergies_chronic_illness.AllergicReaction

GO


-- clean AllergySeverity
UPDATE [ODS].[Care].[CT_AllergiesChronicIllness] 
    SET AllergySeverity = CASE 
                            WHEN AllergySeverity = 'Fatal' THEN 'Fatal'
                            WHEN AllergySeverity IN ('Mild|Mild|Mild', 'Mild|Mild', 'Mild') THEN 'Mild'
                            WHEN AllergySeverity IN ('Moderate|Moderate', 'Moderate') THEN 'Moderate'
                            WHEN AllergySeverity = 'Severe' THEN 'Severe'
                            WHEN AllergySeverity IN ('Unknown', 'Moderate|Mild') THEN 'Unknown'
                        END
WHERE AllergySeverity IN ('Fatal', 'Mild|Mild|Mild', 'Mild|Mild', 'Mild', 'Moderate|Moderate', 'Moderate', 'Severe', 'Unknown', 'Moderate|Mild')

GO