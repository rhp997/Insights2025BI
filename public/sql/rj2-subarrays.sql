DECLARE @json NVARCHAR(MAX) = N'[
    {
        "id": 1002,
        "myarray": [
            "val1",
            "val2"
        ],
        "items": [
            {
                "item_id": 101,
                "name": "Apple and Pears"
            }
        ]
    },
    {
        "id": 2001,
        "myarray": [
            "val4",
            "val5",
            "val6"
        ],
        "items": [
            {
                "item_id": 201,
                "name": "Orange"
            },
            {
                "item_id": 202,
                "name": "Grape"
            }
        ]
    }
]'
-- Use OPENJSON and OUTER APPLY to traverse object​
SELECT ​
      root_js.myIDCol​
    , item.itemID​
    , item.name​
    , myval.val​
FROM OPENJSON(@json) WITH (myIDCol INT '$.id', items NVARCHAR(MAX) '$.items' AS JSON, myarray NVARCHAR(MAX) '$.myarray' AS JSON) AS root_js​
OUTER APPLY OPENJSON(root_js.items) WITH(itemID INT '$.item_id', [name] VARCHAR(20) '$.name') AS item​
OUTER APPLY OPENJSON(root_js.myarray) WITH(val VARCHAR(10) '$') AS myVal