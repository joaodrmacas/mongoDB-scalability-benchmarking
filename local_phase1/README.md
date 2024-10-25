# Project ESLE G7
António Oliveira: antonio.koch@tecnico.ulisboa.pt, Student Number: 104010 \
João Maçãs: joaomacas02@tecnico.ulisboa.pt, Student Number: 99970 \
Miguel Parece: miguelparece@tecnico.ulisboa.pt, Student Number: 103369

## Project choice:
[MongoDB](https://www.mongodb.com/) is a source-available, cross-platform, document-oriented database program. Classified as a NoSQL database product, MongoDB utilizes JSON-like documents with optional schemas. MongoDB is developed by MongoDB Inc. and current versions are licensed under the Server Side Public License (SSPL). MongoDB is a member of the MACH Alliance. 

## Note:
The commands & scripts assume you have access to the docker socket `/var/run/docker.sock` (e.g. they don't use sudo).

## Setup

Build the client/testing containers when you clone the repo (and if you modify the client.js)
```
./build_containers.sh
```

This builds the client containers:
- client_100w (100% writes)
- client_100r (100% reads)
- client_75r.25w (75% reads, 25% writes)

## How to run

1. Start the mongodb server(s):
```
docker compose -f docker-compose.yml up --detach
```

2. Configure the mongodb topology:
```
./configure_topology.sh
```

3. Run the client (**template**). The args have the following format
```
# docker run -it --network host `clientImage` node client.js `numShards` `routerConfig`
```
Where:
- clientImage is: `client_100w | client_100r | client_75r.25w`
- numShards is: `1 | 2 | 3`
- routerConfig is: `-r1 | -r2`

Here an example
```
docker run -it --network host client_100w node client.js 3 -r1
```
Which tests mongodb with `3 shards` and `1 router` using the client `client_100w`

## View Results

The results of the client are printed to the terminal but are also stored as a `.csv` file insid the client container. After the client exited you can run the following command to obtain the csv file.
```
docker cp {client_container_name}:/app/results.csv {dest_folder}
```