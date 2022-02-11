FROM alpine

# install docker
RUN apk add --update curl docker openrc
RUN rc-update add docker boot

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"