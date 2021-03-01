#!/bin/bash

#exctract db json
echo "Unpacking data...";
unzip ./orders.json.zip;

#import json to mongo
echo "Importing data to mongo...";
mongoimport --host mongo --db ordersdb --collection orders --file ./orders.json

#read from files
ls /usr
req_file_1="/usr/requests/mongo_ag_1";
req_file_2="/usr/requests/mongo_ag_2";
req_file_3="/usr/requests/mongo_ag_3";

#read requests from files as a variables
echo "Reading requests from files...";
req_1=$(cat "$req_file_1");
req_2=$(cat "$req_file_2");
req_3=$(cat "$req_file_3");

#execute requests
echo "Executing requests....";
mongo --host mongo ordersdb --quiet --eval "$req_1";
mongo --host mongo ordersdb --quiet --eval "$req_2";
mongo --host mongo ordersdb --quiet --eval "$req_3";

#export results
echo "Exporting results as json files...";
mongoexport --host mongo -d ordersdb -c aggregation_01 > aggregation_01.json;
mongoexport --host mongo -d ordersdb -c aggregation_02 > aggregation_02.json;
mongoexport --host mongo -d ordersdb -c aggregation_03 > aggregation_03.json;

#create archive
echo "Creating results tar archive...";
tar -cvf /usr/result/results.tar aggregation_01.json aggregation_02.json aggregation_03.json --remove-files;
