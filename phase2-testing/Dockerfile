FROM node:18

WORKDIR /app

COPY write_client.js .
COPY read_client.js .
COPY server.js .

RUN npm init -y && npm install mongodb async

CMD ["node", "server.js"]
