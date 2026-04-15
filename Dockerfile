FROM golang:1.24-alpine

# Установка необходимых пакетов
RUN apk add --no-cache \
    git \
    make \
    protoc \
    protobuf-dev \
    bash \
    python3 \
    py3-pip \
    py3-grpcio \
    py3-grpcio-tools

# Установка protoc-gen-go
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0

# Установка protoc-gen-validate
RUN go install github.com/envoyproxy/protoc-gen-validate@v1.0.2

# Установка protoc-gen-go-micro
RUN go install go.unistack.org/protoc-gen-go-micro/v3@latest

# Установка Python зависимостей
RUN pip3 install --upgrade pip && \
    pip3 install grpcio grpcio-tools grpclib protobuf

# Создание рабочей директории
RUN mkdir -p /build
WORKDIR /build

# Git config для безопасности
RUN git config --global --add safe.directory /build

# Копирование скрипта генерации
COPY generate.sh /generate.sh
RUN chmod +x /generate.sh

ENTRYPOINT ["sh"]
CMD ["./generate.sh"]


#FROM registry.gitlab.fortebank.com/domains/proto-gen:v0.0.6
#RUN mkdir -p /build
#WORKDIR /build
#
#RUN apt-get update && apt-get -y install --no-install-recommends protobuf-compiler-grpc python3-grpc-tools libprotobuf-dev protobuf-compiler python3-pip python3-dev python3-pip python3-setuptools ca-certificates openssl && rm -rf /var/lib/apt/lists/*
#RUN python3 -m pip install --upgrade pip && python3 -m pip install grpcio grpcio-tools grpclib protobuf googleapis-common-protos protoc-gen-validate
#
#ARG REPO_HOST=gitlab.fortebank.com
#
#RUN go env -w GOBIN=/usr/local/bin GONOPROXY="$REPO_HOST/*" GONOSUMDB="$REPO_HOST/*"
#
#RUN go install go.unistack.org/protoc-gen-go-micro/v3@latest
#RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0
#RUN go install github.com/envoyproxy/protoc-gen-validate@v1.0.2
#RUN go install github.com/envoyproxy/protoc-gen-validate/cmd/protoc-gen-validate-go@v1.0.2
##RUN go mod init proto || true
##RUN go mod tidy
#
## fixes situation when $(git config --get remote.origin.url) returns empty string
#RUN git config --global --add safe.directory /build
#
#ENTRYPOINT [ "sh" ]
#CMD ["./generate.sh"]