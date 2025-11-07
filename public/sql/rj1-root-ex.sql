DECLARE @json NVARCHAR(MAX) = N'{
    "SalesReps": [
        {
            "SalesRep": "Mark Dodson",
            "UserID": 35,
            "sa": [
                {
                    "DocumentDate": "2025-10-09T00:00:00",
                    "LastSaleLine": 684.8
                }
            ]
        },
        {
            "SalesRep": "Cody Bartlett",
            "UserID": 43,
            "sa": [
                {
                    "DocumentDate": "2025-10-09T00:00:00",
                    "LastSaleLine": 4080
                }
            ]
        }
    ]
}';
/* Example with JSON_VALUE */
SELECT ​
    JSON_VALUE(sr.value, '$.SalesRep') AS SalesRep,
    JSON_VALUE(sr.value, '$.UserID') AS UserID,
    JSON_VALUE(sa.value, '$.DocumentDate') AS DocumentDate,
    JSON_VALUE(sa.value, '$.LastSaleLine') AS LastSaleLine
FROM OPENJSON(@json, '$.SalesReps') AS sr
CROSS APPLY OPENJSON(sr.value, '$.sa') AS sa;
/* Example with OPENJSON and WITH clause */
SELECT ​
      sr.SalesRep
    , sr.UserID
    , sa.DocumentDate
    , sa.LastSaleLine
FROM OPENJSON(@json, '$.SalesReps')
WITH (SalesRep NVARCHAR(100) '$.SalesRep', UserID INT '$.UserID', sa NVARCHAR(MAX) '$.sa' AS JSON) AS sr
CROSS APPLY OPENJSON(sr.sa) WITH(DocumentDate DATETIME '$.DocumentDate', LastSaleLine DECIMAL(10, 2) '$.LastSaleLine') AS sa;