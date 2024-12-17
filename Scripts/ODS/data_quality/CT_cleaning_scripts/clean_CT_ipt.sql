-- clean TBScreening
UPDATE [ODS].[Care].[CT_Ipt]
    SET TBScreening = CASE
                                WHEN IndicationForIPT = '1' THEN 'Screened'
                                WHEN IndicationForIPT IN ('TB Screening not done', '0') THEN  'Not Screened'
                            END
WHERE TBScreening IN ('1','TB Screening not done','0')

GO

UPDATE ods.[Care].CT_IPT  SET TbScreening =  CASE  
            WHEN TbScreening ='On TB Treatment' THEN 'On TB Treatment'  
			WHEN TbScreening ='No Signs' THEN 'No Signs'
            WHEN TbScreening ='Suspect' THEN 'Presumed TB'   
            WHEN TbScreening in ('TB Confirmed','Confirmed') THEN 'TB Confirmed'            
           ELSE 'Not Done'    
                END



-- clean IndicationForIPT
UPDATE [ODS].[Care].[CT_Ipt]
    SET IndicationForIPT = CASE 
                                WHEN IndicationForIPT IN ('Adherence Issues', 'Poor adherence') THEN 'Adherence Issues'
                                WHEN IndicationForIPT = 'Client Traced back a' THEN 'Client Traced back'
                                WHEN IndicationForIPT IN ('No more drug Interru', 'Toxicity Resolved', 'Other patient decisi', 'Pregnancy', 'Patient declined', 'Other', 'High CD4', 'Education', 'Client Discharged fr') THEN 'OTHER'
                            END
WHERE IndicationForIPT IN ('Adherence Issues', 'Poor adherence', 'Client Traced back a', 'No more drug Interru', 'Toxicity Resolved', 'Other patient decisi', 'Pregnancy', 
                            'Patient declined', 'Other', 'High CD4', 'Education', 'Client Discharged fr') 

GO



