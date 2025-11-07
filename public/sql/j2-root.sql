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
} */
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
ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
FOR JSON AUTO, ROOT('SalesReps')