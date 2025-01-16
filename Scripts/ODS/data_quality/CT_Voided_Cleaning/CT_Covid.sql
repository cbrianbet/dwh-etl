UPDATE a
SET voided = 0
FROM [ODS].[Care].[CT_Covid] a
where rtrim(ltrim(voided))='' or voided is null