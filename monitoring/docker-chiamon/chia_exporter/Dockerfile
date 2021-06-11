FROM golang:alpine AS builder

WORKDIR /build
RUN apk add --update --no-cache --virtual build-dependencies git make \
 && git clone https://github.com/adavarski/chia-small-farming \
 && cd chia-small-farming/monitoring/chia_exporter \
 && go build -tags netgo \
 && cp chia_exporter /tmp

FROM alpine
COPY --from=builder  /tmp/chia_exporter /usr/bin/chia_exporter

ENTRYPOINT ["/usr/bin/chia_exporter"]
