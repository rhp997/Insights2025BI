-- TODO: Add udo table create?
SELECT
    c.BranchID
    , c.[Name]
    , c.ViewBox
    , ( /* Sub selects create nested JSON structure for groups and elements */
        SELECT
        g.[Name]
            , g.Style
            , g.Transform
            , g.Class
            , g.Text
            , g.TextStyle
            , g.TextX
            , g.TextY
            , g.TextClass
            , g.ToolTip
            , g.zIndex
        , (SELECT
            e.ID
            , e.d
            , e.Transform
            , e.Class
            , e.Style
            , e.Text
            , e.TextStyle
            , e.TextX
            , e.TextY
            , e.TextClass
            , e.ToolTip
            , e.zIndex
        FROM udoSVGElements e WITH(NOLOCK)
        WHERE e.Deleted = 0
            AND e.SVGGroupID = g.UserDefinedObjectID
        ORDER BY e.zIndex
        FOR JSON PATH) AS [Elements]
    FROM udoSVGGroups g WITH(NOLOCK)
    WHERE g.Deleted = 0
        AND g.SVGCanvasID = c.UserDefinedObjectID
    ORDER BY g.zIndex
    FOR JSON PATH) AS [Groups]
FROM udoSVGCanvas c WITH(NOLOCK)
WHERE c.Deleted = 0
FOR JSON PATH;