/*
[
    {
        "Mark Dodson": [
            {
                "SalesRepID": 18,
                "SalesUserID": 35,
                "DocumentDate": "2025-11-06T00:00:00",
                "LastSaleLine": 4112.64
            }
        ]
    },
    {
        "Cody Bartlett": [
            {
                "SalesRepID": 27,
                "SalesUserID": 43,
                "DocumentDate": "2025-11-06T00:00:00",
                "LastSaleLine": 13391.04
            }
        ]
    }
]
*/
;WITH
    myCTE
    AS
    (
        SELECT -- Use SalesRep as key with subquery and FOR JSON PATH as the value
            CONCAT('{', '"', p.SalesRep, '"', ':', (
            SELECT p.SalesRepID, p.SalesUserID, p.DocumentDate, p.LastSaleLine
            FROM SalesRep sr
            WHERE sr.SalesRepID = p.SalesRepID
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
            ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
    ) p
    )
-- Aggregate the rows into a single JSON object using a comma separator
SELECT FORMATMESSAGE('[%s]', STRING_AGG(JSONResult,',')) [FinalJSON]
FROM myCTE