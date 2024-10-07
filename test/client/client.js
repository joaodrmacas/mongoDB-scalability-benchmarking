const { MongoClient } = require('mongodb');

function randomSleep() {
  const sleepTime = Math.floor(Math.random() * 100) + 1;
  return new Promise(resolve => setTimeout(resolve, sleepTime));
}

async function runStressTest(workerId, docsPerWorker, dbUrl) {
  const client = new MongoClient(dbUrl);

  try {
    await client.connect();
    console.log(`Worker ${workerId}: Connected to MongoDB`);

    const db = client.db('test_db');
    const collection = db.collection('test_collection');

    for (let i = 0; i < docsPerWorker; i++) {
      await collection.insertOne({
        workerId: workerId,
        docId: i,
        data: `Some random data for document ${i} by worker ${workerId}`
      });

      await randomSleep();
    }

    console.log(`Worker ${workerId}: Inserted ${docsPerWorker} documents`);
  } catch (error) {
    console.error(`Worker ${workerId}: Error occurred:`, error);
  } finally {
    await client.close();
    console.log(`Worker ${workerId}: Connection closed`);
  }
}

function startStressTest(numWorkers, docsPerWorker, dbUrl) {
  for (let i = 1; i <= numWorkers; i++) {
    runStressTest(i, docsPerWorker, dbUrl);
  }
}

const numWorkers = 5;
const docsPerWorker = 1000;
const dbUrl = 'mongodb://mongodb-test:27017';

startStressTest(numWorkers, docsPerWorker, dbUrl);
