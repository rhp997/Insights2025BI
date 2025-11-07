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
] */
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
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH
