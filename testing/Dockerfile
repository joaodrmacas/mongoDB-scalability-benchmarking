# Use the official Node.js image as the base
FROM node:18

# Set the working directory
WORKDIR /app

# Copy the JavaScript files into the container
COPY 100r.js .
COPY 100w.js .
COPY 7525rw.js .
COPY server.js .

# Initialize npm and install dependencies
RUN npm init -y && npm install mongodb async

# Keep the application running with the server.js script
CMD ["node", "server.js"]
