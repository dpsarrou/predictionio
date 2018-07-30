#!/bin/bash

# Install the universal recommender engine template
curl -L https://github.com/actionml/universal-recommender/archive/0.7.0.tar.gz -o /tmp/ur.tar.gz \
    && mkdir /tmp/ur && tar -xvzf /tmp/ur.tar.gz -C /tmp/ur \
    && mkdir /root/ur && mv -T /tmp/ur/universal-recommender-0.7.0 /root/ur/ \
    && rm /tmp/ur.tar.gz

sed -i '/Local Repository/c\resolvers += "Local Repository" at "file:///mahout/.custom-scala-m2/repo"' /root/ur/build.sbt