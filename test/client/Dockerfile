FROM node:18

WORKDIR /app

COPY client.js .

RUN npm init -y
RUN npm install mongodb
RUN npm install

EXPOSE 27017

CMD ["node", "client.js"]