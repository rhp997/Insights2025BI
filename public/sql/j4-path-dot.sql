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
] */
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
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH