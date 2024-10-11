const { MongoClient } = require('mongodb');
const async = require('async');
const fs = require('fs');

// The url of the routers are normally comma seperated so that the clients choose one randomly/based on some criteria
// but for testing we want to choose the router in a deterministic way
const url  = 'mongodb://127.0.0.1:27018/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.1';
const url2 = 'mongodb://127.0.0.1:27023/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.1';

const dbName = 'test_db';
const collName = 'coll';
const csvFilePath = 'results.csv';

const steps = [50000, 90000, 130000, 170000, 210000, 250000, 290000, 330000, 370000, 410000];

async function runTestStep(step, workers, shardCount, multipleRouters) {
  const reqPerMin = step;
  const reqPerWorker = reqPerMin / workers;
  const requestsPerSecond = reqPerWorker / 60;

  const totalDuration = 20 * 1000;
  const startTime = Date.now();

  const totalLatencyArray = Array(workers).fill(0);
  const totalRequestsArray = Array(workers).fill(0);

  await async.times(workers, async (workerId) => {
    const client = await MongoClient.connect(((workerId % 2) && multipleRouters) ? url2 : url);
    const db = client.db(dbName);
    const collection = db.collection(collName);
  
    const workerStartTime = Date.now();

    let shardSelector = 0;

    while (Date.now() - workerStartTime < totalDuration) {
      const promises = [];

      const secondStart = Date.now();

      for (let i = 0; i < requestsPerSecond; i++) {
        const requestStart = Date.now();

        shardSelector %= shardCount;
        
        const promise = collection.findOne({ workerId: shardSelector++ })
          .then(() => {
            const requestLatency = Date.now() - requestStart;
            totalLatencyArray[workerId] += requestLatency;
            totalRequestsArray[workerId]++;
          });
        
        promises.push(promise);

        const elapsedTime = Date.now() - secondStart;
        const nextRequestTime = (i + 1) * (1000 / requestsPerSecond);

        if (elapsedTime < nextRequestTime) {
          const delay = nextRequestTime - elapsedTime;
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }

      const delay = Date.now() - secondStart;
      if (delay < 1000)
          await new Promise(resolve => setTimeout(resolve, delay))

      await Promise.all(promises);

    }
  
    await client.close();
  });

  const totalTime = (Date.now() - startTime) / 1000;
  const totalRequests = totalRequestsArray.reduce((acc, curr) => acc + curr, 0);
  const totalLatency = totalLatencyArray.reduce((acc, curr) => acc + curr, 0);
  const avgLatency = totalRequests > 0 ? totalLatency / totalRequests : 0;
  const actualReqMin = (totalRequests / totalTime) * 60;

  console.log(`Step ${reqPerMin}: ${totalRequests} requests made in ${totalTime.toFixed(2)} seconds.`);
  console.log(`Actual req/min: ${actualReqMin.toFixed(2)}, Avg latency: ${avgLatency.toFixed(2)} ms`);

  const csvLine = `${actualReqMin.toFixed(2)},${avgLatency.toFixed(2)}\n`;

  fs.appendFile(csvFilePath, csvLine, (err) => {
    if (err) {
      console.error('Error writing to CSV file:', err);
    }
  });
}

(async function main() {
  const workers = 3;

  fs.truncate(csvFilePath, 0, (err) => { 
    if (err && err.code !== 'ENOENT')
      console.error('Error truncating file:', err); 
  });

  let multipleRouters = false;

  if (process.argv.length < 4) {
    console.log("Please specify the shard & router count");
    process.exit(-1);
  }

  const shardCount = parseInt(process.argv[2]);

  if (process.argv[3] === "-r2")
    multipleRouters = true;

  console.log(`Running with ${shardCount} shards & multiple routers: ${multipleRouters}`);

  for (const step of steps) {

    console.log(`Running test for ${step} req/min with ${workers} workers...`);

    await runTestStep(step, workers, shardCount, multipleRouters);
    
    console.log('-------------------------------------');
  }
})();