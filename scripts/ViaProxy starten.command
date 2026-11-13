#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
jar="$script_dir/ViaProxy.jar"
run_dir="$HOME/minecraft-viaproxy"
java=/opt/homebrew/opt/openjdk@25/bin/java

if [ ! -f "$jar" ]; then
    printf '%s\n' "ViaProxy.jar muss neben diesem Startskript liegen." >&2
    exit 1
fi
if [ ! -x "$java" ]; then
    printf '%s\n' "Java 25 wurde unter $java nicht gefunden." >&2
    exit 1
fi
if [ ! -d "$run_dir" ]; then
    printf '%s\n' "Der ViaProxy-Ordner mit deinen Einstellungen fehlt unter $run_dir." >&2
    exit 1
fi

cd "$run_dir"
export VP_RUN_DIR="$run_dir"
exec "$java" -jar "$jar" "$@"
