# Nginx-unit Python3.11 Docker image

This Dockerfile configuration is super-slim version of official nginx-unit docker image for python.
The problem with official image is its weight – ~1000Mb and the use of Debiam base image.
This image uses multistage build on Alpine with Python 3.11
It's still WIP and I will be working on additional optimization and implement variables for ease of use
