# base-image for node on any machine using a template variable,
# see more about dockerfile templates here: http://docs.resin.io/deployment/docker-templates/
# and about resin base images here: http://docs.resin.io/runtime/resin-base-images/
# Note the node:slim image doesn't have node-gyp
FROM resin/raspberrypi3-node:8-slim

# use apt-get if you need to install dependencies,
# for instance if you need ALSA sound utils, just uncomment the lines below.
#RUN apt-get update && apt-get install -yq \
#    alsa-utils libasound2-dev && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -yq \
      python3=3.4.2-2 sense-hat raspberrypi-bootloader i2c-tools build-essential \
      libssl-dev libffi-dev libyaml-dev python3-dev python3-pip python-rpi.gpio git && \
    pip3 install sense-hat rtimulib pillow 

# Defines our working directory in container
WORKDIR /usr/src/app

# Copies the package.json first for better cache on later pushes
COPY package.json package.json

# This install npm dependencies on the resin.io build server,
# making sure to clean up the artifacts it creates in order to reduce the image size.
RUN JOBS=MAX npm install --unsafe-perm && npm cache clean --force && rm -rf /tmp/*

RUN apt-get remove build-essential libssl-dev libffi-dev libyaml-dev python3-dev python3-pip git \
    && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# This will copy all files in our root to the working  directory in the container
COPY . ./

# Enable systemd init system in container
ENV INITSYSTEM on

# server.js will run when container starts up on the device
CMD ["npm", "start"]
