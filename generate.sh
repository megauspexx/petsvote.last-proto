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

echo "📦 step 1"
# 1. Генерация gRPC standalone файлов
mkdir -p go/grpc
protoc $INC \
    --go-micro_out=go/grpc --go-micro_opt=components="grpc",standalone=true,paths=source_relative \
    *.proto

echo "📦 step 2"
# 2. Генерация основных Go файлов
protoc $INC \
    --go_out=. --go_opt=paths=source_relative \
    --validate_out="lang=go:." --validate_opt=paths=source_relative \
    *.proto

#echo "📦 step 3"
## 3. Генерация micro файлов (без graphql компонента)
#protoc $INC \
#    --go-micro_out=. --go-micro_opt=paths=source_relative \
#    *.proto


echo "✅ Generation completed!"

# Перемещаем сгенерированные файлы в правильную структуру если нужно
if [ -f "go.mod" ]; then
    echo "📁 Organizing files..."
    # Создаем структуру как на скриншоте
    mkdir -p go/grpc
    # Перемещаем все .pb.go файлы в go/grpc если они в корне
    mv *.pb.go go/grpc/ 2>/dev/null || true
fi

echo "📁 Generated files in go/grpc/:"
ls -la go/grpc/ 2>/dev/null | head -20