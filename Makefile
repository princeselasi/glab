GLAB_VERSION ?= $(shell git describe --tags 2>/dev/null || git rev-parse --short HEAD)
DATE_FMT = +%Y-%m-%d
ifdef SOURCE_DATE_EPOCH
    BUILD_DATE ?= $(shell date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u "$(DATE_FMT)")
else
    BUILD_DATE ?= $(shell date "$(DATE_FMT)")
endif

ifndef CGO_CPPFLAGS
    export CGO_CPPFLAGS := $(CPPFLAGS)
endif
ifndef CGO_CFLAGS
    export CGO_CFLAGS := $(CFLAGS)
endif
ifndef CGO_LDFLAGS
    export CGO_LDFLAGS := $(LDFLAGS)
endif

GO_LDFLAGS := -X main.version=$(GLAB_VERSION) $(GO_LDFLAGS)
GO_LDFLAGS := -X main.build=$(BUILD_DATE) $(GO_LDFLAGS)

build:
	go build -trimpath -ldflags "$(GO_LDFLAGS) -X  main.usageMode=prod" -o ./bin/glab ./cmd/glab
run:
	go run -trimpath -ldflags "$(GO_LDFLAGS) -X main.usageMode=dev" ./cmd/glab $(var)
test:
	go test ./...
rt: #Test release
	goreleaser --snapshot --skip-publish --rm-dist
rtdebug: #Test release
	goreleaser --snapshot --skip-publish --rm-dist --debug
release:
	goreleaser $(var)
gen-docs:
	go run ./cmd/gen-docs/docs.go
	cp ./docs/glab.md ./docs/index.md
