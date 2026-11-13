#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
    printf '%s\n' "Usage: $0 STOCK_VIAPROXY_JAR VIABEDROCK_CHECKOUT OUTPUT_JAR" >&2
    exit 1
fi

proxy_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
stock_jar=$1
bedrock_root=$(CDPATH= cd -- "$2" && pwd)
output_jar=$3
bedrock_commit=6aa3fa3bc501ebe0eb0b0b77961d7fe7b9df61d2
stock_sha=be8aa85dad197d6254088c06a18701ecc307330603500d5b55931da27094b234

if [ ! -r "$stock_jar" ] || [ -e "$output_jar" ]; then
    printf '%s\n' "Provide a readable stock JAR and a new output path." >&2
    exit 1
fi
if [ "$(shasum -a 256 < "$stock_jar" | cut -d ' ' -f 1)" != "$stock_sha" ]; then
    printf '%s\n' "The stock JAR does not match the tested ViaProxy build." >&2
    exit 1
fi

build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
trap 'exit 1' HUP INT TERM
mkdir "$build_dir/proxy" "$build_dir/bedrock" "$build_dir/classes"
git -C "$proxy_root" archive --format=zip --output="$build_dir/proxy.zip" HEAD
git -C "$bedrock_root" archive --format=zip --output="$build_dir/bedrock.zip" "$bedrock_commit"
unzip -q "$build_dir/proxy.zip" -d "$build_dir/proxy"
unzip -q "$build_dir/bedrock.zip" -d "$build_dir/bedrock"

proxy="$build_dir/proxy/src/main/java/net/raphimc/viaproxy"
bedrock="$build_dir/bedrock/src/main/java/net/raphimc/viabedrock"
resources="$build_dir/bedrock/src/main/resources"

"${JAVAC:-javac}" --release 17 -cp "$stock_jar" -d "$build_dir/classes" \
    "$proxy/proxy/client2proxy/Client2ProxyHandler.java" \
    "$bedrock/api/model/container/player/HudContainer.java" \
    "$bedrock/api/model/entity/ArmadilloEntity.java" \
    "$bedrock/api/model/entity/Entity.java" \
    "$bedrock/protocol/packet/EntityPackets.java" \
    "$bedrock/protocol/rewriter/EntityMetadataRewriter.java" \
    "$bedrock/protocol/storage/ChunkTracker.java" \
    "$bedrock/protocol/storage/EntityTracker.java"

cp "$stock_jar" "$build_dir/ViaProxy.jar"
"${JAR:-jar}" --update --file "$build_dir/ViaProxy.jar" \
    -C "$build_dir/classes" net \
    -C "$resources" assets/viabedrock/data/bedrock/entity_data_types.json
unzip -tq "$build_dir/ViaProxy.jar"
cp "$build_dir/ViaProxy.jar" "$output_jar"
