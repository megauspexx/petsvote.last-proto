//go:build tools

package tools

import (
	_ "github.com/envoyproxy/protoc-gen-validate"
	_ "go.unistack.org/micro-proto/v3"
	_ "go.unistack.org/micro/v3"
	_ "go.unistack.org/protoc-gen-go-micro/v3"
	_ "google.golang.org/protobuf/cmd/protoc-gen-go"
)
