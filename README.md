# Apache PredictionIO in docker

Run Apache Prediction IO using docker.
Features include being able to select the template engine as long as it supports
the default setup: (clone, build, rename engine.json, train, deploy).
For custom actions please refer to `Makefile` and `config/pio_app.sh`

## Requirements

- Docker
- Docker-compose (if using DockerForMac this is already included)

## Installation

We need to setup some environment variables first.
- Step 1. Copy `.env.example` to `.env`. In that file adjust the parameter values according
    to your needs.

- Step 2. Run `make build` to build the containers and the recommendation engine.

## Usage

- Run `make app` to start the application.

- Run `make stop` to stop the application.

- Run `make clean` to stop the application and delete all data.

To submit data to the recommendation engine for your app make http request to `http://localhost:7070/events.json?accessKey=M41jRfbEXGoHTxyLbn6jxpL2xnfoyxz_Psm0AMfSbzNBXOWphHO3Q1GfOUg3P6O5` where
`accessKey` is the value of `PIO_APP_KEY` as defined in the `.env` file.

To query data and predictions make http requests to `http://localhost:8000`.

You can read more about what kind of data you can send and query on https://predictionio.apache.org/templates/similarproduct/quickstart/ specifically Step 4 and on. This repository has already implemented the previous steps.

## Troubleshooting & FAQ

- If you cannot access the query service at `http://localhost:8000` this probably because
you have not sent any events to the events service. To be able to train a model and query for 
predictions you must first record some events.

- You need to send your own data, but if you want to play around with some sample data run `make sampledata`. This will run the script `./data/importdata.sh` which will do a couple of HTTP requests to feed the engine.

- The first build of a template engine is very slow. For reference 
building the Similar-Product engine for the first time takes ~30minutes on a late 2017 macbook.

**After you have inputted data, it might take about 1 minute for the http://localhost:8000 page to be accessible.**

## Services

The following services are defined:

- pio_db: A Postgres database that will store the events and the model
- elasticsearch: An elasticsearch database for the model metadata
- pio_events: The events service that records all events. Access it on http://localhost:7070
- pio_app: The recommendation service that hosts the prediction engine and allows for quering predictions on port http://localhost:8000.

You can read `docker-compose.yml` for more details.

## Template Engines

This setup has been tested with the Similar-Product engine.
You can find example of events you can send and more info in the official documentation:
https://predictionio.apache.org/templates/similarproduct/quickstart/

More engines that use the same installation steps are supported.
You can do that changing the `.env` file:

1. Setting `PIO_ENGINE` to the url of the template engine. You can find template engines on https://predictionio.apache.org/gallery/template-gallery/

2. Run `make engine` to build the engine. Note that you need to clean your data and installation if you already had installed a different engine before. Use `make clean` to do that.

## About the approach

1. Dockerfile: I used multistage builds for docker to take advantage of caching layers and to 
prevent rebuilding the whole image when updating version of a single vendor dependency.

2. Template engine: The template engine is been downloaded and built after the containers
have started and not in the Dockerfile build process. This is to allow for different
template engines to be used with the same platform, configurable from the environment
variables.

3. Persistent storage: In order to minimize the time spent building the recommendation engine
(it really took >30minutes on my machine) `named volumes` are used to persist the
home directory. This speeds up considerably subsequent engine builds (now take ~5 seconds).