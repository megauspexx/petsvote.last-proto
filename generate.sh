#!/bin/bash

set -e

echo "🧹 Cleaning old files..."
rm -rf go python apidocs.swagger.yaml proto.protoset

# Получаем пути к зависимостям
VALIDATE_DIR=$(go list -f '{{ .Dir }}' -m github.com/envoyproxy/protoc-gen-validate 2>/dev/null || echo "")
MICRO_PROTO_DIR=$(go list -f '{{ .Dir }}' -m go.unistack.org/micro-proto/v3 2>/dev/null || echo "")

# Собираем пути для импорта
INC="-I."
if [ -n "$VALIDATE_DIR" ]; then
    INC="$INC -I$VALIDATE_DIR"
    echo "📁 Found validate at: $VALIDATE_DIR"
fi
if [ -n "$MICRO_PROTO_DIR" ]; then
    INC="$INC -I$MICRO_PROTO_DIR"
    echo "📁 Found micro-proto at: $MICRO_PROTO_DIR"
fi

echo "📦 Generating protos..."

# создаём структуру заранее
mkdir -p go/grpc

echo "📦 step 1: generate micro (ONLY grpc)"
protoc $INC \
    --go-micro_out=go/grpc \
    --go-micro_opt=components="grpc",standalone=true,paths=source_relative \
    *.proto

echo "📦 step 2: generate pb models"
protoc $INC \
    --go_out=go \
    --go_opt=paths=source_relative \
    *.proto

echo "📦 step 3: generate validate"
protoc $INC \
    --validate_out="lang=go:go" \
    --validate_opt=paths=source_relative \
    *.proto

echo "✅ Generation completed!"

echo "📁 Files in go/:"
ls -la go/ | head -20

echo "📁 Files in go/grpc/:"
ls -la go/grpc/ | head -20
