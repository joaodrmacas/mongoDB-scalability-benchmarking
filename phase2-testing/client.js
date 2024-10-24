const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

const { MongoClient } = require('mongodb');
const async = require('async');
const fs = require('fs');

const dbName = 'test_db';
const collName = 'coll';
const url = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.2';
const csvFilePath = 'results.csv';

const totalDuration = 20 * 1000;
const reqPerMin = 250000;

async function workerFunc(shardCount) {
    const requestsPerSecond = reqPerMin / 60;
  
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

        for (let i = 0; i < requestsPerSecond; i++) {
            const requestStart = Date.now();

            shardSelector %= shardCount;

            const promise = collection.insertOne({ workerId: shardSelector++, data: `random data ${Math.random()}` })
            .then(() => {
                const requestLatency = Date.now() - requestStart;
                totalReqLatency += requestLatency;
                totalReqCount++;
            });

            promises.push(promise);

            const elapsedTime = Date.now() - secondStart;
            const nextRequestTime = (i + 1) * (1000 / requestsPerSecond);

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
  
    console.log(`Step ${reqPerMin}: ${totalReqCount} requests made in ${totalTime.toFixed(2)} seconds.`);
    console.log(`Actual req/min: ${actualReqMin.toFixed(2)}, Avg latency: ${avgLatency.toFixed(2)} ms`);
  
    const csvLine = `${actualReqMin.toFixed(2)},${avgLatency.toFixed(2)}\n`;
  
    fs.appendFile(csvFilePath, csvLine, (err) => {
      if (err) {
        console.error('Error writing to CSV file:', err);
      }
    });
}

(async function main() {
    if (cluster.isMaster) {
        fs.truncate(csvFilePath, 0, (err) => {
            if (err && err.code !== 'ENOENT')
                console.error('Error truncating file:', err);
        });
        
        // 1 process per cpu core
        for (let i = 0; i < numCPUs; i++) {
            cluster.fork();
        }
    
        cluster.on('exit', (worker, code, signal) => {
            console.log(`Worker ${worker.process.pid} died`);
        });
    } else {
        await workerFunc(1);
    }
})();