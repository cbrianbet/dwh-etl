-- clean DrinkingAlcohol
UPDATE [ODS].[Care].[CT_DrugAlcoholScreening]
    SET DrinkingAlcohol = CASE 
                            WHEN DrinkingAlcohol = 'No' THEN 'Never'
                            WHEN DrinkingAlcohol = 'Yes' THEN 'OTHER'
                        END
WHERE DrinkingAlcohol IN ('No', 'Yes')

GO

-- clean Smoking
UPDATE [ODS].[Care].[CT_DrugAlcoholScreening]
    SET Smoking = CASE
                    WHEN Smoking = 'No' THEN 'Never smoked'
                    WHEN Smoking = 'Yes' THEN 'OTHER'
                END
WHERE Smoking IN ('No', 'Yes')

GO