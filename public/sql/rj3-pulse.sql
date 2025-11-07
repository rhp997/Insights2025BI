DECLARE @json NVARCHAR(MAX) = N'{
    "columns": [
        {
            "name": "ORDER_TYPE",
            "type": "String",
            "value": ""
        },
        {
            "name": "TOTAL_NUM_OF_LINES",
            "type": "Decimal",
            "value": ""
        }
    ],
    "data": [
        [
            {
                "name": "ORDER_TYPE",
                "type": "Varchar2",
                "value": "WILL CALL"
            },
            {
                "name": "TOTAL_NUM_OF_LINES",
                "type": "Decimal",
                "value": "17"
            }
        ],
        [
            {
                "name": "ORDER_TYPE",
                "type": "Varchar2",
                "value": "MAKEUP"
            },
            {
                "name": "TOTAL_NUM_OF_LINES",
                "type": "Decimal",
                "value": "66"
            }
        ]
    ],
    "error": "Bob''s your uncle"
}';

/* Split the JSON into two fragements and a scalar value */
SELECT​
    /* Return columns and data array as a JSON fragment */​
      JSON_QUERY(@json, '$.columns') AS Cols​
    , JSON_QUERY(@json, '$.data') AS Data​
    /* JSON_VALUE returns a scalar value */​
    , JSON_VALUE(@json, '$.error') AS Errmsg​

/* Read the "data" fragment and extract values into columns */
SELECT
    ORDER_TYPE,
    TOTAL_NUM_OF_LINES
FROM OPENJSON(@json, '$.data')
WITH (
    ORDER_TYPE NVARCHAR(50) '$[0].value',
    TOTAL_NUM_OF_LINES DECIMAL '$[1].value'
) AS jsonValues;