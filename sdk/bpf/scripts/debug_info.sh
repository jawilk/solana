#!/usr/bin/env bash

bpf_sdk=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=sdk/bpf/env.sh
source "$bpf_sdk"/env.sh

so=$1
debug_info=$2
if [[ -z $so ]] || [[ -z $debug_info ]]; then
  echo "Usage: $0 bpf-program.so debug_info.dbg" >&2
  exit 1
fi

if [[ ! -r $so ]]; then
  echo "Error: File not found or readable: $so" >&2
  exit 1
fi

set -e
out_dir=$(dirname "$debug_info")
if [[ ! -d $out_dir ]]; then
  mkdir -p "$out_dir"
fi

(
  set -ex
  ls -la "$so" > "$debug_info"
  "$bpf_sdk"/dependencies/bpf-tools/llvm/bin/llvm-objcopy --only-keep-debug "$so" "$debug_info"
)

if [[ ! -f "$debug_info" ]]; then
  echo "Error: Failed to create $debug_info" >&2
  exit 1
fi

echo >&2
echo "Wrote $debug_info" >&2
