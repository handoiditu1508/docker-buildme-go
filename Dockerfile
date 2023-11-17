# syntax=docker/dockerfile:1
FROM golang:1.20-alpine AS base
WORKDIR /src
COPY go.mod go.sum /
RUN --mount=type=cache,target=/go/pkg/mod/ \
    go mod download -x
COPY . .

FROM base AS build-client
RUN --mount=type=cache,target=/go/pkg/mod/ \
    go build -o /bin/client ./cmd/client

FROM base AS build-server
RUN --mount=type=cache,target=/go/pkg/mod/ \
    go build -o /bin/server ./cmd/server

FROM scratch as client
COPY --from=build-client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]

FROM scratch as server
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]


# clear build cache to see exactly what the build is doing:
# (warning build command will be slow after clear cache since it have to redownload)
# docker builder prune -af

# build client image and log to file:
# docker build --target=client --progress=plain . 2> log1.txt

# run go command in a golang image to update package version
# docker run -v $PWD:$PWD -w $PWD golang:1.21-alpine \
#   go get github.com/go-chi/chi/v5@v5.0.8

# rebuild client image and log to file:
# docker build --target=client --progress=plain . 2> log2.txt