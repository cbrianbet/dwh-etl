IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_NCDControlledStatusLastVisit]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_NCDControlledStatusLastVisit];

with SplitDiseases as (
    select 
        distinct PatientPKHash,
        SiteCode,
        VisitDate,
        trim(value) as disease,
        /* partition to make sure the order of the piped values remain the same */
        row_number() over (partition by PatientPKHash, SiteCode, VisitDate order by (select null)) as DiseaseOrder
    from
        ODS.Care.CT_AllergiesChronicIllness as chronic
    cross apply
        STRING_SPLIT(chronic.ChronicIllness, '|') as illness
    where
        (ChronicIllness like '%Hypertension%' or ChronicIllness like '%Diabetes%')
    and voided = 0
),
SplitControlled AS (
    select 
        distinct PatientPKHash,
        SiteCode,
        VisitDate,
        trim(value) AS controlled,
        /* partition to make sure the order of the piped values remain the same */
        row_number() over (partition by PatientPKHash, SiteCode, VisitDate order by (select null)) AS ControlledOrder
    from 
        ODS.Care.CT_AllergiesChronicIllness as chronic
    cross apply
        STRING_SPLIT(chronic.Controlled, '|') as controlled
    WHERE
        (ChronicIllness like '%Hypertension%' or ChronicIllness like '%Diabetes%')
    and voided = 0
),
final_data as (
 select 
     distinct SplitDiseases.PatientPKHash,
     SplitDiseases.SiteCode,
     SplitDiseases.VisitDate,
     row_number() over (partition by SplitDiseases.PatientPKHash, SplitDiseases.SiteCode, SplitDiseases.disease order by SplitDiseases.VisitDate desc) as VisitRank, 
     disease as Disease,
     controlled as Controlled
from SplitDiseases as SplitDiseases
inner join SplitControlled as SplitControlled on SplitDiseases.DiseaseOrder = SplitControlled.ControlledOrder
    and SplitDiseases.PatientPKHash = SplitControlled.PatientPKHash
    and SplitDiseases.SiteCode = SplitControlled.SiteCode
    and SplitDiseases.VisitDate = SplitControlled.VisitDate
where disease in ('Diabetes', 'Hypertension')
)
select 
    final_data.*,
    cast(getdate() as date) as LoadDate
into ODS.[Intermediate].Intermediate_NCDControlledStatusLastVisit
from final_data
where VisitRank = 1