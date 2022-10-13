FROM node:latest as builder
WORKDIR /app
COPY ./app .
RUN npm install
RUN npm i @angular/cli
RUN npm run build

FROM nginx:alpine as runner
COPY --from=builder /app/dist/demo-app /usr/share/nginx/html

EXPOSE 80