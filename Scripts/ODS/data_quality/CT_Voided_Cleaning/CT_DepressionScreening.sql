UPDATE a
SET voided = 0
FROM [ODS].[Care].[CT_DepressionScreening] a
where rtrim(ltrim(voided))='' or voided is null