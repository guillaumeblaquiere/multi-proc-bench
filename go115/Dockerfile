# Use the offical Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.15 as builder

# Copy local code to the container image.
WORKDIR /go/src/
COPY go.mod .
ENV GO111MODULE=on
RUN go mod download

COPY . .

# Perform test for building a clean package
RUN go test -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -v -o server

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds

# Now copy it into our base image.
FROM gcr.io/distroless/base
#RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/server /server
CMD ["/server"]


