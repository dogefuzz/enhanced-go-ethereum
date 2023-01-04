FROM golang:1.10.2-alpine3.7 as builder

RUN apk add --update git go make gcc musl-dev linux-headers

# WORKDIR /instabul

# RUN git clone https://github.com/getamis/istanbul-tools.git /instabul
# RUN make
# RUN chmod a+rx /instabul/build/bin/istanbul

WORKDIR /geth
ADD . .
RUN make geth

FROM alpine:3.7

WORKDIR /app

RUN apk add --update bash
# COPY --from=builder /instabul/build/bin/instabul /usr/local/bin
COPY --from=builder /geth/build/bin/geth /usr/local/bin/
ADD entrypoint.sh  entrypoint.sh

EXPOSE 8545
EXPOSE 30303
EXPOSE 30303/udp

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]