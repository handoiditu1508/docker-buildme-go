# syntax=docker/dockerfile:1
ARG GO_VERSION=1.20
ARG GOLANGCI_LINT_VERSION=1.52
FROM golang:${GO_VERSION}-alpine AS base
WORKDIR /src
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

FROM base AS build-client
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    go build -o /bin/client ./cmd/client

FROM base AS build-server
ARG APP_VERSION="v0.0.0+unknown"
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    go build -ldflags "-X main.version=${APP_VERSION}" -o /bin/server ./cmd/server

FROM scratch as client
COPY --from=build-client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]

FROM scratch as server
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]

FROM scratch AS binaries
COPY --from=build-client /bin/client /
COPY --from=build-server /bin/server /

FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION} as lint
WORKDIR /test
RUN --mount=type=bind,target=. \
    golangci-lint run

# builds the server image for the linux/arm/v7 platform:
# docker build --target=server --platform=linux/arm/v7 .