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
] */
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
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON PATH