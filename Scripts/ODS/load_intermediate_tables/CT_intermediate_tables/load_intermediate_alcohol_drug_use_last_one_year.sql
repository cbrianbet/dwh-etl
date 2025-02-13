IF OBJECT_ID(N'[ODS].[Intermediate].[IntermediateAlcoholDrugUseLastOneYear]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[IntermediateAlcoholDrugUseLastOneYear];
BEGIN

    with drug_use as (
        select 
            PatientPKHash,
            SiteCode,
            DrugUse,
            VisitDate,
            row_number() over(partition by PatientPKHash, SiteCode order by VisitDate desc) as rank
        from ODS.Care.CT_DrugAlcoholScreening
        where DrugUse is not null and DrugUse not in ('No', 'Never', 'OTHER')
        and datediff(month, VisitDate, eomonth(dateadd(mm,-1,getdate()))) <= 12 -- get data for the last 12 months
    ),
    alcohol_use as (
        select 
            PatientPKHash,
            SiteCode,
            VisitDate,
            DrinkingAlcohol,
            row_number() over(partition by PatientPKHash, SiteCode order by VisitDate desc) as rank
        from ODS.Care.CT_DrugAlcoholScreening
        where DrinkingAlcohol is not null and DrinkingAlcohol not in ('No', 'Never', 'OTHER')
        and datediff(month, VisitDate, eomonth(dateadd(mm,-1,getdate()))) <= 12 -- get data for the last 12 months
    ),
    latest_drug_use_last_one_year as (
        select 
            *
        from drug_use
        where rank = 1
    ),
    latest_alcohol_last_one_year as (
        select 
            *
        from alcohol_use
        where rank = 1
    ),
    unioned_data as (
    select 
            PatientPKHash,
            SiteCode,
            DrugUse,
            null as DrinkingAlcohol,
            VisitDate as LatestVisitDate
    from latest_drug_use_last_one_year

    union 

    select 
            PatientPKHash,
            SiteCode,
            null as DrugUse,
            DrinkingAlcohol,
            VisitDate as LatestVisitDate
    from latest_alcohol_last_one_year
    )
    select 
        *
    into ODS.[Intermediate].[IntermediateAlcoholDrugUseLastOneYear]
    from unioned_data
END