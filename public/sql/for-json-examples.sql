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
    --AND sa.SalesRepID IN (27, 18)
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


SELECT JSON_QUERY(CONCAT(
    '[',
    STRING_AGG(
        CONCAT(
            '[',
            '"', [SalesRep], '",',
            [SalesUserID], ',',
            '"', CONVERT(VARCHAR(10), [DocumentDate], 101), '",',
            [LastSaleLine],
            ']'
        ),
        ','
    ),
    ']')
) AS JSONArray
FROM (
    SELECT TOP (1) WITH TIES
        sr.Name AS [SalesRep],
        sr.UserID AS [SalesUserID],
        sa.DocumentDate AS [DocumentDate],
        sa.TotalSales AS [LastSaleLine]
    FROM SalesAnalysis3 sa WITH(NOLOCK)
        INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
    WHERE sr.Deleted = 0
        AND sa.TotalSales <> 0
        AND sa.DocumentType = 'Invoice'
        AND sa.SalesRepID IN (27, 18)
    ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
) AS salesInfo;
*/

SELECT J1.PieChart, J2.LineChart, J3.DataTable
FROM (
    SELECT -- Without FOR JSON PATH, this would return two JSON cols
        JSON_QUERY(C.ChartJSON) AS [chart]
        , JSON_QUERY(D.dataJSON) AS [data]
    FROM
        ( -- Chart config here
        SELECT
            'Last Sales Line by Sales Rep' AS [caption]
            , 'Simple 3D Pie Chart Example' AS [subCaption]
            , 'fusion' AS [theme]
            , '20' AS [slicingDistance]
            , '1' AS [showTooltip]
            , '1' AS [showLegend]
            , '1' AS [showLegendBorder]
            , '1' AS [showPercentValues]
            , '1' AS [enableSmartLabels]
            , '1' AS [isSmartLineSlanted]
            , '1' AS [useDataPlotColorForLabels]
            , '0' AS [showPlotBorder]
            , '0' AS [decimals]
            , 'FFFFFF' AS [bgColor]
            , '20' AS [bgAlpha]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS C(ChartJSON) CROSS JOIN
    ( -- Sales info subquery in another column
        SELECT TOP(1) WITH TIES
            sr.Name AS [label]
            , sa.TotalSales AS [value]
        FROM SalesAnalysis3 sa WITH(NOLOCK)
            INNER JOIN SalesRep sr WITH(NOLOCK) ON sr.SalesRepID = sa.SalesRepID
        WHERE sr.Deleted = 0
            AND sa.TotalSales <> 0
            AND sa.DocumentType = 'Invoice'
        ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
        FOR JSON PATH
    ) AS D(dataJSON)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS J1(PieChart),
    (
    SELECT -- Without FOR JSON PATH, this would return two JSON cols
        JSON_QUERY(C.ChartJSON) AS [chart]
        , JSON_QUERY(D.dataJSON) AS [data]
    FROM
        ( -- Chart config here
        SELECT
            'Random Monthly Data' AS [caption]
            , 'Click a label to drilldown. Change chart type by clicking radio button above' AS [subCaption]
            , 'fusion' AS [theme]
            , '1' AS [showTooltip]
            , '1' AS [showLegend]
            , '1' AS [showLegendBorder]
            , 'Month' AS [xAxisName]
            , 'Revenue (in Millions)' AS [yAxisName]
            , '$' AS [numberPrefix]
            , '1' AS [useDataPlotColorForLabels]
            , '0' AS [showPlotBorder]
            , '0' AS [decimals]
            , '3190d6,FFFFFF' AS [bgColor]
            , '60,40' AS [bgRatio]
            , '90' AS [bgAngle]
            , '60,70' AS [bgAlpha]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS C(ChartJSON) CROSS JOIN
    ( -- Generate random data for 12 months
        SELECT
            FORMAT(DATEFROMPARTS(1900, v.number, 1), 'MMM', 'en-US') AS [label]
            , CAST(ABS(CHECKSUM(NEWID())) % 100 AS INT) AS [value]
        FROM master..spt_values v
        WHERE v.type='p'
            AND v.number BETWEEN 1 AND 12
        FOR JSON PATH
    ) AS D(dataJSON)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS J2(LineChart),
    (
    SELECT TOP 53
        b.Name AS BranchName
        , oh.OrderID
        , oh.OrderNumber
        , oh.DateTimeCreated
        , oh.TotalSellPrice
        , os.Name [OrderStatus]
    FROM OrderHeader oh WITH(NOLOCK)
        INNER JOIN OrderStatus os WITH(NOLOCK) ON os.OrderStatusID = oh.OrderStatus
        INNER JOIN Branch b WITH(NOLOCK) ON b.BranchID = oh.BranchID
    WHERE oh.Deleted = 0
    ORDER BY oh.DateTimeCreated DESC
    FOR JSON PATH
) AS J3(DataTable)
