GOPATH:=$(shell go env GOPATH)
MODIFY=Mproto/imports/api.proto=github.com/micro/go-micro/v2/api/proto

.PHONY: dep
dep:
	@echo "installing dependence..."
	@go get -v -x && go mod tidy

.PHONY: proto
proto:
	@echo "protocing..."
	@protoc --proto_path=. --micro_out=${MODIFY}:. --go_out=${MODIFY}:. proto/helloworld/helloworld.proto

.PHONY: test
test: dep proto
	go test -v ./... -cover

.PHONY: build
build: proto
	@echo "building..."
	@go build -v -o helloworld_srv *.go

.PHONY: run
run: proto
	@echo "running..."
	@go run main.go

.PHONY: docker_build
docker_build: dep proto
	@docker build -t helloworld_srv:latest .

.PHONY: docker_run
docker_run:
	@docker run -p 30000:30000 -e MICRO_SERVER_ADDRESS=:30000 -e MICRO_REGISTRY=mdns helloworld_srv
