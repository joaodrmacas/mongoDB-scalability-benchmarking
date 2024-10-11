# Configure the configserver
docker exec -it mongo_cfg mongosh --eval 'rs.initiate({  _id: "cfgReplSet",  configsvr: true,  members: [{ _id: 0, host: "mongo_cfg:27017" }]})'
# Configure the shards
docker exec -it mongo_shard1 mongosh --eval 'rs.initiate({ _id: "shard1ReplSet", members: [{ _id: 0, host: "mongo_shard1:27017" }] })'
docker exec -it mongo_shard2 mongosh --eval 'rs.initiate({ _id: "shard2ReplSet", members: [{ _id: 0, host: "mongo_shard2:27017" }] })'
docker exec -it mongo_shard3 mongosh --eval 'rs.initiate({ _id: "shard3ReplSet", members: [{ _id: 0, host: "mongo_shard3:27017" }] })'

# Configure the topology
docker exec -it mongo_mongos mongosh --eval 'sh.addShard("shard1ReplSet/mongo_shard1:27017"); sh.addShard("shard2ReplSet/mongo_shard2:27017");sh.addShard("shard3ReplSet/mongo_shard3:27017");'

# Configure the db & sharding
docker exec -it mongo_mongos mongosh --eval 'use test_db;'
docker exec -it mongo_mongos mongosh --eval '
db.createCollection("coll"); db.coll.createIndex({ workerId: 1 });
sh.shardCollection("test_db.coll", { workerId: 1 });
sh.addShardTag("shard1ReplSet", "zone1");
sh.addShardTag("shard2ReplSet", "zone2");
sh.addShardTag("shard3ReplSet", "zone3");
db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: MinKey() }, max: { workerId: 3 }, zone: "zone1"});
db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 3 }, max: { workerId: 6 }, zone: "zone2"});
db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 6 }, max: { workerId: MaxKey() }, zone: "zone3"});
'
