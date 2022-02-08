FROM node:17-alpine as base

# install docker
RUN apk add --update curl docker openrc
RUN rc-update add docker boot

WORKDIR /usr/app
EXPOSE 3000

# ---------- PRE-REQS ----------
FROM base as prereq
COPY ./package*.json ./
RUN npm install --silent --unsafe-perm --no-audit --no-progress --only=production

# ---------- DEVELOPMENT ----------
FROM prereq as development
RUN npm install --silent --unsafe-perm --no-audit --no-progress --only=development
COPY ./src ./src
CMD npm run debug

# -------- PRODUCTION --------
FROM prereq as production
COPY ./src ./src
CMD npm run start
