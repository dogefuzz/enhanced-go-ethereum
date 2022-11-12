FROM golang:1.10.2-alpine3.7 as builder

WORKDIR /geth
ADD . .

RUN apk add --update git go make gcc musl-dev linux-headers
RUN make geth

FROM alpine:3.7

WORKDIR /app

COPY --from=builder /geth/build/bin/geth /usr/local/bin/
ADD entrypoint.sh  entrypoint.sh

EXPOSE 8545
EXPOSE 30303
EXPOSE 30303/udp

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]