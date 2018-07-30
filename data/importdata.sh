ACCESS_KEY=M41jRfbEXGoHTxyLbn6jxpL2xnfoyxz_Psm0AMfSbzNBXOWphHO3Q1GfOUg3P6O5

# create user Dimi
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "user",
  "entityId" : "Dimi",
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# create user Vicky
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "user",
  "entityId" : "Vicky",
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# create item FreddoCapuccino
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "item",
  "entityId" : "FreddoCapuccino",
  "properties" : {
    "categories" : ["coffee", "drinks"]
  }
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# create item FreddoEspresso
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "item",
  "entityId" : "FreddoEspresso",
  "properties" : {
    "categories" : ["coffee", "drinks"]
  }
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# create item GreekCoffee
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "item",
  "entityId" : "GreekCoffee",
  "properties" : {
    "categories" : ["coffee", "drinks"]
  }
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# create item Espresso
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "$set",
  "entityType" : "item",
  "entityId" : "Espresso",
  "properties" : {
    "categories" : ["coffee", "drinks"]
  }
  "eventTime" : "2014-11-02T09:39:45.618-08:00"
}'

# Dimi views freddoCapuccino
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "view",
  "entityType" : "user",
  "entityId" : "Dimi",
  "targetEntityType" : "item",
  "targetEntityId" : "FreddoCapuccino",
  "eventTime" : "2014-11-10T12:34:56.123-08:00"
}'

# Dimi views FreddoEspresso
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "view",
  "entityType" : "user",
  "entityId" : "Dimi",
  "targetEntityType" : "item",
  "targetEntityId" : "FreddoEspresso",
  "eventTime" : "2014-11-10T12:34:56.123-08:00"
}'

# Vicky views FreddoCapuccino
curl -i -X POST http://localhost:7070/events.json?accessKey=$ACCESS_KEY \
-H "Content-Type: application/json" \
-d '{
  "event" : "view",
  "entityType" : "user",
  "entityId" : "Vicky",
  "targetEntityType" : "item",
  "targetEntityId" : "FreddoCapuccino",
  "eventTime" : "2014-11-10T12:34:56.123-08:00"
}'