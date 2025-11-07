DECLARE @links TABLE (
    LinkID INT IDENTITY(1,1) PRIMARY KEY,
    Text NVARCHAR(255),
    LinkText NVARCHAR(75),
    LinkURL NVARCHAR(255)
);

INSERT @links
    (Text, LinkText, LinkURL)
VALUES
    ('This example opens the (hardcoded) drilldown defined in the hidden OpenTestSV Text Line component', 'Static Drilldown', 'dislinkDrillDown209374'),
    ('The "Text Line Custom" button opens the drilldown defined in a hidden Text Line component, but sends custom values encoded in the link: ', 'Text Line Custom', 'dislinkDrillDown209369%C3%82%C2%A0%drilldownID1%=2025%C3%82%C2%A0%drilldownID2%=1999%C3%82%C2%A0%drilldowncaption%=''Custom%20value%20here''%C3%82%C2%A0'),
    ('The "Custom Param" button opens the drilldown defined in a hidden Text Line component, but sends a drilldown parameter that is not defined (or even available) in the Text Line component', 'Custom Param', 'dislinkDrillDown209369%C3%82%C2%A0%drilldownString=''bob''%C3%82%C2%A0'),
    ('The "Custom Link" button opens the drilldown defined in the DataTable component, but sends custom values encoded in the link', 'Custom Link', 'dislinkDrillDown209369%C3%82%C2%A0%drilldownID1%=2025%C3%82%C2%A0%drilldownID2%=1999%C3%82%C2%A0%drilldowncaption%=''Custom%20value%20here''%C3%82%C2%A0'),
    ('This example opens a Crystal report as defined in the ReportExample Text Line component. Note: The report does not import/export as a linked item (e.g., won''t work out of the box) and must be manually assigned to the Text Line component as a drilldown', 'Report Example', 'dislinkDrillDown209376'),
    ('The "JSON value" button sends URLEncoded JSON value to the drilldown defined in the DataTable component', 'JSON Value', 'dislinkDrillDown209369%C3%82%C2%A0%drilldowncaption%=''%7B%22error%22%3A%20%22Doh%22%7D''%C3%82%C2%A0'),
    ('This example saves JSON from a hidden datatable to session storage. The link passes the storage key to the Drilldowns 2 dashboard which contains logic to use the session storage data if available, otherwise the default SQL is run.', 'Session JSON', 'dislinkDrillDown209383%C3%82%C2%A0%drilldownStorageKey%=TopSales%C3%82%C2%A0'),
    ('Click this button to increment a Session Storage counter', 'Session Counter', 'javascript:clickCounterS()'),
    ('Click this button to increment a Local Storage counter', 'Local Counter', 'javascript:clickCounterL()');
/*
  Create an HTML table with Bootstrap classes and links from the @links table. Requires a separate CSS override to style the table properly.
*/
SELECT 'table table-bordered table-striped table-hover caption-end' AS "@class",
    (SELECT 'This table was created using SQL inside a Data Label component'
    FOR XML PATH('caption'), TYPE), -- caption
    (SELECT
        (SELECT
            'table-primary' AS "th/@class"
            , 'Description' AS th
            , ''
            , 'table-primary' AS "th/@class"
            , 'Link' AS th
            , ''
        FOR XML PATH('tr'), TYPE) AS thead, -- header row
        (SELECT
            (SELECT -- Col 1
                'col1' AS "td/@class"
                , 'cursor: pointer;' AS "td/@style"
                -- Make entire row clickable by adding onclick to td; replace single quotes with URL encoded %27
                , 'javascript:document.location.href=''' + REPLACE(l.LinkURL, '''', '%27') + '''' AS "td/@onclick"
                , l.Text AS td
                , ''
                , ( -- Col 2: Nest with anchor link
                    SELECT
                    l.LinkURL AS "a/@href"
                        , 'btn btn-primary' AS "a/@class"
                        , l.LinkText AS a
                FOR XML PATH('td'), TYPE
                )
            FROM @links l
            FOR XML PATH('tr'), TYPE)
        FOR XML PATH(''), TYPE) AS tbody
    FOR XML PATH(''), TYPE)
FOR XML PATH('table');