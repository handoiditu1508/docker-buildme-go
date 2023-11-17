# syntax=docker/dockerfile:1
FROM golang:1.20-alpine AS base
WORKDIR /src
COPY go.mod go.sum /
RUN go mod download
COPY . .

FROM base AS build-client
RUN go build -o /bin/client ./cmd/client

FROM base AS build-server
RUN go build -o /bin/server ./cmd/server

FROM scratch as client
COPY --from=build-client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]

FROM scratch as server
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]

# build client image:
# docker build --tag=buildme-client --target=client .

# build server image:
# docker build --tag=buildme-server --target=server .

# check images's size:
# docker images buildme*

# run containers from images in detached mode (currently not working):
# docker run --name=buildme-server --rm --detach buildme-server
# docker run --name=buildme-client --rm -it buildme-client

# stop containers:
# docker stop buildme-client
# docker stop buildme-server
