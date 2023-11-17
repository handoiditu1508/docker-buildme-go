# syntax=docker/dockerfile:1
FROM golang:1.20-alpine
WORKDIR /src
COPY go.mod go.sum /
RUN go mod download
COPY . .
RUN go build -o /bin/client ./cmd/client
RUN go build -o /bin/server ./cmd/server

FROM scratch
COPY --from=0 /bin/client /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]

# build image:
# docker build --tag=buildme .

# check image's size:
# docker images buildme

# run container from image in detached mode:
# docker run --name=buildme --rm --detach buildme

# invoke client library:
# docker exec -it buildme /bin/client

# stop container:
# docker stop buildme