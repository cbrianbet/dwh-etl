/* Update of the PatientPK from the mnch_HEIs.This are for the patients who are in ushauri and have been
registered in the EMR. There seem to be no match. Need to know the link from the mhealth team  */

UPDATE a
    SET a.PatientPK = null,a.PatientPKHash =null
FROM [ODS].[dbo].[Ushauri_HEI] a;

--Lanyo to advice on the leankage between Ushauri Hei and MNCH_Heis
--UPDATE a
    --SET a.PatientPK = p.PatientPK
--FROM [ODS].[dbo].[Ushauri_HEI] a
   -- JOIN ods.dbo.MNCH_HEIs p
--ON  a.sitecode = p.sitecode AND a.UshauriPatientPK = p.PatientPk;