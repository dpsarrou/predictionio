# Apache PredictionIO with docker-compose

Run Apache Prediction IO in configurable docker services.
You can configure the template

## Requirements

- Docker
- Docker-compose (if using DockerForMac this is already included)

## Services

This will setup the following services:

- pio_db: A Postgres database that will store the events and the model
- elasticsearch: An elasticsearch 5.5.x database
- pio_events: The predictionIO service that gathers all events and listens to 7070 port
- pio_app: The predictionIO app service that hosts the prediction engine and allows for quering predictions on port 8000.

You should read `docker-compose.yml` for more details.

## Usage

Run `docker-compose up -d`. This will automatically download the required base images, build (if not already) and start the services.
If you want the resource limits to be applied, run it with compatibility flag, since docker-compose.yml v3 deprecated those in favor of deployment limits in docker swarm. `docker-compose --compatibility up -d`

You can then access the services using the accessKey you have defined for your app in docker-compose.yml:

- Submit and store events: http://localhost:7070/events.json?accessKey=
- Query for predictions: http://localhost:8000

## Notes:

You need to submit data to the event store in order for the prediction query service to be able to train a model. If you cannot access the prediction service at http://localhost:8000 then it most probably means you did not input any data.

For some temporary data use the script `./data/importdata.sh` that will do a couple of HTTP requests to feed the engine.

## Template Engines

This setup has been tested with the Similar-Product engine.
You can find example of events you can send and more info here:
https://predictionio.apache.org/templates/similarproduct/quickstart/


It also includes some of the heavy work needed for running the latest version of the Universal Recommender engine. However that version has very specific build tasks, including a custom build of Apache Mahout that delays the process a lot and requires some changes in config files that will simply take much time to make generic and support in this setup. Therefore I've included the tedious custom built tasks of Mahout, but you will need to configure and build the engine on your own. I'm looking at a potential solution of having a custom installation script per engine that can be defined in docker-compose as a build Arg. I will evaluate that approach some time later if I have the free time.





