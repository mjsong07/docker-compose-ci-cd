FROM node:11.6.0
RUN mkdir -p /home/Service
WORKDIR /home/Service
 
COPY . /home/Service
RUN yarn install
 
EXPOSE 3000
 
CMD [ "node", "index.js" ]