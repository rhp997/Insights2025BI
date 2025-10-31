-- WITHOUT_ARRAY_WRAPPER will return a single object instead of an array if only one row is returned
/*
[
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
-- FOR JSON AUTO creates a nested array for the main (not joined) table (sa)
SELECT TOP(1) WITH TIES
      sr.Name [SalesRep]
    , sr.UserID
    , sa.DocumentDate
    , sa.TotalSales [LastSaleLine]
FROM SalesAnalysis3 sa WITH(NOLOCK)
INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
WHERE sr.Deleted = 0
AND sa.TotalSales <> 0
AND sa.DocumentType = 'Invoice'
AND sa.SalesRepID IN (27, 18)
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON AUTO
*/

/*
{
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
}
-- Adding ROOT('SalesReps') wraps the result in a top level array; the outer array brackets are removed
SELECT TOP(1) WITH TIES
      sr.Name [SalesRep]
    , sr.UserID
    , sa.DocumentDate
    , sa.TotalSales [LastSaleLine]
FROM SalesAnalysis3 sa WITH(NOLOCK)
INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
WHERE sr.Deleted = 0
AND sa.TotalSales <> 0
AND sa.DocumentType = 'Invoice'
AND sa.SalesRepID IN (27, 18)
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON AUTO, ROOT('SalesReps')
*/

/*
[
    {
        "SalesRep": "Mark Dodson",
        "UserID": 35,
        "DocumentDate": "2025-10-09T00:00:00",
        "LastSaleLine": 684.8
    },
    {
        "SalesRep": "Cody Bartlett",
        "UserID": 43,
        "DocumentDate": "2025-10-09T00:00:00",
        "LastSaleLine": 4080
    }
]
-- FOR JSON PATH removes the nested array (sa) for a flat structure
SELECT TOP(1) WITH TIES
      sr.Name AS SalesRep
    , sr.UserID
    , sa.DocumentDate
    , sa.TotalSales AS LastSaleLine
FROM SalesAnalysis3 sa WITH(NOLOCK)
INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
WHERE sr.Deleted = 0
AND sa.TotalSales <> 0
AND sa.DocumentType = 'Invoice'
AND sa.SalesRepID IN (27, 18)
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH
*/
/*
[
    {
        "SalesRep": {
            "SalesRep": "Mark Dodson",
            "UserID": 35
        },
        "Sales": {
            "DocumentDate": "2025-10-09T00:00:00",
            "LastSaleLine": 684.8
        }
    },
    {
        "SalesRep": {
            "SalesRep": "Cody Bartlett",
            "UserID": 43
        },
        "Sales": {
            "DocumentDate": "2025-10-09T00:00:00",
            "LastSaleLine": 4080
        }
    }
]
-- Use aliases with FOR JSON PATH and dot notation to create nested objects (SalesRep and Sales)
SELECT TOP(1) WITH TIES
      sr.Name AS [SalesRep.SalesRep]
    , sr.UserID AS [SalesRep.UserID]
    , sa.DocumentDate AS [Sales.DocumentDate]
    , sa.TotalSales AS [Sales.LastSaleLine]
FROM SalesAnalysis3 sa WITH(NOLOCK)
INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
WHERE sr.Deleted = 0
AND sa.TotalSales <> 0
AND sa.DocumentType = 'Invoice'
AND sa.SalesRepID IN (27, 18)
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH
*/
/*
[
    {
        "SalesRepInfo": [
            {
                "SalesRep": "Mark Dodson",
                "UserID": 35
            }
        ],
        "DocumentDate": "2025-10-09T00:00:00",
        "LastSaleLine": 684.8
    },
    {
        "SalesRepInfo": [
            {
                "SalesRep": "Cody Bartlett",
                "UserID": 43
            }
        ],
        "DocumentDate": "2025-10-09T00:00:00",
        "LastSaleLine": 4080
    }
]
-- Using a subquery with FOR JSON PATH to create a nested object (SalesRepInfo)
SELECT TOP(1) WITH TIES
      (SELECT
            sr.Name AS SalesRep
          , sr.UserID
        FROM SalesRep sr WITH(NOLOCK)
        WHERE sr.SalesRepID = sa.SalesRepID
        FOR JSON PATH) AS SalesRepInfo
    , sa.DocumentDate
    , sa.TotalSales AS LastSaleLine
FROM SalesAnalysis3 sa WITH(NOLOCK)
INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
WHERE sr.Deleted = 0
AND sa.TotalSales <> 0
AND sa.DocumentType = 'Invoice'
AND sa.SalesRepID IN (27, 18)
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH
*/

-- TODO: Add examples with metadata
-- TODO: Add examples with values as keys

/*
[
    {
        "MetaData": [
            {
                "UserID": 1,
                "CurDateTime": "2025-10-13T15:01:28.903"
            }
        ],
        "SalesInfo": [
            {
                "SalesRep": "Mark Dodson",
                "SalesUserID": 35,
                "DocumentDate": "2025-10-10T00:00:00",
                "LastSaleLine": 3200
            },
            {
                "SalesRep": "Cody Bartlett",
                "SalesUserID": 43,
                "DocumentDate": "2025-10-10T00:00:00",
                "LastSaleLine": 864.96
            }
        ]
    }
] */
/*
SELECT -- Without FOR JSON PATH, this would return two JSON cols
      MD.MetaDataJSON AS [MetaData]
    , SI.SalesJSON AS [SalesInfo]
FROM
( -- Metadata subquery in one column
    SELECT
        1 AS [UserID]
        , GETDATE() AS [CurDateTime]
    FOR JSON PATH
) AS MD(MetaDataJSON) CROSS JOIN
( -- Sales info subquery in another column
    SELECT TOP(1) WITH TIES
        sr.Name AS [SalesRep]
        , sr.UserID AS [SalesUserID]
        , sa.DocumentDate AS [DocumentDate]
        , sa.TotalSales AS [LastSaleLine]
    FROM SalesAnalysis3 sa WITH(NOLOCK)
    INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
    WHERE sr.Deleted = 0
    AND sa.TotalSales <> 0
    AND sa.DocumentType = 'Invoice'
    AND sa.SalesRepID IN (27, 18)
    ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
    FOR JSON PATH
) AS SI(SalesJSON)
FOR JSON PATH

; WITH myCTE AS (
    SELECT -- Use SalesRep as key with subquery and FOR JSON PATH as the value
        CONCAT('{', '"', p.SalesRep, '"', ':', (
            SELECT p.SalesRepID, p.SalesUserID, p.DocumentDate, p.LastSaleLine
            FROM SalesRep sr WHERE sr.SalesRepID = p.SalesRepID
            FOR JSON PATH), '}') AS JSONResult
    FROM (
        SELECT TOP(1) WITH TIES
              sr.SalesRepID
            , sr.Name AS [SalesRep]
            , sr.UserID AS [SalesUserID]
            , sa.DocumentDate AS [DocumentDate]
            , sa.TotalSales AS [LastSaleLine]
        FROM SalesAnalysis3 sa WITH(NOLOCK)
        INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
        WHERE sr.Deleted = 0
        AND sa.TotalSales <> 0
        AND sa.DocumentType = 'Invoice'
        AND sa.SalesRepID IN (27, 18)
        ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
    ) p
) -- Aggregate the rows into a single JSON object using a comma separator
SELECT FORMATMESSAGE('[%s]', STRING_AGG(JSONResult,',')) [FinalJSON]
FROM myCTE

DECLARE @json NVARCHAR(MAX) = N'{
    "columns": [
        {
            "name": "ORDER_TYPE",
            "type": "String",
            "value": ""
        },
        {
            "name": "TOTAL_NUM_OF_LINES",
            "type": "Decimal",
            "value": ""
        }
    ],
    "data": [
        [
            {
                "name": "ORDER_TYPE",
                "type": "Varchar2",
                "value": "WILL CALL"
            },
            {
                "name": "TOTAL_NUM_OF_LINES",
                "type": "Decimal",
                "value": "17"
            }
        ],
        [
            {
                "name": "ORDER_TYPE",
                "type": "Varchar2",
                "value": "MAKEUP"
            },
            {
                "name": "TOTAL_NUM_OF_LINES",
                "type": "Decimal",
                "value": "66"
            }
        ]
    ],
    "error": "Bob''s your uncle"
}';

SELECT
    ORDER_TYPE,
    TOTAL_NUM_OF_LINES
FROM OPENJSON(@json, '$.data')
WITH (
    ORDER_TYPE NVARCHAR(50) '$[0].value',
    TOTAL_NUM_OF_LINES DECIMAL '$[1].value'
) AS jsonValues;
*/
