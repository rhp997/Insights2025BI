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
    ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
    FOR JSON PATH
) AS SI(SalesJSON)
FOR JSON PATH