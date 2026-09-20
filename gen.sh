#!/usr/bin/env bash
# Generate protobuf code from rotom.proto into ./out/<lang>/
#
# Usage:
#   ./gen.sh                       # python + csharp + descriptor (default)
#   ./gen.sh -l go                 # only go
#   ./gen.sh -l python,csharp      # only python + csharp
#   ./gen.sh -l all                # every supported language
#   ./gen.sh -l list               # show supported languages
#   ./gen.sh -o build -l go        # custom output dir
#
# External plugins (only needed for those languages):
#   go:      go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#   grpc-go: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
set -euo pipefail

cd "$(dirname "$0")"

OUT_DIR="out"
PROTO_FILE="rotom.proto"
LANGS="python,csharp,descriptor"

usage() {
  echo "Usage: $0 [-l lang1,lang2,...] [-o out_dir] [-h]"
  echo "Languages: python, csharp, cpp, java, kotlin, objc, php, ruby, rust,"
  echo "           go, grpc-go, descriptor, all, list"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--lang) LANGS="${2:-}"; shift 2 ;;
    -o|--out) OUT_DIR="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

SUPPORTED="python csharp cpp java kotlin objc php ruby rust go grpc-go descriptor"

if [[ "$LANGS" == "list" ]]; then
  echo "Supported languages: $SUPPORTED (+ all)"
  exit 0
fi

if [[ "$LANGS" == "all" ]]; then
  LANGS="$SUPPORTED"
fi

# Split comma/space separated list into array.
IFS=', ' read -r -a LANG_LIST <<< "$LANGS"

# Validate requested languages.
for lang in "${LANG_LIST[@]}"; do
  [[ -z "$lang" ]] && continue
  valid=0
  for s in $SUPPORTED; do
    if [[ "$lang" == "$s" ]]; then valid=1; break; fi
  done
  if [[ $valid -eq 0 ]]; then
    echo "Unknown language: $lang" >&2
    usage
    exit 1
  fi
done

want() {
  local needle="$1"; shift
  for l in "${LANG_LIST[@]}"; do
    [[ "$l" == "$needle" ]] && return 0
  done
  return 1
}

if ! command -v protoc >/dev/null 2>&1; then
  echo "ERROR: protoc not found in PATH." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

PROTOC_ARGS=(--proto_path=.)
GENERATED=()

if want python; then
  mkdir -p "$OUT_DIR/python"
  PROTOC_ARGS+=(--python_out="$OUT_DIR/python" --pyi_out="$OUT_DIR/python")
  GENERATED+=("$OUT_DIR/python")
fi

if want csharp; then
  mkdir -p "$OUT_DIR/csharp"
  PROTOC_ARGS+=(--csharp_out="$OUT_DIR/csharp")
  GENERATED+=("$OUT_DIR/csharp")
fi

if want cpp; then
  mkdir -p "$OUT_DIR/cpp"
  PROTOC_ARGS+=(--cpp_out="$OUT_DIR/cpp")
  GENERATED+=("$OUT_DIR/cpp")
fi

if want java; then
  mkdir -p "$OUT_DIR/java"
  PROTOC_ARGS+=(--java_out="$OUT_DIR/java")
  GENERATED+=("$OUT_DIR/java")
fi

if want kotlin; then
  mkdir -p "$OUT_DIR/kotlin"
  PROTOC_ARGS+=(--kotlin_out="$OUT_DIR/kotlin")
  GENERATED+=("$OUT_DIR/kotlin")
fi

if want objc; then
  mkdir -p "$OUT_DIR/objc"
  PROTOC_ARGS+=(--objc_out="$OUT_DIR/objc")
  GENERATED+=("$OUT_DIR/objc")
fi

if want php; then
  mkdir -p "$OUT_DIR/php"
  PROTOC_ARGS+=(--php_out="$OUT_DIR/php")
  GENERATED+=("$OUT_DIR/php")
fi

if want ruby; then
  mkdir -p "$OUT_DIR/ruby"
  PROTOC_ARGS+=(--ruby_out="$OUT_DIR/ruby")
  GENERATED+=("$OUT_DIR/ruby")
fi

if want rust; then
  mkdir -p "$OUT_DIR/rust"
  PROTOC_ARGS+=(--rust_out="$OUT_DIR/rust")
  GENERATED+=("$OUT_DIR/rust")
fi

if want go; then
  if ! command -v protoc-gen-go >/dev/null 2>&1; then
    echo "ERROR: protoc-gen-go not found. Install it with:" >&2
    echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest" >&2
    exit 1
  fi
  mkdir -p "$OUT_DIR/go"
  PROTOC_ARGS+=(--go_out="$OUT_DIR/go" --go_opt=paths=source_relative)
  GENERATED+=("$OUT_DIR/go")
fi

if want grpc-go; then
  if ! command -v protoc-gen-go-grpc >/dev/null 2>&1; then
    echo "ERROR: protoc-gen-go-grpc not found. Install it with:" >&2
    echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest" >&2
    exit 1
  fi
  mkdir -p "$OUT_DIR/grpc-go"
  PROTOC_ARGS+=(--go-grpc_out="$OUT_DIR/grpc-go" --go-grpc_opt=paths=source_relative)
  GENERATED+=("$OUT_DIR/grpc-go")
fi

if want descriptor; then
  PROTOC_ARGS+=(--descriptor_set_out="$OUT_DIR/rotom.pb" --include_source_info)
  GENERATED+=("$OUT_DIR/rotom.pb")
fi

if [[ ${#GENERATED[@]} -eq 0 ]]; then
  echo "Nothing to generate." >&2
  usage
  exit 1
fi

protoc "${PROTOC_ARGS[@]}" "$PROTO_FILE"

echo "Generated into $OUT_DIR/:"
for g in "${GENERATED[@]}"; do
  echo "  $g"
done

