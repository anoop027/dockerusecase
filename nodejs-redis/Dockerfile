FROM node:14.14.0-alpine
WORKDIR /usr/app
COPY ./package*.json ./
RUN npm install
COPY ./ ./
EXPOSE 8082
CMD ["npm", "start"]
