#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <journalCommitInterval>"
    exit 1
fi

JOURNAL_COMMIT_INTERVAL=$1

# Get the names of the pods
MONGO_CFG_POD=$(sudo kubectl get pods -l app=mongo-cfg -o jsonpath='{.items[0].metadata.name}')
MONGO_MONGOS1_POD=$(sudo kubectl get pods -l app=mongo-mongos -o jsonpath='{.items[0].metadata.name}')
MONGO_MONGOS2_POD=$(sudo kubectl get pods -l app=mongo-mongos -o jsonpath='{.items[1].metadata.name}')
MONGO_SHARD1_POD=$(sudo kubectl get pods -l app=mongo-shard1 -o jsonpath='{.items[0].metadata.name}')
MONGO_SHARD2_POD=$(sudo kubectl get pods -l app=mongo-shard2 -o jsonpath='{.items[0].metadata.name}')
MONGO_SHARD3_POD=$(sudo kubectl get pods -l app=mongo-shard3 -o jsonpath='{.items[0].metadata.name}')
MONGO_SHARD4_POD=$(sudo kubectl get pods -l app=mongo-shard4 -o jsonpath='{.items[0].metadata.name}')
MONGO_SHARD5_POD=$(sudo kubectl get pods -l app=mongo-shard5 -o jsonpath='{.items[0].metadata.name}')



# Configure the config server
echo "Configuring the config server..."
sudo kubectl exec -it "$MONGO_CFG_POD" -- mongosh --eval 'rs.initiate({ _id: "cfgReplSet", configsvr: true, members: [
  { _id: 0, host: "mongo-cfg-0.mongo-cfg:27017" },
  { _id: 1, host: "mongo-cfg-1.mongo-cfg:27017" },
  { _id: 2, host: "mongo-cfg-2.mongo-cfg:27017" }
]})'

# Configure the shards
echo "Configuring shard 1..."
sudo kubectl exec -it "$MONGO_SHARD1_POD" -- mongosh --eval 'rs.initiate({ _id: "shard1ReplSet", members: [
  { _id: 0, host: "mongo-shard1-0.mongo-shard1:27017" },
  { _id: 1, host: "mongo-shard1-1.mongo-shard1:27017" },
  { _id: 2, host: "mongo-shard1-2.mongo-shard1:27017" }
] })'

echo "Configuring shard 2..."
sudo kubectl exec -it "$MONGO_SHARD2_POD" -- mongosh --eval 'rs.initiate({ _id: "shard2ReplSet", members: [
  { _id: 0, host: "mongo-shard2-0.mongo-shard2:27017" },
  { _id: 1, host: "mongo-shard2-1.mongo-shard2:27017" },
  { _id: 2, host: "mongo-shard2-2.mongo-shard2:27017" }
] })'

echo "Configuring shard 3..."
sudo kubectl exec -it "$MONGO_SHARD3_POD" -- mongosh --eval 'rs.initiate({ _id: "shard3ReplSet", members: [
  { _id: 0, host: "mongo-shard3-0.mongo-shard3:27017" },
  { _id: 1, host: "mongo-shard3-1.mongo-shard3:27017" },
  { _id: 2, host: "mongo-shard3-2.mongo-shard3:27017" }
  ] })'

echo "Configuring shard 4..."
sudo kubectl exec -it "$MONGO_SHARD4_POD" -- mongosh --eval 'rs.initiate({ _id: "shard4ReplSet", members: [
  { _id: 0, host: "mongo-shard4-0.mongo-shard4:27017" },
  { _id: 1, host: "mongo-shard4-1.mongo-shard4:27017" },
  { _id: 2, host: "mongo-shard4-2.mongo-shard4:27017" }
  ] })'

echo "Configuring shard 5..."
sudo kubectl exec -it "$MONGO_SHARD5_POD" -- mongosh --eval 'rs.initiate({ _id: "shard5ReplSet", members: [
  { _id: 0, host: "mongo-shard5-0.mongo-shard5:27017" },
  { _id: 1, host: "mongo-shard5-1.mongo-shard5:27017" },
  { _id: 2, host: "mongo-shard5-2.mongo-shard5:27017" }
  ] })'

sleep 2

echo "Configuring the topology..."

# Configure the topology on both mongos
echo "Configuring the topology on $MONGO_MONGOS1_POD..."
sudo kubectl exec -it "$MONGO_MONGOS1_POD" -- mongosh --eval 'sh.addShard("shard1ReplSet/mongo-shard1-0.mongo-shard1:27017"); sh.addShard("shard2ReplSet/mongo-shard2-0.mongo-shard2:27017"); sh.addShard("shard3ReplSet/mongo-shard3-0.mongo-shard3:27017"); sh.addShard("shard4ReplSet/mongo-shard4-0.mongo-shard4:27017"); sh.addShard("shard5ReplSet/mongo-shard5-0.mongo-shard5:27017");'

sleep 2

echo "Configuring the topology on $MONGO_MONGOS1_POD..."
sudo kubectl exec -it "$MONGO_MONGOS2_POD" -- mongosh --eval 'sh.addShard("shard1ReplSet/mongo-shard1-0.mongo-shard1:27017"); sh.addShard("shard2ReplSet/mongo-shard2-0.mongo-shard2:27017"); sh.addShard("shard3ReplSet/mongo-shard3-0.mongo-shard3:27017"); sh.addShard("shard4ReplSet/mongo-shard4-0.mongo-shard4:27017"); sh.addShard("shard5ReplSet/mongo-shard5-0.mongo-shard5:27017");'

sleep 2

echo "Setting up the database and sharding..."

# Configure the db & sharding
echo "Setting up the database and sharding on $MONGO_MONGOS1_POD..."
sudo kubectl exec -it "$MONGO_MONGOS1_POD" -- mongosh test_db --eval '
  db.createCollection("coll");
  db.coll.createIndex({ workerId: 1 });
  sh.shardCollection("test_db.coll", { workerId: 1 });
  sh.addShardTag("shard1ReplSet", "zone1");
  sh.addShardTag("shard2ReplSet", "zone2");
  sh.addShardTag("shard3ReplSet", "zone3");
  sh.addShardTag("shard4ReplSet", "zone4");
  sh.addShardTag("shard5ReplSet", "zone5");
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: MinKey() }, max: { workerId: 1 }, zone: "zone1"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 1 }, max: { workerId: 2 }, zone: "zone2"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 2 }, max: { workerId: 3 }, zone: "zone3"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 3 }, max: { workerId: 4 }, zone: "zone4"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 4 }, max: { workerId: MaxKey() }, zone: "zone5"});
'
wait 3

# Configure the db & sharding
echo "Setting up the database and sharding on $MONGO_MONGOS2_POD..."
sudo kubectl exec -it "$MONGO_MONGOS2_POD" -- mongosh test_db --eval '
  db.createCollection("coll");
  db.coll.createIndex({ workerId: 1 });
  sh.shardCollection("test_db.coll", { workerId: 1 });
  sh.addShardTag("shard1ReplSet", "zone1");
  sh.addShardTag("shard2ReplSet", "zone2");
  sh.addShardTag("shard3ReplSet", "zone3");
  sh.addShardTag("shard4ReplSet", "zone4");
  sh.addShardTag("shard5ReplSet", "zone5");
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: MinKey() }, max: { workerId: 1 }, zone: "zone1"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 1 }, max: { workerId: 2 }, zone: "zone2"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 2 }, max: { workerId: 3 }, zone: "zone3"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 3 }, max: { workerId: 4 }, zone: "zone4"});
  db.adminCommand({ updateZoneKeyRange: "test_db.coll", min: { workerId: 4 }, max: { workerId: MaxKey() }, zone: "zone5"});
'
wait 3

echo "Setting journalCommitInterval to $JOURNAL_COMMIT_INTERVAL on all shards and config server..."
for POD in "$MONGO_CFG_POD" "$MONGO_SHARD1_POD" "$MONGO_SHARD2_POD" "$MONGO_SHARD3_POD" "$MONGO_SHARD4_POD" "$MONGO_SHARD5_POD"; do
    sudo kubectl exec -it "$POD" -- mongosh --eval "db.adminCommand({ setParameter: 1, journalCommitInterval: $JOURNAL_COMMIT_INTERVAL });"
done

echo "Setup completed."
