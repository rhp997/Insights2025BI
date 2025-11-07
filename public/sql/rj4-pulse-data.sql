DECLARE @json NVARCHAR(MAX) = N'[
    [
        {
            "name": "STOCK_CODE",
            "type": "Varchar2",
            "value": "HBAG-TWTR-1X2.5X16"
        },
        {
            "name": "LOCATION",
            "type": "Varchar2",
            "value": "01A05"
        },
        {
            "name": "NUM_UNITS",
            "type": "Decimal",
            "value": "1"
        },
        {
            "name": "TOTAL_QTY",
            "type": "Decimal",
            "value": "360"
        },
        {
            "name": "OLDEST_UNIT",
            "type": "Date",
            "value": "18-OCT-24"
        }
    ],
    [
        {
            "name": "STOCK_CODE",
            "type": "Varchar2",
            "value": "CEWR-RPSB-6X8X20"
        },
        {
            "name": "LOCATION",
            "type": "Varchar2",
            "value": "05B02"
        },
        {
            "name": "NUM_UNITS",
            "type": "Decimal",
            "value": "1"
        },
        {
            "name": "TOTAL_QTY",
            "type": "Decimal",
            "value": "6"
        },
        {
            "name": "OLDEST_UNIT",
            "type": "Date",
            "value": "06-OCT-21"
        }
    ]
]';
/* Use JSON_VALUE to extract values; note how the NUM_UNITS, TOTAL_QTY, and OLDEST_UNIT columns are formatted */
SELECT
    JSON_VALUE(value, '$[0].value') AS [STOCK_CODE]
    , JSON_VALUE(value, '$[1].value') AS [LOCATION]
    , JSON_VALUE(value, '$[2].value') AS [NUM_UNITS]
    , JSON_VALUE(value, '$[3].value') AS [TOTAL_QTY]
    , JSON_VALUE(value, '$[4].value') AS [OLDEST_UNIT]
FROM OPENJSON(@json) AS root_js

/*
    Use OPENJSON with WITH clause to extract values into columns.
    The OLDEST_UNIT column is formatted as a date, others as decimals.
*/
SELECT
    j.STOCK_CODE
    , j.LOCATION
    , j.NUM_UNITS
    , j.TOTAL_QTY
    , j.OLDEST_UNIT
FROM OPENJSON(@json)
WITH (STOCK_CODE NVARCHAR(100) '$[0].value', LOCATION NVARCHAR(50) '$[1].value'
    , NUM_UNITS DECIMAL(18,2) '$[2].value', TOTAL_QTY DECIMAL(18,2) '$[3].value'
    , OLDEST_UNIT DATE '$[4].value') AS j