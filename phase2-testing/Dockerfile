FROM node:18

WORKDIR /app

COPY client.js .

RUN npm init -y && npm install mongodb async

CMD ["node", "client.js"]
