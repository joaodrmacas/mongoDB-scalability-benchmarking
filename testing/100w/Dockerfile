FROM node:18

WORKDIR /app

EXPOSE 27018
EXPOSE 27023

COPY client.js .

RUN npm init -y
RUN npm install mongodb async
RUN npm install
