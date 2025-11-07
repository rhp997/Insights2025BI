/*
    The main dashboard query returns three JSON objects:
    1. A pie chart showing last sales line by sales rep
    2. A line chart with random monthly data
    3. A data table with recent orders
    Each JSON object is returned as a separate column in the final result set.
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
