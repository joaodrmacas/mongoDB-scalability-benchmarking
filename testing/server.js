const async = require('async');
const fs = require('fs');

// Your MongoDB code or any other logic
console.log('Script running...');

// Function to log the current hour
const logCurrentHour = () => {
    const now = new Date();
    const hours = now.getHours(); // Get current hour
    console.log(`Alive: ${hours}`);
};

// Keeping the application alive and logging the current hour every 10 seconds
setInterval(() => {
    logCurrentHour(); // Call the function to log the hour
}, 60000); // Logs every 10 seconds
