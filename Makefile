current_dir := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

.PHONY: generate
generate:
	@echo "📦 Generating protos locally..."
	@chmod +x generate.sh
	@./generate.sh
	@echo "✅ Generation completed"

.PHONY: clean
clean:
	rm -rf go python apidocs.swagger.yaml proto.protoset
	@echo "🧹 Cleaned generated files"

.PHONY: all
all: clean generate
	@echo "🎉 Full regeneration completed"