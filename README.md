## MongoDB Topic Task
### Task
Write requests to generate reports on the work of the restaurant.

There is a database where orders are stored. Each record looks like:
```json
{
  // ID
  "_id": {
    "$oid": "5ec7916eff6e80725811b3f7"
  },
  //Список заказанных блюд
  "meals": [
    {
      "name": "Fish", // название блюда
      "servings": 2 // количество порций
    },
    {
      "name": "Pizza",
      "servings": 4
    },
    {
      "name": "Soup",
      "servings": 4
    },
    {
      "name": "Beef",
      "servings": 3
    }
  ],
  //Дата и время заказа
  "date": {
    "$date": "2004-09-29T10:37:45Z"
  },
  "_class": "com.example.ordersgenerator.entity.Order"
}
```
##
- #### For each dish, get the number of servings by month

```json
db.orders.aggregate([ 
 { "$unwind" : "$meals" },
 { "$project" : { "meals" : 1, "month" : { "$month" : "$date" }}},
 { "$group" : {
    "_id" : {"meal" : "$meals.name", "month" : "$month" },
    "total": { "$sum" : "$meals.servings" }
    } 
 },
 { "$sort" : { "_id.month" : 1 }},
 { "$group" : {
    "_id" : "$_id.meal",
    "sold": { "$push" : { "month": "$_id.month", "sum" : { "$sum" : "$total" }}}
    }
 },
 { "$project" : {"_id" : 0, "meal" : "$_id", "sold" : "$sold" }},
 { "$out" : "aggregation_01" }
])
```
- Stage 1: **$unwind**: split records to have separate record for each element of meals array
- Stage 2: **$project**: use only meals and get month from date
- Stage 3: **$group**: grouping by meal name and month and calculating the number of servings for each group
- Stage 4: **$sort**: sorting by month, ascending order
- Stage 5: **$group**: group by meal, generating an array of total servings by month
- Stage 6: **$project**: make meal element from id
- Stage 7: **$out**: specify a collection to write aggregation result



##
- #### For each dish, get the number of orders by month
```json
db.orders.aggregate([ 
 { "$unwind" : "$meals" },
 { "$project" : { "meals" : 1, "month" : { $month: "$date" }}},
 { "$group" : {
    "_id" : { "meal" : "$meals.name", "order" : "$_id", "month" : "$month" }
    }
 },
 { "$group" : {
    "_id" : {"meal" : "$_id.meal", "month" : "$_id.month" },
    "orders": { "$sum" : 1 }
    }
 },
 { "$sort" : { "_id.month" : 1 }},
 { "$group" : {
    "_id" : "$_id.meal",
    "orders": { "$push" : { "month" : "$_id.month", "orders" : "$orders" }}
    }
 },
 { "$project" : { "_id" : 0, "meal" : "$_id", "orders" : "$orders" }},
 { "$out" : "aggregation_02" }
], { "allowDiskUse" : true } )
```
- Stage 1: **$unwind**: split records to have separate record for each element of meals array
- Stage 2: **$project**: use only meals and get month from date
- Stage 3: **$group**: grouping by meal name, month and order
- Stage 4: **$group**: group by meal and month, calculating number of orders
- Stage 5: **$sort**: sorting by month, ascending order
- Stage 6: **$group**: group by meal, generating an array of total orders by month
- Stage 7: **$project**: make meal element from id
- Stage 8: **$out**: specify a collection to write aggregation result

*Here using ```allowDiskUse``` argument because Stage 3 exceeds memory limit*

##
- #### Find the top 3 best-selling dishes by month
```json
db.orders.aggregate([ 
 { "$unwind" : "$meals"},
 { "$project" : { "meals" : 1, "month" : { $month: "$date" }} },
 { "$group" : {
    "_id" : { "meal" : "$meals.name", "month":"$month" },
    "total": { "$sum" : "$meals.servings" }
    } 
 },
 { "$group" : {
    "_id" : "$_id.month",
    "sold" : { "$push" : {"meal" : "$_id.meal", "sum" : { "$sum" : "$total" }}}
    }
 },
 { "$unwind" : "$sold" },
 { "$sort" : { "sold.sum": -1 }},
 { "$group" : {
	"_id" : "$_id",
    	"sold" : { "$push" : "$sold.meal" }
	}
 },
 { "$sort" : { "_id" : 1 }},
 { "$project" : { "_id" : 0, "month" : "$_id", "top-sold" : { "$slice" : ["$sold", 3]}}},
 { "$out" : "aggregation_03" }
])
```
- Stage 1: **$unwind**: split records to have separate record for each element of meals array
- Stage 2: **$project**: use only meals and get month from date
- Stage 3: **$group**: grouping by meal name and month, calculating total servings
- Stage 4: **$group**: group by month, generating an array of total servings by meal
- Stage 5: **$unwind**: unwind to sort by number of servings
- Stage 6: **$sort**: sorting by total servings, descending order
- Stage 7: **$group**: collecting sorted records
- Stage 8: **$sort**: sorting by id(month), ascending order
- Stage 9: **$project**: make month element from id, limit sold array by 3
- Stage 10: **$out**: specify a collection to write aggregation result

##
### Results
The result of aggregations is located in ```results.tar``` file. 

To generate this file execute ```docker-compose build && docker-compose up```


