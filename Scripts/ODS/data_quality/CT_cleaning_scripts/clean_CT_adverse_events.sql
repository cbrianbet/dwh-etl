-- clean AdverseEvent
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEvent = lkp_adverse_events.target_name
FROM [ODS].[Care].[CT_AdverseEvents] AS adverse_events
INNER JOIN ods.lkp.lkp_adverse_events ON lkp_adverse_events.source_name = adverse_events.AdverseEvent

GO

-- clean AdverseEventStartDate
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventStartDate = NULL
WHERE AdverseEventStartDate < CAST('1980-01-01' AS DATE) OR AdverseEventStartDate > GETDATE()

-- clean AdverseEventEndDate
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventEndDate = NULL
WHERE AdverseEventEndDate < CAST('1980-01-01' AS DATE) OR AdverseEventEndDate > GETDATE()

GO

-- clean Severity
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET Severity = CASE 
                    WHEN Severity IN ('Mild', 'Mild|Mild|Mild') THEN 'Mild'
                    WHEN Severity IN ('Moderate',  'Moderate|Moderate', 'Moderate|Moderate|Moderate') THEN 'Moderate'
                    WHEN Severity IN ('Severe', 'Fatal', 'Severe|Severe', 'Severe|Severe|Severe') THEN 'Severe'
                    WHEN Severity IN ('Mild|Moderate', 'Moderate|Mild', 'Severe|Moderate', 'Unknown|Moderate', 'Moderate|Severe') THEN 'Unknown'
                  END
WHERE Severity IN ('Moderate','Mild','Severe','Mild|Moderate','Fatal','Severe|Severe','Moderate|Moderate','Moderate|Mild','Severe|Moderate','Mild|Mild|Mild','Unknown|Moderate','Severe|Severe|Severe','Moderate|Moderate|Moderate','Moderate|Severe')
GO

-- clean AdverseEventRegimen
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventRegimen = lkp_regimen.target_name
FROM [ODS].[Care].[CT_AdverseEvents] AS adverse_events
INNER JOIN ods.lkp.lkp_regimen ON lkp_regimen.source_name = adverse_events.AdverseEventRegimen

GO


-- clean AdverseEventActionTaken
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventActionTaken = CASE 
                                    WHEN AdverseEventActionTaken IN ('Medicine not changed', 'CONTINUE REGIMEN', 'CONTINUE REGIMEN|CONTINUE REGIMEN') THEN 'Drug not Changed'
                                    WHEN AdverseEventActionTaken = 'Dose reduced' THEN 'Drug Reduced'
                                    WHEN AdverseEventActionTaken = 'SUBSTITUTED DRUG' THEN 'Drug Substituted'
                                    WHEN AdverseEventActionTaken IN ('Medicine causing AE substituted/withdrawn','STOP','STOP|STOP','All drugs stopped','STOP|STOP|STOP','Other|STOP','NONE|STOP')  THEN 'Drug Withdrawn'
                                    WHEN AdverseEventActionTaken IN ('Other','NONE','Select','SUBSTITUTED DRUG|STOP','Other|Other') THEN 'OTHER'
                                    WHEN AdverseEventActionTaken = 'SWITCHED REGIMEN' THEN 'Regimen Switched'
                                END
WHERE AdverseEventActionTaken IN ('SUBSTITUTED DRUG','Medicine causing AE substituted/withdrawn','Medicine not changed','STOP','Other','SWITCHED REGIMEN','CONTINUE REGIMEN','STOP|STOP','NONE','Dose reduced','Select','CHANGED DOSE','All drugs stopped','CONTINUE REGIMEN|CONTINUE REGIMEN','STOP|STOP|STOP','Other|STOP','NONE|STOP','SUBSTITUTED DRUG|STOP','Other|Other')

GO

--- clean AdverseEventCause
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventCause = CASE 
                                WHEN AdverseEventCause IN ('3TC/D4T','3TC/TDF/NVP','ABACAVIR','abacavirwhen she was using','ABC','ABC+3TC','abc/3tc/efv','AF2B','af2b- avonza','ALL ARV','ALUVIA','art','ARV','arvs','atanzanavir','atavanavir','ataz/rit','atazanavir','Atazanavir/Rironavir','atazanavir/ritonavir','ATV','ATV/r','ATVr','AZT','AZT+3TC+EFV','AZT/3TC/NVP','AZT/ATV','AZT/KALETRA','ctx/3tc/tdf/efv','D4T','D4T / 3TC / NVP','D4T/3TC','D4T/AZT','DDI','Dolotegravir','doluteglavir','dolutegravir','DTG','DTG Aurobindo','dultegravir','EFARIRENZ','EFAVIRENCE','Efavirens','efavirenz','efavirenze','efavirez','efervirence','efervirenz','efevurence','EFV','EFV 600MG','EFV/NVP','efv/rhze','HAART','KALETRA','lopinanavir','LOPINAVIR','LPV','LPV/r','lpvr','NVP','NVP/ABC','pep','TDF','tdf dtg','TDF/3TC/','tdf/3tc/dtg','tdf/3tc/efv','Tenoforvir','tenofovir','TLD','TLE ','TLE 400','TRIMUNE','ZIDOVUDINE','EFV','? NVP','? TLD','?ATV/r','3TC','3TC/3TC', 'D4T', 'EFAVIRENZ') THEN 'ARV'
                                WHEN AdverseEventCause IN ('ART/TB', 'ARVS, CTX , IPT', 'CTX OR EFV', 'D4T/INH', 'INH/NVP', 'isoniazid and nevirapine', 'isoniazid efavirenz', 'NVP/CTX', 'tdf dtg ctx 3tc', 'inh, tdf,3tc,dtg, ctx') THEN 'ARV + OTHER DRUGS'
                                WHEN AdverseEventCause IN ('ANT TB','ANTI TB','anti TBs','ANTI-TB','Co-trimoxazole','CONTRIMAZOLE','cotrimoxasole','cotrimoxazole','cotrimoxazole 960mg','Cotrimoxazole-','CTX','CTX /ANTI TB','Dapson','fluconazole','IHN','INH','INH (IPT)','INH/CTX','IPT','ipt in 2016','ipt side effect ','IRIS','Isiniazid','isiniazide','isonaizid','isoniaizid','isoniasid','isoniazid','Isoniazid - November 2017','isoniazide','isoniazin','isonizid','Isonizide and Pyridoxine','IZONIAZID','IZONIAZIDE','pyrazinamid','pyrazinamide','PYRIDOXINE','RH','RHE','RHZE','septin','SEPTRIN','septrine','Streptomycin','sulfa','sulphonamides','SULPHONOMIDES','SULPHUR','TB','TB DRUGS','tb meds','2RHZ/4RH(children)','2RHZE/10RH','2RHZE/4RH','2SRHZE/1RHZE/', 'INH, SEPTRIN') THEN 'NON-ARVS'
                                ELSE 'UNSPECIFIED' 
                            END

GO

-- clean AdverseEventClinicalOutcome
UPDATE [ODS].[Care].[CT_AdverseEvents]
    SET AdverseEventClinicalOutcome = CASE
                                        WHEN AdverseEventClinicalOutcome = 'Recovered/Resolved' THEN 'Recovered'
                                        WHEN AdverseEventClinicalOutcome = 'Recovering/Resolving' THEN 'Recovering'
                                        WHEN AdverseEventClinicalOutcome = 'Requires intervention to prevent permanent damage' THEN 'OTHER' 
                                    END
WHERE AdverseEventClinicalOutcome IN ('Recovered/Resolved', 'Recovering/Resolving', 'Requires intervention to prevent permanent damage')  
                                   
GO
