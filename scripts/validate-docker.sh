#!/bin/bash

images=$(docker images);
if [ $? -ne 0 ]; then 
  echo "Docker returned an error code. Validate that it is running."
  exit 1; 
fi
