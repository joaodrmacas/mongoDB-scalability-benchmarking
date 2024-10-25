const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

const { MongoClient } = require('mongodb');
const async = require('async');
const fs = require('fs');

const dbName = 'test_db';
const collName = 'coll';
const url = 'mongodb://mongo-mongos:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.2';
const csvFilePath = 'results_read.csv';

const totalDuration = 20 * 1000;
const reqPerMin = 250000;

async function workerFunc() {
    const REQUESTS_PER_SECOND = parseInt(process.env.REQ_PER_MIN) / 60;
    const SHARD_COUNT = parseInt(process.env.SHARD_COUNT);

    const client = await MongoClient.connect(url);
    const db = client.db(dbName);
    const collection = db.collection(collName);

    const startTime = Date.now();
    const workerStartTime = Date.now();

    let shardSelector = 0;

    let totalReqLatency = 0;
    let totalReqCount = 0;

    while (Date.now() - workerStartTime < totalDuration) {
        const promises = [];

        const secondStart = Date.now();

        for (let i = 0; i < REQUESTS_PER_SECOND; i++) {
            const requestStart = Date.now();

            shardSelector %= SHARD_COUNT;

            // Read-intensive test: replace insertOne with findOne
            const promise = collection.findOne({ workerId: shardSelector++ })
                .then(() => {
                    const requestLatency = Date.now() - requestStart;
                    totalReqLatency += requestLatency;
                    totalReqCount++;
                });

            promises.push(promise);

            const elapsedTime = Date.now() - secondStart;
            const nextRequestTime = (i + 1) * (1000 / REQUESTS_PER_SECOND);

            if (elapsedTime < nextRequestTime) {
                const delay = nextRequestTime - elapsedTime;
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }

        await Promise.all(promises);
    }

    await client.close();

    const totalTime = (Date.now() - startTime) / 1000;
    const avgLatency = totalReqCount > 0 ? totalReqLatency / totalReqCount : 0;
    const actualReqMin = (totalReqCount / totalTime) * 60;

    const csvLine = `${actualReqMin.toFixed(2)},${avgLatency.toFixed(2)}\n`;

    await fs.appendFile(csvFilePath, csvLine);

    console.log(`Target req/min: ${REQUESTS_PER_SECOND * 60}, acutal req/min: ${actualReqMin.toFixed(2)}`)
    console.log(`${totalReqCount} requests made in ${totalTime.toFixed(2)} seconds.`);
    console.log(`Avg latency: ${avgLatency.toFixed(2)} ms`);
}


(async function main() {
    if (cluster.isMaster) {

        if (process.argv.length < 4) {
            console.log("Usage: node client.js shardCount reqPerMin");
            process.exit(-1);
        }

        const SHARD_COUNT = process.argv[2];
        const REQ_PER_MIN = process.argv[3];

        // 1 process per cpu core
        for (let i = 0; i < numCPUs; i++) {
            cluster.fork({ SHARD_COUNT, REQ_PER_MIN });
        }

        cluster.on('exit', (worker, code, signal) => {
            console.log(`Worker ${worker.process.pid} died`);
        });
    } else {
        await workerFunc(1);
    }
})();