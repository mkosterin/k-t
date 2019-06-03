FROM mhart/alpine-node:slim-12
#FROM node:carbon
WORKDIR /app
COPY testcase-pybash/index.js /app
CMD [ "node", "index.js" ]

