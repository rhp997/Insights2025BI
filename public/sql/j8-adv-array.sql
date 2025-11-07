/*
[
    [
        "Mark Dodson",
        35,
        "11/06/2025",
        4112.64
    ],
    [
        "Cody Bartlett",
        43,
        "11/06/2025",
        13391.04
    ]
]
*/
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
    ORDER BY ROW_NUMBER() OVER(PARTITION BY sa.SalesRepID ORDER BY sa.DocumentDate DESC)
) AS salesInfo;