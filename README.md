The goal of this repo is to test NEURON models in a Jupyter notebook that will work across workstations.

To run, first build the docker file with something like:

```
docker build -t nrn -f Dockerfile .
```

Then run the docker image with something like:

```
docker run -p 8888:8888 nrnu:latest
```

Then you can edit NEURON models through Python/Jupyter at http://localhost:8888/ and visualize the electrophys output with matplotlib.

Mostly adapted from the helpful dockerfile by DaisukeMiyamoto: https://github.com/DaisukeMiyamoto/docker-neuron
